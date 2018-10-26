Priorities
==========

Sometimes tickets are not equally created. One ticket may need more focus than another. A customer may be given a higher priority by the service desk to help raise customer satisfaction in a pinch or to ensure that a long-running request receives special attention. Keeping track of these higher priority requests is important, as well as handling them quickly.

OTRS provides a traffic light system based per default five levels of priorities to handle this task.

Blue
   Very low
Green
   Low
Grey
   Normal
Orange
   High
Red
   Very high

The colors are based on the ID (very low being ID 1) in the database. Changing the names should be done with this in mind. New priorities have the color gray.

Use this screen to add priorities to the system. A fresh OTRS installation contains five default priority levels. The priority management screen is available in the *Priorities* module of the *Ticket Settings* group.

.. figure:: images/priority-management.png
   :alt: Priority Management Screen

   Priority Management Screen


Manage Priorities
-----------------

.. note::

   When creating a customized list of priorities, please keep in mind that they are sorted alphabetically in the priority selection box in the user interface.

To add a priority:

1. Click on the *Add Priority* button in the left sidebar.
2. Fill in the required fields.
3. Click on the *Save* button.

.. figure:: images/priority-add.png
   :alt: Add Priority Screen

   Add Priority Screen

.. warning::

   Priorities can not be deleted from the system. They can only be deactivated by setting the *Validity* option to *invalid* or *invalid-temporarily*.

.. note::

   It's recommended to limit your system to 5 priorities or less and reuse the current 5 to keep the use of the traffic light system.

To edit a priority:

1. Click on a priority in the list of priorities.
2. Modify the fields.
3. Click on the *Save* or *Save and finish* button.

.. figure:: images/priority-edit.png
   :alt: Edit Priority Screen

   Edit Priority Screen

.. note::

   If several priorities are added to the system, use the filter box to find a particular priority by just typing the name to filter.

If you change the name of a priority which is used in the system configuration, a validation check will warn you and give you the option to apply your changes now by clicking on *Save and update automatically*, manually make the changes your self by choosing another default later by clicking on *Don't save, update manually* or canceling the action by clicking on *Cancel*.

.. figure:: images/priority-system-config-validation.png
   :alt: System Priority Validation Check

   System Priority Validation Check

.. warning::

   Changing the name of this object should be done with care, the check only provides verification for certain settings and ignores things where the name can't be verified. Some examples are dashboard filters, action control lists (ACLs), and processes (sequence flow actions) to name a few. Documentation of your setup is key to surviving a name change.


Priority Settings
-----------------

The following settings are available when adding or editing this resource. The fields marked with an asterisk are mandatory.

Name \*
   The name of this resource. Any type of characters can be entered to this field including uppercase letters and spaces. The name will be displayed in the overview table.

Validity \*
   Set the validity of this resource. Each resource can be used in OTRS only, if this field is set to *valid*. Setting this field to *invalid* or *invalid-temporarily* will disable the use of the resource.
