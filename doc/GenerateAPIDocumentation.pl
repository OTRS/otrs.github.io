#!/usr/bin/perl -w

use strict;
use Getopt::Long;
use Pod::Usage;
use Pod::ProjectDocs;

my($out, $lib, $title, $lang, $desc, $charset, $index, $verbose, $forcegen, $except);
my $help = @ARGV == 0;

my %opt = (
    'help|?'      => \$help,
    'out|o=s'     => \$out,
    'lib|l=s@'    => \$lib,
    'except|e=s@' => \$except,
    'title|t=s'   => \$title,
    'desc|d=s'    => \$desc,
    'charset|c=s' => \$charset,
    'index!'      => \$index,
    'verbose|v'   => \$verbose,
    'forcegen!'   => \$forcegen,
    'lang=s'      => \$lang,
);

GetOptions(%opt);

pod2usage(1) if $help;

my $p = Pod::ProjectDocs->new(
    outroot  => $out,
    libroot  => $lib,
    except   => $except,
    title    => $title,
    desc     => $desc,
    charset  => $charset,
    index    => $index,
    verbose  => $verbose,
    forcegen => $forcegen,
    lang     => $lang,
);
$p->gen();

package Pod::ProjectDocs::DocManager;

no warnings 'redefine';

sub _find_files {
    my $self = shift;
    foreach my $dir ( @{ $self->config->libroot } ) {
        unless ( -e $dir && -d _ ) {
            $self->_croak(qq/$dir isn't detected or it's not a directory./);
        }
    }
    my $suffixs = $self->suffix;
    foreach my $dir ( @{ $self->config->libroot } ) {
        foreach my $suffix (@$suffixs) {
            my $wanted = sub {
                return unless $File::Find::name =~ /\.$suffix$/;
                ( my $path = $File::Find::name ) =~ s#^\\.##;
                my ( $fname, $fdir ) =
                  File::Basename::fileparse( $path, qr/\.$suffix/ );
                my $reldir = File::Spec->abs2rel( $fdir, $dir );
                $reldir ||= File::Spec->curdir;
                my $relpath = File::Spec->catdir( $reldir, $fname );
                $relpath .= ".";
                $relpath .= $suffix;
                $relpath =~ s:\\:/:g if $^O eq 'MSWin32';
                my $matched = 0;

                foreach my $regex ( @{ $self->config->except } ) {
                    if ( $relpath =~ /$regex/ ) {
                        $matched = 1;
                        last;
                    }
                }
                unless ($matched) {

# ---
# OTRS
# ---
# Ignore files which have no POD in them.
use IO::File;
my $FileHandle = IO::File->new( $File::Find::name, 'r' );
my $Content = join('', $FileHandle->getlines());
return if $Content !~ m{=head|=item|=back|=over};
# ---

                    push @{ $self->docs },
                      Pod::ProjectDocs::Doc->new(
                        config      => $self->config,
                        origin      => $path,
                        origin_root => $dir,
                        suffix      => $suffix,
                      );
                }
            };
            File::Find::find( { no_chdir => 1, wanted => $wanted }, $dir );
        }
    }

# ---
# OTRS
# ---
# Properly output Perl namespaces
for my $Doc (@{ $self->docs() }) {
    if ($Doc->suffix() eq 'pm') {
        my $Name = $Doc->name();
        $Name =~ s/-/::/xmsg;
        $Doc->name($Name);
    }
}
# ---

    $self->docs( [ sort { $a->name cmp $b->name } @{ $self->docs } ] );
}
