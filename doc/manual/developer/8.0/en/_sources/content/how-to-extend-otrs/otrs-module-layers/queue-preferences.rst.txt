Queue Preferences Module
========================

There is a DB queue preferences module which come with the OTRS framework. It is also possible to develop your own queue preferences modules. The queue preferences modules are located under ``Kernel/System/Queue/*.pm``. For more information about their configuration see the admin manual. Following, there is an example of a queue preferences module. Save it under ``Kernel/System/Queue/PreferencesCustom.pm``. You just need 3 functions: ``new()``, ``QueuePreferencesSet()`` and ``QueuePreferencesGet()``. Return 1, then the synchronization is ok.


Queue Preferences Code Example
------------------------------

The interface class is called ``Kernel::System::Queue``. The example queue preferences may be called ``Kernel::System::Queue::PreferencesCustom``. You can find an example below.

.. code-block:: Perl

   # --
   # Kernel/System/Queue/PreferencesCustom.pm - some user functions
   # Copyright (C) 2001-2018 OTRS AG, https://otrs.com/
   # --
   # Id: PreferencesCustom.pm,v 1.5 2009/02/16 11:47:34 tr Exp $
   # --
   # This software comes with ABSOLUTELY NO WARRANTY. For details, see
   # the enclosed file COPYING for license information (GPL). If you
   # did not receive this file, see https://www.gnu.org/licenses/gpl-3.0.txt.
   # --

   package Kernel::System::Queue::PreferencesCustom;

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
       $Self->{PreferencesTable}        = 'queue_preferences';
       $Self->{PreferencesTableKey}     = 'preferences_key';
       $Self->{PreferencesTableValue}   = 'preferences_value';
       $Self->{PreferencesTableQueueID} = 'queue_id';

       return $Self;
   }

   sub QueuePreferencesSet {
       my ( $Self, %Param ) = @_;

       # check needed stuff
       for (qw(QueueID Key Value)) {
           if ( !defined( $Param{$_} ) ) {
               $Self->{LogObject}->Log( Priority => 'error', Message => "Need $_!" );
               return;
           }
       }

       # delete old data
       return if !$Self->{DBObject}->Do(
           SQL => "DELETE FROM $Self->{PreferencesTable} WHERE "
               . "$Self->{PreferencesTableQueueID} = ? AND $Self->{PreferencesTableKey} = ?",
           Bind => [ \$Param{QueueID}, \$Param{Key} ],
       );

       $Self->{PreferencesTableValue} .= 'PreferencesCustom';

       # insert new data
       return $Self->{DBObject}->Do(
           SQL => "INSERT INTO $Self->{PreferencesTable} ($Self->{PreferencesTableQueueID}, "
               . " $Self->{PreferencesTableKey}, $Self->{PreferencesTableValue}) "
               . " VALUES (?, ?, ?)",
           Bind => [ \$Param{QueueID}, \$Param{Key}, \$Param{Value} ],
       );
   }

   sub QueuePreferencesGet {
       my ( $Self, %Param ) = @_;

       # check needed stuff
       for (qw(QueueID)) {
           if ( !$Param{$_} ) {
               $Self->{LogObject}->Log( Priority => 'error', Message => "Need $_!" );
               return;
           }
       }

       # check if queue preferences are available
       if ( !$Self->{ConfigObject}->Get('QueuePreferences') ) {
           return;
       }

       # get preferences
       return if !$Self->{DBObject}->Prepare(
           SQL => "SELECT $Self->{PreferencesTableKey}, $Self->{PreferencesTableValue} "
               . " FROM $Self->{PreferencesTable} WHERE $Self->{PreferencesTableQueueID} = ?",
           Bind => [ \$Param{QueueID} ],
       );
       my %Data;
       while ( my @Row = $Self->{DBObject}->FetchrowArray() ) {
           $Data{ $Row[0] } = $Row[1];
       }

       # return data
       return %Data;
   }

   1;


Queue Preferences Configuration Example
---------------------------------------

There is the need to activate your custom queue preferences module. This can be done using the XML configuration below.

.. code-block:: XML

   <ConfigItem Name="Queue::PreferencesModule" Required="1" Valid="1">
       <Description Lang="en">Default queue preferences module.</Description>
       <Description Lang="de">Standard Queue Preferences Module.</Description>
       <Group>Ticket</Group>
       <SubGroup>Frontend::Queue::Preferences</SubGroup>
       <Setting>
           <String Regex="">Kernel::System::Queue::PreferencesCustom</String>
       </Setting>
   </ConfigItem>


Queue Preferences Use Case Example
----------------------------------

Useful preferences implementation could be a SOAP or RADIUS backend.
