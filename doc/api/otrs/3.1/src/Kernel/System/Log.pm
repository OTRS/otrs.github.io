# --
# Kernel/System/Log.pm - log wapper
# Copyright (C) 2001-2014 OTRS AG, http://otrs.com/
# --
# $Id: Log.pm,v 1.67 2012-03-29 19:59:23 mh Exp $
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package Kernel::System::Log;

use strict;
use warnings;

use Kernel::System::Encode;

use vars qw($VERSION);
$VERSION = qw($Revision: 1.67 $) [1];

=head1 NAME

Kernel::System::Log - global log interface

=head1 SYNOPSIS

All log functions.

=head1 PUBLIC INTERFACE

=over 4

=cut

=item new()

create a log object

    use Kernel::Config;
    use Kernel::System::Encode;
    use Kernel::System::Log;

    my $ConfigObject = Kernel::Config->new();
    my $EncodeObject = Kernel::System::Encode->new(
        ConfigObject => $ConfigObject,
    );
    my $LogObject    = Kernel::System::Log->new(
        ConfigObject => $ConfigObject,
        EncodeObject => $EncodeObject,
        LogPrefix    => 'InstallScriptX',  # not required, but highly recommend
    );

=cut

sub new {
    my ( $Type, %Param ) = @_;

    # allocate new hash for object
    my $Self = {};
    bless( $Self, $Type );

    # get config object
    if ( !$Param{ConfigObject} ) {
        die 'Got no ConfigObject!';
    }

    # get system id
    my $SystemID = $Param{ConfigObject}->Get('SystemID');

    # get or create encode object
    $Self->{EncodeObject} = $Param{EncodeObject};
    $Self->{EncodeObject} ||= Kernel::System::Encode->new(%Param);

    # check log prefix
    $Self->{LogPrefix} = $Param{LogPrefix} || '?LogPrefix?';
    $Self->{LogPrefix} .= '-' . $SystemID;

    # load log backend
    my $GenericModule = $Param{ConfigObject}->Get('LogModule') || 'Kernel::System::Log::SysLog';
    if ( !eval "require $GenericModule" ) {
        die "Can't load log backend module $GenericModule! $@";
    }

    # create backend handle
    $Self->{Backend} = $GenericModule->new(
        %Param,
        EncodeObject => $Self->{EncodeObject},
    );

    return $Self if !eval "require IPC::SysV";

    # create the IPC options
    $Self->{IPC}     = 1;
    $Self->{IPCKey}  = '444423' . $SystemID;
    $Self->{IPCSize} = $Param{ConfigObject}->Get('LogSystemCacheSize') || 32 * 1024;

    # init session data mem
    if ( !eval { $Self->{Key} = shmget( $Self->{IPCKey}, $Self->{IPCSize}, oct(1777) ) } ) {
        $Self->{Key} = shmget( $Self->{IPCKey}, 1, oct(1777) );
        $Self->CleanUp();
        $Self->{Key} = shmget( $Self->{IPCKey}, $Self->{IPCSize}, oct(1777) );
    }

    return $Self;
}

=item Log()

log something, log priorities are 'debug', 'info', 'notice' and 'error'.

    $LogObject->Log(
        Priority => 'error',
        Message  => "Need something!",
    );

=cut

sub Log {
    my ( $Self, %Param ) = @_;

    my $Priority = $Param{Priority} || 'debug';
    my $Message  = $Param{MSG}      || $Param{Message} || '???';
    my $Caller   = $Param{Caller}   || 0;

    # returns the context of the current subroutine and sub-subroutine!
    my ( $Package1, $Filename1, $Line1, $Subroutine1 ) = caller( $Caller + 0 );
    my ( $Package2, $Filename2, $Line2, $Subroutine2 ) = caller( $Caller + 1 );

    $Subroutine2 ||= $0;

    # log backend
    $Self->{Backend}->Log(
        Priority  => $Priority,
        Message   => $Message,
        LogPrefix => $Self->{LogPrefix},
        Module    => $Subroutine2,
        Line      => $Line1,
    );

    # if error, write it to STDERR
    if ( $Priority =~ /^error/i ) {

        my $Error
            = sprintf "ERROR: $Self->{LogPrefix} Perl: %vd OS: $^O Time: " . localtime() . "\n\n",
            $^V;

        $Error .= " Message: $Message\n\n";
        $Error .= " Traceback ($$): \n";

        COUNT:
        for ( my $Count = 0; $Count < 30; $Count++ ) {

            my ( $Package1, $Filename1, $Line1, $Subroutine1 ) = caller( $Caller + $Count );

            last COUNT if !$Line1;

            my ( $Package2, $Filename2, $Line2, $Subroutine2 ) = caller( $Caller + 1 + $Count );

            # if there is no caller module use the file name
            $Subroutine2 ||= $0;

            # print line if upper caller module exists
            my $VersionString = '';

            eval { $VersionString = $Package1->VERSION || ''; };

            if ($VersionString) {
                $VersionString = 'v' . $VersionString;
            }
            else {
                $VersionString = 'unknown version';
            }

            $Error .= "   Module: $Subroutine2 ($VersionString) Line: $Line1\n";

            last COUNT if !$Line2;
        }

        $Error .= "\n";
        print STDERR $Error;

        # store data (for the frontend)
        $Self->{error}->{Message}   = $Message;
        $Self->{error}->{Traceback} = $Error;
    }

    # remember to info and notice messages
    elsif ( lc $Priority eq 'info' || lc $Priority eq 'notice' ) {
        $Self->{ lc $Priority }->{Message} = $Message;
    }

    # write shm cache log
    if ( lc $Priority ne 'debug' && $Self->{IPC} ) {

        $Priority = lc $Priority;

        my $Data   = localtime() . ";;$Priority;;$Self->{LogPrefix};;$Message\n";
        my $String = $Self->GetLog();

        shmwrite( $Self->{Key}, $Data . $String, 0, $Self->{IPCSize} ) || die $!;
    }

    return 1;
}

=item GetLogEntry()

to get the last log info back

    my $Message = $LogObject->GetLogEntry(
        Type => 'error', # error|info|notice
        What => 'Message', # Message|Traceback
    );

=cut

sub GetLogEntry {
    my ( $Self, %Param ) = @_;

    return $Self->{ lc $Param{Type} }->{ $Param{What} } || '';
}

=item GetLog()

to get the tmp log data (from shared memory - ipc) in csv form

    my $CSVLog = $LogObject->GetLog();

=cut

sub GetLog {
    my ( $Self, %Param ) = @_;

    my $String = '';
    if ( $Self->{IPC} ) {
        shmread( $Self->{Key}, $String, 0, $Self->{IPCSize} ) || die "$!";
    }

    # encode the string
    $Self->{EncodeObject}->EncodeInput( \$String );

    return $String;
}

=item CleanUp()

to clean up tmp log data from shared memory (ipc)

    $LogObject->CleanUp();

=cut

sub CleanUp {
    my ( $Self, %Param ) = @_;

    return 1 if !$Self->{IPC};

    # remove the shm
    if ( !shmctl( $Self->{Key}, 0, 0 ) ) {
        $Self->Log(
            Priority => 'error',
            Message  => "Can't remove shm for log: $!",
        );
        return;
    }

    return 1;
}

=item Dumper()

dump a perl variable to log

    $LogObject->Dumper(@Array);

    or

    $LogObject->Dumper(%Hash);

=cut

sub Dumper {
    my ( $Self, @Data ) = @_;

    require Data::Dumper;

    # returns the context of the current subroutine and sub-subroutine!
    my ( $Package1, $Filename1, $Line1, $Subroutine1 ) = caller(0);
    my ( $Package2, $Filename2, $Line2, $Subroutine2 ) = caller(1);

    $Subroutine2 ||= $0;

    # log backend
    $Self->{Backend}->Log(
        Priority  => 'debug',
        Message   => substr( Data::Dumper::Dumper(@Data), 0, 600600600 ),
        LogPrefix => $Self->{LogPrefix},
        Module    => $Subroutine2,
        Line      => $Line1,
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

=head1 VERSION

$Revision: 1.67 $ $Date: 2012-03-29 19:59:23 $

=cut
