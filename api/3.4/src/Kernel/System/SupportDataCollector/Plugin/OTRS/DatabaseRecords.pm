# --
# Kernel/System/SupportDataCollector/Plugin/OTRS/DatabaseRecords.pm - system data collector plugin
# Copyright (C) 2001-2014 OTRS AG, http://otrs.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package Kernel::System::SupportDataCollector::Plugin::OTRS::DatabaseRecords;

use strict;
use warnings;

use base qw(Kernel::System::SupportDataCollector::PluginBase);

sub GetDisplayPath {
    return 'OTRS/Database Records';
}

sub Run {
    my $Self = shift;

    my @Checks = (
        {
            SQL        => "SELECT count(*) FROM ticket",
            Identifier => 'TicketCount',
            Label      => "Tickets",
        },
        {
            SQL        => "SELECT count(*) FROM ticket_history",
            Identifier => 'TicketHistoryCount',
            Label      => "Ticket History Entries",
        },
        {
            SQL        => "SELECT count(*) FROM article",
            Identifier => 'ArticleCount',
            Label      => "Articles",
        },
        {
            SQL =>
                "SELECT count(*) from article_attachment WHERE content_type NOT LIKE 'text/html%'",
            Identifier => 'AttachmentCountDBNonHTML',
            Label      => "Attachments (DB, Without HTML)",
        },
        {
            SQL        => "SELECT count(DISTINCT(customer_user_id)) FROM ticket",
            Identifier => 'DistinctTicketCustomerCount',
            Label      => "Customers With At Least One Ticket",
        },
        {
            SQL        => "SELECT count(*) FROM queue",
            Identifier => 'QueueCount',
            Label      => "Queues",
        },
        {
            SQL        => "SELECT count(*) FROM users",
            Identifier => 'AgentCount',
            Label      => "Agents",
        },
        {
            SQL        => "SELECT count(*) FROM roles",
            Identifier => 'RoleCount',
            Label      => "Roles",
        },
        {
            SQL        => "SELECT count(*) FROM groups",
            Identifier => 'GroupCount',
            Label      => "Groups",
        },
        {
            SQL        => "SELECT count(*) FROM dynamic_field",
            Identifier => 'DynamicFieldCount',
            Label      => "Dynamic Fields",
        },
        {
            SQL        => "SELECT count(*) FROM dynamic_field_value",
            Identifier => 'DynamicFieldValueCount',
            Label      => "Dynamic Field Values",
        },
        {
            SQL        => "SELECT count(*) FROM gi_webservice_config",
            Identifier => 'WebserviceCount',
            Label      => "GenericInterface Webservices",
        },
        {
            SQL        => "SELECT count(*) FROM pm_process",
            Identifier => 'ProcessCount',
            Label      => "Processes",
        },
    );

    my %Counts;

    CHECK:
    for my $Check (@Checks) {
        $Self->{DBObject}->Prepare( SQL => $Check->{SQL} );
        while ( my @Row = $Self->{DBObject}->FetchrowArray() ) {
            $Counts{ $Check->{Identifier} } = $Row[0];
        }

        if ( defined $Counts{ $Check->{Identifier} } ) {
            $Self->AddResultInformation(
                Identifier => $Check->{Identifier},
                Label      => $Check->{Label},
                Value      => $Counts{ $Check->{Identifier} },
            );
        }
        else {
            $Self->AddResultProblem(
                Identifier => $Check->{Identifier},
                Label      => $Check->{Label},
                Value      => $Counts{ $Check->{Identifier} },
                Message    => 'Could not determine value.',
            );
        }
    }

    $Self->{DBObject}->Prepare(
        SQL => "SELECT max(create_time_unix), min(create_time_unix) FROM ticket WHERE id > 1 ",
    );
    my $TicketWindowTime = 1;
    while ( my @Row = $Self->{DBObject}->FetchrowArray() ) {
        if ( $Row[0] && $Row[1] ) {
            $TicketWindowTime = ( $Row[0] - $Row[1] ) || 1;
        }

    }
    $TicketWindowTime = $TicketWindowTime / ( 60 * 60 * 24 * 30.4 );    # month in seconds
    $TicketWindowTime = 1 if $TicketWindowTime < 1;

    $Self->AddResultInformation(
        Identifier => 'TicketWindowTime',
        Label      => 'Months Between First And Last Ticket',
        Value      => sprintf( "%.02f", $TicketWindowTime ),
    );
    $Self->AddResultInformation(
        Identifier => 'TicketsPerMonth',
        Label      => 'Tickets Per Month (avg)',
        Value      => sprintf( "%.02f", $Counts{TicketCount} / $TicketWindowTime ),
    );

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
