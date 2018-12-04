Network Transport
=================

The network transport is used as method to send and receive information between OTRS and a remote system. The generic interface configuration allows a web service to use different network transport modules for
provider and requester, but the most common scenario is that the same transport module is used for both.

OTRS as provider
   OTRS uses the network transport modules to get the data from the remote system and the operation to be executed. After the operation is performed OTRS uses them again to send the response back to the remote system.

OTRS as requester
   OTRS uses the network transport modules to send petitions to the remote system to perform a remote action along with the required data. OTRS waits for the remote system response and send it back to the requester module.

In both ways network transport modules deal with the data in the remote system format. It is not recommended to do any data transformation in this modules, as the mapping layer is the responsible to perform any data transformation needed during the communication. An exception of this is the data conversion that is required specifically by for the transport e.g. XML or JSON from / to Perl conversions.


Transport Back End
------------------

Next we will show how to develop a new transport backend. Each transport backend has to implement these subroutines:

-  ``new``
-  ``ProviderProcessRequest``
-  ``ProviderGenerateResponse``
-  ``RequesterPerformRequest``

We should implement each one of this methods in order to be able to communicate correctly with a remote system in both ways. All network transport backends are handled by the transport module (``Kernel/GenericInterface/Transport.pm``).

Currently generic interface implements the HTTP SOAP and HTTP REST transports. If the planned web service can use HTTP SOAP or HTTP SOAP there is no need to create a new network transport module, instead we recommend to take a look into HTTP SOAP or HTTP REST configurations to check their settings and how it can be tuned according to the remote system.


Network Transport Code Example
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

In case that the provided network transports does not match the web service needs, then in this section a sample network transport module is shown and each subroutine is explained. Normally transport modules uses CPAN modules as backends. For example the HTTP SOAP transport modules uses ``SOAP::Lite`` module as backend.

For this example a custom package is used to return the data without doing a real network request to a remote system, instead this custom module acts as a loop-back interface.

.. code-block:: Perl

   # --
   # Kernel/GenericInterface/Transport/HTTP/Test.pm - GenericInterface network transport interface for testing
   # Copyright (C) 2001-2018 OTRS AG, https://otrs.com/
   # --
   # This software comes with ABSOLUTELY NO WARRANTY. For details, see
   # the enclosed file COPYING for license information (GPL). If you
   # did not receive this file, see https://www.gnu.org/licenses/gpl-3.0.txt.
   # --

   package Kernel::GenericInterface::Transport::HTTP::Test;

   use strict;
   use warnings;

   use HTTP::Request::Common;
   use LWP::UserAgent;
   use LWP::Protocol;

   # prevent 'Used once' warning for Kernel::OM
   use Kernel::System::ObjectManager;

   our $ObjectManagerDisabled = 1;

This is common header that can be found in common OTRS modules. The class/package name is declared via the ``package`` keyword. Transports can not be instantiated by the object manager.

.. code-block:: Perl

   sub new {
       my ( $Type, %Param ) = @_;

       my $Self = {};
       bless( $Self, $Type );

       for my $Needed (qw( DebuggerObject TransportConfig)) {
           $Self->{$Needed} = $Param{$Needed} || return {
               Success      => 0,
               ErrorMessage => "Got no $Needed!"
           };
       }

       return $Self;
   }        

The constructor ``new`` creates a new instance of the class. According to the coding guidelines only objects of other classes not handled by the object manager that are needed in this module have to be created in ``new``.

.. code-block:: Perl

   sub ProviderProcessRequest {
       my ( $Self, %Param ) = @_;

       if ( $Self->{TransportConfig}->{Config}->{Fail} ) {

           return {
               Success      => 0,
               ErrorMessage => "HTTP status code: 500",
               Data         => {},
           };
       }

       my $ParamObject = $Kernel::OM->Get('Kernel::System::Web::Request');

       my %Result;
       for my $ParamName ( $ParamObject->GetParamNames() ) {
           $Result{$ParamName} = $ParamObject->GetParam( Param => $ParamName );
       }

       # special handling for empty post request
       if ( scalar keys %Result == 1 && exists $Result{POSTDATA} && !$Result{POSTDATA} ) {
           %Result = ();
       }

       if ( !%Result ) {

           return $Self->{DebuggerObject}->Error(
               Summary => 'No request data found.',
           );
       }

       return {
           Success   => 1,
           Data      => \%Result,
           Operation => 'test_operation',
       };
   }

The ``ProviderProcessRequest`` function gets the request from the remote system (in this case the same OTRS) and extracts the data and the operation to perform from the request. For this example the operation is always ``test_operation``.

The way this function parses the request to get the data and the operation name, depends completely on the protocol to be implemented and the external modules that are used for.

.. code-block:: Perl

   sub ProviderGenerateResponse {
       my ( $Self, %Param ) = @_;

       if ( $Self->{TransportConfig}->{Config}->{Fail} ) {

           return {
               Success      => 0,
               ErrorMessage => 'Test response generation failed',
           };
       }

       my $Response;

       if ( !$Param{Success} ) {
           $Response
               = HTTP::Response->new( 500 => ( $Param{ErrorMessage} || 'Internal Server Error' ) );
           $Response->protocol('HTTP/1.0');
           $Response->content_type("text/plain; charset=UTF-8");
           $Response->date(time);
       }
       else {

           # generate a request string from the data
           my $Request
               = HTTP::Request::Common::POST( 'http://testhost.local/', Content => $Param{Data} );

           $Response = HTTP::Response->new( 200 => "OK" );
           $Response->protocol('HTTP/1.0');
           $Response->content_type("text/plain; charset=UTF-8");
           $Response->add_content_utf8( $Request->content() );
           $Response->date(time);
       }

       $Self->{DebuggerObject}->Debug(
           Summary => 'Sending HTTP response',
           Data    => $Response->as_string(),
       );

       # now send response to client
       print STDOUT $Response->as_string();

       return {
           Success => 1,
       };
   }

This function sends the response back to the remote system for the requested operation.

For this particular example we return a standard HTTP response success (200) or not (500), along with the required data on each case.

.. code-block:: Perl

   sub RequesterPerformRequest {
       my ( $Self, %Param ) = @_;

       if ( $Self->{TransportConfig}->{Config}->{Fail} ) {

           return {
               Success      => 0,
               ErrorMessage => "HTTP status code: 500",
               Data         => {},
           };
       }

       # use custom protocol handler to avoid sending out real network requests
       LWP::Protocol::implementor(
           testhttp => 'Kernel::GenericInterface::Transport::HTTP::Test::CustomHTTPProtocol'
       );
       my $UserAgent = LWP::UserAgent->new();
       my $Response = $UserAgent->post( 'testhttp://localhost.local/', Content => $Param{Data} );

       return {
           Success => 1,
           Data    => {
               ResponseContent => $Response->content(),
           },
       };
   }

This is the only function that is used by OTRS as requester. It sends the request to the remote system and waits for its response.

For this example we use a custom protocol handler to avoid send the request to the real network. This custom protocol is specified below.

.. code-block:: Perl

   package Kernel::GenericInterface::Transport::HTTP::Test::CustomHTTPProtocol;

   use base qw(LWP::Protocol);

   sub new {
       my $Class = shift;

       return $Class->SUPER::new(@_);
   }

   sub request {    ## no critic
       my $Self = shift;

       my ( $Request, $Proxy, $Arg, $Size, $Timeout ) = @_;

       my $Response = HTTP::Response->new( 200 => "OK" );
       $Response->protocol('HTTP/1.0');
       $Response->content_type("text/plain; charset=UTF-8");
       $Response->add_content_utf8( $Request->content() );
       $Response->date(time);

       #print $Request->as_string();
       #print $Response->as_string();

       return $Response;
   }

This is the code for the custom protocol that we use. This approach is only useful for training or for testing environments where the remote systems are not available.

For a new module development we do not recommend to use this approach, a real protocol needs to be implemented.


Network Transport Configuration Example
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

There is the need to register this network transport module to be accessible in the OTRS GUI. This can be done using the XML configuration below.

.. code-block:: XML

   <ConfigItem Name="GenericInterface::Transport::Module###HTTP::Test" Required="0" Valid="1">
       <Description Translatable="1">GenericInterface module registration for the transport layer.</Description>
       <Group>GenericInterface</Group>
       <SubGroup>GenericInterface::Transport::ModuleRegistration</SubGroup>
       <Setting>
           <Hash>
               <Item Key="Name">Test</Item>
               <Item Key="Protocol">HTTP</Item>
               <Item Key="ConfigDialog">AdminGenericInterfaceTransportHTTPTest</Item>
           </Hash>
       </Setting>
   </ConfigItem>
