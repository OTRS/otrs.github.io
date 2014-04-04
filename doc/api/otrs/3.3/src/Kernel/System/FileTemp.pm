# --
# Kernel/System/FileTemp.pm - tmp files
# Copyright (C) 2001-2014 OTRS AG, http://otrs.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package Kernel::System::FileTemp;

use strict;
use warnings;

use File::Temp qw( tempfile tempdir );

=head1 NAME

Kernel::System::Temp - tmp files

=head1 SYNOPSIS

This module is managing tmp files.

=head1 PUBLIC INTERFACE

=over 4

=cut

=item new()

create a tmp file object

    use Kernel::Config;
    use Kernel::System::FileTemp;

    my $ConfigObject = Kernel::Config->new();

    my $TempObject = Kernel::System::FileTemp->new(
        ConfigObject => $ConfigObject,
    );

=cut

sub new {
    my ( $Type, %Param ) = @_;

    # allocate new hash for object
    my $Self = {};
    bless( $Self, $Type );

    # check needed objects
    for my $Object (qw(ConfigObject)) {
        $Self->{$Object} = $Param{$Object} || die "Got no $Object!";
    }

    # set global variables
    $Self->{TempDir}        = $Self->{ConfigObject}->Get('TempDir');
    $Self->{FileList}       = [];
    $Self->{FileHandleList} = [];

    return $Self;
}

=item TempFile()

returns a file handle and the file name

    my ($fh, $Filename) = $TempObject->TempFile();

=cut

sub TempFile {
    my $Self = shift;

    my ( $FH, $Filename ) = tempfile(
        DIR    => $Self->{TempDir},
        SUFFIX => '.tmp',
        UNLINK => 1,
    );

    # remember created tmp files and handles
    push @{ $Self->{FileList} },       $Filename;
    push @{ $Self->{FileHandleList} }, $FH;

    return ( $FH, $Filename );
}

sub DESTROY {
    my ( $Self, %Param ) = @_;

    # close all existing file handles
    FILEHANDLE:
    for my $FileHandle ( @{ $Self->{FileHandleList} } ) {
        next FILEHANDLE if !$FileHandle;
        close $FileHandle;
    }

    # remove all existing tmp files
    FILE:
    for my $File ( @{ $Self->{FileList} } ) {
        next FILE if !-f $File;
        unlink $File;
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
