Import/Export
=============

Use this screen to create import and export templates. The import/export template management screen is available in the *Import/Export* module of the *Administration* group.

.. figure:: images/import-export-management.png
   :alt: Import/Export Template Management Screen

   Import/Export Template Management Screen


Manage Import/Export Templates
------------------------------

To create a new template:

1. Click on the *Add Template* button in the left sidebar.
2. Fill in the required fields in all steps.
3. Click on the *Finish* button.

.. figure:: images/import-export-add-step1.png
   :alt: Create New Import/Export Template Screen

   Create New Import/Export Template Screen

To edit a template:

1. Click on a template in the list of templates.
2. Modify the fields in all steps.
3. Click on the *Finish* button.

.. figure:: images/import-export-edit.png
   :alt: Edit Import/Export Template Screen

   Edit Import/Export Template Screen

To delete a template:

1. Click on the trash icon in the list of templates.
2. Click on the *Confirm* button.

.. figure:: images/import-export-delete.png
   :alt: Delete Import/Export Template Screen

   Delete Import/Export Template Screen

To import data based on a template:

1. Click on the *Import* link in the list of templates.
2. Click on the *Browse…* button and select a CSV file.
3. Click on the *Start Import* button.

.. figure:: images/import-export-import.png
   :alt: Import Data Screen

   Import Data Screen

To export data based on a template:

1. Click on the *Export* link in the list of templates.
2. Choose a location in your computer to save the ``Export.csv`` file.


Import/Export Template Settings
-------------------------------

The following settings are available when adding this resource. The fields marked with an asterisk are mandatory.

.. note::

   Import/Export package is meant to be independent. This means, that the following settings can be different if no configuration items will be imported or exported.


Edit Common Information
~~~~~~~~~~~~~~~~~~~~~~~

.. figure:: images/import-export-add-step1.png
   :alt: Edit Common Information Screen

   Edit Common Information Screen

Name \*
   The name of this resource. Any type of characters can be entered to this field including uppercase letters and spaces. The name will be displayed in the overview table.

Object \*
   Select the object type you want to import to or export from.

Format \*
   Select the import and export format.

Validity \*
   Set the validity of this resource. Each resource can be used in OTRS only, if this field is set to *valid*. Setting this field to *invalid* or *invalid-temporarily* will disable the use of the resource.

Comment
   Add additional information to this resource. It is recommended to always fill this field as a description of the resource with a full sentence for better clarity.


Edit Object Information
~~~~~~~~~~~~~~~~~~~~~~~

.. figure:: images/import-export-add-step2.png
   :alt: Edit Object Information Screen

   Edit Object Information Screen

Name
   This is a read only field from the previous step. Use the *Back* button to edit it.

Object
   This is a read only field from the previous step. Use the *Back* button to edit it.

Class \*
   Select the class that is needed to be affected by the import and export.

Maximum number of one element \*
   Specify, how many items can have an item.

Empty fields indicate that the current values are kept
   Select this checkbox if the empty field should keep the data in OTRS. Otherwise the data will be overwritten with blank value.


Edit Format Information
~~~~~~~~~~~~~~~~~~~~~~~

.. figure:: images/import-export-add-step3.png
   :alt: Edit Format Information Screen

   Edit Format Information Screen

Name
   This is a read only field from the previous step. Use the *Back* button to edit it.

Format
   This is a read only field from the previous step. Use the *Back* button to edit it.

Column Separator \*
   Select a column separator for CSV file.

Charset
   Select a character encoding for the CSV file.

Include Column Headers
   Specify if column headers should be included or not.


Edit Mapping Information
~~~~~~~~~~~~~~~~~~~~~~~~

.. figure:: images/import-export-add-step4.png
   :alt: Edit Mapping Information Screen

   Edit Mapping Information Screen

Click on the *Add Mapping Element* button to add element from the class. You can also specify if this element is an identifier. The order of the elements is sortable.


Edit Search Information
~~~~~~~~~~~~~~~~~~~~~~~

.. figure:: images/import-export-add-step5.png
   :alt: Edit Search Information Screen

   Edit Search Information Screen

Template Name
   This is a read only field from the previous step. Use the *Back* button to edit it.

Restrict export per search
   You can add search term for each attribute of the selected class to restrict the import and export functions. The possible fields are listed below this field.

.. note::

   The other fields come from the back end driver, and can be different depending on the used object to be imported or exported.
