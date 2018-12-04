Notification Module
===================

Notification modules are used to display a notification below the main navigation. You can write and register your own notification module. There are currently 5 ticket menus in the OTRS framework.

-  ``AgentOnline``
-  ``AgentTicketEscalation``
-  ``CharsetCheck``
-  ``CustomerOnline``
-  ``UIDCheck``


Notification Module Code Example
--------------------------------

The notification modules are located under ``Kernel/Output/HTML/TicketNotification*.pm``. Following, there is an example of a notify module. Save it under ``Kernel/Output/HTML/TicketNotificationCustom.pm``. You just need 2 functions: ``new()`` and ``Run()``.

.. code-block:: Perl

   # --
   # Kernel/Output/HTML/NotificationCustom.pm
   # Copyright (C) 2001-2018 OTRS AG, https://otrs.com/
   # --
   # This software comes with ABSOLUTELY NO WARRANTY. For details, see
   # the enclosed file COPYING for license information (GPL). If you
   # did not receive this file, see https://www.gnu.org/licenses/gpl-3.0.txt.
   # --

   package Kernel::Output::HTML::NotificationCustom;

   use strict;
   use warnings;

   use Kernel::System::Custom;

   sub new {
       my ( $Type, %Param ) = @_;

       # allocate new hash for object
       my $Self = {};
       bless( $Self, $Type );

       # get needed objects
       for my $Object (qw(ConfigObject LogObject DBObject LayoutObject TimeObject UserID)) {
           $Self->{$Object} = $Param{$Object} || die "Got no $Object!";
       }
       $Self->{CustomObject} = Kernel::System::Custom->new(%Param);
       return $Self;
   }

   sub Run {
       my ( $Self, %Param ) = @_;

       # get session info
       my %CustomParam      = ();
       my @Customs    = $Self->{CustomObject}->GetAllCustomIDs();
       my $IdleMinutes = $Param{Config}->{IdleMinutes} || 60 * 2;
       for (@Customs) {
           my %Data = $Self->{CustomObject}->GetCustomIDData( CustomID => $_, );
           if (
               $Self->{UserID} ne $Data{UserID}
               && $Data{UserType} eq 'User'
               && $Data{UserLastRequest}
               && $Data{UserLastRequest} + ( $IdleMinutes * 60 ) > $Self->{TimeObject}->SystemTime()
               && $Data{UserFirstname}
               && $Data{UserLastname}
               )
           {
               $CustomParam{ $Data{UserID} } = "$Data{UserFirstname} $Data{UserLastname}";
               if ( $Param{Config}->{ShowEmail} ) {
                   $CustomParam{ $Data{UserID} } .= " ($Data{UserEmail})";
               }
           }
       }
       for ( sort { $CustomParam{$a} cmp $CustomParam{$b} } keys %CustomParam ) {
           if ( $Param{Message} ) {
               $Param{Message} .= ', ';
           }
           $Param{Message} .= "$CustomParam{$_}";
       }
       if ( $Param{Message} ) {
           return $Self->{LayoutObject}->Notify( Info => 'Custom Message: %s", "' . $Param{Message} );
       }
       else {
           return '';
       }
   }

   1;


Notification Module Configuration Example
-----------------------------------------

There is the need to activate your custom notification module. This can be done using the XML configuration below. There may be additional parameters in the config hash for your notification module.

.. code-block:: XML

   <ConfigItem Name="Frontend::NotifyModule###3-Custom" Required="0" Valid="0">
       <Description Lang="en">Module to show custom message in the agent interface.</Description>
       <Description Lang="de">Mit diesem Modul können eigene Meldungenen innerhalb des Agent-Interfaces angezeigt werden.</Description>
       <Group>Framework</Group>
       <SubGroup>Frontend::Agent::ModuleNotify</SubGroup>
       <Setting>
           <Hash>
               <Item Key="Module">Kernel::Output::HTML::NotificationCustom</Item>
               <Item Key="Key1">1</Item>
               <Item Key="Key2">2</Item>
           </Hash>
       </Setting>
   </ConfigItem>


Notification Module Use Case Example
------------------------------------

Useful ticket menu implementation could be a link to an external tool if parameters (e.g. ``FreeTextField``) have been set.
