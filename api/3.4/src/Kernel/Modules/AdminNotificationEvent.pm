# --
# Kernel/Modules/AdminNotificationEvent.pm - to manage event-based notifications
# Copyright (C) 2001-2014 OTRS AG, http://otrs.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package Kernel::Modules::AdminNotificationEvent;

use strict;
use warnings;

use Kernel::System::NotificationEvent;
use Kernel::System::Priority;
use Kernel::System::Event;
use Kernel::System::Lock;
use Kernel::System::Service;
use Kernel::System::SLA;
use Kernel::System::State;
use Kernel::System::Type;
use Kernel::System::Valid;
use Kernel::System::DynamicField;
use Kernel::System::DynamicField::Backend;
use Kernel::System::VariableCheck qw(:all);

sub new {
    my ( $Type, %Param ) = @_;

    # allocate new hash for object
    my $Self = {%Param};
    bless( $Self, $Type );

    # check all needed objects
    for my $Needed (qw(ParamObject DBObject LayoutObject ConfigObject LogObject)) {
        if ( !$Self->{$Needed} ) {
            $Self->{LayoutObject}->FatalError( Message => "Got no $Needed!" );
        }
    }

    $Self->{NotificationEventObject} = Kernel::System::NotificationEvent->new(%Param);

    $Self->{PriorityObject}     = Kernel::System::Priority->new(%Param);
    $Self->{StateObject}        = Kernel::System::State->new(%Param);
    $Self->{LockObject}         = Kernel::System::Lock->new(%Param);
    $Self->{ServiceObject}      = Kernel::System::Service->new(%Param);
    $Self->{SLAObject}          = Kernel::System::SLA->new(%Param);
    $Self->{TypeObject}         = Kernel::System::Type->new(%Param);
    $Self->{ValidObject}        = Kernel::System::Valid->new(%Param);
    $Self->{DynamicFieldObject} = Kernel::System::DynamicField->new(%Param);
    $Self->{BackendObject}      = Kernel::System::DynamicField::Backend->new(%Param);

    $Self->{Config} = $Self->{ConfigObject}->Get("Frontend::Admin::$Self->{Action}");

    $Self->{RichText} = $Self->{ConfigObject}->Get('Frontend::RichText');
    if ( $Self->{RichText} && !$Self->{Config}->{RichText} ) {
        $Self->{RichText} = 0;
    }

    # get the dynamic fields for this screen
    $Self->{DynamicField} = $Self->{DynamicFieldObject}->DynamicFieldListGet(
        Valid      => 1,
        ObjectType => ['Ticket'],
    );

    $Self->{EventObject} = Kernel::System::Event->new(
        %Param,
        DynamicFieldObject => $Self->{DynamicFieldObject},
    );

    return $Self;
}

sub Run {
    my ( $Self, %Param ) = @_;

    # set type for notifications
    my $NotificationType = 'text/plain';
    if ( $Self->{RichText} ) {
        $NotificationType = 'text/html';
    }

    # ------------------------------------------------------------ #
    # change
    # ------------------------------------------------------------ #
    if ( $Self->{Subaction} eq 'Change' ) {
        my $ID = $Self->{ParamObject}->GetParam( Param => 'ID' ) || '';
        my %Data = $Self->{NotificationEventObject}->NotificationGet( ID => $ID );
        my $Output = $Self->{LayoutObject}->Header();
        $Output .= $Self->{LayoutObject}->NavigationBar();
        $Self->_Edit(
            Action => 'Change',
            %Data,
            DynamicFieldValues => $Data{Data},
        );
        $Output .= $Self->{LayoutObject}->Output(
            TemplateFile => 'AdminNotificationEvent',
            Data         => \%Param,
        );
        $Output .= $Self->{LayoutObject}->Footer();

        return $Output;
    }

    # ------------------------------------------------------------ #
    # change action
    # ------------------------------------------------------------ #
    elsif ( $Self->{Subaction} eq 'ChangeAction' ) {

        # challenge token check for write action
        $Self->{LayoutObject}->ChallengeTokenCheck();

        my %GetParam;
        for my $Parameter (qw(ID Name Subject Body Type Charset Comment ValidID Events)) {
            $GetParam{$Parameter} = $Self->{ParamObject}->GetParam( Param => $Parameter ) || '';
        }
        PARAMETER:
        for my $Parameter (
            qw(Recipients RecipientAgents RecipientGroups RecipientRoles RecipientEmail
            Events StateID QueueID PriorityID LockID TypeID ServiceID SLAID
            CustomerID CustomerUserID
            ArticleTypeID ArticleSubjectMatch ArticleBodyMatch ArticleAttachmentInclude
            ArticleSenderTypeID NotificationArticleTypeID)
            )
        {
            my @Data = $Self->{ParamObject}->GetArray( Param => $Parameter );
            next PARAMETER if !@Data;
            $GetParam{Data}->{$Parameter} = \@Data;
        }

        # to store dynamic fields profile data
        my %DynamicFieldValues;

        # get Dynamic fields for search from web request
        # cycle trough the activated Dynamic Fields for this screen
        DYNAMICFIELD:
        for my $DynamicFieldConfig ( @{ $Self->{DynamicField} } ) {
            next DYNAMICFIELD if !IsHashRefWithData($DynamicFieldConfig);

            # extract the dynamic field value form the web request
            my $DynamicFieldValue = $Self->{BackendObject}->SearchFieldValueGet(
                DynamicFieldConfig     => $DynamicFieldConfig,
                ParamObject            => $Self->{ParamObject},
                ReturnProfileStructure => 1,
                LayoutObject           => $Self->{LayoutObject},
            );

            # set the comple value structure in GetParam to store it later in the Notification Item
            if ( IsHashRefWithData($DynamicFieldValue) ) {

                # set search structure for display
                %DynamicFieldValues = ( %DynamicFieldValues, %{$DynamicFieldValue} );

                #make all values array refs
                for my $FieldName ( sort keys %{$DynamicFieldValue} ) {
                    if ( ref $DynamicFieldValue->{$FieldName} ne 'ARRAY' ) {
                        $DynamicFieldValue->{$FieldName} = [ $DynamicFieldValue->{$FieldName} ];
                    }
                }

                # store special structure for match
                $GetParam{Data} = { %{ $GetParam{Data} }, %{$DynamicFieldValue} };
            }
        }

        # update
        my $Ok = $Self->{NotificationEventObject}->NotificationUpdate(
            %GetParam,
            Charset => $Self->{LayoutObject}->{UserCharset},
            Type    => $NotificationType,
            UserID  => $Self->{UserID},
        );
        if ($Ok) {
            $Self->_Overview();
            my $Output = $Self->{LayoutObject}->Header();
            $Output .= $Self->{LayoutObject}->NavigationBar();
            $Output .= $Self->{LayoutObject}->Notify( Info => 'Updated!' );
            $Output .= $Self->{LayoutObject}->Output(
                TemplateFile => 'AdminNotificationEvent',
                Data         => \%Param,
            );
            $Output .= $Self->{LayoutObject}->Footer();

            return $Output;
        }
        else {
            for my $Needed (qw(Name Events Subject Body)) {
                $GetParam{ $Needed . "ServerError" } = "";
                if ( $GetParam{$Needed} eq '' ) {
                    $GetParam{ $Needed . "ServerError" } = "ServerError";
                }
            }
            my $Output = $Self->{LayoutObject}->Header();
            $Output .= $Self->{LayoutObject}->NavigationBar();
            $Output .= $Self->{LayoutObject}->Notify( Priority => 'Error' );
            $Self->_Edit(
                Action => 'Change',
                %GetParam,
                DynamicFieldValues => \%DynamicFieldValues,
            );
            $Output .= $Self->{LayoutObject}->Output(
                TemplateFile => 'AdminNotificationEvent',
                Data         => \%Param,
            );
            $Output .= $Self->{LayoutObject}->Footer();

            return $Output;
        }
    }

    # ------------------------------------------------------------ #
    # add
    # ------------------------------------------------------------ #
    elsif ( $Self->{Subaction} eq 'Add' ) {

        my $Output = $Self->{LayoutObject}->Header();
        $Output .= $Self->{LayoutObject}->NavigationBar();
        $Self->_Edit(
            Action => 'Add',
        );
        $Output .= $Self->{LayoutObject}->Output(
            TemplateFile => 'AdminNotificationEvent',
            Data         => \%Param,
        );
        $Output .= $Self->{LayoutObject}->Footer();

        return $Output;
    }

    # ------------------------------------------------------------ #
    # add action
    # ------------------------------------------------------------ #
    elsif ( $Self->{Subaction} eq 'AddAction' ) {

        # challenge token check for write action
        $Self->{LayoutObject}->ChallengeTokenCheck();

        my %GetParam;
        for my $Parameter (qw(Name Subject Body Comment ValidID Events)) {
            $GetParam{$Parameter} = $Self->{ParamObject}->GetParam( Param => $Parameter ) || '';
        }
        PARAMETER:
        for my $Parameter (
            qw(Recipients RecipientAgents RecipientRoles RecipientGroups RecipientEmail Events StateID QueueID
            PriorityID LockID TypeID ServiceID SLAID CustomerID CustomerUserID
            ArticleTypeID ArticleSubjectMatch ArticleBodyMatch ArticleAttachmentInclude
            ArticleSenderTypeID NotificationArticleTypeID)
            )
        {
            my @Data = $Self->{ParamObject}->GetArray( Param => $Parameter );
            next PARAMETER if !@Data;
            $GetParam{Data}->{$Parameter} = \@Data;
        }

        # to store dynamic fields profile data
        my %DynamicFieldValues;

        # get Dynamic fields for search from web request
        # cycle trough the activated Dynamic Fields for this screen
        DYNAMICFIELD:
        for my $DynamicFieldConfig ( @{ $Self->{DynamicField} } ) {
            next DYNAMICFIELD if !IsHashRefWithData($DynamicFieldConfig);

            # extract the dynamic field value form the web request
            my $DynamicFieldValue = $Self->{BackendObject}->SearchFieldValueGet(
                DynamicFieldConfig     => $DynamicFieldConfig,
                ParamObject            => $Self->{ParamObject},
                ReturnProfileStructure => 1,
                LayoutObject           => $Self->{LayoutObject},
            );

            # set the comple value structure in GetParam to store it later in the Generic Agent Job
            if ( IsHashRefWithData($DynamicFieldValue) ) {

                # set search structure for display
                %DynamicFieldValues = ( %DynamicFieldValues, %{$DynamicFieldValue} );

                #make all values array refs
                for my $FieldName ( sort keys %{$DynamicFieldValue} ) {
                    if ( ref $DynamicFieldValue->{$FieldName} ne 'ARRAY' ) {
                        $DynamicFieldValue->{$FieldName} = [ $DynamicFieldValue->{$FieldName} ];
                    }
                }

                # store special structure for match
                $GetParam{Data} = { %{ $GetParam{Data} }, %{$DynamicFieldValue} };
            }
        }

        # add
        my $ID = $Self->{NotificationEventObject}->NotificationAdd(
            %GetParam,
            Charset => $Self->{LayoutObject}->{UserCharset},
            Type    => $NotificationType,
            UserID  => $Self->{UserID},
        );

        if ($ID) {
            $Self->_Overview();
            my $Output = $Self->{LayoutObject}->Header();
            $Output .= $Self->{LayoutObject}->NavigationBar();
            $Output .= $Self->{LayoutObject}->Notify( Info => 'Added!' );
            $Output .= $Self->{LayoutObject}->Output(
                TemplateFile => 'AdminNotificationEvent',
                Data         => \%Param,
            );
            $Output .= $Self->{LayoutObject}->Footer();

            return $Output;
        }
        else {
            for my $Needed (qw(Name Events Subject Body)) {
                $GetParam{ $Needed . "ServerError" } = "";
                if ( $GetParam{$Needed} eq '' ) {
                    $GetParam{ $Needed . "ServerError" } = "ServerError";
                }
            }
            my $Output = $Self->{LayoutObject}->Header();
            $Output .= $Self->{LayoutObject}->NavigationBar();
            $Output .= $Self->{LayoutObject}->Notify( Priority => 'Error' );
            $Self->_Edit(
                Action => 'Add',
                %GetParam,
                DynamicFieldValues => \%DynamicFieldValues,
            );
            $Output .= $Self->{LayoutObject}->Output(
                TemplateFile => 'AdminNotificationEvent',
                Data         => \%Param,
            );
            $Output .= $Self->{LayoutObject}->Footer();

            return $Output;
        }
    }

    # ------------------------------------------------------------ #
    # delete
    # ------------------------------------------------------------ #
    if ( $Self->{Subaction} eq 'Delete' ) {

        # challenge token check for write action
        $Self->{LayoutObject}->ChallengeTokenCheck();

        my %GetParam;
        for my $Parameter (qw(ID)) {
            $GetParam{$Parameter} = $Self->{ParamObject}->GetParam( Param => $Parameter ) || '';
        }

        my $Delete = $Self->{NotificationEventObject}->NotificationDelete(
            ID     => $GetParam{ID},
            UserID => $Self->{UserID},
        );
        if ( !$Delete ) {
            return $Self->{LayoutObject}->ErrorScreen();
        }

        return $Self->{LayoutObject}->Redirect( OP => "Action=$Self->{Action}" );
    }

    # ------------------------------------------------------------
    # overview
    # ------------------------------------------------------------
    else {
        $Self->_Overview();
        my $Output = $Self->{LayoutObject}->Header();
        $Output .= $Self->{LayoutObject}->NavigationBar();
        $Output .= $Self->{LayoutObject}->Output(
            TemplateFile => 'AdminNotificationEvent',
            Data         => \%Param,
        );
        $Output .= $Self->{LayoutObject}->Footer();

        return $Output;
    }

}

sub _Edit {
    my ( $Self, %Param ) = @_;

    $Self->{LayoutObject}->Block(
        Name => 'Overview',
        Data => \%Param,
    );

    $Self->{LayoutObject}->Block( Name => 'ActionList' );
    $Self->{LayoutObject}->Block( Name => 'ActionOverview' );

    # get list type
    my $TreeView = 0;
    if ( $Self->{ConfigObject}->Get('Ticket::Frontend::ListType') eq 'tree' ) {
        $TreeView = 1;
    }

    $Param{RecipientsStrg} = $Self->{LayoutObject}->BuildSelection(
        Data => {
            AgentOwner            => 'Agent (Owner)',
            AgentResponsible      => 'Agent (Responsible)',
            AgentWritePermissions => 'Agent (All with write permissions)',
            Customer              => 'Customer',
        },
        Name       => 'Recipients',
        Multiple   => 1,
        Size       => 4,
        SelectedID => $Param{Data}->{Recipients},
    );

    my %AllAgents = $Self->{UserObject}->UserList(
        Type  => 'Long',
        Valid => 1,
    );
    $Param{RecipientAgentsStrg} = $Self->{LayoutObject}->BuildSelection(
        Data       => \%AllAgents,
        Name       => 'RecipientAgents',
        Multiple   => 1,
        Size       => 4,
        SelectedID => $Param{Data}->{RecipientAgents},
    );
    $Param{RecipientGroupsStrg} = $Self->{LayoutObject}->BuildSelection(
        Data => { $Self->{GroupObject}->GroupList( Valid => 1 ) },
        Size => 6,
        Name => 'RecipientGroups',
        Multiple   => 1,
        SelectedID => $Param{Data}->{RecipientGroups},
    );
    $Param{RecipientRolesStrg} = $Self->{LayoutObject}->BuildSelection(
        Data => { $Self->{GroupObject}->RoleList( Valid => 1 ) },
        Size => 6,
        Name => 'RecipientRoles',
        Multiple   => 1,
        SelectedID => $Param{Data}->{RecipientRoles},
    );

    # Set class name for event string...
    my $EventClass = 'Validate_Required';
    if ( $Param{EventsServerError} ) {
        $EventClass .= ' ' . $Param{EventsServerError};
    }

    my %RegisteredEvents = $Self->{EventObject}->EventList(
        ObjectTypes => [ 'Ticket', 'Article', ],
    );

    my @Events;
    for my $ObjectType ( sort keys %RegisteredEvents ) {
        push @Events, @{ $RegisteredEvents{$ObjectType} || [] };
    }

    # Build the list...
    $Param{EventsStrg} = $Self->{LayoutObject}->BuildSelection(
        Data       => \@Events,
        Name       => 'Events',
        Multiple   => 1,
        Size       => 5,
        Class      => $EventClass,
        SelectedID => $Param{Data}->{Events},
    );

    $Param{StatesStrg} = $Self->{LayoutObject}->BuildSelection(
        Data => {
            $Self->{StateObject}->StateList(
                UserID => 1,
                Action => $Self->{Action},
            ),
        },
        Name       => 'StateID',
        Multiple   => 1,
        Size       => 5,
        SelectedID => $Param{Data}->{StateID},
    );

    $Param{QueuesStrg} = $Self->{LayoutObject}->AgentQueueListOption(
        Data               => { $Self->{QueueObject}->GetAllQueues(), },
        Size               => 5,
        Multiple           => 1,
        Name               => 'QueueID',
        TreeView           => $TreeView,
        SelectedIDRefArray => $Param{Data}->{QueueID},
        OnChangeSubmit     => 0,
    );

    $Param{PrioritiesStrg} = $Self->{LayoutObject}->BuildSelection(
        Data => {
            $Self->{PriorityObject}->PriorityList(
                UserID => 1,
                Action => $Self->{Action},
            ),
        },
        Name       => 'PriorityID',
        Multiple   => 1,
        Size       => 5,
        SelectedID => $Param{Data}->{PriorityID},
    );

    $Param{LocksStrg} = $Self->{LayoutObject}->BuildSelection(
        Data => {
            $Self->{LockObject}->LockList(
                UserID => 1,
                Action => $Self->{Action},
            ),
        },
        Name       => 'LockID',
        Multiple   => 1,
        Size       => 3,
        SelectedID => $Param{Data}->{LockID},
    );

    # get valid list
    my %ValidList        = $Self->{ValidObject}->ValidList();
    my %ValidListReverse = reverse %ValidList;

    $Param{ValidOption} = $Self->{LayoutObject}->BuildSelection(
        Data       => \%ValidList,
        Name       => 'ValidID',
        SelectedID => $Param{ValidID} || $ValidListReverse{valid},
    );
    $Self->{LayoutObject}->Block(
        Name => 'OverviewUpdate',
        Data => \%Param,
    );

    # shows header
    if ( $Param{Action} eq 'Change' ) {
        $Self->{LayoutObject}->Block( Name => 'HeaderEdit' );
    }
    else {
        $Self->{LayoutObject}->Block( Name => 'HeaderAdd' );
    }

    # build type string
    if ( $Self->{ConfigObject}->Get('Ticket::Type') ) {
        my %Type = $Self->{TypeObject}->TypeList( UserID => $Self->{UserID}, );
        $Param{TypesStrg} = $Self->{LayoutObject}->BuildSelection(
            Data        => \%Type,
            Name        => 'TypeID',
            SelectedID  => $Param{Data}->{TypeID},
            Sort        => 'AlphanumericValue',
            Size        => 3,
            Multiple    => 1,
            Translation => 0,
        );
        $Self->{LayoutObject}->Block(
            Name => 'OverviewUpdateType',
            Data => \%Param,
        );
    }

    # build service string
    if ( $Self->{ConfigObject}->Get('Ticket::Service') ) {

        # get list type
        my %Service = $Self->{ServiceObject}->ServiceList(
            Valid        => 1,
            KeepChildren => 1,
            UserID       => $Self->{UserID},
        );
        $Param{ServicesStrg} = $Self->{LayoutObject}->BuildSelection(
            Data        => \%Service,
            Name        => 'ServiceID',
            SelectedID  => $Param{Data}->{ServiceID},
            Size        => 5,
            Multiple    => 1,
            Translation => 0,
            Max         => 200,
            TreeView    => $TreeView,
        );
        my %SLA = $Self->{SLAObject}->SLAList( UserID => $Self->{UserID}, );
        $Param{SLAsStrg} = $Self->{LayoutObject}->BuildSelection(
            Data        => \%SLA,
            Name        => 'SLAID',
            SelectedID  => $Param{Data}->{SLAID},
            Sort        => 'AlphanumericValue',
            Size        => 5,
            Multiple    => 1,
            Translation => 0,
            Max         => 200,
        );
        $Self->{LayoutObject}->Block(
            Name => 'OverviewUpdateService',
            Data => \%Param,
        );
    }

    # create dynamic field HTML for set with historical data options
    my $PrintDynamicFieldsSearchHeader = 1;

    # cycle trough the activated Dynamic Fields for this screen
    DYNAMICFIELD:
    for my $DynamicFieldConfig ( @{ $Self->{DynamicField} } ) {
        next DYNAMICFIELD if !IsHashRefWithData($DynamicFieldConfig);

        # skip all dynamic fields that are not designed to be notification triggers
        my $IsNotificationEventCondition = $Self->{BackendObject}->HasBehavior(
            DynamicFieldConfig => $DynamicFieldConfig,
            Behavior           => 'IsNotificationEventCondition',
        );

        next DYNAMICFIELD if !$IsNotificationEventCondition;

        # get field html
        my $DynamicFieldHTML = $Self->{BackendObject}->SearchFieldRender(
            DynamicFieldConfig     => $DynamicFieldConfig,
            Profile                => $Param{DynamicFieldValues} || {},
            LayoutObject           => $Self->{LayoutObject},
            ConfirmationCheckboxes => 1,
            UseLabelHints          => 0,
        );

        next DYNAMICFIELD if !IsHashRefWithData($DynamicFieldHTML);

        if ($PrintDynamicFieldsSearchHeader) {
            $Self->{LayoutObject}->Block( Name => 'DynamicField' );
            $PrintDynamicFieldsSearchHeader = 0;
        }

        # output dynamic field
        $Self->{LayoutObject}->Block(
            Name => 'DynamicFieldElement',
            Data => {
                Label => $DynamicFieldHTML->{Label},
                Field => $DynamicFieldHTML->{Field},
            },
        );
    }

    # add rich text editor
    if ( $Self->{RichText} ) {

        # make sure body is rich text (if body is based on config)
        if ( $Param{Type} && $Param{Type} =~ m{text\/plain}xmsi ) {
            $Param{Body} = $Self->{LayoutObject}->Ascii2RichText(
                String => $Param{Body},
            );
        }

        # use height/width defined for this screen
        $Param{RichTextHeight} = $Self->{Config}->{RichTextHeight} || 0;
        $Param{RichTextWidth}  = $Self->{Config}->{RichTextWidth}  || 0;

        $Self->{LayoutObject}->Block(
            Name => 'RichText',
            Data => \%Param,
        );
    }
    else {

        # reformat from html to plain
        if ( $Param{Type} && $Param{Type} =~ m{text\/html}xmsi && $Param{Body} ) {

            $Param{Body} = $Self->{LayoutObject}->RichText2Ascii(
                String => $Param{Body},
            );
        }
    }

    $Param{ArticleTypesStrg} = $Self->{LayoutObject}->BuildSelection(
        Data => { $Self->{TicketObject}->ArticleTypeList( Result => 'HASH' ), },
        Name => 'ArticleTypeID',
        SelectedID  => $Param{Data}->{ArticleTypeID},
        Size        => 5,
        Multiple    => 1,
        Translation => 1,
        Max         => 200,
    );

    $Param{ArticleSenderTypesStrg} = $Self->{LayoutObject}->BuildSelection(
        Data => { $Self->{TicketObject}->ArticleSenderTypeList( Result => 'HASH' ), },
        Name => 'ArticleSenderTypeID',
        SelectedID  => $Param{Data}->{ArticleSenderTypeID},
        Size        => 5,
        Multiple    => 1,
        Translation => 1,
        Max         => 200,
    );

    $Param{ArticleAttachmentIncludeStrg} = $Self->{LayoutObject}->BuildSelection(
        Data => {
            0 => 'No',
            1 => 'Yes',
        },
        Name        => 'ArticleAttachmentInclude',
        SelectedID  => $Param{Data}->{ArticleAttachmentInclude} || 0,
        Translation => 1,
        Max         => 200,
    );

    # Display article types for article creation if notification is sent
    # only use 'email-notification-*'-type articles
    my %NotificationArticleTypes = $Self->{TicketObject}->ArticleTypeList( Result => 'HASH' );
    for my $NotifArticleTypeID ( sort keys %NotificationArticleTypes ) {
        if ( $NotificationArticleTypes{$NotifArticleTypeID} !~ /^email-notification-/ ) {
            delete $NotificationArticleTypes{$NotifArticleTypeID};
        }
    }
    $Param{NotificationArticleTypesStrg} = $Self->{LayoutObject}->BuildSelection(
        Data        => \%NotificationArticleTypes,
        Name        => 'NotificationArticleTypeID',
        Translation => 1,
        SelectedID  => $Param{Data}->{NotificationArticleTypeID},
    );

    # take over data fields
    KEY:
    for my $Key (qw(RecipientEmail CustomerID CustomerUserID ArticleSubjectMatch ArticleBodyMatch))
    {
        next KEY if !$Param{Data}->{$Key};
        next KEY if !defined $Param{Data}->{$Key}->[0];
        $Param{$Key} = $Param{Data}->{$Key}->[0];
    }

    return 1;
}

sub _Overview {
    my ( $Self, %Param ) = @_;

    $Self->{LayoutObject}->Block(
        Name => 'Overview',
        Data => \%Param,
    );

    $Self->{LayoutObject}->Block( Name => 'ActionList' );
    $Self->{LayoutObject}->Block( Name => 'ActionAdd' );

    $Self->{LayoutObject}->Block(
        Name => 'OverviewResult',
        Data => \%Param,
    );
    my %List = $Self->{NotificationEventObject}->NotificationList();

    # if there are any notifications, they are shown
    if (%List) {

        # get valid list
        my %ValidList = $Self->{ValidObject}->ValidList();
        for ( sort { $List{$a} cmp $List{$b} } keys %List ) {

            my %Data = $Self->{NotificationEventObject}->NotificationGet( ID => $_, );
            $Self->{LayoutObject}->Block(
                Name => 'OverviewResultRow',
                Data => {
                    Valid => $ValidList{ $Data{ValidID} },
                    %Data,
                },
            );
        }
    }

    # otherwise a no data found msg is displayed
    else {
        $Self->{LayoutObject}->Block(
            Name => 'NoDataFoundMsg',
            Data => {},
        );
    }

    return 1;
}

1;
