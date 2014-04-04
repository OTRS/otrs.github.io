# --
# Ticket/Number/Date.pm - a date ticket number generator
# Copyright (C) 2001-2014 OTRS AG, http://otrs.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --
# Note:
# available objects are: ConfigObject, LogObject and DBObject
#
# Generates ticket numbers like yyyymmddss.... (e. g. 200206231010138)
# --

package Kernel::System::Ticket::Number::Date;

use strict;
use warnings;

sub TicketCreateNumber {
    my ( $Self, $JumpCounter ) = @_;
    if ( !$JumpCounter ) {
        $JumpCounter = 0;
    }

    # get needed config options
    my $CounterLog = $Self->{ConfigObject}->Get('Ticket::CounterLog');
    my $SystemID   = $Self->{ConfigObject}->Get('SystemID');

    # get current time
    my ( $Sec, $Min, $Hour, $Day, $Month, $Year ) = $Self->{TimeObject}->SystemTime2Date(
        SystemTime => $Self->{TimeObject}->SystemTime(),
    );

    # read count
    my $Count = 0;
    if ( -f $CounterLog ) {
        my $ContentSCALARRef = $Self->{MainObject}->FileRead(
            Location => $CounterLog,
        );
        if ( $ContentSCALARRef && ${$ContentSCALARRef} ) {
            ($Count) = split( /;/, ${$ContentSCALARRef} );

            # just debug
            if ( $Self->{Debug} > 0 ) {
                $Self->{LogObject}->Log(
                    Priority => 'debug',
                    Message  => "Read counter from $CounterLog: $Count",
                );
            }
        }
    }

    # count auto increment ($Count++)
    $Count++;
    $Count = $Count + $JumpCounter;

    # write new count
    my $Write = $Self->{MainObject}->FileWrite(
        Location => $CounterLog,
        Content  => \$Count,
    );
    if ($Write) {
        if ( $Self->{Debug} > 0 ) {
            $Self->{LogObject}->Log(
                Priority => 'debug',
                Message  => "Write counter: $Count",
            );
        }
    }

    # create new ticket number
    my $Tn = $Year . $Month . $Day . $SystemID . $Count;

    # Check ticket number. If exists generate new one!
    if ( $Self->TicketCheckNumber( Tn => $Tn ) ) {
        $Self->{LoopProtectionCounter}++;
        if ( $Self->{LoopProtectionCounter} >= 16000 ) {

            # loop protection
            $Self->{LogObject}->Log(
                Priority => 'error',
                Message  => "CounterLoopProtection is now $Self->{LoopProtectionCounter}!"
                    . " Stopped TicketCreateNumber()!",
            );
            return;
        }

        # create new ticket number again
        $Self->{LogObject}->Log(
            Priority => 'notice',
            Message  => "Tn ($Tn) exists! Creating a new one.",
        );
        $Tn = $Self->TicketCreateNumber( $Self->{LoopProtectionCounter} );
    }
    return $Tn;
}

sub GetTNByString {
    my ( $Self, $String ) = @_;
    if ( !$String ) {
        return;
    }

    # get needed config options
    my $CheckSystemID = $Self->{ConfigObject}->Get('Ticket::NumberGenerator::CheckSystemID');
    my $SystemID      = '';
    if ($CheckSystemID) {
        $SystemID = $Self->{ConfigObject}->Get('SystemID');
    }
    my $TicketHook        = $Self->{ConfigObject}->Get('Ticket::Hook');
    my $TicketHookDivider = $Self->{ConfigObject}->Get('Ticket::HookDivider');

    # check current setting
    if ( $String =~ /\Q$TicketHook$TicketHookDivider\E(\d{8}$SystemID\d{1,40})/i ) {
        return $1;
    }

    # check default setting
    if ( $String =~ /\Q$TicketHook\E:\s{0,2}(\d{8}$SystemID\d{1,40})/i ) {
        return $1;
    }

    return;
}

1;
