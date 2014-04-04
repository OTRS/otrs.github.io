# --
# Kernel/Output/HTML/DashboardIFrame.pm
# Copyright (C) 2001-2014 OTRS AG, http://otrs.com/
# --
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package Kernel::Output::HTML::DashboardIFrame;

use strict;
use warnings;

sub new {
    my ( $Type, %Param ) = @_;

    # allocate new hash for object
    my $Self = {%Param};
    bless( $Self, $Type );

    # get needed objects
    for (
        qw(Config Name ConfigObject LogObject DBObject LayoutObject ParamObject TicketObject UserID)
        )
    {
        die "Got no $_!" if ( !$Self->{$_} );
    }

    return $Self;
}

sub Preferences {
    my ( $Self, %Param ) = @_;

    return;
}

sub Config {
    my ( $Self, %Param ) = @_;

    return (
        %{ $Self->{Config} }
    );
}

sub Run {
    my ( $Self, %Param ) = @_;

    # quote Title attribute, it will be used as name="" parameter of the iframe
    my $Title = $Self->{Config}->{Title} || '';
    $Title =~ s/\s/_/smx;

    my $Content = $Self->{LayoutObject}->Output(
        TemplateFile => 'AgentDashboardIFrame',
        Data         => {
            %{ $Self->{Config} },
            Title => $Title,
        },
    );

    return $Content;
}

1;
