# --
# Kernel/Modules/AgentStats.pm - stats module
# Copyright (C) 2001-2014 OTRS AG, http://otrs.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package Kernel::Modules::AgentStats;

use strict;
use warnings;

use List::Util qw( first );

use Kernel::System::Stats;
use Kernel::System::JSON;
use Kernel::System::CSV;
use Kernel::System::PDF;

sub new {
    my ( $Type, %Param ) = @_;

    # allocate new hash for object
    my $Self = {};
    bless( $Self, $Type );

    # check needed objects
    for my $NeededData (
        qw(
        GroupObject   ParamObject  DBObject   ModuleReg  LayoutObject
        LogObject     ConfigObject UserObject MainObject TimeObject
        SessionObject UserID       Subaction  AccessRo   SessionID
        EncodeObject
        )
        )
    {
        if ( !$Param{$NeededData} ) {
            $Self->{LayoutObject}->FatalError( Message => "Got no $NeededData!" );
        }
        $Self->{$NeededData} = $Param{$NeededData};
    }

    # check necessary params
    for my $Transfer (qw( AccessRw RequestedURL)) {
        if ( $Param{$Transfer} ) {
            $Self->{$Transfer} = $Param{$Transfer};
        }
    }

    # get current frontend language
    $Self->{UserLanguage} = $Param{UserLanguage} || $Self->{ConfigObject}->Get('DefaultLanguage');

    # create necessary objects
    $Self->{JSONObject}  = Kernel::System::JSON->new( %{$Self} );
    $Self->{CSVObject}   = Kernel::System::CSV->new( %{$Self} );
    $Self->{StatsObject} = Kernel::System::Stats->new( %{$Self} );

    return $Self;
}

sub Run {
    my ( $Self, %Param ) = @_;

    my $Output = '';

    # ---------------------------------------------------------- #
    # subaction overview
    # ---------------------------------------------------------- #
    if ( $Self->{Subaction} eq 'Overview' ) {

        # permission check
        $Self->{AccessRo} || return $Self->{LayoutObject}->NoPermission( WithHeader => 'yes' );

        # Get Params
        $Param{SearchPageShown} = $Self->{ConfigObject}->Get('Stats::SearchPageShown') || 10;
        $Param{SearchLimit}     = $Self->{ConfigObject}->Get('Stats::SearchLimit')     || 100;
        $Param{OrderBy}   = $Self->{ParamObject}->GetParam( Param => 'OrderBy' )   || 'ID';
        $Param{Direction} = $Self->{ParamObject}->GetParam( Param => 'Direction' ) || 'ASC';
        $Param{StartHit} = int( $Self->{ParamObject}->GetParam( Param => 'StartHit' ) || 1 );

        # store last screen
        $Self->{SessionObject}->UpdateSessionID(
            SessionID => $Self->{SessionID},
            Key       => 'LastStatsOverview',
            Value     => $Self->{RequestedURL},
            StoreData => 1,
        );

        # get all Stats from the db
        my $Result = $Self->{StatsObject}->GetStatsList(
            AccessRw  => $Self->{AccessRw},
            OrderBy   => $Param{OrderBy},
            Direction => $Param{Direction},
        );

        my %Order2CSSSort = (
            ASC  => 'SortAscending',
            DESC => 'SortDescending',
        );

        my %InverseSorting = (
            ASC  => 'DESC',
            DESC => 'ASC',
        );

        $Param{ 'CSSSort' . $Param{OrderBy} } = $Order2CSSSort{ $Param{Direction} };
        for my $Type (qw(ID Title Object)) {
            $Param{"LinkSort$Type"}
                = ( $Param{OrderBy} eq $Type ) ? $InverseSorting{ $Param{Direction} } : 'ASC';
        }

        # build the info
        my %Frontend = $Self->{LayoutObject}->PageNavBar(
            Limit     => $Param{SearchLimit},
            StartHit  => $Param{StartHit},
            PageShown => $Param{SearchPageShown},
            AllHits   => $#{$Result} + 1,
            Action    => 'Action=AgentStats;Subaction=Overview',
            Link      => ";Direction=$Param{Direction};OrderBy=$Param{OrderBy};",
            IDPrefix  => 'AgentStatsOverview'
        );

        # list result
        my $Index = -1;
        for ( my $Z = 0; ( $Z < $Param{SearchPageShown} && $Index < $#{$Result} ); $Z++ ) {
            $Index = $Param{StartHit} + $Z - 1;
            my $StatID = $Result->[$Index];
            my $Stat   = $Self->{StatsObject}->StatsGet(
                StatID             => $StatID,
                NoObjectAttributes => 1,
            );

            # get the object name
            if ( $Stat->{StatType} eq 'static' ) {
                $Stat->{ObjectName} = $Stat->{File};
            }

            # if no object name is defined use an empty string
            $Stat->{ObjectName} ||= '';

            $Self->{LayoutObject}->Block(
                Name => 'Result',
                Data => $Stat,
            );
        }

        # build output
        $Output .= $Self->{LayoutObject}->Header( Title => 'Overview' );
        $Output .= $Self->{LayoutObject}->NavigationBar();
        $Output .= $Self->{LayoutObject}->Output(
            Data => { %Frontend, %Param },
            TemplateFile => 'AgentStatsOverview',
        );
        $Output .= $Self->{LayoutObject}->Footer();
        return $Output;
    }

    # ---------------------------------------------------------- #
    # subaction add
    # ---------------------------------------------------------- #
    elsif ( $Self->{Subaction} eq 'Add' ) {

        # permission check
        $Self->{AccessRw} || return $Self->{LayoutObject}->NoPermission( WithHeader => 'yes' );

        my $StatID = 'new';

        # redirect to edit
        return $Self->{LayoutObject}->Redirect(
            OP => "Action=AgentStats;Subaction=EditSpecification;StatID=$StatID"
        );
    }

    # ---------------------------------------------------------- #
    # subaction View
    # ---------------------------------------------------------- #
    elsif ( $Self->{Subaction} eq 'View' ) {

        # permission check
        $Self->{AccessRo} || return $Self->{LayoutObject}->NoPermission( WithHeader => 'yes' );

        # get StatID
        my $StatID = $Self->{ParamObject}->GetParam( Param => 'StatID' );
        if ( !$StatID ) {
            return $Self->{LayoutObject}->ErrorScreen( Message => 'View: Get no StatID!' );
        }

        # get message if one available
        my $Message = $Self->{ParamObject}->GetParam( Param => 'Message' );

        my $Stat = $Self->{StatsObject}->StatsGet( StatID => $StatID );

        # get the object name
        if ( $Stat->{StatType} eq 'static' ) {
            $Stat->{ObjectName} = $Stat->{File};
        }

        # if no object name is defined use an empty string
        $Stat->{ObjectName} ||= '';

        $Stat->{Description} = $Self->{LayoutObject}->Ascii2Html(
            Text           => $Stat->{Description},
            HTMLResultMode => 1,
            NewLine        => 72,
        );

        # create format select box
        my %SelectFormat;
        my $Flag    = 0;
        my $Counter = 0;
        my $Format  = $Self->{ConfigObject}->Get('Stats::Format');
        for my $UseAsValueSeries ( @{ $Stat->{UseAsValueSeries} } ) {
            if ( $UseAsValueSeries->{Selected} ) {
                $Counter++;
            }
        }
        my $CounterII = 0;
        for my $Value ( @{ $Stat->{Format} } ) {
            if ( $Counter == 0 || $Value ne 'GD::Graph::pie' ) {
                $SelectFormat{$Value} = $Format->{$Value};
                $CounterII++;
            }
            if ( $Value =~ m{^GD::Graph\.*}x ) {
                $Flag = 1;
            }
        }
        if ( $CounterII > 1 ) {
            my %Frontend;
            $Frontend{SelectFormat} = $Self->{LayoutObject}->BuildSelection(
                Data => \%SelectFormat,
                Name => 'Format',
            );
            $Self->{LayoutObject}->Block(
                Name => 'Format',
                Data => \%Frontend,
            );
        }
        else {
            $Self->{LayoutObject}->Block(
                Name => 'FormatFixed',
                Data => {
                    Format    => $Format->{ $Stat->{Format}->[0] },
                    FormatKey => $Stat->{Format}->[0],
                },
            );
        }

        # create graphic size select box
        if ( $Stat->{GraphSize} && $Flag ) {
            my %GraphSize;
            my %Frontend;
            my $GraphSizeRef = $Self->{ConfigObject}->Get('Stats::GraphSize');
            for my $Value ( @{ $Stat->{GraphSize} } ) {
                $GraphSize{$Value} = $GraphSizeRef->{$Value};
            }
            if ( $#{ $Stat->{GraphSize} } > 0 ) {
                $Frontend{SelectGraphSize} = $Self->{LayoutObject}->BuildSelection(
                    Data        => \%GraphSize,
                    Name        => 'GraphSize',
                    Translation => 0,
                );
                $Self->{LayoutObject}->Block(
                    Name => 'Graphsize',
                    Data => \%Frontend,
                );
            }
            else {
                $Self->{LayoutObject}->Block(
                    Name => 'GraphsizeFixed',
                    Data => {
                        GraphSize    => $GraphSizeRef->{ $Stat->{GraphSize}->[0] },
                        GraphSizeKey => $Stat->{GraphSize}->[0],
                    },
                );
            }
        }

        if ( $Self->{ConfigObject}->Get('Stats::ExchangeAxis') ) {
            my $ExchangeAxis = $Self->{LayoutObject}->BuildSelection(
                Data => {
                    1 => 'Yes',
                    0 => 'No'
                },
                Name       => 'ExchangeAxis',
                SelectedID => 0,
            );

            $Self->{LayoutObject}->Block(
                Name => 'ExchangeAxis',
                Data => { ExchangeAxis => $ExchangeAxis }
            );
        }

        # get static attributes
        if ( $Stat->{StatType} eq 'static' ) {

            # load static module
            my $Params = $Self->{StatsObject}->GetParams( StatID => $StatID );
            $Self->{LayoutObject}->Block( Name => 'Static', );
            PARAMITEM:
            for my $ParamItem ( @{$Params} ) {
                next PARAMITEM if $ParamItem->{Name} eq 'GraphSize';
                $Self->{LayoutObject}->Block(
                    Name => 'ItemParam',
                    Data => {
                        Param => $ParamItem->{Frontend},
                        Name  => $ParamItem->{Name},
                        Field => $Self->{LayoutObject}->BuildSelection(
                            Data       => $ParamItem->{Data},
                            Name       => $ParamItem->{Name},
                            SelectedID => $ParamItem->{SelectedID} || '',
                            Multiple   => $ParamItem->{Multiple} || 0,
                            Size       => $ParamItem->{Size} || '',
                        ),
                    },
                );
            }
        }

        # get dynamic attributes
        elsif ( $Stat->{StatType} eq 'dynamic' ) {
            my %Name = (
                UseAsXvalue      => 'X-axis',
                UseAsValueSeries => 'Value Series',
                UseAsRestriction => 'Restrictions',
            );

            for my $Use (qw(UseAsXvalue UseAsValueSeries UseAsRestriction)) {
                my $Flag = 0;
                $Self->{LayoutObject}->Block(
                    Name => 'Dynamic',
                    Data => { Name => $Name{$Use} },
                );
                OBJECTATTRIBUTE:
                for my $ObjectAttribute ( @{ $Stat->{$Use} } ) {
                    next OBJECTATTRIBUTE if !$ObjectAttribute->{Selected};

                    my %ValueHash;
                    $Flag = 1;

                    # Select All function
                    if ( !$ObjectAttribute->{SelectedValues}[0] ) {
                        if (
                            $ObjectAttribute->{Values} && ref $ObjectAttribute->{Values} ne 'HASH'
                            )
                        {
                            $Self->{LogObject}->Log(
                                Priority => 'error',
                                Message  => 'Values needs to be a hash reference!'
                            );
                            next OBJECTATTRIBUTE;
                        }
                        my @Values = keys( %{ $ObjectAttribute->{Values} } );
                        $ObjectAttribute->{SelectedValues} = \@Values;
                    }
                    for ( @{ $ObjectAttribute->{SelectedValues} } ) {
                        if ( $ObjectAttribute->{Values} ) {
                            $ValueHash{$_} = $ObjectAttribute->{Values}{$_};
                        }
                        else {
                            $ValueHash{Value} = $_;
                        }
                    }

                    $Self->{LayoutObject}->Block(
                        Name => 'Element',
                        Data => { Name => $ObjectAttribute->{Name} },
                    );

                    # show fixed elements
                    if ( $ObjectAttribute->{Fixed} ) {
                        if ( $ObjectAttribute->{Block} eq 'Time' ) {
                            if ( $Use eq 'UseAsRestriction' ) {
                                delete $ObjectAttribute->{SelectedValues};
                            }
                            my $TimeScale = _TimeScale();
                            if ( $ObjectAttribute->{TimeStart} ) {
                                $Self->{LayoutObject}->Block(
                                    Name => 'TimePeriodFixed',
                                    Data => {
                                        TimeStart => $ObjectAttribute->{TimeStart},
                                        TimeStop  => $ObjectAttribute->{TimeStop},
                                    },
                                );
                            }
                            elsif ( $ObjectAttribute->{TimeRelativeUnit} ) {
                                $Self->{LayoutObject}->Block(
                                    Name => 'TimeRelativeFixed',
                                    Data => {
                                        TimeRelativeUnit =>
                                            $TimeScale->{ $ObjectAttribute->{TimeRelativeUnit} }
                                            {Value},
                                        TimeRelativeCount => $ObjectAttribute->{TimeRelativeCount},
                                    },
                                );
                            }
                            if ( $ObjectAttribute->{SelectedValues}[0] ) {
                                $Self->{LayoutObject}->Block(
                                    Name => 'TimeScaleFixed',
                                    Data => {
                                        Scale =>
                                            $TimeScale->{ $ObjectAttribute->{SelectedValues}[0] }
                                            {Value},
                                        Count => $ObjectAttribute->{TimeScaleCount},
                                    },
                                );
                            }
                        }
                        else {

                            # find out which sort mechanism is used
                            my @Sorted;
                            if ( $ObjectAttribute->{SortIndividual} ) {
                                @Sorted = grep { $ValueHash{$_} }
                                    @{ $ObjectAttribute->{SortIndividual} };
                            }
                            else {
                                @Sorted
                                    = sort { $ValueHash{$a} cmp $ValueHash{$b} } keys %ValueHash;
                            }

                            for (@Sorted) {
                                my $Value = $ValueHash{$_};
                                if ( $ObjectAttribute->{Translation} ) {
                                    $Value = $Self->{LayoutObject}->{LanguageObject}
                                        ->Translate( $ValueHash{$_} );
                                }
                                $Self->{LayoutObject}->Block(
                                    Name => 'Fixed',
                                    Data => {
                                        Value   => $Value,
                                        Key     => $_,
                                        Use     => $Use,
                                        Element => $ObjectAttribute->{Element},
                                    },
                                );
                            }
                        }
                    }

                    # show  unfixed elements
                    else {
                        my %BlockData;
                        $BlockData{Name}    = $ObjectAttribute->{Name};
                        $BlockData{Element} = $ObjectAttribute->{Element};
                        $BlockData{Value}   = $ObjectAttribute->{SelectedValues}->[0];

                        if ( $ObjectAttribute->{Block} eq 'MultiSelectField' ) {
                            $BlockData{SelectField} = $Self->{LayoutObject}->BuildSelection(
                                Data           => \%ValueHash,
                                Name           => $Use . $ObjectAttribute->{Element},
                                Multiple       => 1,
                                Size           => 5,
                                SelectedID     => $ObjectAttribute->{SelectedValues},
                                Translation    => $ObjectAttribute->{Translation},
                                TreeView       => $ObjectAttribute->{TreeView} || 0,
                                Sort           => $ObjectAttribute->{Sort} || undef,
                                SortIndividual => $ObjectAttribute->{SortIndividual} || undef,
                            );
                            $Self->{LayoutObject}->Block(
                                Name => 'MultiSelectField',
                                Data => \%BlockData,
                            );
                        }
                        elsif ( $ObjectAttribute->{Block} eq 'SelectField' ) {

                            $BlockData{SelectField} = $Self->{LayoutObject}->BuildSelection(
                                Data           => \%ValueHash,
                                Name           => $Use . $ObjectAttribute->{Element},
                                Translation    => $ObjectAttribute->{Translation},
                                TreeView       => $ObjectAttribute->{TreeView} || 0,
                                Sort           => $ObjectAttribute->{Sort} || undef,
                                SortIndividual => $ObjectAttribute->{SortIndividual} || undef,
                            );
                            $Self->{LayoutObject}->Block(
                                Name => 'SelectField',
                                Data => \%BlockData,
                            );
                        }

                        elsif ( $ObjectAttribute->{Block} eq 'InputField' ) {
                            $Self->{LayoutObject}->Block(
                                Name => 'InputField',
                                Data => {
                                    Key   => $Use . $ObjectAttribute->{Element},
                                    Value => $ObjectAttribute->{SelectedValues}[0],
                                },
                            );
                        }
                        elsif ( $ObjectAttribute->{Block} eq 'Time' ) {
                            $ObjectAttribute->{Element} = $Use . $ObjectAttribute->{Element};
                            my $TimeType = $Self->{ConfigObject}->Get('Stats::TimeType')
                                || 'Normal';
                            my %TimeData = _Timeoutput(
                                $Self, %{$ObjectAttribute},
                                OnlySelectedAttributes => 1
                            );
                            %BlockData = ( %BlockData, %TimeData );
                            if ( $ObjectAttribute->{TimeStart} ) {
                                $BlockData{TimeStartMax} = $ObjectAttribute->{TimeStart};
                                $BlockData{TimeStopMax}  = $ObjectAttribute->{TimeStop};
                                $Self->{LayoutObject}->Block(
                                    Name => 'TimePeriod',
                                    Data => \%BlockData,
                                );
                            }

                            elsif ( $ObjectAttribute->{TimeRelativeUnit} ) {
                                my $TimeScale = _TimeScale();
                                if ( $TimeType eq 'Extended' ) {
                                    my %TimeScaleOption;
                                    ITEM:
                                    for (
                                        sort {
                                            $TimeScale->{$a}->{Position}
                                                <=> $TimeScale->{$b}->{Position}
                                        } keys %{$TimeScale}
                                        )
                                    {
                                        $TimeScaleOption{$_} = $TimeScale->{$_}{Value};
                                        last ITEM if $ObjectAttribute->{TimeRelativeUnit} eq $_;
                                    }
                                    $BlockData{TimeRelativeUnit}
                                        = $Self->{LayoutObject}->BuildSelection(
                                        Name => $ObjectAttribute->{Element} . 'TimeRelativeUnit',
                                        Data => \%TimeScaleOption,
                                        Sort => 'IndividualKey',
                                        SelectedID     => $ObjectAttribute->{TimeRelativeUnit},
                                        SortIndividual => [
                                            'Second', 'Minute', 'Hour', 'Day',
                                            'Week', 'Month', 'Year'
                                        ],
                                        );
                                }
                                $BlockData{TimeRelativeCountMax}
                                    = $ObjectAttribute->{TimeRelativeCount};
                                $BlockData{TimeRelativeUnitMax}
                                    = $TimeScale->{ $ObjectAttribute->{TimeRelativeUnit} }{Value};

                                $Self->{LayoutObject}->Block(
                                    Name => 'TimePeriodRelative',
                                    Data => \%BlockData,
                                );
                            }

                            # build the Timescale output
                            if ( $Use ne 'UseAsRestriction' ) {
                                if ( $TimeType eq 'Normal' ) {
                                    $BlockData{TimeScaleCount} = 1;
                                    $BlockData{TimeScaleUnit}  = $BlockData{TimeSelectField};
                                }
                                elsif ( $TimeType eq 'Extended' ) {
                                    my $TimeScale = _TimeScale();
                                    my %TimeScaleOption;
                                    ITEM:
                                    for (
                                        sort {
                                            $TimeScale->{$b}->{Position}
                                                <=> $TimeScale->{$a}->{Position}
                                        } keys %{$TimeScale}
                                        )
                                    {
                                        $TimeScaleOption{$_} = $TimeScale->{$_}->{Value};
                                        last ITEM if $ObjectAttribute->{SelectedValues}[0] eq $_;
                                    }
                                    $BlockData{TimeScaleUnitMax}
                                        = $TimeScale->{ $ObjectAttribute->{SelectedValues}[0] }
                                        {Value};
                                    $BlockData{TimeScaleCountMax}
                                        = $ObjectAttribute->{TimeScaleCount};

                                    $BlockData{TimeScaleUnit}
                                        = $Self->{LayoutObject}->BuildSelection(
                                        Name           => $ObjectAttribute->{Element},
                                        Data           => \%TimeScaleOption,
                                        SelectedID     => $ObjectAttribute->{SelectedValues}[0],
                                        Sort           => 'IndividualKey',
                                        SortIndividual => [
                                            'Second', 'Minute', 'Hour', 'Day',
                                            'Week', 'Month', 'Year'
                                        ],
                                        );
                                    $Self->{LayoutObject}->Block(
                                        Name => 'TimeScaleInfo',
                                        Data => \%BlockData,
                                    );
                                }
                                if ( $ObjectAttribute->{SelectedValues} ) {
                                    $Self->{LayoutObject}->Block(
                                        Name => 'TimeScale',
                                        Data => \%BlockData,
                                    );
                                    if ( $BlockData{TimeScaleUnitMax} ) {
                                        $Self->{LayoutObject}->Block(
                                            Name => 'TimeScaleInfo',
                                            Data => \%BlockData,
                                        );
                                    }
                                }
                            }

                            # end of build timescale output
                        }
                    }
                }

                # Show this Block if no value series or restrictions are selected
                if ( !$Flag ) {
                    $Self->{LayoutObject}->Block( Name => 'NoElement', );
                }
            }
        }
        my %YesNo        = ( 0 => 'No',      1 => 'Yes' );
        my %ValidInvalid = ( 0 => 'invalid', 1 => 'valid' );
        $Stat->{SumRowValue}                = $YesNo{ $Stat->{SumRow} };
        $Stat->{SumColValue}                = $YesNo{ $Stat->{SumCol} };
        $Stat->{CacheValue}                 = $YesNo{ $Stat->{Cache} };
        $Stat->{ShowAsDashboardWidgetValue} = $YesNo{ $Stat->{ShowAsDashboardWidget} // 0 };
        $Stat->{ValidValue}                 = $ValidInvalid{ $Stat->{Valid} };

        for (qw(CreatedBy ChangedBy)) {
            $Stat->{$_} = $Self->{UserObject}->UserName( UserID => $Stat->{$_} );
        }

        # store last screen
        $Self->{SessionObject}->UpdateSessionID(
            SessionID => $Self->{SessionID},
            Key       => 'LastStatsView',
            Value     => $Self->{RequestedURL},
        );

        # show admin links
        if ( $Self->{AccessRw} ) {
            $Self->{LayoutObject}->Block(
                Name => 'AdminLinks',
                Data => $Stat,
            );
        }

        # Completeness check
        my @Notify = $Self->{StatsObject}->CompletenessCheck(
            StatData => $Stat,
            Section  => 'All'
        );

        # show the start button if the stat is valid and completeness check true
        if ( $Stat->{Valid} && !@Notify ) {
            $Self->{LayoutObject}->Block(
                Name => 'FormSubmit',
                Data => $Stat,
            );
        }

        # check if the PDF module is installed and enabled
        $Stat->{PDFUsable} = Kernel::System::PDF->new( %{$Self} ) ? 1 : 0;

        # build output
        $Output .= $Self->{LayoutObject}->Header( Title => 'View' );
        $Output .= $Self->{LayoutObject}->NavigationBar();

        # Error message if there is an invalid setting in the search mask
        # in need of better solution
        if ($Message) {
            my %ErrorMessages = (
                1 => 'The selected start time is before the allowed start time!',
                2 => 'The selected end time is later than the allowed end time!',
                3 => 'The selected time period is larger than the allowed time period!',
                4 => 'Your reporting time interval is too small, please use a larger time scale!',
            );

            $Output .= $Self->{LayoutObject}->Notify(
                Info     => $ErrorMessages{$Message},
                Priority => 'Error',
            );
        }
        $Output .= $Self->_Notify( StatData => $Stat, Section => 'All' );
        $Output .= $Self->{LayoutObject}->Output(
            Data         => $Stat,
            TemplateFile => 'AgentStatsView',
        );
        $Output .= $Self->{LayoutObject}->Footer();
        return $Output;
    }

    # ---------------------------------------------------------- #
    # show delete screen
    # ---------------------------------------------------------- #
    elsif ( $Self->{Subaction} eq 'Delete' ) {

        # permission check
        $Self->{AccessRw} || return $Self->{LayoutObject}->NoPermission( WithHeader => 'yes' );

        # get params
        for my $Key (qw(Status Yes No)) {
            $Param{$Key} = $Self->{ParamObject}->GetParam( Param => $Key );
        }

        my $StatID = $Self->{ParamObject}->GetParam( Param => 'StatID' );
        if ( !$StatID ) {
            return $Self->{LayoutObject}->ErrorScreen( Message => 'Delete: Get no StatID!' );
        }

        # delete Stat
        if ( $Param{Status} && $Param{Status} eq 'Action' ) {

            # challenge token check for write action
            $Self->{LayoutObject}->ChallengeTokenCheck();

            if ( $Param{Yes} ) {
                $Self->{StatsObject}->StatsDelete( StatID => $StatID );
            }

            # redirect to edit
            return $Self->{LayoutObject}->Redirect( OP => 'Action=AgentStats;Subaction=Overview' );
        }

        my $Stat = $Self->{StatsObject}->StatsGet( StatID => $StatID );

        # build output
        $Output .= $Self->{LayoutObject}->Header( Title => 'Delete' );
        $Output .= $Self->{LayoutObject}->NavigationBar();
        $Output .= $Self->{LayoutObject}->Output(
            TemplateFile => 'AgentStatsDelete',
            Data         => $Stat,
        );
        $Output .= $Self->{LayoutObject}->Footer();
        return $Output;
    }

    # ---------------------------------------------------------- #
    # show export screen
    # ---------------------------------------------------------- #
    elsif ( $Self->{Subaction} eq 'Export' ) {

        # permission check
        $Self->{AccessRw} || return $Self->{LayoutObject}->NoPermission( WithHeader => 'yes' );

        # get params
        my $StatID = $Self->{ParamObject}->GetParam( Param => 'StatID' );

        # check if available
        if ( !$StatID ) {
            return $Self->{LayoutObject}->ErrorScreen( Message => 'Export: Get no StatID!' );
        }
        my $ExportFile = $Self->{StatsObject}->Export( StatID => $StatID );

        return $Self->{LayoutObject}->Attachment(
            Filename    => $ExportFile->{Filename},
            Content     => $ExportFile->{Content},
            ContentType => 'text/xml',
        );

    }

    # ---------------------------------------------------------- #
    # show import screen
    # ---------------------------------------------------------- #
    elsif ( $Self->{Subaction} eq 'Import' ) {

        my $Error = 0;

        # permission check
        return $Self->{LayoutObject}->NoPermission( WithHeader => 'yes' ) if !$Self->{AccessRw};

        # get params
        $Param{Status} = $Self->{ParamObject}->GetParam( Param => 'Status' );

        # importing
        if ( $Param{Status} && $Param{Status} eq 'Action' ) {

            # challenge token check for write action
            $Self->{LayoutObject}->ChallengeTokenCheck();

            my $Uploadfile = '';
            if ( $Uploadfile = $Self->{ParamObject}->GetParam( Param => 'file_upload' ) ) {
                my %UploadStuff = $Self->{ParamObject}->GetUploadAll(
                    Param    => 'file_upload',
                    Encoding => 'Raw'
                );
                if ( $UploadStuff{Content} =~ m{<otrs_stats>}x ) {
                    my $StatID = $Self->{StatsObject}->Import( Content => $UploadStuff{Content}, );

                    if ( !$StatID ) {
                        return $Self->{LayoutObject}->ErrorScreen(
                            Message => "Import: Can't import stat!"
                        );
                    }

                    # redirect to edit
                    return $Self->{LayoutObject}->Redirect(
                        OP => "Action=AgentStats;Subaction=View;StatID=$StatID"
                    );
                }
                else {

                    # return to import: doctype not found!
                    $Error = 1;
                }
            }

            # return to import: no file selected!
            else {
                $Error = 2;
            }
        }

        # show errors
        if ( $Error == 1 ) {
            $Self->{LayoutObject}->Block( Name => 'ErrorDoctype1', );
        }
        elsif ( $Error == 2 ) {
            $Self->{LayoutObject}->Block( Name => 'ErrorDoctype2', );
        }

        # show import form
        $Output = $Self->{LayoutObject}->Header( Title => 'Import' );
        $Output .= $Self->{LayoutObject}->NavigationBar();
        $Output .= $Self->{LayoutObject}->Output( TemplateFile => 'AgentStatsImport' );
        $Output .= $Self->{LayoutObject}->Footer();
        return $Output;
    }

    # ---------------------------------------------------------- #
    # action after edit of Stats
    # ---------------------------------------------------------- #
    elsif ( $Self->{Subaction} eq 'Action' ) {

        # challenge token check for write action
        $Self->{LayoutObject}->ChallengeTokenCheck();

        # permission check
        $Self->{AccessRw} || return $Self->{LayoutObject}->NoPermission( WithHeader => 'yes' );

        # get params
        for (qw(StatID Home Back Next)) {
            $Param{$_} = $Self->{ParamObject}->GetParam( Param => $_ );
        }

        # check if needed params are available
        for (qw(StatID Home)) {
            if ( !$Param{$_} ) {
                return $Self->{LayoutObject}->ErrorScreen( Message => "EditAction: Need $_!" );
            }
        }

        if ( $Param{StatID} eq 'new' ) {

            # call the StatsAddfunction and get the new StatID
            $Param{StatID} = $Self->{StatsObject}->StatsAdd();
            if ( !$Param{StatID} ) {
                return $Self->{LayoutObject}->ErrorScreen( Message => 'Add: Get no StatID!' );
            }
        }

        # get save data
        my %Data;
        my $Subaction = '';

        # save EditSpecification
        if ( $Param{Home} eq 'EditSpecification' ) {

            # save string
            KEY:
            for my $Key (
                qw(Title Description Object File SumRow SumCol Cache ShowAsDashboardWidget StatType Valid)
                )
            {
                if ( defined( $Self->{ParamObject}->GetParam( Param => $Key ) ) ) {
                    $Data{$Key} = $Self->{ParamObject}->GetParam( Param => $Key );
                    $Data{$Key} =~ s{(^\s+|\s+$)}{}xg;
                    next KEY;
                }
                $Data{$Key} = '';
            }

            if ( $Data{StatType} eq '' ) {
                $Data{File}         = '';
                $Data{Object}       = '';
                $Data{ObjectModule} = '';
            }
            elsif ( $Data{StatType} eq 'dynamic' && $Data{Object} ) {
                $Data{File}         = '';
                $Data{ObjectModule} = 'Kernel::System::Stats::Dynamic::' . $Data{Object};
            }
            elsif ( $Data{StatType} eq 'static' && $Data{File} ) {
                $Data{Object}       = '';
                $Data{ObjectModule} = 'Kernel::System::Stats::Static::' . $Data{File};
            }

            # save array
            for my $Key (qw(Permission Format GraphSize)) {
                if ( $Self->{ParamObject}->GetArray( Param => $Key ) ) {
                    my @Array = $Self->{ParamObject}->GetArray( Param => $Key );
                    $Data{$Key} = \@Array;
                }
                else {
                    $Data{$Key} = '';
                }
            }

            # CompletenessCheck and set next subaction
            my @Notify = $Self->{StatsObject}->CompletenessCheck(
                StatData => \%Data,
                Section  => 'Specification'
            );
            if (@Notify) {
                $Subaction = 'EditSpecification';
            }
            elsif ( $Data{StatType} eq 'static' ) {
                $Subaction = 'View';
            }
            else {
                $Subaction = 'EditXaxis';
            }

        }

        # save EditXaxis
        elsif ( $Param{Home} eq 'EditXaxis' ) {
            my $Stat = $Self->{StatsObject}->StatsGet( StatID => $Param{StatID} );
            $Param{Select} = $Self->{ParamObject}->GetParam( Param => 'Select' );
            $Data{StatType} = $Stat->{StatType};

            OBJECTATTRIBUTE:
            for my $ObjectAttribute ( @{ $Stat->{UseAsXvalue} } ) {
                next OBJECTATTRIBUTE if !defined $Param{Select};
                next OBJECTATTRIBUTE if $Param{Select} ne $ObjectAttribute->{Element};

                my @Array = $Self->{ParamObject}->GetArray( Param => $Param{Select} );
                $Data{UseAsXvalue}[0]{SelectedValues} = \@Array;
                $Data{UseAsXvalue}[0]{Element}        = $Param{Select};
                $Data{UseAsXvalue}[0]{Block}          = $ObjectAttribute->{Block};
                $Data{UseAsXvalue}[0]{Selected}       = 1;

                my $Fixed = $Self->{ParamObject}->GetParam( Param => 'Fixed' . $Param{Select} );
                $Data{UseAsXvalue}[0]{Fixed} = $Fixed ? 1 : 0;

                # Check if Time was selected
                next OBJECTATTRIBUTE if $ObjectAttribute->{Block} ne 'Time';

                # This part is only needed if the block time is selected
                # perhaps a separate function is better
                my $TimeType = $Self->{ConfigObject}->Get('Stats::TimeType') || 'Normal';
                my %Time;
                my $Element = $Data{UseAsXvalue}[0]{Element};
                $Data{UseAsXvalue}[0]{TimeScaleCount}
                    = $Self->{ParamObject}->GetParam( Param => $Element . 'TimeScaleCount' )
                    || 1;
                my $TimeSelect = $Self->{ParamObject}->GetParam( Param => $Element . 'TimeSelect' )
                    || 'Absolut';

                if ( $TimeSelect eq 'Absolut' ) {
                    for my $Limit (qw(Start Stop)) {
                        for my $Unit (qw(Year Month Day Hour Minute Second)) {
                            if (
                                defined(
                                    $Self->{ParamObject}->GetParam( Param => "$Element$Limit$Unit" )
                                )
                                )
                            {
                                $Time{ $Limit . $Unit } = $Self->{ParamObject}->GetParam(
                                    Param => "$Element$Limit$Unit",
                                );
                            }
                        }
                        if ( !defined( $Time{ $Limit . 'Hour' } ) ) {
                            if ( $Limit eq 'Start' ) {
                                $Time{StartHour}   = 0;
                                $Time{StartMinute} = 0;
                                $Time{StartSecond} = 0;
                            }
                            elsif ( $Limit eq 'Stop' ) {
                                $Time{StopHour}   = 23;
                                $Time{StopMinute} = 59;
                                $Time{StopSecond} = 59;
                            }
                        }
                        elsif ( !defined( $Time{ $Limit . 'Second' } ) ) {
                            if ( $Limit eq 'Start' ) {
                                $Time{StartSecond} = 0;
                            }
                            elsif ( $Limit eq 'Stop' ) {
                                $Time{StopSecond} = 59;
                            }
                        }

                        $Data{UseAsXvalue}[0]{"Time$Limit"} = sprintf(
                            "%04d-%02d-%02d %02d:%02d:%02d",
                            $Time{ $Limit . 'Year' },
                            $Time{ $Limit . 'Month' },
                            $Time{ $Limit . 'Day' },
                            $Time{ $Limit . 'Hour' },
                            $Time{ $Limit . 'Minute' },
                            $Time{ $Limit . 'Second' },
                        );    # Second for later functions
                    }
                }
                else {
                    $Data{UseAsXvalue}[0]{TimeRelativeUnit}
                        = $Self->{ParamObject}->GetParam( Param => $Element . 'TimeRelativeUnit' );
                    $Data{UseAsXvalue}[0]{TimeRelativeCount}
                        = $Self->{ParamObject}->GetParam( Param => $Element . 'TimeRelativeCount' );
                }
            }

            # CompletenessCheck and set next subaction
            my @Notify = $Self->{StatsObject}->CompletenessCheck(
                StatData => \%Data,
                Section  => 'Xaxis'
            );
            if (@Notify) {
                $Subaction = 'EditXaxis';
            }
            elsif ( $Param{Back} ) {
                $Subaction = 'EditSpecification';
            }
            else {
                $Subaction = 'EditValueSeries';
            }
        }

        # save EditValueSeries
        elsif ( $Param{Home} eq 'EditValueSeries' ) {
            my $Stat = $Self->{StatsObject}->StatsGet( StatID => $Param{StatID} );
            my $Index = 0;
            $Data{StatType} = $Stat->{StatType};

            OBJECTATTRIBUTE:
            for my $ObjectAttribute ( @{ $Stat->{UseAsValueSeries} } ) {
                if (
                    !$Self->{ParamObject}->GetParam( Param => "Select$ObjectAttribute->{Element}" )
                    )
                {
                    next OBJECTATTRIBUTE;
                }

                my @Array = $Self->{ParamObject}->GetArray( Param => $ObjectAttribute->{Element} );
                $Data{UseAsValueSeries}[$Index]{SelectedValues} = \@Array;
                $Data{UseAsValueSeries}[$Index]{Element}        = $ObjectAttribute->{Element};
                $Data{UseAsValueSeries}[$Index]{Block}          = $ObjectAttribute->{Block};
                $Data{UseAsValueSeries}[$Index]{Selected}       = 1;

                my $FixedElement = 'Fixed' . $ObjectAttribute->{Element};
                my $Fixed = $Self->{ParamObject}->GetParam( Param => $FixedElement );
                $Data{UseAsValueSeries}[$Index]{Fixed} = $Fixed ? 1 : 0;

                # Check if Time was selected
                if ( $ObjectAttribute->{Block} eq 'Time' ) {
                    my $TimeType = $Self->{ConfigObject}->Get('Stats::TimeType') || 'Normal';
                    if ( $TimeType eq 'Normal' ) {

                        # if the admin has only one unit selected, unfixed is useless
                        if (
                            !$Data{UseAsValueSeries}[0]{SelectedValues}[1]
                            && $Data{UseAsValueSeries}[0]{SelectedValues}[0]
                            )
                        {
                            $Data{UseAsValueSeries}[0]{Fixed} = 1;
                        }
                    }

                    # for working with extended time
                    $Data{UseAsValueSeries}[$Index]{TimeScaleCount}
                        = $Self->{ParamObject}->GetParam(
                        Param => $ObjectAttribute->{Element} . 'TimeScaleCount'
                        )
                        || 1;
                }
                $Index++;

            }

            $Data{UseAsValueSeries} ||= [];

            # CompletenessCheck and set next subaction
            my @Notify = $Self->{StatsObject}->CompletenessCheck(
                StatData => \%Data,
                Section  => 'ValueSeries'
            );
            if (@Notify) {
                $Subaction = 'EditValueSeries';
            }
            elsif ( $Param{Back} ) {
                $Subaction = 'EditXaxis';
            }
            else {
                $Subaction = 'EditRestrictions';
            }
        }

        # save EditRestrictions
        elsif ( $Param{Home} eq 'EditRestrictions' ) {
            my $Stat             = $Self->{StatsObject}->StatsGet( StatID => $Param{StatID} );
            my $Index            = 0;
            my $SelectFieldError = 0;
            $Data{StatType} = $Stat->{StatType};

            OBJECTATTRIBUTE:
            for my $ObjectAttribute ( @{ $Stat->{UseAsRestriction} } ) {
                my $Element = $ObjectAttribute->{Element};
                next OBJECTATTRIBUTE
                    if !$Self->{ParamObject}->GetParam( Param => "Select$Element" );

                my @Array = $Self->{ParamObject}->GetArray( Param => $Element );
                $Data{UseAsRestriction}[$Index]{SelectedValues} = \@Array;
                $Data{UseAsRestriction}[$Index]{Element}        = $Element;
                $Data{UseAsRestriction}[$Index]{Block}          = $ObjectAttribute->{Block};
                $Data{UseAsRestriction}[$Index]{Selected}       = 1;

                my $Fixed = $Self->{ParamObject}->GetParam( Param => 'Fixed' . $Element );
                $Data{UseAsRestriction}[$Index]{Fixed} = $Fixed ? 1 : 0;

                if ( $ObjectAttribute->{Block} eq 'Time' ) {
                    my %Time;
                    my $TimeSelect
                        = $Self->{ParamObject}->GetParam( Param => $Element . 'TimeSelect' )
                        || 'Absolut';
                    if ( $TimeSelect eq 'Absolut' ) {
                        for my $Limit (qw(Start Stop)) {
                            for my $Unit (qw(Year Month Day Hour Minute Second)) {
                                if (
                                    defined(
                                        $Self->{ParamObject}->GetParam(
                                            Param => "$Element$Limit$Unit"
                                            )
                                    )
                                    )
                                {
                                    $Time{ $Limit . $Unit } = $Self->{ParamObject}->GetParam(
                                        Param => "$Element$Limit$Unit",
                                    );
                                }
                            }
                            if ( !defined( $Time{ $Limit . 'Hour' } ) ) {
                                if ( $Limit eq 'Start' ) {
                                    $Time{StartHour}   = 0;
                                    $Time{StartMinute} = 0;
                                    $Time{StartSecond} = 0;
                                }
                                elsif ( $Limit eq 'Stop' ) {
                                    $Time{StopHour}   = 23;
                                    $Time{StopMinute} = 59;
                                    $Time{StopSecond} = 59;
                                }
                            }
                            elsif ( !defined( $Time{ $Limit . 'Second' } ) ) {
                                if ( $Limit eq 'Start' ) {
                                    $Time{StartSecond} = 0;
                                }
                                elsif ( $Limit eq 'Stop' ) {
                                    $Time{StopSecond} = 59;
                                }
                            }

                            $Data{UseAsRestriction}[$Index]{"Time$Limit"} = sprintf(
                                "%04d-%02d-%02d %02d:%02d:%02d",
                                $Time{ $Limit . 'Year' },
                                $Time{ $Limit . 'Month' },
                                $Time{ $Limit . 'Day' },
                                $Time{ $Limit . 'Hour' },
                                $Time{ $Limit . 'Minute' },
                                $Time{ $Limit . 'Second' },
                            );
                        }
                    }
                    else {
                        $Data{UseAsRestriction}[$Index]{TimeRelativeUnit}
                            = $Self->{ParamObject}->GetParam(
                            Param => $Element . 'TimeRelativeUnit'
                            );
                        $Data{UseAsRestriction}[$Index]{TimeRelativeCount}
                            = $Self->{ParamObject}->GetParam(
                            Param => $Element . 'TimeRelativeCount'
                            );
                    }
                }
                $Index++;

            }

            $Data{UseAsRestriction} ||= [];

            # CompletenessCheck and set next subaction
            my @Notify = $Self->{StatsObject}->CompletenessCheck(
                StatData => \%Data,
                Section  => 'Restrictions'
            );
            if ( @Notify || $SelectFieldError ) {
                $Subaction = 'EditRestrictions';
            }
            elsif ( $Param{Back} ) {
                $Subaction = 'EditValueSeries';
            }
            else {
                $Subaction = 'View';
            }
        }
        else {
            return $Self->{LayoutObject}->ErrorScreen(
                Message => 'EditAction: Invalid declaration of the Home-Attribute!'
            );
        }

        # save xmlhash in db
        $Self->{StatsObject}->StatsUpdate(
            StatID => $Param{StatID},
            Hash   => \%Data,
        );

        # redirect
        return $Self->{LayoutObject}->Redirect(
            OP => "Action=AgentStats;Subaction=$Subaction;StatID=$Param{StatID}"
        );
    }

    # ---------------------------------------------------------- #
    # edit stats specification
    # ---------------------------------------------------------- #
    elsif ( $Self->{Subaction} eq 'EditSpecificationAJAXUpdate' ) {
        return $Self->EditSpecificationAJAXUpdate();
    }
    elsif ( $Self->{Subaction} eq 'EditSpecification' ) {
        my %Frontend;
        my $Stat = {};

        # permission check
        return $Self->{LayoutObject}->NoPermission( WithHeader => 'yes' ) if !$Self->{AccessRw};

        # get param
        if ( !( $Param{StatID} = $Self->{ParamObject}->GetParam( Param => 'StatID' ) ) ) {
            return $Self->{LayoutObject}->ErrorScreen(
                Message => 'EditSpecification: Need StatID!',
            );
        }

        # get Stat data
        if ( $Param{StatID} ne 'new' ) {
            $Stat = $Self->{StatsObject}->StatsGet( StatID => $Param{StatID} );
        }
        else {
            $Stat->{StatID}     = 'new';
            $Stat->{StatNumber} = '';
            $Stat->{Valid}      = 1;
        }

        # build the dynamic and/or static stats selection if nothing is selected
        if ( !$Stat->{StatType} ) {
            my $DynamicFiles = $Self->{StatsObject}->GetDynamicFiles();
            my $StaticFiles  = $Self->{StatsObject}->GetStaticFiles(
                OnlyUnusedFiles => 1,
            );
            my @DynamicFilesArray = keys %{$DynamicFiles};
            my @StaticFilesArray  = keys %{$StaticFiles};

            # build the Dynamic Object selection
            if (@DynamicFilesArray) {
                $Self->{LayoutObject}->Block( Name => 'Selection', );

                # need a radiobutton if dynamic and static stats available
                if ( $StaticFilesArray[0] ) {
                    $Self->{LayoutObject}->Block(
                        Name => 'RadioButton',
                        Data => {
                            Name      => 'Dynamic-Object',
                            StateType => 'dynamic',
                            }
                    );
                }

                # need no radio button if no static stats are available
                else {
                    $Self->{LayoutObject}->Block(
                        Name => 'NoRadioButton',
                        Data => {
                            Name      => 'Dynamic-Object',
                            StateType => 'dynamic',
                        },
                    );
                }

                # need a dropdown menu if more dynamic objects available
                if ( $#DynamicFilesArray > 0 ) {
                    $Frontend{SelectField} = $Self->{LayoutObject}->BuildSelection(
                        Data        => $DynamicFiles,
                        Name        => 'Object',
                        Translation => 1,
                        SelectedID =>
                            $Self->{ConfigObject}->Get('Stats::DefaultSelectedDynamicObject'),
                    );
                    $Self->{LayoutObject}->Block(
                        Name => 'SelectField',
                        Data => { SelectField => $Frontend{SelectField}, },
                    );
                }

                # show this, if only one dynamic object is available
                else {
                    $Self->{LayoutObject}->Block(
                        Name => 'Selected',
                        Data => {
                            SelectedKey  => 'Object',
                            Selected     => $DynamicFilesArray[0],
                            SelectedName => $DynamicFilesArray[0],
                        },
                    );
                }
            }

            # build the static stats selection if one or more static stats are available
            if (@StaticFilesArray) {
                $Self->{LayoutObject}->Block( Name => 'Selection', );

                # need a radiobutton if both dynamic and static stats are available
                if ( $DynamicFilesArray[0] ) {
                    $Self->{LayoutObject}->Block(
                        Name => 'RadioButton',
                        Data => {
                            Name      => 'Static-File',
                            StateType => 'static',
                            }
                    );
                }

                # if no dynamic objects are available the radio buttons are not needed
                else {
                    $Self->{LayoutObject}->Block(
                        Name => 'NoRadioButton',
                        Data => {
                            Name      => 'Static-File',
                            StateType => 'static',
                        },
                    );
                }

                # more static stats available? then make a SelectField
                if ( $#StaticFilesArray > 0 ) {
                    $Frontend{SelectField} = $Self->{LayoutObject}->BuildSelection(
                        Data        => $StaticFiles,
                        Name        => 'File',
                        Translation => 0,
                    );
                    $Self->{LayoutObject}->Block(
                        Name => 'SelectField',
                        Data => {
                            SelectField => $Frontend{SelectField},
                        },
                    );
                }

                # only one static stat available? then show that one
                else {
                    $Self->{LayoutObject}->Block(
                        Name => 'Selected',
                        Data => {
                            SelectedKey  => 'File',
                            Selected     => $StaticFilesArray[0],
                            SelectedName => $StaticFilesArray[0],
                        },
                    );
                }
            }
        }

        # show the dynamic object if it is selected
        elsif ( $Stat->{StatType} eq 'dynamic' ) {
            $Self->{LayoutObject}->Block( Name => 'Selection', );
            $Self->{LayoutObject}->Block(
                Name => 'NoRadioButton',
                Data => {
                    Name      => 'Dynamic-Object',
                    StateType => 'dynamic',
                },
            );
            $Self->{LayoutObject}->Block(
                Name => 'Selected',
                Data => {
                    SelectedKey  => 'Object',
                    Selected     => $Stat->{Object},
                    SelectedName => $Stat->{ObjectName},
                },
            );
        }

        # show the static file if it is selected
        elsif ( $Stat->{StatType} eq 'static' ) {

            $Self->{LayoutObject}->Block( Name => 'Selection', );
            $Self->{LayoutObject}->Block(
                Name => 'NoRadioButton',
                Data => {
                    Name      => 'Static-File',
                    StateType => 'static',
                },
            );
            $Self->{LayoutObject}->Block(
                Name => 'Selected',
                Data => {
                    SelectedKey  => 'File',
                    Selected     => $Stat->{File},
                    SelectedName => $Stat->{File},
                },
            );
        }

        # create selectboxes 'Cache', 'SumRow', 'SumCol', and 'Valid'
        for my $Key (qw(Cache ShowAsDashboardWidget SumRow SumCol)) {
            $Frontend{ 'Select' . $Key } = $Self->{LayoutObject}->BuildSelection(
                Data => {
                    0 => 'No',
                    1 => 'Yes'
                },
                SelectedID => $Stat->{$Key} || 0,
                Name => $Key,
            );
        }

  # If this is a new stat, assume that it does not support the dashboard widget at the start.
  #   This is corrected by a call to AJAXUpdate when the page loads and when the user makes changes.
        if ( $Stat->{StatID} eq 'new' || !$Stat->{ObjectBehaviours}->{ProvidesDashboardWidget} ) {
            $Frontend{'SelectShowAsDashboardWidget'} = $Self->{LayoutObject}->BuildSelection(
                Data => {
                    0 => 'No (not supported)',
                },
                SelectedID => 0,
                Name       => 'ShowAsDashboardWidget',
            );
        }

        $Frontend{SelectValid} = $Self->{LayoutObject}->BuildSelection(
            Data => {
                0 => 'invalid',
                1 => 'valid',
            },
            SelectedID => $Stat->{Valid},
            Name       => 'Valid',
        );

        # create multiselectboxes 'permission'
        my %Permission = (
            Data => { $Self->{GroupObject}->GroupList( Valid => 1 ) },
            Name => 'Permission',
            Class       => 'Validate_Required',
            Multiple    => 1,
            Size        => 5,
            Translation => 0,
        );
        if ( $Stat->{Permission} ) {
            $Permission{SelectedID} = $Stat->{Permission};
        }
        else {
            $Permission{SelectedValue}
                = $Self->{ConfigObject}->Get('Stats::DefaultSelectedPermissions');
        }
        $Stat->{SelectPermission} = $Self->{LayoutObject}->BuildSelection(%Permission);

        # create multiselectboxes 'format'
        my $GDAvailable;
        my $AvailableFormats = $Self->{ConfigObject}->Get('Stats::Format');

        # check availability of packages
        for my $Module ( 'GD', 'GD::Graph' ) {
            $GDAvailable = ( $Self->{MainObject}->Require($Module) ) ? 1 : 0;
        }

        # if the GD package is not installed, all the graph options will be disabled
        if ( !$GDAvailable ) {
            my @FormatData = map {
                Key          => $_,
                    Value    => $AvailableFormats->{$_},
                    Disabled => ( ( $_ =~ m/GD/gi ) ? 1 : 0 ),
            }, keys %{$AvailableFormats};

            $AvailableFormats = \@FormatData;
            $Self->{LayoutObject}->Block( Name => 'PackageUnavailableMsg' );
        }

        $Stat->{SelectFormat} = $Self->{LayoutObject}->BuildSelection(
            Data       => $AvailableFormats,
            Name       => 'Format',
            Class      => 'Validate_Required',
            Multiple   => 1,
            Size       => 5,
            SelectedID => $Stat->{Format}
                || $Self->{ConfigObject}->Get('Stats::DefaultSelectedFormat'),
        );

        # create multiselectboxes 'graphsize'
        $Stat->{SelectGraphSize} = $Self->{LayoutObject}->BuildSelection(
            Data        => $Self->{ConfigObject}->Get('Stats::GraphSize'),
            Name        => 'GraphSize',
            Multiple    => 1,
            Size        => 3,
            SelectedID  => $Stat->{GraphSize},
            Translation => 0,
            Disabled    => ( first { $_ =~ m{^GD::}smx } @{ $Stat->{GraphSize} } ) ? 0 : 1,
        );

        # presentation
        $Output = $Self->{LayoutObject}->Header(
            Area  => 'Stats',
            Title => 'Common Specification',
        );
        $Output .= $Self->{LayoutObject}->NavigationBar();
        if ( $Param{StatID} ne 'new' ) {
            $Output .= $Self->_Notify( StatData => $Stat, Section => 'Specification' );
        }
        $Output .= $Self->{LayoutObject}->Output(
            TemplateFile => 'AgentStatsEditSpecification',
            Data => { %{$Stat}, %Frontend, },
        );
        $Output .= $Self->{LayoutObject}->Footer();
        return $Output;
    }

    # ---------------------------------------------------------- #
    # edit stats X-axis
    # ---------------------------------------------------------- #
    elsif ( $Self->{Subaction} eq 'EditXaxis' ) {

        # permission check
        return $Self->{LayoutObject}->NoPermission( WithHeader => 'yes' ) if !$Self->{AccessRw};

        # get params
        if ( !( $Param{StatID} = $Self->{ParamObject}->GetParam( Param => 'StatID' ) ) ) {
            return $Self->{LayoutObject}->ErrorScreen( Message => 'EditXaxis: Need StatID!' );
        }

        my $Stat = $Self->{StatsObject}->StatsGet( StatID => $Param{StatID} );

        # if only one value is available select this value
        if ( !$Stat->{UseAsXvalue}[0]{Selected} && scalar( @{ $Stat->{UseAsXvalue} } ) == 1 ) {
            $Stat->{UseAsXvalue}[0]{Selected} = 1;
            $Stat->{UseAsXvalue}[0]{Fixed}    = 1;
        }

        for my $ObjectAttribute ( @{ $Stat->{UseAsXvalue} } ) {
            my %BlockData;
            $BlockData{Fixed}   = 'checked="checked"';
            $BlockData{Checked} = '';

            # things which should be done if this attribute is selected
            if ( $ObjectAttribute->{Selected} ) {
                $BlockData{Checked} = 'checked="checked"';
                if ( !$ObjectAttribute->{Fixed} ) {
                    $BlockData{Fixed} = '';
                }
            }

            if ( $ObjectAttribute->{Block} eq 'SelectField' ) {
                $ObjectAttribute->{Block} = 'MultiSelectField';
            }

            if ( $ObjectAttribute->{Block} eq 'MultiSelectField' ) {
                $BlockData{SelectField} = $Self->{LayoutObject}->BuildSelection(
                    Data     => $ObjectAttribute->{Values},
                    Name     => $ObjectAttribute->{Element},
                    Multiple => 1,
                    Size     => 5,
                    Class =>
                        ( $ObjectAttribute->{ShowAsTree} && $ObjectAttribute->{IsDynamicField} )
                    ? 'DynamicFieldWithTreeView'
                    : '',
                    SelectedID     => $ObjectAttribute->{SelectedValues},
                    Translation    => $ObjectAttribute->{Translation},
                    TreeView       => $ObjectAttribute->{TreeView} || 0,
                    Sort           => $ObjectAttribute->{Sort} || undef,
                    SortIndividual => $ObjectAttribute->{SortIndividual} || undef,
                    OnChange =>
                        "Core.Agent.Stats.SelectRadiobutton('$ObjectAttribute->{Element}', 'Select')",

                );

                if ( $ObjectAttribute->{ShowAsTree} && $ObjectAttribute->{IsDynamicField} ) {
                    my $TreeSelectionMessage
                        = $Self->{LayoutObject}->{LanguageObject}->Translate("Show Tree Selection");
                    $BlockData{SelectField}
                        .= ' <a href="#" title="'
                        . $TreeSelectionMessage
                        . '" class="ShowTreeSelection">'
                        . $TreeSelectionMessage . '</a>';
                }
            }

            $BlockData{Name}    = $ObjectAttribute->{Name};
            $BlockData{Element} = $ObjectAttribute->{Element};

            # show the attribute block
            $Self->{LayoutObject}->Block( Name => 'Attribute' );

            if ( $ObjectAttribute->{Block} eq 'Time' ) {
                my $TimeType = $Self->{ConfigObject}->Get('Stats::TimeType') || 'Normal';
                if ( $TimeType eq 'Time' ) {
                    $ObjectAttribute->{Block} = 'Time';
                }
                elsif ( $TimeType eq 'Extended' ) {
                    $ObjectAttribute->{Block} = 'TimeExtended';
                }

                my %TimeData = _Timeoutput( $Self, %{$ObjectAttribute} );
                %BlockData = ( %BlockData, %TimeData );
            }

            # show the input element
            $Self->{LayoutObject}->Block(
                Name => $ObjectAttribute->{Block},
                Data => \%BlockData,
            );
        }

        $Output = $Self->{LayoutObject}->Header(
            Area  => 'Stats',
            Title => 'Xaxis',
        );
        $Output .= $Self->{LayoutObject}->NavigationBar();
        $Output .= $Self->_Notify( StatData => $Stat, Section => 'Xaxis' );
        $Output .= $Self->{LayoutObject}->Output(
            TemplateFile => 'AgentStatsEditXaxis',
            Data         => $Stat,
        );
        $Output .= $Self->{LayoutObject}->Footer();
        return $Output;
    }

    # ---------------------------------------------------------- #
    # edit stats ValueSeries
    # ---------------------------------------------------------- #
    elsif ( $Self->{Subaction} eq 'EditValueSeries' ) {

        # permission check
        $Self->{AccessRw} || return $Self->{LayoutObject}->NoPermission( WithHeader => 'yes' );

        # get params
        if ( !( $Param{StatID} = $Self->{ParamObject}->GetParam( Param => 'StatID' ) ) ) {
            return $Self->{LayoutObject}->ErrorScreen(
                Message => 'EditValueSeries: Need StatID!',
            );
        }

        my $Stat = $Self->{StatsObject}->StatsGet( StatID => $Param{StatID} );

        OBJECTATTRIBUTE:
        for my $ObjectAttribute ( @{ $Stat->{UseAsValueSeries} } ) {
            my %BlockData;
            $BlockData{Fixed}   = 'checked="checked"';
            $BlockData{Checked} = '';

            if ( $ObjectAttribute->{Selected} ) {
                $BlockData{Checked} = 'checked="checked"';
                if ( !$ObjectAttribute->{Fixed} ) {
                    $BlockData{Fixed} = '';
                }
            }

            if ( $ObjectAttribute->{Block} eq 'SelectField' ) {
                $ObjectAttribute->{Block} = 'MultiSelectField';
            }

            if ( $ObjectAttribute->{Block} eq 'MultiSelectField' ) {
                $BlockData{SelectField} = $Self->{LayoutObject}->BuildSelection(
                    Data     => $ObjectAttribute->{Values},
                    Name     => $ObjectAttribute->{Element},
                    Multiple => 1,
                    Size     => 5,
                    Class =>
                        ( $ObjectAttribute->{ShowAsTree} && $ObjectAttribute->{IsDynamicField} )
                    ? 'DynamicFieldWithTreeView'
                    : '',
                    SelectedID     => $ObjectAttribute->{SelectedValues},
                    Translation    => $ObjectAttribute->{Translation},
                    TreeView       => $ObjectAttribute->{TreeView} || 0,
                    Sort           => $ObjectAttribute->{Sort} || undef,
                    SortIndividual => $ObjectAttribute->{SortIndividual} || undef,
                    OnChange       => "Core.Agent.Stats.SelectCheckbox('Select"
                        . $ObjectAttribute->{Element} . "')",
                );

                if ( $ObjectAttribute->{ShowAsTree} && $ObjectAttribute->{IsDynamicField} ) {
                    my $TreeSelectionMessage
                        = $Self->{LayoutObject}->{LanguageObject}->Translate("Show Tree Selection");
                    $BlockData{SelectField}
                        .= ' <a href="#" title="'
                        . $TreeSelectionMessage
                        . '" class="ShowTreeSelection">'
                        . $TreeSelectionMessage . '</a>';
                }
            }

            $BlockData{Name}    = $ObjectAttribute->{Name};
            $BlockData{Element} = $ObjectAttribute->{Element};

            # show the attribute block
            $Self->{LayoutObject}->Block( Name => 'Attribute' );

            if ( $ObjectAttribute->{Block} eq 'Time' ) {
                my $TimeType = $Self->{ConfigObject}->Get("Stats::TimeType") || 'Normal';
                for ( @{ $Stat->{UseAsXvalue} } ) {
                    if (
                        $_->{Selected}
                        && ( $_->{Fixed} || ( !$_->{SelectedValues}[1] && $TimeType eq 'Normal' ) )
                        && $_->{Block} eq 'Time'
                        )
                    {
                        $ObjectAttribute->{OnlySelectedAttributes} = 1;
                        if ( $_->{SelectedValues}[0] eq 'Second' ) {
                            $ObjectAttribute->{SelectedValues} = ['Minute'];
                        }
                        elsif ( $_->{SelectedValues}[0] eq 'Minute' ) {
                            $ObjectAttribute->{SelectedValues} = ['Hour'];
                        }
                        elsif ( $_->{SelectedValues}[0] eq 'Hour' ) {
                            $ObjectAttribute->{SelectedValues} = ['Day'];
                        }
                        elsif ( $_->{SelectedValues}[0] eq 'Day' ) {
                            $ObjectAttribute->{SelectedValues} = ['Month'];
                        }
                        elsif ( $_->{SelectedValues}[0] eq 'Week' ) {
                            $ObjectAttribute->{SelectedValues} = ['Week'];
                        }
                        elsif ( $_->{SelectedValues}[0] eq 'Month' ) {
                            $ObjectAttribute->{SelectedValues} = ['Year'];
                        }
                        elsif ( $_->{SelectedValues}[0] eq 'Year' ) {
                            next OBJECTATTRIBUTE;
                        }
                    }
                }

                $ObjectAttribute->{Block} = $TimeType eq 'Normal' ? 'Time' : 'TimeExtended';

                my %TimeData = _Timeoutput( $Self, %{$ObjectAttribute} );
                %BlockData = ( %BlockData, %TimeData );
            }

            # show the input element
            $Self->{LayoutObject}->Block(
                Name => $ObjectAttribute->{Block},
                Data => \%BlockData,
            );
        }

        # presentation
        $Output = $Self->{LayoutObject}->Header(
            Area  => 'Stats',
            Title => 'Value Series',
        );
        $Output .= $Self->{LayoutObject}->NavigationBar();
        $Output .= $Self->_Notify( StatData => $Stat, Section => 'ValueSeries' );
        $Output .= $Self->{LayoutObject}->Output(
            TemplateFile => 'AgentStatsEditValueSeries',
            Data         => $Stat,
        );
        $Output .= $Self->{LayoutObject}->Footer();
        return $Output;
    }

    # ---------------------------------------------------------- #
    # edit stats restrictions
    # ---------------------------------------------------------- #
    elsif ( $Self->{Subaction} eq 'EditRestrictions' ) {

        # permission check
        return $Self->{LayoutObject}->NoPermission( WithHeader => 'yes' ) if !$Self->{AccessRw};

        # get params
        if ( !( $Param{StatID} = $Self->{ParamObject}->GetParam( Param => 'StatID' ) ) ) {
            $Self->{LayoutObject}->ErrorScreen( Message => 'EditRestrictions: Need StatID!' );
            return;
        }

        my $Stat = $Self->{StatsObject}->StatsGet( StatID => $Param{StatID} );
        for my $ObjectAttribute ( @{ $Stat->{UseAsRestriction} } ) {
            my %BlockData;
            $BlockData{Fixed}   = 'checked="checked"';
            $BlockData{Checked} = '';

            if ( $ObjectAttribute->{Selected} ) {
                $BlockData{Checked} = 'checked="checked"';
                if ( !$ObjectAttribute->{Fixed} ) {
                    $BlockData{Fixed} = "";
                }
            }

            if ( $ObjectAttribute->{SelectedValues} ) {
                $BlockData{SelectedValue} = $ObjectAttribute->{SelectedValues}[0];
            }
            else {
                $BlockData{SelectedValue} = '';
                $ObjectAttribute->{SelectedValues} = undef;
            }

            if (
                $ObjectAttribute->{Block} eq 'MultiSelectField'
                || $ObjectAttribute->{Block} eq 'SelectField'
                )
            {
                $BlockData{SelectField} = $Self->{LayoutObject}->BuildSelection(
                    Data     => $ObjectAttribute->{Values},
                    Name     => $ObjectAttribute->{Element},
                    Multiple => 1,
                    Size     => 5,
                    Class =>
                        ( $ObjectAttribute->{ShowAsTree} && $ObjectAttribute->{IsDynamicField} )
                    ? 'DynamicFieldWithTreeView'
                    : '',
                    SelectedID     => $ObjectAttribute->{SelectedValues},
                    Translation    => $ObjectAttribute->{Translation},
                    TreeView       => $ObjectAttribute->{TreeView} || 0,
                    Sort           => $ObjectAttribute->{Sort} || undef,
                    SortIndividual => $ObjectAttribute->{SortIndividual} || undef,
                    OnChange       => "Core.Agent.Stats.SelectCheckbox('Select"
                        . $ObjectAttribute->{Element} . "')",
                );

                if ( $ObjectAttribute->{ShowAsTree} && $ObjectAttribute->{IsDynamicField} ) {
                    my $TreeSelectionMessage
                        = $Self->{LayoutObject}->{LanguageObject}->Translate("Show Tree Selection");
                    $BlockData{SelectField}
                        .= ' <a href="#" title="'
                        . $TreeSelectionMessage
                        . '" class="ShowTreeSelection">'
                        . $TreeSelectionMessage . '</a>';
                }
            }

            $BlockData{Element} = $ObjectAttribute->{Element};
            $BlockData{Name}    = $ObjectAttribute->{Name};

            # show the attribute block
            $Self->{LayoutObject}->Block( Name => 'Attribute', );
            if ( $ObjectAttribute->{Block} eq 'Time' ) {
                my $TimeType = $Self->{ConfigObject}->Get('Stats::TimeType') || 'Normal';
                $ObjectAttribute->{Block} = $TimeType eq 'Normal' ? 'Time' : 'TimeExtended';

                my %TimeData = _Timeoutput( $Self, %{$ObjectAttribute} );
                %BlockData = ( %BlockData, %TimeData );
            }

            # show the input element
            $Self->{LayoutObject}->Block(
                Name => $ObjectAttribute->{Block},
                Data => \%BlockData,
            );
        }

        # presentation
        $Output = $Self->{LayoutObject}->Header(
            Area  => 'Stats',
            Title => 'Restrictions',
        );
        $Output .= $Self->{LayoutObject}->NavigationBar();

        $Output .= $Self->_Notify( StatData => $Stat, Section => 'Restrictions' );
        $Output .= $Self->{LayoutObject}->Output(
            TemplateFile => 'AgentStatsEditRestrictions',
            Data         => $Stat,
        );

        $Output .= $Self->{LayoutObject}->Footer();
        return $Output;
    }

    # ---------------------------------------------------------- #
    # edit stats running
    # ---------------------------------------------------------- #
    elsif ( $Self->{Subaction} eq 'Run' ) {

        # permission check
        $Self->{AccessRo} || return $Self->{LayoutObject}->NoPermission( WithHeader => 'yes' );

        # get params
        for (qw(Format GraphSize StatID ExchangeAxis Name Cached)) {
            $Param{$_} = $Self->{ParamObject}->GetParam( Param => $_ );
        }
        my @RequiredParams = (qw(Format StatID));
        if ( $Param{Cached} ) {
            push @RequiredParams, 'Name';
        }
        for my $Required (@RequiredParams) {
            if ( !$Param{$Required} ) {
                return $Self->{LayoutObject}->ErrorScreen( Message => "Run: Get no $Required!" );
            }
        }

        if ( $Param{Format} =~ m{^GD::Graph\.*}x ) {

            # check installed packages
            for my $Module ( 'GD', 'GD::Graph' ) {
                if ( !$Self->{MainObject}->Require($Module) ) {
                    return $Self->{LayoutObject}->ErrorScreen(
                        Message => "Run: Please install $Module module!"
                    );
                }
            }
            if ( !$Param{GraphSize} ) {
                return $Self->{LayoutObject}->ErrorScreen( Message => 'Run: Need GraphSize!' );
            }
        }

        my $Stat = $Self->{StatsObject}->StatsGet( StatID => $Param{StatID} );

        # permission check
        if ( !$Self->{AccessRw} ) {
            my $UserPermission = 0;

            # get user groups
            my @Groups = $Self->{GroupObject}->GroupMemberList(
                UserID => $Self->{UserID},
                Type   => 'ro',
                Result => 'ID',
            );

            return $Self->{LayoutObject}->NoPermission( WithHeader => 'yes' ) if !$Stat->{Valid};

            MARKE:
            for my $GroupID ( @{ $Stat->{Permission} } ) {
                for my $UserGroup (@Groups) {
                    if ( $GroupID == $UserGroup ) {
                        $UserPermission = 1;
                        last MARKE;
                    }
                }
            }

            return $Self->{LayoutObject}->NoPermission( WithHeader => 'yes' ) if !$UserPermission;

        }

        # get params
        my %GetParam;

        # not sure, if this is the right way
        if ( $Stat->{StatType} eq 'static' ) {
            my $Params = $Self->{StatsObject}->GetParams( StatID => $Param{StatID} );
            PARAMITEM:
            for my $ParamItem ( @{$Params} ) {

                # param is array
                if ( $ParamItem->{Multiple} ) {
                    my @Array = $Self->{ParamObject}->GetArray( Param => $ParamItem->{Name} );
                    $GetParam{ $ParamItem->{Name} } = \@Array;
                    next PARAMITEM;
                }

                # param is string
                $GetParam{ $ParamItem->{Name} }
                    = $Self->{ParamObject}->GetParam( Param => $ParamItem->{Name} );
            }
        }
        else {
            my $TimePeriod = 0;

            for my $Use (qw(UseAsRestriction UseAsXvalue UseAsValueSeries)) {
                $Stat->{$Use} ||= [];

                my @Array   = @{ $Stat->{$Use} };
                my $Counter = 0;
                ELEMENT:
                for my $Element (@Array) {
                    next ELEMENT if !$Element->{Selected};

                    if ( !$Element->{Fixed} ) {
                        if ( $Self->{ParamObject}->GetArray( Param => $Use . $Element->{Element} ) )
                        {
                            my @SelectedValues = $Self->{ParamObject}->GetArray(
                                Param => $Use . $Element->{Element}
                            );

                            $Element->{SelectedValues} = \@SelectedValues;
                        }
                        if ( $Element->{Block} eq 'Time' ) {
                            if (
                                $Self->{ParamObject}->GetParam(
                                    Param => $Use . $Element->{Element} . 'StartYear'
                                )
                                )
                            {
                                my %Time;
                                for my $Limit (qw(Start Stop)) {
                                    for my $Unit (qw(Year Month Day Hour Minute Second)) {
                                        if (
                                            defined(
                                                $Self->{ParamObject}->GetParam(
                                                    Param => $Use
                                                        . $Element->{Element}
                                                        . "$Limit$Unit"
                                                    )
                                            )
                                            )
                                        {
                                            $Time{ $Limit . $Unit }
                                                = $Self->{ParamObject}->GetParam(
                                                Param => $Use . $Element->{Element} . "$Limit$Unit",
                                                );
                                        }
                                    }
                                    if ( !defined( $Time{ $Limit . 'Hour' } ) ) {
                                        if ( $Limit eq 'Start' ) {
                                            $Time{StartHour}   = 0;
                                            $Time{StartMinute} = 0;
                                            $Time{StartSecond} = 0;
                                        }
                                        elsif ( $Limit eq 'Stop' ) {
                                            $Time{StopHour}   = 23;
                                            $Time{StopMinute} = 59;
                                            $Time{StopSecond} = 59;
                                        }
                                    }
                                    elsif ( !defined( $Time{ $Limit . 'Second' } ) ) {
                                        if ( $Limit eq 'Start' ) {
                                            $Time{StartSecond} = 0;
                                        }
                                        elsif ( $Limit eq 'Stop' ) {
                                            $Time{StopSecond} = 59;
                                        }
                                    }
                                    $Time{"Time$Limit"} = sprintf(
                                        "%04d-%02d-%02d %02d:%02d:%02d",
                                        $Time{ $Limit . 'Year' },
                                        $Time{ $Limit . 'Month' },
                                        $Time{ $Limit . 'Day' },
                                        $Time{ $Limit . 'Hour' },
                                        $Time{ $Limit . 'Minute' },
                                        $Time{ $Limit . 'Second' },
                                    );
                                }

                                # integrate this functionality in the completenesscheck
                                if (
                                    $Self->{TimeObject}->TimeStamp2SystemTime(
                                        String => $Time{TimeStart}
                                    )
                                    < $Self->{TimeObject}->TimeStamp2SystemTime(
                                        String => $Element->{TimeStart}
                                    )
                                    )
                                {

                                    # redirect to edit
                                    return $Self->{LayoutObject}->Redirect(
                                        OP =>
                                            "Action=AgentStats;Subaction=View;StatID=$Param{StatID};Message=1",
                                    );
                                }

                                # integrate this functionality in the completenesscheck
                                if (
                                    $Self->{TimeObject}->TimeStamp2SystemTime(
                                        String => $Time{TimeStop}
                                    )
                                    > $Self->{TimeObject}->TimeStamp2SystemTime(
                                        String => $Element->{TimeStop}
                                    )
                                    )
                                {
                                    return $Self->{LayoutObject}->Redirect(
                                        OP =>
                                            "Action=AgentStats;Subaction=View;StatID=$Param{StatID};Message=2",
                                    );
                                }
                                $Element->{TimeStart} = $Time{TimeStart};
                                $Element->{TimeStop}  = $Time{TimeStop};
                                $TimePeriod
                                    = (
                                    $Self->{TimeObject}->TimeStamp2SystemTime(
                                        String => $Element->{TimeStop}
                                        )
                                    )
                                    - (
                                    $Self->{TimeObject}->TimeStamp2SystemTime(
                                        String => $Element->{TimeStart}
                                        )
                                    );
                            }
                            else {
                                my %Time;
                                my ( $s, $m, $h, $D, $M, $Y )
                                    = $Self->{TimeObject}->SystemTime2Date(
                                    SystemTime => $Self->{TimeObject}->SystemTime(),
                                    );
                                $Time{TimeRelativeUnit} = $Self->{ParamObject}->GetParam(
                                    Param => $Use . $Element->{Element} . 'TimeRelativeUnit'
                                );
                                if (
                                    $Self->{ParamObject}->GetParam(
                                        Param => $Use . $Element->{Element} . 'TimeRelativeCount'
                                    )
                                    )
                                {
                                    $Time{TimeRelativeCount} = $Self->{ParamObject}->GetParam(
                                        Param => $Use . $Element->{Element} . 'TimeRelativeCount'
                                    );
                                }

                                my $TimePeriodAdmin
                                    = $Element->{TimeRelativeCount}
                                    * $Self->_TimeInSeconds(
                                    TimeUnit => $Element->{TimeRelativeUnit}
                                    );
                                my $TimePeriodAgent = $Time{TimeRelativeCount}
                                    * $Self->_TimeInSeconds( TimeUnit => $Time{TimeRelativeUnit} );

                                # integrate this functionality in the completenesscheck
                                if ( $TimePeriodAgent > $TimePeriodAdmin ) {
                                    return $Self->{LayoutObject}->Redirect(
                                        OP =>
                                            "Action=AgentStats;Subaction=View;StatID=$Param{StatID};Message=3",
                                    );
                                }

                                $TimePeriod                   = $TimePeriodAgent;
                                $Element->{TimeRelativeCount} = $Time{TimeRelativeCount};
                                $Element->{TimeRelativeUnit}  = $Time{TimeRelativeUnit};
                            }
                            if (
                                $Self->{ParamObject}->GetParam(
                                    Param => $Use . $Element->{Element} . 'TimeScaleCount'
                                )
                                )
                            {
                                $Element->{TimeScaleCount} = $Self->{ParamObject}->GetParam(
                                    Param => $Use . $Element->{Element} . 'TimeScaleCount'
                                );
                            }
                            else {
                                $Element->{TimeScaleCount} = 1;
                            }
                        }
                    }

                    $GetParam{$Use}[$Counter] = $Element;
                    $Counter++;

                }
                if ( ref $GetParam{$Use} ne 'ARRAY' ) {
                    $GetParam{$Use} = [];
                }
            }

            # check if the timeperiod is too big or the time scale too small
            if (
                $GetParam{UseAsXvalue}[0]{Block} eq 'Time'
                && (
                    !$GetParam{UseAsValueSeries}[0]
                    || (
                        $GetParam{UseAsValueSeries}[0]
                        && $GetParam{UseAsValueSeries}[0]{Block} ne 'Time'
                    )
                )
                )
            {

                my $ScalePeriod = $Self->_TimeInSeconds(
                    TimeUnit => $GetParam{UseAsXvalue}[0]{SelectedValues}[0]
                );

                # integrate this functionality in the completenesscheck
                if (
                    $TimePeriod / ( $ScalePeriod * $GetParam{UseAsXvalue}[0]{TimeScaleCount} )
                    > ( $Self->{ConfigObject}->Get('Stats::MaxXaxisAttributes') || 1000 )
                    )
                {
                    return $Self->{LayoutObject}->Redirect(
                        OP => "Action=AgentStats;Subaction=View;StatID=$Param{StatID};Message=4",
                    );
                }
            }
        }

        # run stat...
        my @StatArray;

        # called from within the dashboard. will use the same mechanism and configuration like in
        # the dashboard stats - the (cached) result will be the same as seen in the dashboard
        if ( $Param{Cached} ) {

            # get settings for specified stats by using the dashboard configuration for the agent
            my %Preferences = $Self->{UserObject}->GetPreferences(
                UserID => $Self->{UserID},
            );
            my $PrefKeyStatsConfiguration = 'UserDashboardStatsStatsConfiguration' . $Param{Name};
            my $StatsSettings             = {};
            if ( $Preferences{$PrefKeyStatsConfiguration} ) {
                $StatsSettings = $Self->{JSONObject}->Decode(
                    Data => $Preferences{$PrefKeyStatsConfiguration},
                );
            }
            @StatArray = @{
                $Self->{StatsObject}->StatsResultCacheGet(
                    StatID       => $Param{StatID},
                    UserGetParam => $StatsSettings,
                );
                }
        }

        # called normally within the stats area - generate stats now and use provided configuraton
        else {
            @StatArray = @{
                $Self->{StatsObject}->StatsRun(
                    StatID   => $Param{StatID},
                    GetParam => \%GetParam,
                );
            };
        }

        # exchange axis if selected
        if ( $Param{ExchangeAxis} ) {
            my @NewStatArray;
            my $Title = $StatArray[0][0];

            shift(@StatArray);
            for my $Key1 ( 0 .. $#StatArray ) {
                for my $Key2 ( 0 .. $#{ $StatArray[0] } ) {
                    $NewStatArray[$Key2][$Key1] = $StatArray[$Key1][$Key2];
                }
            }
            $NewStatArray[0][0] = '';
            unshift( @NewStatArray, [$Title] );
            @StatArray = @NewStatArray;
        }

        # presentation
        my $TitleArrayRef = shift @StatArray;
        my $Title         = $TitleArrayRef->[0];
        my $HeadArrayRef  = shift @StatArray;

        # if array = empty
        if ( !@StatArray ) {
            push @StatArray, [ ' ', 0 ];
        }

        # Generate Filename
        my $Filename = $Self->{StatsObject}->StringAndTimestamp2Filename(
            String => $Stat->{Title} . ' Created',
        );

        # Translate the column and row description
        $Self->_ColumnAndRowTranslation(
            StatArrayRef => \@StatArray,
            HeadArrayRef => $HeadArrayRef,
            StatRef      => $Stat,
            ExchangeAxis => $Param{ExchangeAxis},
        );

        # csv output
        if ( $Param{Format} eq 'CSV' ) {
            my ( $s, $m, $h, $D, $M, $Y )
                = $Self->{TimeObject}->SystemTime2Date(
                SystemTime => $Self->{TimeObject}->SystemTime(),
                );
            my $Time = sprintf( "%04d-%02d-%02d %02d:%02d:%02d", $Y, $M, $D, $h, $m, $s );
            my $Output;

            # get Separator from language file
            my $UserCSVSeparator = $Self->{LayoutObject}->{LanguageObject}->{Separator};

            if ( $Self->{ConfigObject}->Get('PreferencesGroups')->{CSVSeparator}->{Active} ) {
                my %UserData = $Self->{UserObject}->GetUserData( UserID => $Self->{UserID} );
                $UserCSVSeparator = $UserData{UserCSVSeparator} if $UserData{UserCSVSeparator};
            }
            $Output .= $Self->{CSVObject}->Array2CSV(
                Head      => $HeadArrayRef,
                Data      => \@StatArray,
                Separator => $UserCSVSeparator,
            );

            return $Self->{LayoutObject}->Attachment(
                Filename    => $Filename . '.csv',
                ContentType => "text/csv",
                Content     => $Output,
            );
        }

        # pdf or html output
        elsif ( $Param{Format} eq 'Print' ) {
            $Self->{MainObject}->Require('Kernel::System::PDF');
            $Self->{PDFObject} = Kernel::System::PDF->new( %{$Self} );

            # PDF Output
            if ( $Self->{PDFObject} ) {
                my $PrintedBy = $Self->{LayoutObject}->{LanguageObject}->Translate('printed by');
                my $Page      = $Self->{LayoutObject}->{LanguageObject}->Translate('Page');
                my $Time      = $Self->{LayoutObject}->{Time};
                my $Url       = ' ';
                if ( $ENV{REQUEST_URI} ) {
                    $Url
                        = $Self->{ConfigObject}->Get('HttpType') . '://'
                        . $Self->{ConfigObject}->Get('FQDN')
                        . $ENV{REQUEST_URI};
                }

                # get maximum number of pages
                my $MaxPages = $Self->{ConfigObject}->Get('PDF::MaxPages');
                if ( !$MaxPages || $MaxPages < 1 || $MaxPages > 1000 ) {
                    $MaxPages = 100;
                }

                # create the header
                my $CellData;
                my $CounterRow  = 0;
                my $CounterHead = 0;
                for my $Content ( @{$HeadArrayRef} ) {
                    $CellData->[$CounterRow]->[$CounterHead]->{Content} = $Content;
                    $CellData->[$CounterRow]->[$CounterHead]->{Font}    = 'ProportionalBold';
                    $CounterHead++;
                }
                if ( $CounterHead > 0 ) {
                    $CounterRow++;
                }

                # create the content array
                for my $Row (@StatArray) {
                    my $CounterColumn = 0;
                    for my $Content ( @{$Row} ) {
                        $CellData->[$CounterRow]->[$CounterColumn]->{Content} = $Content;
                        $CounterColumn++;
                    }
                    $CounterRow++;
                }

                # output 'No matches found', if no content was given
                if ( !$CellData->[0]->[0] ) {
                    $CellData->[0]->[0]->{Content}
                        = $Self->{LayoutObject}->{LanguageObject}->Translate('No matches found.');
                }

                # page params
                my %User = $Self->{UserObject}->GetUserData( UserID => $Self->{UserID} );
                my %PageParam;
                $PageParam{PageOrientation} = 'landscape';
                $PageParam{MarginTop}       = 30;
                $PageParam{MarginRight}     = 40;
                $PageParam{MarginBottom}    = 40;
                $PageParam{MarginLeft}      = 40;
                $PageParam{HeaderRight}
                    = $Self->{ConfigObject}->Get('Stats::StatsHook') . $Stat->{StatNumber};
                $PageParam{FooterLeft}   = $Url;
                $PageParam{HeadlineLeft} = $Title;
                $PageParam{HeadlineRight}
                    = $PrintedBy . ' '
                    . $User{UserFirstname} . ' '
                    . $User{UserLastname} . ' ('
                    . $User{UserEmail} . ') '
                    . $Time;

                # table params
                my %TableParam;
                $TableParam{CellData}            = $CellData;
                $TableParam{Type}                = 'Cut';
                $TableParam{FontSize}            = 6;
                $TableParam{Border}              = 0;
                $TableParam{BackgroundColorEven} = '#AAAAAA';
                $TableParam{BackgroundColorOdd}  = '#DDDDDD';
                $TableParam{Padding}             = 1;
                $TableParam{PaddingTop}          = 3;
                $TableParam{PaddingBottom}       = 3;

                # create new pdf document
                $Self->{PDFObject}->DocumentNew(
                    Title  => $Self->{ConfigObject}->Get('Product') . ': ' . $Title,
                    Encode => $Self->{LayoutObject}->{UserCharset},
                );

                # start table output
                $Self->{PDFObject}->PageNew( %PageParam, FooterRight => $Page . ' 1', );
                COUNT:
                for ( 2 .. $MaxPages ) {

                    # output table (or a fragment of it)
                    %TableParam = $Self->{PDFObject}->Table( %TableParam, );

                    # stop output or output next page
                    last COUNT if $TableParam{State};

                    $Self->{PDFObject}->PageNew( %PageParam, FooterRight => $Page . ' ' . $_, );
                }

                # return the pdf document
                my $PDFString = $Self->{PDFObject}->DocumentOutput();
                return $Self->{LayoutObject}->Attachment(
                    Filename    => $Filename . '.pdf',
                    ContentType => 'application/pdf',
                    Content     => $PDFString,
                    Type        => 'attachment',
                );
            }

            # HTML Output
            else {
                $Stat->{Table} = $Self->_OutputHTMLTable(
                    Head => $HeadArrayRef,
                    Data => \@StatArray,
                );

                $Stat->{Title} = $Title;

                # presentation
                my $Output = $Self->{LayoutObject}->PrintHeader( Value => $Title );
                $Output .= $Self->{LayoutObject}->Output(
                    Data         => $Stat,
                    TemplateFile => 'AgentStatsPrint',
                );
                $Output .= $Self->{LayoutObject}->PrintFooter();
                return $Output;
            }
        }

        # graph
        elsif ( $Param{Format} =~ m{^GD::Graph\.*}x ) {

            # make graph
            my $Ext   = 'png';
            my $Graph = $Self->{StatsObject}->GenerateGraph(
                Array        => \@StatArray,
                HeadArrayRef => $HeadArrayRef,
                Title        => $Title,
                Format       => $Param{Format},
                GraphSize    => $Param{GraphSize},
            );

            # error messages if there is no graph
            if ( !$Graph ) {
                if ( $Param{Format} =~ m{^GD::Graph::pie}x ) {
                    return $Self->{LayoutObject}->ErrorScreen(
                        Message => 'You use invalid data! Perhaps there are no results.',
                    );
                }
                return $Self->{LayoutObject}->ErrorScreen(
                    Message => "Too much data, can't use it with graph!",
                );
            }

            # return image to browser
            return $Self->{LayoutObject}->Attachment(
                Filename    => $Filename . '.' . $Ext,
                ContentType => "image/$Ext",
                Content     => $Graph,
                Type        => 'attachment',             # not inline because of bug# 2757
            );
        }
    }

    # ---------------------------------------------------------- #
    # show error screen
    # ---------------------------------------------------------- #
    return $Self->{LayoutObject}->ErrorScreen( Message => 'Invalid Subaction process!' );
}

sub EditSpecificationAJAXUpdate {
    my ( $Self, %Param ) = @_;

    my %GetParam;
    $GetParam{Object}   = $Self->{ParamObject}->GetParam( Param => "Object" )   || '';
    $GetParam{File}     = $Self->{ParamObject}->GetParam( Param => "File" )     || '';
    $GetParam{StatType} = $Self->{ParamObject}->GetParam( Param => "StatType" ) || '';
    $GetParam{ShowAsDashboardWidget}
        = $Self->{ParamObject}->GetParam( Param => "ShowAsDashboardWidget" || 0 );

    my $Data = {
        0 => 'No (not supported)',
    };

    my $ObjectName;
    if ( $GetParam{StatType} eq 'static' ) {
        $ObjectName = 'Kernel::System::Stats::Static::' . $GetParam{File};
    }
    else {
        $ObjectName = 'Kernel::System::Stats::Dynamic::' . $GetParam{Object};
    }

    my $ObjectBehaviours = $Self->{StatsObject}->GetObjectBehaviours(
        ObjectModule => $ObjectName,
    );

    if ( $ObjectBehaviours->{ProvidesDashboardWidget} ) {
        $Data = {
            0 => 'No',
            1 => 'Yes'
        };
    }

    my $JSON = $Self->{LayoutObject}->BuildSelectionJSON(
        [
            {
                Name         => 'ShowAsDashboardWidget',
                Data         => $Data,
                SelectedID   => $GetParam{ShowAsDashboardWidget},
                Translation  => 1,
                PossibleNone => 0,
            },
        ],
    );
    return $Self->{LayoutObject}->Attachment(
        ContentType => 'application/json; charset=' . $Self->{LayoutObject}->{Charset},
        Content     => $JSON,
        Type        => 'inline',
        NoCache     => 1,
    );
}

=begin Internal:

=cut

sub _Notify {
    my ( $Self, %Param ) = @_;

    my $NotifyOutput = '';

    # check if need params are available
    for (qw(StatData Section)) {
        if ( !$Param{$_} ) {
            return $Self->{LayoutObject}->ErrorScreen( Message => "_Notify: Need $_!" );
        }
    }

    # CompletenessCheck
    my @Notify = $Self->{StatsObject}->CompletenessCheck(
        StatData => $Param{StatData},
        Section  => $Param{Section},
    );
    for my $Ref (@Notify) {
        $NotifyOutput .= $Self->{LayoutObject}->Notify( %{$Ref} );
    }
    return $NotifyOutput;
}

sub _Timeoutput {
    my ( $Self, %Param ) = @_;

    my %Timeoutput;

    # check if need params are available
    if ( !$Param{TimePeriodFormat} ) {
        return $Self->{LayoutObject}->ErrorScreen(
            Message => '_Timeoutput: Need TimePeriodFormat!'
        );
    }

    # get time
    my ( $Sec, $Min, $Hour, $Day, $Month, $Year )
        = $Self->{TimeObject}->SystemTime2Date( SystemTime => $Self->{TimeObject}->SystemTime(), );
    my $Element = $Param{Element};
    my %TimeConfig;

    # default time configuration
    $TimeConfig{Format}                     = $Param{TimePeriodFormat};
    $TimeConfig{ $Element . 'StartYear' }   = $Year - 1;
    $TimeConfig{ $Element . 'StartMonth' }  = 1;
    $TimeConfig{ $Element . 'StartDay' }    = 1;
    $TimeConfig{ $Element . 'StartHour' }   = 0;
    $TimeConfig{ $Element . 'StartMinute' } = 0;
    $TimeConfig{ $Element . 'StartSecond' } = 1;
    $TimeConfig{ $Element . 'StopYear' }    = $Year;
    $TimeConfig{ $Element . 'StopMonth' }   = 12;
    $TimeConfig{ $Element . 'StopDay' }     = 31;
    $TimeConfig{ $Element . 'StopHour' }    = 23;
    $TimeConfig{ $Element . 'StopMinute' }  = 59;
    $TimeConfig{ $Element . 'StopSecond' }  = 59;
    for (qw(Start Stop)) {
        $TimeConfig{Prefix} = $Element . $_;

        # time setting if available
        if (
            $Param{ 'Time' . $_ }
            && $Param{ 'Time' . $_ } =~ m{^(\d\d\d\d)-(\d\d)-(\d\d)\s(\d\d):(\d\d):(\d\d)$}xi
            )
        {
            $TimeConfig{ $Element . $_ . 'Year' }   = $1;
            $TimeConfig{ $Element . $_ . 'Month' }  = $2;
            $TimeConfig{ $Element . $_ . 'Day' }    = $3;
            $TimeConfig{ $Element . $_ . 'Hour' }   = $4;
            $TimeConfig{ $Element . $_ . 'Minute' } = $5;
            $TimeConfig{ $Element . $_ . 'Second' } = $6;
        }
        $Timeoutput{ 'Time' . $_ } = $Self->{LayoutObject}->BuildDateSelection(%TimeConfig);
    }

    # Solution I (TimeExtended)
    my %TimeLists;
    for ( 1 .. 60 ) {
        $TimeLists{TimeRelativeCount}{$_} = sprintf( "%02d", $_ );
        $TimeLists{TimeScaleCount}{$_}    = sprintf( "%02d", $_ );
    }
    for (qw(TimeRelativeCount TimeScaleCount)) {
        $Timeoutput{$_} = $Self->{LayoutObject}->BuildSelection(
            Data       => $TimeLists{$_},
            Name       => $Element . $_,
            SelectedID => $Param{$_},
        );
    }

    if ( $Param{TimeRelativeCount} && $Param{TimeRelativeUnit} ) {
        $Timeoutput{CheckedRelative} = 'checked="checked"';
    }
    else {
        $Timeoutput{CheckedAbsolut} = 'checked="checked"';
    }

    my %TimeScale = _TimeScaleBuildSelection();

    $Timeoutput{TimeScaleUnit} = $Self->{LayoutObject}->BuildSelection(
        %TimeScale,
        Name       => $Element,
        SelectedID => $Param{SelectedValues}[0],
    );

    $Timeoutput{TimeRelativeUnit} = $Self->{LayoutObject}->BuildSelection(
        %TimeScale,
        Name       => $Element . 'TimeRelativeUnit',
        SelectedID => $Param{TimeRelativeUnit},
        OnChange   => "Core.Agent.Stats.SelectRadiobutton('Relativ', '$Element" . "TimeSelect')",
    );

    # to show only the selected Attributes in the view mask
    my $Multiple = 1;
    my $Size     = 5;

    if ( $Param{OnlySelectedAttributes} ) {

        $TimeScale{Data} = $Param{SelectedValues};

        $Multiple = 0;
        $Size     = 1;
    }

    $Timeoutput{TimeSelectField} = $Self->{LayoutObject}->BuildSelection(
        %TimeScale,
        Name       => $Element,
        SelectedID => $Param{SelectedValues},
        Multiple   => $Multiple,
        Size       => $Size,
    );

    return %Timeoutput;
}

sub _TimeScaleBuildSelection {

    my %TimeScaleBuildSelection = (
        Data => {
            Second => 'second(s)',
            Minute => 'minute(s)',
            Hour   => 'hour(s)',
            Day    => 'day(s)',
            Week   => 'week(s)',
            Month  => 'month(s)',
            Year   => 'year(s)',
        },
        Sort => 'IndividualKey',
        SortIndividual => [ 'Second', 'Minute', 'Hour', 'Day', 'Week', 'Month', 'Year' ]
    );

    return %TimeScaleBuildSelection;
}

sub _TimeScale {
    my %TimeScale = (
        'Second' => {
            Position => 1,
            Value    => 'second(s)',
        },
        'Minute' => {
            Position => 2,
            Value    => 'minute(s)',
        },
        'Hour' => {
            Position => 3,
            Value    => 'hour(s)',
        },
        'Day' => {
            Position => 4,
            Value    => 'day(s)',
        },
        'Week' => {
            Position => 5,
            Value    => 'week(s)',
        },
        'Month' => {
            Position => 6,
            Value    => 'month(s)',
        },
        'Year' => {
            Position => 7,
            Value    => 'year(s)',
        },
    );

    return \%TimeScale;
}

=item _ColumnAndRowTranslation()

translate the column and row name if needed

    $StatsObject->_ColumnAndRowTranslation(
        StatArrayRef => $StatArrayRef,
        HeadArrayRef => $HeadArrayRef,
        StatRef      => $StatRef,
        ExchangeAxis => 1 | 0,
    );

=cut

sub _ColumnAndRowTranslation {
    my ( $Self, %Param ) = @_;

    # check if need params are available
    for my $NeededParam (qw(StatArrayRef HeadArrayRef StatRef)) {
        if ( !$Param{$NeededParam} ) {
            return $Self->{LayoutObject}->ErrorScreen(
                Message => "_ColumnAndRowTranslation: Need $NeededParam!"
            );
        }
    }

    # create the needed language object
    use Kernel::Language;
    $Self->{LanguageObject} = Kernel::Language->new(
        MainObject   => $Self->{MainObject},
        ConfigObject => $Self->{ConfigObject},
        EncodeObject => $Self->{EncodeObject},
        LogObject    => $Self->{LogObject},
        UserLanguage => $Self->{UserLanguage} || 'en',
    );

    # find out, if the column or row names should be translated
    my %Translation;
    my %Sort;

    for my $Use (qw( UseAsXvalue UseAsValueSeries )) {
        if (
            $Param{StatRef}->{StatType} eq 'dynamic'
            && $Param{StatRef}->{$Use}
            && ref( $Param{StatRef}->{$Use} ) eq 'ARRAY'
            )
        {
            my @Array = @{ $Param{StatRef}->{$Use} };

            ELEMENT:
            for my $Element (@Array) {
                next ELEMENT if !$Element->{SelectedValues};

                if ( $Element->{Translation} && $Element->{Block} eq 'Time' ) {
                    $Translation{$Use} = 'Time';
                }
                elsif ( $Element->{Translation} ) {
                    $Translation{$Use} = 'Common';
                }
                else {
                    $Translation{$Use} = '';
                }

                if (
                    $Element->{Translation}
                    && $Element->{Block} ne 'Time'
                    && !$Element->{SortIndividual}
                    )
                {
                    $Sort{$Use} = 1;
                }
                last ELEMENT;
            }
        }
    }

    # check if the axis are changed
    if ( $Param{ExchangeAxis} ) {
        my $UseAsXvalueOld = $Translation{UseAsXvalue};
        $Translation{UseAsXvalue}      = $Translation{UseAsValueSeries};
        $Translation{UseAsValueSeries} = $UseAsXvalueOld;

        my $SortUseAsXvalueOld = $Sort{UseAsXvalue};
        $Sort{UseAsXvalue}      = $Sort{UseAsValueSeries};
        $Sort{UseAsValueSeries} = $SortUseAsXvalueOld;
    }

    # translate the headline
    $Param{HeadArrayRef}->[0] = $Self->{LanguageObject}->Translate( $Param{HeadArrayRef}->[0] );

    if ( $Translation{UseAsXvalue} && $Translation{UseAsXvalue} eq 'Time' ) {
        for my $Word ( @{ $Param{HeadArrayRef} } ) {
            if ( $Word =~ m{ ^ (\w+?) ( \s \d+ ) $ }smx ) {
                my $TranslatedWord = $Self->{LanguageObject}->Translate($1);
                $Word =~ s{ ^ ( \w+? ) ( \s \d+ ) $ }{$TranslatedWord$2}smx;
            }
        }
    }

    elsif ( $Translation{UseAsXvalue} ) {
        for my $Word ( @{ $Param{HeadArrayRef} } ) {
            $Word = $Self->{LanguageObject}->Translate($Word);
        }
    }

    # sort the headline
    if ( $Sort{UseAsXvalue} ) {
        my @HeadOld = @{ $Param{HeadArrayRef} };
        shift @HeadOld;    # because the first value is no sortable column name

        # special handling if the sumfunction is used
        my $SumColRef;
        if ( $Param{StatRef}->{SumRow} ) {
            $SumColRef = pop @HeadOld;
        }

        # sort
        my @SortedHead = sort { $a cmp $b } @HeadOld;

        # special handling if the sumfunction is used
        if ( $Param{StatRef}->{SumCol} ) {
            push @SortedHead, $SumColRef;
            push @HeadOld,    $SumColRef;
        }

        # add the row names to the new StatArray
        my @StatArrayNew;
        for my $Row ( @{ $Param{StatArrayRef} } ) {
            push @StatArrayNew, [ $Row->[0] ];
        }

        # sort the values
        for my $ColumnName (@SortedHead) {
            my $Counter = 0;
            COLUMNNAMEOLD:
            for my $ColumnNameOld (@HeadOld) {
                $Counter++;
                next COLUMNNAMEOLD if $ColumnNameOld ne $ColumnName;

                for my $RowLine ( 0 .. $#StatArrayNew ) {
                    push @{ $StatArrayNew[$RowLine] }, $Param{StatArrayRef}->[$RowLine]->[$Counter];
                }
                last COLUMNNAMEOLD;
            }
        }

        # bring the data back to the references
        unshift @SortedHead, $Param{HeadArrayRef}->[0];
        @{ $Param{HeadArrayRef} } = @SortedHead;
        @{ $Param{StatArrayRef} } = @StatArrayNew;
    }

    # translate the row description
    if ( $Translation{UseAsValueSeries} && $Translation{UseAsValueSeries} eq 'Time' ) {
        for my $Word ( @{ $Param{StatArrayRef} } ) {
            if ( $Word->[0] =~ m{ ^ (\w+?) ( \s \d+ ) $ }smx ) {
                my $TranslatedWord = $Self->{LanguageObject}->Translate($1);
                $Word->[0] =~ s{ ^ ( \w+? ) ( \s \d+ ) $ }{$TranslatedWord$2}smx;
            }
        }
    }
    elsif ( $Translation{UseAsValueSeries} ) {

        # translate
        for my $Word ( @{ $Param{StatArrayRef} } ) {
            $Word->[0] = $Self->{LanguageObject}->Translate( $Word->[0] );
        }
    }

    # sort the row description
    if ( $Sort{UseAsValueSeries} ) {

        # special handling if the sumfunction is used
        my $SumRowArrayRef;
        if ( $Param{StatRef}->{SumRow} ) {
            $SumRowArrayRef = pop @{ $Param{StatArrayRef} };
        }

        # sort
        my $DisableDefaultResultSort = grep {
            $_->{DisableDefaultResultSort}
                && $_->{DisableDefaultResultSort} == 1
        } @{ $Param{StatRef}->{UseAsXvalue} };

        if ( !$DisableDefaultResultSort ) {
            @{ $Param{StatArrayRef} } = sort { $a->[0] cmp $b->[0] } @{ $Param{StatArrayRef} };
        }

        # special handling if the sumfunction is used
        if ( $Param{StatRef}->{SumRow} ) {
            push @{ $Param{StatArrayRef} }, $SumRowArrayRef;
        }
    }

    return 1;
}

# ATTENTION: this function delivers only approximations!!!
sub _TimeInSeconds {
    my ( $Self, %Param ) = @_;

    # check if need params are available
    if ( !$Param{TimeUnit} ) {
        return $Self->{LayoutObject}->ErrorScreen( Message => '_TimeInSeconds: Need TimeUnit!' );
    }

    my %TimeInSeconds = (
        Year   => 31536000,    # 60 * 60 * 60 * 365
        Month  => 2592000,     # 60 * 60 * 24 * 30
        Week   => 604800,      # 60 * 60 * 24 * 7
        Day    => 86400,       # 60 * 60 * 24
        Hour   => 3600,        # 60 * 60
        Minute => 60,
        Second => 1,
    );

    return $TimeInSeconds{ $Param{TimeUnit} };
}

=item _OutputHTMLTable()

returns a html table based on a array

    $HTML = $LayoutObject->_OutputHTMLTable(
        Head => ['RowA', 'RowB', ],
        Data => [
            [1,4],
            [7,3],
            [1,9],
            [34,4],
        ],
    );

=cut

sub _OutputHTMLTable {
    my ( $Self, %Param ) = @_;

    my $Output = '';
    my @Head   = ('##No Head Data##');
    if ( $Param{Head} ) {
        @Head = @{ $Param{Head} };
    }
    my @Data = ( ['##No Data##'] );
    if ( $Param{Data} ) {
        @Data = @{ $Param{Data} };
    }

    $Output .= '<table border="0" width="100%" cellspacing="0" cellpadding="3">';
    $Output .= "<tr>\n";
    for my $Entry (@Head) {
        $Output .= "<td class=\"contentvalue\">$Entry</td>\n";
    }
    $Output .= "</tr>\n";
    for my $EntryRow (@Data) {
        $Output .= "<tr>\n";
        for my $Entry ( @{$EntryRow} ) {
            $Output .= "<td class=\"small\">$Entry</td>\n";
        }
        $Output .= "</tr>\n";
    }
    $Output .= "</table>\n";
    return $Output;
}

=end Internal:

=cut

1;
