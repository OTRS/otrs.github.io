# --
# Kernel/System/Ticket/CustomerPermission/GroupCheck.pm -
# the sub module of the global ticket handle
# Copyright (C) 2001-2014 OTRS AG, http://otrs.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package Kernel::System::Ticket::CustomerPermission::GroupCheck;

use strict;
use warnings;

sub new {
    my ( $Type, %Param ) = @_;

    # allocate new hash for object
    my $Self = {};
    bless( $Self, $Type );

    # get needed objects
    for (
        qw(ConfigObject LogObject DBObject TicketObject QueueObject CustomerGroupObject CustomerUserObject)
        )
    {
        $Self->{$_} = $Param{$_} || die "Got no $_!";
    }

    return $Self;
}

sub Run {
    my ( $Self, %Param ) = @_;

    # check needed stuff
    for (qw(TicketID UserID Type)) {
        if ( !$Param{$_} ) {
            $Self->{LogObject}->Log( Priority => 'error', Message => "Need $_!" );
            return;
        }
    }

    # get ticket data
    my %Ticket = $Self->{TicketObject}->TicketGet(
        TicketID      => $Param{TicketID},
        DynamicFields => 0,
    );

    # get ticket group
    my $GroupID = $Self->{QueueObject}->GetQueueGroupID( QueueID => $Ticket{QueueID} );

    # get user groups
    my %GroupIDs = $Self->{CustomerGroupObject}->GroupMemberList(
        UserID => $Param{UserID},
        Type   => $Param{Type},
        Result => 'HASH',
    );

    # return access if customer is in group
    return 1 if $GroupIDs{$GroupID};

    # return no access
    return;
}

1;
