Ticket Menu Module
==================

Ticket menu modules are used to display an additional link in the menu above a ticket. You can write and register your own ticket menu module. There are 4 ticket menus (Generic, Lock, Responsible and TicketWatcher) which come with the OTRS framework. For more information please have a look at the OTRS admin manual.


Ticket Menu Module Code Example
-------------------------------

The ticket menu modules are located under ``Kernel/Output/HTML/TicketMenu*.pm``. Following, there is an example of a ticket menu module. Save it under ``Kernel/Output/HTML/TicketMenuCustom.pm``. You just need 2 functions: ``new()`` and ``Run()``.

.. code-block:: Perl

   # --
   # Kernel/Output/HTML/TicketMenuCustom.pm
   # Copyright (C) 2001-2018 OTRS AG, https://otrs.com/
   # --
   # Id: TicketMenuCustom.pm,v 1.17 2010/04/12 21:34:06 martin Exp $
   # --
   # This software comes with ABSOLUTELY NO WARRANTY. For details, see
   # the enclosed file COPYING for license information (GPL). If you
   # did not receive this file, see https://www.gnu.org/licenses/gpl-3.0.txt.
   # --

   package Kernel::Output::HTML::TicketMenuCustom;

   use strict;
   use warnings;

   sub new {
       my ( $Type, %Param ) = @_;

       # allocate new hash for object
       my $Self = {};
       bless( $Self, $Type );

       # get needed objects
       for my $Object (qw(ConfigObject LogObject DBObject LayoutObject UserID TicketObject)) {
           $Self->{$Object} = $Param{$Object} || die "Got no $Object!";
       }

       return $Self;
   }

   sub Run {
       my ( $Self, %Param ) = @_;

       # check needed stuff
       if ( !$Param{Ticket} ) {
           $Self->{LogObject}->Log(
               Priority => 'error',
               Message  => 'Need Ticket!'
           );
           return;
       }

       # check if frontend module registered, if not, do not show action
       if ( $Param{Config}->{Action} ) {
           my $Module = $Self->{ConfigObject}->Get('Frontend::Module')->{ $Param{Config}->{Action} };
           return if !$Module;
       }

       # check permission
       my $AccessOk = $Self->{TicketObject}->Permission(
           Type     => 'rw',
           TicketID => $Param{Ticket}->{TicketID},
           UserID   => $Self->{UserID},
           LogNo    => 1,
       );
       return if !$AccessOk;

       # check permission
       if ( $Self->{TicketObject}->CustomIsTicketCustom( TicketID => $Param{Ticket}->{TicketID} ) ) {
           my $AccessOk = $Self->{TicketObject}->OwnerCheck(
               TicketID => $Param{Ticket}->{TicketID},
               OwnerID  => $Self->{UserID},
           );
           return if !$AccessOk;
       }

       # check acl
       return
           if defined $Param{ACL}->{ $Param{Config}->{Action} }
               && !$Param{ACL}->{ $Param{Config}->{Action} };

       # if ticket is customized
       if ( $Param{Ticket}->{Custom} eq 'lock' ) {

           # if it is locked for somebody else
           return if $Param{Ticket}->{OwnerID} ne $Self->{UserID};

           # show custom action
           return {
               %{ $Param{Config} },
               %{ $Param{Ticket} },
               %Param,
               Name        => 'Custom',
               Description => 'Custom to give it back to the queue!',
               Link        => 'Action=AgentTicketCustom;Subaction=Custom;TicketID=$QData{"TicketID"}',
           };
       }

       # if ticket is customized
       return {
           %{ $Param{Config} },
           %{ $Param{Ticket} },
           %Param,
           Name        => 'Custom',
           Description => 'Custom it to work on it!',
           Link        => 'Action=AgentTicketCustom;Subaction=Custom;TicketID=$QData{"TicketID"}',
       };
   }

   1;


Ticket Menu Module Configuration Example
----------------------------------------

There is the need to activate your custom ticket menu module. This can be done using the XML configuration below. There may be additional parameters in the config hash for your ticket menu module.

.. code-block:: XML

   <ConfigItem Name="Ticket::Frontend::MenuModule###110-Custom" Required="0" Valid="1">
       <Description Lang="en">Module to show custom link in menu.</Description>
       <Description Lang="de">Mit diesem Modul wird der Custom-Link in der Linkleiste der Ticketansicht angezeigt.</Description>
       <Group>Ticket</Group>
       <SubGroup>Frontend::Agent::Ticket::MenuModule</SubGroup>
       <Setting>
           <Hash>
               <Item Key="Module">Kernel::Output::HTML::TicketMenuCustom</Item>
               <Item Key="Name">Custom</Item>
               <Item Key="Action">AgentTicketCustom</Item>
           </Hash>
       </Setting>
   </ConfigItem>


Ticket Menu Module Use Case Example
-----------------------------------

Useful ticket menu implementation could be a link to a external tool if parameters (e.g. ``FreeTextField``) have been set.

.. note::

   The ticket menu directs to an URL that can be handled. If you want to handle that request via the OTRS framework, you have to write your own frontend module.
