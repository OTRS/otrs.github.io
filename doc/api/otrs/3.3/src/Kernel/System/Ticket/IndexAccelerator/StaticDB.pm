# --
# Kernel/System/Ticket/IndexAccelerator/StaticDB.pm - static db queue ticket index module
# Copyright (C) 2001-2014 OTRS AG, http://otrs.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package Kernel::System::Ticket::IndexAccelerator::StaticDB;

use strict;
use warnings;

sub TicketAcceleratorUpdate {
    my ( $Self, %Param ) = @_;

    # check needed stuff
    for (qw(TicketID)) {
        if ( !$Param{$_} ) {
            $Self->{LogObject}->Log( Priority => 'error', Message => "Need $_!" );
            return;
        }
    }

    # check if ticket is shown or not
    my $IndexUpdateNeeded = 0;
    my $IndexSelected     = 0;
    my %TicketData        = $Self->TicketGet(
        %Param,
        DynamicFields => 0,
    );
    my %IndexTicketData = $Self->GetIndexTicket(%Param);
    if ( !%IndexTicketData ) {
        $IndexUpdateNeeded = 1;
    }
    else {

        # check if we need to update
        if ( $TicketData{Lock} ne $IndexTicketData{Lock} ) {
            $IndexUpdateNeeded = 1;
        }
        elsif ( $TicketData{State} ne $IndexTicketData{State} ) {
            $IndexUpdateNeeded = 1;
        }
        elsif ( $TicketData{QueueID} ne $IndexTicketData{QueueID} ) {
            $IndexUpdateNeeded = 1;
        }
    }

    # check if this ticket is still viewable
    my @ViewableStates = $Self->{StateObject}->StateGetStatesByType(
        Type   => 'Viewable',
        Result => 'Name',
    );
    my $ViewableStatesHit = 0;
    for (@ViewableStates) {
        if ( $_ =~ /^$TicketData{State}$/i ) {
            $ViewableStatesHit = 1;
        }
    }

    my @ViewableLocks = $Self->{LockObject}->LockViewableLock(
        Type => 'Name',
    );
    my $ViewableLocksHit = 0;
    for (@ViewableLocks) {
        if ( $_ =~ /^$TicketData{Lock}$/i ) {
            $ViewableLocksHit = 1;
        }
    }
    if ( $ViewableStatesHit && $ViewableLocksHit ) {
        $IndexSelected = 1;
    }

    if ( $TicketData{ArchiveFlag} eq 'y' ) {
        $IndexSelected = 0;
    }

    # write index back
    if ($IndexUpdateNeeded) {
        if ($IndexSelected) {
            if ( $IndexTicketData{TicketID} ) {
                $Self->{DBObject}->Do(
                    SQL => '
                        UPDATE ticket_index
                        SET queue_id = ?, queue = ?, group_id = ?, s_lock = ?, s_state = ?
                        WHERE ticket_id = ?',
                    Bind => [
                        \$TicketData{QueueID}, \$TicketData{Queue}, \$TicketData{GroupID},
                        \$TicketData{Lock},    \$TicketData{State}, \$Param{TicketID},
                    ],
                );
            }
            else {
                $Self->TicketAcceleratorAdd(%TicketData);
            }
        }
        else {
            $Self->TicketAcceleratorDelete(%Param);
        }
    }

    # write lock index
    if ( !$ViewableLocksHit ) {

        # check if there is already an lock index entry
        if ( !$Self->_GetIndexTicketLock(%Param) ) {

            # add lock index entry
            $Self->TicketLockAcceleratorAdd(%TicketData);
        }
    }
    else {

        # delete lock index entry if tickst is unlocked
        $Self->TicketLockAcceleratorDelete(%Param);
    }
    return 1;
}

sub TicketAcceleratorDelete {
    my ( $Self, %Param ) = @_;

    # check needed stuff
    for (qw(TicketID)) {
        if ( !$Param{$_} ) {
            $Self->{LogObject}->Log( Priority => 'error', Message => "Need $_!" );
            return;
        }
    }

    return if !$Self->TicketLockAcceleratorDelete(%Param);
    return if !$Self->{DBObject}->Do(
        SQL  => 'DELETE FROM ticket_index WHERE ticket_id = ?',
        Bind => [ \$Param{TicketID} ],
    );
    return 1;
}

sub TicketAcceleratorAdd {
    my ( $Self, %Param ) = @_;

    # check needed stuff
    for (qw(TicketID)) {
        if ( !$Param{$_} ) {
            $Self->{LogObject}->Log( Priority => 'error', Message => "Need $_!" );
            return;
        }
    }

    # get ticket data
    my %TicketData = $Self->TicketGet(
        %Param,
        DynamicFields => 0,
    );

    # check if this ticket is still viewable
    my @ViewableStates = $Self->{StateObject}->StateGetStatesByType(
        Type   => 'Viewable',
        Result => 'Name',
    );
    my $ViewableStatesHit = 0;
    for (@ViewableStates) {
        if ( $_ =~ /^$TicketData{State}$/i ) {
            $ViewableStatesHit = 1;
        }
    }

    my @ViewableLocks = $Self->{LockObject}->LockViewableLock(
        Type => 'Name',
    );
    my $ViewableLocksHit = 0;
    for (@ViewableLocks) {
        if ( $_ =~ /^$TicketData{Lock}$/i ) {
            $ViewableLocksHit = 1;
        }
    }

    # do nothing if stats or lock is not viewable
    if ( !$ViewableStatesHit || !$ViewableLocksHit ) {
        return 1;
    }

    # do nothing if ticket is archived
    if ( $TicketData{ArchiveFlag} eq 'y' ) {
        return 1;
    }

    return if !$Self->{DBObject}->Do(
        SQL => '
            INSERT INTO ticket_index
                (ticket_id, queue_id, queue, group_id, s_lock, s_state, create_time_unix)
                VALUES (?, ?, ?, ?, ?, ?, ?)',
        Bind => [
            \$Param{TicketID},     \$TicketData{QueueID}, \$TicketData{Queue},
            \$TicketData{GroupID}, \$TicketData{Lock},    \$TicketData{State},
            \$TicketData{CreateTimeUnix},
        ],
    );
    return 1;
}

sub TicketLockAcceleratorDelete {
    my ( $Self, %Param ) = @_;

    # check needed stuff
    for (qw(TicketID)) {
        if ( !$Param{$_} ) {
            $Self->{LogObject}->Log( Priority => 'error', Message => "Need $_!" );
            return;
        }
    }

    # db query
    return if !$Self->{DBObject}->Do(
        SQL  => 'DELETE FROM ticket_lock_index WHERE ticket_id = ?',
        Bind => [ \$Param{TicketID} ],
    );
    return 1;
}

sub TicketLockAcceleratorAdd {
    my ( $Self, %Param ) = @_;

    # check needed stuff
    for (qw(TicketID)) {
        if ( !$Param{$_} ) {
            $Self->{LogObject}->Log( Priority => 'error', Message => "Need $_!" );
            return;
        }
    }

    # get ticket data
    my %TicketData = $Self->TicketGet(
        %Param,
        DynamicFields => 0,
    );
    return if !$Self->{DBObject}->Do(
        SQL  => 'INSERT INTO ticket_lock_index (ticket_id) VALUES (?)',
        Bind => [ \$Param{TicketID} ],
    );
    return 1;
}

sub TicketAcceleratorIndex {
    my ( $Self, %Param ) = @_;

    # check needed stuff
    for (qw(UserID QueueID ShownQueueIDs)) {
        if ( !exists( $Param{$_} ) ) {
            $Self->{LogObject}->Log( Priority => 'error', Message => "Need $_!" );
            return;
        }
    }
    my %Queues;
    $Queues{MaxAge}       = 0;
    $Queues{TicketsShown} = 0;
    $Queues{TicketsAvail} = 0;
    my @QueueIDs = @{ $Param{ShownQueueIDs} };

    # prepare "All tickets: ??" in Queue
    my @ViewableStateIDs = $Self->{StateObject}->StateGetStatesByType(
        Type   => 'Viewable',
        Result => 'ID',
    );
    if (@QueueIDs) {
        my $SQL = "
            SELECT count(*)
            FROM ticket st
            WHERE st.ticket_state_id IN ( ${\(join ', ', @ViewableStateIDs)} )
                AND st.queue_id IN (";
        for ( 0 .. $#QueueIDs ) {
            if ( $_ > 0 ) {
                $SQL .= ",";
            }
            $SQL .= $Self->{DBObject}->Quote( $QueueIDs[$_], 'Integer' );
        }
        $SQL .= " )";

        $Self->{DBObject}->Prepare( SQL => $SQL );
        while ( my @Row = $Self->{DBObject}->FetchrowArray() ) {
            $Queues{AllTickets} = $Row[0];
        }
    }

    # get user groups
    my $Type             = 'rw';
    my $AgentTicketQueue = $Self->{ConfigObject}->Get('Ticket::Frontend::AgentTicketQueue');
    if (
        $AgentTicketQueue
        && ref $AgentTicketQueue eq 'HASH'
        && $AgentTicketQueue->{ViewAllPossibleTickets}
        )
    {
        $Type = 'ro';
    }
    my @GroupIDs = $Self->{GroupObject}->GroupMemberList(
        UserID => $Param{UserID},
        Type   => $Type,
        Result => 'ID',
    );

    # get index
    $Queues{MaxAge} = 0;

    # check if user is in min. one group! if not, return here
    if ( !@GroupIDs ) {
        my %Hashes;
        $Hashes{QueueID} = 0;
        $Hashes{Queue}   = 'CustomQueue';
        $Hashes{MaxAge}  = 0;
        $Hashes{Count}   = 0;
        push @{ $Queues{Queues} }, \%Hashes;
        return %Queues;
    }

    # CustomQueue add on
    return if !$Self->{DBObject}->Prepare(
        SQL => "
            SELECT count(*)
            FROM ticket_index ti, personal_queues suq
            WHERE suq.queue_id = ti.queue_id
                AND ti.group_id IN ( ${\(join ', ', @GroupIDs)} )
                AND suq.user_id = $Param{UserID}",
    );
    while ( my @Row = $Self->{DBObject}->FetchrowArray() ) {
        my %Hashes;
        $Hashes{QueueID} = 0;
        $Hashes{Queue}   = 'CustomQueue';
        $Hashes{MaxAge}  = 0;
        $Hashes{Count}   = $Row[0];
        push @{ $Queues{Queues} }, \%Hashes;

        # set some things
        if ( $Param{QueueID} == 0 ) {
            $Queues{TicketsShown} = $Row[0];
            $Queues{TicketsAvail} = $Row[0];
        }
    }

    # prepare the tickets in Queue bar (all data only with my/your Permission)
    return if !$Self->{DBObject}->Prepare(
        SQL => "
            SELECT queue_id, queue, min(create_time_unix), count(*)
            FROM ticket_index
            WHERE group_id IN ( ${\(join ', ', @GroupIDs)} )
            GROUP BY queue_id, queue
            ORDER BY queue",
    );

    while ( my @RowTmp = $Self->{DBObject}->FetchrowArray() ) {

        # store the data into a array
        my %Hashes;
        $Hashes{QueueID} = $RowTmp[0];
        $Hashes{Queue}   = $RowTmp[1];
        $Hashes{MaxAge}  = $Self->{TimeObject}->SystemTime() - $RowTmp[2];
        $Hashes{Count}   = $RowTmp[3];
        push @{ $Queues{Queues} }, \%Hashes;

        # set some things
        if ( $Param{QueueID} == $RowTmp[0] ) {
            $Queues{TicketsShown} = $RowTmp[3];
            $Queues{TicketsAvail} = $RowTmp[3];
        }

        # get the oldest queue id
        if ( $Hashes{MaxAge} > $Queues{MaxAge} ) {
            $Queues{MaxAge}          = $Hashes{MaxAge};
            $Queues{QueueIDOfMaxAge} = $Hashes{QueueID};
        }
    }

    return %Queues;
}

sub TicketAcceleratorRebuild {
    my ( $Self, %Param ) = @_;

    my @ViewableStateIDs = $Self->{StateObject}->StateGetStatesByType(
        Type   => 'Viewable',
        Result => 'ID',
    );
    my @ViewableLockIDs = $Self->{LockObject}->LockViewableLock( Type => 'ID' );

    # get all viewable tickets
    my $SQL = "
        SELECT st.id, st.queue_id, sq.name, sq.group_id, slt.name, tsd.name, st.create_time_unix
        FROM ticket st, queue sq, ticket_state tsd, ticket_lock_type slt
        WHERE st.ticket_state_id = tsd.id
            AND st.queue_id = sq.id
            AND st.ticket_lock_id = slt.id
            AND st.ticket_state_id IN ( ${\(join ', ', @ViewableStateIDs)} )
            AND st.ticket_lock_id IN ( ${\(join ', ', @ViewableLockIDs)} )
            AND st.archive_flag = 0";

    return if !$Self->{DBObject}->Prepare( SQL => $SQL );
    my @RowBuffer;
    while ( my @Row = $Self->{DBObject}->FetchrowArray() ) {
        my %Data;
        $Data{TicketID}       = $Row[0];
        $Data{QueueID}        = $Row[1];
        $Data{Queue}          = $Row[2];
        $Data{GroupID}        = $Row[3];
        $Data{Lock}           = $Row[4];
        $Data{State}          = $Row[5];
        $Data{CreateTimeUnix} = $Row[6];
        push @RowBuffer, \%Data;
    }

    # write index
    return if !$Self->{DBObject}->Do( SQL => 'DELETE FROM ticket_index' );
    for (@RowBuffer) {
        my %Data = %{$_};
        $Self->{DBObject}->Do(
            SQL => '
                INSERT INTO ticket_index
                    (ticket_id, queue_id, queue, group_id, s_lock, s_state, create_time_unix)
                    VALUES (?, ?, ?, ?, ?, ?, ?)',
            Bind => [
                \$Data{TicketID}, \$Data{QueueID}, \$Data{Queue}, \$Data{GroupID},
                \$Data{Lock}, \$Data{State}, \$Data{CreateTimeUnix},
            ],
        );
    }

    # write lock index
    return if !$Self->{DBObject}->Prepare(
        SQL => "
            SELECT ti.id, ti.user_id
            FROM ticket ti
            WHERE ti.ticket_lock_id not IN ( ${\(join ', ', @ViewableLockIDs)} ) ",
    );
    my @LockRowBuffer;
    while ( my @Row = $Self->{DBObject}->FetchrowArray() ) {
        push @LockRowBuffer, $Row[0];
    }

    # add lock index entry
    return if !$Self->{DBObject}->Do( SQL => 'DELETE FROM ticket_lock_index' );
    for (@LockRowBuffer) {
        $Self->TicketLockAcceleratorAdd( TicketID => $_ );
    }
    return 1;
}

sub GetIndexTicket {
    my ( $Self, %Param ) = @_;

    # check needed stuff
    for (qw(TicketID)) {
        if ( !$Param{$_} ) {
            $Self->{LogObject}->Log( Priority => 'error', Message => "Need $_!" );
            return;
        }
    }

    # sql query
    return if !$Self->{DBObject}->Prepare(
        SQL => '
            SELECT ticket_id, queue_id, queue, group_id, s_lock, s_state, create_time_unix
            FROM ticket_index
            WHERE ticket_id = ?',
        Bind => [ \$Param{TicketID} ]
    );
    my %Data;
    while ( my @Row = $Self->{DBObject}->FetchrowArray() ) {
        $Data{TicketID}       = $Row[0];
        $Data{QueueID}        = $Row[1];
        $Data{Queue}          = $Row[2];
        $Data{GroupID}        = $Row[3];
        $Data{Lock}           = $Row[4];
        $Data{State}          = $Row[5];
        $Data{CreateTimeUnix} = $Row[6];
    }
    return %Data;
}

sub _GetIndexTicketLock {
    my ( $Self, %Param ) = @_;

    # check needed stuff
    for (qw(TicketID)) {
        if ( !$Param{$_} ) {
            $Self->{LogObject}->Log( Priority => 'error', Message => "Need $_!" );
            return;
        }
    }

    # sql query
    return if !$Self->{DBObject}->Prepare(
        SQL  => 'SELECT ticket_id FROM ticket_lock_index WHERE ticket_id = ?',
        Bind => [ \$Param{TicketID} ],
    );
    my $Hit = 0;
    while ( my @Row = $Self->{DBObject}->FetchrowArray() ) {
        $Hit = 1;
    }
    return $Hit;
}

1;
