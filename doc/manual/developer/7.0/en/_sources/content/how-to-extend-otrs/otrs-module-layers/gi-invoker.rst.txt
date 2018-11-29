Invoker
=======

The invoker is used to create a request from OTRS to a remote system. This part of the GI is in charge of perform necessary tasks in OTRS side, to gather the necessary data in order to construct the request.


Invoker Back End
----------------

Next we will show how to develop a new invoker. Each invoker has to implement these subroutines:

-  ``new``
-  ``PrepareRequest``
-  ``HandleResponse``

We should implement each one of this methods in order to be able to execute a request using the request handler (``Kernel/GenericInterface/Requester.pm``).


Invoker Code Example
~~~~~~~~~~~~~~~~~~~~

In this section a sample invoker module is shown and each subroutine is explained.

.. code-block:: Perl

   # --
   # Kernel/GenericInterface/Invoker/Test.pm - GenericInterface test data Invoker backend
   # Copyright (C) 2001-2018 OTRS AG, https://otrs.com/
   # --
   # This software comes with ABSOLUTELY NO WARRANTY. For details, see
   # the enclosed file COPYING for license information (GPL). If you
   # did not receive this file, see https://www.gnu.org/licenses/gpl-3.0.txt.
   # --

   package Kernel::GenericInterface::Invoker::Test::Test;

   use strict;
   use warnings;

   use Kernel::System::VariableCheck qw(IsString IsStringWithData);

   # prevent 'Used once' warning for Kernel::OM
   use Kernel::System::ObjectManager;

   our $ObjectManagerDisabled = 1;

This is common header that can be found in common OTRS modules. The class/package name is declared via the ``package`` keyword. Invokers can not be instantiated by the object manager.

.. code-block:: Perl

   sub new {
       my ( $Type, %Param ) = @_;

       # allocate new hash for object
       my $Self = {};
       bless( $Self, $Type );

       # check needed params
       if ( !$Param{DebuggerObject} ) {
           return {
               Success      => 0,
               ErrorMessage => "Got no DebuggerObject!"
           };
       }

       $Self->{DebuggerObject} = $Param{DebuggerObject};

       return $Self;
   }

The constructor ``new`` creates a new instance of the class. According to the coding guidelines only objects of other classes not handled by the object manager that are needed in this module have to be created in ``new``.

.. code-block:: Perl

   sub PrepareRequest {
       my ( $Self, %Param ) = @_;

       # we need a TicketNumber
       if ( !IsStringWithData( $Param{Data}->{TicketNumber} ) ) {
           return $Self->{DebuggerObject}->Error( Summary => 'Got no TicketNumber' );
       }

       my %ReturnData;

       $ReturnData{TicketNumber} = $Param{Data}->{TicketNumber};

       # check Action
       if ( IsStringWithData( $Param{Data}->{Action} ) ) {
           $ReturnData{Action} = $Param{Data}->{Action} . 'Test';
       }

       # check request for system time
       if ( IsStringWithData( $Param{Data}->{GetSystemTime} ) && $Param{Data}->{GetSystemTime} ) {
           $ReturnData{SystemTime} = $Kernel::OM->Get('Kernel::System::Time')->SystemTime();
       }

       return {
           Success => 1,
           Data    => \%ReturnData,
       };
   }

The ``PrepareRequest`` function is used to handle and collect all needed data to be sent into the request. Here we can receive data from the request handler, use it, extend it, generate new data, and after that, we can transfer the results to the mapping layer.

For this example we are expecting to receive a ticket number. If there isn't then we use the debugger method ``Error()`` that creates an entry in the debug log and also returns a structure with the parameter ``Success`` as 0 and an error message as the passed ``Summary``.

Also this example appends the word *Test* to the parameter ``Action`` and if ``GetSystemTime`` is requested, it will fill the ``SystemTime`` parameter with the current system time. This part of the code is to prepare the data to be sent. On a real invoker some calls to core modules (``Kernel/System/*.pm``) should be made here.

If during any part of the ``PrepareRequest`` function the request need to be stop without generating and error an entry in the debug log the following code can be used:

.. code-block:: Perl

   # stop requester communication
   return {
       Success           => 1,
       StopCommunication => 1,
   };

Using this, the requester will understand that the request should not continue (it will not be sent to mapping layer and will also not be sent to the network transport). The requester will not send an error on the debug log, it will only silently stop.

.. code-block:: Perl

   sub HandleResponse {
       my ( $Self, %Param ) = @_;

       # if there was an error in the response, forward it
       if ( !$Param{ResponseSuccess} ) {
           if ( !IsStringWithData( $Param{ResponseErrorMessage} ) ) {

               return $Self->{DebuggerObject}->Error(
                   Summary => 'Got response error, but no response error message!',
               );
           }

           return {
               Success      => 0,
               ErrorMessage => $Param{ResponseErrorMessage},
           };
       }

       # we need a TicketNumber
       if ( !IsStringWithData( $Param{Data}->{TicketNumber} ) ) {

           return $Self->{DebuggerObject}->Error( Summary => 'Got no TicketNumber!' );
       }

       # prepare TicketNumber
       my %ReturnData = (
           TicketNumber => $Param{Data}->{TicketNumber},
       );

       # check Action
       if ( IsStringWithData( $Param{Data}->{Action} ) ) {
           if ( $Param{Data}->{Action} !~ m{ \A ( .*? ) Test \z }xms ) {

               return $Self->{DebuggerObject}->Error(
                   Summary => 'Got Action but it is not in required format!',
               );
           }
           $ReturnData{Action} = $1;
       }

       return {
           Success => 1,
           Data    => \%ReturnData,
       };
   }

The ``HandleResponse`` function is used to receive and process the data from the previous request, that was made to the remote system. This data already passed by mapping layer, to transform it from remote system
format to OTRS format (if needed).

For this particular example it checks the ticket number again and check if the action ends with the word *Test* (as was done in the ``PrepareRequest`` function).

.. note::

   This invoker is only used for tests, a real invoker will check if the response was on the format described by the remote system and can perform some actions like: call another invoker, perform a call to a core module, update the database, send an error, etc.


Invoker Configuration Example
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

There is the need to register this invoker module to be accessible in the OTRS GUI. This can be done using the XML configuration below.

.. code-block:: XML

   <ConfigItem Name="GenericInterface::Invoker::Module###Test::Test" Required="0" Valid="1">
       <Description Translatable="1">GenericInterface module registration for the invoker layer.</Description>
       <Group>GenericInterface</Group>
       <SubGroup>GenericInterface::Invoker::ModuleRegistration</SubGroup>
       <Setting>
           <Hash>
               <Item Key="Name">Test</Item>
               <Item Key="Controller">Test</Item>
               <Item Key="ConfigDialog">AdminGenericInterfaceInvokerDefault</Item>
           </Hash>
       </Setting>
   </ConfigItem>
