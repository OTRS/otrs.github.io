Customer User Preferences Module
================================

There is a DB customer-user preferences module which come with the OTRS framework. It is also possible to develop your own customer-user preferences modules. The customer-user preferences modules are located under ``Kernel/System/CustomerUser/Preferences/*.pm``. For more information about their configuration see the admin manual. Following, there is an example of a customer-user preferences module. Save it under ``Kernel/System/CustomerUser/Preferences/Custom.pm``. You just need 4 functions: ``new()``, ``SearchPreferences()``, ``SetPreferences()`` and ``GetPreferences()``.


Customer User Preferences Module Code Example
---------------------------------------------

The interface class is called ``Kernel::System::CustomerUser``. The example customer-user preferences may be called ``Kernel::System::CustomerUser::Preferences::Custom``. You can find an example below.

.. code-block:: Perl

   # --
   # Kernel/System/CustomerUser/Preferences/Custom.pm - some customer user functions
   # Copyright (C) 2001-2018 OTRS AG, https://otrs.com/
   # --
   # Id: Custom.pm,v 1.20 2009/10/07 20:41:50 martin Exp $
   # --
   # This software comes with ABSOLUTELY NO WARRANTY. For details, see
   # the enclosed file COPYING for license information (GPL). If you
   # did not receive this file, see https://www.gnu.org/licenses/gpl-3.0.txt.
   # --

   package Kernel::System::CustomerUser::Preferences::Custom;

   use strict;
   use warnings;

   use vars qw(@ISA $VERSION);

   sub new {
       my ( $Type, %Param ) = @_;

       # allocate new hash for object
       my $Self = {};
       bless( $Self, $Type );

       # check needed objects
       for my $Object (qw(DBObject ConfigObject LogObject)) {
           $Self->{$Object} = $Param{$Object} || die "Got no $Object!";
       }

       # preferences table data
       $Self->{PreferencesTable} = $Self->{ConfigObject}->Get('CustomerPreferences')->{Params}->{Table}
           || 'customer_preferences';
       $Self->{PreferencesTableKey}
           = $Self->{ConfigObject}->Get('CustomerPreferences')->{Params}->{TableKey}
           || 'preferences_key';
       $Self->{PreferencesTableValue}
           = $Self->{ConfigObject}->Get('CustomerPreferences')->{Params}->{TableValue}
           || 'preferences_value';
       $Self->{PreferencesTableUserID}
           = $Self->{ConfigObject}->Get('CustomerPreferences')->{Params}->{TableUserID}
           || 'user_id';

       return $Self;
   }

   sub SetPreferences {
       my ( $Self, %Param ) = @_;

       my $UserID = $Param{UserID} || return;
       my $Key    = $Param{Key}    || return;
       my $Value = defined( $Param{Value} ) ? $Param{Value} : '';

       # delete old data
       return if !$Self->{DBObject}->Do(
           SQL => "DELETE FROM $Self->{PreferencesTable} WHERE "
               . " $Self->{PreferencesTableUserID} = ? AND $Self->{PreferencesTableKey} = ?",
           Bind => [ \$UserID, \$Key ],
       );

       $Value .= 'Custom';

       # insert new data
       return if !$Self->{DBObject}->Do(
           SQL => "INSERT INTO $Self->{PreferencesTable} ($Self->{PreferencesTableUserID}, "
               . " $Self->{PreferencesTableKey}, $Self->{PreferencesTableValue}) "
               . " VALUES (?, ?, ?)",
           Bind => [ \$UserID, \$Key, \$Value ],
       );

       return 1;
   }

   sub GetPreferences {
       my ( $Self, %Param ) = @_;

       my $UserID = $Param{UserID} || return;
       my %Data;

       # get preferences

       return if !$Self->{DBObject}->Prepare(
           SQL => "SELECT $Self->{PreferencesTableKey}, $Self->{PreferencesTableValue} "
               . " FROM $Self->{PreferencesTable} WHERE $Self->{PreferencesTableUserID} = ?",
           Bind => [ \$UserID ],
       );
       while ( my @Row = $Self->{DBObject}->FetchrowArray() ) {
           $Data{ $Row[0] } = $Row[1];
       }

       # return data
       return %Data;
   }

   sub SearchPreferences {
       my ( $Self, %Param ) = @_;

       my %UserID;
       my $Key   = $Param{Key}   || '';
       my $Value = $Param{Value} || '';

       # get preferences
       my $SQL = "SELECT $Self->{PreferencesTableUserID}, $Self->{PreferencesTableValue} "
           . " FROM "
           . " $Self->{PreferencesTable} "
           . " WHERE "
           . " $Self->{PreferencesTableKey} = '"
           . $Self->{DBObject}->Quote($Key) . "'" . " AND "
           . " LOWER($Self->{PreferencesTableValue}) LIKE LOWER('"
           . $Self->{DBObject}->Quote( $Value, 'Like' ) . "')";

       return if !$Self->{DBObject}->Prepare( SQL => $SQL );
       while ( my @Row = $Self->{DBObject}->FetchrowArray() ) {
           $UserID{ $Row[0] } = $Row[1];
       }

       # return data
       return %UserID;
   }

   1;


Customer User Preferences Module Configuration Example
------------------------------------------------------

There is the need to activate your custom customer-user preferences module. This can be done using the XML configuration below.

.. code-block:: XML

   <ConfigItem Name="CustomerPreferences" Required="1" Valid="1">
       <Description Lang="en">Parameters for the customer preference table.</Description>
       <Description Lang="de">Parameter für die Tabelle mit den Einstellungen für die Customer.</Description>
       <Group>Framework</Group>
       <SubGroup>Frontend::Customer::Preferences</SubGroup>
       <Setting>
           <Hash>
               <Item Key="Module">Kernel::System::CustomerUser::Preferences::Custom</Item>
               <Item  Key="Params">
                   <Hash>
                       <Item Key="Table">customer_preferences</Item>
                       <Item Key="TableKey">preferences_key</Item>
                       <Item Key="TableValue">preferences_value</Item>
                       <Item Key="TableUserID">user_id</Item>
                   </Hash>
               </Item>
           </Hash>
       </Setting>
   </ConfigItem>


Customer User Preferences Module Use Case Example
-------------------------------------------------

Useful preferences implementation could be a SOAP or LDAP backend.
