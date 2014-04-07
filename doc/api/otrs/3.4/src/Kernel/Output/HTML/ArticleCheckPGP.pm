# --
# Kernel/Output/HTML/ArticleCheckPGP.pm
# Copyright (C) 2001-2014 OTRS AG, http://otrs.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package Kernel::Output::HTML::ArticleCheckPGP;

use strict;
use warnings;

use MIME::Parser;

use Kernel::System::Crypt;
use Kernel::System::EmailParser;

use Kernel::System::VariableCheck qw(:all);

sub new {
    my ( $Type, %Param ) = @_;

    # allocate new hash for object
    my $Self = {};
    bless( $Self, $Type );

    # get needed objects
    for (
        qw(ConfigObject LogObject EncodeObject MainObject DBObject LayoutObject UserID TicketObject ArticleID)
        )
    {
        if ( $Param{$_} ) {
            $Self->{$_} = $Param{$_};
        }
        else {
            $Self->{LogObject}->Log( Priority => 'error', Message => "Need $_!" );
        }
    }

    return $Self;
}

sub Check {
    my ( $Self, %Param ) = @_;

    my %SignCheck;
    my @Return;

    # check if pgp is enabled
    return if !$Self->{ConfigObject}->Get('PGP');

    # check if article is an email
    return if $Param{Article}->{ArticleType} !~ /email/i;

    my $StoreDecryptedData = $Self->{ConfigObject}->Get('PGP::StoreDecryptedData');
    $Self->{CryptObject} = Kernel::System::Crypt->new( %{$Self}, CryptType => 'PGP' );

    # check inline pgp crypt
    if ( $Param{Article}->{Body} =~ /\A[\s\n]*^-----BEGIN PGP MESSAGE-----/m ) {

        # check sender (don't decrypt sent emails)
        if ( $Param{Article}->{SenderType} =~ /(agent|system)/i ) {

            # return info
            return (
                {
                    Key   => 'Crypted',
                    Value => 'Sent message crypted to recipient!',
                }
            );
        }
        my %Decrypt = $Self->{CryptObject}->Decrypt( Message => $Param{Article}->{Body} );
        if ( $Decrypt{Successful} ) {

            # remember to result
            $Self->{Result} = \%Decrypt;
            $Param{Article}->{Body} = $Decrypt{Data};

            if ($StoreDecryptedData) {

                # updated article body
                $Self->{TicketObject}->ArticleUpdate(
                    TicketID  => $Param{Article}->{TicketID},
                    ArticleID => $Self->{ArticleID},
                    Key       => 'Body',
                    Value     => $Decrypt{Data},
                    UserID    => $Self->{UserID},
                );

                # get a list of all article attachments
                my %Index = $Self->{TicketObject}->ArticleAttachmentIndex(
                    ArticleID => $Self->{ArticleID},
                    UserID    => $Self->{UserID},
                );

                my @Attachments;
                if ( IsHashRefWithData( \%Index ) ) {
                    for my $FileID ( sort keys %Index ) {

                        # get attachment details
                        my %Attachment = $Self->{TicketObject}->ArticleAttachment(
                            ArticleID => $Self->{ArticleID},
                            FileID    => $FileID,
                            UserID    => $Self->{UserID},
                        );

                        # store attachemnts attributes that might change after decryption
                        my $AttachmentContent  = $Attachment{Content};
                        my $AttachmentFilename = $Attachment{Filename};

                        # try to decrypt the attachment, non ecrypted attachments will succeed too.
                        %Decrypt = $Self->{CryptObject}->Decrypt( Message => $Attachment{Content} );

                        if ( $Decrypt{Successful} ) {

                            # set decrypted content
                            $AttachmentContent = $Decrypt{Data};

                            # remove .pgp .gpg or asc extensions (if any)
                            $AttachmentFilename =~ s{ (\. [^\.]+) \. (?: pgp|gpg|asc) \z}{$1}msx;
                        }

                        # remember decrypted attachement, to add it later
                        push @Attachments, {
                            %Attachment,
                            Content   => $AttachmentContent,
                            Filename  => $AttachmentFilename,
                            ArticleID => $Self->{ArticleID},
                            UserID    => $Self->{UserID},
                        };
                    }

                    # delete crypted attachments
                    $Self->{TicketObject}->ArticleDeleteAttachment(
                        ArticleID => $Self->{ArticleID},
                        UserID    => $Self->{UserID},
                    );

                    # write decrypted attachments to the storage
                    for my $Attachment (@Attachments) {
                        $Self->{TicketObject}->ArticleWriteAttachment( %{$Attachment} );
                    }
                }
            }

            push(
                @Return,
                {
                    Key   => 'Crypted',
                    Value => $Decrypt{Message},
                    %Decrypt,
                },
            );
        }
        else {

            # return with error
            return (
                {
                    Key   => 'Crypted',
                    Value => $Decrypt{Message},
                    %Decrypt,
                }
            );
        }
    }

    # check inline pgp signature (but ignore if is in quoted text)
    if ( $Param{Article}->{Body} =~ m{ ^\s* -----BEGIN [ ] PGP [ ] SIGNED [ ] MESSAGE----- }xms ) {

        # get original message
        my $Message = $Self->{TicketObject}->ArticlePlain(
            ArticleID => $Self->{ArticleID},
            UserID    => $Self->{UserID},
        );

        # create local email parser object
        my $ParserObject = Kernel::System::EmailParser->new(
            %{$Self},
            Email => $Message,
        );

        # get the charset of the original message
        my $Charset = $ParserObject->GetCharset();

        # verify message PGP signature
        %SignCheck = $Self->{CryptObject}->Verify(
            Message => $Param{Article}->{Body},
            Charset => $Charset
        );

        if (%SignCheck) {

            # remember to result
            $Self->{Result} = \%SignCheck;
        }
        else {

            # return with error
            return (
                {
                    Key   => 'Signed',
                    Value => '"PGP SIGNED MESSAGE" header found, but invalid!',
                }
            );
        }
    }

    # check mime pgp
    else {

        # check body
        # if body =~ application/pgp-encrypted
        # if crypted, decrypt it
        # remember that it was crypted!

        # write email to fs
        my $Message = $Self->{TicketObject}->ArticlePlain(
            ArticleID => $Self->{ArticleID},
            UserID    => $Self->{UserID},
        );
        my $Parser = MIME::Parser->new();
        $Parser->decode_headers(0);
        $Parser->extract_nested_messages(0);
        $Parser->output_to_core('ALL');
        my $Entity = $Parser->parse_data($Message);
        my $Head   = $Entity->head();
        $Head->unfold();
        $Head->combine('Content-Type');
        my $ContentType = $Head->get('Content-Type');

        # check if we need to decrypt it
        if (
            $ContentType
            && $ContentType =~ /multipart\/encrypted/i
            && $ContentType =~ /application\/pgp/i
            )
        {

            # check sender (don't decrypt sent emails)
            if ( $Param{Article}->{SenderType} =~ /(agent|system)/i ) {

                # return info
                return (
                    {
                        Key        => 'Crypted',
                        Value      => 'Sent message crypted to recipient!',
                        Successful => 1,
                    }
                );
            }

            # get crypted part of the mail
            my $Crypted = $Entity->parts(1)->as_string();

            # decrypt it
            my %Decrypt = $Self->{CryptObject}->Decrypt( Message => $Crypted, );
            if ( $Decrypt{Successful} ) {
                $Entity = $Parser->parse_data( $Decrypt{Data} );
                my $Head = $Entity->head();
                $Head->unfold();
                $Head->combine('Content-Type');
                $ContentType = $Head->get('Content-Type');

                # use a copy of the Entity to get the body, otherwise the original mail content
                # could be altered and a signature verify could fail. See Bug#9954
                my $EntityCopy = $Entity->dup();

                my $ParserObject = Kernel::System::EmailParser->new(
                    %{$Self},
                    Entity => $EntityCopy,
                );

                my $Body = $ParserObject->GetMessageBody();

                if ($StoreDecryptedData) {

                    # updated article body
                    $Self->{TicketObject}->ArticleUpdate(
                        TicketID  => $Param{Article}->{TicketID},
                        ArticleID => $Self->{ArticleID},
                        Key       => 'Body',
                        Value     => $Body,
                        UserID    => $Self->{UserID},
                    );

                    # delete crypted attachments
                    $Self->{TicketObject}->ArticleDeleteAttachment(
                        ArticleID => $Self->{ArticleID},
                        UserID    => $Self->{UserID},
                    );

                    # write attachments to the storage
                    for my $Attachment ( $ParserObject->GetAttachments() ) {
                        $Self->{TicketObject}->ArticleWriteAttachment(
                            %{$Attachment},
                            ArticleID => $Self->{ArticleID},
                            UserID    => $Self->{UserID},
                        );
                    }
                }

                push(
                    @Return,
                    {
                        Key   => 'Crypted',
                        Value => $Decrypt{Message},
                        %Decrypt,
                    },
                );
            }
            else {
                push(
                    @Return,
                    {
                        Key   => 'Crypted',
                        Value => $Decrypt{Message},
                        %Decrypt,
                    },
                );
            }
        }
        if (
            $ContentType
            && $ContentType =~ /multipart\/signed/i
            && $ContentType =~ /application\/pgp/i
            )
        {
            my $SignedText    = $Entity->parts(0)->as_string();
            my $SignatureText = $Entity->parts(1)->body_as_string();

            # according to RFC3156 all line endings MUST be CR/LF
            $SignedText =~ s/\x0A/\x0D\x0A/g;
            $SignedText =~ s/\x0D+/\x0D/g;

            %SignCheck = $Self->{CryptObject}->Verify(
                Message => $SignedText,
                Sign    => $SignatureText,
            );
        }
    }
    if (%SignCheck) {

        # return result
        push(
            @Return,
            {
                Key   => 'Signed',
                Value => $SignCheck{Message},
                %SignCheck,
            },
        );
    }
    return @Return;
}

sub Filter {
    my ( $Self, %Param ) = @_;

    # remove signature if one is found
    if ( $Self->{Result}->{SignatureFound} ) {

        # remove pgp begin signed message
        $Param{Article}->{Body} =~ s/^-----BEGIN\sPGP\sSIGNED\sMESSAGE-----.+?Hash:\s.+?$//sm;

        # remove pgp inline sign
        $Param{Article}->{Body}
            =~ s/^-----BEGIN\sPGP\sSIGNATURE-----.+?-----END\sPGP\sSIGNATURE-----//sm;
    }
    return 1;
}

1;
