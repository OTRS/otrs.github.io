# --
# Kernel/System/DynamicField/Backend/BackendCommon.pm - Dynamic field backend functions
# Copyright (C) 2001-2014 OTRS AG, http://otrs.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package Kernel::System::DynamicField::Backend::BackendCommon;

use strict;
use warnings;

use Kernel::System::VariableCheck qw(:all);

use vars qw(@ISA);

=head1 NAME

Kernel::System::DynamicField::Backend::BackendCommon - common fields backend functions

=head1 SYNOPSIS

=head1 PUBLIC INTERFACE

=over 4

=cut

=item new()

create an object

    use Kernel::Config;
    use Kernel::System::Encode;
    use Kernel::System::Log;
    use Kernel::System::Main;
    use Kernel::System::DynamicField::Backend::BackendCommon;

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
    );
    my $BackendCommonObject = Kernel::System::DynamicField::Backend::BackendCommon->new(
        LogObject          => $LogObject,
        MainObject         => $MainObject,
    );

=cut

sub new {
    my ( $Type, %Param ) = @_;

    my $Self = {};
    bless( $Self, $Type );

    # check needed objects
    for my $Needed (qw(MainObject LogObject)) {

        if ( !$Param{$Needed} ) {
            return {
                Success      => 0,
                ErrorMessage => "Got no $Needed!"
            };
        }

        $Self->{$Needed} = $Param{$Needed};
    }

    return $Self;
}

=item EditLabelRender()

creates the label HTML to be used in edit masks.

    my $LabelHTML = $BackendObject->EditLabelRender(
        DynamicFieldConfig => $DynamicFieldConfig,      # complete config of the DynamicField
        FieldName          => 'TheField',               # the value to be set on the 'for' attribute
        AdditionalText     => 'Between'                 # other text to be placed next to FieldName
        Mandatory          => 1,                        # 0 or 1,
    );

=cut

sub EditLabelRender {
    my ( $Self, %Param ) = @_;

    # check needed stuff
    for my $Needed (qw(DynamicFieldConfig FieldName)) {
        if ( !$Param{$Needed} ) {
            $Self->{LogObject}->Log( Priority => 'error', Message => "Need $Needed!" );
            return;
        }
    }

    # check DynamicFieldConfig (general)
    if ( !IsHashRefWithData( $Param{DynamicFieldConfig} ) ) {
        $Self->{LogObject}->Log(
            Priority => 'error',
            Message  => "The field configuration is invalid",
        );
        return;
    }

    # check DynamicFieldConfig (internally)
    for my $Needed (qw(Label)) {
        if ( !$Param{DynamicFieldConfig}->{$Needed} ) {
            $Self->{LogObject}->Log(
                Priority => 'error',
                Message  => "Need $Needed in DynamicFieldConfig!"
            );
            return;
        }
    }

    my $Name      = $Param{FieldName};
    my $LabelText = $Param{DynamicFieldConfig}->{Label};

    my $LabelID    = 'Label' . $Param{FieldName};
    my $HTMLString = '';

    if ( $Param{Mandatory} ) {

        # opening tag
        $HTMLString = <<"EOF";
<label id="$LabelID" for="$Name" class="Mandatory">
    <span class="Marker">*</span>
EOF
    }
    else {

        # opening tag
        $HTMLString = <<"EOF";
<label id="$LabelID" for="$Name">
EOF
    }

    # text
    if ( $Param{AdditionalText} ) {
        $HTMLString .= <<"EOF";
        \$Text{"$LabelText"} (\$Text{"$Param{AdditionalText}"}):
EOF

    }
    else {
        $HTMLString .= <<"EOF";
        \$Text{"$LabelText"}:
EOF
    }

    # closing tag
    $HTMLString .= <<"EOF";
</label>
EOF

    return $HTMLString;
}

1;

=back

=head1 TERMS AND CONDITIONS

This software is part of the OTRS project (L<http://otrs.org/>).

This software comes with ABSOLUTELY NO WARRANTY. For details, see
the enclosed file COPYING for license information (AGPL). If you
did not receive this file, see L<http://www.gnu.org/licenses/agpl.txt>.

=cut
