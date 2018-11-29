Config Mechanism
================

OTRS comes with a dedicated mechanism to manage configuration options via a graphical interface (system configuration). This section describes how it works internally and how you can provide new configuration
options or change existing default values.


``Defaults.pm``: OTRS Default Configuration
-------------------------------------------

The default configuration file of OTRS is ``Kernel/Config/Defaults.pm``. This file is needed for operation of freshly installed systems without a deployed XML configuration and should be left untouched as it is automatically updated on framework updates.


Automatically Generated Configuration Files
-------------------------------------------

In ``Kernel/Config/Files`` you can find some automatically generated configuration files:

``ZZZAAuto.pm``
   Perl cache of the XML configuration's current values (default or modified by user).

``ZZZACL.pm``
   Perl cache of ACL configuration from database.

``ZZZProcessManagement.pm``
   Perl cache of process management configuration from database.

These files are a Perl representation of the current system configuration. They should never be manually changed as they are overwritten by OTRS.


XML Configuration Files
-----------------------

In OTRS, configuration options that the administrator can configure via system configuration are provided via XML files with a special format. To convert old XML's you can use the following command:

.. code-block:: Bash

   otrs> /opt/otrs/bin/otrs.Console.pl Dev::Tools::Migrate::ConfigXMLStructure

The file ``Kernel/Config/Files/ZZZAAuto.pm`` is a cached Perl version of the XML that contains all settings with their current value. It can be (re-)generated with:

.. code-block:: Bash

   otrs> /opt/otrs/bin/otrs.Console.pl Maint::Config::Rebuild

Each XML config file has the following layout:

.. code-block:: XML

   <?xml version="1.0" encoding="utf-8" ?>
   <otrs_config version="2.0" init="Changes">

       <!--  settings will be here -->

   </otrs_config>
               

``init``
   The global ``init`` attribute describes where the config options should be loaded. There are different levels available and will be loaded/overloaded in the following order:

   - ``Framework`` (for framework settings e. g. session option)
   - ``Application`` (for application settings e. g. ticket options)
   - ``Config`` (for extensions to existing applications e. g. ITSM options)
   - ``Changes`` (for custom development e. g. to overwrite framework or ticket options).

The configuration items are written as ``Setting`` elements with a ``Description``, a ``Navigation`` group (for the tree-based navigation in the GUI) and the ``Value`` that it represents. Here's an example:

.. code-block:: XML

   <Setting Name="Ticket::Hook" Required="1" Valid="1">
       <Description Translatable="1">The identifier for a ticket, e.g. Ticket#, Call#, MyTicket#. The default is Ticket#.</Description>
       <Navigation>Core::Ticket</Navigation>
       <Value>
           <Item ValueType="String" ValueRegex="">Ticket#</Item>
       </Value>
   </Setting>
               

``Required``
   If this is set to 1, the configuration setting cannot be disabled.

``Valid``
   Determines if the config setting is active (1) or inactive (0) by default.

``ConfigLevel``
   If the optional attribute ``ConfigLevel`` is set, the config variable might not be edited by the administrator, depending on his own config level. The config variable ``ConfigLevel`` sets the level of
   technical experience of the administrator. It can be *100 (Expert)*, *200 (Advanced)* or *300 (Beginner)*. As a guideline which config level should be given to an option, it is recommended that all options having to do with the configuration of external interaction, like Sendmail, LDAP, SOAP, and others should get a config level of at least *200 (Advanced)*.

``Invisible``
   If set to 1, the config setting is not shown in the GUI.

``Readonly``
   If set to 1, the config setting cannot be changed in the GUI.

``UserModificationPossible``
   If ``UserModificationPossible`` is set to ``1``, administrators can enable user modifications of this setting (in user preferences).

``UserModificationActive``
   If ``UserModificationActive`` is set to ``1``, user modifications of this setting is enabled (in user preferences). You should use this attribute together with ``UserModificationPossible``.

``UserPreferencesGroup``
   Use ``UserPreferencesGroup`` attribute to define under which group config variable belongs (in the ``UserPreferences`` screen). You should use this attribute together with ``UserModificationPossible``.

Guidelines for placing settings in the right navigation nodes:

- Only create new nodes if neccessary. Avoid nodes with only very few settings if possible. 
- On the first tree level, no new nodes should be added.
- Don't place new settings in ``Core`` directly. This is reserved for a few important global settings.
- ``Core::*`` can take new groups that contain settings that cover the same topic (like ``Core::Email``) or relate to the same entity (like ``Core::Queue``).
- All event handler registrations go to ``Core::Event``.
- Don't add new direct child nodes within ``Frontend``. Global front end settings go to ``Frontend::Base``, settings only affecting a part of the system go to the respective ``Admin``, ``Agent``, ``Customer`` or ``Public`` sub nodes.
- Front end settings that only affect one screen should go to the relevant screen (``View``) node (create one if needed), for example ``AgentTicketZoom`` related settings go to ``Frontend::Agent::View::TicketZoom``. If there are module layers within one screen with groups of related settings, they would also go to a sub group here (e. g. ``Frontend::Agent::View::TicketZoom::MenuModule`` for all ticket zoom menu module registrations).
- All global loader settings go to ``Frontend::Base::Loader``, screen specific loader settings to ``Frontend::*::ModuleRegistration::Loader``.


Structure of ``Value`` elements
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

``Value`` elements hold the actual configuration data payload. They can
contain single values, hashes or arrays.


``Item``
^^^^^^^^

An ``Item`` element holds one piece of data. The optional ``ValueType`` attribute determines which kind of data and how it needs to be presented to the user in the GUI. If no ``ValueType`` is specified, it defaults to ``String``.

Please see :ref:`Value Types` for a definition of the different value types.

.. code-block:: XML

   <Setting Name="Ticket::Hook" Required="1" Valid="1">
       <Description Translatable="1">The identifier for a ticket, e.g. Ticket#, Call#, MyTicket#. The default is Ticket#.</Description>
       <Navigation>Core::Ticket</Navigation>
       <Value>
           <Item ValueType="String" ValueRegex="">Ticket#</Item>
       </Value>
   </Setting>


``Array``
^^^^^^^^^

With this config element arrays can be displayed.

.. code-block:: XML

   <Setting Name="SettingName">
       ...
       <Value>
           <Array>
               <Item Translatable="1">Value 1</Item>
               <Item Translatable="1">Value 2</Item>
               ...
           </Array>
       </Value>
   </Setting>
                       

``Hash``
^^^^^^^^

With this config element hashes can be displayed.

.. code-block:: XML

   <Setting Name="SettingName">
       ...
       <Value>
           <Hash>
               <Item Key="One" Translatable="1">First</Item>
               <Item Key="Two" Translatable="1">Second</Item>
               ...
           </Hash>
       </Value>
   </Setting>
                       

It's possible to have nested array/hash elements (like hash of arrays, array of hashes, array of hashes of arrays, etc.). Below is an example array of hashes.

.. code-block:: XML

   <Setting Name="ExampleAoH">
       ...
       <Value>
           <Array>
               <DefaultItem>
                   <Hash>
                       <Item></Item>
                   </Hash>
               </DefaultItem>
               <Item>
                   <Hash>
                       <Item Key="One">1</Item>
                       <Item Key="Two">2</Item>
                   </Hash>
               </Item>
               <Item>
                   <Hash>
                       <Item Key="Three">3</Item>
                       <Item Key="Four">4</Item>
                   </Hash>
               </Item>
           </Array>
       </Value>
   </Setting>


Value Types
~~~~~~~~~~~

The XML config settings support various types of configuration variables.


String
^^^^^^

.. code-block:: XML

   <Setting Name="SettingName">
       ...
       <Value>
           <Item ValueType="String" ValueRegex=""></Item>
       </Value>
   </Setting>
                       

A config element for numbers and single-line strings. Checking the validity with a regular expression is possible (optional). This is the default ``ValueType``.

.. code-block:: XML

   <Setting Name="SettingName">
       ...
       <Value>
           <Item ValueType="String" ValueRegex="" Translatable="1">Value</Item>
       </Value>
   </Setting>
                       

The optional ``Translatable`` attribute marks this setting as translatable, which will cause it to be included in the OTRS translation files. This attribute can be placed on any tag (see also below).


Password
^^^^^^^^

A config element for passwords. It's still stored as plain text in the XML, but it's masked in the GUI.

.. code-block:: XML

   <Setting Name="SettingName">
       ...
       <Value>
           <Item ValueType="Password">Secret</Item>
       </Value>
   </Setting>


PerlModule
^^^^^^^^^^

A config element for Perl module. It has a ``ValueFilter`` attribute, which filters possible values for selection. In the example below, user can select Perl module ``Kernel::System::Log::SysLog`` or ``Kernel::System::Log::File``.

.. code-block:: XML

   <Setting Name="SettingName">
       ...
       <Value>
           <Item ValueType="PerlModule" ValueFilter="Kernel/System/Log/*.pm">Kernel::System::Log::SysLog</Item>
       </Value>
   </Setting>


Textarea
^^^^^^^^

A config element for multiline text.

.. code-block:: XML

   <Setting Name="SettingName">
       ...
       <Value>
           <Item ValueType="Textarea"></Item>
       </Value>
   </Setting>


Select
^^^^^^

This config element offers preset values as a pull-down menu. The ``SelectedID`` or ``SelectedValue`` attributes can pre-select a default value.

.. code-block:: XML

   <Setting Name="SettingName">
       ...
       <Value>
           <Item ValueType="Select" SelectedID="Queue">
               <Item ValueType="Option" Value="Queue" Translatable="1">Queue</Item>
               <Item ValueType="Option" Value="SystemAddress" Translatable="1">System address</Item>
           </Item>
       </Value>
   </Setting>


Checkbox
^^^^^^^^

This config element checkbox has two states: 0 or 1.

.. code-block:: XML

   <Setting Name="SettingName">
       ...
       <Value>
           <Item ValueType="Checkbox">0</Item>
       </Value>
   </Setting>


Date
^^^^

This config element contains a date value.

.. code-block:: XML

   <Setting Name="SettingName">
       ...
       <Value>
           <Item ValueType="Date">2016-02-02</Item>
       </Value>
   </Setting>


DateTime
^^^^^^^^

This config element contains a date and time value.

.. code-block:: XML

   <Setting Name="SettingName">
       ...
       <Value>
           <Item ValueType="DateTime">2016-12-08 01:02:03</Item>
       </Value>
   </Setting>


Directory
^^^^^^^^^

This config element contains a directory.

.. code-block:: XML

   <Setting Name="SettingName">
       ...
       <Value>
           <Item ValueType="Directory">/etc</Item>
       </Value>
   </Setting>


File
^^^^

This config element contains a file path.

.. code-block:: XML

   <Setting Name="SettingName">
       ...
       <Value>
           <Item ValueType="File">/etc/hosts</Item>
       </Value>
   </Setting>


Entity
^^^^^^

This config element contains a value of a particular entity. ``ValueEntityType`` attribute defines the entity type. Supported entities: ``DynamicField``, ``Queue``, ``Priority``, ``State`` and ``Type``. Consistency checks will ensure that only valid entities can be configured and that entities used in the configuration cannot be set to invalid. Also, when an entity is renamed, all referencing config settings will be updated.

.. code-block:: XML

   <Setting Name="SettingName">
       ...
       <Value>
           <Item ValueType="Entity" ValueEntityType="Queue">Junk</Item>
       </Value>
   </Setting>


TimeZone
^^^^^^^^

This config element contains a time zone value.

.. code-block:: XML

   <Setting Name="SettingName">
       ...
       <Value>
           <Item ValueType="TimeZone">UTC</Item>
       </Value>
   </Setting>


VacationDays
^^^^^^^^^^^^

This config element contains definitions for vacation days which are repeating each year. Following attributes are mandatory: ``ValueMonth``, ``ValueDay``.

.. code-block:: XML

   <Setting Name="SettingName">
       ...
       <Value>
           <Item ValueType="VacationDays">
               <DefaultItem ValueType="VacationDays"></DefaultItem>
               <Item ValueMonth="1" ValueDay="1" Translatable="1">New Year's Day</Item>
               <Item ValueMonth="5" ValueDay="1" Translatable="1">International Workers' Day</Item>
               <Item ValueMonth="12" ValueDay="24" Translatable="1">Christmas Eve</Item>
           </Item>
       </Value>
   </Setting>


VacationDaysOneTime
^^^^^^^^^^^^^^^^^^^

This config element contains definitions for vacation days which occur only once. Following attributes are mandatory: ``ValueMonth``, ``ValueDay`` and ``ValueYear``.

.. code-block:: XML

   <Setting Name="SettingName">
       ...
       <Value>
           <Item ValueType="VacationDaysOneTime">
               <Item ValueYear="2004" ValueMonth="1" ValueDay="1">test</Item>
           </Item>
       </Value>
   </Setting>


WorkingHours
^^^^^^^^^^^^

This config element contains definitions for working hours.

.. code-block:: XML

   <Setting Name="SettingName">
       ...
       <Value>
           <Item ValueType="WorkingHours">
               <Item ValueType="Day" ValueName="Mon">
                   <Item ValueType="Hour">8</Item>
                   <Item ValueType="Hour">9</Item>
               </Item>
               <Item ValueType="Day" ValueName="Tue">
                   <Item ValueType="Hour">8</Item>
                   <Item ValueType="Hour">9</Item>
               </Item>
           </Item>
       </Value>
   </Setting>


Frontend Registration
^^^^^^^^^^^^^^^^^^^^^

Module registration for agent interface:

.. code-block:: XML

   <Setting Name="SettiFrontend::Module###AgentModuleName">
       ...
       <Value>
           <Item ValueType="FrontendRegistration">
               <Hash>
                   <Item Key="Group">
                       <Array>
                       </Array>
                   </Item>
                   <Item Key="GroupRo">
                       <Array>
                       </Array>
                   </Item>
                   <Item Key="Description" Translatable="1">Phone Call.</Item>
                   <Item Key="Title" Translatable="1">Phone-Ticket</Item>
                   <Item Key="NavBarName">Ticket</Item>
               </Hash>
           </Item>
       </Value>
   </Setting>


DefaultItem in Array and Hash
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

The new XML structure allows us to create complex structures. Therefore we need ``DefaultItem`` entries to describe the structure of the array/hash. If it's not provided, system considers that you want simple array/hash with scalar values. ``DefaultItem`` is used as a template when adding new elements, so it can contain additional attributes, like ``ValueType``, and it can define default values.

Here are few examples:


Array of Array with Select items
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. code-block:: XML

   <Array>
       <DefaultItem>
           <Array>
               <DefaultItem ValueType="Select" SelectedID='option-2'>
                   <Item ValueType="Option" Value="option-1">Option 1</Item>
                   <Item ValueType="Option" Value="option-2">Option 2</Item>
               </DefaultItem>
           </Array>
       </DefaultItem>
       ...
   </Array>


Hash of Hash with Date items
^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. code-block:: XML

   <Hash>
       <DefaultItem>
           <Hash>
               <DefaultItem ValueType="Date">2017-01-01</DefaultItem>
           </Hash>
       </DefaultItem>
       ...
   </Hash>


Accessing Config Options at Runtime
-----------------------------------

You can read and write (for one request) the config options via the core module ``Kernel::Config``.

If you want to read a config option:

.. code-block:: Perl

   my $ConfigOption = $Kernel::OM->Get('Kernel::Config')->Get('Prefix::Option');
               

If you want to change a config option at runtime and just for this one request/process:

.. code-block:: Perl

   $Kernel::OM->Get('Kernel::Config')->Set(
       Key => 'Prefix::Option'
       Value => 'SomeNewValue',
   );
               
