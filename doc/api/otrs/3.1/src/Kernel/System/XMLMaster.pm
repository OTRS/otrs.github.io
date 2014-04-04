# --
# Kernel/System/XMLMaster.pm - the global XMLMaster module for OTRS
# Copyright (C) 2001-2014 OTRS AG, http://otrs.com/
# --
# $Id: XMLMaster.pm,v 1.17 2010-06-17 21:39:40 cr Exp $
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package Kernel::System::XMLMaster;

use strict;
use warnings;

use Kernel::System::XML;

use vars qw(@ISA $VERSION);

$VERSION = qw($Revision: 1.17 $) [1];

=head1 NAME

Kernel::System::XMLMaster - xml master handle

=head1 SYNOPSIS

This module is managing xml master handle.

=head1 PUBLIC INTERFACE

=over 4

=cut

=item new()

create a xml master object

    use Kernel::Config;
    use Kernel::System::Encode;
    use Kernel::System::Log;
    use Kernel::System::Main;
    use Kernel::System::Time;
    use Kernel::System::DB;
    use Kernel::System::XMLMaster;

    my $ConfigObject = Kernel::Config->new();
    my $EncodeObject = Kernel::System::Encode->new(
        ConfigObject => $ConfigObject,
    );
    my $LogObject = Kernel::System::Log->new(
        ConfigObject => $ConfigObject,
        EncodeObject => $EncodeObject,
    );
    my $MainObject = Kernel::System::Main->new(
        ConfigObject => $ConfigObject,
        EncodeObject => $EncodeObject,
        LogObject    => $LogObject,
    );
    my $TimeObject = Kernel::System::Time->new(
        ConfigObject => $ConfigObject,
        LogObject    => $LogObject,
    );
    my $DBObject = Kernel::System::DB->new(
        ConfigObject => $ConfigObject,
        EncodeObject => $EncodeObject,
        LogObject    => $LogObject,
        MainObject   => $MainObject,
    );
    my $XMLMasterObject = Kernel::System::XMLMaster->new(
        DBObject     => $DBObject,
        MainObject   => $MainObject,
        ConfigObject => $ConfigObject,
        LogObject    => $LogObject,
        TimeObject   => $TimeObject,
    );

=cut

sub new {
    my ( $Type, %Param ) = @_;

    # allocate new hash for object
    my $Self = {%Param};
    bless( $Self, $Type );

    # check needed objects
    for (qw(DBObject LogObject ConfigObject TimeObject MainObject)) {
        die "Got no $_" if !$Param{$_};
    }

    # for debug
    $Self->{Debug} = $Param{Debug} || 0;

    # create common objects
    $Self->{XMLObject} = Kernel::System::XML->new(%Param);

    return $Self;
}

=item Run()

to execute the run process

    my $XML = '<SomeXMLString>Test<SomeXMLString>';

    $XMLMasterObject->Run(
        XML => \$XML,
    );

=cut

sub Run {
    my ( $Self, %Param ) = @_;

    # check needed stuff
    for (qw(XML)) {
        if ( !defined $Param{$_} ) {
            $Self->{LogObject}->Log( Priority => 'error', Message => "Need $_ !" );
            return;
        }
    }

    my @XMLHash = $Self->{XMLObject}->XMLParse2XMLHash( String => ${ $Param{XML} } );

    # run all XMLMasterModules
    if ( ref( $Self->{ConfigObject}->Get('XMLMaster::Module') ) eq 'HASH' ) {
        my %Jobs = %{ $Self->{ConfigObject}->Get('XMLMaster::Module') };
        for my $Job ( sort keys %Jobs ) {
            if ( $Self->{MainObject}->Require( $Jobs{$Job}->{Module} ) ) {
                my $FilterObject = $Jobs{$Job}->{Module}->new(
                    ConfigObject => $Self->{ConfigObject},
                    LogObject    => $Self->{LogObject},
                    DBObject     => $Self->{DBObject},
                    TimeObject   => $Self->{TimeObject},
                    Debug        => $Self->{Debug},
                );

                # modify params
                if (
                    !$FilterObject->Run(
                        XMLHash   => \@XMLHash,
                        JobConfig => $Jobs{$Job},
                    )
                    )
                {
                    $Self->{LogObject}->Log(
                        Priority => 'error',
                        Message =>
                            "Execute Run() of XMLModule $Jobs{$Job}->{Module} not successfully!",
                    );
                }
            }
        }
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

=head1 VERSION

$Revision: 1.17 $ $Date: 2010-06-17 21:39:40 $

=cut
