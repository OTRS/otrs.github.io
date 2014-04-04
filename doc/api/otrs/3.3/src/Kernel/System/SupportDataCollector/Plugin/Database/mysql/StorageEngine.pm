# --
# Kernel/System/SupportDataCollector/Plugin/Database/mysql/StorageEngine.pm - system data collector plugin
# Copyright (C) 2001-2014 OTRS AG, http://otrs.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package Kernel::System::SupportDataCollector::Plugin::Database::mysql::StorageEngine;

use strict;
use warnings;

use base qw(Kernel::System::SupportDataCollector::PluginBase);

sub GetDisplayPath {
    return 'Database';
}

sub Run {
    my $Self = shift;

    if ( $Self->{DBObject}->GetDatabaseFunction('Type') ne 'mysql' ) {
        return $Self->GetResults();
    }

    my $DefaultStorageEngine;

    $Self->{DBObject}->Prepare( SQL => "show variables like 'storage_engine'" );
    while ( my @Row = $Self->{DBObject}->FetchrowArray() ) {
        $DefaultStorageEngine = $Row[1];
        $Self->AddResultOk(
            Identifier => 'DefaultStorageEngine',
            Label      => 'Default Storage Engine',
            Value      => $DefaultStorageEngine,
        );
    }

    $Self->{DBObject}->Prepare(
        SQL  => "show table status where engine != ?",
        Bind => [ \$DefaultStorageEngine ],
    );
    my @TablesWithDifferentStorageEngine;
    while ( my @Row = $Self->{DBObject}->FetchrowArray() ) {
        push @TablesWithDifferentStorageEngine, $Row[0];
    }

    if (@TablesWithDifferentStorageEngine) {
        $Self->AddResultProblem(
            Identifier => 'TablesWithDifferentStorageEngine',
            Label      => 'Table Storage Engine',
            Value      => join( ', ', @TablesWithDifferentStorageEngine ),
            Message => 'Tables with a different storage engine than the default engine were found.'
        );
    }
    else {
        $Self->AddResultOk(
            Identifier => 'TablesWithDifferentStorageEngine',
            Label      => 'Table Storage Engine',
            Value      => '',
        );
    }

    return $Self->GetResults();
}

=back

=head1 TERMS AND CONDITIONS

This software is part of the OTRS project (L<http://otrs.org/>).

This software comes with ABSOLUTELY NO WARRANTY. For details, see
the enclosed file COPYING for license information (AGPL). If you
did not receive this file, see L<http://www.gnu.org/licenses/agpl.txt>.

=cut

1;
