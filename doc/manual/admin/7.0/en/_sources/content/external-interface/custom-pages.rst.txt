Custom Pages
============

Use this screen to add custom pages for use in external interface. A fresh OTRS installation already contains some custom pages by default. The custom page management screen is available in the *Custom Pages* module of the *External Interface* group.

.. figure:: images/custom-page-management.png
   :alt: Custom Page Management Screen

   Custom Page Management Screen


Manage Custom Pages
-------------------

.. warning::

   Make sure to save your changes when you finish. The new configuration will be immediately deployed.

To add a custom page:

1. Click on the *Add Custom Page* button in the left sidebar.
2. Fill in the required fields.
3. Click on the *Save* button.

.. figure:: images/custom-page-add.png
   :alt: Add Custom Page Screen

   Add Custom Page Screen

To edit a custom page:

1. Click on a custom page in the list of custom pages.
2. Modify the fields.
3. Click on the *Save* or *Save and finish* button.

.. figure:: images/custom-page-edit.png
   :alt: Edit Custom Page Screen

   Edit Custom Page Screen

To delete a custom page:

1. Click on the trash icon in the fourth column of the overview table.
2. Click on the *Confirm* button.

.. figure:: images/custom-page-delete.png
   :alt: Delete Custom Page Screen

   Delete Custom Page Screen

.. note::

   If several custom pages are added to the system, use the filter box to find a particular custom page by just typing the name to filter.


Custom Page Settings
--------------------

The following settings are available when adding or editing this resource. The fields marked with an asterisk are mandatory.

Internal Title \*
   The name of this resource, that are only displayed in the admin interface. Any type of characters can be entered to this field including uppercase letters and spaces. The name will be displayed in the overview table.

Slug \*
   This will be the URL of the custom page. Recommended characters are lowercase letters, numbers and minus sign.

Validity \*
   Set the validity of this resource. Each resource can be used in OTRS only, if this field is set to *valid*. Setting this field to *invalid* or *invalid-temporarily* will disable the use of the resource.

Custom Page Content
   In this widget can be added some localized content for the item.

   Title \*
      The name of this resource in the given language. Any type of characters can be entered to this field including uppercase letters and spaces.

   Content \*
      The text for this item in the given language.

   Add new custom page content
      Select which languages should be added to create localized item content. All added languages can hold its own localized content, that are explained above.
