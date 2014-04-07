# --
# Kernel/Modules/CustomerTicketProcess.pm - to create process tickets
# Copyright (C) 2001-2014 OTRS AG, http://otrs.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package Kernel::Modules::CustomerTicketProcess;
## nofilter(TidyAll::Plugin::OTRS::Perl::DBObject)

use strict;
use warnings;

use Kernel::System::ProcessManagement::Activity;
use Kernel::System::ProcessManagement::ActivityDialog;
use Kernel::System::ProcessManagement::TransitionAction;
use Kernel::System::ProcessManagement::Transition;
use Kernel::System::ProcessManagement::Process;
use Kernel::System::DynamicField;
use Kernel::System::DynamicField::Backend;
use Kernel::System::State;
use Kernel::System::Web::UploadCache;
use Kernel::System::Service;
use Kernel::System::SLA;
use Kernel::System::User;
use Kernel::System::Group;
use Kernel::System::Lock;
use Kernel::System::Priority;
use Kernel::System::CustomerUser;
use Kernel::System::Type;
use Kernel::System::VariableCheck qw(:all);

sub new {
    my ( $Type, %Param ) = @_;

    # allocate new hash for object
    my $Self = {%Param};
    bless $Self, $Type;

    # check needed Objects
    for my $Needed (
        qw(
        ParamObject DBObject TicketObject LayoutObject LogObject ConfigObject TimeObject MainObject
        EncodeObject QueueObject
        )
        )
    {
        if ( !$Self->{$Needed} ) {
            $Self->{LayoutObject}->CustomerFatalError( Message => "Got no $Needed!" );
        }
    }

    $Self->{StateObject}          = Kernel::System::State->new(%Param);
    $Self->{UploadCacheObject}    = Kernel::System::Web::UploadCache->new(%Param);
    $Self->{LockObject}           = Kernel::System::Lock->new(%Param);
    $Self->{PriorityObject}       = Kernel::System::Priority->new(%Param);
    $Self->{ServiceObject}        = Kernel::System::Service->new(%Param);
    $Self->{SLAObject}            = Kernel::System::SLA->new(%Param);
    $Self->{UserObject}           = Kernel::System::User->new(%Param);
    $Self->{GroupObject}          = Kernel::System::Group->new(%Param);
    $Self->{ActivityObject}       = Kernel::System::ProcessManagement::Activity->new(%Param);
    $Self->{ActivityDialogObject} = Kernel::System::ProcessManagement::ActivityDialog->new(%Param);
    $Self->{TransitionActionObject}
        = Kernel::System::ProcessManagement::TransitionAction->new(%Param);
    $Self->{TransitionObject}   = Kernel::System::ProcessManagement::Transition->new(%Param);
    $Self->{DynamicFieldObject} = Kernel::System::DynamicField->new(%Param);
    $Self->{BackendObject}      = Kernel::System::DynamicField::Backend->new(%Param);
    $Self->{ProcessObject}      = Kernel::System::ProcessManagement::Process->new(
        ActivityObject         => $Self->{ActivityObject},
        ActivityDialogObject   => $Self->{ActivityDialogObject},
        TransitionObject       => $Self->{TransitionObject},
        TransitionActionObject => $Self->{TransitionActionObject},
        %Param,
    );
    $Self->{CustomerUserObject} = Kernel::System::CustomerUser->new(%Param);
    $Self->{TypeObject}         = Kernel::System::Type->new(%Param);
    $Self->{DynamicField}       = $Self->{DynamicFieldObject}->DynamicFieldListGet(
        Valid      => 1,
        ObjectType => 'Ticket',
    );

    # reduce the dynamic fields to only the ones that are desinged for customer interface
    my @CustomerDynamicFields;
    DYNAMICFIELD:
    for my $DynamicFieldConfig ( @{ $Self->{DynamicField} } ) {
        next DYNAMICFIELD if !IsHashRefWithData($DynamicFieldConfig);

        my $IsCustomerInterfaceCapable = $Self->{BackendObject}->HasBehavior(
            DynamicFieldConfig => $DynamicFieldConfig,
            Behavior           => 'IsCustomerInterfaceCapable',
        );
        next DYNAMICFIELD if !$IsCustomerInterfaceCapable;

        push @CustomerDynamicFields, $DynamicFieldConfig;
    }
    $Self->{DynamicField} = \@CustomerDynamicFields;

    # global config hash for id dissolution
    $Self->{NameToID} = {
        Title          => 'Title',
        State          => 'StateID',
        StateID        => 'StateID',
        Lock           => 'LockID',
        LockID         => 'LockID',
        Priority       => 'PriorityID',
        PriorityID     => 'PriorityID',
        Queue          => 'QueueID',
        QueueID        => 'QueueID',
        Customer       => 'CustomerID',
        CustomerID     => 'CustomerID',
        CustomerNo     => 'CustomerID',
        CustomerUserID => 'CustomerUserID',
        Type           => 'TypeID',
        TypeID         => 'TypeID',
        SLA            => 'SLAID',
        SLAID          => 'SLAID',
        Service        => 'ServiceID',
        ServiceID      => 'ServiceID',
        Article        => 'Article',
    };

    # some fields should be skipped for the customer interface
    $Self->{SkipFields} = [ 'Owner', 'Responsible', 'Lock', 'PendingTime', 'CustomerID' ];

    return $Self;
}

sub Run {
    my ( $Self, %Param ) = @_;

    my $TicketID = $Self->{ParamObject}->GetParam( Param => 'TicketID' );
    my $ActivityDialogEntityID
        = $Self->{ParamObject}->GetParam( Param => 'ActivityDialogEntityID' );
    my $ActivityDialogHashRef;

    if ($TicketID) {

        # include extra fields should be skipped
        for my $Item (qw(Service SLA Queue)) {
            push @{ $Self->{SkipFields} }, $Item;
        }

        # check if there is a configured required permission
        # for the ActivityDialog (if there is one)
        my $ActivityDialogPermission = 'rw';
        if ($ActivityDialogEntityID) {
            $ActivityDialogHashRef
                = $Self->{ActivityDialogObject}->ActivityDialogGet(
                ActivityDialogEntityID => $ActivityDialogEntityID,
                Interface              => 'CustomerInterface',
                );

            if ( !IsHashRefWithData($ActivityDialogHashRef) ) {
                return $Self->{LayoutObject}->CustomerErrorScreen(
                    Message => "Couldn't get ActivityDialogEntityID '$ActivityDialogEntityID'!",
                    Comment => 'Please contact the admin.',
                );
            }

            if ( $ActivityDialogHashRef->{Permission} ) {
                $ActivityDialogPermission = $ActivityDialogHashRef->{Permission};
            }
        }

        # check permissions
        my $Access = $Self->{TicketObject}->TicketCustomerPermission(
            Type     => $ActivityDialogPermission,
            TicketID => $Self->{TicketID},
            UserID   => $Self->{UserID}
        );

        # error screen, don't show ticket
        if ( !$Access ) {
            return $Self->{LayoutObject}->CustomerNoPermission(
                Message    => "You need $ActivityDialogPermission permissions!",
                WithHeader => 'yes',
            );
        }

        # get ACL restrictions
        $Self->{TicketObject}->TicketAcl(
            Data           => '-',
            TicketID       => $TicketID,
            ReturnType     => 'Action',
            ReturnSubType  => '-',
            CustomerUserID => $Self->{UserID},
        );
        my %AclAction = $Self->{TicketObject}->TicketAclActionData();

        # check if ACL resctictions if exist
        if ( IsHashRefWithData( \%AclAction ) ) {

            # show error screen if ACL prohibits this action
            if ( defined $AclAction{ $Self->{Action} } && $AclAction{ $Self->{Action} } eq '0' ) {
                return $Self->{LayoutObject}->CustomerNoPermission( WithHeader => 'yes' );
            }
        }
        if ( IsHashRefWithData($ActivityDialogHashRef) ) {

            # get ACL restrictions
            $Self->{TicketObject}->TicketAcl(
                Data                   => '-',
                ActivityDialogEntityID => $ActivityDialogEntityID,
                TicketID               => $TicketID,
                ReturnType             => 'Ticket',
                ReturnSubType          => '-',
                CustomerUserID         => $Self->{UserID},
            );

            my @PossibleActivityDialogs = $Self->{TicketObject}
                ->TicketAclActivityDialogData( ActivityDialogs => [ $ActivityDialogEntityID, ] );

            # check if ACL resctictions exist
            if (
                !$PossibleActivityDialogs[0]
                || $PossibleActivityDialogs[0] ne $ActivityDialogEntityID
                )
            {
                return $Self->{LayoutObject}->CustomerNoPermission( WithHeader => 'yes' );
            }
        }
    }

    # list only Active processes by default
    my @ProcessStates = ('Active');

    # set AJAXDialog for proper error responses, screen display and process list
    $Self->{AJAXDialog} = $Self->{ParamObject}->GetParam( Param => 'AJAXDialog' ) || '';

    # fetch also FadeAway processes to continue working with existing tickets, but not to start new
    #    ones
    if ( !$Self->{AJAXDialog} && $Self->{Subaction} ) {
        push @ProcessStates, 'FadeAway'
    }

    # get the list of processes that customer can start
    my $ProcessList = $Self->{ProcessObject}->ProcessList(
        ProcessState => \@ProcessStates,
        Interface    => ['CustomerInterface'],
    );

    # also get the list of processes initiated by agents, as an activity dialog might be configured
    # for the customer interface
    my $FollowupProcessList = $Self->{ProcessObject}->ProcessList(
        ProcessState => \@ProcessStates,
        Interface => [ 'AgentInterface', 'CustomerInterface' ],
    );

    my $ProcessEntityID = $Self->{ParamObject}->GetParam( Param => 'ProcessEntityID' );

    if ( !IsHashRefWithData($ProcessList) && !IsHashRefWithData($FollowupProcessList) ) {
        return $Self->{LayoutObject}->CustomerErrorScreen(
            Message => 'No Process configured!',
            Comment => 'Please contact the admin.',
        );
    }

    # validate the ProcessList with stored acls
    $Self->{TicketObject}->TicketAcl(
        ReturnType     => 'Ticket',
        ReturnSubType  => '-',
        Data           => $ProcessList,
        CustomerUserID => $Self->{UserID},
    );

    if ( IsHashRefWithData($ProcessList) ) {
        $ProcessList = $Self->{TicketObject}->TicketAclProcessData(
            Processes => $ProcessList,
        );
    }

    $Self->{TicketObject}->TicketAcl(
        ReturnType     => 'Ticket',
        ReturnSubType  => '-',
        Data           => $FollowupProcessList,
        CustomerUserID => $Self->{UserID},
    );

    if ( IsHashRefWithData($FollowupProcessList) ) {
        $FollowupProcessList = $Self->{TicketObject}->TicketAclProcessData(
            Processes => $FollowupProcessList,
        );
    }

    # set AJAXDialog for proper error responses and screen display
    $Self->{AJAXDialog} = $Self->{ParamObject}->GetParam( Param => 'AJAXDialog' ) || '';

    # if we have no subaction display the process list to start a new one
    if ( !$Self->{Subaction} ) {

        # to display the process list is mandatory to have processes that customer can start
        if ( !IsHashRefWithData($ProcessList) ) {
            return $Self->{LayoutObject}->CustomerErrorScreen(
                Message => 'No Process configured!',
                Comment => 'Please contact the admin.',
            );
        }

        return $Self->_DisplayProcessList(
            %Param,
            ProcessList     => $ProcessList,
            ProcessEntityID => $ProcessEntityID
        );
    }

    # check if the selected process from the list is valid, prevent tamper with process selection
    #    list (not existing, invalid an fade away processes must not be able to start a new process
    #    ticket)
    elsif (
        $Self->{Subaction} eq 'DisplayActivityDialogAJAX'
        && !$ProcessList->{$ProcessEntityID}
        && $Self->{AJAXDialog}
        )
    {

        # translate the error message (as it will be injected in the HTML)
        my $ErrorMessage
            = $Self->{LayoutObject}->{LanguageObject}
            ->Translate("The selected process is invalid!");

        # return a predefined HTML sctructure as the AJAX call is expecting and HTML response
        return $Self->{LayoutObject}->Attachment(
            ContentType => 'text/html; charset=' . $Self->{LayoutObject}->{Charset},
            Content     => '<div class="ServerError" data-message="' . $ErrorMessage . '"></div>',
            Type        => 'inline',
            NoCache     => 1,
        );
    }

    # if invalid process is detected on a ActivityDilog popup screen show an error message
    elsif (
        $Self->{Subaction} eq 'DisplayActivityDialog'
        && !$FollowupProcessList->{$ProcessEntityID}
        && !$Self->{AJAXDialog}
        )
    {
        $Self->{LayoutObject}->CustomerFatalError(
            Message => "Process $ProcessEntityID is invalid!",
            Comment => 'Please contact the admin.',
        );
    }

    # Get the necessary parameters
    # collects a mixture of present values bottom to top:
    # SysConfig DefaultValues, ActivityDialog DefaultValues, TicketValues, SubmittedValues
    # including ActivityDialogEntityID and ProcessEntityID
    # is used for:
    # - Parameter checking before storing
    # - will be used for ACL checking later on
    my $GetParam = $Self->_GetParam(
        ProcessEntityID => $ProcessEntityID,
    );

    # get form id
    $Self->{FormID} = $Self->{ParamObject}->GetParam( Param => 'FormID' );

    # create form id
    if ( !$Self->{FormID} ) {
        $Self->{FormID} = $Self->{UploadCacheObject}->FormIDCreate();
    }

    if ( $Self->{Subaction} eq 'StoreActivityDialog' && $ProcessEntityID ) {
        $Self->{LayoutObject}->ChallengeTokenCheck( Type => 'Customer' );

        return $Self->_StoreActivityDialog(
            %Param,
            ProcessName     => $ProcessList->{$ProcessEntityID},
            ProcessEntityID => $ProcessEntityID,
            GetParam        => $GetParam,
        );
    }
    if ( $Self->{Subaction} eq 'DisplayActivityDialog' && $ProcessEntityID ) {

        return $Self->_OutputActivityDialog(
            %Param,
            ProcessEntityID => $ProcessEntityID,
            GetParam        => $GetParam,
        );
    }
    if ( $Self->{Subaction} eq 'DisplayActivityDialogAJAX' && $ProcessEntityID ) {

        my $ActivityDialogHTML = $Self->_OutputActivityDialog(
            %Param,
            ProcessEntityID => $ProcessEntityID,
            GetParam        => $GetParam,
        );
        return $Self->{LayoutObject}->Attachment(
            ContentType => 'text/html; charset=' . $Self->{LayoutObject}->{Charset},
            Content     => $ActivityDialogHTML,
            Type        => 'inline',
            NoCache     => 1,
        );

    }
    elsif ( $Self->{Subaction} eq 'AJAXUpdate' ) {

        return $Self->_RenderAjax(
            %Param,
            ProcessEntityID => $ProcessEntityID,
            GetParam        => $GetParam,
        );
    }
    return $Self->{LayoutObject}->CustomerErrorScreen(
        Message => 'Subacion is invalid!',
        Comment => 'Please contact the admin.',
    );
}

sub _RenderAjax {

    # FatalError is safe because a JSON strcuture is expecting, then it will result into a
    # communications error

    my ( $Self, %Param ) = @_;
    for my $Needed (qw(ProcessEntityID)) {
        if ( !$Param{$Needed} ) {
            $Self->{LayoutObject}
                ->CustomerFatalError( Message => "Got no $Needed in _RenderAjax!" );
        }
    }
    my $ActivityDialogEntityID = $Param{GetParam}{ActivityDialogEntityID};
    if ( !$ActivityDialogEntityID ) {
        $Self->{LayoutObject}->CustomerFatalError(
            Message => "Got no ActivityDialogEntityID in _RenderAjax!"
        );
    }
    my $ActivityDialog = $Self->{ActivityDialogObject}->ActivityDialogGet(
        ActivityDialogEntityID => $ActivityDialogEntityID,
        Interface              => 'CustomerInterface',
    );

    if ( !IsHashRefWithData($ActivityDialog) ) {
        $Self->{LayoutObject}->CustomerFatalError(
            Message => "No ActivityDialog configured for $ActivityDialogEntityID in _RenderAjax!"
        );
    }

    # get list type
    my $TreeView = 0;
    if ( $Self->{ConfigObject}->Get('Ticket::Frontend::ListType') eq 'tree' ) {
        $TreeView = 1;
    }

    my %FieldsProcessed;
    my @JSONCollector;

    my $Services;

    # All submitted DynamicFields
    # get dynamic field values form http request
    my %DynamicFieldValues;

    # cycle trough the activated Dynamic Fields for this screen
    DYNAMICFIELD:
    for my $DynamicFieldConfig ( @{ $Self->{DynamicField} } ) {
        next DYNAMICFIELD if !IsHashRefWithData($DynamicFieldConfig);

        # extract the dynamic field value form the web request
        $DynamicFieldValues{ $DynamicFieldConfig->{Name} }
            = $Self->{BackendObject}->EditFieldValueGet(
            DynamicFieldConfig => $DynamicFieldConfig,
            ParamObject        => $Self->{ParamObject},
            LayoutObject       => $Self->{LayoutObject},
            );
    }

    # convert dynamic field values into a structure for ACLs
    my %DynamicFieldCheckParam;
    DYNAMICFIELD:
    for my $DynamicField ( sort keys %DynamicFieldValues ) {
        next DYNAMICFIELD if !$DynamicField;
        next DYNAMICFIELD if !$DynamicFieldValues{$DynamicField};

        $DynamicFieldCheckParam{ 'DynamicField_' . $DynamicField }
            = $DynamicFieldValues{$DynamicField};
    }

    # Get the activity dialog's Submit Param's or Config Params
    DIALOGFIELD:
    for my $CurrentField ( @{ $ActivityDialog->{FieldOrder} } ) {

        # some fields should be skipped for the customer interface
        next DIALOGFIELD if ( grep { $_ eq $CurrentField } @{ $Self->{SkipFields} } );

        # Skip if we're working on a field that was already done with or without ID
        if (
            $Self->{NameToID}{$CurrentField}
            && $FieldsProcessed{ $Self->{NameToID}{$CurrentField} }
            )
        {
            next DIALOGFIELD;
        }

        if ( $CurrentField =~ m{^DynamicField_(.*)}xms ) {
            my $DynamicFieldName = $1;

            my $DynamicFieldConfig
                = ( grep { $_->{Name} eq $DynamicFieldName } @{ $Self->{DynamicField} } )[0];

            next DIALOGFIELD if !IsHashRefWithData($DynamicFieldConfig);

            my $IsACLReducible = $Self->{BackendObject}->HasBehavior(
                DynamicFieldConfig => $DynamicFieldConfig,
                Behavior           => 'IsACLReducible',
            );
            next DIALOGFIELD if !$IsACLReducible;

            my $PossibleValues = $Self->{BackendObject}->PossibleValuesGet(
                DynamicFieldConfig => $DynamicFieldConfig,
            );
            my %DynamicFieldCheckParam = map { $_ => $Param{GetParam}{$_} }
                grep {m{^DynamicField_}xms} ( keys %{ $Param{GetParam} } );

            # convert possible values key => value to key => key for ACLs using a Hash slice
            my %AclData = %{$PossibleValues};
            @AclData{ keys %AclData } = keys %AclData;

            # set possible values filter from ACLs
            my $ACL = $Self->{TicketObject}->TicketAcl(
                %{ $Param{GetParam} },
                DynamicField   => \%DynamicFieldCheckParam,
                ReturnType     => 'Ticket',
                ReturnSubType  => 'DynamicField_' . $DynamicFieldConfig->{Name},
                Data           => \%AclData,
                CustomerUserID => $Self->{UserID},
            );

            if ($ACL) {
                my %Filter = $Self->{TicketObject}->TicketAclData();

                # convert Filer key => key back to key => value using map
                %{$PossibleValues} = map { $_ => $PossibleValues->{$_} } keys %Filter;
            }

            my $DataValues = $Self->{BackendObject}->BuildSelectionDataGet(
                DynamicFieldConfig => $DynamicFieldConfig,
                PossibleValues     => $PossibleValues,
                Value => $Param{GetParam}{ 'DynamicField_' . $DynamicFieldConfig->{Name} },
            ) || $PossibleValues;

            # add dynamic field to the JSONCollector
            push(
                @JSONCollector,
                {
                    Name        => 'DynamicField_' . $DynamicFieldConfig->{Name},
                    Data        => $DataValues,
                    SelectedID  => $DynamicFieldValues{ $DynamicFieldConfig->{Name} },
                    Translation => $DynamicFieldConfig->{Config}->{TranslatableValues} || 0,
                    Max         => 100,
                }
            );
        }
        elsif ( $Self->{NameToID}{$CurrentField} eq 'QueueID' ) {
            next DIALOGFIELD if $FieldsProcessed{ $Self->{NameToID}{$CurrentField} };

            my $Data = $Self->_GetQueues(
                %{ $Param{GetParam} },
            );

            # add Queue to the JSONCollector
            push(
                @JSONCollector,
                {
                    Name         => $Self->{NameToID}{$CurrentField},
                    Data         => $Data,
                    SelectedID   => $Param{GetParam}{ $Self->{NameToID}{$CurrentField} },
                    PossibleNone => 1,
                    Translation  => 0,
                    TreeView     => $TreeView,
                    Max          => 100,
                },
            );
            $FieldsProcessed{ $Self->{NameToID}{$CurrentField} } = 1;
        }

        elsif ( $Self->{NameToID}{$CurrentField} eq 'StateID' ) {
            next DIALOGFIELD if $FieldsProcessed{ $Self->{NameToID}{$CurrentField} };

            my $Data = $Self->_GetStates(
                %{ $Param{GetParam} },
            );

            # add State to the JSONCollector
            push(
                @JSONCollector,
                {
                    Name        => 'StateID',
                    Data        => $Data,
                    SelectedID  => $Param{GetParam}{ $Self->{NameToID}{$CurrentField} },
                    Translation => 1,
                    Max         => 100,
                },
            );
            $FieldsProcessed{ $Self->{NameToID}{$CurrentField} } = 1;
        }
        elsif ( $Self->{NameToID}{$CurrentField} eq 'PriorityID' ) {
            next DIALOGFIELD if $FieldsProcessed{ $Self->{NameToID}{$CurrentField} };

            my $Data = $Self->_GetPriorities(
                %{ $Param{GetParam} },
            );

            # add Priority to the JSONCollector
            push(
                @JSONCollector,
                {
                    Name        => $Self->{NameToID}{$CurrentField},
                    Data        => $Data,
                    SelectedID  => $Param{GetParam}{ $Self->{NameToID}{$CurrentField} },
                    Translation => 1,
                    Max         => 100,
                },
            );
            $FieldsProcessed{ $Self->{NameToID}{$CurrentField} } = 1;
        }
        elsif ( $Self->{NameToID}{$CurrentField} eq 'ServiceID' ) {
            next DIALOGFIELD if $FieldsProcessed{ $Self->{NameToID}{$CurrentField} };

            my $Data = $Self->_GetServices(
                %{ $Param{GetParam} },
            );
            $Services = $Data;

            # add Service to the JSONCollector (Use ServiceID from web request)
            push(
                @JSONCollector,
                {
                    Name         => $Self->{NameToID}{$CurrentField},
                    Data         => $Data,
                    SelectedID   => $Self->{ParamObject}->GetParam( Param => 'ServiceID' ) || '',
                    PossibleNone => 1,
                    Translation  => 0,
                    TreeView     => $TreeView,
                    Max          => 100,
                },
            );
            $FieldsProcessed{ $Self->{NameToID}{$CurrentField} } = 1;
        }
        elsif ( $Self->{NameToID}{$CurrentField} eq 'SLAID' ) {
            next DIALOGFIELD if $FieldsProcessed{ $Self->{NameToID}{$CurrentField} };

            # if SLA is render before service (by it order in the fields) it needs to create
            # the service list
            if ( !IsHashRefWithData($Services) ) {
                $Services = $Self->_GetServices(
                    %{ $Param{GetParam} },
                );
            }

            my $Data = $Self->_GetSLAs(
                %{ $Param{GetParam} },
                Services => $Services,
                ServiceID => $Self->{ParamObject}->GetParam( Param => 'ServiceID' ) || '',
            );

            # add SLA to the JSONCollector (Use SelectedID from web request)
            push(
                @JSONCollector,
                {
                    Name         => $Self->{NameToID}{$CurrentField},
                    Data         => $Data,
                    SelectedID   => $Self->{ParamObject}->GetParam( Param => 'SLAID' ) || '',
                    PossibleNone => 1,
                    Translation  => 0,
                    Max          => 100,
                },
            );
            $FieldsProcessed{ $Self->{NameToID}{$CurrentField} } = 1;
        }
    }

    my $JSON = $Self->{LayoutObject}->BuildSelectionJSON( [@JSONCollector] );

    return $Self->{LayoutObject}->Attachment(
        ContentType => 'application/json; charset=' . $Self->{LayoutObject}->{Charset},
        Content     => $JSON,
        Type        => 'inline',
        NoCache     => 1,
    );
}

=item _GetParam()

returns the current data state of the submitted information

This contains the following data for the different callers:

    Initial call with selected Process:
        ProcessEntityID
        ActivityDialogEntityID
        DefaultValues for the configured Fields in that ActivityDialog
        DefaultValues for the 4 required Fields Queue State Lock Priority

    First Store call submitting an Activity Dialog:
        ProcessEntityID
        ActivityDialogEntityID
        SubmittedValues for the current ActivityDialog
        ActivityDialog DefaultValues for invisible fields of that ActivityDialog
        DefaultValues for the 4 required Fields Queue State Lock Priority
            if not configured in the ActivityDialog

    ActivityDialog fillout request on existing Ticket:
        ProcessEntityID
        ActivityDialogEntityID
        TicketValues

    ActivityDialog store request or AjaxUpdate request on existing Tickets:
        ProcessEntityID
        ActivityDialogEntityID
        TicketValues for all not-Submitted Values
        Submitted Values

    my $GetParam = _GetParam(
        ProcessEntityID => $ProcessEntityID,
    );

=cut

sub _GetParam {
    my ( $Self, %Param ) = @_;

    #my $IsAJAXUpdate = $Param{AJAX} || '';

    for my $Needed (qw(ProcessEntityID)) {
        if ( !$Param{$Needed} ) {
            $Self->{LayoutObject}->CustomerFatalError( Message => "Got no $Needed in _GetParam!" );
        }
    }
    my %GetParam;
    my %Ticket;
    my $ProcessEntityID        = $Param{ProcessEntityID};
    my $TicketID               = $Self->{ParamObject}->GetParam( Param => 'TicketID' );
    my $ActivityDialogEntityID = $Self->{ParamObject}->GetParam(
        Param => 'ActivityDialogEntityID',
    );
    my $ActivityEntityID;
    my %ValuesGotten;
    my $Value;

    # If we got no ActivityDialogEntityID and no TicketID
    # we have to get the Processes' Startpoint
    if ( !$ActivityDialogEntityID && !$TicketID ) {
        my $ActivityActivityDialog = $Self->{ProcessObject}->ProcessStartpointGet(
            ProcessEntityID => $ProcessEntityID,
        );
        if (
            !$ActivityActivityDialog->{ActivityDialog}
            || !$ActivityActivityDialog->{Activity}
            )
        {
            my $Message = "Got no Start ActivityEntityID or Start ActivityDialogEntityID for"
                . " Process: $ProcessEntityID in _GetParam!";

            # does not show header and footer again
            if ( $Self->{AJAXDialog} ) {
                return $Self->{LayoutObject}->CustomerError(
                    Message => $Message,
                );
            }

            $Self->{LayoutObject}->CustomerFatalError(
                Message => $Message,
            );
        }
        $ActivityDialogEntityID = $ActivityActivityDialog->{ActivityDialog};
        $ActivityEntityID       = $ActivityActivityDialog->{Activity};
    }

    my $ActivityDialog = $Self->{ActivityDialogObject}->ActivityDialogGet(
        ActivityDialogEntityID => $ActivityDialogEntityID,
        Interface              => 'CustomerInterface',
    );

    if ( !IsHashRefWithData($ActivityDialog) ) {
        return $Self->{LayoutObject}->CustomerErrorScreen(
            Message => "Couldn't get ActivityDialogEntityID '$ActivityDialogEntityID'!",
            Comment => 'Please contact the admin.',
        );
    }

    # if there is a ticket then is not an AJAX request
    if ($TicketID) {
        %Ticket = $Self->{TicketObject}->TicketGet(
            TicketID      => $TicketID,
            UserID        => $Self->{ConfigObject}->Get('CustomerPanelUserID'),
            DynamicFields => 1,
        );

        %GetParam = %Ticket;
        if ( !IsHashRefWithData( \%GetParam ) ) {
            $Self->{LayoutObject}->CustomerFatalError(
                Message => "Couldn't get Ticket for TicketID: $TicketID in _GetParam!",
            );
        }

        $ActivityEntityID = $Ticket{
            'DynamicField_'
                . $Self->{ConfigObject}->Get("Process::DynamicFieldProcessManagementActivityID")
        };
        if ( !$ActivityEntityID ) {
            $Self->{LayoutObject}->CustomerFatalError(
                Message =>
                    "Couldn't determine ActivityEntityID. DynamicField or Config isn't set properly!",
            );
        }

    }
    $GetParam{ActivityDialogEntityID} = $ActivityDialogEntityID;
    $GetParam{ActivityEntityID}       = $ActivityEntityID;
    $GetParam{ProcessEntityID}        = $ProcessEntityID;

    # Get the activitydialogs's Submit Param's or Config Params
    DIALOGFIELD:
    for my $CurrentField ( @{ $ActivityDialog->{FieldOrder} } ) {

        # some fields should be skipped for the customer interface
        next DIALOGFIELD if ( grep { $_ eq $CurrentField } @{ $Self->{SkipFields} } );

        # Skip if we're working on a field that was already done with or without ID
        if ( $Self->{NameToID}{$CurrentField} && $ValuesGotten{ $Self->{NameToID}{$CurrentField} } )
        {
            next DIALOGFIELD;
        }

        if ( $CurrentField =~ m{^DynamicField_(.*)}xms ) {
            my $DynamicFieldName = $1;

           # Get the Config of the current DynamicField (the first element of the grep result array)
            my $DynamicFieldConfig
                = ( grep { $_->{Name} eq $DynamicFieldName } @{ $Self->{DynamicField} } )[0];

            if ( !IsHashRefWithData($DynamicFieldConfig) ) {
                my $Message = "DynamicFieldConfig missing for field: $DynamicFieldName!";

                # does not show header and footer again
                if ( $Self->{AJAXDialog} ) {
                    return $Self->{LayoutObject}->CustomerError(
                        Message => $Message,
                    );
                }

                $Self->{LayoutObject}->CustomerFatalError(
                    Message => $Message,
                );
            }

            # Get DynamicField Values
            $Value = $Self->{BackendObject}->EditFieldValueGet(
                DynamicFieldConfig => $DynamicFieldConfig,
                ParamObject        => $Self->{ParamObject},
                LayoutObject       => $Self->{LayoutObject},
            );

            # If we got a submitted param, take it and next out
            if (
                defined $Value
                && (
                    $Value eq ''
                    || IsStringWithData($Value)
                    || IsArrayRefWithData($Value)
                    || IsHashRefWithData($Value)
                )
                )
            {
                $GetParam{$CurrentField} = $Value;
                next DIALOGFIELD;
            }

            # If we didn't have a Param Value try the ticket Value
            # next out if it was successful
            if (
                defined $Ticket{$CurrentField}
                && (
                    $Ticket{$CurrentField} eq ''
                    || IsStringWithData( $Ticket{$CurrentField} )
                    || IsArrayRefWithData( $Ticket{$CurrentField} )
                    || IsHashRefWithData( $Ticket{$CurrentField} )
                )
                )
            {
                $GetParam{$CurrentField} = $Ticket{$CurrentField};
                next DIALOGFIELD;
            }

            # If we had neighter submitted nor ticket param get the ActivityDialog's default Value
            # next out if it was successful
            $Value = $ActivityDialog->{Fields}{$CurrentField}{DefaultValue};
            if ($Value) {
                $GetParam{$CurrentField} = $Value;
                next DIALOGFIELD;
            }

            # If we had no submitted, ticket or ActivityDialog default value
            # use the DynamicField's default value and next out
            $Value = $DynamicFieldConfig->{Config}{DefaultValue};
            if ($Value) {
                $GetParam{$CurrentField} = $Value;
                next DIALOGFIELD;
            }

            # if all that failed then the field should not have a defined value otherwise
            # if a value (even empty) is sent, fields like Date or DateTime will mark the field as
            # used with the field display value, this could lead to unwanted field sets,
            # see bug#9159
            next DIALOGFIELD;
        }

        # get article fields
        if ( $CurrentField eq 'Article' ) {

            $GetParam{Subject} = $Self->{ParamObject}->GetParam( Param => 'Subject' );
            $GetParam{Body}    = $Self->{ParamObject}->GetParam( Param => 'Body' );
            @{ $GetParam{InformUserID} } = $Self->{ParamObject}->GetArray(
                Param => 'InformUserID',
            );

            $ValuesGotten{Article} = 1 if ( $GetParam{Subject} && $GetParam{Body} );
        }

        if ( $CurrentField eq 'CustomerID' ) {
            $GetParam{Customer} = $Self->{ParamObject}->GetParam(
                Param => 'SelectedCustomerUser',
            ) || '';
            $GetParam{CustomerUserID} = $Self->{ParamObject}->GetParam(
                Param => 'SelectedCustomerUser',
            ) || '';
        }

        # Non DynamicFields
        # 1. try to get the required param
        my $Value = $Self->{ParamObject}->GetParam( Param => $Self->{NameToID}{$CurrentField} );

        if ($Value) {

            # if we have an ID field make sure the value without ID won't be in the
            # %GetParam Hash any more
            if ( $Self->{NameToID}{$CurrentField} =~ m{(.*)ID$}xms ) {
                $GetParam{$1} = undef;
            }
            $GetParam{ $Self->{NameToID}{$CurrentField} }     = $Value;
            $ValuesGotten{ $Self->{NameToID}{$CurrentField} } = 1;
            next DIALOGFIELD;
        }

        # If we got ticket params, the GetParam Hash was already filled before the loop
        # and we can next out
        if ( $GetParam{ $Self->{NameToID}{$CurrentField} } ) {
            $ValuesGotten{ $Self->{NameToID}{$CurrentField} } = 1;
            next DIALOGFIELD;
        }

        # if no Submitted nore Ticket Param get ActivityDialog Config's Param
        if ( $CurrentField ne 'CustomerID' ) {
            $Value = $ActivityDialog->{Fields}{$CurrentField}{DefaultValue};
        }
        if ($Value) {
            $ValuesGotten{ $Self->{NameToID}{$CurrentField} } = 1;
            $GetParam{$CurrentField} = $Value;
            next DIALOGFIELD;
        }
    }
    REQUIREDFIELDLOOP:
    for my $CurrentField (qw(Queue State Lock Priority)) {
        $Value = undef;
        if ( !$ValuesGotten{ $Self->{NameToID}{$CurrentField} } ) {
            $Value = $Self->{ConfigObject}->Get("Process::Default$CurrentField");
            if ( !$Value ) {

                my $Message = "Process::Default$CurrentField Config Value missing!";

                # does not show header and footer again
                if ( $Self->{AJAXDialog} ) {
                    return $Self->{LayoutObject}->CustomerError(
                        Message => $Message,
                    );
                }

                $Self->{LayoutObject}->CustomerFatalError(
                    Message => $Message,
                );
            }
            $GetParam{$CurrentField} = $Value;
            $ValuesGotten{ $Self->{NameToID}{$CurrentField} } = 1;
        }
    }

    # get also the IDs for the Required files (if they are not present)
    if ( $GetParam{Queue} && !$GetParam{QueueID} ) {
        $GetParam{QueueID} = $Self->{QueueObject}->QueueLookup( Queue => $GetParam{Queue} );
    }
    if ( $GetParam{State} && !$GetParam{StateID} ) {
        $GetParam{StateID} = $Self->{StateObject}->StateLookup( State => $GetParam{State} );
    }
    if ( $GetParam{Lock} && !$GetParam{LockID} ) {
        $GetParam{LockID} = $Self->{LockObject}->LockLookup( Lock => $GetParam{Lock} );
    }
    if ( $GetParam{Priority} && !$GetParam{PriorityID} ) {
        $GetParam{PriorityID} = $Self->{PriorityObject}->PriorityLookup(
            Priority => $GetParam{Priority},
        );
    }

    # and finally we'll have the special parameters:
    $GetParam{ResponsibleAll} = $Self->{ParamObject}->GetParam( Param => 'ResponsibleAll' );
    $GetParam{OwnerAll}       = $Self->{ParamObject}->GetParam( Param => 'OwnerAll' );

    return \%GetParam;
}

sub _OutputActivityDialog {
    my ( $Self, %Param ) = @_;
    my $TicketID               = $Param{GetParam}{TicketID};
    my $ActivityDialogEntityID = $Param{GetParam}{ActivityDialogEntityID};

    # Check needed parameters:
    # ProcessEntityID only
    # TicketID ActivityDialogEntityID
    if ( !$Param{ProcessEntityID} || ( !$TicketID && !$ActivityDialogEntityID ) ) {
        my $Message = 'Got no ProcessEntityID or TicketID and ActivityDialogEntityID!';

        # does not show header and footer again
        if ( $Self->{AJAXDialog} ) {
            return $Self->{LayoutObject}->CustomerError(
                Message => $Message,
            );
        }

        $Self->{LayoutObject}->CustomerFatalError(
            Message => $Message,
        );
    }

    my $ActivityActivityDialog;
    my %Ticket;
    my %Error = ();

    # If we had Errors, we got an Errorhash
    %Error = %{ $Param{Error} } if ( IsHashRefWithData( $Param{Error} ) );

    if ( !$TicketID ) {
        $ActivityActivityDialog = $Self->{ProcessObject}->ProcessStartpointGet(
            ProcessEntityID => $Param{ProcessEntityID},
        );

        if ( !IsHashRefWithData($ActivityActivityDialog) ) {
            my $Message = "Can't get StartActivityDialog and StartActivityDialog for the"
                . " ProcessEntityID '$Param{ProcessEntityID}'!";

            # does not show header and footer again
            if ( $Self->{AJAXDialog} ) {
                return $Self->{LayoutObject}->CustomerError(
                    Message => $Message,
                );
            }

            $Self->{LayoutObject}->CustomerFatalError(
                Message => $Message,
            );
        }
    }
    else {

        # no AJAX update in this part
        %Ticket = $Self->{TicketObject}->TicketGet(
            TicketID      => $TicketID,
            UserID        => $Self->{ConfigObject}->Get('CustomerPanelUserID'),
            DynamicFields => 1,
        );

        if ( !IsHashRefWithData( \%Ticket ) ) {
            $Self->{LayoutObject}->CustomerFatalError(
                Message => "Can't get Ticket '$Param{TicketID}'!",
            );
        }

        my $DynamicFieldProcessID = 'DynamicField_'
            . $Self->{ConfigObject}->Get('Process::DynamicFieldProcessManagementProcessID');
        my $DynamicFieldActivityID
            = 'DynamicField_'
            . $Self->{ConfigObject}->Get('Process::DynamicFieldProcessManagementActivityID');

        if ( !$Ticket{$DynamicFieldProcessID} || !$Ticket{$DynamicFieldActivityID} ) {
            $Self->{LayoutObject}->CustomerFatalError(
                Message =>
                    "Can't get ProcessEntityID or ActivityEntityID for Ticket '$Param{TicketID}'!",
            );
        }

        $ActivityActivityDialog = {
            Activity       => $Ticket{$DynamicFieldActivityID},
            ActivityDialog => $ActivityDialogEntityID,
        };
    }

    my $Activity = $Self->{ActivityObject}->ActivityGet(
        Interface        => 'CustomerInterface',
        ActivityEntityID => $ActivityActivityDialog->{Activity}
    );
    if ( !$Activity ) {
        my $Message = "Can't get Activity configuration for ActivityEntityID"
            . " $ActivityActivityDialog->{Activity}!";

        # does not show header and footer again
        if ( $Self->{AJAXDialog} ) {
            return $Self->{LayoutObject}->CustomerError(
                Message => $Message,
            );
        }

        $Self->{LayoutObject}->CustomerFatalError(
            Message => $Message,
        );
    }

    my $ActivityDialog = $Self->{ActivityDialogObject}->ActivityDialogGet(
        ActivityDialogEntityID => $ActivityActivityDialog->{ActivityDialog},
        Interface              => 'CustomerInterface',
    );
    if ( !IsHashRefWithData($ActivityDialog) ) {
        my $Message = "Can't get ActivityDialog configuration for ActivityDialogEntityID"
            . " '$ActivityActivityDialog->{ActivityDialog}'!";

        # does not show header and footer again
        if ( $Self->{AJAXDialog} ) {
            return $Self->{LayoutObject}->CustomerError(
                Message => $Message,
            );
        }

        $Self->{LayoutObject}->CustomerFatalError(
            Message => $Message,
        );
    }

    # grep out Overwrites if defined on the Activity
    my @OverwriteActivityDialogNumber = grep {
        ref $Activity->{ActivityDialog}{$_} eq 'HASH'
            && $Activity->{ActivityDialog}{$_}{ActivityDialogEntityID}
            && $Activity->{ActivityDialog}{$_}{ActivityDialogEntityID} eq
            $ActivityActivityDialog->{ActivityDialog}
            && IsHashRefWithData( $Activity->{ActivityDialog}{$_}{Overwrite} )
    } keys %{ $Activity->{ActivityDialog} };

    # let the Overwrites Overwrite the ActivityDialog's Hashvalues
    if ( $OverwriteActivityDialogNumber[0] ) {
        %{$ActivityDialog} = (
            %{$ActivityDialog},
            %{ $Activity->{ActivityDialog}{ $OverwriteActivityDialogNumber[0] }{Overwrite} }
        );
    }

    # Add PageHeader, Navbar, Formheader (Process/ActivityDialogHeader)
    my $Output;
    my $MainBoxClass;

    if ( !$Self->{AJAXDialog} ) {
        $Output = $Self->{LayoutObject}->CustomerHeader(
            Type  => 'Small',
            Value => $Ticket{Number},
        );

        # display given notify messages if this is not an ajax request
        if ( IsArrayRefWithData( $Param{Notify} ) ) {

            for my $NotifyString ( @{ $Param{Notify} } ) {
                $Output .= $Self->{LayoutObject}->Notify(
                    Data => $NotifyString,
                );
            }
        }

        $Self->{LayoutObject}->Block(
            Name => 'Header',
            Data => {
                Name =>
                    $Self->{LayoutObject}->{LanguageObject}->Translate( $ActivityDialog->{Name} )
                    || '',
                }
        );
    }
    elsif ( $Self->{AJAXDialog} && IsHashRefWithData( \%Error ) ) {

        # add rich text editor
        if ( $Self->{LayoutObject}->{BrowserRichText} ) {

            # use height/width defined for this screen
            $Param{RichTextHeight} = $Self->{Config}->{RichTextHeight} || 0;
            $Param{RichTextWidth}  = $Self->{Config}->{RichTextWidth}  || 0;

            $Self->{LayoutObject}->Block(
                Name => 'RichText',
                Data => \%Param,
            );
        }

        # display complete header and nav bar in ajax dialogs when there is a server error
        $Output = $Self->{LayoutObject}->CustomerHeader();
        $Output .= $Self->{LayoutObject}->CustomerNavigationBar();

        # display original header texts (the process list maybe is not necessary)
        $Output .= $Self->{LayoutObject}->Output(
            TemplateFile => 'CustomerTicketProcess',
            Data         => {},
        );

        # set the MainBox class to add correct borders to the screen
        $MainBoxClass = 'MainBox';
    }

    # display process iformation
    if ( $Self->{AJAXDialog} ) {

        # get process data
        my $Process = $Self->{ProcessObject}->ProcessGet(
            ProcessEntityID => $Param{ProcessEntityID},
        );

        # output main process information
        $Self->{LayoutObject}->Block(
            Name => 'ProcessInfoSidebar',
            Data => {
                Process        => $Process->{Name}        || '',
                Activity       => $Activity->{Name}       || '',
                ActivityDialog => $ActivityDialog->{Name} || '',
            },
        );

        # output activity dilalog short description (if any)
        if (
            defined $ActivityDialog->{DescriptionShort}
            && $ActivityDialog->{DescriptionShort} ne ''
            )
        {
            $Self->{LayoutObject}->Block(
                Name => 'ProcessInfoSidebarActivityDialogDesc',
                Data => {
                    ActivityDialogDescription => $ActivityDialog->{DescriptionShort} || '',
                },
            );
        }
    }

    # show descriptions
    if ( $ActivityDialog->{DescriptionShort} ) {
        $Self->{LayoutObject}->Block(
            Name => 'DescriptionShort',
            Data => {
                DescriptionShort
                    => $Self->{LayoutObject}->{LanguageObject}->Translate(
                    $ActivityDialog->{DescriptionShort},
                    ),
            },
        );
    }
    if ( $ActivityDialog->{DescriptionLong} ) {
        $Self->{LayoutObject}->Block(
            Name => 'DescriptionLong',
            Data => {
                DescriptionLong
                    => $Self->{LayoutObject}->{LanguageObject}->Translate(
                    $ActivityDialog->{DescriptionLong},
                    ),
            },
        );
    }

    # show close & cancel link if neccessary
    if ( !$Self->{AJAXDialog} ) {
        if ( $Param{RenderLocked} ) {
            $Self->{LayoutObject}->Block(
                Name => 'PropertiesLock',
                Data => {
                    %Param,
                    TicketID => $TicketID,
                },
            );
        }
        else {
            $Self->{LayoutObject}->Block(
                Name => 'CancelLink',
            );
        }
    }

    $Output .= $Self->{LayoutObject}->Output(
        TemplateFile => 'ProcessManagement/CustomerActivityDialogHeader',
        Data         => {
            FormName  => 'ActivityDialogDialog' . $ActivityActivityDialog->{ActivityDialog},
            FormID    => $Self->{FormID},
            Subaction => 'StoreActivityDialog',
            TicketID  => $Ticket{TicketID} || '',
            ActivityDialogEntityID => $ActivityActivityDialog->{ActivityDialog},
            ProcessEntityID        => $Param{ProcessEntityID}
                || $Ticket{
                'DynamicField_'
                    . $Self->{ConfigObject}->Get(
                    'Process::DynamicFieldProcessManagementProcessID'
                    )
                },
            AJAXDialog => $Self->{AJAXDialog},
            MainBoxClass => $MainBoxClass || '',
        },
    );

    my %RenderedFields = ();

    # get the list of fields where the AJAX loader icon should appear on AJAX updates triggered
    # by ActivityDialog fields
    my $AJAXUpdatableFields = $Self->_GetAJAXUpdatableFields(
        ActivityDialogFields => $ActivityDialog->{Fields},
    );

    # Loop through ActivityDialogFields and render their output
    DIALOGFIELD:
    for my $CurrentField ( @{ $ActivityDialog->{FieldOrder} } ) {

        # some fields should be skipped for the customer interface
        next DIALOGFIELD if ( grep { $_ eq $CurrentField } @{ $Self->{SkipFields} } );

        if ( !IsHashRefWithData( $ActivityDialog->{Fields}{$CurrentField} ) ) {
            my $Message = "Can't get data for Field '$CurrentField' of ActivityDialog"
                . " '$ActivityActivityDialog->{ActivityDialog}'!";

            # does not show header and footer again
            if ( $Self->{AJAXDialog} ) {
                return $Self->{LayoutObject}->CustomerError(
                    Message => $Message,
                );
            }

            $Self->{LayoutObject}->CustomerFatalError(
                Message => $Message,
            );
        }

        my %FieldData = %{ $ActivityDialog->{Fields}{$CurrentField} };

        # We render just visible ActivityDialogFields
        next DIALOGFIELD if !$FieldData{Display};

        # render DynamicFields
        if ( $CurrentField =~ m{^DynamicField_(.*)}xms ) {
            my $DynamicFieldName = $1;
            my $Response         = $Self->_RenderDynamicField(
                ActivityDialogField => $ActivityDialog->{Fields}{$CurrentField},
                FieldName           => $DynamicFieldName,
                DescriptionShort    => $ActivityDialog->{Fields}{$CurrentField}{DescriptionShort},
                Ticket              => \%Ticket || {},
                Error               => \%Error || {},
                FormID              => $Self->{FormID},
                GetParam            => $Param{GetParam},
                AJAXUpdatableFields => $AJAXUpdatableFields,
            );

            if ( !$Response->{Success} ) {

                # does not show header and footer again
                if ( $Self->{AJAXDialog} ) {
                    return $Self->{LayoutObject}->CustomerError(
                        Message => $Response->{Message},
                    );
                }

                $Self->{LayoutObject}->CustomerFatalError(
                    Message => $Response->{Message},
                );
            }

            $Output .= $Response->{HTML};

            $RenderedFields{$CurrentField} = 1;

        }

        # render State
        elsif ( $Self->{NameToID}->{$CurrentField} eq 'StateID' )
        {

            # We don't render Fields twice,
            # if there was already a Config without ID, skip this field
            # next DIALOGFIELD if $RenderedFields{ $Self->{NameToID}->{$CurrentField} };

            my $Response = $Self->_RenderState(
                ActivityDialogField => $ActivityDialog->{Fields}{$CurrentField},
                FieldName           => $CurrentField,
                DescriptionShort    => $ActivityDialog->{Fields}{$CurrentField}{DescriptionShort},
                Ticket              => \%Ticket || {},
                Error               => \%Error || {},
                FormID              => $Self->{FormID},
                GetParam            => $Param{GetParam},
                AJAXUpdatableFields => $AJAXUpdatableFields,
            );

            if ( !$Response->{Success} ) {

                # does not show header and footer again
                if ( $Self->{AJAXDialog} ) {
                    return $Self->{LayoutObject}->CustomerError(
                        Message => $Response->{Message},
                    );
                }

                $Self->{LayoutObject}->CustomerFatalError(
                    Message => $Response->{Message},
                );
            }

            $Output .= $Response->{HTML};

            $RenderedFields{ $Self->{NameToID}->{$CurrentField} } = 1;
        }

        # render Queue
        elsif ( $Self->{NameToID}->{$CurrentField} eq 'QueueID' )
        {
            next DIALOGFIELD if $RenderedFields{ $Self->{NameToID}->{$CurrentField} };

            my $Response = $Self->_RenderQueue(
                ActivityDialogField => $ActivityDialog->{Fields}{$CurrentField},
                FieldName           => $CurrentField,
                DescriptionShort    => $ActivityDialog->{Fields}{$CurrentField}{DescriptionShort},
                Ticket              => \%Ticket || {},
                Error               => \%Error || {},
                FormID              => $Self->{FormID},
                GetParam            => $Param{GetParam},
                AJAXUpdatableFields => $AJAXUpdatableFields,
            );

            if ( !$Response->{Success} ) {

                # does not show header and footer again
                if ( $Self->{AJAXDialog} ) {
                    return $Self->{LayoutObject}->CustomerError(
                        Message => $Response->{Message},
                    );
                }

                $Self->{LayoutObject}->CustomerFatalError(
                    Message => $Response->{Message},
                );
            }

            $Output .= $Response->{HTML};

            $RenderedFields{ $Self->{NameToID}->{$CurrentField} } = 1;
        }

        # render Priority
        elsif ( $Self->{NameToID}->{$CurrentField} eq 'PriorityID' )
        {
            next DIALOGFIELD if $RenderedFields{ $Self->{NameToID}->{$CurrentField} };

            my $Response = $Self->_RenderPriority(
                ActivityDialogField => $ActivityDialog->{Fields}{$CurrentField},
                FieldName           => $CurrentField,
                DescriptionShort    => $ActivityDialog->{Fields}{$CurrentField}{DescriptionShort},
                Ticket              => \%Ticket || {},
                Error               => \%Error || {},
                FormID              => $Self->{FormID},
                GetParam            => $Param{GetParam},
                AJAXUpdatableFields => $AJAXUpdatableFields,
            );

            if ( !$Response->{Success} ) {

                # does not show header and footer again
                if ( $Self->{AJAXDialog} ) {
                    return $Self->{LayoutObject}->CustomerError(
                        Message => $Response->{Message},
                    );
                }

                $Self->{LayoutObject}->CustomerFatalError(
                    Message => $Response->{Message},
                );
            }

            $Output .= $Response->{HTML};

            $RenderedFields{ $Self->{NameToID}->{$CurrentField} } = 1;
        }

        # render Service
        elsif ( $Self->{NameToID}->{$CurrentField} eq 'ServiceID' )
        {
            next DIALOGFIELD if $RenderedFields{ $Self->{NameToID}->{$CurrentField} };

            my $Response = $Self->_RenderService(
                ActivityDialogField => $ActivityDialog->{Fields}{$CurrentField},
                FieldName           => $CurrentField,
                DescriptionShort    => $ActivityDialog->{Fields}{$CurrentField}{DescriptionShort},
                Ticket              => \%Ticket || {},
                Error               => \%Error || {},
                FormID              => $Self->{FormID},
                GetParam            => $Param{GetParam},
                AJAXUpdatableFields => $AJAXUpdatableFields,
            );

            if ( !$Response->{Success} ) {

                # does not show header and footer again
                if ( $Self->{AJAXDialog} ) {
                    return $Self->{LayoutObject}->CustomerError(
                        Message => $Response->{Message},
                    );
                }

                $Self->{LayoutObject}->CustomerFatalError(
                    Message => $Response->{Message},
                );
            }

            $Output .= $Response->{HTML};

            $RenderedFields{$CurrentField} = 1;
        }

        # render SLA
        elsif ( $Self->{NameToID}->{$CurrentField} eq 'SLAID' )
        {
            next DIALOGFIELD if $RenderedFields{ $Self->{NameToID}->{$CurrentField} };

            my $Response = $Self->_RenderSLA(
                ActivityDialogField => $ActivityDialog->{Fields}{$CurrentField},
                FieldName           => $CurrentField,
                DescriptionShort    => $ActivityDialog->{Fields}{$CurrentField}{DescriptionShort},
                Ticket              => \%Ticket || {},
                Error               => \%Error || {},
                FormID              => $Self->{FormID},
                GetParam            => $Param{GetParam},
                AJAXUpdatableFields => $AJAXUpdatableFields,
            );

            if ( !$Response->{Success} ) {

                # does not show header and footer again
                if ( $Self->{AJAXDialog} ) {
                    return $Self->{LayoutObject}->CustomerError(
                        Message => $Response->{Message},
                    );
                }

                $Self->{LayoutObject}->CustomerFatalError(
                    Message => $Response->{Message},
                );
            }

            $Output .= $Response->{HTML};

            $RenderedFields{ $Self->{NameToID}->{$CurrentField} } = 1;
        }

        # render Title
        elsif ( $Self->{NameToID}->{$CurrentField} eq 'Title' ) {
            next DIALOGFIELD if $RenderedFields{ $Self->{NameToID}->{$CurrentField} };

            my $Response = $Self->_RenderTitle(
                ActivityDialogField => $ActivityDialog->{Fields}{$CurrentField},
                FieldName           => $CurrentField,
                DescriptionShort    => $ActivityDialog->{Fields}{$CurrentField}{DescriptionShort},
                Ticket              => \%Ticket || {},
                Error               => \%Error || {},
                FormID              => $Self->{FormID},
                GetParam            => $Param{GetParam},
            );

            if ( !$Response->{Success} ) {

                # does not show header and footer again
                if ( $Self->{AJAXDialog} ) {
                    return $Self->{LayoutObject}->CustomerError(
                        Message => $Response->{Message},
                    );
                }

                $Self->{LayoutObject}->CustomerFatalError(
                    Message => $Response->{Message},
                );
            }

            $Output .= $Response->{HTML};

            $RenderedFields{$CurrentField} = 1;
        }

        # render Article
        elsif (
            $Self->{NameToID}->{$CurrentField} eq 'Article'
            )
        {
            next DIALOGFIELD if $RenderedFields{ $Self->{NameToID}->{$CurrentField} };

            my $Response = $Self->_RenderArticle(
                ActivityDialogField => $ActivityDialog->{Fields}{$CurrentField},
                FieldName           => $CurrentField,
                DescriptionShort    => $ActivityDialog->{Fields}{$CurrentField}{DescriptionShort},
                Ticket              => \%Ticket || {},
                Error               => \%Error || {},
                FormID              => $Self->{FormID},
                GetParam            => $Param{GetParam},
                InformAgents => $ActivityDialog->{Fields}->{Article}->{Config}->{InformAgents},
            );

            if ( !$Response->{Success} ) {

                # does not show header and footer again
                if ( $Self->{AJAXDialog} ) {
                    return $Self->{LayoutObject}->CustomerError(
                        Message => $Response->{Message},
                    );
                }

                $Self->{LayoutObject}->CustomerFatalError(
                    Message => $Response->{Message},
                );
            }

            $Output .= $Response->{HTML};

            $RenderedFields{$CurrentField} = 1;
        }

        # render Type
        elsif ( $Self->{NameToID}->{$CurrentField} eq 'TypeID' )
        {

            # We don't render Fields twice,
            # if there was already a Config without ID, skip this field
            next DIALOGFIELD if $RenderedFields{ $Self->{NameToID}->{$CurrentField} };

            my $Response = $Self->_RenderType(
                ActivityDialogField => $ActivityDialog->{Fields}{$CurrentField},
                FieldName           => $CurrentField,
                DescriptionShort    => $ActivityDialog->{Fields}{$CurrentField}{DescriptionShort},
                Ticket              => \%Ticket || {},
                Error               => \%Error || {},
                FormID              => $Self->{FormID},
                GetParam            => $Param{GetParam},
                AJAXUpdatableFields => $AJAXUpdatableFields,
            );

            if ( !$Response->{Success} ) {

                # does not show header and footer again
                if ( $Self->{AJAXDialog} ) {
                    return $Self->{LayoutObject}->CustomerError(
                        Message => $Response->{Message},
                    );
                }

                $Self->{LayoutObject}->CustomerFatalError(
                    Message => $Response->{Message},
                );
            }

            $Output .= $Response->{HTML};

            $RenderedFields{ $Self->{NameToID}->{$CurrentField} } = 1;
        }
    }

    my $FooterCSSClass = 'Footer';

    if ( $Self->{AJAXDialog} ) {

        # Due to the initial loading of
        # the first ActivityDialog after Process selection
        # we have to bind the AjaxUpdate Function on
        # the selects, so we get the complete JSOnDocumentComplete code
        # and deliver it in the FooterJS block.
        # This Javascript Part is executed in
        # CustomerTicketProcess.dtl
        $Self->{LayoutObject}->Block(
            Name => 'FooterJS',
            Data => {},
        );

        $FooterCSSClass = 'Centered';
    }

    # set submit button data
    my $ButtonText  = 'Submit';
    my $ButtonTitle = 'Save';
    my $ButtonID    = 'Submit' . $ActivityActivityDialog->{ActivityDialog};
    if ( $ActivityDialog->{SubmitButtonText} ) {
        $ButtonText  = $ActivityDialog->{SubmitButtonText};
        $ButtonTitle = $ActivityDialog->{SubmitButtonText};
    }

    $Self->{LayoutObject}->Block(
        Name => 'Footer',
        Data => {
            FooterCSSClass => $FooterCSSClass,
            ButtonText     => $ButtonText,
            ButtonTitle    => $ButtonTitle,
            ButtonID       => $ButtonID
        },
    );

    if ( $ActivityDialog->{SubmitAdviceText} ) {
        $Self->{LayoutObject}->Block(
            Name => 'SubmitAdviceText',
            Data => {
                AdviceText => $ActivityDialog->{SubmitAdviceText},
            },
        );
    }

    # reload parent window
    if ( $Param{ParentReload} ) {
        $Self->{LayoutObject}->Block(
            Name => 'ParentReload',
        );
    }

    # Add the FormFooter
    $Output .= $Self->{LayoutObject}->Output(
        TemplateFile => 'ProcessManagement/CustomerActivityDialogFooter',
        Data         => {},
    );

    if ( !$Self->{AJAXDialog} ) {

        # Add the OTRS Footer
        $Output .= $Self->{LayoutObject}->CustomerFooter( Type => 'Small' );
    }
    elsif ( $Self->{AJAXDialog} && IsHashRefWithData( \%Error ) ) {

        # display complete footer in ajax dialogs when there is a server error
        $Output .= $Self->{LayoutObject}->CustomerFooter();
    }

    return $Output;
}

sub _RenderDynamicField {
    my ( $Self, %Param ) = @_;

    for my $Needed (qw(FormID FieldName)) {
        if ( !$Param{$Needed} ) {
            return {
                Success => 0,
                Message => "Got no $Needed in _RenderDynamicField!",
            };
        }
    }
    my $DynamicFieldConfig
        = ( grep { $_->{Name} eq $Param{FieldName} } @{ $Self->{DynamicField} } )[0];

    my $PossibleValuesFilter;

    my $IsACLReducible = $Self->{BackendObject}->HasBehavior(
        DynamicFieldConfig => $DynamicFieldConfig,
        Behavior           => 'IsACLReducible',
    );

    if ($IsACLReducible) {

        # get PossibleValues
        my $PossibleValues = $Self->{BackendObject}->PossibleValuesGet(
            DynamicFieldConfig => $DynamicFieldConfig,
        );

        # All Ticket DynamicFields
        # used for ACL checking
        my %DynamicFieldCheckParam = map { $_ => $Param{GetParam}{$_} }
            grep {m{^DynamicField_}xms} ( keys %{ $Param{GetParam} } );

        # check if field has PossibleValues property in its configuration
        if ( IsHashRefWithData($PossibleValues) ) {

            # convert possible values key => value to key => key for ACLs using a Hash slice
            my %AclData = %{$PossibleValues};
            @AclData{ keys %AclData } = keys %AclData;

            # set possible values filter from ACLs
            my $ACL = $Self->{TicketObject}->TicketAcl(
                %{ $Param{GetParam} },
                DynamicField   => \%DynamicFieldCheckParam,
                Action         => $Self->{Action},
                ReturnType     => 'Ticket',
                ReturnSubType  => 'DynamicField_' . $DynamicFieldConfig->{Name},
                Data           => \%AclData,
                CustomerUserID => $Self->{UserID},
            );
            if ($ACL) {
                my %Filter = $Self->{TicketObject}->TicketAclData();

                # convert Filer key => key back to key => value using map
                %{$PossibleValuesFilter}
                    = map { $_ => $PossibleValues->{$_} } keys %Filter;
            }
        }
    }

    my $ServerError;
    if ( IsHashRefWithData( $Param{Error} ) ) {
        if (
            defined $Param{Error}->{ $Param{FieldName} }
            && $Param{Error}->{ $Param{FieldName} } ne ''
            )
        {
            $ServerError = 1;
        }
    }

    my $DynamicFieldHTML = $Self->{BackendObject}->EditFieldRender(
        DynamicFieldConfig   => $DynamicFieldConfig,
        PossibleValuesFilter => $PossibleValuesFilter,
        Value                => $Param{GetParam}{ 'DynamicField_' . $Param{FieldName} },
        LayoutObject         => $Self->{LayoutObject},
        ParamObject          => $Self->{ParamObject},
        AJAXUpdate           => 1,
        Mandatory            => $Param{ActivityDialogField}->{Display} == 2,
        UpdatableFields      => $Param{AJAXUpdatableFields},
        ServerError          => $ServerError,
    );

    my %Data = (
        Name    => $DynamicFieldHTML->{Name},
        Label   => $DynamicFieldHTML->{Label},
        Content => $DynamicFieldHTML->{Field},
    );

    $Self->{LayoutObject}->Block(
        Name => $Param{ActivityDialogField}->{LayoutBlock} || 'rw:DynamicField',
        Data => \%Data,
    );
    if ( $Param{DescriptionShort} ) {
        $Self->{LayoutObject}->Block(
            Name => $Param{ActivityDialogField}->{LayoutBlock}
                || 'rw:DynamicField:DescriptionShort',
            Data => {
                DescriptionShort => $Param{DescriptionShort},
            },
        );
    }

    return {
        Success => 1,
        HTML => $Self->{LayoutObject}->Output( TemplateFile => 'ProcessManagement/DynamicField' ),
    };
}

sub _RenderTitle {
    my ( $Self, %Param ) = @_;

    for my $Needed (qw(FormID)) {
        if ( !$Param{$Needed} ) {
            return {
                Success => 0,
                Message => "Got no $Needed in _RenderTitle!",
            };
        }
    }
    if ( !IsHashRefWithData( $Param{ActivityDialogField} ) ) {
        return {
            Success => 0,
            Message => "Got no ActivityDialogField in _RenderTitle!",
        };
    }

    my %Data = (
        Label            => $Self->{LayoutObject}->{LanguageObject}->Translate("Title"),
        FieldID          => 'Title',
        FormID           => $Param{FormID},
        Value            => $Param{GetParam}{Title},
        Name             => 'Title',
        MandatoryClass   => '',
        ValidateRequired => '',
    );

    # If field is required put in the necessary variables for
    # ValidateRequired class input field, Mandatory class for the label
    if ( $Param{ActivityDialogField}->{Display} && $Param{ActivityDialogField}->{Display} == 2 ) {
        $Data{ValidateRequired} = 'Validate_Required';
        $Data{MandatoryClass}   = 'Mandatory';
    }

    # output server errors
    if ( IsHashRefWithData( $Param{Error} ) && $Param{Error}->{'Title'} ) {
        $Data{ServerError} = 'ServerError';
    }

    $Self->{LayoutObject}->Block(
        Name => $Param{ActivityDialogField}->{LayoutBlock} || 'rw:Title',
        Data => \%Data,
    );

    # set mandatory label marker
    if ( $Data{MandatoryClass} && $Data{MandatoryClass} ne '' ) {
        $Self->{LayoutObject}->Block(
            Name => 'LabelSpan',
            Data => {},
        );
    }

    if ( $Param{DescriptionShort} ) {
        $Self->{LayoutObject}->Block(
            Name => $Param{ActivityDialogField}->{LayoutBlock} || 'rw:Title:DescriptionShort',
            Data => {
                DescriptionShort => $Param{DescriptionShort},
            },
        );
    }

    return {
        Success => 1,
        HTML => $Self->{LayoutObject}->Output( TemplateFile => 'ProcessManagement/Title' ),
    };

}

sub _RenderArticle {
    my ( $Self, %Param ) = @_;

    for my $Needed (qw(FormID Ticket)) {
        if ( !$Param{$Needed} ) {
            return {
                Success => 0,
                Message => "Got no $Needed in _RenderArticle!",
            };
        }
    }
    if ( !IsHashRefWithData( $Param{ActivityDialogField} ) ) {
        return {
            Success => 0,
            Message => "Got no ActivityDialogField in _RenderArticle!",
        };
    }

    my %Data = (
        Name             => 'Article',
        MandatoryClass   => '',
        ValidateRequired => '',
        Subject          => $Param{GetParam}{Subject},
        Body             => $Param{GetParam}{Body},
        LabelSubject     => $Param{ActivityDialogField}->{Config}->{LabelSubject}
            || $Self->{LayoutObject}->{LanguageObject}->Translate("Subject"),
        LabelBody => $Param{ActivityDialogField}->{Config}->{LabelBody}
            || $Self->{LayoutObject}->{LanguageObject}->Translate("Text"),
    );

    # If field is required put in the necessary variables for
    # ValidateRequired class input field, Mandatory class for the label
    if ( $Param{ActivityDialogField}->{Display} && $Param{ActivityDialogField}->{Display} == 2 ) {
        $Data{ValidateRequired} = 'Validate_Required';
        $Data{MandatoryClass}   = 'Mandatory';
    }

    # output server errors
    if ( IsHashRefWithData( $Param{Error} ) && $Param{Error}->{'ArticleSubject'} ) {
        $Data{SubjectServerError} = 'ServerError';
    }
    if ( IsHashRefWithData( $Param{Error} ) && $Param{Error}->{'ArticleBody'} ) {
        $Data{BodyServerError} = 'ServerError';
    }

    $Self->{LayoutObject}->Block(
        Name => $Param{ActivityDialogField}->{LayoutBlock} || 'rw:Article',
        Data => \%Data,
    );

    # set mandatory label marker
    if ( $Data{MandatoryClass} && $Data{MandatoryClass} ne '' ) {
        $Self->{LayoutObject}->Block(
            Name => 'LabelSpanSubject',
            Data => {},
        );
        $Self->{LayoutObject}->Block(
            Name => 'LabelSpanBody',
            Data => {},
        );
    }

    # add rich text editor
    if ( $Self->{LayoutObject}->{BrowserRichText} ) {

        # use height/width defined for this screen
        $Param{RichTextHeight} = $Self->{Config}->{RichTextHeight} || 0;
        $Param{RichTextWidth}  = $Self->{Config}->{RichTextWidth}  || 0;

        $Self->{LayoutObject}->Block(
            Name => 'RichText',
            Data => \%Param,
        );
    }

    if ( $Param{DescriptionShort} ) {
        $Self->{LayoutObject}->Block(
            Name => 'rw:Article:DescriptionShort',
            Data => {
                DescriptionShort => $Param{DescriptionShort},
            },
        );
    }

    if ( $Param{InformAgents} ) {

        my %ShownUsers;
        my %AllGroupsMembers = $Self->{UserObject}->UserList(
            Type  => 'Long',
            Valid => 1,
        );
        my $GID = $Self->{QueueObject}->GetQueueGroupID( QueueID => $Param{Ticket}->{QueueID} );
        my %MemberList = $Self->{GroupObject}->GroupMemberList(
            GroupID => $GID,
            Type    => 'note',
            Result  => 'HASH',
            Cached  => 1,
        );
        for my $UserID ( sort keys %MemberList ) {
            $ShownUsers{$UserID} = $AllGroupsMembers{$UserID};
        }
        $Param{OptionStrg} = $Self->{LayoutObject}->BuildSelection(
            Data       => \%ShownUsers,
            SelectedID => '',
            Name       => 'InformUserID',
            Multiple   => 1,
            Size       => 3,
        );
        $Self->{LayoutObject}->Block(
            Name => 'rw:Article:InformAgent',
            Data => \%Param,
        );
    }

    # get all attachments meta data
    my @Attachments = $Self->{UploadCacheObject}->FormIDGetAllFilesMeta(
        FormID => $Self->{FormID},
    );

    # show attachments
    ATTACHMENT:
    for my $Attachment (@Attachments) {
        if (
            $Attachment->{ContentID}
            && $Self->{LayoutObject}->{BrowserRichText}
            && ( $Attachment->{ContentType} =~ /image/i )
            && ( $Attachment->{Disposition} eq 'inline' )
            )
        {
            next ATTACHMENT;
        }
        $Self->{LayoutObject}->Block(
            Name => 'Attachment',
            Data => $Attachment,
        );
    }

    return {
        Success => 1,
        HTML => $Self->{LayoutObject}->Output( TemplateFile => 'ProcessManagement/Article' ),
    };
}

sub _RenderCustomer {
    my ( $Self, %Param ) = @_;

    for my $Needed (qw(FormID)) {
        if ( !$Param{$Needed} ) {
            return {
                Success => 0,
                Message => "Got no $Needed in _RenderResponsible!",
            };
        }
    }
    if ( !IsHashRefWithData( $Param{ActivityDialogField} ) ) {
        return {
            Success => 0,
            Message => "Got no ActivityDialogField in _RenderCustomer!",
        };
    }

    my $AutoCompleteConfig
        = $Self->{ConfigObject}->Get('Ticket::Frontend::CustomerSearchAutoComplete');

    my %CustomerUserData = ();

    my $SubmittedCustomerUserID = $Param{GetParam}{CustomerUserID};

    my %Data = (
        LabelCustomerUser => $Self->{LayoutObject}->{LanguageObject}->Translate("Customer user"),
        LabelCustomerID   => $Self->{LayoutObject}->{LanguageObject}->Translate("CustomerID"),
        FormID            => $Param{FormID},
        MandatoryClass    => '',
        ValidateRequired  => '',
    );

    # If field is required put in the necessary variables for
    # ValidateRequired class input field, Mandatory class for the label
    if ( $Param{ActivityDialogField}->{Display} && $Param{ActivityDialogField}->{Display} == 2 ) {
        $Data{ValidateRequired} = 'Validate_Required';
        $Data{MandatoryClass}   = 'Mandatory';
    }

    # output server errors
    if ( IsHashRefWithData( $Param{Error} ) && $Param{Error}->{CustomerUserID} ) {
        $Data{CustomerUserIDServerError} = 'ServerError';
    }
    if ( IsHashRefWithData( $Param{Error} ) && $Param{Error}->{CustomerID} ) {
        $Data{CustomerIDServerError} = 'ServerError';
    }

    # set some customer search autocomplete properties
    $Self->{LayoutObject}->Block(
        Name => 'CustomerSearchAutoComplete',
        Data => {
            minQueryLength      => $AutoCompleteConfig->{MinQueryLength}      || 2,
            queryDelay          => $AutoCompleteConfig->{QueryDelay}          || 100,
            maxResultsDisplayed => $AutoCompleteConfig->{MaxResultsDisplayed} || 20,
            ActiveAutoComplete  => $AutoCompleteConfig->{Active},
        },
    );

    if (
        ( IsHashRefWithData( $Param{Ticket} ) && $Param{Ticket}->{CustomerUserID} )
        || $SubmittedCustomerUserID
        )
    {
        %CustomerUserData
            = $Self->{CustomerUserObject}->CustomerUserDataGet(
            User => $SubmittedCustomerUserID
                || $Param{Ticket}{CustomerUserID},
            );
    }

    # show customer field as "FirstName Lastname" <MailAddress>
    if ( IsHashRefWithData( \%CustomerUserData ) ) {
        $Data{CustomerUserID} = "\"$CustomerUserData{UserFirstname} " .
            "$CustomerUserData{UserLastname}\" <$CustomerUserData{UserEmail}>";
        $Data{CustomerID}           = $CustomerUserData{UserCustomerID} || '';
        $Data{SelectedCustomerUser} = $CustomerUserData{UserID}         || '';
    }

    # set fields that will get an AJAX loader icon when this field changes
    my $JSON = $Self->{LayoutObject}->JSONEncode(
        Data     => $Param{AJAXUpdatableFields},
        NoQuotes => 0,
    );
    $Data{FieldsToUpdate} = $JSON;

    $Self->{LayoutObject}->Block(
        Name => $Param{ActivityDialogField}->{LayoutBlock} || 'rw:Customer',
        Data => \%Data,
    );

    # set mandatory label marker
    if ( $Data{MandatoryClass} && $Data{MandatoryClass} ne '' ) {
        $Self->{LayoutObject}->Block(
            Name => 'LabelSpanCustomerUser',
            Data => {},
        );
        $Self->{LayoutObject}->Block(
            Name => 'LabelSpanCustomerID',
            Data => {},
        );
    }

    if ( $Param{DescriptionShort} ) {
        $Self->{LayoutObject}->Block(
            Name => $Param{ActivityDialogField}->{LayoutBlock} || 'rw:Customer:DescriptionShort',
            Data => {
                DescriptionShort => $Param{DescriptionShort},
            },
        );
    }

    return {
        Success => 1,
        HTML => $Self->{LayoutObject}->Output( TemplateFile => 'ProcessManagement/Customer' ),
    };
}

sub _RenderSLA {
    my ( $Self, %Param ) = @_;

    for my $Needed (qw(FormID)) {
        if ( !$Param{$Needed} ) {
            return {
                Sucess  => 0,
                Message => "Got no $Needed in _RenderSLA!",
            };
        }
    }
    if ( !IsHashRefWithData( $Param{ActivityDialogField} ) ) {
        return {
            Success => 0,
            Message => "Got no ActivityDialogField in _RenderSLA!",
        };
    }
    my $Services = $Self->_GetServices(
        %{ $Param{GetParam} },
    );

    my $SLAs = $Self->_GetSLAs(
        %{ $Param{GetParam} },
        Services => $Services,
    );

    my %Data = (
        Label            => $Self->{LayoutObject}->{LanguageObject}->Translate("SLA"),
        FieldID          => 'SLAID',
        FormID           => $Param{FormID},
        MandatoryClass   => '',
        ValidateRequired => '',
    );

    # If field is required put in the necessary variables for
    # ValidateRequired class input field, Mandatory class for the label
    if ( $Param{ActivityDialogField}->{Display} && $Param{ActivityDialogField}->{Display} == 2 ) {
        $Data{ValidateRequired} = 'Validate_Required';
        $Data{MandatoryClass}   = 'Mandatory';
    }

    my $SelectedValue;

    my $SLAIDParam = $Param{GetParam}{SLAID};
    if ($SLAIDParam) {
        $SelectedValue = $Self->{SLAObject}->SLALookup( SLAID => $SLAIDParam );
    }

    if ( $Param{FieldName} eq 'SLA' ) {

        if ( !$SelectedValue ) {

            # Fetch DefaultValue from Config
            if (
                defined $Param{ActivityDialogField}->{DefaultValue}
                && $Param{ActivityDialogField}->{DefaultValue} ne ''
                )
            {
                $SelectedValue = $Self->{SLAObject}->SLALookup(
                    SLA => $Param{ActivityDialogField}->{DefaultValue},
                );
            }

            if ($SelectedValue) {
                $SelectedValue = $Param{ActivityDialogField}->{DefaultValue};
            }
        }
    }
    else {
        if ( !$SelectedValue ) {
            if (
                defined $Param{ActivityDialogField}->{DefaultValue}
                && $Param{ActivityDialogField}->{DefaultValue} ne ''
                )
            {
                $SelectedValue = $Self->{SLAObject}->SLALookup(
                    SLA => $Param{ActivityDialogField}->{DefaultValue},
                );
            }
        }
    }

    # Get TicketValue
    if ( IsHashRefWithData( $Param{Ticket} ) && !$SelectedValue ) {
        $SelectedValue = $Param{Ticket}->{SLA};
    }

    # set server errors
    my $ServerError;
    if ( IsHashRefWithData( $Param{Error} ) && $Param{Error}->{'SLAID'} ) {
        $ServerError = 'ServerError';
    }

    # build SLA string
    $Data{Content} = $Self->{LayoutObject}->BuildSelection(
        Data          => $SLAs,
        Name          => 'SLAID',
        SelectedValue => $SelectedValue,
        PossibleNone  => 1,
        Sort          => 'AlphanumericValue',
        Translation   => 0,
        Class         => $ServerError,
        Max           => 200,
    );

    # set fields that will get an AJAX loader icon when this field changes
    $Data{FieldsToUpdate} = $Self->_GetFieldsToUpdateStrg(
        TriggerField        => 'SLAID',
        AJAXUpdatableFields => $Param{AJAXUpdatableFields},
    );

    $Self->{LayoutObject}->Block(
        Name => $Param{ActivityDialogField}->{LayoutBlock} || 'rw:SLA',
        Data => \%Data,
    );

    # set mandatory label marker
    if ( $Data{MandatoryClass} && $Data{MandatoryClass} ne '' ) {
        $Self->{LayoutObject}->Block(
            Name => 'LabelSpan',
            Data => {},
        );
    }

    if ( $Param{DescriptionShort} ) {
        $Self->{LayoutObject}->Block(
            Name => $Param{ActivityDialogField}->{LayoutBlock} || 'rw:SLA:DescriptionShort',
            Data => {
                DescriptionShort => $Param{DescriptionShort},
            },
        );
    }

    return {
        Success => 1,
        HTML => $Self->{LayoutObject}->Output( TemplateFile => 'ProcessManagement/SLA' ),
    };
}

sub _RenderService {
    my ( $Self, %Param ) = @_;

    for my $Needed (qw(FormID)) {
        if ( !$Param{$Needed} ) {
            return {
                Success => 0,
                Message => "Got no $Needed in _RenderService!",
            };
        }
    }
    if ( !IsHashRefWithData( $Param{ActivityDialogField} ) ) {
        return {
            Success => 0,
            Message => "Got no ActivityDialogField in _RenderService!"
        };
    }

    my $Services = $Self->_GetServices(
        %{ $Param{GetParam} },
    );

    my %Data = (
        Label            => $Self->{LayoutObject}->{LanguageObject}->Translate("Service"),
        FieldID          => 'ServiceID',
        FormID           => $Param{FormID},
        MandatoryClass   => '',
        ValidateRequired => '',
    );

    # If field is required put in the necessary variables for
    # ValidateRequired class input field, Mandatory class for the label
    if ( $Param{ActivityDialogField}->{Display} && $Param{ActivityDialogField}->{Display} == 2 ) {
        $Data{ValidateRequired} = 'Validate_Required';
        $Data{MandatoryClass}   = 'Mandatory';
    }

    my $SelectedValue;

    my $ServiceIDParam = $Param{GetParam}{ServiceID};
    if ($ServiceIDParam) {
        $SelectedValue = $Self->{ServiceObject}->ServiceLookup(
            ServiceID => $ServiceIDParam,
        );
    }

    if ( $Param{FieldName} eq 'Service' ) {

        if ( !$SelectedValue ) {

            # Fetch DefaultValue from Config
            if (
                defined $Param{ActivityDialogField}->{DefaultValue}
                && $Param{ActivityDialogField}->{DefaultValue} ne ''
                )
            {
                $SelectedValue = $Self->{ServiceObject}->ServiceLookup(
                    Name => $Param{ActivityDialogField}->{DefaultValue},
                );
            }
            if ($SelectedValue) {
                $SelectedValue = $Param{ActivityDialogField}->{DefaultValue};
            }
        }
    }
    else {
        if ( !$SelectedValue ) {
            if (
                defined $Param{ActivityDialogField}->{DefaultValue}
                && $Param{ActivityDialogField}->{DefaultValue} ne ''
                )
            {
                $SelectedValue = $Self->{ServiceObject}->ServiceLookup(
                    Service => $Param{ActivityDialogField}->{DefaultValue},
                );
            }
        }
    }

    # Get TicketValue
    if ( IsHashRefWithData( $Param{Ticket} ) && !$SelectedValue ) {
        $SelectedValue = $Param{Ticket}->{Service};
    }

    # set server errors
    my $ServerError;
    if ( IsHashRefWithData( $Param{Error} ) && $Param{Error}->{'ServiceID'} ) {
        $ServerError = 'ServerError';
    }

    # get list type
    my $TreeView = 0;
    if ( $Self->{ConfigObject}->Get('Ticket::Frontend::ListType') eq 'tree' ) {
        $TreeView = 1;
    }

    # build Service string
    $Data{Content} = $Self->{LayoutObject}->BuildSelection(
        Data          => $Services,
        Name          => 'ServiceID',
        Class         => $ServerError,
        SelectedValue => $SelectedValue,
        PossibleNone  => 1,
        TreeView      => $TreeView,
        Sort          => 'TreeView',
        Translation   => 0,
        Max           => 200,
    );

    # set fields that will get an AJAX loader icon when this field changes
    $Data{FieldsToUpdate} = $Self->_GetFieldsToUpdateStrg(
        TriggerField        => 'ServiceID',
        AJAXUpdatableFields => $Param{AJAXUpdatableFields},
    );

    $Self->{LayoutObject}->Block(
        Name => $Param{ActivityDialogField}->{LayoutBlock} || 'rw:Service',
        Data => \%Data,
    );

    # set mandatory label marker
    if ( $Data{MandatoryClass} && $Data{MandatoryClass} ne '' ) {
        $Self->{LayoutObject}->Block(
            Name => 'LabelSpan',
            Data => {},
        );
    }

    if ( $Param{DescriptionShort} ) {
        $Self->{LayoutObject}->Block(
            Name => $Param{ActivityDialogField}->{LayoutBlock} || 'rw:Service:DescriptionShort',
            Data => {
                DescriptionShort => $Param{DescriptionShort},
            },
        );
    }

    return {
        Success => 1,
        HTML => $Self->{LayoutObject}->Output( TemplateFile => 'ProcessManagement/Service' ),
    };

}

sub _RenderPriority {
    my ( $Self, %Param ) = @_;

    for my $Needed (qw(FormID)) {
        if ( !$Param{$Needed} ) {
            return {
                Success => 0,
                Message => "Got no $Needed in _RenderPriority!",
            };
        }
    }
    if ( !IsHashRefWithData( $Param{ActivityDialogField} ) ) {
        return {
            Success => 0,
            Message => "Got no ActivityDialogField in _RenderPriority!",
        };
    }

    my $Priorities = $Self->_GetPriorities(
        %{ $Param{GetParam} },
    );

    my %Data = (
        Label            => $Self->{LayoutObject}->{LanguageObject}->Translate("Priority"),
        FieldID          => 'PriorityID',
        FormID           => $Param{FormID},
        MandatoryClass   => '',
        ValidateRequired => '',
    );

    # If field is required put in the necessary variables for
    # ValidateRequired class input field, Mandatory class for the label
    if ( $Param{ActivityDialogField}->{Display} && $Param{ActivityDialogField}->{Display} == 2 ) {
        $Data{ValidateRequired} = 'Validate_Required';
        $Data{MandatoryClass}   = 'Mandatory';
    }

    my $SelectedValue;

    my $PriorityIDParam = $Param{GetParam}{PriorityID};
    if ($PriorityIDParam) {
        $SelectedValue = $Self->{PriorityObject}->PriorityLookup(
            PriorityID => $PriorityIDParam,
        );
    }

    if ( $Param{FieldName} eq 'Priority' ) {

        if ( !$SelectedValue ) {

            # Fetch DefaultValue from Config
            $SelectedValue = $Self->{PriorityObject}->PriorityLookup(
                Priority => $Param{ActivityDialogField}->{DefaultValue} || '',
            );
            if ($SelectedValue) {
                $SelectedValue = $Param{ActivityDialogField}->{DefaultValue};
            }
        }
    }
    else {
        if ( !$SelectedValue ) {
            $SelectedValue = $Self->{PriorityObject}->PriorityLookup(
                PriorityID => $Param{ActivityDialogField}->{DefaultValue} || '',
            );
        }
    }

    # Get TicketValue
    if ( IsHashRefWithData( $Param{Ticket} ) && !$SelectedValue ) {
        $SelectedValue = $Param{Ticket}->{Priority};
    }

    # set server errors
    my $ServerError;
    if ( IsHashRefWithData( $Param{Error} ) && $Param{Error}->{'PriorityID'} ) {
        $ServerError = 'ServerError';
    }

    # build next Priorities string
    $Data{Content} = $Self->{LayoutObject}->BuildSelection(
        Data          => $Priorities,
        Name          => 'PriorityID',
        Translation   => 1,
        SelectedValue => $SelectedValue,
        Class         => $ServerError,
    );

    # set fields that will get an AJAX loader icon when this field changes
    $Data{FieldsToUpdate} = $Self->_GetFieldsToUpdateStrg(
        TriggerField        => 'PriorityID',
        AJAXUpdatableFields => $Param{AJAXUpdatableFields},
    );

    $Self->{LayoutObject}->Block(
        Name => $Param{ActivityDialogField}->{LayoutBlock} || 'rw:Priority',
        Data => \%Data,
    );

    # set mandatory label marker
    if ( $Data{MandatoryClass} && $Data{MandatoryClass} ne '' ) {
        $Self->{LayoutObject}->Block(
            Name => 'LabelSpan',
            Data => {},
        );
    }

    if ( $Param{DescriptionShort} ) {
        $Self->{LayoutObject}->Block(
            Name => $Param{ActivityDialogField}->{LayoutBlock} || 'rw:Priority:DescriptionShort',
            Data => {
                DescriptionShort => $Param{DescriptionShort},
            },
        );
    }

    return {
        Success => 1,
        HTML => $Self->{LayoutObject}->Output( TemplateFile => 'ProcessManagement/Priority' ),
    };
}

sub _RenderQueue {
    my ( $Self, %Param ) = @_;

    for my $Needed (qw(FormID)) {
        if ( !$Param{$Needed} ) {
            return {
                Success => 0,
                Message => "Got no $Needed in _RenderQueue!",
            };
        }
    }
    if ( !IsHashRefWithData( $Param{ActivityDialogField} ) ) {
        return {
            Success => 0,
            Message => "Got no ActivityDialogField in _RenderQueue!",
        };
    }

    my $Queues = $Self->_GetQueues(
        %{ $Param{GetParam} },
    );

    my %Data = (
        Label            => $Self->{LayoutObject}->{LanguageObject}->Translate("To queue"),
        FieldID          => 'QueueID',
        FormID           => $Param{FormID},
        MandatoryClass   => '',
        ValidateRequired => '',
    );

    # If field is required put in the necessary variables for
    # ValidateRequired class input field, Mandatory class for the label
    if ( $Param{ActivityDialogField}->{Display} && $Param{ActivityDialogField}->{Display} == 2 ) {
        $Data{ValidateRequired} = 'Validate_Required';
        $Data{MandatoryClass}   = 'Mandatory';
    }
    my $SelectedValue;

    # if we got QueueID as Param from the GUI
    my $QueueIDParam = $Param{GetParam}{QueueID};
    if ($QueueIDParam) {
        $SelectedValue = $Self->{QueueObject}->QueueLookup(
            QueueID => $QueueIDParam,
        );
    }

    if ( $Param{FieldName} eq 'Queue' ) {

        if ( !$SelectedValue ) {

            # Fetch DefaultValue from Config
            $SelectedValue = $Self->{QueueObject}->QueueLookup(
                Queue => $Param{ActivityDialogField}->{DefaultValue} || '',
            );
            if ($SelectedValue) {
                $SelectedValue = $Param{ActivityDialogField}->{DefaultValue};
            }
        }
    }
    else {
        if ( !$SelectedValue ) {
            $SelectedValue = $Self->{QueueObject}->QueueLookup(
                QueueID => $Param{ActivityDialogField}->{DefaultValue} || '',
            );
        }
    }

    # Get TicketValue
    if ( IsHashRefWithData( $Param{Ticket} ) && !$SelectedValue ) {
        $SelectedValue = $Param{Ticket}->{Queue};
    }

    # set server errors
    my $ServerError;
    if ( IsHashRefWithData( $Param{Error} ) && $Param{Error}->{'QueueID'} ) {
        $ServerError = 'ServerError';
    }

    # get list type
    my $TreeView = 0;
    if ( $Self->{ConfigObject}->Get('Ticket::Frontend::ListType') eq 'tree' ) {
        $TreeView = 1;
    }

    # build next queues string
    $Data{Content} = $Self->{LayoutObject}->BuildSelection(
        Data          => $Queues,
        Name          => 'QueueID',
        Translation   => 1,
        SelectedValue => $SelectedValue,
        Class         => $ServerError,
        TreeView      => $TreeView,
        Sort          => 'TreeView',
        PossibleNone  => 1,
    );

    $Data{FieldsToUpdate} = $Self->_GetFieldsToUpdateStrg(
        TriggerField        => 'QueueID',
        AJAXUpdatableFields => $Param{AJAXUpdatableFields},
    );

    $Self->{LayoutObject}->Block(
        Name => $Param{ActivityDialogField}->{LayoutBlock} || 'rw:Queue',
        Data => \%Data,
    );

    # set mandatory label marker
    if ( $Data{MandatoryClass} && $Data{MandatoryClass} ne '' ) {
        $Self->{LayoutObject}->Block(
            Name => 'LabelSpan',
            Data => {},
        );
    }

    if ( $Param{DescriptionShort} ) {
        $Self->{LayoutObject}->Block(
            Name => $Param{ActivityDialogField}->{LayoutBlock} || 'rw:Queue:DescriptionShort',
            Data => {
                DescriptionShort => $Param{DescriptionShort},
            },
        );
    }

    return {
        Success => 1,
        HTML => $Self->{LayoutObject}->Output( TemplateFile => 'ProcessManagement/Queue' ),
    };
}

sub _RenderState {
    my ( $Self, %Param ) = @_;

    for my $Needed (qw(FormID)) {
        if ( !$Param{$Needed} ) {
            return {
                Success => 0,
                Message => "Got no $Needed in _RenderState!",
            };
        }
    }
    if ( !IsHashRefWithData( $Param{ActivityDialogField} ) ) {
        return {
            Success => 0,
            Message => "Got no ActivityDialogField in _RenderState!",
        };
    }

    my $States = $Self->_GetStates( %{ $Param{Ticket} } );

    my %Data = (
        Label            => $Self->{LayoutObject}->{LanguageObject}->Translate("Next ticket state"),
        FieldID          => 'StateID',
        FormID           => $Param{FormID},
        MandatoryClass   => '',
        ValidateRequired => '',
    );

    # If field is required put in the necessary variables for
    # ValidateRequired class input field, Mandatory class for the label
    if ( $Param{ActivityDialogField}->{Display} && $Param{ActivityDialogField}->{Display} == 2 ) {
        $Data{ValidateRequired} = 'Validate_Required';
        $Data{MandatoryClass}   = 'Mandatory';
    }
    my $SelectedValue;

    my $StateIDParam = $Param{GetParam}{StateID};
    if ($StateIDParam) {
        $SelectedValue = $Self->{StateObject}->StateLookup( StateID => $StateIDParam );
    }

    if ( $Param{FieldName} eq 'State' ) {

        if ( !$SelectedValue ) {

            # Fetch DefaultValue from Config
            $SelectedValue = $Self->{StateObject}->StateLookup(
                State => $Param{ActivityDialogField}->{DefaultValue} || '',
            );
            if ($SelectedValue) {
                $SelectedValue = $Param{ActivityDialogField}->{DefaultValue};
            }
        }
    }
    else {
        if ( !$SelectedValue ) {
            $SelectedValue = $Self->{StateObject}->StateLookup(
                StateID => $Param{ActivityDialogField}->{DefaultValue} || '',
            );
        }
    }

    # Get TicketValue
    if ( IsHashRefWithData( $Param{Ticket} ) && !$SelectedValue ) {
        $SelectedValue = $Param{Ticket}->{State};
    }

    # set server errors
    my $ServerError;
    if ( IsHashRefWithData( $Param{Error} ) && $Param{Error}->{'StateID'} ) {
        $ServerError = 'ServerError';
    }

    # build next states string
    $Data{Content} = $Self->{LayoutObject}->BuildSelection(
        Data          => $States,
        Name          => 'StateID',
        Translation   => 1,
        SelectedValue => $SelectedValue,
        Class         => $ServerError,
    );

    # set fields that will get an AJAX loader icon when this field changes
    $Data{FieldsToUpdate} = $Self->_GetFieldsToUpdateStrg(
        TriggerField        => 'StateID',
        AJAXUpdatableFields => $Param{AJAXUpdatableFields},
    );

    $Self->{LayoutObject}->Block(
        Name => $Param{ActivityDialogField}->{LayoutBlock} || 'rw:State',
        Data => \%Data,
    );

    # set mandatory label marker
    if ( $Data{MandatoryClass} && $Data{MandatoryClass} ne '' ) {
        $Self->{LayoutObject}->Block(
            Name => 'LabelSpan',
            Data => {},
        );
    }

    if ( $Param{DescriptionShort} ) {
        $Self->{LayoutObject}->Block(
            Name => $Param{ActivityDialogField}->{LayoutBlock} || 'rw:State:DescriptionShort',
            Data => {
                DescriptionShort => $Param{DescriptionShort},
            },
        );
    }

    return {
        Success => 1,
        HTML => $Self->{LayoutObject}->Output( TemplateFile => 'ProcessManagement/State' ),
    };
}

sub _RenderType {
    my ( $Self, %Param ) = @_;

    for my $Needed (qw(FormID)) {
        if ( !$Param{$Needed} ) {
            return {
                Success => 0,
                Message => "Got no $Needed in _RenderType!",
            };
        }
    }
    if ( !IsHashRefWithData( $Param{ActivityDialogField} ) ) {
        return {
            Success => 0,
            Message => "Got no ActivityDialogField in _RenderType!"
        };
    }

    my $Types = $Self->_GetTypes(
        %{ $Param{GetParam} },
    );

    my %Data = (
        Label            => $Self->{LayoutObject}->{LanguageObject}->Translate("Type"),
        FieldID          => 'TypeID',
        FormID           => $Param{FormID},
        MandatoryClass   => '',
        ValidateRequired => '',
    );

    # If field is required put in the necessary variables for
    # ValidateRequired class input field, Mandatory class for the label
    if ( $Param{ActivityDialogField}->{Display} && $Param{ActivityDialogField}->{Display} == 2 ) {
        $Data{ValidateRequired} = 'Validate_Required';
        $Data{MandatoryClass}   = 'Mandatory';
    }

    my $SelectedValue;

    my $TypeIDParam = $Param{GetParam}{TypeID};
    if ($TypeIDParam) {
        $SelectedValue = $Self->{TypeObject}->TypeLookup(
            TypeID => $TypeIDParam,
        );
    }

    if ( $Param{FieldName} eq 'Type' ) {

        if ( !$SelectedValue ) {

            # Fetch DefaultValue from Config
            if (
                defined $Param{ActivityDialogField}->{DefaultValue}
                && $Param{ActivityDialogField}->{DefaultValue} ne ''
                )
            {
                $SelectedValue = $Self->{TypeObject}->TypeLookup(
                    Type => $Param{ActivityDialogField}->{DefaultValue},
                );
            }
            if ($SelectedValue) {
                $SelectedValue = $Param{ActivityDialogField}->{DefaultValue};
            }
        }
    }
    else {
        if ( !$SelectedValue ) {
            if (
                defined $Param{ActivityDialogField}->{DefaultValue}
                && $Param{ActivityDialogField}->{DefaultValue} ne ''
                )
            {
                $SelectedValue = $Self->{TypeObject}->TypeLookup(
                    Type => $Param{ActivityDialogField}->{DefaultValue},
                );
            }
        }
    }

    # Get TicketValue
    if ( IsHashRefWithData( $Param{Ticket} ) && !$SelectedValue ) {
        $SelectedValue = $Param{Ticket}->{Type};
    }

    # set server errors
    my $ServerError;
    if ( IsHashRefWithData( $Param{Error} ) && $Param{Error}->{'TypeID'} ) {
        $ServerError = 'ServerError';
    }

    # build Service string
    $Data{Content} = $Self->{LayoutObject}->BuildSelection(
        Data          => $Types,
        Name          => 'TypeID',
        Class         => $ServerError,
        SelectedValue => $SelectedValue,
        PossibleNone  => 1,
        Sort          => 'AlphanumericValue',
        Translation   => 0,
        Max           => 200,
    );

    # set fields that will get an AJAX loader icon when this field changes
    $Data{FieldsToUpdate} = $Self->_GetFieldsToUpdateStrg(
        TriggerField        => 'TypeID',
        AJAXUpdatableFields => $Param{AJAXUpdatableFields},
    );

    $Self->{LayoutObject}->Block(
        Name => $Param{ActivityDialogField}->{LayoutBlock} || 'rw:Type',
        Data => \%Data,
    );

    # set mandatory label marker
    if ( $Data{MandatoryClass} && $Data{MandatoryClass} ne '' ) {
        $Self->{LayoutObject}->Block(
            Name => 'LabelSpan',
            Data => {},
        );
    }

    if ( $Param{DescriptionShort} ) {
        $Self->{LayoutObject}->Block(
            Name => $Param{ActivityDialogField}->{LayoutBlock} || 'rw:Type:DescriptionShort',
            Data => {
                DescriptionShort => $Param{DescriptionShort},
            },
        );
    }

    return {
        Success => 1,
        HTML => $Self->{LayoutObject}->Output( TemplateFile => 'ProcessManagement/Type' ),
    };
}

sub _StoreActivityDialog {
    my ( $Self, %Param ) = @_;

    my $TicketID = $Param{GetParam}{TicketID};
    my $ProcessStartpoint;
    my %Ticket;
    my $ProcessEntityID;
    my $ActivityEntityID;
    my %Error;

    my %TicketParam;

    my $ActivityDialogEntityID = $Param{GetParam}{ActivityDialogEntityID};
    if ( !$ActivityDialogEntityID ) {
        $Self->{LayoutObject}->CustomerFatalError(
            Message => "ActivityDialogEntityID missing!",
        );
    }

    my $ActivityDialog = $Self->{ActivityDialogObject}->ActivityDialogGet(
        ActivityDialogEntityID => $ActivityDialogEntityID,
        Interface              => 'CustomerInterface',
    );

    if ( !IsHashRefWithData($ActivityDialog) ) {
        $Self->{LayoutObject}->CustomerFatalError(
            Message => "Couldn't get Config for ActivityDialogEntityID '$ActivityDialogEntityID'!",
        );
    }

    # If is an action about attachments
    my $IsUpload = 0;

    # attachment delete
    my @AttachmentIDs = map {
        my ($ID) = $_ =~ m{ \A AttachmentDelete (\d+) \z }xms;
        $ID ? $ID : ();
    } $Self->{ParamObject}->GetParamNames();

    COUNT:
    for my $Count ( reverse sort @AttachmentIDs ) {
        my $Delete = $Self->{ParamObject}->GetParam( Param => "AttachmentDelete$Count" );
        next COUNT if !$Delete;
        %Error = ();
        $Error{AttachmentDelete} = 1;
        $Self->{UploadCacheObject}->FormIDRemoveFile(
            FormID => $Self->{FormID},
            FileID => $Count,
        );
        $IsUpload = 1;
    }

    # attachment upload
    if ( $Self->{ParamObject}->GetParam( Param => 'AttachmentUpload' ) ) {
        $IsUpload                = 1;
        %Error                   = ();
        $Error{AttachmentUpload} = 1;
        my %UploadStuff = $Self->{ParamObject}->GetUploadAll(
            Param => 'FileUpload',
        );
        $Self->{UploadCacheObject}->FormIDAddFile(
            FormID      => $Self->{FormID},
            Disposition => 'attachment',
            %UploadStuff,
        );
    }

   # check each Field of an Activity Dialog and fill the error hash if something goes horribly wrong
    my %CheckedFields;
    DIALOGFIELD:
    for my $CurrentField ( @{ $ActivityDialog->{FieldOrder} } ) {

        # some fields should be skipped for the customer interface
        next DIALOGFIELD if ( grep { $_ eq $CurrentField } @{ $Self->{SkipFields} } );

        if ( $CurrentField =~ m{^DynamicField_(.*)}xms ) {
            my $DynamicFieldName = $1;

           # Get the Config of the current DynamicField (the first element of the grep result array)
            my $DynamicFieldConfig
                = ( grep { $_->{Name} eq $DynamicFieldName } @{ $Self->{DynamicField} } )[0];

            if ( !IsHashRefWithData($DynamicFieldConfig) ) {
                $Self->{LayoutObject}->CustomerFatalError(
                    Message => "DynamicFieldConfig missing for field: $DynamicFieldName!",
                );
            }

            # Will be extended lateron for ACL Checking:
            my $PossibleValuesFilter;

            # Check DynamicField Values
            my $ValidationResult = $Self->{BackendObject}->EditFieldValueValidate(
                DynamicFieldConfig   => $DynamicFieldConfig,
                PossibleValuesFilter => $PossibleValuesFilter,
                ParamObject          => $Self->{ParamObject},
                Mandatory            => $ActivityDialog->{Fields}{$CurrentField}{Display} == 2,
            );

            if ( !IsHashRefWithData($ValidationResult) ) {
                $Self->{LayoutObject}->CustomerFatalError(
                    Message =>
                        "Could not perform validation on field $DynamicFieldConfig->{Label}!",
                );
            }

            if ( $ValidationResult->{ServerError} ) {
                $Error{ $DynamicFieldConfig->{Name} } = 1;
            }

            # if we had an invisible field, use config's default value
            if ( $ActivityDialog->{Fields}{$CurrentField}{Display} == 0 ) {
                $TicketParam{$CurrentField} = $ActivityDialog->{Fields}{$CurrentField}{DefaultValue}
                    || '';
            }

            # else take the DynamicField Value
            else {
                $TicketParam{$CurrentField} =
                    $Self->{BackendObject}->EditFieldValueGet(
                    DynamicFieldConfig => $DynamicFieldConfig,
                    ParamObject        => $Self->{ParamObject},
                    LayoutObject       => $Self->{LayoutObject},
                    );
            }

            # In case of DynamicFields there is no NameToID translation
            # so just take the DynamicField name
            $CheckedFields{$CurrentField} = 1;
        }
        elsif (
            $Self->{NameToID}->{$CurrentField} eq 'CustomerID'
            || $Self->{NameToID}->{$CurrentField} eq 'CustomerUserID'
            )
        {

            next DIALOGFIELD if $CheckedFields{ $Self->{NameToID}{'CustomerID'} };

            my $CustomerID = $Param{GetParam}{CustomerID} || $Self->{UserCustomerID};
            if ( !$CustomerID ) {
                $Error{'CustomerID'} = 1;
            }
            $TicketParam{CustomerID} = $CustomerID;

            # Unfortunately TicketCreate needs 'CustomerUser' as param instead of 'CustomerUserID'
            my $CustomerUserID = $Self->{ParamObject}->GetParam( Param => 'SelectedCustomerUser' )
                || $Self->{UserID};
            if ( !$CustomerUserID ) {
                $CustomerUserID = $Self->{ParamObject}->GetParam( Param => 'SelectedUserID' );
            }
            if ( !$CustomerUserID ) {
                $Error{'CustomerUserID'} = 1;
            }
            else {
                $TicketParam{CustomerUser} = $CustomerUserID;
            }
            $CheckedFields{ $Self->{NameToID}{'CustomerID'} }     = 1;
            $CheckedFields{ $Self->{NameToID}{'CustomerUserID'} } = 1;

        }
        else {

            # skip if we've already checked ID or Name
            next DIALOGFIELD if $CheckedFields{ $Self->{NameToID}->{$CurrentField} };

            my $Result = $Self->_CheckField(
                Field => $Self->{NameToID}->{$CurrentField},
                %{ $ActivityDialog->{Fields}{$CurrentField} },
            );

            if ( !$Result && $ActivityDialog->{Fields}{$CurrentField}->{Display} == 2 ) {

                # special case for Article (Subject & Body)
                if ( $CurrentField eq 'Article' ) {
                    for my $ArticlePart (qw(Subject Body)) {
                        if ( !$Param{GetParam}->{$ArticlePart} ) {

                            # set error for each part (if any)
                            $Error{ 'Article' . $ArticlePart } = 1;
                        }
                    }
                }

                # all other fields
                else {
                    $Error{ $Self->{NameToID}->{$CurrentField} } = 1;
                }
            }
            elsif ($Result) {
                $TicketParam{ $Self->{NameToID}->{$CurrentField} } = $Result;
            }
            $CheckedFields{ $Self->{NameToID}->{$CurrentField} } = 1;
        }
    }

    my $NewTicketID;
    if ( !$TicketID ) {

        $ProcessEntityID = $Param{GetParam}{ProcessEntityID};
        if ( !$ProcessEntityID )
        {
            return $Self->{LayoutObject}->CustomerFatalError(
                Message => "Missing ProcessEntityID, check your ActivityDialogHeader.dtl!",
            );
        }

        $ProcessStartpoint = $Self->{ProcessObject}->ProcessStartpointGet(
            ProcessEntityID => $Param{ProcessEntityID},
        );

        if (
            !$ProcessStartpoint
            || !IsHashRefWithData($ProcessStartpoint)
            || !$ProcessStartpoint->{Activity} || !$ProcessStartpoint->{ActivityDialog}
            )
        {
            $Self->{LayoutObject}->CustomerFatalError(
                Message => "No StartActivityDialog or StartActivityDialog for Process"
                    . " '$Param{ProcessEntityID}' configured!",
            );
        }

        $ActivityEntityID = $ProcessStartpoint->{Activity};

        NEEDEDLOOP:
        for my $Needed (qw(Queue State Lock Priority)) {

            if ( !$TicketParam{ $Self->{NameToID}->{$Needed} } ) {

                # if a required field has no value call _CheckField as filed is hidden
                # (No Display param = Display => 0) and no DefaultValue, to use global default as
                # fallback. One reason for this to happen is that ActivityDialog DefaultValue tried
                # to set before, was not valid.
                my $Result = $Self->_CheckField(
                    Field => $Self->{NameToID}->{$Needed},
                );

                if ( !$Result ) {
                    $Error{ $Self->{NameToID}->{$Needed} } = ' ServerError';
                }
                elsif ($Result) {
                    $TicketParam{ $Self->{NameToID}->{$Needed} } = $Result;
                }
            }
        }

        # If we had no Errors, we can create the Ticket and Set ActivityEntityID as well as
        # ProcessEntityID
        if ( !IsHashRefWithData( \%Error ) ) {

            $TicketParam{UserID} = $Self->{UserID};

            $TicketParam{CustomerID}   = $Self->{UserCustomerID};
            $TicketParam{CustomerUser} = $Self->{UserLogin};
            $TicketParam{OwnerID}      = $Self->{ConfigObject}->Get('CustomerPanelUserID');
            $TicketParam{UserID}       = $Self->{ConfigObject}->Get('CustomerPanelUserID');

            if ( !$TicketParam{OwnerID} ) {

                $TicketParam{OwnerID} = $Param{GetParam}{OwnerID} || 1;
            }

            # if StartActivityDialog does not provide a ticket title set a default value
            if ( !$TicketParam{Title} ) {

                # get the current server Timestamp
                my $CurrentTimeStamp = $Self->{TimeObject}->CurrentTimestamp();
                $TicketParam{Title} = "$Param{ProcessName} - $CurrentTimeStamp";

                # use article subject from the web request if any
                if ( IsStringWithData( $Param{GetParam}->{Subject} ) ) {
                    $TicketParam{Title} = $Param{GetParam}->{Subject};
                }
            }

            # create a new ticket
            $TicketID = $Self->{TicketObject}->TicketCreate(%TicketParam);

            if ( !$TicketID ) {
                $Self->{LayoutObject}->CustomerFatalError(
                    Message => "Couldn't create ticket for Process with ProcessEntityID"
                        . " '$Param{ProcessEntityID}'!",
                );
            }

            my $Success = $Self->{ProcessObject}->ProcessTicketProcessSet(
                ProcessEntityID => $Param{ProcessEntityID},
                TicketID        => $TicketID,
                UserID          => $Self->{ConfigObject}->Get('CustomerPanelUserID'),
            );
            if ( !$Success ) {
                $Self->{LayoutObject}->CustomerFatalError(
                    Message => "Couldn't set ProcessEntityID '$Param{ProcessEntityID}' on"
                        . " TicketID '$TicketID'!",
                );
            }

            $Success = undef;

            $Success = $Self->{ProcessObject}->ProcessTicketActivitySet(
                ProcessEntityID  => $Param{ProcessEntityID},
                ActivityEntityID => $ProcessStartpoint->{Activity},
                TicketID         => $TicketID,
                UserID           => $Self->{ConfigObject}->Get('CustomerPanelUserID'),
            );

            if ( !$Success ) {
                $Self->{LayoutObject}->CustomerFatalError(
                    Message => "Couldn't set ActivityEntityID '$Param{ProcessEntityID}' on"
                        . " TicketID '$TicketID'!",
                    Comment => 'Please contact the admin.',
                );
            }

            %Ticket = $Self->{TicketObject}->TicketGet(
                TicketID      => $TicketID,
                UserID        => $Self->{ConfigObject}->Get('CustomerPanelUserID'),
                DynamicFields => 1,
            );

            if ( !IsHashRefWithData( \%Ticket ) ) {
                $Self->{LayoutObject}->CustomerFatalError(
                    Message => "Could not Store ActivityDialog, invalid TicketID: $TicketID!",
                    Comment => 'Please contact the admin.',
                );
            }
            for my $DynamicFieldConfig (

                # 2. remove "DynamicField_" from string
                map {
                    my $Field = $_;
                    $Field =~ s{^DynamicField_(.*)}{$1}xms;

                    # 3. grep from the DynamicFieldConfigs the resulting DynamicFields without
                    # "DynamicField_"
                    grep { $_->{Name} eq $Field } @{ $Self->{DynamicField} }
                }

                # 1. grep all DynamicFields
                grep {m{^DynamicField_(.*)}xms} @{ $ActivityDialog->{FieldOrder} }
                )
            {

                # and now it's easy, just store the dynamic Field Values ;)
                $Self->{BackendObject}->ValueSet(
                    DynamicFieldConfig => $DynamicFieldConfig,
                    ObjectID           => $TicketID,
                    Value  => $TicketParam{ 'DynamicField_' . $DynamicFieldConfig->{Name} },
                    UserID => $Self->{ConfigObject}->Get('CustomerPanelUserID'),
                );
            }

            # remember new created TicketID
            $NewTicketID = $TicketID;
        }
    }

    # If we had a TicketID, get the Ticket
    else {

        # Get Ticket to check TicketID was valid
        %Ticket = $Self->{TicketObject}->TicketGet(
            TicketID      => $TicketID,
            UserID        => $Self->{ConfigObject}->Get('CustomerPanelUserID'),
            DynamicFields => 1,
        );

        if ( !IsHashRefWithData( \%Ticket ) ) {
            $Self->{LayoutObject}->CustomerFatalError(
                Message => "Could not Store ActivityDialog, invalid TicketID: $TicketID!",
            );
        }

        $ActivityEntityID = $Ticket{
            'DynamicField_'
                . $Self->{ConfigObject}->Get('Process::DynamicFieldProcessManagementActivityID')
        };
        if ( !$ActivityEntityID )
        {
            return $Self->{LayoutObject}->CustomerErrorScreen(
                Message => "Missing ActivityEntityID in Ticket $Ticket{TicketID}!",
                Comment => 'Please contact the admin.',
            );
        }

        $ProcessEntityID = $Ticket{
            'DynamicField_'
                . $Self->{ConfigObject}->Get('Process::DynamicFieldProcessManagementProcessID')
        };

        if ( !$ProcessEntityID )
        {
            $Self->{LayoutObject}->CustomerFatalError(
                Message => "Missing ProcessEntityID in Ticket $Ticket{TicketID}!",
            );
        }
    }

    # if we got errors go back to displaying the ActivityDialog
    if ( IsHashRefWithData( \%Error ) ) {
        return $Self->_OutputActivityDialog(
            ProcessEntityID        => $ProcessEntityID,
            TicketID               => $TicketID || undef,
            ActivityDialogEntityID => $ActivityDialogEntityID,
            Error                  => \%Error,
            GetParam               => $Param{GetParam},
        );
    }

    # Check if we deal with a Ticket Update
    my $UpdateTicketID = $Param{GetParam}{TicketID};

    # We save only once, no matter if one or more configs are set for the same param
    my %StoredFields;

    # Save loop for storing Ticket Values that were not required on the initial TicketCreate
    DIALOGFIELD:
    for my $CurrentField ( @{ $ActivityDialog->{FieldOrder} } ) {

        # some fields should be skipped for the customer interface
        next DIALOGFIELD if ( grep { $_ eq $CurrentField } @{ $Self->{SkipFields} } );

        if ( !IsHashRefWithData( $ActivityDialog->{Fields}{$CurrentField} ) ) {
            $Self->{LayoutObject}->CustomerFatalError(
                Message => "Can't get data for Field '$CurrentField' of ActivityDialog"
                    . " '$ActivityDialogEntityID'!",
            );
        }

        if ( $CurrentField =~ m{^DynamicField_(.*)}xms ) {
            my $DynamicFieldName = $1;
            my $DynamicFieldConfig
                = ( grep { $_->{Name} eq $DynamicFieldName } @{ $Self->{DynamicField} } )[0];

            my $Success = $Self->{BackendObject}->ValueSet(
                DynamicFieldConfig => $DynamicFieldConfig,
                ObjectID           => $TicketID,
                Value              => $TicketParam{$CurrentField},
                UserID             => $Self->{ConfigObject}->Get('CustomerPanelUserID'),
            );
            if ( !$Success ) {
                $Self->{LayoutObject}->CustomerFatalError(
                    Message => "Could not set DynamicField value for $CurrentField of Ticket"
                        . " with ID '$TicketID' in ActivityDialog '$ActivityDialogEntityID'!",
                );
            }
        }
        elsif ( $CurrentField eq 'Article' && ( $UpdateTicketID || $NewTicketID ) ) {

            my $TicketID = $UpdateTicketID || $NewTicketID;

            if ( $Param{GetParam}{Subject} && $Param{GetParam}{Body} ) {

                # add note
                my $ArticleID = '';
                my $MimeType  = 'text/plain';
                if ( $Self->{LayoutObject}->{BrowserRichText} ) {
                    $MimeType = 'text/html';

                    # verify html document
                    $Param{GetParam}{Body} = $Self->{LayoutObject}->RichTextDocumentComplete(
                        String => $Param{GetParam}{Body},
                    );
                }

                my $From = "$Self->{UserFirstname} $Self->{UserLastname} <$Self->{UserEmail}>";
                $ArticleID = $Self->{TicketObject}->ArticleCreate(
                    TicketID       => $TicketID,
                    SenderType     => 'customer',
                    From           => $From,
                    MimeType       => $MimeType,
                    Charset        => $Self->{LayoutObject}->{UserCharset},
                    UserID         => $Self->{ConfigObject}->Get('CustomerPanelUserID'),
                    HistoryType    => 'AddNote',
                    HistoryComment => '%%Note',
                    Body           => $Param{GetParam}{Body},
                    Subject        => $Param{GetParam}{Subject},
                    ArticleType    => $ActivityDialog->{Fields}->{Article}->{Config}->{ArticleType},
                    ForceNotificationToUserID => $Param{GetParam}{InformUserID},
                );
                if ( !$ArticleID ) {
                    return $Self->{LayoutObject}->CustomerErrorScreen();
                }

                # get pre loaded attachment
                my @Attachments = $Self->{UploadCacheObject}->FormIDGetAllFilesData(
                    FormID => $Self->{FormID},
                );

                # get submit attachment
                my %UploadStuff = $Self->{ParamObject}->GetUploadAll(
                    Param => 'FileUpload',
                );
                if (%UploadStuff) {
                    push @Attachments, \%UploadStuff;
                }

                # write attachments
                ATTACHMENT:
                for my $Attachment (@Attachments) {

                    # skip, deleted not used inline images
                    my $ContentID = $Attachment->{ContentID};
                    if (
                        $ContentID
                        && ( $Attachment->{ContentType} =~ /image/i )
                        && ( $Attachment->{Disposition} eq 'inline' )
                        )
                    {
                        my $ContentIDHTMLQuote = $Self->{LayoutObject}->Ascii2Html(
                            Text => $ContentID,
                        );

                        # workaround for link encode of rich text editor, see bug#5053
                        my $ContentIDLinkEncode = $Self->{LayoutObject}->LinkEncode($ContentID);
                        $Param{GetParam}{Body} =~ s/(ContentID=)$ContentIDLinkEncode/$1$ContentID/g;

                        # ignore attachment if not linked in body
                        if ( $Param{GetParam}{Body} !~ /(\Q$ContentIDHTMLQuote\E|\Q$ContentID\E)/i )
                        {
                            next ATTACHMENT;
                        }
                    }

                    # write existing file to backend
                    $Self->{TicketObject}->ArticleWriteAttachment(
                        %{$Attachment},
                        ArticleID => $ArticleID,
                        UserID    => $Self->{ConfigObject}->Get('CustomerPanelUserID'),
                    );
                }

                # remove pre submited attachments
                $Self->{UploadCacheObject}->FormIDRemove( FormID => $Self->{FormID} );
            }
        }

        # If we have to Update a ticket, update the transmitted values
        elsif ($UpdateTicketID) {

            my $Success;
            if ( $Self->{NameToID}{$CurrentField} eq 'Title' ) {

                # if there is no title, nothig is needed to be done
                if (
                    !defined $TicketParam{'Title'}
                    || ( defined $TicketParam{'Title'} && $TicketParam{'Title'} eq '' )
                    )
                {
                    $Success = 1;
                }

                # otherwise set the ticket title
                else {
                    $Success = $Self->{TicketObject}->TicketTitleUpdate(
                        Title    => $TicketParam{'Title'},
                        TicketID => $TicketID,
                        UserID   => $Self->{ConfigObject}->Get('CustomerPanelUserID'),
                    );
                }
            }
            elsif (
                (
                    $Self->{NameToID}{$CurrentField} eq 'CustomerID'
                    || $Self->{NameToID}{$CurrentField} eq 'CustomerUserID'
                )
                )
            {
                next DIALOGFIELD if $StoredFields{ $Self->{NameToID}{$CurrentField} };

                if ( $ActivityDialog->{Fields}{$CurrentField}{Display} == 1 ) {
                    $Self->{LayoutObject}->CustomerFatalError(
                        Message => "Wrong ActivityDialog Field config: $CurrentField can't be"
                            . ' Display => 1 / Show field (Please change its configuration to be'
                            . ' Display => 0 / Do not show field or '
                            . ' Display => 2 / Show field as mandatory )!',
                    );
                }

                # skip TicketCustomerSet() if there is no change in the customer
                if (
                    $Ticket{CustomerID} eq $TicketParam{CustomerID}
                    && $Ticket{CustomerUserID} eq $TicketParam{CustomerUser}
                    )
                {

                    # In this case we don't want to call any additional stores
                    # on Customer, CustomerNo, CustomerID or CustomerUserID
                    # so make sure both fields are set to "Stored" ;)
                    $StoredFields{ $Self->{NameToID}{'CustomerID'} }     = 1;
                    $StoredFields{ $Self->{NameToID}{'CustomerUserID'} } = 1;
                    next DIALOGFIELD;
                }

                $Success = $Self->{TicketObject}->TicketCustomerSet(
                    No => $TicketParam{CustomerID},

                    # here too: unfortunately TicketCreate takes Param 'CustomerUser'
                    # instead of CustomerUserID, so our TicketParam hash
                    # has the CustomerUser Key instead of 'CustomerUserID'
                    User     => $TicketParam{CustomerUser},
                    TicketID => $TicketID,
                    UserID   => $Self->{ConfigObject}->Get('CustomerPanelUserID'),
                );

                # In this case we don't want to call any additional stores
                # on Customer, CustomerNo, CustomerID or CustomerUserID
                # so make sure both fields are set to "Stored" ;)
                $StoredFields{ $Self->{NameToID}{'CustomerID'} }     = 1;
                $StoredFields{ $Self->{NameToID}{'CustomerUserID'} } = 1;
            }
            else {
                next DIALOGFIELD if $StoredFields{ $Self->{NameToID}{$CurrentField} };

                my $TicketFieldSetSub = $CurrentField;
                $TicketFieldSetSub =~ s{ID$}{}xms;
                $TicketFieldSetSub = 'Ticket' . $TicketFieldSetSub . 'Set';

                if ( $Self->{TicketObject}->can($TicketFieldSetSub) )
                {
                    my $UpdateFieldName;

                    $UpdateFieldName = $Self->{NameToID}{$CurrentField};

                    # to store if the field needs to be updated
                    my $FieldUpdate;

                    # only Service and SLA fields accepts empty values if the hash key is not
                    # defined set it to empty so the Ticket*Set function call will get the empty
                    # value
                    if (
                        ( $UpdateFieldName eq 'ServiceID' || $UpdateFieldName eq 'SLAID' )
                        && !defined $TicketParam{ $Self->{NameToID}{$CurrentField} }
                        )
                    {
                        $TicketParam{ $Self->{NameToID}{$CurrentField} } = '';
                        $FieldUpdate = 1;
                    }

                    # update Service an SLA fields if they have a defined value (even empty)
                    elsif ( $UpdateFieldName eq 'ServiceID' || $UpdateFieldName eq 'SLAID' )
                    {
                        $FieldUpdate = 1;
                    }

                    # update any other field that its value is defiend and not emoty
                    elsif (
                        $UpdateFieldName ne 'ServiceID'
                        && $UpdateFieldName ne 'SLAID'
                        && defined $TicketParam{ $Self->{NameToID}{$CurrentField} }
                        && $TicketParam{ $Self->{NameToID}{$CurrentField} } ne ''
                        )
                    {
                        $FieldUpdate = 1;
                    }

                    $Success = 1;

                    # check if field needs to be updated
                    if ($FieldUpdate) {
                        $Success = $Self->{TicketObject}->$TicketFieldSetSub(
                            $UpdateFieldName => $TicketParam{ $Self->{NameToID}{$CurrentField} },
                            TicketID         => $TicketID,
                            UserID           => $Self->{ConfigObject}->Get('CustomerPanelUserID'),
                        );
                    }
                }
            }
            if ( !$Success ) {
                $Self->{LayoutObject}->CustomerFatalError(
                    Message => "Could not set $CurrentField for Ticket with ID '$TicketID'"
                        . " in ActivityDialog '$ActivityDialogEntityID'!",
                );
            }
        }
    }

    # Transitions will be handled by ticket event module (TicketProcessTransitions.pm).

    # if we were updating a ticket, close the popup and return to zoom
    # else (new ticket) just go to zoom to show the new ticket
    if ($UpdateTicketID) {

        # load new URL in parent window and close popup
        return $Self->{LayoutObject}->PopupClose(
            URL => "Action=CustomerTicketZoom;TicketID=$UpdateTicketID",
        );
    }

    return $Self->{LayoutObject}->Redirect(
        OP => "Action=CustomerTicketZoom;TicketID=$TicketID",
    );
}

sub _DisplayProcessList {
    my ( $Self, %Param ) = @_;

    # If we have a ProcessEntityID
    $Param{Errors}->{ProcessEntityIDInvalid} = ' ServerError'
        if ( $Param{ProcessEntityID} && !$Param{ProcessList}->{ $Param{ProcessEntityID} } );

    $Param{ProcessList} = $Self->{LayoutObject}->BuildSelection(
        Class => 'Validate_Required' . ( $Param{Errors}->{ProcessEntityIDInvalid} || ' ' ),
        Data  => $Param{ProcessList},
        Name  => 'ProcessEntityID',
        SelectedID   => $Param{ProcessEntityID},
        PossibleNone => 1,
        Sort         => 'AlphanumericValue',
        Translation  => 0,
    );

    # add rich text editor
    if ( $Self->{LayoutObject}->{BrowserRichText} ) {

        # use height/width defined for this screen
        $Param{RichTextHeight} = $Self->{Config}->{RichTextHeight} || 0;
        $Param{RichTextWidth}  = $Self->{Config}->{RichTextWidth}  || 0;

        $Self->{LayoutObject}->Block(
            Name => 'RichText',
            Data => \%Param,
        );
    }

    $Self->{LayoutObject}->Block(
        Name => 'ProcessList',
        Data => {
            %Param,
            FormID => $Self->{FormID},
        },
    );
    my $Output = $Self->{LayoutObject}->CustomerHeader();
    $Output .= $Self->{LayoutObject}->CustomerNavigationBar();

    $Output .= $Self->{LayoutObject}->Output(
        TemplateFile => 'CustomerTicketProcess',
        Data         => {
            %Param,
        },
    );

    # workaround when activity dialog is loaded by AJAX as first activity dialog, if there is
    # a date field like Pending Time or Dynamic Fields Date/Time or Date, there is no way to set
    # this options in the footer again
    $Self->{LayoutObject}->{HasDatepicker} = 1;

    $Output .= $Self->{LayoutObject}->CustomerFooter();

    return $Output;
}

=item _CheckField()

checks all the possible ticket fields and returns the ID (if possible) value of the field, if valid
and checks are successfull

if Display param is set to 0 or not given, it uses ActivityDialog field default value for all fields
or global default value as fallback only for certain fields

if Display param is set to 1 or 2 it uses the value from the web request

    my $PriorityID = $CustomerTicketProcessObject->_CheckField(
        Field        => 'PriorityID',
        Display      => 1,                   # optional, 0 or 1 or 2
        DefaultValue => '3 normal',          # ActivityDialog field default value (it uses global
                                             #    default value as fall back for mandatory fields
                                             #    (Queue, Sate, Lock and Priority)
    );

Returns:
    $PriorityID = 1;                         # if PriorityID is set to 1 in the web request

    my $PriorityID = $CustomerTicketProcessObject->_CheckField(
        Field        => 'PriorityID',
        Display      => 0,
        DefaultValue => '3 normal',
    );

Returns:
    $PriorityID = 3;                        # since ActivityDialog default value is '3 normal' and
                                            #     field is hidden

=cut

sub _CheckField {
    my ( $Self, %Param ) = @_;

    # check needed stuff
    for my $Needed (qw(Field)) {
        if ( !$Param{$Needed} ) {
            $Self->{LogObject}->Log( Priority => 'error', Message => "Need $Needed!" );
            return;
        }
    }

    # remove the ID and check if the given field is required for creating a ticket
    my $FieldWithoutID = $Param{Field};
    $FieldWithoutID =~ s{ID$}{}xms;
    my $TicketRequiredField = scalar grep { $_ eq $FieldWithoutID } qw(Queue State Lock Priority);

    my $Value;

    # if no Display (or Display == 0) is commited
    if ( !$Param{Display} ) {

        # Check if a DefaultValue is given
        if ( $Param{DefaultValue} ) {

            # check if the given field param is valid
            $Value = $Self->_LookupValue(
                Field => $FieldWithoutID,
                Value => $Param{DefaultValue},
            );
        }

        # if we got a required ticket field, check if we got a valid DefaultValue in the SysConfig
        if ( !$Value && $TicketRequiredField ) {
            $Value = $Self->{ConfigObject}->Get("Process::Default$FieldWithoutID");

            if ( !$Value ) {
                $Self->{LayoutObject}->CustomerFatalError(
                    Message => "Default Config for Process::Default$FieldWithoutID missing!",
                );
            }
            else {

                # check if the given field param is valid
                $Value = $Self->_LookupValue(
                    Field => $FieldWithoutID,
                    Value => $Value,
                );
                if ( !$Value ) {
                    $Self->{LayoutObject}->CustomerFatalError(
                        Message => "Default Config for Process::Default$FieldWithoutID invalid!",
                    );
                }
            }
        }
    }
    elsif ( $Param{Display} == 1 ) {

        # Display == 1 is logicaliy not possible for a ticket required field
        if ($TicketRequiredField) {
            $Self->{LayoutObject}->CustomerFatalError(
                Message => "Wrong ActivityDialog Field config: $Param{Field} can't be"
                    . ' Display => 1 / Show field (Please change its configuration to be'
                    . ' Display => 0 / Do not show field or '
                    . ' Display => 2 / Show field as mandatory )!',
            );
        }

        # check if the given field param is valid
        if ( $Param{Field} eq 'Article' ) {

            # in case of article fields we need to fake a value
            $Value = 1;
        }
        else {

            $Value = $Self->_LookupValue(
                Field => $Param{Field},
                Value => $Self->{ParamObject}->GetParam( Param => $Param{Field} ) || '',
            );
        }
    }
    elsif ( $Param{Display} == 2 ) {

        # check if the given field param is valid
        if ( $Param{Field} eq 'Article' ) {

            my ( $Body, $Subject ) = (
                $Self->{ParamObject}->GetParam( Param => 'Body' ),
                $Self->{ParamObject}->GetParam( Param => 'Subject' )
            );

            $Value = 0;
            if ( $Body && $Subject ) {
                $Value = 1;
            }
        }
        else {
            $Value = $Self->_LookupValue(
                Field => $Param{Field},
                Value => $Self->{ParamObject}->GetParam( Param => $Param{Field} ) || '',
            );
        }
    }

    return $Value;
}

=item _LookupValue()

returns the ID (if possible) of nearly all ticket fields and/or checks if its valid.
Can handle IDs or Strings.
Currently working with: State, Queue, Lock, Priority (possible more).

    my $PriorityID = $CustomerTicketProcessObject->_LookupValue(
        PriorityID => 1,
    );
    $PriorityID = 1;

    my $StateID = $CustomerTicketProcessObject->_LookupValue(
        State => 'open',
    );
    $StateID = 3;

    my $PriorityID = $CustomerTicketProcessObject->_LookupValue(
        Priority => 'unknownpriority1234',
    );
    $PriorityID = undef;

=cut

sub _LookupValue {
    my ( $Self, %Param ) = @_;

    # check needed stuff
    for my $Needed (qw(Field Value)) {
        if ( !defined $Param{$Needed} ) {
            $Self->{LogObject}->Log(
                Priority => 'error',
                Message  => "Need $Needed!"
            );
            return;
        }
    }

    if ( !$Param{Field} ) {
        $Self->{LogObject}->Log(
            Priority => 'error',
            Message  => "Field should not be empty!"
        );
        return;
    }

    # if there is no value, there is nothing to do
    return if !$Param{Value};

    # remove the ID for function name purpose
    my $FieldWithoutID = $Param{Field};
    $FieldWithoutID =~ s{ID$}{}xms;

    my $LookupFieldName;
    my $ObjectName;
    my $FunctionName;

    # service and SLA lookup needs Name as parameter (While ServiceID an SLAID uses standard)
    if ( scalar grep { $Param{Field} eq $_ } qw( Service SLA ) ) {
        $LookupFieldName = 'Name';
        $ObjectName      = $FieldWithoutID . 'Object';
        $FunctionName    = $FieldWithoutID . 'Lookup';
    }

    # other fields can use standard parameter names as Priority or PriorityID
    else {
        $LookupFieldName = $Param{Field};
        $ObjectName      = $FieldWithoutID . 'Object';
        $FunctionName    = $FieldWithoutID . 'Lookup';
    }

    my $Value;

    # check if the backend module has the needed *Lookup sub
    if (
        $Self->{$ObjectName}
        && $Self->{$ObjectName}->can($FunctionName)
        )
    {

        # call the *Lookup sub and get the value
        $Value = $Self->{$ObjectName}->$FunctionName(
            $LookupFieldName => $Param{Value},
        );
    }

    # if we didn't have an object and the value has no ref a string e.g. Title and so on
    # return true
    elsif ( $Param{Field} eq $FieldWithoutID && !ref $Param{Value} ) {
        return $Param{Value};
    }
    else {
        $Self->{LogObject}->Log(
            Priority => 'error',
            Message  => "Error while checking with " . $FieldWithoutID . "Object!"
        );
        return;
    }

    return if ( !$Value );

    # return the given ID value if the *Lookup result was a string
    if ( $Param{Field} ne $FieldWithoutID ) {
        return $Param{Value};
    }

    # return the *Lookup string return value
    return $Value;
}

sub _GetSLAs {
    my ( $Self, %Param ) = @_;

    # if no CustomerUserID is present, consider the logged in customer
    if ( !$Param{CustomerUserID} ) {
        $Param{CustomerUserID} = $Self->{UserID};
    }

    # get sla
    my %SLA;
    if ( $Param{ServiceID} && $Param{Services} && %{ $Param{Services} } ) {
        if ( $Param{Services}->{ $Param{ServiceID} } ) {
            %SLA = $Self->{TicketObject}->TicketSLAList(
                %Param,
                Action => $Self->{Action},
            );
        }
    }
    return \%SLA;
}

sub _GetServices {
    my ( $Self, %Param ) = @_;

    # get service
    my %Service;

    # check needed
    return \%Service if !$Param{QueueID} && !$Param{TicketID};

    # get options for default services for unknown customers
    my $DefaultServiceUnknownCustomer
        = $Self->{ConfigObject}->Get('Ticket::Service::Default::UnknownCustomer');

    # if no CustomerUserID is present, consider the logged in customer
    if ( !$Param{CustomerUserID} ) {
        $Param{CustomerUserID} = $Self->{UserID};
    }

    # check if still no CustomerUserID is selected
    # if $DefaultServiceUnknownCustomer = 0 leave CustomerUserID empty, it will not get any services
    # if $DefaultServiceUnknownCustomer = 1 set CustomerUserID to get default services
    if ( !$Param{CustomerUserID} && $DefaultServiceUnknownCustomer ) {
        $Param{CustomerUserID} = '<DEFAULT>';
    }

    # get service list
    if ( $Param{CustomerUserID} ) {
        %Service = $Self->{TicketObject}->TicketServiceList(
            %Param,
            Action => $Self->{Action},
        );
    }
    return \%Service;
}

sub _GetPriorities {
    my ( $Self, %Param ) = @_;

    my %Priorities;

    # Initially we have just the default Queue Parameter
    # so make sure to get the ID in that case
    my $QueueID;
    if ( !$Param{QueueID} && $Param{Queue} ) {
        $QueueID = $Self->{QueueObject}->QueueLookup( Queue => $Param{Queue} );
    }
    if ( $Param{QueueID} || $QueueID || $Param{TicketID} ) {
        %Priorities = $Self->{TicketObject}->TicketPriorityList(
            %Param,
            Action         => $Self->{Action},
            CustomerUserID => $Self->{UserID},
        );

    }
    return \%Priorities;
}

sub _GetQueues {
    my ( $Self, %Param ) = @_;

    # check own selection
    my %NewQueues;
    if ( $Self->{ConfigObject}->Get('Ticket::Frontend::NewQueueOwnSelection') ) {
        %NewQueues = %{ $Self->{ConfigObject}->Get('Ticket::Frontend::NewQueueOwnSelection') };
    }
    else {

        # SelectionType Queue or SystemAddress?
        my %Queues;
        if ( $Self->{ConfigObject}->Get('Ticket::Frontend::NewQueueSelectionType') eq 'Queue' ) {
            %Queues = $Self->{TicketObject}->MoveList(
                %Param,
                Type    => 'create',
                Action  => $Self->{Action},
                QueueID => $Self->{QueueID},
                UserID  => $Self->{ConfigObject}->Get('CustomerPanelUserID'),
            );
        }
        else {
            %Queues = $Self->{DBObject}->GetTableData(
                Table => 'system_address',
                What  => 'queue_id, id',
                Valid => 1,
                Clamp => 1,
            );
        }

        # get create permission queues
        my %UserGroups = $Self->{GroupObject}->GroupMemberList(
            UserID => $Self->{ConfigObject}->Get('CustomerPanelUserID'),
            Type   => 'create',
            Result => 'HASH',
        );

        # build selection string
        QUEUEID:
        for my $QueueID ( sort keys %Queues ) {
            my %QueueData = $Self->{QueueObject}->QueueGet( ID => $QueueID );

            # permission check, can we create new tickets in queue
            next QUEUEID if !$UserGroups{ $QueueData{GroupID} };

            my $String = $Self->{ConfigObject}->Get('Ticket::Frontend::NewQueueSelectionString')
                || '<Realname> <<Email>> - Queue: <Queue>';
            $String =~ s/<Queue>/$QueueData{Name}/g;
            $String =~ s/<QueueComment>/$QueueData{Comment}/g;
            if ( $Self->{ConfigObject}->Get('Ticket::Frontend::NewQueueSelectionType') ne 'Queue' )
            {
                my %SystemAddressData = $Self->{SystemAddress}->SystemAddressGet(
                    ID => $Queues{$QueueID},
                );
                $String =~ s/<Realname>/$SystemAddressData{Realname}/g;
                $String =~ s/<Email>/$SystemAddressData{Name}/g;
            }
            $NewQueues{$QueueID} = $String;
        }
    }

    return \%NewQueues;
}

sub _GetStates {
    my ( $Self, %Param ) = @_;

    my %States = $Self->{TicketObject}->TicketStateList(
        %Param,

        # Set default values for new process ticket
        QueueID  => $Param{QueueID}  || 1,
        TicketID => $Param{TicketID} || '',

        # remove type, since if Ticket::Type is active in sysconfig, the Type parameter will
        # be sent and the TicketStateList will send the parameter as State Type
        Type => undef,

        Action => $Self->{Action},
        UserID => $Self->{ConfigObject}->Get('CustomerPanelUserID'),
    );

    return \%States;
}

sub _GetTypes {
    my ( $Self, %Param ) = @_;

    # get type
    my %Type;
    if ( $Param{QueueID} || $Param{TicketID} ) {
        %Type = $Self->{TicketObject}->TicketTypeList(
            %Param,
            Action => $Self->{Action},
            UserID => $Self->{ConfigObject}->Get('CustomerPanelUserID'),
        );
    }
    return \%Type;
}

sub _GetAJAXUpdatableFields {
    my ( $Self, %Param ) = @_;

    my %DefaultUpdatableFields = (
        PriorityID    => 1,
        QueueID       => 1,
        ResponsibleID => 1,
        ServiceID     => 1,
        SLAID         => 1,
        StateID       => 1,
        OwnerID       => 1,
        LockID        => 1,
    );

    # create a DynamicFieldLookupTable
    my %DynamicFieldLookup = map { 'DynamicField_' . $_->{Name} => $_ } @{ $Self->{DynamicField} };

    my @UpdatableFields;
    FIELD:
    for my $Field ( sort keys %{ $Param{ActivityDialogFields} } ) {

        my $FieldData = $Param{ActivityDialogFields}->{$Field};

        # skip hidden fields
        next FIELD if !$FieldData->{Display};

        # for Dynamic Fields check if is AJAXUpdatable
        if ( $Field =~ m{^DynamicField_(.*)}xms ) {
            my $DynamicFieldConfig = $DynamicFieldLookup{$Field};

            # skip any field with wrong config
            next FIELD if !IsHashRefWithData($DynamicFieldConfig);

            # skip field if is not IsACLReducible (updatable)

            my $IsACLReducible = $Self->{BackendObject}->HasBehavior(
                DynamicFieldConfig => $DynamicFieldConfig,
                Behavior           => 'IsACLReducible',
            );
            next FIELD if !$IsACLReducible;

            push @UpdatableFields, $Field;
        }

        # for all others use %DefaultUpdatableFields table
        else {

            # standarize the field name (e.g. use StateID for State field)
            my $FieldName = $Self->{NameToID}->{$Field};

            # skip if field name could not be converted (this means that field is unknown)
            next FIELD if !$FieldName;

            # skip if the field is not updatable via ajax
            next FIELD if !$DefaultUpdatableFields{$FieldName};

            push @UpdatableFields, $FieldName;
        }
    }

    return \@UpdatableFields;
}

sub _GetFieldsToUpdateStrg {
    my ( $Self, %Param ) = @_;

    my $FieldsToUpdate = '';
    if ( IsArrayRefWithData( $Param{AJAXUpdatableFields} ) ) {
        my $FirstItem = 1;
        FIELD:
        for my $Field ( @{ $Param{AJAXUpdatableFields} } ) {
            next FIELD if $Field eq $Param{TriggerField};
            if ($FirstItem) {
                $FirstItem = 0;
            }
            else {
                $FieldsToUpdate .= ', ';
            }
            $FieldsToUpdate .= "'" . $Field . "'";
        }
    }
    return $FieldsToUpdate;
}

1;
