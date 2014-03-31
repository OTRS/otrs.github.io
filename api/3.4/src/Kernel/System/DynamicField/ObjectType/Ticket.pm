# --
# Kernel/System/DynamicField/ObjectType/Ticket.pm - Ticket object handler for DynamicField
# Copyright (C) 2001-2014 OTRS AG, http://otrs.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package Kernel::System::DynamicField::ObjectType::Ticket;

use strict;
use warnings;

use Scalar::Util;

use Kernel::System::VariableCheck qw(:all);
use Kernel::System::Ticket;

=head1 NAME

Kernel::System::DynamicField::ObjectType::Ticket

=head1 SYNOPSIS

Ticket object handler for DynamicFields

=head1 PUBLIC INTERFACE

=over 4

=item new()

usually, you want to create an instance of this
by using Kernel::System::DynamicField::ObjectType::Ticket->new();

=cut

sub new {
    my ( $Type, %Param ) = @_;

    # allocate new hash for object
    my $Self = {};
    bless( $Self, $Type );

    # get needed objects
    for my $Needed (
        qw(ConfigObject EncodeObject LogObject MainObject DBObject TimeObject)
        )
    {
        die "Got no $Needed!" if !$Param{$Needed};

        $Self->{$Needed} = $Param{$Needed};
    }

    # check for TicketObject
    if ( $Param{TicketObject} ) {

        $Self->{TicketObject} = $Param{TicketObject};

     # Make ticket object reference weak so it will not count as a reference on objects destroy.
     #   This is because the TicketObject has a Kernel::DynamicField::Backend object, which has this
     #   object, which has a TicketObject again. Without weaken() we'd have a cyclic reference.
        Scalar::Util::weaken( $Self->{TicketObject} );
    }

    return $Self;
}

=item PostValueSet()

perform specific functions after the Value set for this object type.

    my $Success = $DynamicFieldTicketHandlerObject->PostValueSet(
        DynamicFieldConfig => $DynamicFieldConfig,      # complete config of the DynamicField
        ObjectID           => $ObjectID,                # ID of the current object that the field
                                                        # must be linked to, e. g. TicketID
        Value              => $Value,                   # Value to store, depends on backend type
        UserID             => 123,
    );

=cut

sub PostValueSet {
    my ( $Self, %Param ) = @_;

    # check needed stuff
    for my $Needed (qw(DynamicFieldConfig ObjectID UserID)) {
        if ( !$Param{$Needed} ) {
            $Self->{LogObject}->Log( Priority => 'error', Message => "Need $Needed!" );
            return;
        }
    }

    # check DynamicFieldConfig (general)
    if ( !IsHashRefWithData( $Param{DynamicFieldConfig} ) ) {
        $Self->{LogObject}->Log(
            Priority => 'error',
            Message  => "The field configuration is invalid",
        );
        return;
    }

    # check DynamicFieldConfig (internally)
    for my $Needed (qw(ID FieldType ObjectType)) {
        if ( !$Param{DynamicFieldConfig}->{$Needed} ) {
            $Self->{LogObject}->Log(
                Priority => 'error',
                Message  => "Need $Needed in DynamicFieldConfig!"
            );
            return;
        }
    }

    # check for TicketObject
    if ( !$Self->{TicketObject} ) {

        # create it on demand
        $Self->{TicketObject} = Kernel::System::Ticket->new( %{$Self} );
    }

    my %Ticket = $Self->{TicketObject}->TicketGet(
        TicketID      => $Param{ObjectID},
        DynamicFields => 0,
    );

    my $HistoryValue    = defined $Param{Value}    ? $Param{Value}    : '';
    my $HistoryOldValue = defined $Param{OldValue} ? $Param{OldValue} : '';

    # get value for storing
    my $ValueStrg = $Self->{TicketObject}->{DynamicFieldBackendObject}->ReadableValueRender(
        DynamicFieldConfig => $Param{DynamicFieldConfig},
        Value              => $HistoryValue,
    );
    $HistoryValue = $ValueStrg->{Value};

    my $OldValueStrg = $Self->{TicketObject}->{DynamicFieldBackendObject}->ReadableValueRender(
        DynamicFieldConfig => $Param{DynamicFieldConfig},
        Value              => $HistoryOldValue,
    );
    $HistoryOldValue = $OldValueStrg->{Value};

    # history insert
    $Self->{TicketObject}->HistoryAdd(
        TicketID    => $Param{ObjectID},
        QueueID     => $Ticket{QueueID},
        HistoryType => 'TicketDynamicFieldUpdate',
        Name =>
            "\%\%FieldName\%\%$Param{DynamicFieldConfig}->{Name}"
            . "\%\%Value\%\%$HistoryValue\%\%OldValue\%\%$HistoryOldValue",
        CreateUserID => $Param{UserID},
    );

    # clear ticket cache
    $Self->{TicketObject}->_TicketCacheClear( TicketID => $Param{ObjectID} );

    # Trigger event.
    $Self->{TicketObject}->EventHandler(
        Event => 'TicketDynamicFieldUpdate_' . $Param{DynamicFieldConfig}->{Name},
        Data  => {
            FieldName => $Param{DynamicFieldConfig}->{Name},
            Value     => $Param{Value},
            OldValue  => $Param{OldValue},
            TicketID  => $Param{ObjectID},
            UserID    => $Param{UserID},
        },
        UserID => $Param{UserID},
    );

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
