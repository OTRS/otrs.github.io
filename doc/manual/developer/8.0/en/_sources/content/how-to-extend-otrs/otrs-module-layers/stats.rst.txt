Stats Module
============

There are two different types of internal stats modules - dynamic and static. This section describes how such stats modules can be developed.


Dynamic Stats
-------------

In contrast to static stats modules, dynamic statistics can be configured via the OTRS web interface. In this section a simple statistic module is developed. Each dynamic stats module has to implement these subroutines:

-  ``new``
-  ``GetObjectName``
-  ``GetObjectAttributes``
-  ``ExportWrapper``
-  ``ImportWrapper``

Furthermore the module has to implement either ``GetStatElement`` or ``GetStatTable``. And if the header line of the result table should be changed, a sub called ``GetHeaderLine`` has to be developed.


Stats Code Example
~~~~~~~~~~~~~~~~~~

In this section a sample stats module is shown and each subroutine is explained.

.. code-block:: Perl

   # --
   # Kernel/System/Stats/Dynamic/DynamicStatsTemplate.pm - all advice functions
   # Copyright (C) 2001-2018 OTRS AG, https://otrs.com/
   # --
   # This software comes with ABSOLUTELY NO WARRANTY. For details, see
   # the enclosed file COPYING for license information (GPL). If you
   # did not receive this file, see https://www.gnu.org/licenses/gpl-3.0.txt.
   # --

   package Kernel::System::Stats::Dynamic::DynamicStatsTemplate;

   use strict;
   use warnings;

   use Kernel::System::Queue;
   use Kernel::System::State;
   use Kernel::System::Ticket;

This is a common boilerplate that can be found in common OTRS modules. The class/package name is declared via the ``package`` keyword. Then the needed modules are used via the ``use`` keyword.

.. code-block:: Perl

   sub new {
       my ( $Type, %Param ) = @_;

       # allocate new hash for object
       my $Self = {};
       bless( $Self, $Type );

       # check needed objects
       for my $Object (
           qw(DBObject ConfigObject LogObject UserObject TimeObject MainObject EncodeObject)
           )
       {
           $Self->{$Object} = $Param{$Object} || die "Got no $Object!";
       }

       # created needed objects
       $Self->{QueueObject}    = Kernel::System::Queue->new( %{$Self} );
       $Self->{TicketObject}   = Kernel::System::Ticket->new( %{$Self} );
       $Self->{StateObject}    = Kernel::System::State->new( %{$Self} );

       return $Self;
   }

The ``new`` is the constructor for this statistic module. It creates a new instance of the class. According to the coding guidelines objects of other classes that are needed in this module have to be created in ``new``. In lines 27 to 29 the object of the stats module is created. Lines 31 to 37 check if objects that are needed in this code - either for creating other objects or in this module - are passed. After that the other objects are created.

.. code-block:: Perl

   sub GetObjectName {
       my ( $Self, %Param ) = @_;

       return 'Sample Statistics';
   }

``GetObjectName`` returns a name for the statistics module. This is the label that is shown in the drop down in the configuration as well as in the list of existing statistics (column *object*).

.. code-block:: Perl

   sub GetObjectAttributes {
       my ( $Self, %Param ) = @_;

       # get state list
       my %StateList = $Self->{StateObject}->StateList(
           UserID => 1,
       );

       # get queue list
       my %QueueList = $Self->{QueueObject}->GetAllQueues();

       # get current time to fix bug#3830
       my $TimeStamp = $Self->{TimeObject}->CurrentTimestamp();
       my ($Date) = split /\s+/, $TimeStamp;
       my $Today = sprintf "%s 23:59:59", $Date;

       my @ObjectAttributes = (
           {
               Name             => 'State',
               UseAsXvalue      => 1,
               UseAsValueSeries => 1,
               UseAsRestriction => 1,
               Element          => 'StateIDs',
               Block            => 'MultiSelectField',
               Values           => \%StateList,
           },
           {
               Name             => 'Created in Queue',
               UseAsXvalue      => 1,
               UseAsValueSeries => 1,
               UseAsRestriction => 1,
               Element          => 'CreatedQueueIDs',
               Block            => 'MultiSelectField',
               Translation      => 0,
               Values           => \%QueueList,
           },
           {
               Name             => 'Create Time',
               UseAsXvalue      => 1,
               UseAsValueSeries => 1,
               UseAsRestriction => 1,
               Element          => 'CreateTime',
               TimePeriodFormat => 'DateInputFormat',    # 'DateInputFormatLong',
               Block            => 'Time',
               TimeStop         => $Today,
               Values           => {
                   TimeStart => 'TicketCreateTimeNewerDate',
                   TimeStop  => 'TicketCreateTimeOlderDate',
               },
           },
       );

       return @ObjectAttributes;
   }

In this sample stats module, we want to provide three attributes the user can chose from: a list of queues, a list of states and a time drop down. To get the values shown in the drop down, some operations are needed. In this case ``StateList`` and ``GetAllQueues`` are called.

Then the list of attributes is created. Each attribute is defined via a hash reference. You can use these keys:

``Name``
   The label in the web interface.

``UseAsXvalue``
   This attribute can be used on the x-axis.

``UseAsValueSeries``
   This attribute can be used on the y-axis.

``UseAsRestriction``
   This attribute can be used for restrictions.

``Element``
   The HTML field name.

``Block``
   The block name in the template file (e.g. ``<OTRS_HOME>/Kernel/Output/HTML/Standard/AgentStatsEditXaxis.tt``).

``Values``
   The values shown in the attribute.

Hint: If you install this sample and you configure a statistic with some queues - lets say 'queue A' and 'queue B' - then these queues are the only ones that are shown to the user when he starts the statistic. Sometimes a dynamic drop down or multiselect field is needed. In this case, you can set ``SelectedValues`` in the definition of the attribute:

.. code-block:: Perl

           {
               Name             => 'Created in Queue',
               UseAsXvalue      => 1,
               UseAsValueSeries => 1,
               UseAsRestriction => 1,
               Element          => 'CreatedQueueIDs',
               Block            => 'MultiSelectField',
               Translation      => 0,
               Values           => \%QueueList,
               SelectedValues   => [ @SelectedQueues ],
           },

.. code-block:: Perl

   sub GetStatElement {
       my ( $Self, %Param ) = @_;

       # search tickets
       return $Self->{TicketObject}->TicketSearch(
           UserID     => 1,
           Result     => 'COUNT',
           Permission => 'ro',
           Limit      => 100_000_000,
           %Param,
       );
   }

``GetStatElement`` gets called for each cell in the result table. So it should be a numeric value. In this sample it does a simple ticket search. The hash ``%Param`` contains information about the *current* x-value and the y-value as well as any restrictions. So, for a cell that should count the created tickets for queue *Misc* with state *open* the passed parameter hash looks something like this:

.. code-block:: Perl

       'CreatedQueueIDs' => [
           '4'
       ],
       'StateIDs' => [
           '2'
       ]

If the *per cell* calculation should be avoided, ``GetStatTable`` is an alternative. ``GetStatTable`` returns a list of rows, hence an array of array references. This leads to the same result as using ``GetStatElement``.

.. code-block:: Perl

   sub GetStatTable {
       my ( $Self, %Param ) = @_;

       my @StatData;

       for my $StateName ( keys %{ $Param{TableStructure} } ) {
           my @Row;
           for my $Params ( @{ $Param{TableStructure}->{$StateName} } ) {
               my $Tickets = $Self->{TicketObject}->TicketSearch(
                   UserID     => 1,
                   Result     => 'COUNT',
                   Permission => 'ro',
                   Limit      => 100_000_000,
                   %{$Params},
               );

               push @Row, $Tickets;
           }

           push @StatData, [ $StateName, @Row ];
       }

       return @StatData;
   }

``GetStatTable`` gets all information about the stats query that is needed. The passed parameters contain information about the attributes (``Restrictions``, attributes that are used for x/y-axis) and the table structure. The table structure is a hash reference where the keys are the values of the y-axis and their values are hash references with the parameters used for ``GetStatElement`` subroutines.

.. code-block:: Perl

       'Restrictions' => {},
       'TableStructure' => {
           'closed successful' => [
               {
                   'CreatedQueueIDs' => [
                       '3'
                   ],
                   'StateIDs' => [
                       '2'
                   ]
               },
           ],
           'closed unsuccessful' => [
               {
                   'CreatedQueueIDs' => [
                       '3'
                   ],
                   'StateIDs' => [
                       '3'
                   ]
               },
           ],
       },
       'ValueSeries' => [
           {
               'Block' => 'MultiSelectField',
               'Element' => 'StateIDs',
               'Name' => 'State',
               'SelectedValues' => [
                   '5',
                   '3',
                   '2',
                   '1',
                   '4'
               ],
               'Translation' => 1,
               'Values' => {
                   '1' => 'new',
                   '10' => 'closed with workaround',
                   '2' => 'closed successful',
                   '3' => 'closed unsuccessful',
                   '4' => 'open',
                   '5' => 'removed',
                   '6' => 'pending reminder',
                   '7' => 'pending auto close+',
                   '8' => 'pending auto close-',
                   '9' => 'merged'
               }
           }
       ],
       'XValue' => {
           'Block' => 'MultiSelectField',
           'Element' => 'CreatedQueueIDs',
           'Name' => 'Created in Queue',
           'SelectedValues' => [
               '3',
               '4',
               '1',
               '2'
           ],
           'Translation' => 0,
           'Values' => {
               '1' => 'Postmaster',
               '2' => 'Raw',
               '3' => 'Junk',
               '4' => 'Misc'
           }
       }

Sometimes the headers of the table have to be changed. In that case, a subroutine called ``GetHeaderLine`` has to be implemented. That subroutine has to return an array reference with the column headers as elements. It gets information about the x-values passed.

.. code-block:: Perl

   sub GetHeaderLine {
       my ( $Self, %Param ) = @_;

       my @HeaderLine = ('');
       for my $SelectedXValue ( @{ $Param{XValue}->{SelectedValues} } ) {
           push @HeaderLine, $Param{XValue}->{Values}->{$SelectedXValue};
       }

       return \@HeaderLine;
   }

.. code-block:: Perl

   sub ExportWrapper {
       my ( $Self, %Param ) = @_;

       # wrap ids to used spelling
       for my $Use (qw(UseAsValueSeries UseAsRestriction UseAsXvalue)) {
           ELEMENT:
           for my $Element ( @{ $Param{$Use} } ) {
               next ELEMENT if !$Element || !$Element->{SelectedValues};
               my $ElementName = $Element->{Element};
               my $Values      = $Element->{SelectedValues};

               if ( $ElementName eq 'QueueIDs' || $ElementName eq 'CreatedQueueIDs' ) {
                   ID:
                   for my $ID ( @{$Values} ) {
                       next ID if !$ID;
                       $ID->{Content} = $Self->{QueueObject}->QueueLookup( QueueID => $ID->{Content} );
                   }
               }
               elsif ( $ElementName eq 'StateIDs' || $ElementName eq 'CreatedStateIDs' ) {
                   my %StateList = $Self->{StateObject}->StateList( UserID => 1 );
                   ID:
                   for my $ID ( @{$Values} ) {
                       next ID if !$ID;
                       $ID->{Content} = $StateList{ $ID->{Content} };
                   }
               }
           }
       }
       return \%Param;
   }

Configured statistics can be exported into XML format. But as queues with the same queue names can have different IDs on different OTRS instances it would be quite painful to export the IDs (the statistics would calculate the wrong numbers then). So an export wrapper should be written to use the names instead of ids. This should be done for each *dimension* of the stats module (x-axis, y-axis and restrictions).

``ImportWrapper`` works the other way around - it converts the name to the ID in the instance the configuration is imported to.

This is a sample export:

.. code-block:: XML

   <?xml version="1.0" encoding="utf-8"?>

   <otrs_stats>
   <Cache>0</Cache>
   <Description>Sample stats module</Description>
   <File></File>
   <Format>CSV</Format>
   <Format>Print</Format>
   <Object>DeveloperManualSample</Object>
   <ObjectModule>Kernel::System::Stats::Dynamic::DynamicStatsTemplate</ObjectModule>
   <ObjectName>Sample Statistics</ObjectName>
   <Permission>stats</Permission>
   <StatType>dynamic</StatType>
   <SumCol>0</SumCol>
   <SumRow>0</SumRow>
   <Title>Sample 1</Title>
   <UseAsValueSeries Element="StateIDs" Fixed="1">
   <SelectedValues>removed</SelectedValues>
   <SelectedValues>closed unsuccessful</SelectedValues>
   <SelectedValues>closed successful</SelectedValues>
   <SelectedValues>new</SelectedValues>
   <SelectedValues>open</SelectedValues>
   </UseAsValueSeries>
   <UseAsXvalue Element="CreatedQueueIDs" Fixed="1">
   <SelectedValues>Junk</SelectedValues>
   <SelectedValues>Misc</SelectedValues>
   <SelectedValues>Postmaster</SelectedValues>
   <SelectedValues>Raw</SelectedValues>
   </UseAsXvalue>
   <Valid>1</Valid>
   </otrs_stats>

Now, that all subroutines are explained, this is the complete sample stats module.

.. code-block:: Perl

   # --
   # Kernel/System/Stats/Dynamic/DynamicStatsTemplate.pm - all advice functions
   # Copyright (C) 2001-2018 OTRS AG, https://otrs.com/
   # --
   # This software comes with ABSOLUTELY NO WARRANTY. For details, see
   # the enclosed file COPYING for license information (GPL). If you
   # did not receive this file, see https://www.gnu.org/licenses/gpl-3.0.txt.
   # --

   package Kernel::System::Stats::Dynamic::DynamicStatsTemplate;

   use strict;
   use warnings;

   use Kernel::System::Queue;
   use Kernel::System::State;
   use Kernel::System::Ticket;

   sub new {
       my ( $Type, %Param ) = @_;

       # allocate new hash for object
       my $Self = {};
       bless( $Self, $Type );

       # check needed objects
       for my $Object (
           qw(DBObject ConfigObject LogObject UserObject TimeObject MainObject EncodeObject)
           )
       {
           $Self->{$Object} = $Param{$Object} || die "Got no $Object!";
       }

       # created needed objects
       $Self->{QueueObject}    = Kernel::System::Queue->new( %{$Self} );
       $Self->{TicketObject}   = Kernel::System::Ticket->new( %{$Self} );
       $Self->{StateObject}    = Kernel::System::State->new( %{$Self} );

       return $Self;
   }

   sub GetObjectName {
       my ( $Self, %Param ) = @_;

       return 'Sample Statistics';
   }

   sub GetObjectAttributes {
       my ( $Self, %Param ) = @_;

       # get state list
       my %StateList = $Self->{StateObject}->StateList(
           UserID => 1,
       );

       # get queue list
       my %QueueList = $Self->{QueueObject}->GetAllQueues();

       # get current time to fix bug#3830
       my $TimeStamp = $Self->{TimeObject}->CurrentTimestamp();
       my ($Date) = split /\s+/, $TimeStamp;
       my $Today = sprintf "%s 23:59:59", $Date;

       my @ObjectAttributes = (
           {
               Name             => 'State',
               UseAsXvalue      => 1,
               UseAsValueSeries => 1,
               UseAsRestriction => 1,
               Element          => 'StateIDs',
               Block            => 'MultiSelectField',
               Values           => \%StateList,
           },
           {
               Name             => 'Created in Queue',
               UseAsXvalue      => 1,
               UseAsValueSeries => 1,
               UseAsRestriction => 1,
               Element          => 'CreatedQueueIDs',
               Block            => 'MultiSelectField',
               Translation      => 0,
               Values           => \%QueueList,
           },
           {
               Name             => 'Create Time',
               UseAsXvalue      => 1,
               UseAsValueSeries => 1,
               UseAsRestriction => 1,
               Element          => 'CreateTime',
               TimePeriodFormat => 'DateInputFormat',    # 'DateInputFormatLong',
               Block            => 'Time',
               TimeStop         => $Today,
               Values           => {
                   TimeStart => 'TicketCreateTimeNewerDate',
                   TimeStop  => 'TicketCreateTimeOlderDate',
               },
           },
       );

       return @ObjectAttributes;
   }

   sub GetStatElement {
       my ( $Self, %Param ) = @_;

       # search tickets
       return $Self->{TicketObject}->TicketSearch(
           UserID     => 1,
           Result     => 'COUNT',
           Permission => 'ro',
           Limit      => 100_000_000,
           %Param,
       );
   }

   sub ExportWrapper {
       my ( $Self, %Param ) = @_;

       # wrap ids to used spelling
       for my $Use (qw(UseAsValueSeries UseAsRestriction UseAsXvalue)) {
           ELEMENT:
           for my $Element ( @{ $Param{$Use} } ) {
               next ELEMENT if !$Element || !$Element->{SelectedValues};
               my $ElementName = $Element->{Element};
               my $Values      = $Element->{SelectedValues};

               if ( $ElementName eq 'QueueIDs' || $ElementName eq 'CreatedQueueIDs' ) {
                   ID:
                   for my $ID ( @{$Values} ) {
                       next ID if !$ID;
                       $ID->{Content} = $Self->{QueueObject}->QueueLookup( QueueID => $ID->{Content} );
                   }
               }
               elsif ( $ElementName eq 'StateIDs' || $ElementName eq 'CreatedStateIDs' ) {
                   my %StateList = $Self->{StateObject}->StateList( UserID => 1 );
                   ID:
                   for my $ID ( @{$Values} ) {
                       next ID if !$ID;
                       $ID->{Content} = $StateList{ $ID->{Content} };
                   }
               }
           }
       }
       return \%Param;
   }

   sub ImportWrapper {
       my ( $Self, %Param ) = @_;

       # wrap used spelling to ids
       for my $Use (qw(UseAsValueSeries UseAsRestriction UseAsXvalue)) {
           ELEMENT:
           for my $Element ( @{ $Param{$Use} } ) {
               next ELEMENT if !$Element || !$Element->{SelectedValues};
               my $ElementName = $Element->{Element};
               my $Values      = $Element->{SelectedValues};

               if ( $ElementName eq 'QueueIDs' || $ElementName eq 'CreatedQueueIDs' ) {
                   ID:
                   for my $ID ( @{$Values} ) {
                       next ID if !$ID;
                       if ( $Self->{QueueObject}->QueueLookup( Queue => $ID->{Content} ) ) {
                           $ID->{Content}
                               = $Self->{QueueObject}->QueueLookup( Queue => $ID->{Content} );
                       }
                       else {
                           $Self->{LogObject}->Log(
                               Priority => 'error',
                               Message  => "Import: Can' find the queue $ID->{Content}!"
                           );
                           $ID = undef;
                       }
                   }
               }
               elsif ( $ElementName eq 'StateIDs' || $ElementName eq 'CreatedStateIDs' ) {
                   ID:
                   for my $ID ( @{$Values} ) {
                       next ID if !$ID;

                       my %State = $Self->{StateObject}->StateGet(
                           Name  => $ID->{Content},
                           Cache => 1,
                       );
                       if ( $State{ID} ) {
                           $ID->{Content} = $State{ID};
                       }
                       else {
                           $Self->{LogObject}->Log(
                               Priority => 'error',
                               Message  => "Import: Can' find state $ID->{Content}!"
                           );
                           $ID = undef;
                       }
                   }
               }
           }
       }
       return \%Param;
   }

   1;


Stats Configuration Example
~~~~~~~~~~~~~~~~~~~~~~~~~~~

.. code-block:: XML

   <?xml version="1.0" encoding="utf-8" ?>
   <otrs_config version="1.0" init="Config">
       <ConfigItem Name="Stats::DynamicObjectRegistration###DynamicStatsTemplate" Required="0" Valid="1">
           <Description Lang="en">Here you can decide if the common stats module may generate stats about the number of default tickets a requester created.</Description>
           <Group>Framework</Group>
           <SubGroup>Core::Stats</SubGroup>
           <Setting>
               <Hash>
                   <Item Key="Module">Kernel::System::Stats::Dynamic::DynamicStatsTemplate</Item>
               </Hash>
           </Setting>
       </ConfigItem>
   </otrs_config>

.. note::

   If you have a lot of cells in the result table and the ``GetStatElement`` is quite complex, the request can take a long time.


Static Stats
------------

The subsequent paragraphs describe the static stats. Static stats are very easy to create as these modules have to implement only three subroutines.

-  ``new``
-  ``Param``
-  ``Run``


Static Stats Code Example
~~~~~~~~~~~~~~~~~~~~~~~~~

The following paragraphs describe the subroutines needed in a static stats.

.. code-block:: Perl

   sub new {
       my ( $Type, %Param ) = @_;

       # allocate new hash for object
       my $Self = {%Param};
       bless( $Self, $Type );

       # check all needed objects
       for my $Needed (
           qw(DBObject ConfigObject LogObject
           TimeObject MainObject EncodeObject)
           )
       {
           $Self->{$Needed} = $Param{$Needed} || die "Got no $Needed";
       }

       # create needed objects
       $Self->{TypeObject}   = Kernel::System::Type->new( %{$Self} );
       $Self->{TicketObject} = Kernel::System::Ticket->new( %{$Self} );
       $Self->{QueueObject}  = Kernel::System::Queue->new( %{$Self} );

       return $Self;
   }

The ``new`` creates a new instance of the static stats class. First it creates a new object and then it checks for the needed objects.

.. code-block:: Perl

   sub Param {
       my $Self = shift;

       my %Queues = $Self->{QueueObject}->GetAllQueues();
       my %Types  = $Self->{TypeObject}->TypeList(
           Valid => 1,
       );

       my @Params = (
           {
               Frontend  => 'Type',
               Name      => 'TypeIDs',
               Multiple  => 1,
               Size      => 3,
               Data      => \%Types,
           },
           {
               Frontend  => 'Queue',
               Name      => 'QueueIDs',
               Multiple  => 1,
               Size      => 3,
               Data      => \%Queues,
           },
       );

       return @Params;
   }

The ``Param`` method provides the list of all parameters/attributes that can be selected to create a static stat. It gets some parameters passed: The values for the stats attributes provided in a request, the format of the stats and the name of the object (name of the module).

The parameters/attributes have to be hash references with these key-value pairs:

``Frontend``
   The label in the web interface.

``Name``
   The HTML field name.

``Data``
   The values shown in the attribute.

Other parameter for the ``BuildSelection`` method of the ``LayoutObject`` can be used, as it is done with ``Size`` and ``Multiple`` in this sample module.

.. code-block:: Perl

   sub Run {
       my ( $Self, %Param ) = @_;

       # check needed stuff
       for my $Needed (qw(TypeIDs QueueIDs)) {
           if ( !$Param{$Needed} ) {
               $Self->{LogObject}->Log(
                   Priority => 'error',
                   Message  => "Need $Needed!",
               );
               return;
           }
       }

       # set report title
       my $Title = 'Tickets per Queue';

       # table headlines
       my @HeadData = (
           'Ticket Number',
           'Queue',
           'Type',
       );

       my @Data;
       my @TicketIDs = $Self->{TicketObject}->TicketSearch(
           UserID     => 1,
           Result     => 'ARRAY',
           Permission => 'ro',
           %Param,
       );

       for my $TicketID ( @TicketIDs ) {
           my %Ticket = $Self->{TicketObject}->TicketGet(
               UserID => 1,
               TicketID => $TicketID,
           );
           push @Data, [ $Ticket{TicketNumber}, $Ticket{Queue}, $Ticket{Type} ];
       }

       return ( [$Title], [@HeadData], @Data );
   }

The ``Run`` method actually generates the table data for the stats. It gets the attributes for this stats passed. In this sample in ``%Param`` a key ``TypeIDs`` and a key ``QueueIDs`` exist (see attributes in ``Param`` method) and their values are array references. The returned data consists of three parts: Two array references and an array. In the first array reference the title for the statistic is stored, the second array reference contains the headlines for the columns in the table. And then the data for the table body follow.

.. code-block:: Perl

   # --
   # Kernel/System/Stats/Static/StaticStatsTemplate.pm
   # Copyright (C) 2001-2018 OTRS AG, https://otrs.com/
   # --
   # This software comes with ABSOLUTELY NO WARRANTY. For details, see
   # the enclosed file COPYING for license information (GPL). If you
   # did not receive this file, see https://www.gnu.org/licenses/gpl-3.0.txt.
   # --

   package Kernel::System::Stats::Static::StaticStatsTemplate;

   use strict;
   use warnings;

   use Kernel::System::Type;
   use Kernel::System::Ticket;
   use Kernel::System::Queue;

   =head1 NAME

   StaticStatsTemplate.pm - the module that creates the stats about tickets in a queue

   =head1 SYNOPSIS

   All functions

   =head1 PUBLIC INTERFACE

   =over 4

   =cut

   =item new()

   create an object

       use Kernel::Config;
       use Kernel::System::Encode;
       use Kernel::System::Log;
       use Kernel::System::Main;
       use Kernel::System::Time;
       use Kernel::System::DB;
       use Kernel::System::Stats::Static::StaticStatsTemplate;

       my $ConfigObject = Kernel::Config->new();
       my $EncodeObject = Kernel::System::Encode->new(
           ConfigObject => $ConfigObject,
       );
       my $LogObject    = Kernel::System::Log->new(
           ConfigObject => $ConfigObject,
       );
       my $MainObject = Kernel::System::Main->new(
           ConfigObject => $ConfigObject,
           LogObject    => $LogObject,
       );
       my $TimeObject = Kernel::System::Time->new(
           ConfigObject => $ConfigObject,
           LogObject    => $LogObject,
       );
       my $DBObject = Kernel::System::DB->new(
           ConfigObject => $ConfigObject,
           LogObject    => $LogObject,
           MainObject   => $MainObject,
       );
       my $StatsObject = Kernel::System::Stats::Static::StaticStatsTemplate->new(
           ConfigObject => $ConfigObject,
           LogObject    => $LogObject,
           MainObject   => $MainObject,
           TimeObject   => $TimeObject,
           DBObject     => $DBObject,
           EncodeObject => $EncodeObject,
       );

   =cut

   sub new {
       my ( $Type, %Param ) = @_;

       # allocate new hash for object
       my $Self = {%Param};
       bless( $Self, $Type );

       # check all needed objects
       for my $Needed (
           qw(DBObject ConfigObject LogObject
           TimeObject MainObject EncodeObject)
           )
       {
           $Self->{$Needed} = $Param{$Needed} || die "Got no $Needed";
       }

       # create needed objects
       $Self->{TypeObject}   = Kernel::System::Type->new( %{$Self} );
       $Self->{TicketObject} = Kernel::System::Ticket->new( %{$Self} );
       $Self->{QueueObject}  = Kernel::System::Queue->new( %{$Self} );

       return $Self;
   }

   =item Param()

   Get all parameters a user can specify.

       my @Params = $StatsObject->Param();

   =cut

   sub Param {
       my $Self = shift;

       my %Queues = $Self->{QueueObject}->GetAllQueues();
       my %Types  = $Self->{TypeObject}->TypeList(
           Valid => 1,
       );

       my @Params = (
           {
               Frontend  => 'Type',
               Name      => 'TypeIDs',
               Multiple  => 1,
               Size      => 3,
               Data      => \%Types,
           },
           {
               Frontend  => 'Queue',
               Name      => 'QueueIDs',
               Multiple  => 1,
               Size      => 3,
               Data      => \%Queues,
           },
       );

       return @Params;
   }

   =item Run()

   generate the statistic.

       my $StatsInfo = $StatsObject->Run(
           TypeIDs  => [
               1, 2, 4
           ],
           QueueIDs => [
               3, 4, 6
           ],
       );

   =cut

   sub Run {
       my ( $Self, %Param ) = @_;

       # check needed stuff
       for my $Needed (qw(TypeIDs QueueIDs)) {
           if ( !$Param{$Needed} ) {
               $Self->{LogObject}->Log(
                   Priority => 'error',
                   Message  => "Need $Needed!",
               );
               return;
           }
       }

       # set report title
       my $Title = 'Tickets per Queue';

       # table headlines
       my @HeadData = (
           'Ticket Number',
           'Queue',
           'Type',
       );

       my @Data;
       my @TicketIDs = $Self->{TicketObject}->TicketSearch(
           UserID     => 1,
           Result     => 'ARRAY',
           Permission => 'ro',
           %Param,
       );

       for my $TicketID ( @TicketIDs ) {
           my %Ticket = $Self->{TicketObject}->TicketGet(
               UserID => 1,
               TicketID => $TicketID,
           );
           push @Data, [ $Ticket{TicketNumber}, $Ticket{Queue}, $Ticket{Type} ];
       }

       return ( [$Title], [@HeadData], @Data );
   }

   1;


Static Stats Configuration Example
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

There is no configuration needed. Right after installation, the module is available to create a statistic for this module.
