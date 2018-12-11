Groups
======

Access to the change management module is managed on a role-based access concept. After installation of the package some new groups are added to the system. The group management screen is available in the *Groups* module of the *Users, Groups & Roles* group.

.. figure:: images/group-management.png
   :alt: Group Management Screen

   Group Management Screen


New Groups
----------

After installation of the package the following groups are added to the system:

*itsm-change*
   Members of this group have access to the change management module. All potential work order agents should be assigned to this group. All changes and work orders can be viewed by these users.

*itsm-change-builder*
   Members of this group can create new changes and work orders in the system. All changes and work orders can be viewed by this group. Changes and work orders created by the change builder, or that have been defined as accessible to the change builder, may be edited by these users.

*itsm-change-manager*
   Members of this group can create new changes and work orders in the system. All changes and work orders can be viewed by this group. These users can edit all changes and work orders.

.. note::

   The primary administrator user (root@localhost) is added to all groups with permission *rw* by default.

.. seealso::

   To set the correct permissions for other users, check the following relations:

   - *Agents ↔ Groups*
   - *Customers ↔ Groups*
   - *Customer Users ↔ Groups*
   - *Roles ↔ Groups*
