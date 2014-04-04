# --
# Kernel/Output/HTML/QueuePreferencesGeneric.pm
# Copyright (C) 2001-2014 OTRS AG, http://otrs.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package Kernel::Output::HTML::QueuePreferencesGeneric;

use strict;
use warnings;

sub new {
    my ( $Type, %Param ) = @_;

    # allocate new hash for object
    my $Self = {%Param};
    bless( $Self, $Type );

    # get needed objects
    for (qw(ConfigObject LogObject DBObject LayoutObject UserID ParamObject ConfigItem QueueObject))
    {
        die "Got no $_!" if ( !$Self->{$_} );
    }

    return $Self;
}

sub Param {
    my ( $Self, %Param ) = @_;

    my @Params = ();
    my $GetParam = $Self->{ParamObject}->GetParam( Param => $Self->{ConfigItem}->{PrefKey} );
    if ( !defined($GetParam) ) {
        $GetParam
            = defined( $Param{QueueData}->{ $Self->{ConfigItem}->{PrefKey} } )
            ? $Param{QueueData}->{ $Self->{ConfigItem}->{PrefKey} }
            : $Self->{ConfigItem}->{DataSelected};
    }
    push(
        @Params,
        {
            %Param,
            Name       => $Self->{ConfigItem}->{PrefKey},
            SelectedID => $GetParam,
        },
    );
    return @Params;
}

sub Run {
    my ( $Self, %Param ) = @_;

    for my $Key ( sort keys %{ $Param{GetParam} } ) {
        my @Array = @{ $Param{GetParam}->{$Key} };
        for (@Array) {

            # pref update db
            $Self->{QueueObject}->QueuePreferencesSet(
                QueueID => $Param{QueueData}->{QueueID},
                Key     => $Key,
                Value   => $_,
            );
        }
    }
    $Self->{Message} = 'Preferences updated successfully!';
    return 1;
}

sub Error {
    my ( $Self, %Param ) = @_;

    return $Self->{Error} || '';
}

sub Message {
    my ( $Self, %Param ) = @_;

    return $Self->{Message} || '';
}

1;
