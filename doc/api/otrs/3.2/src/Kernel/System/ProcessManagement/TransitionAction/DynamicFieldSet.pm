# --
# Kernel/System/ProcessManagement/TransitionAction/DynamicFieldSet.pm - A Module to change the ticket owner
# Copyright (C) 2001-2014 OTRS AG, http://otrs.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package Kernel::System::ProcessManagement::TransitionAction::DynamicFieldSet;

use strict;
use warnings;
use Kernel::System::VariableCheck qw(:all);

use utf8;
use Kernel::System::DynamicField;
use Kernel::System::DynamicField::Backend;

=head1 NAME

Kernel::System::ProcessManagement::TransitionAction::DynamicFieldSet - A module to set a new ticket owner

=head1 SYNOPSIS

All DynamicFieldSet functions.

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
    use Kernel::System::ProcessManagement::TransitionAction::DynamicFieldSet;

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
    my $DynamicFieldSetActionObject = Kernel::System::ProcessManagement::TransitionAction::DynamicFieldSet->new(
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

    $Self->{DynamicFieldObject}        = Kernel::System::DynamicField->new(%Param);
    $Self->{DynamicFieldBackendObject} = Kernel::System::DynamicField::Backend->new(%Param);
    return $Self;
}

=item Run()

    Run Data

    my $DynamicFieldSetResult = $DynamicFieldSetActionObject->Run(
        UserID                   => 123,
        Ticket                   => \%Ticket,   # required
        ProcessEntityID          => 'P123',     # optional
        ActivityEntityID         => 'A123',     # optional
        TransitionEntityID       => 'T123',     # optional
        TransitionActionEntityID => 'TA123',    # optional
        Config                   => {
            MasterSlave => 'Master',
            Approved    => '1',
            UserID      => 123,                 # optional, to override the UserID from the logged user
        }
    );
    Ticket contains the result of TicketGet including DynamicFields
    Config is the Config Hash stored in a Process::TransitionAction's  Config key

    If a Dynamic Field is named UserID (to avoid conficts) it must be set in the config as:
    DynamicField_UserID => $Value,

    Returns:

    $DynamicFieldSetResult = 1; # 0

    );

=cut

sub Run {
    my ( $Self, %Param ) = @_;

    for my $Needed (qw(UserID Ticket Config)) {
        if ( !defined $Param{$Needed} ) {
            $Self->{LogObject}->Log(
                Priority => 'error',
                Message  => "Need $Needed!",
            );
            return;
        }
    }

    # define a common message to output in case of any error
    my $CommonMessage;
    if ( $Param{ProcessEntityID} ) {
        $CommonMessage .= "Process: $Param{ProcessEntityID}";
    }
    if ( $Param{ActivityEntityID} ) {
        $CommonMessage .= " Activity: $Param{ActivityEntityID}";
    }
    if ( $Param{TransitionEntityID} ) {
        $CommonMessage .= " Transition: $Param{TransitionEntityID}";
    }
    if ( $Param{TransitionActionEntityID} ) {
        $CommonMessage .= " TransitionAction: $Param{TransitionActionEntityID}";
    }
    if ($CommonMessage) {

        # add a separator
        $CommonMessage .= " - ";
    }
    else {

        # otherwise at least define it to prevent errors
        $CommonMessage = '';
    }

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

    # special case for DyanmicField UserID, convert form DynamicField_UserID to UserID
    if ( defined $Param{Config}->{DynamicField_UserID} ) {
        $Param{Config}->{UserID} = $Param{Config}->{DynamicField_UserID};
        delete $Param{Config}->{DynamicField_UserID};
    }

    for my $CurrentDynamicField ( sort keys %{ $Param{Config} } ) {

        # get required DynamicField config
        my $DynamicFieldConfig = $Self->{DynamicFieldObject}->DynamicFieldGet(
            Name => $CurrentDynamicField,
        );

        # check if we have a valid DynamicField
        if ( !IsHashRefWithData($DynamicFieldConfig) ) {
            $Self->{LogObject}->Log(
                Priority => 'error',
                Message  => $CommonMessage
                    . "Can't get DynamicField config for DynamicField: '$CurrentDynamicField'!",
            );
            return;
        }

        # try to set the configured value
        my $Success = $Self->{DynamicFieldBackendObject}->ValueSet(
            DynamicFieldConfig => $DynamicFieldConfig,
            ObjectID           => $Param{Ticket}->{TicketID},
            Value              => $Param{Config}->{$CurrentDynamicField},
            UserID             => $Param{UserID},
        );

        # check if everything went right
        if ( !$Success ) {
            $Self->{LogObject}->Log(
                Priority => 'error',
                Message  => $CommonMessage
                    . "Can't set value '"
                    . $Param{Config}->{$CurrentDynamicField}
                    . "' for DynamicField '$CurrentDynamicField',"
                    . "TicketID '" . $Param{Ticket}->{TicketID} . "'!",
            );
            return;
        }
    }

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
