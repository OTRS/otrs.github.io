# --
# Kernel/System/PostMaster.pm - the global PostMaster module for OTRS
# Copyright (C) 2001-2014 OTRS AG, http://otrs.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package Kernel::System::PostMaster;

use strict;
use warnings;

use Kernel::System::EmailParser;
use Kernel::System::Ticket;
use Kernel::System::Queue;
use Kernel::System::State;
use Kernel::System::Priority;
use Kernel::System::PostMaster::Reject;
use Kernel::System::PostMaster::FollowUp;
use Kernel::System::PostMaster::NewTicket;
use Kernel::System::PostMaster::DestQueue;

=head1 NAME

Kernel::System::PostMaster - postmaster lib

=head1 SYNOPSIS

All postmaster functions. E. g. to process emails.

=head1 PUBLIC INTERFACE

=over 4

=cut

=item new()

create an object. Do not use it directly, instead use:

    use Kernel::System::ObjectManager;
    local $Kernel::OM = Kernel::System::ObjectManager->new(
        PostMasterObject => {
            Email        => \@ArrayOfEmailContent,
            Trusted      => 1, # 1|0 ignore X-OTRS header if false
        },
    );
    my $PostMasterObject = $Kernel::OM->Get('PostMasterObject');

=cut

sub new {
    my ( $Type, %Param ) = @_;

    # allocate new hash for object
    my $Self = {};
    bless( $Self, $Type );

    # check needed objects
    for (qw(DBObject LogObject ConfigObject TimeObject MainObject EncodeObject Email)) {
        $Self->{$_} = $Param{$_} || die "Got no $_!";
    }

    # for debug 0=off; 1=info; 2=on; 3=with GetHeaderParam;
    $Self->{Debug} = $Param{Debug} || 0;

    # create common objects
    $Self->{TicketObject} = Kernel::System::Ticket->new( %{$Self} );
    $Self->{ParserObject} = Kernel::System::EmailParser->new(
        Email => $Param{Email},
        %Param,
    );
    $Self->{QueueObject}     = Kernel::System::Queue->new( %{$Self} );
    $Self->{StateObject}     = Kernel::System::State->new( %{$Self} );
    $Self->{PriorityObject}  = Kernel::System::Priority->new( %{$Self} );
    $Self->{DestQueueObject} = Kernel::System::PostMaster::DestQueue->new(
        %{$Self},
        QueueObject  => $Self->{QueueObject},
        ParserObject => $Self->{ParserObject},
    );
    $Self->{NewTicket} = Kernel::System::PostMaster::NewTicket->new(
        %{$Self},
        Debug          => $Self->{Debug},
        ParserObject   => $Self->{ParserObject},
        TicketObject   => $Self->{TicketObject},
        QueueObject    => $Self->{QueueObject},
        StateObject    => $Self->{StateObject},
        PriorityObject => $Self->{PriorityObject},
    );
    $Self->{FollowUp} = Kernel::System::PostMaster::FollowUp->new(
        %{$Self},
        Debug        => $Self->{Debug},
        TicketObject => $Self->{TicketObject},
        ParserObject => $Self->{ParserObject},
    );
    $Self->{Reject} = Kernel::System::PostMaster::Reject->new(
        %{$Self},
        Debug        => $Self->{Debug},
        TicketObject => $Self->{TicketObject},
        ParserObject => $Self->{ParserObject},
    );

    # check needed config options
    for my $Option (qw(PostmasterUserID PostmasterX-Header)) {
        $Self->{$Option} = $Param{ConfigObject}->Get($Option)
            || die "Found no '$Option' option in configuration!";
    }

    # should I use x-otrs headers?
    $Self->{Trusted} = defined $Param{Trusted} ? $Param{Trusted} : 1;

    if ( $Self->{Trusted} ) {

        # add Dynamic Field headers
        my $DynamicFields = $Self->{TicketObject}->{DynamicFieldObject}->DynamicFieldList(
            Valid      => 1,
            ObjectType => [ 'Ticket', 'Article' ],
            ResultType => 'HASH',
        );

        # create a lookup table
        my %HeaderLookup = map { $_ => 1 } @{ $Self->{'PostmasterX-Header'} };

        for my $DynamicField ( values %$DynamicFields ) {
            for my $Header (
                'X-OTRS-DynamicField-' . $DynamicField,
                'X-OTRS-FollowUp-DynamicField-' . $DynamicField,
                )
            {

                # only add the header if is not alreday in the conifg
                if ( !$HeaderLookup{$Header} ) {
                    push @{ $Self->{'PostmasterX-Header'} }, $Header;
                }
            }
        }
    }

    return $Self;
}

=item Run()

to execute the run process

    $PostMasterObject->Run();

return params

    0 = error (also false)
    1 = new ticket created
    2 = follow up / open/reopen
    3 = follow up / close -> new ticket
    4 = follow up / close -> reject
    5 = ignored (because of X-OTRS-Ignore header)

=cut

sub Run {
    my ( $Self, %Param ) = @_;

    my @Return;

    # ConfigObject section / get params
    my $GetParam = $Self->GetEmailParams();

    # check if follow up
    my ( $Tn, $TicketID ) = $Self->CheckFollowUp( %{$GetParam} );

    # run all PreFilterModules (modify email params)
    if ( ref $Self->{ConfigObject}->Get('PostMaster::PreFilterModule') eq 'HASH' ) {
        my %Jobs = %{ $Self->{ConfigObject}->Get('PostMaster::PreFilterModule') };
        JOB:
        for my $Job ( sort keys %Jobs ) {
            return if !$Self->{MainObject}->Require( $Jobs{$Job}->{Module} );

            my $FilterObject = $Jobs{$Job}->{Module}->new(
                EncodeObject => $Self->{EncodeObject},
                ConfigObject => $Self->{ConfigObject},
                MainObject   => $Self->{MainObject},
                LogObject    => $Self->{LogObject},
                DBObject     => $Self->{DBObject},
                ParserObject => $Self->{ParserObject},
                TicketObject => $Self->{TicketObject},
                TimeObject   => $Self->{TimeObject},
                Debug        => $Self->{Debug},
            );
            if ( !$FilterObject ) {
                $Self->{LogObject}->Log(
                    Priority => 'error',
                    Message  => "new() of PreFilterModule $Jobs{$Job}->{Module} not successfully!",
                );
                next JOB;
            }

            # modify params
            my $Run = $FilterObject->Run(
                GetParam  => $GetParam,
                JobConfig => $Jobs{$Job},
                TicketID  => $TicketID,
            );
            if ( !$Run ) {
                $Self->{LogObject}->Log(
                    Priority => 'error',
                    Message =>
                        "Execute Run() of PreFilterModule $Jobs{$Job}->{Module} not successfully!",
                );
            }
        }
    }

    # should I ignore the incoming mail?
    if ( $GetParam->{'X-OTRS-Ignore'} && $GetParam->{'X-OTRS-Ignore'} =~ /(yes|true)/i ) {
        $Self->{LogObject}->Log(
            Priority => 'info',
            Message =>
                "Ignored Email (From: $GetParam->{'From'}, Message-ID: $GetParam->{'Message-ID'}) "
                . "because the X-OTRS-Ignore is set (X-OTRS-Ignore: $GetParam->{'X-OTRS-Ignore'})."
        );
        return (5);
    }

    # ----------------------
    # ticket section
    # ----------------------

    # check if follow up (again, with new GetParam)
    ( $Tn, $TicketID ) = $Self->CheckFollowUp( %{$GetParam} );

    # check if it's a follow up ...
    if ( $Tn && $TicketID ) {

        # get ticket data
        my %Ticket = $Self->{TicketObject}->TicketGet(
            TicketID      => $TicketID,
            DynamicFields => 0,
        );

        # check if it is possible to do the follow up
        # get follow up option (possible or not)
        my $FollowUpPossible = $Self->{QueueObject}->GetFollowUpOption(
            QueueID => $Ticket{QueueID},
        );

        # get lock option (should be the ticket locked - if closed - after the follow up)
        my $Lock = $Self->{QueueObject}->GetFollowUpLockOption(
            QueueID => $Ticket{QueueID},
        );

        # get state details
        my %State = $Self->{StateObject}->StateGet( ID => $Ticket{StateID} );

        # create a new ticket
        if ( $FollowUpPossible =~ /new ticket/i && $State{TypeName} =~ /^close/i ) {
            $Self->{LogObject}->Log(
                Priority => 'info',
                Message  => "Follow up for [$Tn] but follow up not possible ($Ticket{State})."
                    . " Create new ticket."
            );

            # send mail && create new article
            # get queue if of From: and To:
            if ( !$Param{QueueID} ) {
                $Param{QueueID} = $Self->{DestQueueObject}->GetQueueID( Params => $GetParam, );
            }

            # check if trusted returns a new queue id
            my $TQueueID = $Self->{DestQueueObject}->GetTrustedQueueID( Params => $GetParam, );
            if ($TQueueID) {
                $Param{QueueID} = $TQueueID;
            }

            # Clean out the old TicketNumber from the subject (see bug#9108).
            # This avoids false ticket number detection on customer replies.
            if ( $GetParam->{Subject} ) {
                $GetParam->{Subject} = $Self->{TicketObject}->TicketSubjectClean(
                    TicketNumber => $Tn,
                    Subject      => $GetParam->{Subject},
                );
            }

            $TicketID = $Self->{NewTicket}->Run(
                InmailUserID     => $Self->{PostmasterUserID},
                GetParam         => $GetParam,
                QueueID          => $Param{QueueID},
                Comment          => "Because the old ticket [$Tn] is '$State{Name}'",
                AutoResponseType => 'auto reply/new ticket',
                LinkToTicketID   => $TicketID,
            );
            if ( !$TicketID ) {
                return;
            }
            @Return = ( 3, $TicketID );
        }

        # reject follow up
        elsif ( $FollowUpPossible =~ /reject/i && $State{TypeName} =~ /^close/i ) {
            $Self->{LogObject}->Log(
                Priority => 'info',
                Message  => "Follow up for [$Tn] but follow up not possible. Follow up rejected."
            );

            # send reject mail && and add article to ticket
            my $Run = $Self->{Reject}->Run(
                TicketID         => $TicketID,
                InmailUserID     => $Self->{PostmasterUserID},
                GetParam         => $GetParam,
                Lock             => $Lock,
                Tn               => $Tn,
                Comment          => 'Follow up rejected.',
                AutoResponseType => 'auto reject',
            );
            if ( !$Run ) {
                return;
            }
            @Return = ( 4, $TicketID );
        }

        # create normal follow up
        else {
            my $Run = $Self->{FollowUp}->Run(
                TicketID         => $TicketID,
                InmailUserID     => $Self->{PostmasterUserID},
                GetParam         => $GetParam,
                Lock             => $Lock,
                Tn               => $Tn,
                AutoResponseType => 'auto follow up',
            );
            if ( !$Run ) {
                return;
            }
            @Return = ( 2, $TicketID );
        }
    }

    # create new ticket
    else {
        if ( $Param{Queue} && !$Param{QueueID} ) {

            # queue lookup if queue name is given
            $Param{QueueID} = $Self->{QueueObject}->QueueLookup( Queue => $Param{Queue} );
        }

        # get queue if of From: and To:
        if ( !$Param{QueueID} ) {
            $Param{QueueID} = $Self->{DestQueueObject}->GetQueueID( Params => $GetParam );
        }

        # check if trusted returns a new queue id
        my $TQueueID = $Self->{DestQueueObject}->GetTrustedQueueID( Params => $GetParam, );
        if ($TQueueID) {
            $Param{QueueID} = $TQueueID;
        }
        $TicketID = $Self->{NewTicket}->Run(
            InmailUserID     => $Self->{PostmasterUserID},
            GetParam         => $GetParam,
            QueueID          => $Param{QueueID},
            AutoResponseType => 'auto reply',
        );
        return if !$TicketID;
        @Return = ( 1, $TicketID );
    }

    # run all PostFilterModules (modify email params)
    if ( ref $Self->{ConfigObject}->Get('PostMaster::PostFilterModule') eq 'HASH' ) {
        my %Jobs = %{ $Self->{ConfigObject}->Get('PostMaster::PostFilterModule') };
        JOB:
        for my $Job ( sort keys %Jobs ) {
            return if !$Self->{MainObject}->Require( $Jobs{$Job}->{Module} );

            my $FilterObject = $Jobs{$Job}->{Module}->new(
                EncodeObject => $Self->{EncodeObject},
                ConfigObject => $Self->{ConfigObject},
                MainObject   => $Self->{MainObject},
                LogObject    => $Self->{LogObject},
                DBObject     => $Self->{DBObject},
                ParserObject => $Self->{ParserObject},
                TicketObject => $Self->{TicketObject},
                TimeObject   => $Self->{TimeObject},
                Debug        => $Self->{Debug},
            );
            if ( !$FilterObject ) {
                $Self->{LogObject}->Log(
                    Priority => 'error',
                    Message  => "new() of PostFilterModule $Jobs{$Job}->{Module} not successfully!",
                );
                next JOB;
            }

            # modify params
            my $Run = $FilterObject->Run(
                TicketID  => $TicketID,
                GetParam  => $GetParam,
                JobConfig => $Jobs{$Job},
            );
            if ( !$Run ) {
                $Self->{LogObject}->Log(
                    Priority => 'error',
                    Message =>
                        "Execute Run() of PostFilterModule $Jobs{$Job}->{Module} not successfully!",
                );
            }
        }
    }
    return @Return;
}

=item CheckFollowUp()

to detect the ticket number in processing email

    my ($TicketNumber, $TicketID) = $PostMasterObject->CheckFollowUp(
        Subject => 'Re: [Ticket:#123456] Some Subject',
    );

=cut

sub CheckFollowUp {
    my ( $Self, %Param ) = @_;

    my $Subject = $Param{Subject} || '';
    my $Tn = $Self->{TicketObject}->GetTNByString($Subject);

    if ($Tn) {
        my $TicketID = $Self->{TicketObject}->TicketCheckNumber( Tn => $Tn );
        return if !$TicketID;

        my %Ticket = $Self->{TicketObject}->TicketGet(
            TicketID      => $TicketID,
            DynamicFields => 0,
        );
        if ( $Self->{Debug} > 1 ) {
            $Self->{LogObject}->Log(
                Priority => 'debug',
                Message  => "CheckFollowUp: ja, it's a follow up ($Ticket{TicketNumber}/$TicketID)",
            );
        }
        return ( $Ticket{TicketNumber}, $TicketID );
    }

    # There is no valid ticket number in the subject.
    # Try to find ticket number in References and In-Reply-To header.
    if ( $Self->{ConfigObject}->Get('PostmasterFollowUpSearchInReferences') ) {
        my @References = $Self->{ParserObject}->GetReferences();

        REFERENCE:
        for my $Reference (@References) {

            # get ticket id of message id
            my $TicketID = $Self->{TicketObject}->ArticleGetTicketIDOfMessageID(
                MessageID => "<$Reference>",
            );
            next REFERENCE if !$TicketID;
            my $Tn = $Self->{TicketObject}->TicketNumberLookup( TicketID => $TicketID, );
            if ( $TicketID && $Tn ) {
                return ( $Tn, $TicketID );
            }
        }
    }

    # do body ticket number lookup
    if ( $Self->{ConfigObject}->Get('PostmasterFollowUpSearchInBody') ) {
        my $Tn = $Self->{TicketObject}->GetTNByString( $Self->{ParserObject}->GetMessageBody() );
        if ($Tn) {
            my $TicketID = $Self->{TicketObject}->TicketCheckNumber( Tn => $Tn );
            if ($TicketID) {
                my %Ticket = $Self->{TicketObject}->TicketGet(
                    TicketID      => $TicketID,
                    DynamicFields => 0,
                );
                if ( $Self->{Debug} > 1 ) {
                    $Self->{LogObject}->Log(
                        Priority => 'debug',
                        Message =>
                            "CheckFollowUp (in body): ja, it's a follow up ($Ticket{TicketNumber}/$TicketID)",
                    );
                }
                return ( $Ticket{TicketNumber}, $TicketID );
            }
        }
    }

    # do attachment ticket number lookup
    if ( $Self->{ConfigObject}->Get('PostmasterFollowUpSearchInAttachment') ) {
        for my $Attachment ( $Self->{ParserObject}->GetAttachments() ) {
            my $Tn = $Self->{TicketObject}->GetTNByString( $Attachment->{Content} );
            if ($Tn) {
                my $TicketID = $Self->{TicketObject}->TicketCheckNumber( Tn => $Tn );
                if ($TicketID) {
                    my %Ticket = $Self->{TicketObject}->TicketGet(
                        TicketID      => $TicketID,
                        DynamicFields => 0,
                    );
                    if ( $Self->{Debug} > 1 ) {
                        $Self->{LogObject}->Log(
                            Priority => 'debug',
                            Message =>
                                "CheckFollowUp (in attachment): ja, it's a follow up ($Ticket{TicketNumber}/$TicketID)",
                        );
                    }
                    return ( $Ticket{TicketNumber}, $TicketID );
                }
            }
        }
    }

    # do plain/raw ticket number lookup
    if ( $Self->{ConfigObject}->Get('PostmasterFollowUpSearchInRaw') ) {
        my $Tn = $Self->{TicketObject}->GetTNByString( $Self->{ParserObject}->GetPlainEmail() );
        if ($Tn) {
            my $TicketID = $Self->{TicketObject}->TicketCheckNumber( Tn => $Tn );
            if ($TicketID) {
                my %Ticket = $Self->{TicketObject}->TicketGet(
                    TicketID      => $TicketID,
                    DynamicFields => 0,
                );
                if ( $Self->{Debug} > 1 ) {
                    $Self->{LogObject}->Log(
                        Priority => 'debug',
                        Message =>
                            "CheckFollowUp (in plain/raw): ja, it's a follow up ($Ticket{TicketNumber}/$TicketID)",
                    );
                }
                return ( $Ticket{TicketNumber}, $TicketID );
            }
        }
    }
    return;
}

=item GetEmailParams()

to get all configured PostmasterX-Header email headers

    my %Header = $PostMasterObject->GetEmailParams();

=cut

sub GetEmailParams {
    my ( $Self, %Param ) = @_;

    my %GetParam;

    # parse section
    HEADER:
    for my $Param ( @{ $Self->{'PostmasterX-Header'} } ) {

        # do not scan x-otrs headers if mailbox is not marked as trusted
        next HEADER if ( !$Self->{Trusted} && $Param =~ /^x-otrs/i );
        if ( $Self->{Debug} > 2 ) {
            $Self->{LogObject}->Log(
                Priority => 'debug',
                Message => "$Param: " . $Self->{ParserObject}->GetParam( WHAT => $Param ),
            );
        }
        $GetParam{$Param} = $Self->{ParserObject}->GetParam( WHAT => $Param );
    }

    # set compat. headers
    if ( $GetParam{'Message-Id'} ) {
        $GetParam{'Message-ID'} = $GetParam{'Message-Id'};
    }
    if ( $GetParam{'Reply-To'} ) {
        $GetParam{'ReplyTo'} = $GetParam{'Reply-To'};
    }
    if (
        $GetParam{'Mailing-List'}
        || $GetParam{'Precedence'}
        || $GetParam{'X-Loop'}
        || $GetParam{'X-No-Loop'}
        || $GetParam{'X-OTRS-Loop'}
        || (
            $GetParam{'Auto-Submitted'}
            && substr( $GetParam{'Auto-Submitted'}, 0, 5 ) eq 'auto-'
        )
        )
    {
        $GetParam{'X-OTRS-Loop'} = 'yes';
    }
    if ( !$GetParam{'X-Sender'} ) {

        # get sender email
        my @EmailAddresses = $Self->{ParserObject}->SplitAddressLine(
            Line => $GetParam{From},
        );
        for my $Email (@EmailAddresses) {
            $GetParam{'X-Sender'} = $Self->{ParserObject}->GetEmailAddress(
                Email => $Email,
            );
        }
    }

    # set sender type if not given
    for my $Key (qw(X-OTRS-SenderType X-OTRS-FollowUp-SenderType)) {
        if ( !$GetParam{$Key} ) {
            $GetParam{$Key} = 'customer';
        }

        # check if X-OTRS-SenderType exists, if not, set customer
        if ( !$Self->{TicketObject}->ArticleSenderTypeLookup( SenderType => $GetParam{$Key} ) ) {
            $Self->{LogObject}->Log(
                Priority => 'error',
                Message  => "Can't find sender type '$GetParam{$Key}' in db, take 'customer'",
            );
            $GetParam{$Key} = 'customer';
        }
    }

    # set article type if not given
    for my $Key (qw(X-OTRS-ArticleType X-OTRS-FollowUp-ArticleType)) {
        if ( !$GetParam{$Key} ) {
            $GetParam{$Key} = 'email-external';
        }

        # check if X-OTRS-ArticleType exists, if not, set 'email'
        if ( !$Self->{TicketObject}->ArticleTypeLookup( ArticleType => $GetParam{$Key} ) ) {
            $Self->{LogObject}->Log(
                Priority => 'error',
                Message => "Can't find article type '$GetParam{$Key}' in db, take 'email-external'",
            );
            $GetParam{$Key} = 'email-external';
        }
    }

    # get body
    $GetParam{Body} = $Self->{ParserObject}->GetMessageBody();

    # get content type
    $GetParam{'Content-Type'} = $Self->{ParserObject}->GetReturnContentType();
    $GetParam{Charset} = $Self->{ParserObject}->GetReturnCharset();

    # get attachments
    my @Attachments = $Self->{ParserObject}->GetAttachments();
    $GetParam{Attachment} = \@Attachments;

    # return params
    return \%GetParam;
}

1;

=back

=head1 TERMS AND CONDITIONS

This software is part of the OTRS project (L<http://otrs.org/>).

This software comes with ABSOLUTELY NO WARRANTY. For details, see
the enclosed file COPYING for license information (AGPL). If you
did not receive this file, see L<http://www.gnu.org/licenses/agpl.txt>.

=cut
