SLA Preferences Module
======================

There is a DB SLA preferences module which come with the OTRS framework. It is also possible to develop your own SLA preferences modules. The SLA preferences modules are located under ``Kernel/System/SLA/*.pm``. For more information about their configuration see the admin manual. Following, there is an example of an SLA preferences module. Save it under ``Kernel/System/SLA/PreferencesCustom.pm``. You just need 3 functions: ``new()``, ``SLAPreferencesSet()`` and ``SLAPreferencesGet()``. Make sure the function returns 1.


SLA Preferences Code Example
----------------------------

The interface class is called ``Kernel::System::SLA``. The example SLA preferences may be called ``Kernel::System::SLA::PreferencesCustom``. You can find an example below.

.. code-block:: Perl

   # --
   # Kernel/System/SLA/PreferencesCustom.pm - some user functions
   # Copyright (C) 2001-2018 OTRS AG, https://otrs.com/
   # --
   # This software comes with ABSOLUTELY NO WARRANTY. For details, see
   # the enclosed file COPYING for license information (GPL). If you
   # did not receive this file, see https://www.gnu.org/licenses/gpl-3.0.txt.
   # --

   package Kernel::System::SLA::PreferencesCustom;

   use strict;
   use warnings;

   use vars qw(@ISA);

   sub new {
       my ( $Type, %Param ) = @_;

       # allocate new hash for object
       my $Self = {};
       bless( $Self, $Type );

       # check needed objects
       for (qw(DBObject ConfigObject LogObject)) {
           $Self->{$_} = $Param{$_} || die "Got no $_!";
       }

       # preferences table data
       $Self->{PreferencesTable}      = 'sla_preferences';
       $Self->{PreferencesTableKey}   = 'preferences_key';
       $Self->{PreferencesTableValue} = 'preferences_value';
       $Self->{PreferencesTableSLAID} = 'sla_id';

       return $Self;
   }

   sub SLAPreferencesSet {
       my ( $Self, %Param ) = @_;

       # check needed stuff
       for (qw(SLAID Key Value)) {
           if ( !defined( $Param{$_} ) ) {
               $Self->{LogObject}->Log( Priority => 'error', Message => "Need $_!" );
               return;
           }
       }

       # delete old data
       return if !$Self->{DBObject}->Do(
           SQL => "DELETE FROM $Self->{PreferencesTable} WHERE "
               . "$Self->{PreferencesTableSLAID} = ? AND $Self->{PreferencesTableKey} = ?",
           Bind => [ \$Param{SLAID}, \$Param{Key} ],
       );

   $Self->{PreferencesTableValue} .= 'PreferencesCustom';

       # insert new data
       return $Self->{DBObject}->Do(
           SQL => "INSERT INTO $Self->{PreferencesTable} ($Self->{PreferencesTableSLAID}, "
               . " $Self->{PreferencesTableKey}, $Self->{PreferencesTableValue}) "
               . " VALUES (?, ?, ?)",
           Bind => [ \$Param{SLAID}, \$Param{Key}, \$Param{Value} ],
       );
   }

   sub SLAPreferencesGet {
       my ( $Self, %Param ) = @_;

       # check needed stuff
       for (qw(SLAID)) {
           if ( !$Param{$_} ) {
               $Self->{LogObject}->Log( Priority => 'error', Message => "Need $_!" );
               return;
           }
       }

       # check if SLA preferences are available
       if ( !$Self->{ConfigObject}->Get('SLAPreferences') ) {
           return;
       }

       # get preferences
       return if !$Self->{DBObject}->Prepare(
           SQL => "SELECT $Self->{PreferencesTableKey}, $Self->{PreferencesTableValue} "
               . " FROM $Self->{PreferencesTable} WHERE $Self->{PreferencesTableSLAID} = ?",
           Bind => [ \$Param{SLAID} ],
       );
       my %Data;
       while ( my @Row = $Self->{DBObject}->FetchrowArray() ) {
           $Data{ $Row[0] } = $Row[1];
       }

       # return data
       return %Data;
   }

   1;


SLA Preferences Configuration Example
-------------------------------------

There is the need to activate your custom SLA preferences module. This can be done using the XML configuration below.

.. code-block:: XML

   <ConfigItem Name="SLA::PreferencesModule" Required="1" Valid="1">
       <Description Translatable="1">Default SLA preferences module.</Description>
       <Group>Ticket</Group>
       <SubGroup>Frontend::SLA::Preferences</SubGroup>
       <Setting>
           <String Regex="">Kernel::System::SLA::PreferencesCustom</String>
       </Setting>
   </ConfigItem>


SLA Preferences Use Case Example
--------------------------------

Useful preferences implementation could be to store additional values on SLAs.
