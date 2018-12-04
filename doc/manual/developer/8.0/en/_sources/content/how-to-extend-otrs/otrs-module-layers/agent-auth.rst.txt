Agent Authentication Module
===========================

There are several agent authentication modules (DB, LDAP and HTTPBasicAuth) which come with the OTRS framework. It is also possible to develop your own authentication modules. The agent authentication modules are located under ``Kernel/System/Auth/*.pm``. For more information about their configuration see the admin manual. Following, there is an example of a simple agent auth module. Save it under ``Kernel/System/Auth/Simple.pm``. You just need 3 functions: ``new()``, ``GetOption()`` and ``Auth()``. Return the uid, then the authentication is ok.


Agent Authentication Module Code Example
----------------------------------------

The interface class is called ``Kernel::System::Auth``. The example agent authentication may be called ``Kernel::System::Auth::CustomAuth``. You can find an example below.

.. code-block:: Perl

   # --
   # Kernel/System/Auth/CustomAuth.pm - provides the CustomAuth authentication
   # based on Martin Edenhofer's Kernel::System::Auth::DB
   # Copyright (C) 2001-2018 OTRS AG, https://otrs.com/
   # --
   # ID: CustomAuth.pm,v 1.1 2010/05/10 15:30:34 fk Exp $
   # --
   # This software comes with ABSOLUTELY NO WARRANTY. For details, see
   # the enclosed file COPYING for license information (GPL). If you
   # did not receive this file, see https://www.gnu.org/licenses/gpl-3.0.txt.
   # --

   package Kernel::System::Auth::CustomAuth;

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
       $Self->{Die} = $Self->{ConfigObject}->Get( 'AuthModule::CustomAuth::Die' . $Param{Count} );

       # get user table
       $Self->{CustomAuthHost} = $Self->{ConfigObject}->Get( 'AuthModule::CustomAuth::Host' . $Param{Count} )
           || die "Need AuthModule::CustomAuth::Host$Param{Count}.";
       $Self->{CustomAuthSecret}
           = $Self->{ConfigObject}->Get( 'AuthModule::CustomAuth::Password' . $Param{Count} )
           || die "Need AuthModule::CustomAuth::Password$Param{Count}.";

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
               Message  => "User: '$User' tried to authenticate with Pw: '$Pw' ($RemoteAddr)",
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
               Message  => "User: $User authentication without Pw!!! (REMOTE_ADDR: $RemoteAddr)",
           );
           return;
       }

       # Create a RADIUS object
       my $CustomAuth = Authen::CustomAuth->new(
           Host   => $Self->{CustomAuthHost},
           Secret => $Self->{CustomAuthecret},
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
               Message  => "User: $User authentication ok (REMOTE_ADDR: $RemoteAddr).",
           );
           return $User;
       }

       # just a note
       else {
           $Self->{LogObject}->Log(
               Priority => 'notice',
               Message  => "User: $User authentication with wrong Pw!!! (REMOTE_ADDR: $RemoteAddr)"
           );
           return;
       }
   }

   1;


Agent Authentication Module Configuration Example
-------------------------------------------------

There is the need to activate your custom agent authenticate module. This can be done using the Perl configuration below. It is not recommended to use the XML configuration because you can lock you out via the system configuration.

.. code-block:: Perl

   $Self->{'AuthModule'} = 'Kernel::System::Auth::CustomAuth';


Agent Authentication Module Use Case Example
--------------------------------------------

A useful example of an authentication implementation could be a SOAP backend.
