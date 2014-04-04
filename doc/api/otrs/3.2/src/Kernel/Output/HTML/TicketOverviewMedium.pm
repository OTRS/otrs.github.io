# --
# Kernel/Output/HTML/TicketOverviewMedium.pm
# Copyright (C) 2001-2014 OTRS AG, http://otrs.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package Kernel::Output::HTML::TicketOverviewMedium;

use strict;
use warnings;

use Kernel::System::CustomerUser;
use Kernel::System::DynamicField;
use Kernel::System::DynamicField::Backend;
use Kernel::System::VariableCheck qw(:all);

sub new {
    my ( $Type, %Param ) = @_;

    # allocate new hash for object
    my $Self = \%Param;
    bless( $Self, $Type );

    # get needed objects
    for (
        qw(ConfigObject LogObject DBObject LayoutObject UserID UserObject GroupObject TicketObject MainObject QueueObject)
        )
    {
        $Self->{$_} = $Param{$_} || die "Got no $_!";
    }

    $Self->{CustomerUserObject} = Kernel::System::CustomerUser->new(%Param);
    $Self->{DynamicFieldObject} = Kernel::System::DynamicField->new(%Param);
    $Self->{BackendObject}      = Kernel::System::DynamicField::Backend->new(%Param);

    # get dynamic field config for frontend module
    $Self->{DynamicFieldFilter}
        = $Self->{ConfigObject}->Get("Ticket::Frontend::OverviewMedium")->{DynamicField};

    # get the dynamic fields for this screen
    $Self->{DynamicField} = $Self->{DynamicFieldObject}->DynamicFieldListGet(
        Valid       => 1,
        ObjectType  => ['Ticket'],
        FieldFilter => $Self->{DynamicFieldFilter} || {},
    );

    return $Self;
}

sub ActionRow {
    my ( $Self, %Param ) = @_;

    # check if bulk feature is enabled
    my $BulkFeature = 0;
    if ( $Param{Bulk} && $Self->{ConfigObject}->Get('Ticket::Frontend::BulkFeature') ) {
        my @Groups;
        if ( $Self->{ConfigObject}->Get('Ticket::Frontend::BulkFeatureGroup') ) {
            @Groups = @{ $Self->{ConfigObject}->Get('Ticket::Frontend::BulkFeatureGroup') };
        }
        if ( !@Groups ) {
            $BulkFeature = 1;
        }
        else {
            for my $Group (@Groups) {
                next if !$Self->{LayoutObject}->{"UserIsGroup[$Group]"};
                if ( $Self->{LayoutObject}->{"UserIsGroup[$Group]"} eq 'Yes' ) {
                    $BulkFeature = 1;
                    last;
                }
            }
        }
    }

    $Self->{LayoutObject}->Block(
        Name => 'DocumentActionRow',
        Data => \%Param,
    );

    if ($BulkFeature) {
        $Self->{LayoutObject}->Block(
            Name => 'DocumentActionRowBulk',
            Data => {
                %Param,
                Name => 'Bulk',
            },
        );
    }

    # init for table control
    $Self->{LayoutObject}->Block(
        Name => 'DocumentReadyStart',
        Data => \%Param,
    );

    my $Output = $Self->{LayoutObject}->Output(
        TemplateFile => 'AgentTicketOverviewMedium',
        Data         => \%Param,
    );

    return $Output;
}

sub SortOrderBar {
    my ( $Self, %Param ) = @_;

    return '';
}

sub Run {
    my ( $Self, %Param ) = @_;

    # check needed stuff
    for (qw(TicketIDs PageShown StartHit)) {
        if ( !$Param{$_} ) {
            $Self->{LogObject}->Log( Priority => 'error', Message => "Need $_!" );
            return;
        }
    }

    # check if bulk feature is enabled
    my $BulkFeature = 0;
    if ( $Param{Bulk} && $Self->{ConfigObject}->Get('Ticket::Frontend::BulkFeature') ) {
        my @Groups;
        if ( $Self->{ConfigObject}->Get('Ticket::Frontend::BulkFeatureGroup') ) {
            @Groups = @{ $Self->{ConfigObject}->Get('Ticket::Frontend::BulkFeatureGroup') };
        }
        if ( !@Groups ) {
            $BulkFeature = 1;
        }
        else {
            for my $Group (@Groups) {
                next if !$Self->{LayoutObject}->{"UserIsGroup[$Group]"};
                if ( $Self->{LayoutObject}->{"UserIsGroup[$Group]"} eq 'Yes' ) {
                    $BulkFeature = 1;
                    last;
                }
            }
        }
    }

    $Self->{LayoutObject}->Block(
        Name => 'DocumentHeader',
        Data => \%Param,
    );

    my $OutputMeta = $Self->{LayoutObject}->Output(
        TemplateFile => 'AgentTicketOverviewMedium',
        Data         => \%Param,
    );
    my $OutputRaw = '';
    if ( !$Param{Output} ) {
        $Self->{LayoutObject}->Print( Output => \$OutputMeta );
    }
    else {
        $OutputRaw .= $OutputMeta;
    }
    my $Output        = '';
    my $Counter       = 0;
    my $CounterOnSite = 0;
    my @TicketIDsShown;

    # check if there are tickets to show
    if ( scalar @{ $Param{TicketIDs} } ) {

        for my $TicketID ( @{ $Param{TicketIDs} } ) {
            $Counter++;
            if (
                $Counter >= $Param{StartHit}
                && $Counter < ( $Param{PageShown} + $Param{StartHit} )
                )
            {
                push @TicketIDsShown, $TicketID;
                my $Output = $Self->_Show(
                    TicketID => $TicketID,
                    Counter  => $CounterOnSite,
                    Bulk     => $BulkFeature,
                    Config   => $Param{Config},
                );
                $CounterOnSite++;
                if ( !$Param{Output} ) {
                    $Self->{LayoutObject}->Print( Output => $Output );
                }
                else {
                    $OutputRaw .= ${$Output};
                }
            }
        }
    }
    else {
        $Self->{LayoutObject}->Block( Name => 'NoTicketFound' );
    }

    # check if bulk feature is enabled
    if ($BulkFeature) {
        $Self->{LayoutObject}->Block(
            Name => 'DocumentFooter',
            Data => \%Param,
        );
        for my $TicketID (@TicketIDsShown) {
            $Self->{LayoutObject}->Block(
                Name => 'DocumentFooterBulkItem',
                Data => \%Param,
            );
        }
        my $OutputMeta = $Self->{LayoutObject}->Output(
            TemplateFile => 'AgentTicketOverviewMedium',
            Data         => \%Param,
        );
        if ( !$Param{Output} ) {
            $Self->{LayoutObject}->Print( Output => \$OutputMeta );
        }
        else {
            $OutputRaw .= $OutputMeta;
        }
    }

    # add action row js data

    return $OutputRaw;
}

sub _Show {
    my ( $Self, %Param ) = @_;

    # check needed stuff
    if ( !$Param{TicketID} ) {
        $Self->{LogObject}->Log( Priority => 'error', Message => 'Need TicketID!' );
        return;
    }

    # get move queues
    my %MoveQueues = $Self->{TicketObject}->MoveList(
        TicketID => $Param{TicketID},
        UserID   => $Self->{UserID},
        Action   => $Self->{LayoutObject}->{Action},
        Type     => 'move_into',
    );

    # get last customer article
    my %Article = $Self->{TicketObject}->ArticleLastCustomerArticle(
        TicketID      => $Param{TicketID},
        DynamicFields => 0,
    );

    # get ticket data
    my %Ticket = $Self->{TicketObject}->TicketGet(
        TicketID      => $Param{TicketID},
        DynamicFields => 0,
    );

    # Fallback for tickets without articles: get at least basic ticket data
    if ( !%Article ) {
        %Article = %Ticket;
        if ( !$Article{Title} ) {
            $Article{Title} = $Self->{LayoutObject}->{LanguageObject}->Get(
                'This ticket has no title or subject'
            );
        }
        $Article{Subject} = $Article{Title};
    }

    # show ticket create time in current view
    $Article{Created} = $Ticket{Created};

    # user info
    my %UserInfo = $Self->{UserObject}->GetUserData(
        UserID => $Article{OwnerID},
    );
    %Article = ( %UserInfo, %Article );

    # create human age
    $Article{Age} = $Self->{LayoutObject}->CustomerAge( Age => $Article{Age}, Space => ' ' );

    # fetch all std. responses ...
    my %StandardResponses
        = $Self->{QueueObject}->GetStandardResponses( QueueID => $Article{QueueID} );

    $Param{StandardResponsesStrg} = $Self->{LayoutObject}->BuildSelection(
        Name => 'ResponseID',
        Data => \%StandardResponses,
    );

    # customer info
    if ( $Param{Config}->{CustomerInfo} ) {
        if ( $Article{CustomerUserID} ) {
            $Article{CustomerName} = $Self->{CustomerUserObject}->CustomerName(
                UserLogin => $Article{CustomerUserID},
            );
        }
    }

    # get acl actions
    $Self->{TicketObject}->TicketAcl(
        Data          => '-',
        Action        => $Self->{Action},
        TicketID      => $Article{TicketID},
        ReturnType    => 'Action',
        ReturnSubType => '-',
        UserID        => $Self->{UserID},
    );
    my %AclAction = $Self->{TicketObject}->TicketAclActionData();

    # run ticket pre menu modules
    my @ActionItems;
    if ( ref $Self->{ConfigObject}->Get('Ticket::Frontend::PreMenuModule') eq 'HASH' ) {
        my %Menus = %{ $Self->{ConfigObject}->Get('Ticket::Frontend::PreMenuModule') };
        for my $Menu ( sort keys %Menus ) {

            # load module
            if ( !$Self->{MainObject}->Require( $Menus{$Menu}->{Module} ) ) {
                return $Self->{LayoutObject}->FatalError();
            }
            my $Object = $Menus{$Menu}->{Module}->new( %{$Self}, TicketID => $Param{TicketID}, );

            # run module
            my $Item = $Object->Run(
                %Param,
                Ticket => \%Article,
                ACL    => \%AclAction,
                Config => $Menus{$Menu},
            );
            next if !$Item;
            next if ref $Item ne 'HASH';
            for my $Key (qw(Name Link Description)) {
                next if !$Item->{$Key};
                $Item->{$Key} = $Self->{LayoutObject}->Output(
                    Template => $Item->{$Key},
                    Data     => \%Article,
                );
            }

            # add session id if needed
            if ( !$Self->{LayoutObject}->{SessionIDCookie} && $Item->{Link} ) {
                $Item->{Link}
                    .= ';'
                    . $Self->{LayoutObject}->{SessionName} . '='
                    . $Self->{LayoutObject}->{SessionID};
            }

            # create id
            $Item->{ID} = $Item->{Name};
            $Item->{ID} =~ s/(\s|&|;)//ig;

            $Self->{LayoutObject}->Block(
                Name => $Item->{Block} || 'DocumentMenuItem',
                Data => $Item,
            );
            my $Output = $Self->{LayoutObject}->Output(
                TemplateFile => 'AgentTicketOverviewMedium',
                Data         => $Item,
            );
            $Output =~ s/\n+//g;
            $Output =~ s/\s+/ /g;
            $Output =~ s/<\!--.+?-->//g;

            push @ActionItems, {
                HTML        => $Output,
                ID          => $Item->{ID},
                Name        => $Self->{LayoutObject}->{LanguageObject}->Get( $Item->{Name} ),
                Link        => $Self->{LayoutObject}->{Baselink} . $Item->{Link},
                Target      => $Item->{Target},
                PopupType   => $Item->{PopupType},
                Description => $Item->{Description},
                Block       => $Item->{Block} || 'DocumentMenuItem',
            };
        }
    }

    # prepare subject
    $Article{Subject} = $Self->{TicketObject}->TicketSubjectClean(
        TicketNumber => $Article{TicketNumber},
        Subject => $Article{Subject} || '',
    );

    $Self->{LayoutObject}->Block(
        Name => 'DocumentContent',
        Data => { %Param, %Article },
    );

    # if "Actions per Ticket" (Inline Action Row) is active
    if ( $Param{Config}->{TicketActionsPerTicket} ) {
        $Self->{LayoutObject}->Block(
            Name => 'InlineActionRow',
            Data => \%Param,
        );

        # Add list entries for every action
        for my $Item (@ActionItems) {
            my $Link = $Item->{Link};
            if ( $Item->{Target} ) {
                $Link = '#';
            }

            my $Class = '';
            if ( $Item->{PopupType} ) {
                $Class = 'AsPopup PopupType_' . $Item->{PopupType};
            }

            if ( $Item->{Block} eq 'DocumentMenuItem' ) {
                $Self->{LayoutObject}->Block(
                    Name => 'InlineActionRowItem',
                    Data => {
                        TicketID    => $Param{TicketID},
                        QueueID     => $Article{QueueID},
                        ID          => $Item->{ID},
                        Name        => $Item->{Name},
                        Description => $Item->{Description},
                        Class       => $Class,
                        Link        => $Link,
                    },
                );
            }
            else {
                my $TicketID   = $Param{TicketID};
                my $SelectHTML = $Item->{HTML};
                $SelectHTML =~ s/id="DestQueueID"/id="DestQueueID$TicketID"/xmig;
                $SelectHTML =~ s/for="DestQueueID"/for="DestQueueID$TicketID"/xmig;
                $Self->{LayoutObject}->Block(
                    Name => 'InlineActionRowItemHTML',
                    Data => {
                        HTML => $SelectHTML,
                    },
                );
            }
        }
    }

    # check if bulk feature is enabled
    if ( $Param{Bulk} ) {
        $Self->{LayoutObject}->Block(
            Name => 'Bulk',
            Data => \%Param,
        );
    }

    # show ticket flags
    my @TicketMetaItems = $Self->{LayoutObject}->TicketMetaItems(
        Ticket => \%Article,
    );
    for my $Item (@TicketMetaItems) {
        $Self->{LayoutObject}->Block(
            Name => 'Meta',
            Data => $Item,
        );
        if ($Item) {
            $Self->{LayoutObject}->Block(
                Name => 'MetaIcon',
                Data => $Item,
            );
        }
    }

    # run article modules
    if ( $Article{ArticleID} ) {
        if ( ref $Self->{ConfigObject}->Get('Ticket::Frontend::ArticlePreViewModule') eq 'HASH' ) {
            my %Jobs = %{ $Self->{ConfigObject}->Get('Ticket::Frontend::ArticlePreViewModule') };
            for my $Job ( sort keys %Jobs ) {

                # load module
                if ( !$Self->{MainObject}->Require( $Jobs{$Job}->{Module} ) ) {
                    return $Self->{LayoutObject}->FatalError();
                }
                my $Object = $Jobs{$Job}->{Module}->new(
                    %{$Self},
                    ArticleID => $Article{ArticleID},
                    UserID    => $Self->{UserID},
                    Debug     => $Self->{Debug},
                );

                # run module
                my @Data = $Object->Check( Article => \%Article, %Param, Config => $Jobs{$Job} );

                for my $DataRef (@Data) {
                    $Self->{LayoutObject}->Block(
                        Name => 'ArticleOption',
                        Data => $DataRef,
                    );
                }

                # filter option
                $Object->Filter( Article => \%Article, %Param, Config => $Jobs{$Job} );
            }
        }
    }

    # build header lines
    #    for (qw(From To Cc Subject)) {
    #        next if !$Article{$_};
    #        $Self->{LayoutObject}->Block(
    #            Name => 'Row',
    #            Data => {
    #                Key   => $_,
    #                Value => $Article{$_},
    #            },
    #        );
    #    }

    # create output
    $Self->{LayoutObject}->Block(
        Name => 'AgentAnswer',
        Data => { %Param, %Article, %AclAction },
    );
    if (
        $Self->{ConfigObject}->Get('Frontend::Module')->{AgentTicketCompose}
        && ( !defined $AclAction{AgentTicketCompose} || $AclAction{AgentTicketCompose} )
        )
    {
        my $Access = 1;
        my $Config = $Self->{ConfigObject}->Get("Ticket::Frontend::AgentTicketCompose");
        if ( $Config->{Permission} ) {
            my $Ok = $Self->{TicketObject}->TicketPermission(
                Type     => $Config->{Permission},
                TicketID => $Param{TicketID},
                UserID   => $Self->{UserID},
                LogNo    => 1,
            );
            if ( !$Ok ) {
                $Access = 0;
            }
            if ($Access) {
                $Self->{LayoutObject}->Block(
                    Name => 'AgentAnswerCompose',
                    Data => { %Param, %Article, %AclAction },
                );
            }
        }
    }
    if (
        $Self->{ConfigObject}->Get('Frontend::Module')->{AgentTicketPhoneOutbound}
        && (
            !defined $AclAction{AgentTicketPhoneOutbound}
            || $AclAction{AgentTicketPhoneOutbound}
        )
        )
    {
        my $Access = 1;
        my $Config = $Self->{ConfigObject}->Get("Ticket::Frontend::AgentTicketPhoneOutbound");
        if ( $Config->{Permission} ) {
            my $OK = $Self->{TicketObject}->TicketPermission(
                Type     => $Config->{Permission},
                TicketID => $Param{TicketID},
                UserID   => $Self->{UserID},
                LogNo    => 1,
            );
            if ( !$OK ) {
                $Access = 0;
            }
        }
        if ($Access) {
            $Self->{LayoutObject}->Block(
                Name => 'AgentAnswerPhoneOutbound',
                Data => { %Param, %Article, %AclAction },
            );
        }
    }

    # ticket type
    if ( $Self->{ConfigObject}->Get('Ticket::Type') ) {
        $Self->{LayoutObject}->Block(
            Name => 'Type',
            Data => { %Param, %Article },
        );
    }

    # ticket service
    if ( $Self->{ConfigObject}->Get('Ticket::Service') && $Article{Service} ) {
        $Self->{LayoutObject}->Block(
            Name => 'Service',
            Data => { %Param, %Article },
        );
        if ( $Article{SLA} ) {
            $Self->{LayoutObject}->Block(
                Name => 'SLA',
                Data => { %Param, %Article },
            );
        }
    }

    # show first response time if needed
    if ( defined $Article{FirstResponseTime} ) {
        $Article{FirstResponseTimeHuman} = $Self->{LayoutObject}->CustomerAgeInHours(
            Age   => $Article{FirstResponseTime},
            Space => ' ',
        );
        $Article{FirstResponseTimeWorkingTime} = $Self->{LayoutObject}->CustomerAgeInHours(
            Age   => $Article{FirstResponseTimeWorkingTime},
            Space => ' ',
        );
        if ( 60 * 60 * 1 > $Article{FirstResponseTime} ) {
            $Article{FirstResponseTimeClass} = 'Warning'
        }
        $Self->{LayoutObject}->Block(
            Name => 'FirstResponseTime',
            Data => { %Param, %Article },
        );
    }

    # show update time if needed
    if ( defined $Article{UpdateTime} ) {
        $Article{UpdateTimeHuman} = $Self->{LayoutObject}->CustomerAgeInHours(
            Age   => $Article{UpdateTime},
            Space => ' ',
        );
        $Article{UpdateTimeWorkingTime} = $Self->{LayoutObject}->CustomerAgeInHours(
            Age   => $Article{UpdateTimeWorkingTime},
            Space => ' ',
        );
        if ( 60 * 60 * 1 > $Article{UpdateTime} ) {
            $Article{UpdateTimeClass} = 'Warning'
        }
        $Self->{LayoutObject}->Block(
            Name => 'UpdateTime',
            Data => { %Param, %Article },
        );
    }

    # show solution time if needed
    if ( defined $Article{SolutionTime} ) {
        $Article{SolutionTimeHuman} = $Self->{LayoutObject}->CustomerAgeInHours(
            Age   => $Article{SolutionTime},
            Space => ' ',
        );
        $Article{SolutionTimeWorkingTime} = $Self->{LayoutObject}->CustomerAgeInHours(
            Age   => $Article{SolutionTimeWorkingTime},
            Space => ' ',
        );
        if ( 60 * 60 * 1 > $Article{SolutionTime} ) {
            $Article{SolutionTimeClass} = 'Warning'
        }
        $Self->{LayoutObject}->Block(
            Name => 'SolutionTime',
            Data => { %Param, %Article },
        );
    }

    # Dynamic fields
    my $Counter                  = 0;
    my $DisplayDynamicFieldTable = 1;

    # cycle trough the activated Dynamic Fields for this screen
    DYNAMICFIELD:
    for my $DynamicFieldConfig ( @{ $Self->{DynamicField} } ) {
        next DYNAMICFIELD if !IsHashRefWithData($DynamicFieldConfig);

        $Counter++;

        # get field value
        my $Value = $Self->{BackendObject}->ValueGet(
            DynamicFieldConfig => $DynamicFieldConfig,
            ObjectID           => $Param{TicketID},
        );

        next DYNAMICFIELD if ( !defined $Value );

        my $ValueStrg = $Self->{BackendObject}->DisplayValueRender(
            DynamicFieldConfig => $DynamicFieldConfig,
            Value              => $Value,
            ValueMaxChars      => 20,
            LayoutObject       => $Self->{LayoutObject},
        );

        my $Label = $DynamicFieldConfig->{Label};

        # show dynamic field table if at least one field is displayed
        if ( $DisplayDynamicFieldTable == 1 ) {
            $Self->{LayoutObject}->Block(
                Name => 'DynamicFieldTable',
                Data => {},
            );
            $DisplayDynamicFieldTable = 0;
        }

        # create a new row if counter is starting
        if ( $Counter == 1 ) {
            $Self->{LayoutObject}->Block(
                Name => 'DynamicFieldTableRow',
                Data => {},
            );
        }

        # outout dynamic field label
        $Self->{LayoutObject}->Block(
            Name => 'DynamicFieldTableRowRecord',
            Data => {
                Label => $Label,
            },
        );

        if ( $ValueStrg->{Link} ) {

            # outout dynamic field value link
            $Self->{LayoutObject}->Block(
                Name => 'DynamicFieldTableRowRecordLink',
                Data => {
                    Value                       => $ValueStrg->{Value},
                    Title                       => $ValueStrg->{Title},
                    Link                        => $ValueStrg->{Link},
                    $DynamicFieldConfig->{Name} => $ValueStrg->{Title},
                },
            );
        }
        else {

            # outout dynamic field value plain
            $Self->{LayoutObject}->Block(
                Name => 'DynamicFieldTableRowRecordPlain',
                Data => {
                    Value => $ValueStrg->{Value},
                    Title => $ValueStrg->{Title},
                },
            );
        }

        # only 5 dynamic fields by row are allowed, reset couter if needed
        if ( $Counter == 5 ) {
            $Counter = 0;
        }

        # example of dynamic fields order customization
        # outout dynamic field label
        $Self->{LayoutObject}->Block(
            Name => 'DynamicFieldTableRowRecord' . $DynamicFieldConfig->{Name},
            Data => {
                Label => $Label,
            },
        );

        if ( $ValueStrg->{Link} ) {

            # outout dynamic field value link
            $Self->{LayoutObject}->Block(
                Name => 'DynamicFieldTableRowRecord' . $DynamicFieldConfig->{Name} . 'Link',
                Data => {
                    Value                       => $ValueStrg->{Value},
                    Title                       => $ValueStrg->{Title},
                    Link                        => $ValueStrg->{Link},
                    $DynamicFieldConfig->{Name} => $ValueStrg->{Title},
                },
            );
        }
        else {

            # outout dynamic field value plain
            $Self->{LayoutObject}->Block(
                Name => 'DynamicFieldTableRowRecord' . $DynamicFieldConfig->{Name} . 'Plain',
                Data => {
                    Value => $ValueStrg->{Value},
                    Title => $ValueStrg->{Title},
                },
            );
        }
    }

    # fill the rest of the Dynamic Fields row with empty cells, this will look better
    if ( $Counter > 0 && $Counter < 5 ) {

        for ( $Counter + 1 ... 5 ) {

            # outout dynamic field label
            $Self->{LayoutObject}->Block(
                Name => 'DynamicFieldTableRowRecord',
                Data => {
                    Label => '',
                },
            );

            # outout dynamic field value plain
            $Self->{LayoutObject}->Block(
                Name => 'DynamicFieldTableRowRecordPlain',
                Data => {
                    Value => '',
                    Title => '',
                },
            );
        }
    }

    # test access to frontend module for Customer
    my $Access = $Self->{LayoutObject}->Permission(
        Action => 'AgentTicketCustomer',
        Type   => 'rw',
    );
    if ($Access) {

        # test access to ticket
        my $Config = $Self->{ConfigObject}->Get('Ticket::Frontend::AgentTicketCustomer');
        if ( $Config->{Permission} ) {
            my $OK = $Self->{TicketObject}->Permission(
                Type     => $Config->{Permission},
                TicketID => $Param{TicketID},
                UserID   => $Self->{UserID},
                LogNo    => 1,
            );
            if ( !$OK ) {
                $Access = 0;
            }
        }
    }

    # define proper DTL block based on permissions
    my $CustomerIDBlock = $Access ? 'CustomerIDRW' : 'CustomerIDRO';
    $Self->{LayoutObject}->Block(
        Name => $CustomerIDBlock,
        Data => { %Param, %Article },
    );

    # get MoveQueuesStrg
    if ( $Self->{ConfigObject}->Get('Ticket::Frontend::MoveType') =~ /^form$/i ) {
        $Param{MoveQueuesStrg} = $Self->{LayoutObject}->AgentQueueListOption(
            Name       => 'DestQueueID',
            Data       => \%MoveQueues,
            SelectedID => $Article{QueueID},
        );
    }
    if (
        $Self->{ConfigObject}->Get('Frontend::Module')->{AgentTicketMove}
        && ( !defined $AclAction{AgentTicketMove} || $AclAction{AgentTicketMove} )
        )
    {
        my $Access = $Self->{TicketObject}->TicketPermission(
            Type     => 'move',
            TicketID => $Param{TicketID},
            UserID   => $Self->{UserID},
            LogNo    => 1,
        );
        if ($Access) {
            $Self->{LayoutObject}->Block(
                Name => 'Move',
                Data => { %Param, %AclAction },
            );
        }
    }

    # add action items as js
    if ( @ActionItems && !$Param{Config}->{TicketActionsPerTicket} ) {
        my $JSON = $Self->{LayoutObject}->JSONEncode(
            Data => \@ActionItems,
        );

        $Self->{LayoutObject}->Block(
            Name => 'DocumentReadyActionRowAdd',
            Data => {
                TicketID => $Param{TicketID},
                Data     => $JSON,
            },
        );
    }

    # create & return output
    my $Output = $Self->{LayoutObject}->Output(
        TemplateFile => 'AgentTicketOverviewMedium',
        Data => { %Param, %Article, %AclAction },
    );

    return \$Output;
}
1;
