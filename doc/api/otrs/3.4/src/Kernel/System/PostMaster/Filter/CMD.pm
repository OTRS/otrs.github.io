# --
# Kernel/System/PostMaster/Filter/CMD.pm - sub part of PostMaster.pm
# Copyright (C) 2001-2014 OTRS AG, http://otrs.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package Kernel::System::PostMaster::Filter::CMD;

use strict;
use warnings;

sub new {
    my ( $Type, %Param ) = @_;

    # allocate new hash for object
    my $Self = {};
    bless( $Self, $Type );

    $Self->{Debug} = $Param{Debug} || 0;

    # get needed objects
    for (qw(ConfigObject LogObject DBObject ParserObject)) {
        $Self->{$_} = $Param{$_} || die "Got no $_!";
    }

    return $Self;
}

sub Run {
    my ( $Self, %Param ) = @_;

    # get config options
    my %Config;
    my %Set;
    if ( $Param{JobConfig} && ref( $Param{JobConfig} ) eq 'HASH' ) {
        %Config = %{ $Param{JobConfig} };
        if ( $Config{Set} ) {
            %Set = %{ $Config{Set} };
        }
    }

    # check CMD config param
    if ( !$Config{CMD} ) {
        $Self->{LogObject}->Log(
            Priority => 'error',
            Message  => 'Need CMD config option in PostMaster::PreFilterModule job!',
        );
        return;
    }

    # execute prog
    my $TmpFile = $Self->{ConfigObject}->Get('TempDir') . "/PostMaster.Filter.CMD.$$";
    ## no critic
    if ( open my $Prog, '|-', "$Config{CMD} > $TmpFile" ) {
        ## use critic
        print $Prog $Self->{ParserObject}->GetPlainEmail();
        close $Prog;
    }
    if ( -s $TmpFile ) {
        open my $In, '<', $TmpFile;    ## no critic
        my $Ret = <$In>;
        close $In;

        # set new params
        for ( sort keys %Set ) {
            $Param{GetParam}->{$_} = $Set{$_};
            $Self->{LogObject}->Log(
                Priority => 'notice',
                Message =>
                    "Set param '$_' to '$Set{$_}' because of '$Ret' (Message-ID: $Param{GetParam}->{'Message-ID'}) ",
            );
        }
    }
    unlink $TmpFile;
    return 1;
}

1;
