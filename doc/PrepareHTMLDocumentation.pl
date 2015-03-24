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
otrs.PrepareHTMLDocumentation.pl - update translation files
Copyright (C) 2001-2014 OTRS AG, http://otrs.org/
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
        # ignore jsdoc generated files
        return if $File::Find::name =~ m{/JavaScript/}smx;
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
    my @Sublevels = split m{/}, $SubPath;
    my $PathToJS  = join('/', map { '..' } (1 .. (@Sublevels - 2)));
    $PathToJS ||= '.';

    my $HTMLContent = ReadFile(File => $Param{File});

    my $FinalContent = $HTMLContent;

    my $HTMLInject =<<"EOF";
<!-- otrs.github.io -->
<link href="https://netdna.bootstrapcdn.com/font-awesome/4.0.3/css/font-awesome.css" rel="stylesheet">
<link href="https://fonts.googleapis.com/css?family=Roboto" rel="stylesheet" type="text/css">
<link rel="stylesheet" href="$PathToJS/documentation.css">
<script src="https://code.jquery.com/jquery-1.11.0.min.js"></script>
<script type="text/javascript" src="$PathToJS/documentation.js"></script>
<!-- otrs.github.io -->
EOF

    if ($FinalContent !~ m{<!--[ ]otrs.github.io[ ]-->}smx) {
        # original file, inject HTML in header
        # remove pre-existing style tags first
        $FinalContent =~ s{<link\s+rel="stylesheet"[^>]+>}{}smxg;
        $FinalContent =~ s{<head>}{<head>\n$HTMLInject}smx;
    }
    else {
        # Already updated file, update injected content
        $FinalContent =~ s{<!--[ ]otrs.github.io[ ]-->.*<!--[ ]otrs.github.io[ ]-->\n}{$HTMLInject}smx;
    }

    return 1 if $FinalContent eq $HTMLContent;

    WriteFile(
        File => $Param{File},
        Content => $FinalContent,
    );

    return 1;
}

sub ReadFile {
    my %Param = @_;

    if (!$Param{File}) {
        die "Need File.";
    }

    my $FileHandle = IO::File->new( $Param{File}, 'r' );
    my @Lines = $FileHandle->getlines();
    return join('', @Lines);
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
