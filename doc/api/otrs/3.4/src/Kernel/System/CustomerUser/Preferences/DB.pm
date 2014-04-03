# --
# Kernel/System/CustomerUser/Preferences/DB.pm - some customer user functions
# Copyright (C) 2001-2014 OTRS AG, http://otrs.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package Kernel::System::CustomerUser::Preferences::DB;

use strict;
use warnings;

use Kernel::System::CacheInternal;

sub new {
    my ( $Type, %Param ) = @_;

    # allocate new hash for object
    my $Self = {};
    bless( $Self, $Type );

    # check needed objects
    for (qw(DBObject ConfigObject LogObject EncodeObject MainObject)) {
        $Self->{$_} = $Param{$_} || die "Got no $_!";
    }

    $Self->{CacheInternalObject} = Kernel::System::CacheInternal->new(
        %{$Self},
        Type => 'CustomerUserPreferencesDB',
        TTL  => 60 * 60 * 24,
    );

    # preferences table data
    $Self->{PreferencesTable} = $Self->{ConfigObject}->Get('CustomerPreferences')->{Params}->{Table}
        || 'customer_preferences';
    $Self->{PreferencesTableKey}
        = $Self->{ConfigObject}->Get('CustomerPreferences')->{Params}->{TableKey}
        || 'preferences_key';
    $Self->{PreferencesTableValue}
        = $Self->{ConfigObject}->Get('CustomerPreferences')->{Params}->{TableValue}
        || 'preferences_value';
    $Self->{PreferencesTableUserID}
        = $Self->{ConfigObject}->Get('CustomerPreferences')->{Params}->{TableUserID}
        || 'user_id';

    # set lower if database is case sensitive
    $Self->{Lower} = '';
    if ( $Self->{DBObject}->GetDatabaseFunction('CaseSensitive') ) {
        $Self->{Lower} = 'LOWER';
    }

    # create cache prefix
    $Self->{CachePrefix} = 'CustomerUserPreferencesDB'
        . $Self->{PreferencesTable}
        . $Self->{PreferencesTableKey}
        . $Self->{PreferencesTableValue}
        . $Self->{PreferencesTableUserID};

    return $Self;
}

sub SetPreferences {
    my ( $Self, %Param ) = @_;

    return if !$Param{UserID};
    return if !$Param{Key};

    my $Value = defined $Param{Value} ? $Param{Value} : '';

    # delete old data
    return if !$Self->{DBObject}->Do(
        SQL => "
            DELETE FROM $Self->{PreferencesTable}
            WHERE $Self->{PreferencesTableUserID} = ?
                AND $Self->{PreferencesTableKey} = ?",
        Bind => [ \$Param{UserID}, \$Param{Key} ],
    );

    # insert new data
    return if !$Self->{DBObject}->Do(
        SQL => "
            INSERT INTO $Self->{PreferencesTable}
            ($Self->{PreferencesTableUserID}, $Self->{PreferencesTableKey}, $Self->{PreferencesTableValue})
            VALUES (?, ?, ?)",
        Bind => [ \$Param{UserID}, \$Param{Key}, \$Value ],
    );

    # delete cache
    $Self->{CacheInternalObject}->Delete(
        Key => $Self->{CachePrefix} . $Param{UserID},
    );

    return 1;
}

=item RenamePreferences()

rename the old userid with the new userid in the preferences

returns 1 if success or undef otherwise

    my $Success = $PreferencesObject->RenamePreferences(
        NewUserID => 2,
        OldUserID => 1,
    );

=cut

sub RenamePreferences {
    my ( $Self, %Param ) = @_;

    return if !$Param{NewUserID};
    return if !$Param{OldUserID};

    # update the preferences
    return if !$Self->{DBObject}->Prepare(
        SQL => "
            UPDATE $Self->{PreferencesTable}
            SET $Self->{PreferencesTableUserID} = ?
            WHERE $Self->{PreferencesTableUserID} = ?",
        Bind => [ \$Param{NewUserID}, \$Param{OldUserID}, ],
    );

    # delete cache
    $Self->{CacheInternalObject}->Delete(
        Key => $Self->{CachePrefix} . $Param{OldUserID},
    );

    return 1;
}

sub GetPreferences {
    my ( $Self, %Param ) = @_;

    return if !$Param{UserID};

    # read cache
    my $Cache = $Self->{CacheInternalObject}->Get(
        Key => $Self->{CachePrefix} . $Param{UserID},
    );
    return %{$Cache} if $Cache;

    # get preferences
    return if !$Self->{DBObject}->Prepare(
        SQL => "
            SELECT $Self->{PreferencesTableKey}, $Self->{PreferencesTableValue}
            FROM $Self->{PreferencesTable}
            WHERE $Self->{PreferencesTableUserID} = ?",
        Bind => [ \$Param{UserID} ],
    );

    # fetch the result
    my %Data;
    while ( my @Row = $Self->{DBObject}->FetchrowArray() ) {
        $Data{ $Row[0] } = $Row[1];
    }

    # set cache
    $Self->{CacheInternalObject}->Set(
        Key   => $Self->{CachePrefix} . $Param{UserID},
        Value => \%Data,
    );

    return %Data;
}

sub SearchPreferences {
    my ( $Self, %Param ) = @_;

    my $Key   = $Param{Key}   || '';
    my $Value = $Param{Value} || '';

    my $Lower = '';
    if ( $Self->{DBObject}->GetDatabaseFunction('CaseSensitive') ) {
        $Lower = 'LOWER';
    }

    my $SQL = "
        SELECT $Self->{PreferencesTableUserID}, $Self->{PreferencesTableValue}
        FROM $Self->{PreferencesTable}
        WHERE $Self->{PreferencesTableKey} = ?";
    my @Bind = ( \$Key );

    if ($Value) {
        $SQL .= " AND $Lower($Self->{PreferencesTableValue}) LIKE $Lower(?)";
        push @Bind, \$Value;
    }

    # get preferences
    return if !$Self->{DBObject}->Prepare(
        SQL  => $SQL,
        Bind => \@Bind,
    );

    # fetch the result
    my %UserID;
    while ( my @Row = $Self->{DBObject}->FetchrowArray() ) {
        $UserID{ $Row[0] } = $Row[1];
    }

    return %UserID;
}

1;
