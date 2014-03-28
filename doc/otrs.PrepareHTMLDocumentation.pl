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

my @NavigationConfig = (
    {
        Name => 'Admin Manual',
        Path => 'admin',
        Versions => [
            {
                Version => '3.3',
                Name    => 'OTRS 3.3',
                Languages => ['en'],
            },
        ],
    },
);

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
        return if ($File::Find::name eq "$RealBin/index.html");
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

    my $HTMLContent = ReadFile(File => $Param{File});

    # Get original title, description and raw body content
    my ($Title) = $HTMLContent =~ m{<title>(.*)</title>}xms;
    $Title ||= '';

    my ($Description) = $HTMLContent =~ m{<meta\s+name="description"\scontent="(.*?)"}xms;
    $Description ||= '';

    # Original body might be in a already replaced file, marked with comments
    my ($OriginalBodyContent) =
        $HTMLContent =~ m{<!--[ ]Start[ ]OriginalBodyContent[ ]-->\n(.*?)\n<!--[ ]End[ ]OriginalBodyContent[ ]-->}xms;
    if (!$OriginalBodyContent) {
        # Unprocessed file, use real body
        ($OriginalBodyContent) = $HTMLContent =~ m{<body[^>]*>(.*?)</body>}xms;
    }

    my $Navigation = GenerateNavigation();

    my $FinalContent =<<EOF;
<!doctype html>
<html lang="de">
<head>
    <meta charset="UTF-8" />
    <title>$Title</title>
    <meta name="description" content="$Description" />
    <meta name="author" content="libertello GmbH" />
    <meta http-equiv="X-UA-Compatible" content="edge">
    <link rel="stylesheet" href="../../../../doku.reset.css"/>
    <link rel="stylesheet" href="../../../../doku.design.css"/>
</head>
<body>
<div class="doconline">
    <div id="wrapper">
        <a id="logo" title="OTRS Documentation" href="http://doc.otrs.org/">Documentation</a>
        <div id="content">
            <div id="marginalia_wrapper">
                $Navigation
                <form action="http://www.google.com/cse" id="search">
                    <div>
                        <input type="hidden" value="016655303084217971695:zg-eih1lc60" name="cx">
                        <input type="hidden" value="UTF-8" name="ie">
                        <input type="text" name="q" value="" class="searchinput">
                        <input type="submit" name="sa" value="Search" class="searchsubmit">
                    </div>
                </form>
            </div>
            <div id="doc">
<!-- Start OriginalBodyContent -->
$OriginalBodyContent
<!-- End OriginalBodyContent -->
            </div>
            <div id="footer">
                <p class="copyright">
            Copyright &copy;  2001-2012 OTRS Team, All Rights Reserved.
            - <a href="http://www.otrs.com/en/corporate-navigation/imprint/">Imprint</a>
                </p>
            </div>
        </div>
    </div>
</div>
<script src="http://code.jquery.com/jquery-1.11.0.min.js"></script>
<script src="../../../../doku.js"></script>
</body>
EOF

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

sub GenerateNavigation {

    my $Navigation = '<ul id="marginalia">';
    for my $Category (@NavigationConfig) {
        $Navigation .= '<li><a href="#">' . $Category->{Name} . '</a><ul>';

        for my $Version (@{ $Category->{Versions} || []}) {

            $Navigation .= '<li><a href="#">' . $Version->{Name} . '</a><ul>';

            for my $Language (@{ $Version->{Languages} || []}) {
                $Navigation .= '<li><a href="#">' . $Language . '</a><ul>';
                $Navigation .= qq{<li><a href="../../../../$Category->{Path}/$Version->{Version}/$Language/html/index.html">HTML</a></li>};
                $Navigation .= qq{<li><a href="http://ftp.otrs.org/pub/otrs/doc/doc-$Category->{Path}/$Version->{Version}/$Language/pdf/otrs_$Category->{Path}_book.pdf">PDF</a></li>};
                $Navigation .= '</ul></li>';
            }

            $Navigation .= '</ul></li>';
        }

        $Navigation .= '</ul></li>';

    }
    $Navigation .= '</ul>';


    return $Navigation;
}

Run();
