General Catalog
===============

Use this screen to add catalog classes and items to the system. If only this package is installed to the system without any OTRS::ITSM packages, then the general catalog contains no entries. Install other OTRS::ITSM packages (e.g. :doc:`../../../itsm-core`) to add some classes and items to the catalog. The general catalog management screen is available in the *General Catalog* module of the *Administration* group.

.. figure:: images/general-catalog-management.png
   :alt: General Catalog Management Screen

   General Catalog Management Screen


Manage General Catalog
----------------------

To add a catalog class:

1. Click on the *Add Catalog Class* button in the left sidebar.
2. Fill in the required fields.
3. Click on the *Save* button.

.. figure:: images/general-catalog-class-add.png
   :alt: Add Catalog Class Screen

   Add Catalog Class Screen

.. warning::

   Catalog classes can not be deleted from the system. They can only be deactivated by setting the *Validity* option to *invalid* or *invalid-temporarily*.

To add a catalog item:

1. Select a catalog class in the list of catalog classes and click on it.
2. Click on the *Add Catalog Item* button in the left sidebar.
3. Fill in the required fields.
4. Click on the *Save* button.

.. figure:: images/general-catalog-item-add.png
   :alt: Add Catalog Item Screen

   Add Catalog Item Screen

.. warning::

   Catalog items can not be deleted from the system. They can only be deactivated by setting the *Validity* option to *invalid* or *invalid-temporarily*.

To edit a catalog item:

1. Select a catalog class in the list of catalog classes and click on it.
2. Select a catalog item in the list of catalog items and click on it.
3. Modify the fields.
4. Click on the *Save* or *Save and finish* button.

.. figure:: images/general-catalog-item-edit.png
   :alt: Edit Catalog Item Screen

   Edit Catalog Item Screen


Catalog Class Settings
----------------------

The following settings are available when adding this resource. The fields marked with an asterisk are mandatory.

Catalog Class \*
   The name of the catalog class. The catalog class will be displayed in the overview table of catalog classes.

Name \*
   The name of the catalog item to be added to the class. Any type of characters can be entered to this field including uppercase letters and spaces. The name will be displayed in the overview table of catalog items.

Validity \*
   Set the validity of this resource. Each resource can be used in OTRS only, if this field is set to *valid*. Setting this field to *invalid* or *invalid-temporarily* will disable the use of the resource.

Comment
   Add additional information to this resource. It is recommended to always fill this field as a description of the resource with a full sentence for better clarity.


Catalog Item Settings
---------------------

The following settings are available when adding this resource. The fields marked with an asterisk are mandatory.

Catalog Class
   The name of the catalog class. This is read only in this screen.

Name \*
   The name of the catalog item to be added to the class. Any type of characters can be entered to this field including uppercase letters and spaces. The name will be displayed in the overview table of catalog items.

Validity \*
   Set the validity of this resource. Each resource can be used in OTRS only, if this field is set to *valid*. Setting this field to *invalid* or *invalid-temporarily* will disable the use of the resource.

Comment
   Add additional information to this resource. It is recommended to always fill this field as a description of the resource with a full sentence for better clarity.
