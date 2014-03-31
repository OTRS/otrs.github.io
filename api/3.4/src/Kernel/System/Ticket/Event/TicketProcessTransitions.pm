# --
# Kernel/System/Ticket/Event/TicketProcessTransitions.pm - a event module to change from one activity to another based on the transition
# Copyright (C) 2001-2014 OTRS AG, http://otrs.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package Kernel::System::Ticket::Event::TicketProcessTransitions;

use strict;
use warnings;

use Kernel::System::ProcessManagement::Activity;
use Kernel::System::ProcessManagement::ActivityDialog;
use Kernel::System::ProcessManagement::Process;
use Kernel::System::ProcessManagement::Transition;
use Kernel::System::ProcessManagement::TransitionAction;

sub new {
    my ( $Type, %Param ) = @_;

    # allocate new hash for object
    my $Self = {};
    bless( $Self, $Type );

    # get needed objects
    for my $Needed (
        qw(ConfigObject EncodeObject TimeObject DBObject MainObject TicketObject LogObject)
        )
    {
        $Self->{$Needed} = $Param{$Needed} || die "Got no $Needed!";
    }

    return $Self;
}

sub Run {
    my ( $Self, %Param ) = @_;

    # check needed stuff
    for my $Needed (qw(Data Event Config UserID)) {
        if ( !$Param{$Needed} ) {
            $Self->{LogObject}->Log(
                Priority => 'error',
                Message  => "Need $Needed!",
            );
            return;
        }
    }

    # listen to all kinds of events
    if ( !$Param{Data}->{TicketID} ) {
        $Self->{LogObject}->Log(
            Priority => 'error',
            Message  => "Need TicketID in Data!",
        );
        return;
    }

    my $CacheKey = '_TicketProcessTransitions::AlreadyProcessed';

    # loop protection: only execute this handler once for each ticket, as multiple events may be
    #   fired, for example TicketTitleUpdate and TicketPriorityUpdate.
    return if ( $Self->{TicketObject}->{$CacheKey}->{ $Param{Data}->{TicketID} } );

    # get ticket data in silent mode, it could be that the ticket was deleted
    #   in the meantime.
    my %Ticket = $Self->{TicketObject}->TicketGet(
        TicketID      => $Param{Data}->{TicketID},
        DynamicFields => 1,
        Silent        => 1,
    );

    if ( !%Ticket ) {

        # remember that the event was executed for this TicketID to avoid multiple executions.
        #   Store the information on the ticketobject
        $Self->{TicketObject}->{$CacheKey}->{ $Param{Data}->{TicketID} } = 1;

        return;
    }

    my $ProcessIDField
        = $Self->{ConfigObject}->Get("Process::DynamicFieldProcessManagementProcessID");
    my $ProcessEntityID = $Ticket{"DynamicField_$ProcessIDField"};

    my $ActivityIDField
        = $Self->{ConfigObject}->Get("Process::DynamicFieldProcessManagementActivityID");
    my $ActivityEntityID = $Ticket{"DynamicField_$ActivityIDField"};

    # ticket can be ignored if it is no process ticket. Don't set the cache key in this case as
    #   later events might make a transition check neccessary.
    return if ( !$ProcessEntityID || !$ActivityEntityID );

    # ok, now we know that we need to call the transition logic for this ticket.

    # create the needed objects only now to save performance.
    my $ActivityObject = Kernel::System::ProcessManagement::Activity->new( %{$Self} );
    my $ActivityDialogObject
        = Kernel::System::ProcessManagement::ActivityDialog->new( %{$Self} );
    my $TransitionObject = Kernel::System::ProcessManagement::Transition->new( %{$Self} );
    my $TransitionActionObject
        = Kernel::System::ProcessManagement::TransitionAction->new( %{$Self} );
    my $ProcessObject = Kernel::System::ProcessManagement::Process->new(
        %{$Self},
        ActivityObject         => $ActivityObject,
        ActivityDialogObject   => $ActivityDialogObject,
        TransitionObject       => $TransitionObject,
        TransitionActionObject => $TransitionActionObject,
    );

    # Remember that the event was executed for this ticket to avoid multiple executions.
    #   Store the information on the ticketobject, this needs to be done before the execution of the
    #   transitions as it could happen that the transition generates new events that will be
    #   processed in the mean time, before the chache is set, see bug#9748
    $Self->{TicketObject}->{$CacheKey}->{ $Param{Data}->{TicketID} } = 1;

    my $TransitionApplied = $ProcessObject->ProcessTransition(
        ProcessEntityID  => $ProcessEntityID,
        ActivityEntityID => $ActivityEntityID,
        TicketID         => $Param{Data}->{TicketID},
        UserID           => $Param{UserID},
    );

    if ( $Self->{Debug} ) {
        $Self->{LogObject}->Log(
            Priority => 'error',
            Message =>
                "Transition for to TicketID: $Param{Data}->{TicketID}"
                . "  ProcessEntityID: $ProcessEntityID OldActivityEntityID: $ActivityEntityID "
                . ( $TransitionApplied ? "was applied." : "was not applied." ),
        );
    }

    return 1;
}

1;
