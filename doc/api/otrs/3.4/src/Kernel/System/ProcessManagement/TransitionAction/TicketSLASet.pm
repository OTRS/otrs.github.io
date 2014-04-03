# --
# Kernel/System/ProcessManagement/TransitionAction/TicketSLASet.pm - A Module to set the ticket service
# Copyright (C) 2001-2014 OTRS AG, http://otrs.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package Kernel::System::ProcessManagement::TransitionAction::TicketSLASet;

use strict;
use warnings;
use Kernel::System::VariableCheck qw(:all);

use utf8;
use Kernel::System::SLA;

=head1 NAME

Kernel::System::ProcessManagement::TransitionAction::TicketSLASet - A module to set the ticket SLA

=head1 SYNOPSIS

All TicketSLASet functions.

=head1 PUBLIC INTERFACE

=over 4

=cut

=item new()

create an object

    use Kernel::Config;
    use Kernel::System::Encode;
    use Kernel::System::Log;
    use Kernel::System::Time;
    use Kernel::System::Main;
    use Kernel::System::DB;
    use Kernel::System::Ticket;
    use Kernel::System::ProcessManagement::TransitionAction::TicketSLASet;

    my $ConfigObject = Kernel::Config->new();
    my $EncodeObject = Kernel::System::Encode->new(
        ConfigObject => $ConfigObject,
    );
    my $LogObject = Kernel::System::Log->new(
        ConfigObject => $ConfigObject,
        EncodeObject => $EncodeObject,
    );
    my $TimeObject = Kernel::System::Time->new(
        ConfigObject => $ConfigObject,
        LogObject    => $LogObject,
    );
    my $MainObject = Kernel::System::Main->new(
        ConfigObject => $ConfigObject,
        EncodeObject => $EncodeObject,
        LogObject    => $LogObject,
    );
    my $DBObject = Kernel::System::DB->new(
        ConfigObject => $ConfigObject,
        EncodeObject => $EncodeObject,
        LogObject    => $LogObject,
        MainObject   => $MainObject,
    );
    my $TicketObject = Kernel::System::Ticket->new(
        ConfigObject       => $ConfigObject,
        LogObject          => $LogObject,
        DBObject           => $DBObject,
        MainObject         => $MainObject,
        TimeObject         => $TimeObject,
        EncodeObject       => $EncodeObject,
    );
    my $TicketSLASetActionObject = Kernel::System::ProcessManagement::TransitionAction::TicketSLASet->new(
        ConfigObject       => $ConfigObject,
        LogObject          => $LogObject,
        EncodeObject       => $EncodeObject,
        DBObject           => $DBObject,
        MainObject         => $MainObject,
        TimeObject         => $TimeObject,
        TicketObject       => $TicketObject,
    );

=cut

sub new {
    my ( $Type, %Param ) = @_;

    # allocate new hash for object
    my $Self = {};
    bless( $Self, $Type );

    # get needed objects
    for my $Needed (
        qw(ConfigObject LogObject EncodeObject DBObject MainObject TimeObject TicketObject)
        )
    {
        die "Got no $Needed!" if !$Param{$Needed};

        $Self->{$Needed} = $Param{$Needed};
    }

    $Self->{SLAObject} = Kernel::System::SLA->new(
        %Param,
        DBObject   => $Self->{DBObject},
        MainObject => $Self->{MainObject},
        TimeObject => $Self->{TimeObject},
    );

    return $Self;
}

=item Run()

    Run Data

    my $TicketSLASetResult = $TicketSLASetActionObject->Run(
        UserID                   => 123,
        Ticket                   => \%Ticket,   # required
        ProcessEntityID          => 'P123',
        ActivityEntityID         => 'A123',
        TransitionEntityID       => 'T123',
        TransitionActionEntityID => 'TA123',
        Config                   => {
            SLA => 'MySLA',
            # or
            SLAID  => 123,
            UserID => 123,                      # optional, to override the UserID from the logged user
        }
    );
    Ticket contains the result of TicketGet including DynamicFields
    Config is the Config Hash stored in a Process::TransitionAction's  Config key
    Returns:

    $TicketSLASetResult = 1; # 0

=cut

sub Run {
    my ( $Self, %Param ) = @_;

    for my $Needed (
        qw(UserID Ticket ProcessEntityID ActivityEntityID TransitionEntityID
        TransitionActionEntityID Config
        )
        )
    {
        if ( !defined $Param{$Needed} ) {
            $Self->{LogObject}->Log(
                Priority => 'error',
                Message  => "Need $Needed!",
            );
            return;
        }
    }

    # define a common message to output in case of any error
    my $CommonMessage = "Process: $Param{ProcessEntityID} Activity: $Param{ActivityEntityID}"
        . " Transition: $Param{TransitionEntityID}"
        . " TransitionAction: $Param{TransitionActionEntityID} - ";

    # Check if we have Ticket to deal with
    if ( !IsHashRefWithData( $Param{Ticket} ) ) {
        $Self->{LogObject}->Log(
            Priority => 'error',
            Message  => $CommonMessage . "Ticket has no values!",
        );
        return;
    }

    # Check if we have a ConfigHash
    if ( !IsHashRefWithData( $Param{Config} ) ) {
        $Self->{LogObject}->Log(
            Priority => 'error',
            Message  => $CommonMessage . "Config has no values!",
        );
        return;
    }

    # override UserID if specified as a parameter in the TA config
    if ( IsNumber( $Param{Config}->{UserID} ) ) {
        $Param{UserID} = $Param{Config}->{UserID};
        delete $Param{Config}->{UserID};
    }

    if ( !$Param{Config}->{SLAID} && !$Param{Config}->{SLA} ) {
        $Self->{LogObject}->Log(
            Priority => 'error',
            Message  => $CommonMessage . "No SLA or SLAID configured!",
        );
        return;
    }

    if ( !$Param{Ticket}->{ServiceID} && !$Param{Ticket}->{Service} ) {
        $Self->{LogObject}->Log(
            Priority => 'error',
            Message  => $CommonMessage . "To set a SLA the ticket requires a service!",
        );
        return;
    }

    my $Success;

    # If Ticket's SLAID is already the same as the Value we
    # should set it to, we got nothing to do and return success
    if (
        defined $Param{Config}->{SLAID}
        && defined $Param{Ticket}->{SLAID}
        && $Param{Config}->{SLAID} eq $Param{Ticket}->{SLAID}
        )
    {
        return 1;
    }

    # If Ticket's SLAID is not the same as the Value we
    # should set it to, set the SLAID
    elsif (
        (
            defined $Param{Config}->{SLAID}
            && defined $Param{Ticket}->{SLAID}
            && $Param{Config}->{SLAID} ne $Param{Ticket}->{SLAID}
        )
        || !defined $Param{Ticket}->{SLAID}
        )
    {

        # check if serivce is assigned to Service otherwise return
        $Success = $Self->_CheckSLA(
            ServiceID => $Param{Ticket}->{ServiceID},
            SLAID     => $Param{Config}->{SLAID},
        );

        if ( !$Success ) {
            $Self->{LogObject}->Log(
                Priority => 'error',
                Message  => $CommonMessage
                    . 'SLAID '
                    . $Param{Config}->{SLAID}
                    . ' is not assigned to Service '
                    . $Param{Ticket}->{Service}
            );
            return;
        }

        # set ticket SLA
        $Success = $Self->{TicketObject}->TicketSLASet(
            TicketID => $Param{Ticket}->{TicketID},
            SLAID    => $Param{Config}->{SLAID},
            UserID   => $Param{UserID},
        );

        if ( !$Success ) {
            $Self->{LogObject}->Log(
                Priority => 'error',
                Message  => $CommonMessage
                    . 'Ticket SLAID '
                    . $Param{Config}->{SLAID}
                    . ' could not be updated for Ticket: '
                    . $Param{Ticket}->{TicketID} . '!',
            );
        }
    }

    # If Ticket's SLA is already the same as the Value we
    # should set it to, we got nothing to do and return success
    elsif (
        defined $Param{Config}->{SLA}
        && defined $Param{Ticket}->{SLA}
        && $Param{Config}->{SLA} eq $Param{Ticket}->{SLA}
        )
    {
        return 1;
    }

    # If Ticket's SLA is not the same as the Value we
    # should set it to, set the SLA
    elsif (
        (
            defined $Param{Config}->{SLA}
            && defined $Param{Ticket}->{SLA}
            && $Param{Config}->{SLA} ne $Param{Ticket}->{SLA}
        )
        || !defined $Param{Ticket}->{SLA}
        )
    {

        my $SLAID = $Self->{SLAObject}->SLALookup(
            Name => $Param{Config}->{SLA},
        );

        if ( !$SLAID ) {
            $Self->{LogObject}->Log(
                Priority => 'error',
                Message  => $CommonMessage
                    . 'SLA '
                    . $Param{Config}->{SLA}
                    . ' is invalid!'
            );
            return;
        }

        # check if SLA is assigned to Service, otherwise return
        $Success = $Self->_CheckSLA(
            ServiceID => $Param{Ticket}->{ServiceID},
            SLAID     => $SLAID,
        );

        if ( !$Success ) {
            $Self->{LogObject}->Log(
                Priority => 'error',
                Message  => $CommonMessage
                    . 'SLA '
                    . $Param{Config}->{SLA}
                    . ' is not assigned to Service '
                    . $Param{Ticket}->{Service}
            );
            return;
        }

        # set ticket SLA
        $Success = $Self->{TicketObject}->TicketSLASet(
            TicketID => $Param{Ticket}->{TicketID},
            SLA      => $Param{Config}->{SLA},
            UserID   => $Param{UserID},
        );

        if ( !$Success ) {
            $Self->{LogObject}->Log(
                Priority => 'error',
                Message  => $CommonMessage
                    . 'Ticket SLA '
                    . $Param{Config}->{SLA}
                    . ' could not be updated for Ticket: '
                    . $Param{Ticket}->{TicketID} . '!',
            );
        }
    }
    else {
        $Self->{LogObject}->Log(
            Priority => 'error',
            Message  => $CommonMessage
                . "Couldn't update Ticket SLA - can't find valid SLA parameter!",
        );
        return;
    }

    return $Success;
}

=item _CheckSLA()

checks if a SLA is assigned to a Service

    my $Success = _CheckSLA(
        ServiceID => 123,
        SLAID     => 123,
    );

    Returns:

    $Success = 1;       # or undef
=cut

sub _CheckSLA {
    my ( $Self, %Param ) = @_;

    # get a list of assigned SLAs to the Service
    my %SLAs = $Self->{SLAObject}->SLAList(
        ServiceID => $Param{ServiceID},
        UserID    => 1,
    );

    # return failure if there are no assigned SLAs for this Service
    return if !IsHashRefWithData( \%SLAs );

    # return failure if the the SLA is not assigned to the Service
    return if !$SLAs{ $Param{SLAID} };

    # otherwise return success
    return 1;
}
1;

=back

=head1 TERMS AND CONDITIONS

This software is part of the OTRS project (L<http://otrs.org/>).

This software comes with ABSOLUTELY NO WARRANTY. For details, see
the enclosed file COPYING for license information (AGPL). If you
did not receive this file, see L<http://www.gnu.org/licenses/agpl.txt>.

=cut
