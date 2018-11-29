Writing A New OTRS Frontend Module
==================================

In this chapter, the writing of a new OTRS module is illustrated on the basis of a simple small program. Necessary prerequisite is an OTRS development environment as specified in the chapter of the same name.


What we want to write
---------------------

We want to write a little OTRS module that displays the text 'Hello World' when called up. First of all we must build the directory ``/Hello World`` for the module in the developer directory. In this directory, all directories existent in OTRS can be created. Each module should at least contain the following directories:

::

   Kernel
   Kernel/System
   Kernel/Modules
   Kernel/Output/HTML/Templates/Standard
   Kernel/Config
   Kernel/Config/Files
   Kernel/Config/Files/XML/
   Kernel/Language

Default Config File
-------------------

The creation of a module registration facilitates the display of the new module in OTRS. Therefore we create a file ``/Kernel/Config/Files/XML/HelloWorld.xml``. In this file, we create a new config element. The impact of the various settings is described in the chapter :doc:`../how-it-works/config-mechanism`.

.. code-block:: XML

   <?xml version="1.0" encoding="UTF-8" ?>
   <otrs_config version="2.0" init="Application">
       <Setting Name="Frontend::Module###AgentHelloWorld" Required="1" Valid="1">
           <Description Translatable="1">FrontendModuleRegistration for HelloWorld module.</Description>
           <Navigation>Frontend::Agent::ModuleRegistration</Navigation>
           <Value>
               <Item ValueType="FrontendRegistration">
                   <Hash>
                       <Item Key="Group">
                           <Array>
                               <Item>users</Item>
                           </Array>
                       </Item>
                       <Item Key="GroupRo">
                           <Array>
                           </Array>
                       </Item>
                       <Item Key="Description" Translatable="1">HelloWorld.</Item>
                       <Item Key="Title" Translatable="1">HelloWorld</Item>
                       <Item Key="NavBarName">HelloWorld</Item>
                   </Hash>
               </Item>
           </Value>
       </Setting>
       <Setting Name="Loader::Module::AgentHelloWorld###002-Filename" Required="0" Valid="1">
           <Description Translatable="1">Loader module registration for the agent interface.</Description>
           <Navigation>Frontend::Agent::ModuleRegistration::Loader</Navigation>
           <Value>
               <Hash>
                   <Item Key="CSS">
                       <Array>
                       </Array>
                   </Item>
                   <Item Key="JavaScript">
                       <Array>
                       </Array>
                   </Item>
               </Hash>
           </Value>
       </Setting>
       <Setting Name="Frontend::Navigation###AgentHelloWorld###002-Filename" Required="0" Valid="1">
           <Description Translatable="1">Main menu item registration.</Description>
           <Navigation>Frontend::Agent::ModuleRegistration::MainMenu</Navigation>
           <Value>
               <Array>
                   <DefaultItem ValueType="FrontendNavigation">
                       <Hash>
                       </Hash>
                   </DefaultItem>
                   <Item>
                       <Hash>
                           <Item Key="Group">
                               <Array>
                                   <Item>users</Item>
                               </Array>
                           </Item>
                           <Item Key="GroupRo">
                               <Array>
                               </Array>
                           </Item>
                           <Item Key="Description" Translatable="1">HelloWorld.</Item>
                           <Item Key="Name" Translatable="1">HelloWorld</Item>
                           <Item Key="Link">Action=AgentHelloWorld</Item>
                           <Item Key="LinkOption"></Item>
                           <Item Key="NavBar">HelloWorld</Item>
                           <Item Key="Type">Menu</Item>
                           <Item Key="Block"></Item>
                           <Item Key="AccessKey"></Item>
                           <Item Key="Prio">8400</Item>
                       </Hash>
                   </Item>
               </Array>
           </Value>
       </Setting>
   </otrs_config>


Frontend Module
---------------

After creating the links and executing the system configuration, a new module with the name 'HelloWorld' is displayed. When calling it up, an error message is displayed as OTRS cannot find the matching frontend module yet. This is the next thing to be created. To do so, we create the following file:

.. code-block:: Perl

   # --
   # Kernel/Modules/AgentHelloWorld.pm - frontend module
   # Copyright (C) (year) (name of author) (email of author)
   # --
   # This software comes with ABSOLUTELY NO WARRANTY. For details, see
   # the enclosed file COPYING for license information (GPL). If you
   # did not receive this file, see https://www.gnu.org/licenses/gpl-3.0.txt.
   # --

   package Kernel::Modules::AgentHelloWorld;

   use strict;
   use warnings;

   # Frontend modules are not handled by the ObjectManager.
   our $ObjectManagerDisabled = 1;

   sub new {
       my ( $Type, %Param ) = @_;

       # allocate new hash for object
       my $Self = {%Param};
       bless ($Self, $Type);

       return $Self;
   }

   sub Run {
       my ( $Self, %Param ) = @_;
       my %Data = ();

       my $HelloWorldObject = $Kernel::OM->Get('Kernel::System::HelloWorld');
       my $LayoutObject     = $Kernel::OM->Get('Kernel::Output::HTML::Layout');

       $Data{HelloWorldText} = $HelloWorldObject->GetHelloWorldText();

       # build output
       my $Output = $LayoutObject->Header(Title => "HelloWorld");
       $Output   .= $LayoutObject->NavigationBar();
       $Output   .= $LayoutObject->Output(
           Data         => \%Data,
           TemplateFile => 'AgentHelloWorld',
       );
       $Output   .= $LayoutObject->Footer();

       return $Output;
   }

   1;


Core Module
-----------

Next, we create the file for the core module ``/HelloWorld/Kernel/System/HelloWorld.pm`` with the following content:

.. code-block:: Perl

   # --
   # Kernel/System/HelloWorld.pm - core module
   # Copyright (C) (year) (name of author) (email of author)
   # --
   # This software comes with ABSOLUTELY NO WARRANTY. For details, see
   # the enclosed file COPYING for license information (GPL). If you
   # did not receive this file, see https://www.gnu.org/licenses/gpl-3.0.txt.
   # --

   package Kernel::System::HelloWorld;

   use strict;
   use warnings;

   # list your object dependencies (e.g. Kernel::System::DB) here
   our @ObjectDependencies = (
       # 'Kernel::System::DB',
   );

   =head1 NAME

   HelloWorld - Little "Hello World" module

   =head1 DESCRIPTION

   Little OTRS module that displays the text 'Hello World' when called up.

   =head2 new()

   Create an object. Do not use it directly, instead use:

       my $HelloWorldObject = $Kernel::OM->Get('Kernel::System::HelloWorld');

   =cut

   sub new {
       my ( $Type, %Param ) = @_;

       # allocate new hash for object
       my $Self = {};
       bless ($Self, $Type);

       return $Self;
   }

   =head2 GetHelloWorldText()

   Return the "Hello World" text.

       my $HelloWorldText = $HelloWorldObject->GetHelloWorldText();

   =cut

   sub GetHelloWorldText {
       my ( $Self, %Param ) = @_;

       # Get the DBObject from the central object manager
       # my $DBObject = $Kernel::OM->Get('Kernel::System::DB');

       my $HelloWorld = $Self->_FormatHelloWorldText(
           String => 'Hello World',
       );

       return $HelloWorld;
   }

   =begin Internal:

   =cut

   =head2 _FormatHelloWorldText()

   Format "Hello World" text to uppercase

       my $HelloWorld = $Self->_FormatHelloWorldText(
           String => 'Hello World',
       );

   sub _FormatHelloWorldText{
       my ( $Self, %Param ) = @_;

       my $HelloWorld = uc $Param{String};

       return $HelloWorld;

   }

   =end Internal:

   1;


Template File
-------------

The last thing missing before the new module can run is the relevant HTML template. Thus, we create the following file:

.. code-block:: HTML

   # --
   # Kernel/Output/HTML/Templates/Standard/AgentHelloWorld.tt - overview
   # Copyright (C) (year) (name of author) (email of author)
   # --
   # This software comes with ABSOLUTELY NO WARRANTY. For details, see
   # the enclosed file COPYING for license information (GPL). If you
   # did not receive this file, see https://www.gnu.org/licenses/gpl-3.0.txt.
   # --
   <h1>[% Translate("Overview") | html %]: [% Translate("HelloWorld") %]</h1>
   <p>
       [% Data.HelloWorldText | Translate() | html %]
   </p>

The module is working now and displays the text *Hello World* when called.


Language File
-------------

If the text *Hello World!* is to be translated into for instance German, you can create a translation file for this language in ``HelloWorld/Kernel/Language/de_AgentHelloWorld.pm``. Example:

.. code-block:: Perl

   package Kernel::Language::de_AgentHelloWorld;

   use strict;
   use warnings;

   sub Data {
       my $Self = shift;

       $Self->{Translation}->{'Hello World!'} = 'Hallo Welt!';

       return 1;
   }
   1;


Summary
-------

The example given above shows that it is not too difficult to write a new module for OTRS. It is important, though, to make sure that the module and file name are unique and thus do not interfere with the framework or other expansion modules. When a module is finished, an OPM package must be generated from it (see chapter :doc:`../how-to-publish-otrs-extensions/package-building`).
