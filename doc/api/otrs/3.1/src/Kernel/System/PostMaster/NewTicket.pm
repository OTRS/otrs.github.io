# --
# Kernel/System/PostMaster/NewTicket.pm - sub part of PostMaster.pm
# Copyright (C) 2001-2014 OTRS AG, http://otrs.com/
# --
# $Id: NewTicket.pm,v 1.86 2012-04-19 21:12:39 mb Exp $
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package Kernel::System::PostMaster::NewTicket;

use strict;
use warnings;

use Kernel::System::AutoResponse;
use Kernel::System::CustomerUser;

use vars qw($VERSION);
$VERSION = qw($Revision: 1.86 $) [1];

sub new {
    my ( $Type, %Param ) = @_;

    # allocate new hash for object
    my $Self = {};
    bless( $Self, $Type );

    $Self->{Debug} = $Param{Debug} || 0;

    # get all objects
    for (
        qw(DBObject ConfigObject TicketObject LogObject ParserObject TimeObject QueueObject StateObject PriorityObject)
        )
    {
        $Self->{$_} = $Param{$_} || die 'Got no $_';
    }

    $Self->{CustomerUserObject} = Kernel::System::CustomerUser->new(%Param);

    return $Self;
}

sub Run {
    my ( $Self, %Param ) = @_;

    # check needed stuff
    for (qw(InmailUserID GetParam)) {
        if ( !$Param{$_} ) {
            $Self->{LogObject}->Log( Priority => 'error', Message => "Need $_!" );
            return;
        }
    }
    my %GetParam         = %{ $Param{GetParam} };
    my $Comment          = $Param{Comment} || '';
    my $AutoResponseType = $Param{AutoResponseType} || '';

    # get queue id and name
    my $QueueID = $Param{QueueID} || die "need QueueID!";
    my $Queue = $Self->{QueueObject}->QueueLookup( QueueID => $QueueID );

    # get state
    my $State = $Self->{ConfigObject}->Get('PostmasterDefaultState') || 'new';
    if ( $GetParam{'X-OTRS-State'} ) {
        my $StateID = $Self->{StateObject}->StateLookup( State => $GetParam{'X-OTRS-State'} );
        if ($StateID) {
            $State = $GetParam{'X-OTRS-State'};
        }
        else {
            $Self->{LogObject}->Log(
                Priority => 'error',
                Message => "State $GetParam{'X-OTRS-State'} does not exist, falling back to $State!"
            );
        }
    }

    # get priority
    my $Priority = $Self->{ConfigObject}->Get('PostmasterDefaultPriority') || '3 normal';
    if ( $GetParam{'X-OTRS-Priority'} ) {
        my $PriorityID
            = $Self->{PriorityObject}->PriorityLookup( Priority => $GetParam{'X-OTRS-Priority'} );
        if ($PriorityID) {
            $Priority = $GetParam{'X-OTRS-Priority'};
        }
        else {
            $Self->{LogObject}->Log(
                Priority => 'error',
                Message =>
                    "Priority $GetParam{'X-OTRS-Priority'} does not exist, falling back to $Priority!"
            );
        }
    }

    # get sender email
    my @EmailAddresses = $Self->{ParserObject}->SplitAddressLine( Line => $GetParam{From}, );
    for (@EmailAddresses) {
        $GetParam{SenderEmailAddress} = $Self->{ParserObject}->GetEmailAddress( Email => $_, );
    }

    # get customer id (sender email) if there is no customer id given
    if ( !$GetParam{'X-OTRS-CustomerNo'} && $GetParam{'X-OTRS-CustomerUser'} ) {

        # get customer user data form X-OTRS-CustomerUser
        my %CustomerData = $Self->{CustomerUserObject}->CustomerUserDataGet(
            User => $GetParam{'X-OTRS-CustomerUser'},
        );
        if (%CustomerData) {
            $GetParam{'X-OTRS-CustomerNo'} = $CustomerData{UserCustomerID};
        }
    }

    # get customer user data form From: (sender address)
    if ( !$GetParam{'X-OTRS-CustomerUser'} ) {
        my %CustomerData;
        if ( $GetParam{From} ) {
            my @EmailAddresses = $Self->{ParserObject}->SplitAddressLine(
                Line => $GetParam{From},
            );
            for (@EmailAddresses) {
                $GetParam{EmailForm} = $Self->{ParserObject}->GetEmailAddress(
                    Email => $_,
                );
            }
            my %List = $Self->{CustomerUserObject}->CustomerSearch(
                PostMasterSearch => lc( $GetParam{EmailForm} ),
            );
            for ( keys %List ) {
                %CustomerData = $Self->{CustomerUserObject}->CustomerUserDataGet(
                    User => $_,
                );
            }
        }

        # take CustomerID from customer backend lookup or from from field
        if ( $CustomerData{UserLogin} && !$GetParam{'X-OTRS-CustomerUser'} ) {
            $GetParam{'X-OTRS-CustomerUser'} = $CustomerData{UserLogin};

            # notice that UserLogin is from customer source backend
            $Self->{LogObject}->Log(
                Priority => 'notice',
                Message  => "Take UserLogin ($CustomerData{UserLogin}) from "
                    . "customer source backend based on ($GetParam{'EmailForm'}).",
            );
        }
        if ( $CustomerData{UserCustomerID} && !$GetParam{'X-OTRS-CustomerNo'} ) {
            $GetParam{'X-OTRS-CustomerNo'} = $CustomerData{UserCustomerID};

            # notice that UserCustomerID is from customer source backend
            $Self->{LogObject}->Log(
                Priority => 'notice',
                Message  => "Take UserCustomerID ($CustomerData{UserCustomerID})"
                    . " from customer source backend based on ($GetParam{'EmailForm'}).",
            );
        }
    }

    # if there is no customer id found!
    if ( !$GetParam{'X-OTRS-CustomerNo'} ) {
        $GetParam{'X-OTRS-CustomerNo'} = $GetParam{SenderEmailAddress};
    }

    # if there is no customer user found!
    if ( !$GetParam{'X-OTRS-CustomerUser'} ) {
        $GetParam{'X-OTRS-CustomerUser'} = $GetParam{SenderEmailAddress};
    }

    # create new ticket
    my $NewTn    = $Self->{TicketObject}->TicketCreateNumber();
    my $TicketID = $Self->{TicketObject}->TicketCreate(
        TN           => $NewTn,
        Title        => $GetParam{Subject},
        QueueID      => $QueueID,
        Lock         => $GetParam{'X-OTRS-Lock'} || 'unlock',
        Priority     => $Priority,
        State        => $State,
        Type         => $GetParam{'X-OTRS-Type'} || '',
        Service      => $GetParam{'X-OTRS-Service'} || '',
        SLA          => $GetParam{'X-OTRS-SLA'} || '',
        CustomerID   => $GetParam{'X-OTRS-CustomerNo'},
        CustomerUser => $GetParam{'X-OTRS-CustomerUser'},
        OwnerID      => $Param{InmailUserID},
        UserID       => $Param{InmailUserID},
    );

    if ( !$TicketID ) {
        return;
    }

    # debug
    if ( $Self->{Debug} > 0 ) {
        print "New Ticket created!\n";
        print "TicketNumber: $NewTn\n";
        print "TicketID: $TicketID\n";
        print "Priority: $Priority\n";
        print "State: $State\n";
        print "CustomerID: $GetParam{'X-OTRS-CustomerNo'}\n";
        print "CustomerUser: $GetParam{'X-OTRS-CustomerUser'}\n";
        for (qw(Type Service SLA Lock)) {

            if ( $GetParam{ 'X-OTRS-' . $_ } ) {
                print "Type: " . $GetParam{ 'X-OTRS-' . $_ } . "\n";
            }
        }
    }

    # set pending time
    if ( $GetParam{'X-OTRS-State-PendingTime'} ) {
        my $Set = $Self->{TicketObject}->TicketPendingTimeSet(
            String   => $GetParam{'X-OTRS-State-PendingTime'},
            TicketID => $TicketID,
            UserID   => $Param{InmailUserID},
        );

        # debug
        if ( $Set && $Self->{Debug} > 0 ) {
            print "State-PendingTime: $GetParam{'X-OTRS-State-PendingTime'}\n";
        }
    }

    # dynamic fields
    my $DynamicFieldList =
        $Self->{TicketObject}->{DynamicFieldObject}->DynamicFieldList(
        Valid      => 1,
        ResultType => 'HASH',
        ObjectType => 'Ticket'
        );

    # set dynamic fields for Ticket object type
    DYNAMICFIELDID:
    for my $DynamicFieldID ( sort keys %{$DynamicFieldList} ) {
        next DYNAMICFIELDID if !$DynamicFieldID;
        next DYNAMICFIELDID if !$DynamicFieldList->{$DynamicFieldID};
        my $Key = 'X-OTRS-DynamicField-' . $DynamicFieldList->{$DynamicFieldID};

        if ( $GetParam{$Key} ) {

            # get dynamic field config
            my $DynamicFieldGet
                = $Self->{TicketObject}->{DynamicFieldObject}->DynamicFieldGet(
                ID => $DynamicFieldID,
                );

            $Self->{TicketObject}->{DynamicFieldBackendObject}->ValueSet(
                DynamicFieldConfig => $DynamicFieldGet,
                ObjectID           => $TicketID,
                Value              => $GetParam{$Key},
                UserID             => $Param{InmailUserID},
            );

            if ( $Self->{Debug} > 0 ) {
                print "$Key: " . $GetParam{$Key} . "\n";
            }
        }
    }

    # reverse dynamic field list
    my %DynamicFieldListReversed = reverse %{$DynamicFieldList};

    # set ticket free text
    my %Values =
        (
        'X-OTRS-TicketKey'   => 'TicketFreeKey',
        'X-OTRS-TicketValue' => 'TicketFreeText',
        );
    for my $Item ( sort keys %Values ) {
        for my $Count ( 1 .. 16 ) {
            my $Key = $Item . $Count;
            if ( $GetParam{$Key} && $DynamicFieldListReversed{ $Values{$Item} . $Count } ) {

                # get dynamic field config
                my $DynamicFieldGet = $Self->{TicketObject}->{DynamicFieldObject}->DynamicFieldGet(
                    ID => $DynamicFieldListReversed{ $Values{$Item} . $Count },
                );
                if ($DynamicFieldGet) {
                    my $Success = $Self->{TicketObject}->{DynamicFieldBackendObject}->ValueSet(
                        DynamicFieldConfig => $DynamicFieldGet,
                        ObjectID           => $TicketID,
                        Value              => $GetParam{$Key},
                        UserID             => $Param{InmailUserID},
                    );
                }

                if ( $Self->{Debug} > 0 ) {
                    print "TicketKey$Count: " . $GetParam{$Key} . "\n";
                }
            }
        }
    }

    # set ticket free time
    for my $Count ( 1 .. 6 ) {
        my $Key = 'X-OTRS-TicketTime' . $Count;
        if ( $GetParam{$Key} ) {
            my $SystemTime = $Self->{TimeObject}->TimeStamp2SystemTime(
                String => $GetParam{$Key},
            );
            if ( $SystemTime && $DynamicFieldListReversed{ 'TicketFreeTime' . $Count } ) {

                # get dynamic field config
                my $DynamicFieldGet = $Self->{TicketObject}->{DynamicFieldObject}->DynamicFieldGet(
                    ID => $DynamicFieldListReversed{ 'TicketFreeTime' . $Count },
                );
                if ($DynamicFieldGet) {
                    my $Success = $Self->{TicketObject}->{DynamicFieldBackendObject}->ValueSet(
                        DynamicFieldConfig => $DynamicFieldGet,
                        ObjectID           => $TicketID,
                        Value              => $GetParam{$Key},
                        UserID             => $Param{InmailUserID},
                    );
                }

                if ( $Self->{Debug} > 0 ) {
                    print "TicketTime$Count: " . $GetParam{$Key} . "\n";
                }
            }
        }
    }

    # do article db insert
    my $ArticleID = $Self->{TicketObject}->ArticleCreate(
        TicketID         => $TicketID,
        ArticleType      => $GetParam{'X-OTRS-ArticleType'},
        SenderType       => $GetParam{'X-OTRS-SenderType'},
        From             => $GetParam{From},
        ReplyTo          => $GetParam{ReplyTo},
        To               => $GetParam{To},
        Cc               => $GetParam{Cc},
        Subject          => $GetParam{Subject},
        MessageID        => $GetParam{'Message-ID'},
        InReplyTo        => $GetParam{'In-Reply-To'},
        References       => $GetParam{'References'},
        ContentType      => $GetParam{'Content-Type'},
        Body             => $GetParam{Body},
        UserID           => $Param{InmailUserID},
        HistoryType      => 'EmailCustomer',
        HistoryComment   => "\%\%$Comment",
        OrigHeader       => \%GetParam,
        AutoResponseType => $AutoResponseType,
        Queue            => $Queue,
    );

    # close ticket if article create failed!
    if ( !$ArticleID ) {
        $Self->{TicketObject}->TicketDelete(
            TicketID => $TicketID,
            UserID   => $Param{InmailUserID},
        );
        $Self->{LogObject}->Log(
            Priority => 'error',
            Message  => "Can't process email with MessageID <$GetParam{'Message-ID'}>! "
                . "Please create a bug report with this email (From: $GetParam{From}, Located "
                . "under var/spool/problem-email*) on http://bugs.otrs.org/!",
        );
        return;
    }

    # debug
    if ( $Self->{Debug} > 0 ) {
        print "From: $GetParam{From}\n";
        print "ReplyTo: $GetParam{ReplyTo}\n" if ( $GetParam{ReplyTo} );
        print "To: $GetParam{To}\n";
        print "Cc: $GetParam{Cc}\n" if ( $GetParam{Cc} );
        print "Subject: $GetParam{Subject}\n";
        print "MessageID: $GetParam{'Message-ID'}\n";
        print "Queue: $Queue\n";
        print "SenderType: $GetParam{'X-OTRS-SenderType'}\n";
        print "ArticleType: $GetParam{'X-OTRS-ArticleType'}\n";
    }

    # dynamic fields
    $DynamicFieldList =
        $Self->{TicketObject}->{DynamicFieldObject}->DynamicFieldList(
        Valid      => 1,
        ResultType => 'HASH',
        ObjectType => 'Article'
        );

    # set dynamic fields for Article object type
    DYNAMICFIELDID:
    for my $DynamicFieldID ( sort keys %{$DynamicFieldList} ) {
        next DYNAMICFIELDID if !$DynamicFieldID;
        next DYNAMICFIELDID if !$DynamicFieldList->{$DynamicFieldID};
        my $Key = 'X-OTRS-DynamicField-' . $DynamicFieldList->{$DynamicFieldID};
        if ( $GetParam{$Key} ) {

            # get dynamic field config
            my $DynamicFieldGet
                = $Self->{TicketObject}->{DynamicFieldObject}->DynamicFieldGet(
                ID => $DynamicFieldID,
                );

            $Self->{TicketObject}->{DynamicFieldBackendObject}->ValueSet(
                DynamicFieldConfig => $DynamicFieldGet,
                ObjectID           => $ArticleID,
                Value              => $GetParam{$Key},
                UserID             => $Param{InmailUserID},
            );

            if ( $Self->{Debug} > 0 ) {
                print "$Key: " . $GetParam{$Key} . "\n";
            }
        }
    }

    # reverse dynamic field list
    %DynamicFieldListReversed = reverse %{$DynamicFieldList};

    # set free article text
    %Values =
        (
        'X-OTRS-ArticleKey'   => 'ArticleFreeKey',
        'X-OTRS-ArticleValue' => 'ArticleFreeText',
        );
    for my $Item ( sort keys %Values ) {
        for my $Count ( 1 .. 16 ) {
            my $Key = $Item . $Count;
            if ( $GetParam{$Key} && $DynamicFieldListReversed{ $Values{$Item} . $Count } ) {

                # get dynamic field config
                my $DynamicFieldGet = $Self->{TicketObject}->{DynamicFieldObject}->DynamicFieldGet(
                    ID => $DynamicFieldListReversed{ $Values{$Item} . $Count },
                );
                if ($DynamicFieldGet) {
                    my $Success = $Self->{TicketObject}->{DynamicFieldBackendObject}->ValueSet(
                        DynamicFieldConfig => $DynamicFieldGet,
                        ObjectID           => $ArticleID,
                        Value              => $GetParam{$Key},
                        UserID             => $Param{InmailUserID},
                    );
                }

                if ( $Self->{Debug} > 0 ) {
                    print "TicketKey$Count: " . $GetParam{$Key} . "\n";
                }
            }
        }
    }

    # write plain email to the storage
    $Self->{TicketObject}->ArticleWritePlain(
        ArticleID => $ArticleID,
        Email     => $Self->{ParserObject}->GetPlainEmail(),
        UserID    => $Param{InmailUserID},
    );

    # write attachments to the storage
    for my $Attachment ( $Self->{ParserObject}->GetAttachments() ) {
        $Self->{TicketObject}->ArticleWriteAttachment(
            Filename           => $Attachment->{Filename},
            Content            => $Attachment->{Content},
            ContentType        => $Attachment->{ContentType},
            ContentID          => $Attachment->{ContentID},
            ContentAlternative => $Attachment->{ContentAlternative},
            ArticleID          => $ArticleID,
            UserID             => $Param{InmailUserID},
        );
    }

    return $TicketID;
}

1;
