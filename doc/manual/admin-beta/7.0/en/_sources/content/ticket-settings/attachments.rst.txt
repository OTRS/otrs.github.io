Attachments
===========

For any size of organization it is often required to send a service agreement, the terms of service or a privacy statement out when a customer signs a contract.

OTRS can handle an infinite number of attachments (PDF, image, etc.) and can bundle them into templates. Your agents don’t need to maintain the attachments on their own, nor don’t they need to upload them again and again - they can just use the predefined templates.

Use this screen to add attachments for use in templates. A fresh OTRS installation doesn't contain any attachments by default. The attachment management screen is available in the *Attachments* module of the *Ticket Settings* group.

.. figure:: images/attachment-management.png
   :alt: Attachment Management Screen

   Attachment Management Screen


Manage Attachments
------------------

To add an attachment:

1. Click on the *Add Attachments* button in the left sidebar.
2. Fill in the required fields.
3. Click on the *Save* button.

.. figure:: images/attachment-add.png
   :alt: Add Attachment Screen

   Add Attachment Screen

To edit an attachment:

1. Click on an attachment in the list of attachments.
2. Modify the fields.
3. Click on the *Save* or *Save and finish* button.

.. figure:: images/attachment-edit.png
   :alt: Edit Attachment Screen

   Edit Attachment Screen

To delete an attachment:

1. Click on the trash icon in the last column of the overview table.
2. Click on the *Confirm* button.

.. figure:: images/attachment-delete.png
   :alt: Delete Attachment Screen

   Delete Attachment Screen

.. note::

   If several attachments are added to the system, use the filter box to find a particular attachment by just typing the name to filter.


Attachment Settings
-------------------

The following settings are available when adding or editing this resource. The fields marked with an asterisk are mandatory.

Name \*
   The name of this resource. Any type of characters can be entered to this field including uppercase letters and spaces. The name will be displayed in the overview table.

Attachment \*
   Open the file dialog to add a file from the file system. This field is mandatory in the attachment add screen, but optional in the attachment edit screen. Adding a new file in the edit screen will overwrite the existing attachment.

Validity \*
   Set the validity of this resource. Each resource can be used in OTRS only, if this field is set to *valid*. Setting this field to *invalid* or *invalid-temporarily* will disable the use of the resource.

Comment
   Add additional information to this resource. It is recommended to always fill this field as a description of the resource with a full sentence for better clarity, because the comment will be also displayed in the overview table.

