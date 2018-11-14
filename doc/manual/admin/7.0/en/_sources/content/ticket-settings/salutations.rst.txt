Salutations
===========

Addressing customers must be done in a standardized way. Your customers may not always be external customers requiring a less formal greeting.

OTRS provides you with the tools needed to create a standardized communication form for any one of your queues. As defined in the :ref:`Queue Settings`: :doc:`salutations`, :doc:`templates`, and :doc:`signatures` are combined to ensure a well formed standardized email communication.

Salutations can be linked to one or more :doc:`queues`. A salutation is used only in email answers to tickets.

Use this screen to add salutations to the system. A fresh OTRS installation already contains a standard salutation. The salutation management screen is available in the *Salutations* module of the *Ticket Settings* group.

.. figure:: images/salutation-management.png
   :alt: Salutation Management Screen

   Salutation Management Screen


Manage Salutations
------------------

To add a salutation:

1. Click on the *Add Salutation* button in the left sidebar.
2. Fill in the required fields.
3. Click on the *Save* button.

.. figure:: images/salutation-add.png
   :alt: Add Salutation Screen

   Add Salutation Screen

.. warning::

   Salutations can not be deleted from the system. They can only be deactivated by setting the *Validity* option to *invalid* or *invalid-temporarily*.

To edit a salutation:

1. Click on a salutation in the list of salutations.
2. Modify the fields.
3. Click on the *Save* or *Save and finish* button.

.. figure:: images/salutation-edit.png
   :alt: Edit Salutation Screen

   Edit Salutation Screen

.. note::

   If several salutations are added to the system, use the filter box to find a particular salutation by just typing the name to filter.

.. warning::

   Before invalidating this object, please go to the *Queues* module of the *Ticket Settings* group and make sure all queues using this setting are using a valid object.


Salutation Settings
-------------------

The following settings are available when adding or editing this resource. The fields marked with an asterisk are mandatory.

Name \*
   The name of this resource. Any type of characters can be entered to this field including uppercase letters and spaces. The name will be displayed in the overview table.

Salutation
   The text that will be placed to the beginning of new emails.

Validity \*
   Set the validity of this resource. Each resource can be used in OTRS only, if this field is set to *valid*. Setting this field to *invalid* or *invalid-temporarily* will disable the use of the resource.

Comment
   Add additional information to this resource. It is recommended to always fill this field as a description of the resource with a full sentence for better clarity, because the comment will be also displayed in the overview table.


Salutation Variables
--------------------

Using variables in salutations is possible. Variables, known as OTRS tags, are replaced by OTRS when generating the mail. Find a list of available tags stems for salutations at the bottom of both add and edit screens.

.. figure:: images/salutation-variables.png
   :alt: Salutation Variables

   Salutation Variables

For example, the variable ``<OTRS_CUSTOMER_DATA_UserLastname>`` expands to the customer's last name to be included in something like the following.

.. code-block:: text

   Dear <OTRS_CUSTOMER_DATA_UserFirstname> <OTRS_CUSTOMER_DATA_UserLastname>,

This tag expands, for example to:

.. code-block:: text

   Dear Lisa Wagner,
