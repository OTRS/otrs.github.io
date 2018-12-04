Ticket Postmaster Module
========================

Postmaster modules are used during the postmaster process. There are two kinds of postmaster modules:

- ``PostMasterPre``: used after parsing an email.
- ``PostMasterPost``: used after an email is processed and is in the database.

If you want to create your own postmaster filter, just create your own module. These modules are located under ``Kernel/System/PostMaster/Filter/*.pm``. For default modules see the admin manual. You just need two functions: ``new()`` and ``Run()``.

The following is an exemplary module to match emails and set X-OTRS-Headers (see ``doc/X-OTRS-Headers.txt`` for more info).

``Kernel/Config/Files/XML/MyModule.xml``:

.. code-block:: XML

   <ConfigItem Name="PostMaster::PreFilterModule###1-Example" Required="0" Valid="1">
       <Description Translatable="1">Example module to filter and manipulate incoming messages.</Description>
       <Group>Ticket</Group>
       <SubGroup>Core::PostMaster</SubGroup>
       <Setting>
           <Hash>
               <Item Key="Module">Kernel::System::PostMaster::Filter::Example</Item>
               <Item Key="Match">
                   <Hash>
                       <Item Key="From">noreply@</Item>
                   </Hash>
               </Item>
               <Item Key="Set">
                   <Hash>
                       <Item Key="X-OTRS-Ignore">yes</Item>
                   </Hash>
               </Item>
           </Hash>
       </Setting>
   </ConfigItem>

And the actual filter code in ``Kernel/System/PostMaster/Filter/Example.pm``:

.. code-block:: Perl

   # --
   # Copyright (C) 2001-2018 OTRS AG, https://otrs.com/
   # --
   # This software comes with ABSOLUTELY NO WARRANTY. For details, see
   # the enclosed file COPYING for license information (GPL). If you
   # did not receive this file, see https://www.gnu.org/licenses/gpl-3.0.txt.
   # --

   package Kernel::System::PostMaster::Filter::Example;

   use strict;
   use warnings;

   our @ObjectDependencies = (
       'Kernel::System::Log',
   );

   sub new {
       my ( $Type, %Param ) = @_;

       # allocate new hash for object
       my $Self = {};
       bless ($Self, $Type);

       $Self->{Debug} = $Param{Debug} || 0;

       return $Self;
   }

   sub Run {
       my ( $Self, %Param ) = @_;
       # get config options
       my %Config = ();
       my %Match = ();
       my %Set = ();
       if ($Param{JobConfig} && ref($Param{JobConfig}) eq 'HASH') {
           %Config = %{$Param{JobConfig}};
           if ($Config{Match}) {
               %Match = %{$Config{Match}};
           }
           if ($Config{Set}) {
               %Set = %{$Config{Set}};
           }
           }
           # match 'Match => ???' stuff
           my $Matched = '';
           my $MatchedNot = 0;
           for (sort keys %Match) {
           if ($Param{GetParam}->{$_} && $Param{GetParam}->{$_} =~ /$Match{$_}/i) {
               $Matched = $1 || '1';
               if ($Self->{Debug} > 1) {
                   $Kernel::OM->Get('Kernel::System::Log')->Log(
                       Priority => 'debug',
                       Message => "'$Param{GetParam}->{$_}' =~ /$Match{$_}/i matched!",
                   );
               }
           }
           else {
               $MatchedNot = 1;
               if ($Self->{Debug} > 1) {
                   $Kernel::OM->Get('Kernel::System::Log')->Log(
                       Priority => 'debug',
                       Message => "'$Param{GetParam}->{$_}' =~ /$Match{$_}/i matched NOT!",
                   );
               }
           }
           }
           # should I ignore the incoming mail?
           if ($Matched && !$MatchedNot) {
           for (keys %Set) {
               if ($Set{$_} =~ /\[\*\*\*\]/i) {
                   $Set{$_} = $Matched;
               }
               $Param{GetParam}->{$_} = $Set{$_};
               $Kernel::OM->Get('Kernel::System::Log')->Log(
                   Priority => 'notice',
                   Message => "Set param '$_' to '$Set{$_}' (Message-ID: $Param{GetParam}->{'Message-ID'}) ",
               );
           }
       }

       return 1;
   }

   1;

The following image shows you the email processing flow.

.. figure:: images/email-processing.png
   :alt: Email Processing Flow

   Email Processing Flow
