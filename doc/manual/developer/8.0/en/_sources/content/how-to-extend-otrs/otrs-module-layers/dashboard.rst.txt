Dashboard Module
================

Dashboard module to display statistics in the form of a line graph.

.. figure:: images/dashboard.png
   :alt: Dashboard Widget

   Dashboard Widget

.. code-block:: Perl

   # --
   # Kernel/Output/HTML/DashboardTicketStatsGeneric.pm - message of the day
   # Copyright (C) 2001-2018 OTRS AG, https://otrs.com/
   # --
   # This software comes with ABSOLUTELY NO WARRANTY. For details, see
   # the enclosed file COPYING for license information (GPL). If you
   # did not receive this file, see https://www.gnu.org/licenses/gpl-3.0.txt.
   # --

   package Kernel::Output::HTML::DashboardTicketStatsGeneric;

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
           die "Got no $_!" if !$Self->{$_};
       }

       return $Self;
   }

   sub Preferences {
       my ( $Self, %Param ) = @_;

       return;
   }

   sub Config {
       my ( $Self, %Param ) = @_;

       my $Key = $Self->{LayoutObject}->{UserLanguage} . '-' . $Self->{Name};
       return (
           %{ $Self->{Config} },
           CacheKey => 'TicketStats' . '-' . $Self->{UserID} . '-' . $Key,
       );

   }

   sub Run {
       my ( $Self, %Param ) = @_;

       my %Axis = (
           '7Day' => {
               0 => { Day => 'Sun', Created => 0, Closed => 0, },
               1 => { Day => 'Mon', Created => 0, Closed => 0, },
               2 => { Day => 'Tue', Created => 0, Closed => 0, },
               3 => { Day => 'Wed', Created => 0, Closed => 0, },
               4 => { Day => 'Thu', Created => 0, Closed => 0, },
               5 => { Day => 'Fri', Created => 0, Closed => 0, },
               6 => { Day => 'Sat', Created => 0, Closed => 0, },
           },
       );

       my @Data;
       my $Max = 1;
       for my $Key ( 0 .. 6 ) {

           my $TimeNow = $Self->{TimeObject}->SystemTime();
           if ($Key) {
               $TimeNow = $TimeNow - ( 60 * 60 * 24 * $Key );
           }
           my ( $Sec, $Min, $Hour, $Day, $Month, $Year, $WeekDay )
               = $Self->{TimeObject}->SystemTime2Date(
               SystemTime => $TimeNow,
               );

           $Data[$Key]->{Day} = $Self->{LayoutObject}->{LanguageObject}->Get(
               $Axis{'7Day'}->{$WeekDay}->{Day}
           );

           my $CountCreated = $Self->{TicketObject}->TicketSearch(

               # cache search result 20 min
               CacheTTL => 60 * 20,

               # tickets with create time after ... (ticket newer than this date) (optional)
               TicketCreateTimeNewerDate => "$Year-$Month-$Day 00:00:00",

               # tickets with created time before ... (ticket older than this date) (optional)
               TicketCreateTimeOlderDate => "$Year-$Month-$Day 23:59:59",

               CustomerID => $Param{Data}->{UserCustomerID},
               Result     => 'COUNT',

               # search with user permissions
               Permission => $Self->{Config}->{Permission} || 'ro',
               UserID => $Self->{UserID},
           );
           $Data[$Key]->{Created} = $CountCreated;
           if ( $CountCreated > $Max ) {
               $Max = $CountCreated;
           }

           my $CountClosed = $Self->{TicketObject}->TicketSearch(

               # cache search result 20 min
               CacheTTL => 60 * 20,

               # tickets with create time after ... (ticket newer than this date) (optional)
               TicketCloseTimeNewerDate => "$Year-$Month-$Day 00:00:00",

               # tickets with created time before ... (ticket older than this date) (optional)
               TicketCloseTimeOlderDate => "$Year-$Month-$Day 23:59:59",

               CustomerID => $Param{Data}->{UserCustomerID},
               Result     => 'COUNT',

               # search with user permissions
               Permission => $Self->{Config}->{Permission} || 'ro',
               UserID => $Self->{UserID},
           );
           $Data[$Key]->{Closed} = $CountClosed;
           if ( $CountClosed > $Max ) {
               $Max = $CountClosed;
           }
       }

       @Data = reverse @Data;
       my $Source = $Self->{LayoutObject}->JSONEncode(
           Data => \@Data,
       );

       my $Content = $Self->{LayoutObject}->Output(
           TemplateFile => 'AgentDashboardTicketStats',
           Data         => {
               %{ $Self->{Config} },
               Key    => int rand 99999,
               Max    => $Max,
               Source => $Source,
           },
       );

       return $Content;
   }

   1;

To use this module add the following to the ``Kernel/Config.pm`` and restart your web server (if you use ``mod_perl``).

.. code-block:: XML

   <ConfigItem Name="DashboardBackend###0250-TicketStats" Required="0" Valid="1">
       <Description Lang="en">Parameters for the dashboard backend. "Group" are used to restricted access to the plugin (e. g. Group: admin;group1;group2;). "Default" means if the plugin is enabled per default or if the user needs to enable it manually. "CacheTTL" means the cache time in minutes for the plugin.</Description>
       <Description Lang="de">Parameter für das Dashboard Backend. "Group" ist verwendet um den Zugriff auf das Plugin einzuschränken (z. B. Group: admin;group1;group2;). ""Default" bedeutet ob das Plugin per default aktiviert ist oder ob dies der Anwender manuell machen muss. "CacheTTL" ist die Cache-Zeit in Minuten nach der das Plugin erneut aufgerufen wird.</Description>
       <Group>Ticket</Group>
       <SubGroup>Frontend::Agent::Dashboard</SubGroup>
       <Setting>
           <Hash>
               <Item Key="Module">Kernel::Output::HTML::DashboardTicketStatsGeneric</Item>
               <Item Key="Title">7 Day Stats</Item>
               <Item Key="Created">1</Item>
               <Item Key="Closed">1</Item>
               <Item Key="Permission">rw</Item>
               <Item Key="Block">ContentSmall</Item>
               <Item Key="Group"></Item>
               <Item Key="Default">1</Item>
               <Item Key="CacheTTL">45</Item>
           </Hash>
       </Setting>
   </ConfigItem>

.. note::

   An excessive number of days or individual lines may lead to performance degradation.
