# --
# Kernel/System/Ticket/CustomerPermission/CustomerIDCheck.pm - the sub
# module of the global ticket handle
# Copyright (C) 2001-2014 OTRS AG, http://otrs.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package Kernel::System::Ticket::CustomerPermission::CustomerIDCheck;

use strict;
use warnings;

sub new {
    my ( $Type, %Param ) = @_;

    # allocate new hash for object
    my $Self = {};
    bless( $Self, $Type );

    # get needed objects
    for (qw(ConfigObject LogObject DBObject TicketObject CustomerUserObject)) {
        $Self->{$_} = $Param{$_} || die "Got no $_!";
    }

    # disable output of customer company tickets
    $Self->{DisableCompanyTickets}
        = $Self->{ConfigObject}->Get('Ticket::Frontend::CustomerDisableCompanyTicketAccess');

    return $Self;
}

sub Run {
    my ( $Self, %Param ) = @_;

    # check needed stuff
    for (qw(TicketID UserID)) {
        if ( !$Param{$_} ) {
            $Self->{LogObject}->Log( Priority => 'error', Message => "Need $_!" );
            return;
        }
    }

    # disable output of customer company tickets if configured
    return if $Self->{DisableCompanyTickets};

    # get ticket data
    my %Ticket = $Self->{TicketObject}->TicketGet(
        TicketID      => $Param{TicketID},
        DynamicFields => 0,
    );

    # check customer id
    my %CustomerData = $Self->{CustomerUserObject}->CustomerUserDataGet( User => $Param{UserID} );

    # get customer ids
    my @CustomerIDs = $Self->{CustomerUserObject}->CustomerIDs( User => $Param{UserID} );

    # add own customer id
    if ( $CustomerData{UserCustomerID} ) {
        push @CustomerIDs, $CustomerData{UserCustomerID};
    }

    # check customer ids, return access if customer id is the same
    CUSTOMERID:
    for my $CustomerID (@CustomerIDs) {
        next CUSTOMERID if !$Ticket{CustomerID};
        return 1 if ( lc $Ticket{CustomerID} eq lc $CustomerID );
    }

    # return no access
    return;
}

1;
