Creating a Dynamic Field Functionality Extension
================================================

To illustrate this process a new dynamic field functionality extension for the function ``Foo`` will be added to the back end object as well as in the text field driver.

To create this extension we will create 3 files:

1. A configuration file (XML) to register the modules.
2. A back end extension (Perl) to define the new function.
3. A text field driver extension (Perl) that implements the new function for text fields.

File structure:

::

   $HOME (e. g. /opt/otrs/)
   |
   ...
   |--/Kernel/
   |   |--/Config/
   |   |   |--/Files/
   |   |   |   |--/XML/
   |   |   |   |DynamicFieldFooExtension.xml
   ...
   |   |--/System/
   |   |   |--/DynamicField/
   |   |   |   FooExtensionBackend.pm
   |   |   |   |--/Driver/
   |   |   |   |   |FooExtensionText.pm
   ...

Dynamic Field Foo Extension files
---------------------------------

Dynamic Field Extension Configuration File Example
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

The configuration files are used to register the extensions for the back end and drivers as well as new behaviors for each drivers.

.. note::

   If a driver is extended with a new function, the backend will need also an extension for that function.

In this section a configuration file for ``Foo`` extension is shown and explained.

.. code-block:: XML

   <?xml version="1.0" encoding="utf-8" ?>
   <otrs_config version="2.0" init="Application">

This is the normal header for a configuration file.

.. code-block:: XML

       <ConfigItem Name="DynamicFields::Extension::Backend###100-Foo" Required="0" Valid="1">
           <Description Translatable="1">Dynamic Fields Extension.</Description>
           <Group>DynamicFieldFooExtension</Group>
           <SubGroup>DynamicFields::Extension::Registration</SubGroup>
           <Setting>
               <Hash>
                   <Item Key="Module">Kernel::System::DynamicField::FooExtensionBackend</Item>
               </Hash>
           </Setting>
       </ConfigItem>

This setting registers the extension in the back end object. The module will be loaded from ``Backend`` as a base class.

.. code-block:: XML

       <ConfigItem Name="DynamicFields::Extension::Driver::Text###100-Foo" Required="0" Valid="1">
           <Description Translatable="1">Dynamic Fields Extension.</Description>
           <Group>DynamicFieldFooExtension</Group>
           <SubGroup>DynamicFields::Extension::Registration</SubGroup>
           <Setting>
               <Hash>
                   <Item Key="Module">Kernel::System::DynamicField::Driver::FooExtensionText</Item>
                   <Item Key="Behaviors">
                       <Hash>
                           <Item Key="Foo">1</Item>
                       </Hash>
                   </Item>
               </Hash>
           </Setting>
       </ConfigItem>

This is the registration for an extension in the text dynamic field driver. The module will be loaded as a base class in the driver. Notice also that new behaviors can be specified. These extended behaviors will be added to the behaviors that the driver has out of the box, therefore a call to ``HasBehavior()`` to check for these new behaviors will be totally transparent.

.. code-block:: XML

   </otrs_config>

Standard closure of a configuration file.


Dynamic Field Backend Extension Example
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Backend extensions will be loaded transparently into the back end itself as a base class. All defined object and properties from the back end will be accessible in the extension.

.. note::

   All new functions defined in the back end extension should be implemented in a driver extension.

In this section the ``Foo`` extension for back end is shown and explained. The extension only defines the function ``Foo()``.

.. code-block:: Perl

   # --
   # Kernel/System/DynamicField/FooExtensionBackend.pm - Extension for DynamicField backend
   # Copyright (C) 2001-2018 OTRS AG, https://otrs.com/
   # --
   # This software comes with ABSOLUTELY NO WARRANTY. For details, see
   # the enclosed file COPYING for license information (GPL). If you
   # did not receive this file, see https://www.gnu.org/licenses/gpl-3.0.txt.
   # --

   package Kernel::System::DynamicField::FooExtensionBackend;

   use strict;
   use warnings;

   use Kernel::System::VariableCheck qw(:all);

   =head1 NAME

   Kernel::System::DynamicField::FooExtensionBackend

   =head1 SYNOPSIS

   DynamicFields Extension for Backend

   =head1 PUBLIC INTERFACE

   =over 4

   =cut

This is common header that can be found in common OTRS modules. The class/package name is declared via the ``package`` keyword.

.. code-block:: Perl

   =item Foo()

   Testing function: returns 1 if function is available on a Dynamic Field driver.

       my $Success = $BackendObject->Foo(
           DynamicFieldConfig   => $DynamicFieldConfig,      # complete config of the DynamicField
       );

   Returns:
       $Success = 1;       # or undef

   =cut

   sub Foo {
       my ( $Self, %Param ) = @_;

       # check needed stuff
       for my $Needed (qw(DynamicFieldConfig)) {
           if ( !$Param{$Needed} ) {
               $Kernel::OM->Get('Kernel::System::Log')->Log(
                   Priority => 'error',
                   Message  => "Need $Needed!",
               );

               return;
           }
       }

       # check DynamicFieldConfig (general)
       if ( !IsHashRefWithData( $Param{DynamicFieldConfig} ) ) {
           $Kernel::OM->Get('Kernel::System::Log')->Log(
               Priority => 'error',
               Message  => "The field configuration is invalid",
           );

           return;
       }

       # check DynamicFieldConfig (internally)
       for my $Needed (qw(ID FieldType ObjectType)) {
           if ( !$Param{DynamicFieldConfig}->{$Needed} ) {
               $Kernel::OM->Get('Kernel::System::Log')->Log(
                   Priority => 'error',
                   Message  => "Need $Needed in DynamicFieldConfig!",
               );

               return;
           }
       }

       # set the dynamic field specific backend
       my $DynamicFieldBackend = 'DynamicField' . $Param{DynamicFieldConfig}->{FieldType} . 'Object';

       if ( !$Self->{$DynamicFieldBackend} ) {
           $Kernel::OM->Get('Kernel::System::Log')->Log(
               Priority => 'error',
               Message  => "Backend $Param{DynamicFieldConfig}->{FieldType} is invalid!",
           );

           return;
       }

       # verify if function is available
       return if !$Self->{$DynamicFieldBackend}->can('Foo');

       # call HasBehavior on the specific backend
       return $Self->{$DynamicFieldBackend}->Foo(%Param);
   }

The function ``Foo()`` is only used for test purposes. First it checks the dynamic field configuration, then it checks if the dynamic field driver (type) exists and was already loaded. To prevent the function call on a driver where is not defined it first check if the driver can execute the function, then executes the function in the driver passing all parameters.

.. note::

   It is also possible to skip the step that tests if the driver can execute the function. To do that it is necessary to implement a mechanism in the front end module to require a special behavior on the dynamic field, and only after call the function in the back end object.


Dynamic Field Driver Extension Example
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Driver extensions will be loaded transparently into the driver itself as a base class. All defined object and properties from the driver will be accessible in the extension.

.. note::

   All new functions implemented in the driver extension should be defined in a back end extension, as every function is called from the back end object.

In this section the ``Foo`` extension for text field driver is shown and explained. The extension only implements the function ``Foo()``.

.. code-block:: Perl

   # --
   # Kernel/System/DynamicField/Driver/FooExtensionText.pm - Extension for DynamicField Text Driver
   # Copyright (C) 2001-2018 OTRS AG, https://otrs.com/
   # --
   # This software comes with ABSOLUTELY NO WARRANTY. For details, see
   # the enclosed file COPYING for license information (GPL). If you
   # did not receive this file, see https://www.gnu.org/licenses/gpl-3.0.txt.
   # --

   package Kernel::System::DynamicField::Driver::FooExtensionText;

   use strict;
   use warnings;

   =head1 NAME

   Kernel::System::DynamicField::Driver::FooExtensionText

   =head1 SYNOPSIS

   DynamicFields Text Driver Extension

   =head1 PUBLIC INTERFACE

   This module extends the public interface of L<Kernel::System::DynamicField::Backend>.
   Please look there for a detailed reference of the functions.

   =over 4

   =cut

This is common header that can be found in common OTRS modules. The class/package name is declared via the ``package`` keyword.

.. code-block:: Perl

   sub Foo {
       my ( $Self, %Param ) = @_;
       return 1;
   }

The function ``Foo()`` has no special logic. It is only for testing and it always returns 1.
