Dynamic Fields
==============

Beside general information that required for all tickets, organizations have individual needs to add specific details to tickets. This needed information takes various formats like texts, integers, date-time and more.

OTRS supports adding a so-called :term:`dynamic field` to handle texts, integers, dropdown lists, multi-select fields, date-time, checkboxes and more. OTRS administrators can define where those fields should be visible or editable, and of course, the dynamic fields are also available in statistics and reports.

Use this screen to manage dynamic fields in the system. A fresh OTRS installation contains three dynamic fields by default. The dynamic field management screen is available in the *Dynamic Fields* module of the *Processes & Automation* group.

.. figure:: images/dynamic-field-management.png
   :alt: Dynamic Field Management Screen

   Dynamic Field Management Screen


Manage Dynamic Fields
---------------------

To create a new dynamic fields:

1. Choose an object in the left sidebar and select a dynamic field type from its dropdown.
2. Fill in the required fields.
3. Click on the *Save* button.

.. figure:: images/dynamic-field-add.png
   :alt: Create New Dynamic Field Screen

   Create New Dynamic Field Screen

To edit a dynamic field:

1. Click on a dynamic field in the list of dynamic fields.
2. Modify the fields.
3. Click on the *Save* or *Save and finish* button.

.. figure:: images/dynamic-field-edit.png
   :alt: Edit Dynamic Field Screen

   Edit Dynamic Field Screen

To delete a dynamic field:

1. Click on the trash icon in the last column of the overview table.
2. Click on the *Confirm* button.

.. figure:: images/dynamic-field-delete.png
   :alt: Delete Dynamic Field Screen

   Delete Dynamic Field Screen

.. note::

   If several dynamic fields are added to the system, use the filter box to find a particular dynamic field by just typing the name to filter.


Dynamic Field Settings
----------------------

The following settings are available when adding or editing this resource. The fields marked with an asterisk are mandatory.


General Dynamic Field Settings
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

These settings are the same for all types of dynamic fields.

.. figure:: images/dynamic-field-add.png
   :alt: Dynamic Field General Screen

   Dynamic Field General Screen

Name \*
   The name of this resource. Any type of characters can be entered to this field including uppercase letters and spaces. The name will be displayed in the overview table.

Label \*
   This is the name to be shown on the screens where the field is active.

   .. seealso::

      It is possible to add translations for a dynamic field label. Label translations have to be added manually to language translation files.

Field order \*
   This is the order in which this field will be shown on the screens where is active.

Validity \*
   Set the validity of this resource. Each resource can be used in OTRS only, if this field is set to *valid*. Setting this field to *invalid* or *invalid-temporarily* will disable the use of the resource.

Field type
   This type have been selected in the previous page and can not be changed here anymore. This is a read-only field.

Object type
   This type have been selected in the previous page and can not be changed here anymore. This is a read-only field.

   .. note::

      The object type determines where the dynamic field can be used. For example dynamic field with object type *Ticket* can be used only in tickets, and can not be used in articles.

The following settings are relevant only for the particular type of dynamic fields.


Checkbox Dynamic Field Settings
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Checkbox dynamic field is used to store true or false value.

.. figure:: images/dynamic-field-checkbox.png
   :alt: Checkbox Dynamic Field Settings

   Checkbox Dynamic Field Settings

Default value \*
   The default value for the checkbox.

   Checked
      The checkbox is checked by default.

   Unchecked
      The checkbox is unchecked by default.


Contact With Data Dynamic Field Settings
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

This dynamic field allows to add contacts with data to tickets.

.. figure:: images/dynamic-field-contact-with-data.png
   :alt: Contact With Data Dynamic Field Settings

   Contact With Data Dynamic Field Settings

Possible values \*
   These are the possible data attributes for contacts. Clicking on the *⊞* button will add two new fields, where a key (internal value) and a value (displayed value) can be set. With the button you can add multiple key-value pairs.

   .. note::

      The attributes ``Name`` and ``ValidID`` are always mandatory and they are not automatically added, so for each new data source these attributes must be added manually.

      Within the data source definition (or dynamic field configuration) they must be represented by the keys ``Name`` and ``ValidID`` respectively while the values could be *Name* and *Validity* for example.

Mandatory fields
   Comma separated list of mandatory keys.

   .. note::

      Keys *Name* and *ValidID* are always mandatory and doesn't have to be listed here.

Sorted fields
   Comma separated list of keys in sort order. Keys listed here come first, all remaining fields afterwards and sorted alphabetically.

Searchable fields
   Comma separated list of searchable keys.

   .. note::

      Key *Name* is always searchable and doesn't have to be listed here.

Translatable values
   If you activate this option the values will be translated to the user defined language.

   .. note::

      You need to add the translations manually into the language translation files.

Contact with data management
   There is a link *Add/Edit*, that points to *Ticket* → *Edit contact with data* to add some data.

The usage of this type of dynamic field is more complex then the others. An exemplary usage of contacts with data is as follows:

1. Create a new dynamic field of type contact with data.
2. Set the possible contact attributes (possible values). ``Name`` and ``ValidID`` are required for any contact with data dynamic field.

   - Add ``Name`` attribute (key: ``Name``, value: *Name*).
   - Add ``ValidID`` attribute (key: ``ValidID``, value: *Validity*).
   - Add any other attribute such as ``Telephone`` attribute (key: ``Telephone``, value: *Phone*).

3. Add the list of mandatory attribute keys comma separated (``Name`` and ``ValidID`` are not needed).
4. Set the attribute key order list comma separated as: ``Name,Telephone,ValidID``.
5. Add the list of searchable attribute keys comma separated (``Name`` is not needed).
6. Populate the data source by adding at least one contact in the newly created data source by using *Tickets* → *Edit contacts with data* screen from the main navigation bar.
7. Add the new dynamic field to the screen's configuration where it should be shown. For example in *New Phone Ticket* screen by updating the system configuration setting ``Ticket::Frontend::AgentTicketPhone###DynamicField`` and do the same for ``Ticket::Frontend::AgentTicketZoom###DynamicField``.
8. Go to *New Phone Ticket* screen, and notice that the new field is there. Add all ticket needed information.
9. Select an existing contact using autocomplete and choosing a contact.
10. The assigned contact and its attributes will be shown in the *Ticket Zoom* screen.
11. It is possible to update the attributes of the contact by clicking the *Edit contact data button* that appears in the right side of the title of the contact data box (if the current user is a member of the groups defined in system configuration setting ``Frontend::Module###AdminDynamicFieldContactWithData``).
12. If is necessary to change the contact for this ticket, it can be done via any other ticket action where the dynamic field is configured for display.


Date Dynamic Field Settings
~~~~~~~~~~~~~~~~~~~~~~~~~~~

Date dynamic field is used to store a date value.

.. figure:: images/dynamic-field-date.png
   :alt: Date Dynamic Field Settings

   Date Dynamic Field Settings

Default date difference
   The difference from **now** (in seconds) to calculate the field default value (e.g. 3600 or -60).

Define years period
   Activate this feature to define a fixed range of years (in the future and in the past) to be displayed on the year part of the field. If set to *Yes* the following options will be available:

   Years in the past
      Define the number of years in the past from the current day to display in the year selection for this dynamic field in edit screens.

   Years in the future
      Define the number of years in the future from the current day to display in the year selection for this dynamic field in edit screens.

Show link
   Here you can specify an optional HTTP link for the field value in overviews and zoom screens. Example:

   ::

      http://some.example.com/handle?query=[% Data.Field1 | uri %]

Link for preview
   If filled in, this URL will be used for a preview which is shown when this link is hovered in ticket zoom. Please note that for this to work, the regular URL field above needs to be filled in, too.

Restrict entering of dates
   Here you can restrict the entering of dates of tickets.

   Prevent entry of dates in the future
      Selecting this option will prevent entering a date that is after the current date.

   Prevent entry of dates in the past
      Selecting this option will prevent entering a date that is before the current date.


Date / Time Dynamic Field Settings
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Date / time dynamic field is used to store a date time value.

.. figure:: images/dynamic-field-date-time.png
   :alt: Date / Time Dynamic Field Settings

   Date / Time Dynamic Field Settings

The settings for this type of dynamic field is the same as for date dynamic field.


Dropdown Dynamic Field Settings
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Dropdown dynamic field is used to store a single value, from a closed list.

.. figure:: images/dynamic-field-dropdown.png
   :alt: Dropdown Dynamic Field Settings

   Dropdown Dynamic Field Settings

Possible values
   These are the possible data attributes for contacts. Clicking on the *⊞* button will add two new fields, where a key (internal value) and a value (displayed value) can be set. With the button you can add multiple key-value pairs.

Default value
   This is the default value for this field and this will be shown on the edit screens.

Add empty value
   If this option is activated an extra value is defined to show as a *-* in the list of possible values. This special value is empty internally.

Tree View
   Activate this option to display values as a tree.

Translatable values
   If you activate this option the values will be translated to the user defined language.

   .. note::

      You need to add the translations manually into the language translation files.

Show link
   Here you can specify an optional HTTP link for the field value in overviews and zoom screens. Example:

   ::

      http://some.example.com/handle?query=[% Data.Field1 | uri %]

Link for preview
   If filled in, this URL will be used for a preview which is shown when this link is hovered in ticket zoom. Please note that for this to work, the regular URL field above needs to be filled in, too.


Multiselect Dynamic Field Settings
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

.. figure:: images/dynamic-field-multiselect.png
   :alt: Multiselect Dynamic Field Settings

   Multiselect Dynamic Field Settings

Possible values
   These are the possible data attributes for contacts. Clicking on the *⊞* button will add two new fields, where a key (internal value) and a value (displayed value) can be set. With the button you can add multiple key-value pairs.

Default value
   This is the default value for this field and this will be shown on the edit screens.

Add empty value
   If this option is activated an extra value is defined to show as a *-* in the list of possible values. This special value is empty internally.

Tree View
   Activate this option to display values as a tree.

Translatable values
   If you activate this option the values will be translated to the user defined language.

   .. note::

      You need to add the translations manually into the language translation files.


Text Dynamic Field Settings
~~~~~~~~~~~~~~~~~~~~~~~~~~~

Text dynamic field is used to store a single line string.

.. figure:: images/dynamic-field-text.png
   :alt: Text Dynamic Field Settings

   Contact With Data Dynamic Field Settings

Default value
   This is the default value for this field and this will be shown on the edit screens.

Show link
   Here you can specify an optional HTTP link for the field value in overviews and zoom screens. Example:

   ::

      http://some.example.com/handle?query=[% Data.Field1 | uri %]


Link for preview
   If filled in, this URL will be used for a preview which is shown when this link is hovered in ticket zoom. Please note that for this to work, the regular URL field above needs to be filled in, too.

Check RegEx
   Here you can specify a regular expression to check the value. The regex will be executed with the modifiers ``xms``. Example:

   ::

      ^[0-9]$

Add RegEx
   Clicking on the *⊞* button will add two new fields, where a regular expression and an error message can be added.


Textarea Dynamic Field Settings
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Textarea dynamic field is used to store a multiple line string.

.. figure:: images/dynamic-field-textarea.png
   :alt: Textarea Dynamic Field Settings

   Textarea Dynamic Field Settings

Number of rows
   The height (in lines) for this field in the edit mode.

Number of cols
   The width (in characters) for this field in the edit mode.

Default value
   This is the default value for this field and this will be shown on the edit screens.

Check RegEx
   Here you can specify a regular expression to check the value. The regex will be executed with the modifiers ``xms``. Example:

   ::

      ^[0-9]$

Add RegEx
   Clicking on the *⊞* button will add two new fields, where a regular expression and an error message can be added.


Database Dynamic Field
~~~~~~~~~~~~~~~~~~~~~~

.. note::

   To use this type of dynamic field, an **OTRS** service package is needed. Please contact at sales@otrs.com for an upgrade.


Web Service Dynamic Field
~~~~~~~~~~~~~~~~~~~~~~~~~

.. note::

   To use this type of dynamic field, an **OTRS** service package is needed. Please contact at sales@otrs.com for an upgrade.


Display Dynamic Fields on Screens
---------------------------------

To display a dynamic field on a screen:

1. Make sure that the dynamic field *Validity* is set to *valid*.
2. Open the *System Configuration* module in the admin interface.
3. Navigate to *Fromtend* → *Agent* → *View* and select a view to add the dynamic field to.
4. Find the setting ends with ``###DynamicField`` and click on the *Edit this setting* button.
5. Click on the *+* button to add the dynamic field.
6. Enter the name of the dynamic field to the textbox and click on the tick button.
7. Select *1 - Enabled* or *2 - Enabled and required*.
8. Click on the tick button on the right to save the setting.
9. Deploy the modified system configuration.

.. figure:: images/dynamic-field-system-configuration.png
   :alt: Display Dynamic Fields on Screen

   Display Dynamic Fields on Screen

.. note::

   It is possible to add multiple dynamic fields at the same time. To do this, repeat steps 5-7.


Set Default Value via Ticket Event Module
-----------------------------------------

A ticket event (e.g. ``TicketCreate``) can trigger a value set for a certain field, if the field does not have a value yet.

1. Open the *System Configuration* module in the admin interface.
2. Navigate to *Core* → *Event* → *Ticket* and search for the setting ``Ticket::EventModulePost###9600-TicketDynamicFieldDefault``.
3. Click on the *Edit this setting* button to activate the setting.
4. Click on the tick button on the right to save the setting.
5. Deploy the modified system configuration.

.. figure:: images/dynamic-field-ticket-event-module.png
   :alt: Activate Ticket Event Module

   Activate Ticket Event Module

Example: activate *Field1* in ``TicketCreate`` event:

1. Open the *System Configuration* module in the admin interface.
2. Navigate to *Core* → *Ticket* → *DynamicFieldDefault* and search for the setting ``Ticket::TicketDynamicFieldDefault###Element1``.
3. Click on the *Edit this setting* button to activate the setting.
4. Click on the tick button on the right to save the setting.
5. Deploy the modified system configuration.

.. figure:: images/dynamic-field-ticket-dynamic-field-default.png
   :alt: Activate Dynamic Field in Ticket Create Event

   Activate Dynamic Field in Ticket Create Event

.. note::

   This configuration can be set in any of the 16 ``Ticket::TicketDynamicFieldDefault###Element`` settings.

.. seealso::
   If more that 16 fields needs to be set up a custom XML file must be places in ``$OTRS_HOME/Kernel/Config/XML/Files`` directory to extend this feature.


Set Default Value via User Preferences
--------------------------------------

The dynamic field default value can be overwritten with a user defined value stored in the personal preferences.

1. Open the *System Configuration* module in the admin interface.
2. Navigate to *Frontend* → *Agent* → *View* → *Preferences* and search for the setting ``PreferencesGroups###DynamicField``.
3. Click on the *Edit this setting* button to activate the setting.
4. Click on the tick button on the right to save the setting.
5. Deploy the modified system configuration.

.. figure:: images/dynamic-field-preferences-groups.png
   :alt: Activate Dynamic Field in Personal Preferences

   Activate Dynamic Field in Personal Preferences

Click on your avatar on the top left corner, and select *Personal Preferences* → *Miscellaneous* to add a default value for the dynamic field.

.. figure:: images/dynamic-field-personal-preferences.png
   :alt: Dynamic Field in Personal Preferences

   Dynamic Field in Personal Preferences

This setting is an example of how to create an entry in the user preferences screen to set an exclusive dynamic field ``Name_X`` default value for the selected user. The limitation of this setting is that it only permits the use of one dynamic field. If two or more fields will use this feature, it is necessary to create a custom XML configuration file to add more settings similar to this one.

.. note::

   If more settings are added in a new XML each setting name needs to be unique in the system and different than ``PreferencesGroups###DynamicField``. For example:

   - ``PreferencesGroups###101-DynamicField-Field1``
   - ``PreferencesGroups###102-DynamicField-Field2``
   - ``PreferencesGroups###My-Field1``
   - ``PreferencesGroups###My-Field2``
