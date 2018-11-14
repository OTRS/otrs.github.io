Roles
=====

Use this screen to add roles to the system. A fresh OTRS installation contains no roles by default. The role management screen is available in the *Roles* module of the *Users, Groups & Roles* group.

.. figure:: images/role-management.png
   :alt: Role Management Screen

   Role Management Screen


Manage Roles
------------

To add a role:

1. Click on the *Add Role* button in the left sidebar.
2. Fill in the required fields.
3. Click on the *Save* button.

.. figure:: images/role-add.png
   :alt: Add Role Screen

   Add Role Screen

.. warning::

   Roles can not be deleted from the system. They can only be deactivated by setting the *Validity* option to *invalid* or *invalid-temporarily*.

To edit a role:

1. Click on a role in the list of roles.
2. Modify the fields.
3. Click on the *Save* or *Save and finish* button.

.. figure:: images/role-edit.png
   :alt: Edit Role Screen

   Edit Role Screen

.. note::

   If several roles are added to the system, use the filter box to find a particular role by just typing the name to filter.


Role Settings
-------------

The following settings are available when adding or editing this resource. The fields marked with an asterisk are mandatory.

Name \*
   The name of this resource. Any type of characters can be entered to this field including uppercase letters and spaces. The name will be displayed in the overview table.

Validity \*
   Set the validity of this resource. Each resource can be used in OTRS only, if this field is set to *valid*. Setting this field to *invalid* or *invalid-temporarily* will disable the use of the resource.

Comment
   Add additional information to this resource. It is recommended to always fill this field as a description of the resource with a full sentence for better clarity, because the comment will be also displayed in the overview table.
