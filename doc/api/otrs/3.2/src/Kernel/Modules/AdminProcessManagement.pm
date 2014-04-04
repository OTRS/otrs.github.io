# --
# Kernel/Modules/AdminProcessManagement.pm - process management
# Copyright (C) 2001-2014 OTRS AG, http://otrs.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package Kernel::Modules::AdminProcessManagement;
## nofilter(TidyAll::Plugin::OTRS::Perl::Dumper)

use strict;
use warnings;
use Data::Dumper;

use Kernel::System::YAML;

use Kernel::System::JSON;
use Kernel::System::DynamicField;
use Kernel::System::ProcessManagement::DB::Entity;
use Kernel::System::ProcessManagement::DB::Activity;
use Kernel::System::ProcessManagement::DB::ActivityDialog;
use Kernel::System::ProcessManagement::DB::Process;
use Kernel::System::ProcessManagement::DB::Process::State;
use Kernel::System::ProcessManagement::DB::Transition;
use Kernel::System::ProcessManagement::DB::TransitionAction;

use Kernel::System::VariableCheck qw(:all);

sub new {
    my ( $Type, %Param ) = @_;

    # allocate new hash for object
    my $Self = {%Param};
    bless( $Self, $Type );

    # check all needed objects
    for my $Needed (
        qw(ParamObject DBObject LayoutObject ConfigObject LogObject MainObject EncodeObject)
        )
    {
        if ( !$Self->{$Needed} ) {
            $Self->{LayoutObject}->FatalError( Message => "Got no $Needed!" );
        }
    }

    # create additional objects
    $Self->{JSONObject}         = Kernel::System::JSON->new( %{$Self} );
    $Self->{DynamicFieldObject} = Kernel::System::DynamicField->new( %{$Self} );
    $Self->{YAMLObject}         = Kernel::System::YAML->new( %{$Self} );
    $Self->{ProcessObject}      = Kernel::System::ProcessManagement::DB::Process->new( %{$Self} );
    $Self->{EntityObject}       = Kernel::System::ProcessManagement::DB::Entity->new( %{$Self} );
    $Self->{ActivityObject}     = Kernel::System::ProcessManagement::DB::Activity->new( %{$Self} );

    $Self->{ActivityDialogObject}
        = Kernel::System::ProcessManagement::DB::ActivityDialog->new( %{$Self} );

    $Self->{StateObject} = Kernel::System::ProcessManagement::DB::Process::State->new( %{$Self} );

    $Self->{TransitionObject}
        = Kernel::System::ProcessManagement::DB::Transition->new( %{$Self} );

    $Self->{TransitionActionObject}
        = Kernel::System::ProcessManagement::DB::TransitionAction->new( %{$Self} );

    return $Self;
}

sub Run {
    my ( $Self, %Param ) = @_;

    $Self->{Subaction} = $Self->{ParamObject}->GetParam( Param => 'Subaction' ) || '';

    my $ProcessID = $Self->{ParamObject}->GetParam( Param => 'ID' )       || '';
    my $EntityID  = $Self->{ParamObject}->GetParam( Param => 'EntityID' ) || '';

    # get the list of updated or deleted entities
    my $EntitySyncStateList = $Self->{EntityObject}->EntitySyncStateList(
        UserID => $Self->{UserID}
    );

    my $SynchronizeMessage
        = 'Process Management information from database is not in sync with the system configuration, please synchronize all processes.';

    if ( IsArrayRefWithData($EntitySyncStateList) ) {

        # create a notification if system is not up to date
        $Param{NotifyData} = [
            {
                Info => $SynchronizeMessage,
            },
        ];
    }

    # ------------------------------------------------------------ #
    # ProcessImport
    # ------------------------------------------------------------ #
    if ( $Self->{Subaction} eq 'ProcessImport' ) {

        # challenge token check for write action
        $Self->{LayoutObject}->ChallengeTokenCheck();

        my $FormID = $Self->{ParamObject}->GetParam( Param => 'FormID' ) || '';
        my %UploadStuff = $Self->{ParamObject}->GetUploadAll(
            Param  => 'FileUpload',
            Source => 'string',
        );

        my $OverwriteExistingEntities
            = $Self->{ParamObject}->GetParam( Param => 'OverwriteExistingEntities' );

        # import the process YAML file
        my %ProcessImport = $Self->{ProcessObject}->ProcessImport(
            Content                   => $UploadStuff{Content},
            OverwriteExistingEntities => $OverwriteExistingEntities,
            UserID                    => $Self->{UserID},
        );

        if ( !$ProcessImport{Success} ) {

            # show the error screen
            return $Self->{LayoutObject}->ErrorScreen(
                Message => $ProcessImport{Message},
            );
        }
        else {

            # show the overview with success informations
            $Param{NotifyData} = [
                {
                    Info => $ProcessImport{Message},
                },
                {
                    Info => $SynchronizeMessage,
                },
            ];

            return $Self->_ShowOverview(
                %Param,
            );
        }
    }

    # ------------------------------------------------------------ #
    # ProcessExport
    # ------------------------------------------------------------ #
    elsif ( $Self->{Subaction} eq 'ProcessExport' ) {

        # check for ProcessID
        my $ProcessID = $Self->{ParamObject}->GetParam( Param => 'ID' ) || '';
        if ( !$ProcessID ) {
            return $Self->{LayoutObject}->ErrorScreen(
                Message => "Need ProcessID!",
            );
        }

        my $ProcessData = $Self->_GetProcessData(
            ID => $ProcessID
        );

        # convert the processdata hash to string
        my $ProcessDataYAML = $Self->{YAMLObject}->Dump( Data => $ProcessData );

        # send the result to the browser
        return $Self->{LayoutObject}->Attachment(
            ContentType => 'text/html; charset=' . $Self->{LayoutObject}->{Charset},
            Content     => $ProcessDataYAML,
            Type        => 'attachment',
            Filename    => 'Export_ProcessEntityID_' . $ProcessData->{Process}->{EntityID} . '.yml',
            NoCache     => 1,
        );
    }

    # ------------------------------------------------------------ #
    # ProcessPrint
    # ------------------------------------------------------------ #
    elsif ( $Self->{Subaction} eq 'ProcessPrint' ) {

        # we need to use Data::Dumper with custom Indent
        my $Indent = $Data::Dumper::Indent;
        $Data::Dumper::Indent = 1;

        # check for ProcessID
        my $ProcessID = $Self->{ParamObject}->GetParam( Param => 'ID' ) || '';
        if ( !$ProcessID ) {
            return $Self->{LayoutObject}->ErrorScreen(
                Message => "Need ProcessID!",
            );
        }

        my $BooleanMapping = {
            0 => 'No',
            1 => 'Yes',
            2 => 'Yes (mandatory)',
        };

        my $ProcessData = $Self->_GetProcessData(
            ID => $ProcessID
        );

        my $Output = $Self->{LayoutObject}->Header(
            Value => $Param{Title},
            Type  => 'Small',
        );

        # print all activities
        if ( $ProcessData->{Activities} && %{ $ProcessData->{Activities} } ) {

            for my $ActivityEntityID ( sort keys %{ $ProcessData->{Activities} } ) {

                $Self->{LayoutObject}->Block(
                    Name => 'ActivityRow',
                    Data => {
                        %{ $ProcessData->{Activities}->{$ActivityEntityID} },
                        DialogCount =>
                            scalar
                            @{ $ProcessData->{Activities}->{$ActivityEntityID}->{ActivityDialogs} },
                    },
                );

                # list all assigned dialogs
                my $AssignedDialogs
                    = $ProcessData->{Activities}->{$ActivityEntityID}->{Config}->{ActivityDialog};
                if ( $AssignedDialogs && %{$AssignedDialogs} ) {

                    $Self->{LayoutObject}->Block(
                        Name => 'AssignedDialogs',
                    );

                    for my $AssignedDialog ( sort keys %{$AssignedDialogs} ) {

                        my $AssignedDialogEntityID
                            = $ProcessData->{Activities}->{$ActivityEntityID}->{Config}
                            ->{ActivityDialog}->{$AssignedDialog};

                        $Self->{LayoutObject}->Block(
                            Name => 'AssignedDialogsRow',
                            Data => {
                                Name => $ProcessData->{ActivityDialogs}->{$AssignedDialogEntityID}
                                    ->{Name},
                                EntityID => $AssignedDialogEntityID,
                            },
                        );
                    }
                }
            }
        }
        else {
            $Self->{LayoutObject}->Block(
                Name => 'ActivityRowEmpty',
            );
        }

        # print all activity dialogs
        if ( $ProcessData->{ActivityDialogs} && %{ $ProcessData->{ActivityDialogs} } ) {

            for my $ActivityDialogEntityID ( sort keys %{ $ProcessData->{ActivityDialogs} } ) {

                $Self->{LayoutObject}->Block(
                    Name => 'ActivityDialogRow',
                    Data => {
                        ShownIn => join(
                            ', ',
                            @{
                                $ProcessData->{ActivityDialogs}->{$ActivityDialogEntityID}
                                    ->{Config}->{Interface}
                                }
                        ),
                        %{ $ProcessData->{ActivityDialogs}->{$ActivityDialogEntityID} },
                    },
                );

                for my $ElementAttribute (
                    qw(DescriptionShort DescriptionLong SubmitButtonText SubmitAdviceText Permission RequiredLock)
                    )
                {

                    my $Value = $ProcessData->{ActivityDialogs}->{$ActivityDialogEntityID}->{Config}
                        ->{$ElementAttribute};

                    if ( defined $Value ) {

                        if ( $ElementAttribute eq 'RequiredLock' ) {
                            $Value = $BooleanMapping->{$Value};
                        }

                        $Self->{LayoutObject}->Block(
                            Name => 'ElementAttribute',
                            Data => {
                                Key   => $ElementAttribute,
                                Value => $Value,
                            },
                        );
                    }
                }

                # list all assigned fields
                my $AssignedFields
                    = $ProcessData->{ActivityDialogs}->{$ActivityDialogEntityID}->{Config}
                    ->{FieldOrder};
                if ( $AssignedFields && @{$AssignedFields} ) {

                    $Self->{LayoutObject}->Block(
                        Name => 'AssignedFields',
                    );

                    for my $AssignedField ( @{$AssignedFields} ) {

                        $Self->{LayoutObject}->Block(
                            Name => 'AssignedFieldsRow',
                            Data => {
                                Name => $AssignedField,
                            },
                        );

                        my %Values = %{
                            $ProcessData->{ActivityDialogs}->{$ActivityDialogEntityID}
                                ->{Config}->{Fields}->{$AssignedField}
                        };
                        if ( $Values{Config} ) {
                            $Values{Config} = Dumper( $Values{Config} );    ## no critic
                            $Values{Config} =~ s{ \s* \$VAR1 \s* =}{}xms;
                            $Values{Config} =~ s{\s+\{}{\{}xms;
                        }

                        for my $Key ( sort keys %Values ) {

                            if ( $Key eq 'Display' ) {
                                $Values{$Key} = $BooleanMapping->{ $Values{$Key} };
                            }

                            if ( $Values{$Key} ) {
                                $Self->{LayoutObject}->Block(
                                    Name => 'AssignedFieldsRowValue',
                                    Data => {
                                        Key   => $Key,
                                        Value => $Values{$Key},
                                    },
                                );
                            }
                        }
                    }
                }
            }
        }
        else {
            $Self->{LayoutObject}->Block(
                Name => 'ActivityDialogRowEmpty',
            );
        }

        # print all transitions
        if ( $ProcessData->{Transitions} && %{ $ProcessData->{Transitions} } ) {

            for my $TransitionEntityID ( sort keys %{ $ProcessData->{Transitions} } ) {

                # list config
                my $Config = $ProcessData->{Transitions}->{$TransitionEntityID}->{Config};

                $Self->{LayoutObject}->Block(
                    Name => 'TransitionRow',
                    Data => {
                        %{ $ProcessData->{Transitions}->{$TransitionEntityID} },
                        ConditionLinking => $Config->{ConditionLinking},
                    },
                );

                if ( $Config && %{$Config} ) {

                    $Self->{LayoutObject}->Block(
                        Name => 'Condition',
                    );

                    for my $Condition ( sort keys %{ $Config->{Condition} } ) {

                        $Self->{LayoutObject}->Block(
                            Name => 'ConditionRow',
                            Data => {
                                Name => $Condition,
                            },
                        );

                        my %Values = %{ $Config->{Condition}->{$Condition} };

                        for my $Key ( sort keys %Values ) {

                            if ( $Values{$Key} ) {

                                if ( ref $Values{$Key} eq 'HASH' ) {

                                    $Self->{LayoutObject}->Block(
                                        Name => 'ConditionRowSub',
                                        Data => {
                                            NameSub => $Key,
                                        },
                                    );

                                    for my $SubKey ( sort keys %{ $Values{$Key} } ) {

                                        if ( ref $Values{$Key}->{$SubKey} eq 'HASH' ) {

                                            $Self->{LayoutObject}->Block(
                                                Name => 'ConditionRowSubSub',
                                                Data => {
                                                    NameSubSub => $SubKey,
                                                },
                                            );

                                            for my $SubSubKey (
                                                sort keys %{ $Values{$Key}->{$SubKey} }
                                                )
                                            {

                                                $Self->{LayoutObject}->Block(
                                                    Name => 'ConditionRowSubSubValue',
                                                    Data => {
                                                        Key => $SubSubKey,
                                                        Value =>
                                                            $Values{$Key}->{$SubKey}->{$SubSubKey},
                                                    },
                                                );
                                            }
                                        }
                                        else {

                                            $Self->{LayoutObject}->Block(
                                                Name => 'ConditionRowSubValue',
                                                Data => {
                                                    Key   => $SubKey,
                                                    Value => $Values{$Key}->{$SubKey},
                                                },
                                            );
                                        }
                                    }
                                }
                                else {

                                    $Self->{LayoutObject}->Block(
                                        Name => 'ConditionRowValue',
                                        Data => {
                                            Key   => $Key,
                                            Value => $Values{$Key},
                                        },
                                    );
                                }
                            }
                        }
                    }
                }
            }
        }
        else {
            $Self->{LayoutObject}->Block(
                Name => 'TransitionRowEmpty',
            );
        }

        # print all transition actions
        if ( $ProcessData->{TransitionActions} && %{ $ProcessData->{TransitionActions} } ) {

            for my $TransitionActionEntityID ( sort keys %{ $ProcessData->{TransitionActions} } ) {

                $Self->{LayoutObject}->Block(
                    Name => 'TransitionActionRow',
                    Data => {
                        Module => $ProcessData->{TransitionActions}->{$TransitionActionEntityID}
                            ->{Config}->{Module},
                        %{ $ProcessData->{TransitionActions}->{$TransitionActionEntityID} },
                    },
                );

                # list config
                my $Config
                    = $ProcessData->{TransitionActions}->{$TransitionActionEntityID}->{Config}
                    ->{Config};
                if ( $Config && %{$Config} ) {

                    $Self->{LayoutObject}->Block(
                        Name => 'Config',
                    );

                    CONFIGITEM:
                    for my $ConfigItem ( sort keys %{$Config} ) {

                        next CONFIGITEM if !$ConfigItem;

                        $Self->{LayoutObject}->Block(
                            Name => 'ConfigRow',
                            Data => {
                                Name  => $ConfigItem,
                                Value => $Config->{$ConfigItem},
                            },
                        );
                    }
                }

            }
        }
        else {
            $Self->{LayoutObject}->Block(
                Name => 'TransitionActionRowEmpty',
            );
        }

        # get logo
        my $Logo = $Self->{ConfigObject}->Get('AgentLogo');
        if ( $Logo && %{$Logo} ) {
            $Self->{LayoutObject}->Block(
                Name => 'Logo',
                Data => {
                    LogoURL => $Param{LogoURL}
                        = $Self->{ConfigObject}->Get('Frontend::WebPath') . $Logo->{URL},
                },
            );
        }

        # collect path information
        my @Path;
        push @Path, $ProcessData->{Process}->{Config}->{StartActivity};

        ACTIVITY:
        for my $Activity ( @{ $ProcessData->{Process}->{Activities} } ) {
            next ACTIVITY if $Activity eq $ProcessData->{Process}->{Config}->{StartActivity};
            push @Path, $Activity;
        }

        for my $Activity (@Path) {

            for my $Transition (
                sort keys %{ $ProcessData->{Process}->{Config}->{Path}->{$Activity} }
                )
            {
                my $TransitionActionString;
                if (
                    $ProcessData->{Process}->{Config}->{Path}->{$Activity}->{$Transition}
                    ->{TransitionAction}
                    && @{
                        $ProcessData->{Process}->{Config}->{Path}->{$Activity}->{$Transition}
                            ->{TransitionAction}
                    }
                    )
                {
                    $TransitionActionString = join(
                        ', ',
                        @{
                            $ProcessData->{Process}->{Config}->{Path}->{$Activity}->{$Transition}
                                ->{TransitionAction}
                            }
                    );
                    if ($TransitionActionString) {
                        $TransitionActionString = '(' . $TransitionActionString . ')';
                    }
                }

                $Self->{LayoutObject}->Block(
                    Name => 'PathItem',
                    Data => {
                        ActivityStart     => $Activity,
                        Transition        => $Transition,
                        TransitionActions => $TransitionActionString,
                        ActivityEnd =>
                            $ProcessData->{Process}->{Config}->{Path}->{$Activity}->{$Transition}
                            ->{ActivityEntityID},
                    },
                );
            }
        }

        $Output .= $Self->{LayoutObject}->Output(
            TemplateFile => "AdminProcessManagementProcessPrint",
            Data         => {
                Name => $ProcessData->{Process}->{Name} . ' ('
                    . $ProcessData->{Process}->{EntityID} . ')',
                State => $ProcessData->{Process}->{State} . ' ('
                    . $ProcessData->{Process}->{StateEntityID} . ')',
                Description   => $ProcessData->{Process}->{Config}->{Description},
                StartActivity => $ProcessData->{Process}->{Config}->{StartActivity},

                %Param,
            },
        );

        $Output .= $Self->{LayoutObject}->Footer();

        # reset Indent
        $Data::Dumper::Indent = $Indent;

        return $Output;
    }

    # ------------------------------------------------------------ #
    # ProcessCopy
    # ------------------------------------------------------------ #
    elsif ( $Self->{Subaction} eq 'ProcessCopy' ) {

        # challenge token check for write action
        $Self->{LayoutObject}->ChallengeTokenCheck();

        # get Process data
        my $ProcessData = $Self->{ProcessObject}->ProcessGet(
            ID     => $ProcessID,
            UserID => $Self->{UserID},
        );
        if ( !$ProcessData ) {
            return $Self->{LayoutObject}->ErrorScreen(
                Message => "Unknown Process $ProcessID!",
            );
        }

        # create new process name
        my $ProcessName =
            $ProcessData->{Name}
            . ' ('
            . $Self->{LayoutObject}->{LanguageObject}->Get('Copy')
            . ')';

        # generate entity ID
        my $EntityID = $Self->{EntityObject}->EntityIDGenerate(
            EntityType => 'Process',
            UserID     => $Self->{UserID},
        );

        # show error if can't generate a new EntityID
        if ( !$EntityID ) {
            return $Self->{LayoutObject}->ErrorScreen(
                Message => "There was an error generating a new EntityID for this Process",
            );
        }

        # check if Inactive state estity exists
        my $StateList = $Self->{StateObject}->StateList( UserID => $Self->{UserID} );
        my %StateLookup = reverse %{$StateList};

        my $StateEntityID = $StateLookup{'Inactive'};

        # show error if  StateEntityID for Inactive does not exist
        if ( !$EntityID ) {
            return $Self->{LayoutObject}->ErrorScreen(
                Message => "The StateEntityID for for state Inactive does not exists",
            );
        }

        # otherwise save configuration and return to overview screen
        my $ProcessID = $Self->{ProcessObject}->ProcessAdd(
            Name          => $ProcessName,
            EntityID      => $EntityID,
            StateEntityID => $StateEntityID,
            Layout        => $ProcessData->{Layout},
            Config        => $ProcessData->{Config},
            UserID        => $Self->{UserID},
        );

        # show error if can't create
        if ( !$ProcessID ) {
            return $Self->{LayoutObject}->ErrorScreen(
                Message => "There was an error creating the Process",
            );
        }

        # set entitty sync state
        my $Success = $Self->{EntityObject}->EntitySyncStateSet(
            EntityType => 'Process',
            EntityID   => $EntityID,
            SyncState  => 'not_sync',
            UserID     => $Self->{UserID},
        );

        # show error if can't set
        if ( !$Success ) {
            return $Self->{LayoutObject}->ErrorScreen(
                Message => "There was an error setting the entity sync status for Process "
                    . "entity:$EntityID",
            );
        }

        # return to overview
        return $Self->{LayoutObject}->Redirect( OP => "Action=$Self->{Action}" );
    }

    # ------------------------------------------------------------ #
    # ProcessNew
    # ------------------------------------------------------------ #
    elsif ( $Self->{Subaction} eq 'ProcessNew' ) {

        return $Self->_ShowEdit(
            %Param,
            Action => 'New',
        );
    }

    # ------------------------------------------------------------ #
    # ProcessNewAction
    # ------------------------------------------------------------ #
    elsif ( $Self->{Subaction} eq 'ProcessNewAction' ) {

        # challenge token check for write action
        $Self->{LayoutObject}->ChallengeTokenCheck();

        # get process data
        my $ProcessData;

        # get parameter from web browser
        my $GetParam = $Self->_GetParams();

        # set new confguration
        $ProcessData->{Name}                  = $GetParam->{Name};
        $ProcessData->{Config}->{Description} = $GetParam->{Description};
        $ProcessData->{StateEntityID}         = $GetParam->{StateEntityID};

        # check required parameters
        my %Error;
        if ( !$GetParam->{Name} ) {

            # add server error error class
            $Error{NameServerError}        = 'ServerError';
            $Error{NameServerErrorMessage} = 'This field is required';
        }

        if ( !$GetParam->{Description} ) {

            # add server error error class
            $Error{DescriptionServerError}        = 'ServerError';
            $Error{DescriptionServerErrorMessage} = 'This field is required';
        }

        # check if state exists
        my $StateList = $Self->{StateObject}->StateList( UserID => $Self->{UserID} );

        if ( !$StateList->{ $GetParam->{StateEntityID} } )
        {

            # add server error error class
            $Error{StateEntityIDServerError} = 'ServerError';
        }

        # if there is an error return to edit screen
        if ( IsHashRefWithData( \%Error ) ) {
            return $Self->_ShowEdit(
                %Error,
                %Param,
                ProcessData => $ProcessData,
                Action      => 'New',
            );
        }

        # generate entity ID
        my $EntityID = $Self->{EntityObject}->EntityIDGenerate(
            EntityType => 'Process',
            UserID     => $Self->{UserID},
        );

        # show error if can't generate a new EntityID
        if ( !$EntityID ) {
            return $Self->{LayoutObject}->ErrorScreen(
                Message => "There was an error generating a new EntityID for this Process",
            );
        }

        # otherwise save configuration and return to overview screen
        my $ProcessID = $Self->{ProcessObject}->ProcessAdd(
            Name          => $ProcessData->{Name},
            EntityID      => $EntityID,
            StateEntityID => $ProcessData->{StateEntityID},
            Layout        => {},
            Config        => $ProcessData->{Config},
            UserID        => $Self->{UserID},
        );

        # show error if can't create
        if ( !$ProcessID ) {
            return $Self->{LayoutObject}->ErrorScreen(
                Message => "There was an error creating the Process",
            );
        }

        # set entitty sync state
        my $Success = $Self->{EntityObject}->EntitySyncStateSet(
            EntityType => 'Process',
            EntityID   => $EntityID,
            SyncState  => 'not_sync',
            UserID     => $Self->{UserID},
        );

        # show error if can't set
        if ( !$Success ) {
            return $Self->{LayoutObject}->ErrorScreen(
                Message => "There was an error setting the entity sync status for Process "
                    . "entity:$EntityID",
            );
        }

        # redirect to process edit screen
        return $Self->{LayoutObject}->Redirect(
            OP =>
                "Action=AdminProcessManagement;Subaction=ProcessEdit;ID=$ProcessID"
        );

    }

    # ------------------------------------------------------------ #
    # ProcessEdit
    # ------------------------------------------------------------ #
    elsif ( $Self->{Subaction} eq 'ProcessEdit' ) {

        # check for ProcessID
        if ( !$ProcessID ) {
            return $Self->{LayoutObject}->ErrorScreen(
                Message => "Need ProcessID!",
            );
        }

        # set screens path in session
        my @ScreensPath = (
            {
                Action    => $Self->{Action}    || '',
                Subaction => $Self->{Subaction} || '',
                Parameters => 'ID=' . $ProcessID . ';EntityID=' . $EntityID
            }
        );

        # convert screens patch to string (JSON)
        my $JSONScreensPath = $Self->{LayoutObject}->JSONEncode(
            Data => \@ScreensPath,
        );

        $Self->{SessionObject}->UpdateSessionID(
            SessionID => $Self->{SessionID},
            Key       => 'ProcessManagementScreensPath',
            Value     => $JSONScreensPath,
        );

        # get Process data
        my $ProcessData = $Self->{ProcessObject}->ProcessGet(
            ID     => $ProcessID,
            UserID => $Self->{UserID},
        );

        # check for valid Process data
        if ( !IsHashRefWithData($ProcessData) ) {
            return $Self->{LayoutObject}->ErrorScreen(
                Message => "Could not get data for ProcessID $ProcessID",
            );
        }

        return $Self->_ShowEdit(
            %Param,
            ProcessID   => $ProcessID,
            ProcessData => $ProcessData,
            Action      => 'Edit',
        );
    }

    # ------------------------------------------------------------ #
    # ProcessEditAction
    # ------------------------------------------------------------ #
    elsif ( $Self->{Subaction} eq 'ProcessEditAction' ) {

        # challenge token check for write action
        $Self->{LayoutObject}->ChallengeTokenCheck();

        # get webserice configuration
        my $ProcessData;

        # get parameter from web browser
        my $GetParam = $Self->_GetParams();

        # set new confguration
        $ProcessData->{Name}                          = $GetParam->{Name};
        $ProcessData->{EntityID}                      = $GetParam->{EntityID};
        $ProcessData->{ProcessLayout}                 = $GetParam->{ProcessLayout};
        $ProcessData->{StateEntityID}                 = $GetParam->{StateEntityID};
        $ProcessData->{Config}->{Description}         = $GetParam->{Description};
        $ProcessData->{Config}->{Path}                = $GetParam->{Path};
        $ProcessData->{Config}->{StartActivity}       = $GetParam->{StartActivity};
        $ProcessData->{Config}->{StartActivityDialog} = $GetParam->{StartActivityDialog};

        # check required parameters
        my %Error;
        if ( !$GetParam->{Name} ) {

            # add server error error class
            $Error{NameServerError}        = 'ServerError';
            $Error{NameServerErrorMessage} = 'This field is required';
        }

        if ( !$GetParam->{Description} ) {

            # add server error error class
            $Error{DescriptionServerError}        = 'ServerError';
            $Error{DescriptionServerErrorMessage} = 'This field is required';
        }

        # check if state exists
        my $StateList = $Self->{StateObject}->StateList( UserID => $Self->{UserID} );

        if ( !$StateList->{ $GetParam->{StateEntityID} } )
        {

            # add server error error class
            $Error{StateEntityIDServerError} = 'ServerError';
        }

        # if there is an error return to edit screen
        if ( IsHashRefWithData( \%Error ) ) {
            return $Self->_ShowEdit(
                %Error,
                %Param,
                ProcessData => $ProcessData,
                Action      => 'Edit',
            );
        }

        # otherwise save configuration and return to overview screen
        my $Success = $Self->{ProcessObject}->ProcessUpdate(
            ID            => $ProcessID,
            Name          => $ProcessData->{Name},
            EntityID      => $ProcessData->{EntityID},
            StateEntityID => $ProcessData->{StateEntityID},
            Layout        => $ProcessData->{ProcessLayout},
            Config        => $ProcessData->{Config},
            UserID        => $Self->{UserID},
        );

        # show error if can't update
        if ( !$Success ) {
            return $Self->{LayoutObject}->ErrorScreen(
                Message => "There was an error updating the Process",
            );
        }

        # set entitty sync state
        $Success = $Self->{EntityObject}->EntitySyncStateSet(
            EntityType => 'Process',
            EntityID   => $ProcessData->{EntityID},
            SyncState  => 'not_sync',
            UserID     => $Self->{UserID},
        );

        # show error if can't set
        if ( !$Success ) {
            return $Self->{LayoutObject}->ErrorScreen(
                Message => "There was an error setting the entity sync status for Process "
                    . "entity:$ProcessData->{EntityID}",
            );
        }

        if ( $Self->{ParamObject}->GetParam( Param => 'ContinueAfterSave' ) eq '1' ) {

          # if the user would like to continue editing the process, just redirect to the edit screen
            return $Self->{LayoutObject}->Redirect(
                OP =>
                    "Action=AdminProcessManagement;Subaction=ProcessEdit;ID=$ProcessID;EntityID=$ProcessData->{EntityID}"
            );
        }
        else {

            # otherwise return to overview
            return $Self->{LayoutObject}->Redirect( OP => "Action=$Self->{Action}" );
        }
    }

    # ------------------------------------------------------------ #
    # ProcessDeleteCheck AJAX
    # ------------------------------------------------------------ #
    elsif ( $Self->{Subaction} eq 'ProcessDeleteCheck' ) {

        # check for ProcessID
        return if !$ProcessID;

        my $CheckResult = $Self->_CheckProcessDelete( ID => $ProcessID );

        # build JSON output
        my $JSON = $Self->{LayoutObject}->JSONEncode(
            Data => {
                %{$CheckResult},
            },
        );

        # send JSON response
        return $Self->{LayoutObject}->Attachment(
            ContentType => 'application/json; charset=' . $Self->{LayoutObject}->{Charset},
            Content     => $JSON,
            Type        => 'inline',
            NoCache     => 1,
        );
    }

    # ------------------------------------------------------------ #
    # ProcessDelete AJAX
    # ------------------------------------------------------------ #
    elsif ( $Self->{Subaction} eq 'ProcessDelete' ) {

        # challenge token check for write action
        $Self->{LayoutObject}->ChallengeTokenCheck();

        # check for ProcessID
        return if !$ProcessID;

        my $CheckResult = $Self->_CheckProcessDelete( ID => $ProcessID );

        my $JSON;
        if ( $CheckResult->{Success} ) {

            my $Success = $Self->{ProcessObject}->ProcessDelete(
                ID     => $ProcessID,
                UserID => $Self->{UserID},
            );

            my %DeleteResult = (
                Success => $Success,
            );

            if ( !$Success ) {
                $DeleteResult{Message} = 'Process:$ProcessID could not be deleted';
            }
            else {

                # set entitty sync state
                my $Success = $Self->{EntityObject}->EntitySyncStateSet(
                    EntityType => 'Process',
                    EntityID   => $CheckResult->{ProcessData}->{EntityID},
                    SyncState  => 'deleted',
                    UserID     => $Self->{UserID},
                );

                # show error if cant set
                if ( !$Success ) {
                    $DeleteResult{Success} = $Success;
                    $DeleteResult{Message} = "There was an error setting the entity sync status "
                        . "for Process entity:$CheckResult->{ProcessData}->{EntityID}"
                }
            }

            # build JSON output
            $JSON = $Self->{LayoutObject}->JSONEncode(
                Data => {
                    %DeleteResult,
                },
            );
        }
        else {

            # build JSON output
            $JSON = $Self->{LayoutObject}->JSONEncode(
                Data => {
                    %{$CheckResult},
                },
            );
        }

        # send JSON response
        return $Self->{LayoutObject}->Attachment(
            ContentType => 'application/json; charset=' . $Self->{LayoutObject}->{Charset},
            Content     => $JSON,
            Type        => 'inline',
            NoCache     => 1,
        );
    }

    # ------------------------------------------------------------ #
    # ProcessSync
    # ------------------------------------------------------------ #
    elsif ( $Self->{Subaction} eq 'ProcessSync' ) {

        my $Location
            = $Self->{ConfigObject}->Get('Home') . '/Kernel/Config/Files/ZZZProcessManagement.pm';

        my $ProcessDump = $Self->{ProcessObject}->ProcessDump(
            ResultType => 'FILE',
            Location   => $Location,
            UserID     => $Self->{UserID},
        );

        if ($ProcessDump) {

            my $Success = $Self->{EntityObject}->EntitySyncStatePurge(
                UserID => $Self->{UserID},
            );

            if ($Success) {
                return $Self->{LayoutObject}->Redirect( OP => "Action=$Self->{Action}" );
            }
            else {

                # show error if can't set state
                return $Self->{LayoutObject}->ErrorScreen(
                    Message => "There was an error setting the entity sync status.",
                );
            }
        }
        else {

            # show error if can't synch
            return $Self->{LayoutObject}->ErrorScreen(
                Message => "There was an error synchronizing the processes.",
            );
        }
    }

    # ------------------------------------------------------------ #
    # EntityUsageCheck AJAX
    # ------------------------------------------------------------ #
    elsif ( $Self->{Subaction} eq 'EntityUsageCheck' ) {

        my %GetParam;
        for my $Param (qw(EntityType EntityID)) {
            $GetParam{$Param} = $Self->{ParamObject}->GetParam( Param => $Param ) || '';
        }

        # check needed information
        return if !$GetParam{EntityType};
        return if !$GetParam{EntityID};

        my $EntityCheck = $Self->_CheckEntityUsage(%GetParam);

        # build JSON output
        my $JSON = $Self->{LayoutObject}->JSONEncode(
            Data => {
                %{$EntityCheck},
            },
        );

        # send JSON response
        return $Self->{LayoutObject}->Attachment(
            ContentType => 'application/json; charset=' . $Self->{LayoutObject}->{Charset},
            Content     => $JSON,
            Type        => 'inline',
            NoCache     => 1,
        );
    }

    # ------------------------------------------------------------ #
    # EntityDelete AJAX
    # ------------------------------------------------------------ #
    elsif ( $Self->{Subaction} eq 'EntityDelete' ) {

        # challenge token check for write action
        $Self->{LayoutObject}->ChallengeTokenCheck();

        my %GetParam;
        for my $Param (qw(EntityType EntityID ItemID)) {
            $GetParam{$Param} = $Self->{ParamObject}->GetParam( Param => $Param ) || '';
        }

        # check needed information
        return if !$GetParam{EntityType};
        return if !$GetParam{EntityID};
        return if !$GetParam{ItemID};

        return if $GetParam{EntityType} ne 'Activity'
            && $GetParam{EntityType} ne 'ActivityDialog'
            && $GetParam{EntityType} ne 'Transition'
            && $GetParam{EntityType} ne 'TransitionAction';

        my $EntityCheck = $Self->_CheckEntityUsage(%GetParam);

        my $JSON;
        if ( !$EntityCheck->{Deleteable} ) {
            $JSON = $Self->{LayoutObject}->JSONEncode(
                Data => {
                    Success => 0,
                    Message => "The $GetParam{EntityType}:$GetParam{EntityID} is still in use",
                },
            );
        }
        else {

            # get entity
            my $Method = $GetParam{EntityType} . 'Get';
            my $Entity = $Self->{ $GetParam{EntityType} . 'Object' }->$Method(
                ID     => $GetParam{ItemID},
                UserID => $Self->{UserID},
            );

            if ( $Entity->{EntityID} ne $GetParam{EntityID} ) {
                $JSON = $Self->{LayoutObject}->JSONEncode(
                    Data => {
                        Success => 0,
                        Message => "The $GetParam{EntityType}:$GetParam{ItemID} has a different"
                            . " EntityID",
                    },
                );
            }
            else {

                # delete entity
                $Method = $GetParam{EntityType} . 'Delete';
                my $Success = $Self->{ $GetParam{EntityType} . 'Object' }->$Method(
                    ID     => $GetParam{ItemID},
                    UserID => $Self->{UserID},
                );

                my $Message;
                if ( !$Success ) {
                    $Success = 0;
                    $Message = "Could not delete $GetParam{EntityType}:$GetParam{ItemID}";
                }
                else {

                    # set entitty sync state
                    my $Success = $Self->{EntityObject}->EntitySyncStateSet(
                        EntityType => $GetParam{EntityType},
                        EntityID   => $Entity->{EntityID},
                        SyncState  => 'deleted',
                        UserID     => $Self->{UserID},
                    );

                    # show error if cant set
                    if ( !$Success ) {
                        $Success = 0;
                        $Message = "There was an error setting the entity sync status for "
                            . "$GetParam{EntityType} entity:$Entity->{EntityID}"
                    }
                }

                # build JSON output
                $JSON = $Self->{LayoutObject}->JSONEncode(
                    Data => {
                        Success => $Success,
                        Message => $Message,
                    },
                );
            }
        }

        # send JSON response
        return $Self->{LayoutObject}->Attachment(
            ContentType => 'application/json; charset=' . $Self->{LayoutObject}->{Charset},
            Content     => $JSON,
            Type        => 'inline',
            NoCache     => 1,
        );
    }

    # ------------------------------------------------------------ #
    # EntityGet AJAX
    # ------------------------------------------------------------ #
    elsif ( $Self->{Subaction} eq 'EntityGet' ) {

        my %GetParam;
        for my $Param (qw(EntityType EntityID ItemID)) {
            $GetParam{$Param} = $Self->{ParamObject}->GetParam( Param => $Param ) || '';
        }

        # check needed information
        return if !$GetParam{EntityType};
        return if !$GetParam{EntityID} && !$GetParam{ItemID};

        return if $GetParam{EntityType} ne 'Activity'
            && $GetParam{EntityType} ne 'ActivityDialog'
            && $GetParam{EntityType} ne 'Transition'
            && $GetParam{EntityType} ne 'TransitionAction'
            && $GetParam{EntityType} ne 'Process';

        # get entity
        my $Method = $GetParam{EntityType} . 'Get';

        my $EntityData;
        if ( $GetParam{ItemID} && $GetParam{ItemID} ne '' ) {
            $EntityData = $Self->{ $GetParam{EntityType} . 'Object' }->$Method(
                ID     => $GetParam{ItemID},
                UserID => $Self->{UserID},
            );
        }
        else {
            $EntityData = $Self->{ $GetParam{EntityType} . 'Object' }->$Method(
                EntityID => $GetParam{EntityID},
                UserID   => $Self->{UserID},
            );
        }

        my $JSON;
        if ( !IsHashRefWithData($EntityData) ) {
            $JSON = $Self->{LayoutObject}->JSONEncode(
                Data => {
                    Success => 0,
                    Message => "Could not get $GetParam{EntityType}",
                },
            );
        }
        else {

            # build JSON output
            $JSON = $Self->{LayoutObject}->JSONEncode(
                Data => {
                    Success    => 1,
                    EntityData => $EntityData,
                },
            );
        }

        # send JSON response
        return $Self->{LayoutObject}->Attachment(
            ContentType => 'application/json; charset=' . $Self->{LayoutObject}->{Charset},
            Content     => $JSON,
            Type        => 'inline',
            NoCache     => 1,
        );
    }

    # ------------------------------------------------------------ #
    # UpdateSyncMessage AJAX
    # ------------------------------------------------------------ #
    elsif ( $Self->{Subaction} eq 'UpdateSyncMessage' ) {

        # get the list of updated or deleted entities
        my $EntitySyncStateList = $Self->{EntityObject}->EntitySyncStateList(
            UserID => $Self->{UserID}
        );

        # prevent errors by defining $Output as an empty string instead of undef
        my $Output = '';
        if ( IsArrayRefWithData($EntitySyncStateList) ) {
            $Output = $Self->{LayoutObject}->Notify(
                Info => $SynchronizeMessage,
            );
        }

        # send HTML response
        return $Self->{LayoutObject}->Attachment(
            ContentType => 'text/html',
            Content     => $Output,
            Type        => 'inline',
            NoCache     => 1,
        );
    }

    # ------------------------------------------------------------ #
    # UpdateAccordion AJAX
    # ------------------------------------------------------------ #
    elsif ( $Self->{Subaction} eq 'UpdateAccordion' ) {

        # ouput available process elements in the accordion
        for my $Element (qw(Activity ActivityDialog Transition TransitionAction)) {

            my $ElementMethod = $Element . 'ListGet';

            # get a list of all elements with details
            my $ElementList
                = $Self->{ $Element . 'Object' }->$ElementMethod( UserID => $Self->{UserID} );

            # check there are elements to display
            if ( IsArrayRefWithData($ElementList) ) {
                for my $ElementData (
                    sort { lc( $a->{Name} ) cmp lc( $b->{Name} ) }
                    @{$ElementList}
                    )
                {

                    my $AvailableIn = '';
                    if ( $Element eq "ActivityDialog" ) {
                        my $ConfigAvailableIn = $ElementData->{Config}->{Interface};

                        if ( defined $ConfigAvailableIn ) {
                            my $InterfaceLength = scalar @{$ConfigAvailableIn};
                            if ( $InterfaceLength == 2 ) {
                                $AvailableIn = 'A/C';
                            }
                            elsif ( $InterfaceLength == 1 ) {
                                $AvailableIn = substr( $ConfigAvailableIn->[0], 0, 1 );
                            }
                            else {
                                $AvailableIn = 'A';
                            }
                        }
                        else {
                            $AvailableIn = 'A';
                        }
                    }

                    # print each element in the accordion
                    $Self->{LayoutObject}->Block(
                        Name => $Element . 'Row',
                        Data => {
                            %{$ElementData},
                            AvailableIn => $AvailableIn,    #only used for ActivityDialogs
                        },
                    );
                }
            }
            else {

                # print no data found in the accordion
                $Self->{LayoutObject}->Block(
                    Name => $Element . 'NoDataRow',
                    Data => {},
                );
            }
        }

        my $Output = $Self->{LayoutObject}->Output(
            TemplateFile => "AdminProcessManagementProcessAccordion",
            Data         => {},
        );

        # send HTML response
        return $Self->{LayoutObject}->Attachment(
            ContentType => 'text/html',
            Content     => $Output,
            Type        => 'inline',
            NoCache     => 1,
        );

    }

    # ------------------------------------------------------------ #
    # UpdateScreensPath AJAX
    # ------------------------------------------------------------ #
    elsif ( $Self->{Subaction} eq 'UpdateScreensPath' ) {

        my $Success = 1;
        my $Message = '';
        for my $Needed (qw(ProcessID ProcessEntityID)) {

            $Param{$Needed} = $Self->{ParamObject}->GetParam( Param => $Needed ) || '';
            if ( !$Param{$Needed} ) {
                $Success = 0;
                $Message = 'Need $Needed!';
            }
        }

        if ($Success) {

            $Self->_PushSessionScreen(
                ID        => $Param{ProcessID},
                EntityID  => $Param{ProcessEntityID},
                Subaction => 'ProcessEdit',
                Action    => 'AdminProcessManagement',
            );
        }

        # build JSON output
        my $JSON = $Self->{LayoutObject}->JSONEncode(
            Data => {
                Success => $Success,
                Message => $Message,
            },
        );

        # send JSON response
        return $Self->{LayoutObject}->Attachment(
            ContentType => 'application/json; charset=' . $Self->{LayoutObject}->{Charset},
            Content     => $JSON,
            Type        => 'inline',
            NoCache     => 1,
        );
    }

    # ------------------------------------------------------------ #
    # Overview
    # ------------------------------------------------------------ #
    else {
        return $Self->_ShowOverview(
            %Param,
        );
    }
}

sub _ShowOverview {
    my ( $Self, %Param ) = @_;

    my $Output = $Self->{LayoutObject}->Header();
    $Output .= $Self->{LayoutObject}->NavigationBar();

    # show notifications if any
    if ( $Param{NotifyData} ) {
        for my $Notification ( @{ $Param{NotifyData} } ) {
            $Output .= $Self->{LayoutObject}->Notify(
                %{$Notification},
            );
        }
    }

    # get a process list
    my $ProcessList = $Self->{ProcessObject}->ProcessList( UserID => $Self->{UserID} );

    if ( IsHashRefWithData($ProcessList) ) {

        # get each process data
        for my $ProcessID ( sort keys %{$ProcessList} ) {
            my $ProcessData = $Self->{ProcessObject}->ProcessGet(
                ID     => $ProcessID,
                UserID => $Self->{UserID},
            );

            # print each process in overview table
            $Self->{LayoutObject}->Block(
                Name => 'ProcessRow',
                Data => {
                    %{$ProcessData},
                    Description => $ProcessData->{Config}->{Description},
                    }
            );
        }
    }
    else {

        # print no data found message
        $Self->{LayoutObject}->Block(
            Name => 'ProcessNoDataRow',
            Data => {},
        );
    }

    $Output .= $Self->{LayoutObject}->Output(
        TemplateFile => 'AdminProcessManagement',
        Data         => \%Param,
    );
    $Output .= $Self->{LayoutObject}->Footer();

    return $Output;
}

sub _ShowEdit {
    my ( $Self, %Param ) = @_;

    # get process information
    my $ProcessData = $Param{ProcessData} || {};

    if ( defined $Param{Action} && $Param{Action} eq 'Edit' ) {

        # check if process is inactive and show delete action
        my $State = $Self->{StateObject}->StateLookup(
            EntityID => $ProcessData->{StateEntityID},
            UserID   => $Self->{UserID},
        );
        if ( $State eq 'Inactive' ) {
            $Self->{LayoutObject}->Block(
                Name => 'ProcessDeleteAction',
                Data => {
                    %{$ProcessData},
                },
            );
        }

        # ouput available process elements in the accordion
        for my $Element (qw(Activity ActivityDialog Transition TransitionAction)) {

            my $ElementMethod = $Element . 'ListGet';

            # get a list of all elements with details
            my $ElementList
                = $Self->{ $Element . 'Object' }->$ElementMethod( UserID => $Self->{UserID} );

            # check there are elements to display
            if ( IsArrayRefWithData($ElementList) ) {
                for my $ElementData (
                    sort { lc( $a->{Name} ) cmp lc( $b->{Name} ) }
                    @{$ElementList}
                    )
                {

                    my $AvailableIn = '';
                    if ( $Element eq "ActivityDialog" ) {
                        my $ConfigAvailableIn = $ElementData->{Config}->{Interface};

                        if ( defined $ConfigAvailableIn ) {
                            my $InterfaceLength = scalar @{$ConfigAvailableIn};
                            if ( $InterfaceLength == 2 ) {
                                $AvailableIn = 'A/C';
                            }
                            elsif ( $InterfaceLength == 1 ) {
                                $AvailableIn = substr( $ConfigAvailableIn->[0], 0, 1 );
                            }
                            else {
                                $AvailableIn = 'A';
                            }
                        }
                        else {
                            $AvailableIn = 'A';
                        }
                    }

                    # print each element in the accordion
                    $Self->{LayoutObject}->Block(
                        Name => $Element . 'Row',
                        Data => {
                            %{$ElementData},
                            AvailableIn => $AvailableIn,    #only used for ActivityDialogs
                        },
                    );
                }
            }
            else {

                # print no data found in the accordion
                $Self->{LayoutObject}->Block(
                    Name => $Element . 'NoDataRow',
                    Data => {},
                );
            }
        }
    }

    # get a list of all states
    my $StateList = $Self->{StateObject}->StateList( UserID => $Self->{UserID} );

    # get the 'inactive' state for init
    my $InactiveStateID;
    for my $StateID ( sort keys %{$StateList} ) {
        if ( $StateList->{$StateID} =~ m{Inactive}xmsi ) {
            $InactiveStateID = $StateID;
        }
    }

    my $StateError = '';
    if ( $Param{StateEntityIDServerError} ) {
        $StateError = $Param{StateEntityIDServerError};
    }

    # create estate selection
    $Param{StateSelection} = $Self->{LayoutObject}->BuildSelection(
        Data => $StateList || {},
        Name => 'StateEntityID',
        ID   => 'StateEntityID',
        SelectedID => $ProcessData->{StateEntityID}
            || $InactiveStateID,    # select inactive by default
        Sort        => 'AlphanumericKey',
        Translation => 1,
        Class       => 'W50pc ' . $StateError,
    );

    my $Output = $Self->{LayoutObject}->Header();
    $Output .= $Self->{LayoutObject}->NavigationBar();

    # show notifications if any
    if ( $Param{NotifyData} ) {
        for my $Notification ( @{ $Param{NotifyData} } ) {
            $Output .= $Self->{LayoutObject}->Notify(
                %{$Notification},
            );
        }
    }

    # set db dump as config settings
    my $ProcessDump = $Self->{ProcessObject}->ProcessDump(
        ResultType => 'HASH',
        UserID     => $Self->{UserID},
    );
    my $ProcessConfigJSON = $Self->{LayoutObject}->JSONEncode(
        Data => $ProcessDump->{Process},
    );
    my $ActivityConfigJSON = $Self->{LayoutObject}->JSONEncode(
        Data => $ProcessDump->{Activity},
    );
    my $ActivityDialogConfigJSON = $Self->{LayoutObject}->JSONEncode(
        Data => $ProcessDump->{ActivityDialog},
    );
    my $TransitionConfigJSON = $Self->{LayoutObject}->JSONEncode(
        Data => $ProcessDump->{Transition},
    );
    my $TransitionActionConfigJSON = $Self->{LayoutObject}->JSONEncode(
        Data => $ProcessDump->{TransitionAction},
    );

    my $ProcessLayoutJSON = $Self->{LayoutObject}->JSONEncode(
        Data => $ProcessData->{Layout},
    );

    $Self->{LayoutObject}->Block(
        Name => 'ConfigSet',
        Data => {
            ProcessConfig          => $ProcessConfigJSON,
            ProcessLayout          => $ProcessLayoutJSON,
            ActivityConfig         => $ActivityConfigJSON,
            ActivityDialogConfig   => $ActivityDialogConfigJSON,
            TransitionConfig       => $TransitionConfigJSON,
            TransitionActionConfig => $TransitionActionConfigJSON,
        },
    );

    $Output .= $Self->{LayoutObject}->Output(
        TemplateFile => "AdminProcessManagementProcess$Param{Action}",
        Data         => {
            %Param,
            %{$ProcessData},
            Description => $ProcessData->{Config}->{Description} || '',
        },
    );

    $Output .= $Self->{LayoutObject}->Footer();

    return $Output;
}

sub _GetParams {
    my ( $Self, %Param ) = @_;

    my $GetParam;

    # get parameters from web browser
    for my $ParamName (
        qw( Name EntityID ProcessLayout Path StartActivity StartActivityDialog Description StateEntityID )
        )
    {
        $GetParam->{$ParamName} = $Self->{ParamObject}->GetParam( Param => $ParamName ) || '';
    }

    if ( $GetParam->{ProcessLayout} ) {
        $GetParam->{ProcessLayout} = $Self->{JSONObject}->Decode(
            Data => $GetParam->{ProcessLayout},
        );
    }

    if ( $GetParam->{Path} ) {
        $GetParam->{Path} = $Self->{JSONObject}->Decode(
            Data => $GetParam->{Path},
        );
    }

    return $GetParam;
}

sub _CheckProcessDelete {
    my ( $Self, %Param ) = @_;

    # get Process data
    my $ProcessData = $Self->{ProcessObject}->ProcessGet(
        ID     => $Param{ID},
        UserID => $Self->{UserID},
    );

    # check for valid Process data
    if ( !IsHashRefWithData($ProcessData) ) {
        return {
            Success => 0,
            Message => "Could not get data for ProcessID $Param{ID}",
        };
    }

    # check that the Process is in Inactive state
    my $State = $Self->{StateObject}->StateLookup(
        EntityID => $ProcessData->{StateEntityID},
        UserID   => $Self->{UserID},
    );

    if ( $State ne 'Inactive' ) {
        return {
            Success => 0,
            Message => "Process:$Param{ID} is not Inactive",
        };
    }

    return {
        Success     => 1,
        ProcessData => $ProcessData,
    };
}

sub _CheckEntityUsage {
    my ( $Self, %Param ) = @_;

    my %Config = (
        Activity => {
            Parent => 'Process',
            Method => 'ProcessListGet',
            Array  => 'Activities',
        },
        ActivityDialog => {
            Parent => 'Activity',
            Method => 'ActivityListGet',
            Array  => 'ActivityDialogs',
        },
        Transition => {
            Parent => 'Process',
            Method => 'ProcessListGet',
            Array  => 'Transitions',
        },
        TransitionAction => {
            Parent => 'Transition',
            Method => 'TransitionListGet',
            Array  => 'TransitionActions',
        },
    );

    return if !$Config{ $Param{EntityType} };

    my $Parent = $Config{ $Param{EntityType} }->{Parent};
    my $Method = $Config{ $Param{EntityType} }->{Method};
    my $Array  = $Config{ $Param{EntityType} }->{Array};

    # get a list of parents with all the details
    my $List = $Self->{ $Parent . 'Object' }->$Method(
        UserID => 1,
    );

    my @Usage;

    # search entity id in all parents
    PARENT:
    for my $ParentData ( @{$List} ) {
        next PARENT if !$ParentData;
        next PARENT if !$ParentData->{$Array};

        ENTITY:
        for my $EntityID ( @{ $ParentData->{$Array} } ) {
            if ( $EntityID eq $Param{EntityID} ) {
                push @Usage, $ParentData->{Name};
                last ENTITY;
            }
        }
    }

    my $Deleteable = 0;

    if ( scalar @Usage == 0 ) {
        $Deleteable = 1;
    }

    return {
        Deleteable => $Deleteable,
        Usage      => \@Usage,
    };
}

sub _PushSessionScreen {
    my ( $Self, %Param ) = @_;

    # add screen to the screen path
    push @{ $Self->{ScreensPath} }, {
        Action => $Self->{Action} || '',
        Subaction => $Param{Subaction},
        ID        => $Param{ID},
        EntityID  => $Param{EntityID},
    };

    # convert screens path to string (JSON)
    my $JSONScreensPath = $Self->{LayoutObject}->JSONEncode(
        Data => $Self->{ScreensPath},
    );

    # update session
    $Self->{SessionObject}->UpdateSessionID(
        SessionID => $Self->{SessionID},
        Key       => 'ProcessManagementScreensPath',
        Value     => $JSONScreensPath,
    );

    return 1;
}

sub _GetFullProcessConfig {
    my ( $Self, %Param )

}

sub _GetProcessData {

    my ( $Self, %Param ) = @_;

    my %ProcessData;

    # get process data
    my $Process = $Self->{ProcessObject}->ProcessGet(
        ID     => $Param{ID},
        UserID => $Self->{UserID},
    );
    if ( !$Process ) {
        return $Self->{LayoutObject}->ErrorScreen(
            Message => "Unknown Process $Param{ID}!",
        );
    }
    $ProcessData{Process} = $Process;

    # get all used activities
    for my $ActivityEntityID ( @{ $Process->{Activities} } ) {

        my $Activity = $Self->{ActivityObject}->ActivityGet(
            EntityID => $ActivityEntityID,
            UserID   => $Self->{UserID},
        );
        $ProcessData{Activities}->{$ActivityEntityID} = $Activity;

        # get all used activity dialogs
        for my $ActivityDialogEntityID ( @{ $Activity->{ActivityDialogs} } ) {

            my $ActivityDialog = $Self->{ActivityDialogObject}->ActivityDialogGet(
                EntityID => $ActivityDialogEntityID,
                UserID   => $Self->{UserID},
            );
            $ProcessData{ActivityDialogs}->{$ActivityDialogEntityID} = $ActivityDialog;
        }
    }

    # get all used transitions
    for my $TransitionEntityID ( @{ $Process->{Transitions} } ) {

        my $Transition = $Self->{TransitionObject}->TransitionGet(
            EntityID => $TransitionEntityID,
            UserID   => $Self->{UserID},
        );
        $ProcessData{Transitions}->{$TransitionEntityID} = $Transition;
    }

    # get all used transition actions
    for my $TransitionActionEntityID ( @{ $Process->{TransitionActions} } ) {

        my $TransitionAction = $Self->{TransitionActionObject}->TransitionActionGet(
            EntityID => $TransitionActionEntityID,
            UserID   => $Self->{UserID},
        );
        $ProcessData{TransitionActions}->{$TransitionActionEntityID} = $TransitionAction;
    }

    return \%ProcessData;
}

1;
