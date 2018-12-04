Authentication Synchronization Module
=====================================

There is an LDAP authentication synchronization module which come with the OTRS framework. It is also possible to develop your own authentication modules. The authentication synchronization modules are located under ``Kernel/System/Auth/Sync/*.pm``. For more information about their configuration see the admin manual. Following, there is an example of an authentication synchronization module. Save it under ``Kernel/System/Auth/Sync/CustomAuthSync.pm``. You just need 2 functions: ``new()`` and ``Sync()``. Return 1, then the synchronization is ok.


Authentication Synchronization Module Code Example
--------------------------------------------------

The interface class is called ``Kernel::System::Auth``. The example agent authentication may be called
``Kernel::System::Auth::Sync::CustomAuthSync``. You can find an example below.

.. code-block:: Perl

   # --
   # Kernel/System/Auth/Sync/CustomAuthSync.pm - provides the CustomAuthSync
   # Copyright (C) 2001-2018 OTRS AG, https://otrs.com/
   # --
   # Id: CustomAuthSync.pm,v 1.9 2010/03/25 14:42:45 martin Exp $
   # --
   # This software comes with ABSOLUTELY NO WARRANTY. For details, see
   # the enclosed file COPYING for license information (GPL). If you
   # did not receive this file, see https://www.gnu.org/licenses/gpl-3.0.txt.
   # --

   package Kernel::System::Auth::Sync::CustomAuthSync;

   use strict;
   use warnings;
   use Net::LDAP;

   sub new {
       my ( $Type, %Param ) = @_;

       # allocate new hash for object
       my $Self = {};
       bless( $Self, $Type );

       # check needed objects
       for (qw(LogObject ConfigObject DBObject UserObject GroupObject EncodeObject)) {
           $Self->{$_} = $Param{$_} || die "No $_!";
       }

       # Debug 0=off 1=on
       $Self->{Debug} = 0;

   ...

       return $Self;
   }

   sub Sync {
       my ( $Self, %Param ) = @_;

       # check needed stuff
       for (qw(User)) {
           if ( !$Param{$_} ) {
               $Self->{LogObject}->Log( Priority => 'error', Message => "Need $_!" );
               return;
           }
       }
   ...
       return 1;
   }


Authentication Synchronization Module Configuration Example
-----------------------------------------------------------

You should activate your custom synchronization module. This can be done using the Perl configuration below. It is not recommended to use the XML configuration because this would allow you to lock yourself out via system configuration.

.. code-block:: Perl

   $Self->{'AuthSyncModule'} = 'Kernel::System::Auth::Sync::LDAP';


Authentication Synchronization Module Use Case Example
------------------------------------------------------

Useful synchronization implementation could be a SOAP or RADIUS backend.
