# --
# Kernel/System/SupportDataCollector/Plugin/OTRS/ConfigSettings.pm - system data collector plugin
# Copyright (C) 2001-2014 OTRS AG, http://otrs.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package Kernel::System::SupportDataCollector::Plugin::OTRS::ConfigSettings;

use strict;
use warnings;

use base qw(Kernel::System::SupportDataCollector::PluginBase);

sub GetDisplayPath {
    return 'OTRS/Config Settings';
}

sub Run {
    my $Self = shift;

    my @Settings = qw(
        Home
        FQDN
        HttpType
        DefaultLanguage
        SystemID
        Version
        ProductName
        Organization
        Ticket::IndexModule
        Ticket::SearchIndexModule
        Ticket::StorageModule
        SendmailModule
        Frontend::RichText
    );

    for my $Setting (@Settings) {
        my $ConfigValue = $Self->{ConfigObject}->Get($Setting);

        if ( defined $ConfigValue ) {
            $Self->AddResultInformation(
                Identifier => $Setting,
                Label      => $Setting,
                Value      => $ConfigValue,
            );
        }
        else {
            $Self->AddResultProblem(
                Identifier => $Setting,
                Label      => $Setting,
                Value      => $ConfigValue,
                Message    => 'Could not determine value.',
            );
        }
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
