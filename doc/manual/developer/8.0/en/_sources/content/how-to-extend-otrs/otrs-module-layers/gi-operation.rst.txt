Operation
=========

The operation is used to perform an action within OTRS. This action is requested by the external system and can include special parameters in order to correctly execute the action. After the action is performed, OTRS sends a defined confirmation to the external system.


Operation Back End
------------------

Next we will show how to develop a new operation, each operation has to implement these subroutines:

-  ``new``
-  ``Run``

We should implement each one of this methods in order to be able to execute the action handled by the provider (``Kernel/GenericInterface/Provider.pm``).


Operation Code Example
~~~~~~~~~~~~~~~~~~~~~~

In this section a sample operation module is shown and each subroutine is explained.

.. code-block:: Perl

   # --
   # Kernel/GenericInterface/Operation/Test/Test.pm - GenericInterface test operation backend
   # Copyright (C) 2001-2018 OTRS AG, https://otrs.com/
   # --
   # This software comes with ABSOLUTELY NO WARRANTY. For details, see
   # the enclosed file COPYING for license information (GPL). If you
   # did not receive this file, see https://www.gnu.org/licenses/gpl-3.0.txt.
   # --

   package Kernel::GenericInterface::Operation::Test::Test;

   use strict;
   use warnings;

   use Kernel::System::VariableCheck qw(IsHashRefWithData);

   our $ObjectManagerDisabled = 1;

This is common header that can be found in common OTRS modules. The class/package name is declared via the ``package`` keyword.

We also include ``VariableCheck`` module to perform certain validation over some variables. Operations can not be instantiated by the object manager.

.. code-block:: Perl

   sub new {
       my ( $Type, %Param ) = @_;

       my $Self = {};
       bless( $Self, $Type );

       # check needed objects
       for my $Needed (qw(DebuggerObject)) {
           if ( !$Param{$Needed} ) {
               return {
                   Success      => 0,
                   ErrorMessage => "Got no $Needed!"
               };
           }

           $Self->{$Needed} = $Param{$Needed};
       }

       return $Self;
   }

The constructor ``new`` creates a new instance of the class. According to the coding guidelines only objects of other classes not handled by the object manager that are needed in this module have to be created in ``new``.

.. code-block:: Perl

   sub Run {
       my ( $Self, %Param ) = @_;

       # check data - only accept undef or hash ref
       if ( defined $Param{Data} && ref $Param{Data} ne 'HASH' ) {

           return $Self->{DebuggerObject}->Error(
               Summary => 'Got Data but it is not a hash ref in Operation Test backend)!'
           );
       }

       if ( defined $Param{Data} && $Param{Data}->{TestError} ) {

           return {
               Success      => 0,
               ErrorMessage => "Error message for error code: $Param{Data}->{TestError}",
               Data         => {
                   ErrorData => $Param{Data}->{ErrorData},
               },
           };
       }

       # copy data
       my $ReturnData;

       if ( ref $Param{Data} eq 'HASH' ) {
           $ReturnData = \%{ $Param{Data} };
       }
       else {
           $ReturnData = undef;
       }

       # return result
       return {
           Success => 1,
           Data    => $ReturnData,
       };
   }

The ``Run`` function is the main part of each operation. It receives all internal mapped data from remote system needed by the provider to execute the action, it performs the action and returns the result to the provider to be external mapped and deliver back to the remote system.

This particular example returns the same data as came from the remote system, unless ``TestError`` parameter is passed. In this case it returns an error.


Operation Configuration Example
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

There is the need to register this operation module to be accessible in the OTRS GUI. This can be done using the XML configuration below.

.. code-block:: XML

   <ConfigItem Name="GenericInterface::Operation::Module###Test::Test" Required="0" Valid="1">
       <Description Translatable="1">GenericInterface module registration for the operation layer.</Description>
       <Group>GenericInterface</Group>
       <SubGroup>GenericInterface::Operation::ModuleRegistration</SubGroup>
       <Setting>
           <Hash>
               <Item Key="Name">Test</Item>
               <Item Key="Controller">Test</Item>
               <Item Key="ConfigDialog">AdminGenericInterfaceOperationDefault</Item>
           </Hash>
       </Setting>
   </ConfigItem>


Unit Test Example
~~~~~~~~~~~~~~~~~

Unit test for generic interface operations does not differs from other unit tests but it is needed to consider testing locally, but also simulating a remote connection. It is a good practice to test both separately since results could be slightly different.

.. seealso::

   To learn more about unit tests, please take a look to the :doc:`../../contributing/unit-tests` chapter.

The following is just the starting point for a unit test:

.. code-block:: Perl

   # --
   # Copyright (C) 2001-2018 OTRS AG, https://otrs.com/
   # --
   # This software comes with ABSOLUTELY NO WARRANTY. For details, see
   # the enclosed file COPYING for license information (GPL). If you
   # did not receive this file, see https://www.gnu.org/licenses/gpl-3.0.txt.
   # --

   ## no critic (Modules::RequireExplicitPackage)
   use strict;
   use warnings;
   use utf8;

   use vars (qw($Self));

   use Kernel::GenericInterface::Debugger;
   use Kernel::GenericInterface::Operation::Test::Test;

   use Kernel::System::VariableCheck qw(:all);

   # Skip SSL certificate verification (RestoreDatabase must not be used in this test).
   $Kernel::OM->ObjectParamAdd(
       'Kernel::System::UnitTest::Helper' => {
           SkipSSLVerify => 1,
       },
   );
   my $Helper = $Kernel::OM->Get('Kernel::System::UnitTest::Helper');

   # get a random number
   my $RandomID = $Helper->GetRandomNumber();

   # create a new user for current test
   my $UserLogin = $Helper->TestUserCreate(
       Groups => ['users'],
   );
   my $Password = $UserLogin;

   my $UserID = $Kernel::OM->Get('Kernel::System::User')->UserLookup(
       UserLogin => $UserLogin,
   );

   # set web-service name
   my $WebserviceName = '-Test-' . $RandomID;

   # create web-service object
   my $WebserviceObject = $Kernel::OM->Get('Kernel::System::GenericInterface::Webservice');
   $Self->Is(
       'Kernel::System::GenericInterface::Webservice',
       ref $WebserviceObject,
       "Create web service object",
   );

   my $WebserviceID = $WebserviceObject->WebserviceAdd(
       Name   => $WebserviceName,
       Config => {
           Debugger => {
               DebugThreshold => 'debug',
           },
           Provider => {
               Transport => {
                   Type => '',
               },
           },
       },
       ValidID => 1,
       UserID  => 1,
   );
   $Self->True(
       $WebserviceID,
       "Added Web Service",
   );

   # get remote host with some precautions for certain unit test systems
   my $Host = $Helper->GetTestHTTPHostname();

   my $ConfigObject = $Kernel::OM->Get('Kernel::Config');

   # prepare web-service config
   my $RemoteSystem =
       $ConfigObject->Get('HttpType')
       . '://'
       . $Host
       . '/'
       . $ConfigObject->Get('ScriptAlias')
       . '/nph-genericinterface.pl/WebserviceID/'
       . $WebserviceID;

   my $WebserviceConfig = {
       Description =>
           'Test for Ticket Connector using SOAP transport backend.',
       Debugger => {
           DebugThreshold => 'debug',
           TestMode       => 1,
       },
       Provider => {
           Transport => {
               Type   => 'HTTP::SOAP',
               Config => {
                   MaxLength => 10000000,
                   NameSpace => 'http://otrs.org/SoapTestInterface/',
                   Endpoint  => $RemoteSystem,
               },
           },
           Operation => {
               Test => {
                   Type => 'Test::Test',
               },
           },
       },
       Requester => {
           Transport => {
               Type   => 'HTTP::SOAP',
               Config => {
                   NameSpace => 'http://otrs.org/SoapTestInterface/',
                   Encoding  => 'UTF-8',
                   Endpoint  => $RemoteSystem,
               },
           },
           Invoker => {
               Test => {
                   Type => 'Test::TestSimple'
                   ,    # requester needs to be Test::TestSimple in order to simulate a request to a remote system
               },
           },
       },
   };

   # update web-service with real config
   # the update is needed because we are using
   # the WebserviceID for the Endpoint in config
   my $WebserviceUpdate = $WebserviceObject->WebserviceUpdate(
       ID      => $WebserviceID,
       Name    => $WebserviceName,
       Config  => $WebserviceConfig,
       ValidID => 1,
       UserID  => $UserID,
   );
   $Self->True(
       $WebserviceUpdate,
       "Updated Web Service $WebserviceID - $WebserviceName",
   );

   # debugger object
   my $DebuggerObject = Kernel::GenericInterface::Debugger->new(
       DebuggerConfig => {
           DebugThreshold => 'debug',
           TestMode       => 1,
       },
       WebserviceID      => $WebserviceID,
       CommunicationType => 'Provider',
   );
   $Self->Is(
       ref $DebuggerObject,
       'Kernel::GenericInterface::Debugger',
       'DebuggerObject instantiate correctly',
   );

   # define test cases
   my @Tests = (
       {
           Name           => 'Test case name',
           SuccessRequest => 1,                  # 1 or 0
           RequestData    => {

               # ... add test data
           },
           ExpectedReturnLocalData => {
               Data => {

                   # ... add expected local results
               },
               Success => 1,                     # 1 or 0
           },
           ExpectedReturnRemoteData => {
               Data => {

                   # ... add expected remote results
               },
               Success => 1,                     # 1 or 0
           },
           Operation => 'Test',
       },

       # ... add more test cases
   );

   TEST:
   for my $Test (@Tests) {

       # create local object
       my $LocalObject = "Kernel::GenericInterface::Operation::Test::$Test->{Operation}"->new(
           DebuggerObject => $DebuggerObject,
           WebserviceID   => $WebserviceID,
       );

       $Self->Is(
           "Kernel::GenericInterface::Operation::Test::$Test->{Operation}",
           ref $LocalObject,
           "$Test->{Name} - Create local object",
       );

       my %Auth = (
           UserLogin => $UserLogin,
           Password  => $Password,
       );
       if ( IsHashRefWithData( $Test->{Auth} ) ) {
           %Auth = %{ $Test->{Auth} };
       }

       # start requester with our web-service
       my $LocalResult = $LocalObject->Run(
           WebserviceID => $WebserviceID,
           Invoker      => $Test->{Operation},
           Data         => {
               %Auth,
               %{ $Test->{RequestData} },
           },
       );

       # check result
       $Self->Is(
           'HASH',
           ref $LocalResult,
           "$Test->{Name} - Local result structure is valid",
       );

       # create requester object
       my $RequesterObject = $Kernel::OM->Get('Kernel::GenericInterface::Requester');
       $Self->Is(
           'Kernel::GenericInterface::Requester',
           ref $RequesterObject,
           "$Test->{Name} - Create requester object",
       );

       # start requester with our web-service
       my $RequesterResult = $RequesterObject->Run(
           WebserviceID => $WebserviceID,
           Invoker      => $Test->{Operation},
           Data         => {
               %Auth,
               %{ $Test->{RequestData} },
           },
       );

       # check result
       $Self->Is(
           'HASH',
           ref $RequesterResult,
           "$Test->{Name} - Requester result structure is valid",
       );

       $Self->Is(
           $RequesterResult->{Success},
           $Test->{SuccessRequest},
           "$Test->{Name} - Requester successful result",
       );

       # ... add tests for the results
   }

   # delete web service
   my $WebserviceDelete = $WebserviceObject->WebserviceDelete(
       ID     => $WebserviceID,
       UserID => $UserID,
   );
   $Self->True(
       $WebserviceDelete,
       "Deleted Web Service $WebserviceID",
   );

   # also delete any other added data during the this test, since RestoreDatabase must not be used.

   1;


WSDL Extension Example
~~~~~~~~~~~~~~~~~~~~~~

WSDL files contain the definitions of the web services and its operations for SOAP messages, in case we will extend ``development/webservices/GenericTickeConnectorSOAP.wsdl`` in some places:

Port Type:

.. code-block:: XML

       <wsdl:portType name="GenericTicketConnector_PortType">
           <!-- ... -->
           <wsdl:operation name="Test">
               <wsdl:input message="tns:TestRequest"/>
               <wsdl:output message="tns:TestResponse"/>
           </wsdl:operation>
       <!-- ... -->

Binding:

.. code-block:: XML

       <wsdl:binding name="GenericTicketConnector_Binding" type="tns:GenericTicketConnector_PortType">
           <soap:binding style="document" transport="http://schemas.xmlsoap.org/soap/http"/>
           <!-- ... -->
           <wsdl:operation name="Test">
               <soap:operation soapAction="http://www.otrs.org/TicketConnector/Test"/>
               <wsdl:input>
                   <soap:body use="literal"/>
               </wsdl:input>
               <wsdl:output>
                   <soap:body use="literal"/>
               </wsdl:output>
           </wsdl:operation>
           <!-- ... -->
       </wsdl:binding>

Type:

.. code-block:: XML

       <wsdl:types>
           <xsd:schema targetNamespace="http://www.otrs.org/TicketConnector/" xmlns:xsd="http://www.w3.org/2001/XMLSchema">
           <!-- ... -->
               <xsd:element name="Test">
                   <xsd:complexType>
                       <xsd:sequence>
                               <xsd:element minOccurs="0" name="Param1" type="xsd:string"/>
                               <xsd:element minOccurs="0" name="Param2" type="xsd:positiveInteger"/>
                       </xsd:sequence>
                   </xsd:complexType>
               </xsd:element>
               <xsd:element name="TestResponse">
                   <xsd:complexType>
                       <xsd:sequence>
                           <xsd:element maxOccurs="unbounded" minOccurs="1" name="Attribute1" type="xsd:string"/>
                       </xsd:sequence>
                   </xsd:complexType>
               </xsd:element>
           <!-- ... -->
           </xsd:schema>
       </wsdl:types>

Message:

.. code-block:: XML

       <!-- ... -->
       <wsdl:message name="TestRequest">
           <wsdl:part element="tns:Test" name="parameters"/>
       </wsdl:message>
       <wsdl:message name="TestResponse">
           <wsdl:part element="tns:TestResponse" name="parameters"/>
       </wsdl:message>
       <!-- ... -->


WADL Extension Example
~~~~~~~~~~~~~~~~~~~~~~

WADL files contain the definitions of the web services and its operations for REST interface, add a new resource to ``development/webservices/GenericTickeConnectorREST.wadl``.

.. code-block:: XML

     <resources base="http://localhost/otrs/nph-genericinterface.pl/Webservice/GenericTicketConnectorREST">
       <!-- ... -->
       <resource path="Test" id="Test">
         <doc xml:lang="en" title="Test"/>
           <param name="Param1" type="xs:string" required="false" default="" style="query" xmlns:xs="http://www.w3.org/2001/XMLSchema"/>
           <param name="Param2" type="xs:string" required="false" default="" style="query" xmlns:xs="http://www.w3.org/2001/XMLSchema"/>
           <method name="GET" id="GET_Test">
             <doc xml:lang="en" title="GET_Test"/>
             <request/>
             <response status="200">
               <representation mediaType="application/json; charset=UTF-8"/>
             </response>
           </method>
         </resource>
       </resource>
       <!-- ... -->
     </resources>


Web Service SOAP Extension Example
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Web services can be imported into OTRS by a YAML with a predefined structure in this case we will extend ``development/webservices/GenericTickeConnectorSOAP.yml`` for a SOAP web service.

.. code-block:: YAML

   Provider:
     Operation:
       # ...
       Test:
         Description: This is only a test
         MappingInbound: {}
         MappingOutbound: {}
         Type: Test::Test


Web Service REST Extension Example
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Web services can be imported into OTRS by a YAML with a predefined structure in this case we will extend ``development/webservices/GenericTickeConnectorREST.yml`` for a REST web service.

.. code-block:: YAML

   Provider:
     Operation:
       # ...
       Test:
         Description: This is only a test
         MappingInbound: {}
         MappingOutbound: {}
         Type: Test::Test
     # ...
     Transport:
       Config:
         # ...
         RouteOperationMapping:
           # ..
           Test:
             RequestMethod:
             - GET
             Route: /Test
