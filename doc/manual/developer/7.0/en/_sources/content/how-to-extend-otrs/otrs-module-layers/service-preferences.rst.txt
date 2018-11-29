Service Preferences Module
==========================

There is a DB service preferences module which come with the OTRS framework. It is also possible to develop your own service preferences modules. The service preferences modules are located under ``Kernel/System/Service/*.pm``. For more information about their configuration see the admin manual. Following, there is an example of a service preferences module. Save it under ``Kernel/System/Service/PreferencesCustom.pm``. You just need 3 functions: ``new()``, ``ServicePreferencesSet()`` and ``ServicePreferencesGet()``. Return 1, then the synchronization is ok.


Service Preferences Code Example
--------------------------------

The interface class is called ``Kernel::System::Service``. The example service preferences may be called
``Kernel::System::Service::PreferencesCustom``. You can find an example below.

.. code-block:: Perl

   # --
   # Kernel/System/Service/PreferencesCustom - some user functions
   # Copyright (C) 2001-2018 OTRS AG, https://otrs.com/
   # --
   # Id: PreferencesCustom.pm,v 1.2 2009/02/16 11:47:34 tr Exp $
   # --
   # This software comes with ABSOLUTELY NO WARRANTY. For details, see
   # the enclosed file COPYING for license information (GPL). If you
   # did not receive this file, see https://www.gnu.org/licenses/gpl-3.0.txt.
   # --

   package Kernel::System::Service::PreferencesCustom;

   use strict;
   use warnings;

   use vars qw(@ISA $VERSION);

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
       $Self->{PreferencesTable}          = 'service_preferences';
       $Self->{PreferencesTableKey}       = 'preferences_key';
       $Self->{PreferencesTableValue}     = 'preferences_value';
       $Self->{PreferencesTableServiceID} = 'service_id';

       return $Self;
   }

   sub ServicePreferencesSet {
       my ( $Self, %Param ) = @_;

       # check needed stuff
       for (qw(ServiceID Key Value)) {
           if ( !defined( $Param{$_} ) ) {
               $Self->{LogObject}->Log( Priority => 'error', Message => "Need $_!" );
               return;
           }
       }

       # delete old data
       return if !$Self->{DBObject}->Do(
           SQL => "DELETE FROM $Self->{PreferencesTable} WHERE "
               . "$Self->{PreferencesTableServiceID} = ? AND $Self->{PreferencesTableKey} = ?",
           Bind => [ \$Param{ServiceID}, \$Param{Key} ],
       );

   $Self->{PreferencesTableValue} .= 'PreferencesCustom';

       # insert new data
       return $Self->{DBObject}->Do(
           SQL => "INSERT INTO $Self->{PreferencesTable} ($Self->{PreferencesTableServiceID}, "
               . " $Self->{PreferencesTableKey}, $Self->{PreferencesTableValue}) "
               . " VALUES (?, ?, ?)",
           Bind => [ \$Param{ServiceID}, \$Param{Key}, \$Param{Value} ],
       );
   }

   sub ServicePreferencesGet {
       my ( $Self, %Param ) = @_;

       # check needed stuff
       for (qw(ServiceID)) {
           if ( !$Param{$_} ) {
               $Self->{LogObject}->Log( Priority => 'error', Message => "Need $_!" );
               return;
           }
       }

       # check if service preferences are available
       if ( !$Self->{ConfigObject}->Get('ServicePreferences') ) {
           return;
       }

       # get preferences
       return if !$Self->{DBObject}->Prepare(
           SQL => "SELECT $Self->{PreferencesTableKey}, $Self->{PreferencesTableValue} "
               . " FROM $Self->{PreferencesTable} WHERE $Self->{PreferencesTableServiceID} = ?",
           Bind => [ \$Param{ServiceID} ],
       );
       my %Data;
       while ( my @Row = $Self->{DBObject}->FetchrowArray() ) {
           $Data{ $Row[0] } = $Row[1];
       }

       # return data
       return %Data;
   }

   1;


Service Preferences Configuration Example
-----------------------------------------

There is the need to activate your custom service preferences module. This can be done using the XML configuration below.

.. code-block:: XML

   <ConfigItem Name="Service::PreferencesModule" Required="1" Valid="1">
       <Description Lang="en">Default service preferences module.</Description>
       <Description Lang="de">Standard Service Preferences Module.</Description>
       <Group>Ticket</Group>
       <SubGroup>Frontend::Service::Preferences</SubGroup>
       <Setting>
           <String Regex="">Kernel::System::Service::PreferencesCustom</String>
       </Setting>
   </ConfigItem>


Service Preferences Use Case Example
------------------------------------

Useful preferences implementation could be a SOAP or RADIUS backend.
