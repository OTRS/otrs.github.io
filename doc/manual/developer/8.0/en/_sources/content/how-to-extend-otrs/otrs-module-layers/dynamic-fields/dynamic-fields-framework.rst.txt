Dynamic Fields Framework
========================

Before creating new dynamic fields is necessary to understand its framework and how OTRS screens interact with them, as well as their underlying API.

The following picture shows the architecture of the dynamic fields framework.

.. figure:: images/dfframework.png
   :alt: Dynamic Fields Framework

   Dynamic Fields Framework


Dynamic Field Back End Modules
------------------------------


Dynamic Field (Back End)
~~~~~~~~~~~~~~~~~~~~~~~~

Normally called as ``BackendObject`` in the frontend modules is the mediator between the frontend modules and each specific dynamic field implementation or driver. It defines a generic middle API for all dynamic field drivers, and each driver has the responsibility to implement the middle API for the specific needs for the field.

The dynamic field back end is the master controller of all the drivers. Each function in this module is responsible to check the required parameters and call the same function in the specific driver according to the dynamic field configuration parameter received.

This module is also responsible to call specific functions on each object type delegate (like ``Ticket`` or ``Article``) e.g. to add a history entry or fire an event.

This module is located in ``$OTRS_HOME/Kernel/System/DynamicField/Backend.pm``.

.. _dynamic-fields-framework-backends-drivers:


Dynamic Field Drivers
~~~~~~~~~~~~~~~~~~~~~

A dynamic field driver is the implementation of the dynamic field. Each driver must implement all the mandatory functions specified in the back end (there are some functions that depends on a behavior and it is
not needed to implement those if the dynamic field does not have that particular behavior).

A driver is responsible to know how to get its own value or values from a web request, or from a profile (like a search profile). It also needs to know the HTML code to render the field in edit or display screens, or how to interact with the stats module, among other functions.

These modules are located in ``$OTRS_HOME/Kernel/System/DynamicField/Driver/*.pm``.

It exists some base drivers like ``Base.pm``, ``BaseText.pm``, ``BaseSelect.pm`` and ``BaseDateTime.pm``, that implements common functions for certain drivers (e.g. driver ``TextArea.pm`` uses ``BaseText.pm`` that also uses ``Base.pm`` then ``TextArea`` only needs to implement the functions that are missing in ``Base.pm`` and ``BateText.pm`` or the ones that are special cases).

The following is the drivers inheritance tree:

- ``Base.pm``

   - ``BaseText.pm``

      - ``Text.pm``
      - ``TextArea.pm``

   - ``BaseSelect.pm``

      - ``Dropdown.pm``
      - ``Multiselect.pm``

   - ``BaseDateTime.pm``

      - ``DateTime.pm``
      - ``Date.pm``

   - ``Checkbox.pm``


Object Type Delegate
~~~~~~~~~~~~~~~~~~~~

An object type delegate is responsible to perform specific functions on the object linked to the dynamic field. These functions are triggered by the back end object as they are needed.

These modules are located in ``$OTRS_HOME/Kernel/System/DynamicField/ObjectType/*.pm``.


Dynamic Fields Admin Modules
----------------------------

To manage the dynamic fields (add, edit and list) a series of modules has been already developed. There is one specific master module (``AdminDynamicField.pm``) that shows the list of defined dynamic fields, and from within other modules are called to create new dynamic fields or modify an existing ones.

Normally a dynamic field driver needs its own admin module (admin dialog) to define its properties. This dialog might differ from other drivers. But this is not mandatory, drivers can share admin dialogs, if they can provide needed information for all the drivers that are linked to them, no matter if they are from different type. What is mandatory is that each driver must be linked to an admin dialog (e.g. text and textarea drivers share ``AdminDynamicFieldText.pm`` admin dialog, and date and date/time drivers share ``AdminDynamicFieldDateTime.pm`` admin dialog).

Admin dialogs follow the normal OTRS admin module rules and architecture. But for standardization all configuration common parts to all dynamic fields should have the same look and feel among all admin dialogs.

These modules are located in ``$OTRS_HOME/Kernel/Modules/*.pm``.

.. note::

   Each admin dialog needs its corresponding HTML template file (``.tt``).


Dynamic Fields Core Modules
---------------------------

This modules reads and writes the dynamic fields information from and to the database tables.

``DynamicField.pm``
   This module is responsible to manage the dynamic field definitions. It provides the basic API for add, change, delete, list and get dynamic fields. This module is located in ``$OTRS_HOME/Kernel/System/DynamicField.pm``.

``DynamicFieldValue.pm``
   This module is responsible to read and write dynamic field values into the form and into the database. This module is highly used by the drivers and is located in ``$OTRS_HOME/Kernel/System/DynamicFieldValue.pm``.


Dynamic Fields Database Tables
------------------------------

There are two tables in the database to store the dynamic field information:

``dynamic_field``
   Used by the core module ``DynamicField.pm``, it stores the dynamic field definitions.

``dynamic_field_value``
   Used by the core module ``DynamicFieldValue.pm`` to save the dynamic field values for each dynamic field and each object type instance.


Dynamic Fields Configuration Files
----------------------------------

The back end module needs a way to know which drivers exists and since the amount of drivers can be easily extended. The easiest way to manage them is to use the system configuration, where the information of dynamic field drivers and object type drivers can be stored and extended.

The master admin module also needs to know this information about the available dynamic field drivers to use the admin dialog linked with, to create or modify the dynamic fields.

Frontend modules need to read the system configuration to know which dynamic fields are active for each screen and which ones are also mandatory. For example: ``Ticket::Frontend::AgentTicketPhone###DynamicField`` stores the active, mandatory and inactive dynamic fields for *New Phone Ticket* screen.
