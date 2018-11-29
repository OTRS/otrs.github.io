Mapping
=======

The mapping is used to convert data from OTRS to the external systems, and vice versa. This data can be represented as key => value pairs. Mapping modules can be developed to transform not just values but also
the keys.

For example:

+-----------------+-----------------+
| From            | To              |
+=================+=================+
| Prio => Warning | PriorityID => 3 |
+-----------------+-----------------+

The mapping layer is not absolutely necessary, a web service can skip it completely depending on the web service configuration and how invokers and operation are implemented. But if some data transformations are needed, is highly recommended to use an existing mapping module or create a new one.

Mapping modules can be called more than one time during a normal communication, take a look to the following examples.

OTRS as provider example
   1. The remote system sends the request with the data in the remote system format.
   2. The data is mapped from the remote system format to the OTRS format.
   3. OTRS performs the operation and return the response in OTRS format.
   4. The data is mapped from the OTRS format to the remote system format.
   5. The response with the data in the remote system format is sent to the remote system.

OTRS as requester example
   1. OTRS prepares the request to the remote system using the data in the OTRS format.
   2. The data is mapped from the OTRS format to the remote system format.
   3. The request is sent to the remote system which performs the action and sends the response back to OTRS with the data in remote system format.
   4. The data is mapped form remote system format (again) to the OTRS format.
   5. OTRS processes the response.


Mapping Back End
----------------

Generic interface provides a mapping module called *Simple*. With this module most of the data transformations including key and value mapping can be done, and also it defines rules for to handling the default mappings for both keys and values.

So it is highly probable that you don't need to develop a custom mapping module. Please check *Simple* mapping module (``Kernel/GenericInterface/Mapping/Simple.pm``) and its on-line documentation before continue.

If *Simple* mapping module does not match your needs then we will show how to develop a new mapping backend. Each mapping backend has to implement these subroutines:

-  ``new``
-  ``Map``

We should implement each one of this methods in order to be able to map the data in the communication, handled either by the requester or provider. All mapping backends are handled by the mapping module (``Kernel/GenericInterface/Mapping.pm``).


Mapping Code Example
~~~~~~~~~~~~~~~~~~~~

In this section a sample mapping module is shown and each subroutine is explained.

.. code-block:: Perl

   # --
   # Kernel/GenericInterface/Mapping/Test.pm - GenericInterface test data mapping backend
   # Copyright (C) 2001-2018 OTRS AG, https://otrs.com/
   # --
   # This software comes with ABSOLUTELY NO WARRANTY. For details, see
   # the enclosed file COPYING for license information (GPL). If you
   # did not receive this file, see https://www.gnu.org/licenses/gpl-3.0.txt.
   # --

   package Kernel::GenericInterface::Mapping::Test;

   use strict;
   use warnings;

   use Kernel::System::VariableCheck qw(IsHashRefWithData IsStringWithData);

   our $ObjectManagerDisabled = 1;

This is common header that can be found in common OTRS modules. The class/package name is declared via the ``package`` keyword.

We also include ``VariableCheck`` module to perform certain validation over some variables. Mappings can not be instantiated by the object manager.

.. code-block:: Perl

   sub new {
       my ( $Type, %Param ) = @_;

       # allocate new hash for object
       my $Self = {};
       bless( $Self, $Type );

       # check needed params
       for my $Needed (qw(DebuggerObject MappingConfig)) {
           if ( !$Param{$Needed} ) {

               return {
                   Success      => 0,
                   ErrorMessage => "Got no $Needed!"
               };
           }
           $Self->{$Needed} = $Param{$Needed};
       }

       # check mapping config
       if ( !IsHashRefWithData( $Param{MappingConfig} ) ) {

           return $Self->{DebuggerObject}->Error(
               Summary => 'Got no MappingConfig as hash ref with content!',
           );
       }

       # check config - if we have a map config, it has to be a non-empty hash ref
       if (
           defined $Param{MappingConfig}->{Config}
           && !IsHashRefWithData( $Param{MappingConfig}->{Config} )
           )
       {

           return $Self->{DebuggerObject}->Error(
               Summary => 'Got MappingConfig with Data, but Data is no hash ref with content!',
           );
       }

       return $Self;
   }

The constructor ``new`` creates a new instance of the class. According to the coding guidelines only objects of other classes not handled by the object manager that are needed in this module have to be created in ``new``.

.. code-block:: Perl

   sub Map {
       my ( $Self, %Param ) = @_;

       # check data - only accept undef or hash ref
       if ( defined $Param{Data} && ref $Param{Data} ne 'HASH' ) {

           return $Self->{DebuggerObject}->Error(
               Summary => 'Got Data but it is not a hash ref in Mapping Test backend!'
           );
       }

       # return if data is empty
       if ( !defined $Param{Data} || !%{ $Param{Data} } ) {

           return {
               Success => 1,
               Data    => {},
           };
       }

       # no config means that we just return input data
       if (
           !defined $Self->{MappingConfig}->{Config}
           || !defined $Self->{MappingConfig}->{Config}->{TestOption}
           )
       {

           return {
               Success => 1,
               Data    => $Param{Data},
           };
       }

       # check TestOption format
       if ( !IsStringWithData( $Self->{MappingConfig}->{Config}->{TestOption} ) ) {

           return $Self->{DebuggerObject}->Error(
               Summary => 'Got no TestOption as string with value!',
           );
       }

       # parse data according to configuration
       my $ReturnData = {};
       if ( $Self->{MappingConfig}->{Config}->{TestOption} eq 'ToUpper' ) {
           $ReturnData = $Self->_ToUpper( Data => $Param{Data} );
       }
       elsif ( $Self->{MappingConfig}->{Config}->{TestOption} eq 'ToLower' ) {
           $ReturnData = $Self->_ToLower( Data => $Param{Data} );
       }
       elsif ( $Self->{MappingConfig}->{Config}->{TestOption} eq 'Empty' ) {
           $ReturnData = $Self->_Empty( Data => $Param{Data} );
       }
       else {
           $ReturnData = $Param{Data};
       }

       # return result
       return {
           Success => 1,
           Data    => $ReturnData,
       };
   }

The ``Map`` function is the main part of each mapping module. It receives the mapping configuration (rules) and the data in the original format (either OTRS or remote system format) and converts it to a new format, even if the structure of the data can be changed during the mapping process.

In this particular example there are three rules to map the values. This rules are set in the mapping configuration key ``TestOption`` and they are ``ToUpper``, ``ToLower`` and ``Empty``.

- ``ToUpper``: converts each data value to upper case.
- ``ToLower``: converts each data value to lower case.
- ``Empty``: converts each data value into an empty string.

In this example no data key transformations were implemented.

.. code-block:: Perl

   sub _ToUpper {
       my ( $Self, %Param ) = @_;

       my $ReturnData = {};
       for my $Key ( sort keys %{ $Param{Data} } ) {
           $ReturnData->{$Key} = uc $Param{Data}->{$Key};
       }

       return $ReturnData;
   }

   sub _ToLower {
       my ( $Self, %Param ) = @_;

       my $ReturnData = {};
       for my $Key ( sort keys %{ $Param{Data} } ) {
           $ReturnData->{$Key} = lc $Param{Data}->{$Key};
       }

       return $ReturnData;
   }

   sub _Empty {
       my ( $Self, %Param ) = @_;

       my $ReturnData = {};
       for my $Key ( sort keys %{ $Param{Data} } ) {
           $ReturnData->{$Key} = '';
       }

       return $ReturnData;
   }

This are the helper functions that actually performs the string conversions.


Mapping Configuration Example
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

There is the need to register this mapping module to be accessible in the OTRS GUI. This can be done using the XML configuration below.

.. code-block:: XML

   <ConfigItem Name="GenericInterface::Mapping::Module###Test" Required="0" Valid="1">
       <Description Translatable="1">GenericInterface module registration for the mapping layer.</Description>
       <Group>GenericInterface</Group>
       <SubGroup>GenericInterface::Mapping::ModuleRegistration</SubGroup>
       <Setting>
           <Hash>
               <Item Key="ConfigDialog"></Item>
           </Hash>
       </Setting>
   </ConfigItem>
