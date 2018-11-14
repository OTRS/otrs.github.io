Signatures
==========

Corporate identity and team information are essential in each communication. The name of the employee writing and other vital details like disclaimers are some examples of necessary information to include in the communication with the customer.

OTRS provides you with the same tools here, as with :doc:`salutations`, to create a standardized communication form for any one of your queues. As defined in the :ref:`queue settings`: :doc:`salutations`, :doc:`templates`, and :doc:`signatures` are combined to ensure a well formed standardized email communication.

Signatures can be linked to one or more :doc:`queues`. A signature is used only in email answers to tickets.

Use this screen to add signatures to the system. A fresh OTRS installation already contains a standard signature. The signature management screen is available in the *Signatures* module of the *Ticket Settings* group.

.. figure:: images/signature-management.png
   :alt: Signature Management Screen

   Signature Management Screen


Manage Signatures
-----------------

To add a signature:

1. Click on the *Add Signature* button in the left sidebar.
2. Fill in the required fields.
3. Click on the *Save* button.

.. figure:: images/signature-add.png
   :alt: Add Signature Screen

   Add Signature Screen

.. warning::

   Signatures can not be deleted from the system. They can only be deactivated by setting the *Validity* option to *invalid* or *invalid-temporarily*.

To edit a signature:

1. Click on a signature in the list of signatures.
2. Modify the fields.
3. Click on the *Save* or *Save and finish* button.

.. figure:: images/signature-edit.png
   :alt: Edit Signature Screen

   Edit Signature Screen

.. note::

   If several signatures are added to the system, use the filter box to find a particular signature by just typing the name to filter.

.. warning::

   Before invalidating this object, please go to the *Queues* module of the *Ticket Settings* group and make sure all queues using this setting are using a valid object.


Signature Settings
------------------

The following settings are available when adding or editing this resource. The fields marked with an asterisk are mandatory.

Name \*
   The name of this resource. Any type of characters can be entered to this field including uppercase letters and spaces. The name will be displayed in the overview table.

Signature
   The text that will be placed to the end of new emails.

Validity \*
   Set the validity of this resource. Each resource can be used in OTRS only, if this field is set to *valid*. Setting this field to *invalid* or *invalid-temporarily* will disable the use of the resource.

Comment
   Add additional information to this resource. It is recommended to always fill this field as a description of the resource with a full sentence for better clarity, because the comment will be also displayed in the overview table.


Signature Variables
-------------------

Using variables in signatures is possible. Variables, known as OTRS tags, are replaced by OTRS when generating the mail. Find a list of available tags stems for signatures at the bottom of both add and edit screens.

.. figure:: images/signature-variables.png
   :alt: Signature Variables

   Signature Variables

For example, the variable ``<OTRS_CURRENT_UserFirstname> <OTRS_CURRENT_UserLastname>`` expands to the agent's first and last name allowing a template to include something like the following.

.. code-block:: text

   Best regards,

   <OTRS_CURRENT_UserFirstname> <OTRS_CURRENT_UserLastname>


This tag expands, for example to:

.. code-block:: text

   Best regards,

   Steven Weber
