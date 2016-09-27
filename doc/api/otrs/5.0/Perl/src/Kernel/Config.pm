# --
# Copyright (C) 2001-2016 OTRS AG, http://otrs.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --
#  Note:
#
#  -->> Most OTRS configuration should be done via the OTRS web interface
#       and the SysConfig. Only for some configuration, such as database
#       credentials and customer data source changes, you should edit this
#       file. For changes do customer data sources you can copy the definitions
#       from Kernel/Config/Defaults.pm and paste them in this file.
#       Config.pm will not be overwritten when updating OTRS.
# --

package Kernel::Config;

use strict;
use warnings;
use utf8;

sub Load {
    my $Self = shift;

    # ---------------------------------------------------- #
    # database settings                                    #
    # ---------------------------------------------------- #

    # The database host
    $Self->{DatabaseHost} = '127.0.0.1';

    # The database name
    $Self->{Database} = 'otrs';

    # The database user
    $Self->{DatabaseUser} = 'otrs';

    # The password of database user. You also can use bin/otrs.Console.pl Maint::Database::PasswordCrypt
    # for crypted passwords
    $Self->{DatabasePw} = 'some-pass';

    # The database DSN for MySQL ==> more: "perldoc DBD::mysql"
    $Self->{DatabaseDSN} = "DBI:mysql:database=$Self->{Database};host=$Self->{DatabaseHost};";

    # The database DSN for PostgreSQL ==> more: "perldoc DBD::Pg"
    # if you want to use a local socket connection
#    $Self->{DatabaseDSN} = "DBI:Pg:dbname=$Self->{Database};";
    # if you want to use a TCP/IP connection
#    $Self->{DatabaseDSN} = "DBI:Pg:dbname=$Self->{Database};host=$Self->{DatabaseHost};";

    # The database DSN for Microsoft SQL Server - only supported if OTRS is
    # installed on Windows as well
#    $Self->{DatabaseDSN} = "DBI:ODBC:driver={SQL Server};Database=$Self->{Database};Server=$Self->{DatabaseHost},1433";

    # The database DSN for Oracle ==> more: "perldoc DBD::oracle"
#    $Self->{DatabaseDSN} = "DBI:Oracle://$Self->{DatabaseHost}:1521/$Self->{Database}";
#
#    $ENV{ORACLE_HOME}     = '/path/to/your/oracle';
#    $ENV{NLS_DATE_FORMAT} = 'YYYY-MM-DD HH24:MI:SS';
#    $ENV{NLS_LANG}        = 'AMERICAN_AMERICA.AL32UTF8';

    # ---------------------------------------------------- #
    # fs root directory
    # ---------------------------------------------------- #
    $Self->{Home} = '/opt/otrs';

    # ---------------------------------------------------- #
    # insert your own config settings "here"               #
    # config settings taken from Kernel/Config/Defaults.pm #
    # ---------------------------------------------------- #
    # $Self->{SessionUseCookie} = 0;
    # $Self->{CheckMXRecord} = 0;

    # ---------------------------------------------------- #

    # ---------------------------------------------------- #
    # data inserted by installer                           #
    # ---------------------------------------------------- #
    # $DIBI$

    # ---------------------------------------------------- #
    # ---------------------------------------------------- #
    #                                                      #
    # end of your own config options!!!                    #
    #                                                      #
    # ---------------------------------------------------- #
    # ---------------------------------------------------- #
}

# ---------------------------------------------------- #
# needed system stuff (don't edit this)                #
# ---------------------------------------------------- #

use Kernel::Config::Defaults; # import Translatable()
use base qw(Kernel::Config::Defaults);

# -----------------------------------------------------#

1;
# --
# Copyright (C) 2001-2016 OTRS AG, http://otrs.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

=head1 NAME

Kernel::Config - Provide access to the system configuration at runtime.

=head1 SYNOPSIS

    my $ConfigObject = $Kernel::OM->Get('Kernel::Config');

    my $Value = $ConfigObject->Get('My::Setting::Name');

    $ConfigObject->Set(
        Key   => 'My::Setting::Name',
        Value => 42,    # new value; set to undef to remove the setting
    );

=head1 DESCRIPTION

This object provides access to the system's configuration at runtime via
the L</Get()> and L</Set()> methods.

=head1 BASE CLASSES

Inherits from L<Kernel::Config::Defaults>.

=head1 PUBLIC INTERFACE

=head2 new()

Don't use the constructor directly, use the ObjectManager instead:

    my $ConfigObject = $Kernel::OM->Get('Kernel::Config');

=head2 Get()

Retrieves the value of a config setting.

    my $Value = $ConfigObject->Get('My::Setting::Name');

Returns the value of the setting.

=head2 Set()

Changes or deletes the value of a config setting.

    $ConfigObject->Set(
        Key   => 'My::Setting::Name',
        Value => 42,    # new value; set to undef to remove the setting
    );

=head2 ConfigChecksum()

This function returns an MD5 sum that is generated from all available
config files (F<Kernel/Config.pm>, F<Kernel/Config/Defaults.pm>, F<Kernel/Config/Files/*.(pm|xml)>
except F<ZZZAAuto.pm>) and their modification timestamps.

Whenever a file is changed, added or removed, this checksum will change.

This is used for example in the Loader to generate cache file names that change whenever
the system configuration changes.

=head1 TERMS AND CONDITIONS

This software is part of the OTRS project (L<http://otrs.org/>).

This software comes with ABSOLUTELY NO WARRANTY. For details, see
the enclosed file COPYING for license information (AGPL). If you
did not receive this file, see L<http://www.gnu.org/licenses/agpl.txt>.

=cut
