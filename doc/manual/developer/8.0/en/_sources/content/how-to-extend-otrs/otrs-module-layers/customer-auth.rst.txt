Customer Authentication Module
==============================

There are several customer authentication modules (DB, LDAP and HTTPBasicAuth) which come with the OTRS framework. It is also possible to develop your own authentication modules. The customer authentication modules are located under ``Kernel/System/CustomerAuth/*.pm``. For more information about their configuration see the admin manual. Following, there is an example of a simple customer auth module. Save it under ``Kernel/System/CustomerAuth/Simple.pm``. You just need 3 functions: ``new()``, ``GetOption()`` and ``Auth()``. Return the uid, then the authentication is ok.


Customer Authentication Module Code Example
-------------------------------------------

The interface class is called ``Kernel::System::CustomerAuth``. The example customer authentication may be called ``Kernel::System::CustomerAuth::CustomAuth``. You can find an example below.

.. code-block:: Perl

   # --
   # Kernel/System/CustomerAuth/CustomAuth.pm - provides the custom Authentication
   # based on Martin Edenhofer's Kernel::System::Auth::DB
   # Copyright (C) 2001-2018 OTRS AG, https://otrs.com/
   # --
   # Id: CustomAuth.pm,v 1.11 2009/09/22 15:16:05 mb Exp $
   # --
   # This software comes with ABSOLUTELY NO WARRANTY. For details, see
   # the enclosed file COPYING for license information (GPL). If you
   # did not receive this file, see https://www.gnu.org/licenses/gpl-3.0.txt.
   # --

   package Kernel::System::CustomerAuth::CustomAuth;

   use strict;
   use warnings;

   use Authen::CustomAuth;

   sub new {
       my ( $Type, %Param ) = @_;

       # allocate new hash for object
       my $Self = {};
       bless( $Self, $Type );

       # check needed objects
       for (qw(LogObject ConfigObject DBObject)) {
           $Self->{$_} = $Param{$_} || die "No $_!";
       }

       # Debug 0=off 1=on
       $Self->{Debug} = 0;

       # get config
       $Self->{Die}
           = $Self->{ConfigObject}->Get( 'Customer::AuthModule::CustomAuth::Die' . $Param{Count} );

       # get user table
       $Self->{CustomAuthHost}
           = $Self->{ConfigObject}->Get( 'Customer::AuthModule::CustomAuth::Host' . $Param{Count} )
           || die "Need Customer::AuthModule::CustomAuth::Host$Param{Count} in Kernel/Config.pm";
       $Self->{CustomAuthSecret}
           = $Self->{ConfigObject}->Get( 'Customer::AuthModule::CustomAuth::Password' . $Param{Count} )
           || die "Need Customer::AuthModule::CustomAuth::Password$Param{Count} in Kernel/Config.pm";

       return $Self;
   }

   sub GetOption {
       my ( $Self, %Param ) = @_;

       # check needed stuff
       if ( !$Param{What} ) {
           $Self->{LogObject}->Log( Priority => 'error', Message => "Need What!" );
           return;
       }

       # module options
       my %Option = ( PreAuth => 0, );

       # return option
       return $Option{ $Param{What} };
   }

   sub Auth {
       my ( $Self, %Param ) = @_;

       # check needed stuff
       if ( !$Param{User} ) {
           $Self->{LogObject}->Log( Priority => 'error', Message => "Need User!" );
           return;
       }

       # get params
       my $User       = $Param{User}      || '';
       my $Pw         = $Param{Pw}        || '';
       my $RemoteAddr = $ENV{REMOTE_ADDR} || 'Got no REMOTE_ADDR env!';
       my $UserID     = '';
       my $GetPw      = '';

       # just in case for debug!
       if ( $Self->{Debug} > 0 ) {
           $Self->{LogObject}->Log(
               Priority => 'notice',
               Message  => "User: '$User' tried to authentificate with Pw: '$Pw' ($RemoteAddr)",
           );
       }

       # just a note
       if ( !$User ) {
           $Self->{LogObject}->Log(
               Priority => 'notice',
               Message  => "No User given!!! (REMOTE_ADDR: $RemoteAddr)",
           );
           return;
       }

       # just a note
       if ( !$Pw ) {
           $Self->{LogObject}->Log(
               Priority => 'notice',
               Message  => "User: $User Authentication without Pw!!! (REMOTE_ADDR: $RemoteAddr)",
           );
           return;
       }

       # Create a custom object
       my $CustomAuth = Authen::CustomAuth->new(
           Host   => $Self->{CustomAuthHost},
           Secret => $Self->{CustomAuthSecret},
       );
       if ( !$CustomAuth ) {
           if ( $Self->{Die} ) {
               die "Can't connect to $Self->{CustomAuthHost}: $@";
           }
           else {
               $Self->{LogObject}->Log(
                   Priority => 'error',
                   Message  => "Can't connect to $Self->{CustomAuthHost}: $@",
               );
               return;
           }
       }
       my $AuthResult = $CustomAuth->check_pwd( $User, $Pw );

       # login note
       if ( defined($AuthResult) && $AuthResult == 1 ) {
           $Self->{LogObject}->Log(
               Priority => 'notice',
               Message  => "User: $User Authentication ok (REMOTE_ADDR: $RemoteAddr).",
           );
           return $User;
       }

       # just a note
       else {
           $Self->{LogObject}->Log(
               Priority => 'notice',
               Message  => "User: $User Authentication with wrong Pw!!! (REMOTE_ADDR: $RemoteAddr)"
           );
           return;
       }
   }

   1;


Customer Authentication Module Configuration Example
----------------------------------------------------

There is the need to activate your custom customer authenticate module. This can be done using the XML configuration below.

.. code-block:: XML

   <ConfigItem Name="AuthModule" Required="1" Valid="1">
       <Description Lang="en">Module to authenticate customers.</Description>
       <Description Lang="de">Modul zum Authentifizieren der Customer.</Description>
       <Group>Framework</Group>
       <SubGroup>Frontend::CustomerAuthAuth</SubGroup>
       <Setting>
           <Option Location="Kernel/System/CustomerAuth/*.pm" SelectedID="Kernel::System::CustomerAuth::CustomAuth"></Option>
       </Setting>
   </ConfigItem>


Customer Authentication Module Use Case Example
-----------------------------------------------

Useful authentication implementation could be a SOAP backend.
