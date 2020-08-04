#!/usr/bin/perl
# --
# bin/otrs.PrepareHTMLDocumentation.pl - create new translation file
# Copyright (C) 2001-2014 OTRS AG, http://otrs.com/
# --
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU AFFERO General Public License as published by
# the Free Software Foundation; either version 3 of the License, or
# any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301 USA
# or see http://www.gnu.org/licenses/agpl.txt.
# --

use strict;
use warnings;

use File::Basename;
use FindBin qw($RealBin);
use lib dirname($RealBin);

use File::Find();
use IO::File();

sub PrintUsage {
    print <<"EOF";
otrs.PrepareHTMLDocumentation.pl - generate online documentation files
Copyright (C) 2001-2020 OTRS AG, http://otrs.org/
EOF
}

sub Run {

    PrintUsage();
    my @HTMLFiles = FindHTMLFiles();

    for my $HTMLFile (@HTMLFiles) {
        ProcessHTMLFile(
            File => $HTMLFile
        );
    }
}

# Collect all HTML files to process
sub FindHTMLFiles {
    my @HTMLFiles;

    my $Wanted = sub {
        return if (!-f $File::Find::name);
        return if (substr($File::Find::name, -5) ne '.html');

        push @HTMLFiles, $File::Find::name;
    };
    File::Find::find($Wanted, $RealBin);

    return @HTMLFiles;
}

sub ProcessHTMLFile {
    my %Param = @_;

    if (!$Param{File}) {
        die "Need File.";
    }

    my $SubPath   = substr($Param{File}, length($RealBin));

    my $RedirectURL = "https://doc.otrs.com/doc/$SubPath";
    $RedirectURL =~ s{/{2,}}{/}g;

    my $HTMLContent = <<"EOF";
<!DOCTYPE html>
<html>
<head>
    <meta http-equiv="refresh" content="0;URL='$RedirectURL'" />
</head>
<body>
    <p>Please wait while you are being <a href="$RedirectURL">redirected</a>...
<body>
EOF

    WriteFile(
        File => $Param{File},
        Content => $HTMLContent,
    );

    return 1;
}

sub WriteFile {
    my %Param = @_;

    if (!$Param{File} || !$Param{Content}) {
        die "Need File and Content.";
    }

    my $FileHandle = IO::File->new( $Param{File}, 'w' );
    $FileHandle->print($Param{Content});
}

Run();
