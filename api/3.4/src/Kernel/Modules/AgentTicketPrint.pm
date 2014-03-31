# --
# Kernel/Modules/AgentTicketPrint.pm - print layout for agent interface
# Copyright (C) 2001-2014 OTRS AG, http://otrs.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package Kernel::Modules::AgentTicketPrint;

use strict;
use warnings;

use Kernel::System::CustomerUser;
use Kernel::System::LinkObject;
use Kernel::System::PDF;
use Kernel::System::DynamicField;
use Kernel::System::DynamicField::Backend;
use Kernel::System::VariableCheck qw(:all);

sub new {
    my ( $Type, %Param ) = @_;

    # allocate new hash for object
    my $Self = {%Param};
    bless( $Self, $Type );

    # check needed objects
    for my $Needed (
        qw(ParamObject DBObject TicketObject LayoutObject LogObject QueueObject ConfigObject UserObject MainObject)
        )
    {
        if ( !$Self->{$Needed} ) {
            $Self->{LayoutObject}->FatalError( Message => "Got no $Needed!" );
        }
    }

    # get config settings
    $Self->{ZoomExpandSort} = $Self->{ConfigObject}->Get('Ticket::Frontend::ZoomExpandSort');

    $Self->{CustomerUserObject} = Kernel::System::CustomerUser->new(%Param);
    $Self->{LinkObject}         = Kernel::System::LinkObject->new(%Param);
    $Self->{PDFObject}          = Kernel::System::PDF->new(%Param);
    $Self->{DynamicFieldObject} = Kernel::System::DynamicField->new(%Param);
    $Self->{BackendObject}      = Kernel::System::DynamicField::Backend->new(%Param);

    # get dynamic field config for frontend module
    $Self->{DynamicFieldFilter}
        = $Self->{ConfigObject}->Get("Ticket::Frontend::AgentTicketPrint")->{DynamicField};

    return $Self;
}

sub Run {
    my ( $Self, %Param ) = @_;

    my $Output;
    my $QueueID = $Self->{TicketObject}->TicketQueueID( TicketID => $Self->{TicketID} );
    my $ArticleID = $Self->{ParamObject}->GetParam( Param => 'ArticleID' );

    # check needed stuff
    if ( !$Self->{TicketID} || !$QueueID ) {
        return $Self->{LayoutObject}->ErrorScreen( Message => 'Need TicketID!' );
    }

    # check permissions
    my $Access = $Self->{TicketObject}->TicketPermission(
        Type     => 'ro',
        TicketID => $Self->{TicketID},
        UserID   => $Self->{UserID}
    );

    return $Self->{LayoutObject}->NoPermission( WithHeader => 'yes' ) if !$Access;

    # get ACL restrictions
    $Self->{TicketObject}->TicketAcl(
        Data          => '-',
        TicketID      => $Self->{TicketID},
        ReturnType    => 'Action',
        ReturnSubType => '-',
        UserID        => $Self->{UserID},
    );
    my %AclAction = $Self->{TicketObject}->TicketAclActionData();

    # check if ACL restrictions exist
    if ( IsHashRefWithData( \%AclAction ) ) {

        # show error screen if ACL prohibits this action
        if ( defined $AclAction{ $Self->{Action} } && $AclAction{ $Self->{Action} } eq '0' ) {
            return $Self->{LayoutObject}->NoPermission( WithHeader => 'yes' );
        }
    }

    # get linked objects
    my $LinkListWithData = $Self->{LinkObject}->LinkListWithData(
        Object => 'Ticket',
        Key    => $Self->{TicketID},
        State  => 'Valid',
        UserID => $Self->{UserID},
    );

    # get link type list
    my %LinkTypeList = $Self->{LinkObject}->TypeList(
        UserID => $Self->{UserID},
    );

    # get the link data
    my %LinkData;
    if ( $LinkListWithData && ref $LinkListWithData eq 'HASH' && %{$LinkListWithData} ) {
        %LinkData = $Self->{LayoutObject}->LinkObjectTableCreate(
            LinkListWithData => $LinkListWithData,
            ViewMode         => 'SimpleRaw',
        );
    }

    # get content
    my %Ticket = $Self->{TicketObject}->TicketGet(
        TicketID => $Self->{TicketID},
        UserID   => $Self->{UserID},
    );
    my @ArticleBox = $Self->{TicketObject}->ArticleContentIndex(
        TicketID                   => $Self->{TicketID},
        StripPlainBodyAsAttachment => 1,
        UserID                     => $Self->{UserID},
        DynamicFields              => 0,
    );

    # check if only one article need printed
    if ($ArticleID) {

        ARTICLE:
        for my $Article (@ArticleBox) {
            if ( $Article->{ArticleID} == $ArticleID ) {
                @ArticleBox = ($Article);
                last ARTICLE;
            }
        }
    }

    # resort article order
    if ( $Self->{ZoomExpandSort} eq 'reverse' ) {
        @ArticleBox = reverse(@ArticleBox);
    }

    # show total accounted time if feature is active:
    if ( $Self->{ConfigObject}->Get('Ticket::Frontend::AccountTime') ) {
        $Ticket{TicketTimeUnits} = $Self->{TicketObject}->TicketAccountedTimeGet(
            TicketID => $Ticket{TicketID},
        );
    }

    # user info
    my %UserInfo = $Self->{UserObject}->GetUserData(
        User => $Ticket{Owner},
    );

    # responsible info
    my %ResponsibleInfo;
    if ( $Self->{ConfigObject}->Get('Ticket::Responsible') && $Ticket{Responsible} ) {
        %ResponsibleInfo = $Self->{UserObject}->GetUserData(
            User => $Ticket{Responsible},
        );
    }

    # customer info
    my %CustomerData;
    if ( $Ticket{CustomerUserID} ) {
        %CustomerData = $Self->{CustomerUserObject}->CustomerUserDataGet(
            User => $Ticket{CustomerUserID},
        );
    }

    # do some html quoting
    $Ticket{Age} = $Self->{LayoutObject}->CustomerAge(
        Age   => $Ticket{Age},
        Space => ' ',
    );

    if ( $Ticket{UntilTime} ) {
        $Ticket{PendingUntil} = $Self->{LayoutObject}->CustomerAge(
            Age   => $Ticket{UntilTime},
            Space => ' ',
        );
    }

    # generate pdf output
    if ( $Self->{PDFObject} ) {
        my $PrintedBy = $Self->{LayoutObject}->{LanguageObject}->Translate('printed by');
        my $Time      = $Self->{LayoutObject}->{Time};
        my %Page;

        # get maximum number of pages
        $Page{MaxPages} = $Self->{ConfigObject}->Get('PDF::MaxPages');
        if ( !$Page{MaxPages} || $Page{MaxPages} < 1 || $Page{MaxPages} > 1000 ) {
            $Page{MaxPages} = 100;
        }
        my $HeaderRight  = $Self->{ConfigObject}->Get('Ticket::Hook') . $Ticket{TicketNumber};
        my $HeadlineLeft = $HeaderRight;
        my $Title        = $HeaderRight;
        if ( $Ticket{Title} ) {
            $HeadlineLeft = $Ticket{Title};
            $Title .= ' / ' . $Ticket{Title};
        }

        $Page{MarginTop}    = 30;
        $Page{MarginRight}  = 40;
        $Page{MarginBottom} = 40;
        $Page{MarginLeft}   = 40;
        $Page{HeaderRight}  = $HeaderRight;
        $Page{FooterLeft}   = '';
        $Page{PageText}     = $Self->{LayoutObject}->{LanguageObject}->Translate('Page');
        $Page{PageCount}    = 1;

        # create new pdf document
        $Self->{PDFObject}->DocumentNew(
            Title  => $Self->{ConfigObject}->Get('Product') . ': ' . $Title,
            Encode => $Self->{LayoutObject}->{UserCharset},
        );

        # create first pdf page
        $Self->{PDFObject}->PageNew(
            %Page, FooterRight => $Page{PageText} . ' ' . $Page{PageCount},
        );
        $Page{PageCount}++;

        $Self->{PDFObject}->PositionSet(
            Move => 'relativ',
            Y    => -6,
        );

        # output title
        $Self->{PDFObject}->Text(
            Text     => $Ticket{Title},
            FontSize => 13,
        );

        $Self->{PDFObject}->PositionSet(
            Move => 'relativ',
            Y    => -6,
        );

        # output "printed by"
        $Self->{PDFObject}->Text(
            Text => $PrintedBy . ' '
                . $Self->{UserFirstname} . ' '
                . $Self->{UserLastname} . ' ('
                . $Self->{UserEmail} . ')'
                . ', ' . $Time,
            FontSize => 9,
        );

        $Self->{PDFObject}->PositionSet(
            Move => 'relativ',
            Y    => -14,
        );

        # output ticket infos
        $Self->_PDFOutputTicketInfos(
            PageData        => \%Page,
            TicketData      => \%Ticket,
            UserData        => \%UserInfo,
            ResponsibleData => \%ResponsibleInfo,
        );

        # output ticket dynamic fields
        $Self->_PDFOutputTicketDynamicFields(
            PageData   => \%Page,
            TicketData => \%Ticket,
        );

        # output linked objects
        if (%LinkData) {
            $Self->_PDFOutputLinkedObjects(
                PageData     => \%Page,
                LinkData     => \%LinkData,
                LinkTypeList => \%LinkTypeList,
            );
        }

        # output customer infos
        if (%CustomerData) {
            $Self->_PDFOutputCustomerInfos(
                PageData     => \%Page,
                CustomerData => \%CustomerData,
            );
        }

        # output articles
        $Self->_PDFOutputArticles(
            PageData    => \%Page,
            ArticleData => \@ArticleBox,
        );

        # return the pdf document
        my $Filename = 'Ticket_' . $Ticket{TicketNumber};
        my ( $s, $m, $h, $D, $M, $Y ) = $Self->{TimeObject}->SystemTime2Date(
            SystemTime => $Self->{TimeObject}->SystemTime(),
        );
        $M = sprintf( "%02d", $M );
        $D = sprintf( "%02d", $D );
        $h = sprintf( "%02d", $h );
        $m = sprintf( "%02d", $m );
        my $PDFString = $Self->{PDFObject}->DocumentOutput();
        return $Self->{LayoutObject}->Attachment(
            Filename    => $Filename . "_" . "$Y-$M-$D" . "_" . "$h-$m.pdf",
            ContentType => "application/pdf",
            Content     => $PDFString,
            Type        => 'attachment',
        );
    }

    # generate html output
    else {

        # output header
        $Output .= $Self->{LayoutObject}->PrintHeader( Value => $Ticket{TicketNumber} );

        if (%LinkData) {

            # output link data
            $Self->{LayoutObject}->Block(
                Name => 'Link',
            );

            for my $LinkTypeLinkDirection ( sort { lc $a cmp lc $b } keys %LinkData ) {

                # investigate link type name
                my @LinkData = split q{::}, $LinkTypeLinkDirection;

                # output link type data
                $Self->{LayoutObject}->Block(
                    Name => 'LinkType',
                    Data => {
                        LinkTypeName => $LinkTypeList{ $LinkData[0] }->{ $LinkData[1] . 'Name' },
                    },
                );

                # extract object list
                my $ObjectList = $LinkData{$LinkTypeLinkDirection};

                for my $Object ( sort { lc $a cmp lc $b } keys %{$ObjectList} ) {

                    for my $Item ( @{ $ObjectList->{$Object} } ) {

                        # output link type data
                        $Self->{LayoutObject}->Block(
                            Name => 'LinkTypeRow',
                            Data => {
                                LinkStrg => $Item->{Title},
                            },
                        );
                    }
                }
            }
        }

        # output customer infos
        if (%CustomerData) {
            $Param{CustomerTable} = $Self->{LayoutObject}->AgentCustomerViewTable(
                Data => \%CustomerData,
                Max  => 100,
            );
        }

        # show ticket
        $Output .= $Self->_HTMLMask(
            TicketID        => $Self->{TicketID},
            QueueID         => $QueueID,
            ArticleBox      => \@ArticleBox,
            ResponsibleData => \%ResponsibleInfo,
            %Param,
            %UserInfo,
            %Ticket,
        );

        # add footer
        $Output .= $Self->{LayoutObject}->PrintFooter();

        # return output
        return $Output;
    }
}

sub _PDFOutputTicketInfos {
    my ( $Self, %Param ) = @_;

    # check needed stuff
    for my $Needed (qw(PageData TicketData UserData)) {
        if ( !defined( $Param{$Needed} ) ) {
            $Self->{LogObject}->Log( Priority => 'error', Message => "Need $Needed!" );
            return;
        }
    }
    my %Ticket   = %{ $Param{TicketData} };
    my %UserInfo = %{ $Param{UserData} };
    my %Page     = %{ $Param{PageData} };

    # create left table
    my $TableLeft = [
        {
            Key   => $Self->{LayoutObject}->{LanguageObject}->Translate('State'),
            Value => $Self->{LayoutObject}->{LanguageObject}->Translate( $Ticket{State} ),
        },
        {
            Key   => $Self->{LayoutObject}->{LanguageObject}->Translate('Priority'),
            Value => $Self->{LayoutObject}->{LanguageObject}->Translate( $Ticket{Priority} ),
        },
        {
            Key   => $Self->{LayoutObject}->{LanguageObject}->Translate('Queue'),
            Value => $Ticket{Queue},
        },
        {
            Key   => $Self->{LayoutObject}->{LanguageObject}->Translate('Lock'),
            Value => $Self->{LayoutObject}->{LanguageObject}->Translate( $Ticket{Lock} ),
        },
        {
            Key   => $Self->{LayoutObject}->{LanguageObject}->Translate('CustomerID'),
            Value => $Ticket{CustomerID},
        },
        {
            Key   => $Self->{LayoutObject}->{LanguageObject}->Translate('Owner'),
            Value => $Ticket{Owner} . ' ('
                . $UserInfo{UserFirstname} . ' '
                . $UserInfo{UserLastname} . ')',
        },
    ];

    # add responsible row, if feature is enabled
    if ( $Self->{ConfigObject}->Get('Ticket::Responsible') ) {
        my $Responsible = '-';
        if ( $Ticket{Responsible} ) {
            $Responsible
                = $Ticket{Responsible} . ' ('
                . $Param{ResponsibleData}->{UserFirstname} . ' '
                . $Param{ResponsibleData}->{UserLastname} . ')';
        }
        my $Row = {
            Key   => $Self->{LayoutObject}->{LanguageObject}->Translate('Responsible'),
            Value => $Responsible,
        };
        push( @{$TableLeft}, $Row );
    }

    # add type row, if feature is enabled
    if ( $Self->{ConfigObject}->Get('Ticket::Type') ) {
        my $Row = {
            Key   => $Self->{LayoutObject}->{LanguageObject}->Translate('Type'),
            Value => $Ticket{Type},
        };
        push( @{$TableLeft}, $Row );
    }

    # add service and sla row, if feature is enabled
    if ( $Self->{ConfigObject}->Get('Ticket::Service') ) {
        my $RowService = {
            Key => $Self->{LayoutObject}->{LanguageObject}->Translate('Service'),
            Value => $Ticket{Service} || '-',
        };
        push( @{$TableLeft}, $RowService );
        my $RowSLA = {
            Key => $Self->{LayoutObject}->{LanguageObject}->Translate('SLA'),
            Value => $Ticket{SLA} || '-',
        };
        push( @{$TableLeft}, $RowSLA );
    }

    # create right table
    my $TableRight = [
        {
            Key   => $Self->{LayoutObject}->{LanguageObject}->Translate('Age'),
            Value => $Self->{LayoutObject}->{LanguageObject}->Translate( $Ticket{Age} ),
        },
        {
            Key   => $Self->{LayoutObject}->{LanguageObject}->Translate('Created'),
            Value => $Self->{LayoutObject}->{LanguageObject}->FormatTimeString(
                $Ticket{Created},
                'DateFormat',
            ),
        },
    ];

    if ( $Self->{ConfigObject}->Get('Ticket::Frontend::AccountTime') ) {
        my $Row = {
            Key   => $Self->{LayoutObject}->{LanguageObject}->Translate('Accounted time'),
            Value => $Ticket{TicketTimeUnits},
        };
        push( @{$TableRight}, $Row );
    }

    # only show pending until unless it is really pending
    if ( $Ticket{PendingUntil} ) {
        my $Row = {
            Key   => $Self->{LayoutObject}->{LanguageObject}->Translate('Pending till'),
            Value => $Ticket{PendingUntil},
        };
        push( @{$TableRight}, $Row );
    }

    # add first response time row
    if ( defined( $Ticket{FirstResponseTime} ) ) {
        my $Row = {
            Key   => $Self->{LayoutObject}->{LanguageObject}->Translate('First Response Time'),
            Value => $Self->{LayoutObject}->{LanguageObject}->FormatTimeString(
                $Ticket{FirstResponseTimeDestinationDate},
                'DateFormat',
                'NoSeconds',
            ),
        };
        push( @{$TableRight}, $Row );
    }

    # add update time row
    if ( defined( $Ticket{UpdateTime} ) ) {
        my $Row = {
            Key   => $Self->{LayoutObject}->{LanguageObject}->Translate('Update Time'),
            Value => $Self->{LayoutObject}->{LanguageObject}->FormatTimeString(
                $Ticket{UpdateTimeDestinationDate},
                'DateFormat',
                'NoSeconds',
            ),
        };
        push( @{$TableRight}, $Row );
    }

    # add solution time row
    if ( defined( $Ticket{SolutionTime} ) ) {
        my $Row = {
            Key   => $Self->{LayoutObject}->{LanguageObject}->Translate('Solution Time'),
            Value => $Self->{LayoutObject}->{LanguageObject}->FormatTimeString(
                $Ticket{SolutionTimeDestinationDate},
                'DateFormat',
                'NoSeconds',
            ),
        };
        push( @{$TableRight}, $Row );
    }

    my $Rows = @{$TableLeft};
    if ( @{$TableRight} > $Rows ) {
        $Rows = @{$TableRight};
    }

    my %TableParam;
    for my $Row ( 1 .. $Rows ) {
        $Row--;
        $TableParam{CellData}[$Row][0]{Content}         = $TableLeft->[$Row]->{Key};
        $TableParam{CellData}[$Row][0]{Font}            = 'ProportionalBold';
        $TableParam{CellData}[$Row][1]{Content}         = $TableLeft->[$Row]->{Value};
        $TableParam{CellData}[$Row][2]{Content}         = ' ';
        $TableParam{CellData}[$Row][2]{BackgroundColor} = '#FFFFFF';
        $TableParam{CellData}[$Row][3]{Content}         = $TableRight->[$Row]->{Key};
        $TableParam{CellData}[$Row][3]{Font}            = 'ProportionalBold';
        $TableParam{CellData}[$Row][4]{Content}         = $TableRight->[$Row]->{Value};
    }

    $TableParam{ColumnData}[0]{Width} = 70;
    $TableParam{ColumnData}[1]{Width} = 156.5;
    $TableParam{ColumnData}[2]{Width} = 1;
    $TableParam{ColumnData}[3]{Width} = 70;
    $TableParam{ColumnData}[4]{Width} = 156.5;

    $TableParam{Type}                = 'Cut';
    $TableParam{Border}              = 0;
    $TableParam{FontSize}            = 7;
    $TableParam{BackgroundColorEven} = '#DDDDDD';
    $TableParam{Padding}             = 6;
    $TableParam{PaddingTop}          = 3;
    $TableParam{PaddingBottom}       = 3;

    # output table
    PAGE:
    for ( $Page{PageCount} .. $Page{MaxPages} ) {

        # output table (or a fragment of it)
        %TableParam = $Self->{PDFObject}->Table( %TableParam, );

        # stop output or output next page
        if ( $TableParam{State} ) {
            last PAGE;
        }
        else {
            $Self->{PDFObject}->PageNew(
                %Page, FooterRight => $Page{PageText} . ' ' . $Page{PageCount},
            );
            $Page{PageCount}++;
        }
    }
    return 1;
}

sub _PDFOutputLinkedObjects {
    my ( $Self, %Param ) = @_;

    # check needed stuff
    for my $Needed (qw(PageData LinkData LinkTypeList)) {
        if ( !defined( $Param{$Needed} ) ) {
            $Self->{LogObject}->Log( Priority => 'error', Message => "Need $Needed!" );
            return;
        }
    }

    my %Page     = %{ $Param{PageData} };
    my %TypeList = %{ $Param{LinkTypeList} };
    my %TableParam;
    my $Row = 0;

    for my $LinkTypeLinkDirection ( sort { lc $a cmp lc $b } keys %{ $Param{LinkData} } ) {

        # investigate link type name
        my @LinkData = split q{::}, $LinkTypeLinkDirection;
        my $LinkTypeName = $TypeList{ $LinkData[0] }->{ $LinkData[1] . 'Name' };
        $LinkTypeName = $Self->{LayoutObject}->{LanguageObject}->Translate($LinkTypeName);

        # define headline
        $TableParam{CellData}[$Row][0]{Content} = $LinkTypeName . ':';
        $TableParam{CellData}[$Row][0]{Font}    = 'ProportionalBold';
        $TableParam{CellData}[$Row][1]{Content} = '';

        # extract object list
        my $ObjectList = $Param{LinkData}->{$LinkTypeLinkDirection};

        for my $Object ( sort { lc $a cmp lc $b } keys %{$ObjectList} ) {

            for my $Item ( @{ $ObjectList->{$Object} } ) {

                $TableParam{CellData}[$Row][0]{Content} ||= '';
                $TableParam{CellData}[$Row][1]{Content} = $Item->{Title} || '';
            }
            continue {
                $Row++;
            }
        }
    }

    $TableParam{ColumnData}[0]{Width} = 80;
    $TableParam{ColumnData}[1]{Width} = 431;

    # set new position
    $Self->{PDFObject}->PositionSet(
        Move => 'relativ',
        Y    => -15,
    );

    # output headline
    $Self->{PDFObject}->Text(
        Text     => $Self->{LayoutObject}->{LanguageObject}->Translate('Linked Objects'),
        Height   => 7,
        Type     => 'Cut',
        Font     => 'ProportionalBoldItalic',
        FontSize => 7,
        Color    => '#666666',
    );

    # set new position
    $Self->{PDFObject}->PositionSet(
        Move => 'relativ',
        Y    => -4,
    );

    # table params
    $TableParam{Type}            = 'Cut';
    $TableParam{Border}          = 0;
    $TableParam{FontSize}        = 6;
    $TableParam{BackgroundColor} = '#DDDDDD';
    $TableParam{Padding}         = 1;
    $TableParam{PaddingTop}      = 3;
    $TableParam{PaddingBottom}   = 3;

    # output table
    PAGE:
    for ( $Page{PageCount} .. $Page{MaxPages} ) {

        # output table (or a fragment of it)
        %TableParam = $Self->{PDFObject}->Table( %TableParam, );

        # stop output or output next page
        if ( $TableParam{State} ) {
            last PAGE;
        }
        else {
            $Self->{PDFObject}->PageNew(
                %Page, FooterRight => $Page{PageText} . ' ' . $Page{PageCount},
            );
            $Page{PageCount}++;
        }
    }

    return 1;
}

sub _PDFOutputTicketDynamicFields {
    my ( $Self, %Param ) = @_;

    # check needed stuff
    for my $Needed (qw(PageData TicketData)) {
        if ( !defined( $Param{$Needed} ) ) {
            $Self->{LogObject}->Log( Priority => 'error', Message => "Need $Needed!" );
            return;
        }
    }
    my $Output = 0;
    my %Ticket = %{ $Param{TicketData} };
    my %Page   = %{ $Param{PageData} };

    my %TableParam;
    my $Row = 0;

    # get the dynamic fields for ticket object
    my $DynamicField = $Self->{DynamicFieldObject}->DynamicFieldListGet(
        Valid       => 1,
        ObjectType  => ['Ticket'],
        FieldFilter => $Self->{DynamicFieldFilter} || {},
    );

    # generate table
    # cycle trough the activated Dynamic Fields for ticket object
    DYNAMICFIELD:
    for my $DynamicFieldConfig ( @{$DynamicField} ) {
        next DYNAMICFIELD if !IsHashRefWithData($DynamicFieldConfig);

        my $Value = $Self->{BackendObject}->ValueGet(
            DynamicFieldConfig => $DynamicFieldConfig,
            ObjectID           => $Ticket{TicketID},
        );

        next DYNAMICFIELD if !$Value;
        next DYNAMICFIELD if $Value eq "";

        # get print string for this dynamic field
        my $ValueStrg = $Self->{BackendObject}->DisplayValueRender(
            DynamicFieldConfig => $DynamicFieldConfig,
            Value              => $Value,
            HTMLOutput         => 0,
            LayoutObject       => $Self->{LayoutObject},
        );

        $TableParam{CellData}[$Row][0]{Content}
            = $Self->{LayoutObject}->{LanguageObject}->Translate( $DynamicFieldConfig->{Label} )
            . ':';
        $TableParam{CellData}[$Row][0]{Font}    = 'ProportionalBold';
        $TableParam{CellData}[$Row][1]{Content} = $ValueStrg->{Value};

        $Row++;
        $Output = 1;
    }

    $TableParam{ColumnData}[0]{Width} = 80;
    $TableParam{ColumnData}[1]{Width} = 431;

    # output ticket dynamic fields
    if ($Output) {

        # set new position
        $Self->{PDFObject}->PositionSet(
            Move => 'relativ',
            Y    => -15,
        );

        # output headline
        $Self->{PDFObject}->Text(
            Text     => $Self->{LayoutObject}->{LanguageObject}->Translate('Ticket Dynamic Fields'),
            Height   => 7,
            Type     => 'Cut',
            Font     => 'ProportionalBoldItalic',
            FontSize => 7,
            Color    => '#666666',
        );

        # set new position
        $Self->{PDFObject}->PositionSet(
            Move => 'relativ',
            Y    => -4,
        );

        # table params
        $TableParam{Type}            = 'Cut';
        $TableParam{Border}          = 0;
        $TableParam{FontSize}        = 6;
        $TableParam{BackgroundColor} = '#DDDDDD';
        $TableParam{Padding}         = 1;
        $TableParam{PaddingTop}      = 3;
        $TableParam{PaddingBottom}   = 3;

        # output table
        PAGE:
        for ( $Page{PageCount} .. $Page{MaxPages} ) {

            # output table (or a fragment of it)
            %TableParam = $Self->{PDFObject}->Table( %TableParam, );

            # stop output or output next page
            if ( $TableParam{State} ) {
                last PAGE;
            }
            else {
                $Self->{PDFObject}->PageNew(
                    %Page, FooterRight => $Page{PageText} . ' ' . $Page{PageCount},
                );
                $Page{PageCount}++;
            }
        }
    }
    return 1;
}

sub _PDFOutputCustomerInfos {
    my ( $Self, %Param ) = @_;

    # check needed stuff
    for my $Needed (qw(PageData CustomerData)) {
        if ( !defined( $Param{$Needed} ) ) {
            $Self->{LogObject}->Log( Priority => 'error', Message => "Need $Needed!" );
            return;
        }
    }
    my $Output       = 0;
    my %CustomerData = %{ $Param{CustomerData} };
    my %Page         = %{ $Param{PageData} };
    my %TableParam;
    my $Row = 0;
    my $Map = $CustomerData{Config}->{Map};

    # check if customer company support is enabled
    if ( $CustomerData{Config}->{CustomerCompanySupport} ) {
        my $Map2 = $CustomerData{CompanyConfig}->{Map};
        if ($Map2) {
            push( @{$Map}, @{$Map2} );
        }
    }
    for my $Field ( @{$Map} ) {
        if ( ${$Field}[3] && $CustomerData{ ${$Field}[0] } ) {
            $TableParam{CellData}[$Row][0]{Content}
                = $Self->{LayoutObject}->{LanguageObject}->Translate( ${$Field}[1] ) . ':';
            $TableParam{CellData}[$Row][0]{Font}    = 'ProportionalBold';
            $TableParam{CellData}[$Row][1]{Content} = $CustomerData{ ${$Field}[0] };

            $Row++;
            $Output = 1;
        }
    }
    $TableParam{ColumnData}[0]{Width} = 80;
    $TableParam{ColumnData}[1]{Width} = 431;

    if ($Output) {

        # set new position
        $Self->{PDFObject}->PositionSet(
            Move => 'relativ',
            Y    => -15,
        );

        # output headline
        $Self->{PDFObject}->Text(
            Text     => $Self->{LayoutObject}->{LanguageObject}->Translate('Customer Information'),
            Height   => 7,
            Type     => 'Cut',
            Font     => 'ProportionalBoldItalic',
            FontSize => 7,
            Color    => '#666666',
        );

        # set new position
        $Self->{PDFObject}->PositionSet(
            Move => 'relativ',
            Y    => -4,
        );

        # table params
        $TableParam{Type}            = 'Cut';
        $TableParam{Border}          = 0;
        $TableParam{FontSize}        = 6;
        $TableParam{BackgroundColor} = '#DDDDDD';
        $TableParam{Padding}         = 1;
        $TableParam{PaddingTop}      = 3;
        $TableParam{PaddingBottom}   = 3;

        # output table
        PAGE:
        for ( $Page{PageCount} .. $Page{MaxPages} ) {

            # output table (or a fragment of it)
            %TableParam = $Self->{PDFObject}->Table( %TableParam, );

            # stop output or output next page
            if ( $TableParam{State} ) {
                last PAGE;
            }
            else {
                $Self->{PDFObject}->PageNew(
                    %Page, FooterRight => $Page{PageText} . ' ' . $Page{PageCount},
                );
                $Page{PageCount}++;
            }
        }
    }
    return 1;
}

sub _PDFOutputArticles {
    my ( $Self, %Param ) = @_;

    # check needed stuff
    for my $Needed (qw(PageData ArticleData)) {
        if ( !defined( $Param{$Needed} ) ) {
            $Self->{LogObject}->Log( Priority => 'error', Message => "Need $Needed!" );
            return;
        }
    }
    my %Page = %{ $Param{PageData} };

    my $ArticleCounter = 1;
    for my $ArticleTmp ( @{ $Param{ArticleData} } ) {
        if ( $ArticleCounter == 1 ) {
            $Self->{PDFObject}->PositionSet(
                Move => 'relativ',
                Y    => -15,
            );

            # output headline
            $Self->{PDFObject}->Text(
                Text     => $Self->{LayoutObject}->{LanguageObject}->Translate('Articles'),
                Height   => 7,
                Type     => 'Cut',
                Font     => 'ProportionalBoldItalic',
                FontSize => 7,
                Color    => '#666666',
            );
            $Self->{PDFObject}->PositionSet(
                Move => 'relativ',
                Y    => 2,
            );
        }

        my %Article = %{$ArticleTmp};

        # get attachment string
        my %AtmIndex = ();
        if ( $Article{Atms} ) {
            %AtmIndex = %{ $Article{Atms} };
        }
        my $Attachments;
        for my $FileID ( sort keys %AtmIndex ) {
            my %File = %{ $AtmIndex{$FileID} };
            $Attachments .= $File{Filename} . ' (' . $File{Filesize} . ")\n";
        }

        # show total accounted time if feature is active:
        if ( $Self->{ConfigObject}->Get('Ticket::Frontend::AccountTime') ) {
            $Article{'Accounted time'} = $Self->{TicketObject}->ArticleAccountedTimeGet(
                ArticleID => $Article{ArticleID},
            );
        }

        # generate article info table
        my %TableParam1;
        my $Row = 0;

        $Self->{PDFObject}->PositionSet(
            Move => 'relativ',
            Y    => -6,
        );

        # article number tag
        $Self->{PDFObject}->Text(
            Text     => '    # ' . $ArticleCounter,
            Height   => 7,
            Type     => 'Cut',
            Font     => 'ProportionalBoldItalic',
            FontSize => 7,
            Color    => '#666666',
        );

        $Self->{PDFObject}->PositionSet(
            Move => 'relativ',
            Y    => 2,
        );

        for my $Parameter ( 'From', 'To', 'Cc', 'Accounted time', 'Subject', ) {
            if ( $Article{$Parameter} ) {
                $TableParam1{CellData}[$Row][0]{Content}
                    = $Self->{LayoutObject}->{LanguageObject}->Translate($Parameter) . ':';
                $TableParam1{CellData}[$Row][0]{Font}    = 'ProportionalBold';
                $TableParam1{CellData}[$Row][1]{Content} = $Article{$Parameter};
                $Row++;
            }
        }
        $TableParam1{CellData}[$Row][0]{Content}
            = $Self->{LayoutObject}->{LanguageObject}->Translate('Created') . ':';
        $TableParam1{CellData}[$Row][0]{Font} = 'ProportionalBold';
        $TableParam1{CellData}[$Row][1]{Content}
            = $Self->{LayoutObject}->{LanguageObject}->FormatTimeString(
            $Article{Created},
            'DateFormat',
            );
        $TableParam1{CellData}[$Row][1]{Content}
            .= ' ' . $Self->{LayoutObject}->{LanguageObject}->Translate('by');
        $TableParam1{CellData}[$Row][1]{Content}
            .= ' ' . $Self->{LayoutObject}->{LanguageObject}->Translate( $Article{SenderType} );
        $Row++;

        # get the dynamic fields for ticket object
        my $DynamicField = $Self->{DynamicFieldObject}->DynamicFieldListGet(
            Valid       => 1,
            ObjectType  => ['Article'],
            FieldFilter => $Self->{DynamicFieldFilter} || {},
        );

        # generate table
        # cycle trough the activated Dynamic Fields for ticket object
        DYNAMICFIELD:
        for my $DynamicFieldConfig ( @{$DynamicField} ) {
            next DYNAMICFIELD if !IsHashRefWithData($DynamicFieldConfig);

            my $Value = $Self->{BackendObject}->ValueGet(
                DynamicFieldConfig => $DynamicFieldConfig,
                ObjectID           => $Article{ArticleID},
            );

            next DYNAMICFIELD if !$Value;
            next DYNAMICFIELD if $Value eq "";

            # get print string for this dynamic field
            my $ValueStrg = $Self->{BackendObject}->DisplayValueRender(
                DynamicFieldConfig => $DynamicFieldConfig,
                Value              => $Value,
                HTMLOutput         => 0,
                LayoutObject       => $Self->{LayoutObject},
            );
            $TableParam1{CellData}[$Row][0]{Content}
                = $Self->{LayoutObject}->{LanguageObject}->Translate( $DynamicFieldConfig->{Label} )
                . ':';
            $TableParam1{CellData}[$Row][0]{Font}    = 'ProportionalBold';
            $TableParam1{CellData}[$Row][1]{Content} = $ValueStrg->{Value};
            $Row++;
        }

        $TableParam1{CellData}[$Row][0]{Content}
            = $Self->{LayoutObject}->{LanguageObject}->Translate('Type') . ':';
        $TableParam1{CellData}[$Row][0]{Font} = 'ProportionalBold';
        $TableParam1{CellData}[$Row][1]{Content}
            = $Self->{LayoutObject}->{LanguageObject}->Translate( $Article{ArticleType} );
        $Row++;

        if ($Attachments) {
            $TableParam1{CellData}[$Row][0]{Content}
                = $Self->{LayoutObject}->{LanguageObject}->Translate('Attachment') . ':';
            $TableParam1{CellData}[$Row][0]{Font} = 'ProportionalBold';
            chomp($Attachments);
            $TableParam1{CellData}[$Row][1]{Content} = $Attachments;
        }
        $TableParam1{ColumnData}[0]{Width} = 80;
        $TableParam1{ColumnData}[1]{Width} = 431;

        $Self->{PDFObject}->PositionSet(
            Move => 'relativ',
            Y    => -6,
        );

        # table params (article infos)
        $TableParam1{Type}            = 'Cut';
        $TableParam1{Border}          = 0;
        $TableParam1{FontSize}        = 6;
        $TableParam1{BackgroundColor} = '#DDDDDD';
        $TableParam1{Padding}         = 1;
        $TableParam1{PaddingTop}      = 3;
        $TableParam1{PaddingBottom}   = 3;

        # output table (article infos)
        PAGE:
        for ( $Page{PageCount} .. $Page{MaxPages} ) {

            # output table (or a fragment of it)
            %TableParam1 = $Self->{PDFObject}->Table( %TableParam1, );

            # stop output or output next page
            if ( $TableParam1{State} ) {
                last PAGE;
            }
            else {
                $Self->{PDFObject}->PageNew(
                    %Page, FooterRight => $Page{PageText} . ' ' . $Page{PageCount},
                );
                $Page{PageCount}++;
            }
        }

        # table params (article body)
        my %TableParam2;
        $TableParam2{CellData}[0][0]{Content} = $Article{Body} || ' ';
        $TableParam2{Type}                    = 'Cut';
        $TableParam2{Border}                  = 0;
        $TableParam2{Font}                    = 'Monospaced';
        $TableParam2{FontSize}                = 7;
        $TableParam2{BackgroundColor}         = '#DDDDDD';
        $TableParam2{Padding}                 = 4;
        $TableParam2{PaddingTop}              = 8;
        $TableParam2{PaddingBottom}           = 8;

        # output table (article body)
        PAGE:
        for ( $Page{PageCount} .. $Page{MaxPages} ) {

            # output table (or a fragment of it)
            %TableParam2 = $Self->{PDFObject}->Table( %TableParam2, );

            # stop output or output next page
            if ( $TableParam2{State} ) {
                last PAGE;
            }
            else {
                $Self->{PDFObject}->PageNew(
                    %Page, FooterRight => $Page{PageText} . ' ' . $Page{PageCount},
                );
                $Page{PageCount}++;
            }
        }
        $ArticleCounter++;
    }
    return 1;
}

sub _HTMLMask {
    my ( $Self, %Param ) = @_;

    # output responsible, if feature is enabled
    if ( $Self->{ConfigObject}->Get('Ticket::Responsible') ) {
        my $Responsible = '-';
        if ( $Param{Responsible} ) {
            $Responsible
                = $Param{Responsible} . ' ('
                . $Param{ResponsibleData}->{UserFirstname} . ' '
                . $Param{ResponsibleData}->{UserLastname} . ')';
        }
        $Self->{LayoutObject}->Block(
            Name => 'Responsible',
            Data => { ResponsibleString => $Responsible, },
        );
    }

    # output type, if feature is enabled
    if ( $Self->{ConfigObject}->Get('Ticket::Type') ) {
        $Self->{LayoutObject}->Block(
            Name => 'TicketType',
            Data => { %Param, },
        );
    }

    # output service and sla, if feature is enabled
    if ( $Self->{ConfigObject}->Get('Ticket::Service') ) {
        $Self->{LayoutObject}->Block(
            Name => 'TicketService',
            Data => {
                Service => $Param{Service} || '-',
                SLA     => $Param{SLA}     || '-',
            },
        );
    }

    # output accounted time
    if ( $Self->{ConfigObject}->Get('Ticket::Frontend::AccountTime') ) {
        $Self->{LayoutObject}->Block(
            Name => 'AccountedTime',
            Data => {%Param},
        );
    }

    # output pending date
    if ( $Param{PendingUntil} ) {
        $Self->{LayoutObject}->Block(
            Name => 'PendingUntil',
            Data => {%Param},
        );
    }

    # output first response time
    if ( defined( $Param{FirstResponseTime} ) ) {
        $Self->{LayoutObject}->Block(
            Name => 'FirstResponseTime',
            Data => {%Param},
        );
    }

    # output update time
    if ( defined( $Param{UpdateTime} ) ) {
        $Self->{LayoutObject}->Block(
            Name => 'UpdateTime',
            Data => {%Param},
        );
    }

    # output solution time
    if ( defined( $Param{SolutionTime} ) ) {
        $Self->{LayoutObject}->Block(
            Name => 'SolutionTime',
            Data => {%Param},
        );
    }

    # get the dynamic fields for ticket object
    my $DynamicField = $Self->{DynamicFieldObject}->DynamicFieldListGet(
        Valid       => 1,
        ObjectType  => ['Ticket'],
        FieldFilter => $Self->{DynamicFieldFilter} || {},
    );

    # cycle trough the activated Dynamic Fields for ticket object
    DYNAMICFIELD:
    for my $DynamicFieldConfig ( @{$DynamicField} ) {
        next DYNAMICFIELD if !IsHashRefWithData($DynamicFieldConfig);

        my $Value = $Self->{BackendObject}->ValueGet(
            DynamicFieldConfig => $DynamicFieldConfig,
            ObjectID           => $Param{TicketID},
        );

        next DYNAMICFIELD if !$Value;
        next DYNAMICFIELD if $Value eq "";

        # get print string for this dynamic field
        my $ValueStrg = $Self->{BackendObject}->DisplayValueRender(
            DynamicFieldConfig => $DynamicFieldConfig,
            Value              => $Value,
            HTMLOutput         => 1,
            ValueMaxChars      => 20,
            LayoutObject       => $Self->{LayoutObject},
        );

        my $Label = $DynamicFieldConfig->{Label};

        $Self->{LayoutObject}->Block(
            Name => 'TicketDynamicField',
            Data => {
                Label => $Label,
                Value => $ValueStrg->{Value},
                Title => $ValueStrg->{Title},
            },
        );

        # example of dynamic fields order customization
        $Self->{LayoutObject}->Block(
            Name => 'TicketDynamicField_' . $DynamicFieldConfig->{Name},
            Data => {
                Label => $Label,
                Value => $ValueStrg->{Value},
                Title => $ValueStrg->{Title},
            },
        );
    }

    # build article stuff
    my $SelectedArticleID = $Param{ArticleID} || '';
    my @ArticleBox = @{ $Param{ArticleBox} };

    # get last customer article
    for my $ArticleTmp (@ArticleBox) {
        my %Article = %{$ArticleTmp};

        # get attachment string
        my %AtmIndex = ();
        if ( $Article{Atms} ) {
            %AtmIndex = %{ $Article{Atms} };
        }
        $Param{'Article::ATM'} = '';
        for my $FileID ( sort keys %AtmIndex ) {
            my %File = %{ $AtmIndex{$FileID} };
            $File{Filename} = $Self->{LayoutObject}->Ascii2Html( Text => $File{Filename} );
            my $DownloadText = $Self->{LayoutObject}->{LanguageObject}->Translate("Download");
            $Param{'Article::ATM'}
                .= '<a href="' . $Self->{LayoutObject}->{Baselink} . 'Action=AgentTicketAttachment;'
                . "ArticleID=$Article{ArticleID};FileID=$FileID\" target=\"attachment\" "
                . "title=\"$DownloadText: $File{Filename}\">"
                . "$File{Filename}</a> $File{Filesize}<br/>";
        }

        # check if just a only html email
        my $MimeTypeText = $Self->{LayoutObject}->CheckMimeType(
            %Param,
            %Article,
            Action => 'AgentTicketZoom',
        );
        if ($MimeTypeText) {
            $Param{TextNote} = $MimeTypeText;
            $Article{Body}   = '';
        }
        else {

            # html quoting
            $Article{Body} = $Self->{LayoutObject}->Ascii2Html(
                NewLine => $Self->{ConfigObject}->Get('DefaultViewNewLine'),
                Text    => $Article{Body},
                VMax    => $Self->{ConfigObject}->Get('DefaultViewLines') || 5000,
            );
        }
        $Self->{LayoutObject}->Block(
            Name => 'Article',
            Data => { %Param, %Article },
        );

        # do some strips && quoting
        for my $Parameter (qw(From To Cc Subject)) {
            if ( $Article{$Parameter} ) {
                $Self->{LayoutObject}->Block(
                    Name => 'Row',
                    Data => {
                        Key   => $Parameter,
                        Value => $Article{$Parameter},
                    },
                );
            }
        }

        # show accounted article time
        if ( $Self->{ConfigObject}->Get('Ticket::ZoomTimeDisplay') ) {
            my $ArticleTime = $Self->{TicketObject}->ArticleAccountedTimeGet(
                ArticleID => $Article{ArticleID},
            );
            $Self->{LayoutObject}->Block(
                Name => "Row",
                Data => {
                    Key   => 'Time',
                    Value => $ArticleTime,
                },
            );
        }

        # get the dynamic fields for ticket object
        my $DynamicField = $Self->{DynamicFieldObject}->DynamicFieldListGet(
            Valid       => 1,
            ObjectType  => ['Article'],
            FieldFilter => $Self->{DynamicFieldFilter} || {},
        );

        # cycle trough the activated Dynamic Fields for ticket object
        DYNAMICFIELD:
        for my $DynamicFieldConfig ( @{$DynamicField} ) {
            next DYNAMICFIELD if !IsHashRefWithData($DynamicFieldConfig);

            my $Value = $Self->{BackendObject}->ValueGet(
                DynamicFieldConfig => $DynamicFieldConfig,
                ObjectID           => $Article{ArticleID},
            );

            next DYNAMICFIELD if !$Value;
            next DYNAMICFIELD if $Value eq "";

            # get print string for this dynamic field
            my $ValueStrg = $Self->{BackendObject}->DisplayValueRender(
                DynamicFieldConfig => $DynamicFieldConfig,
                Value              => $Value,
                HTMLOutput         => 1,
                ValueMaxChars      => 20,
                LayoutObject       => $Self->{LayoutObject},
            );

            my $Label = $DynamicFieldConfig->{Label};

            $Self->{LayoutObject}->Block(
                Name => 'ArticleDynamicField',
                Data => {
                    Label => $Label,
                    Value => $ValueStrg->{Value},
                    Title => $ValueStrg->{Title},
                },
            );

            # example of dynamic fields order customization
            #            $Self->{LayoutObject}->Block(
            #                Name => 'ArticleDynamicField_' . $DynamicFieldConfig->{Name},
            #                Data => {
            #                    Label => $Label,
            #                    Value => $ValueStrg->{Value},
            #                    Title => $ValueStrg->{Title},
            #                },
            #            );
        }
    }

    return $Self->{LayoutObject}->Output(
        TemplateFile => 'AgentTicketPrint',
        Data         => \%Param,
    );
}

1;
