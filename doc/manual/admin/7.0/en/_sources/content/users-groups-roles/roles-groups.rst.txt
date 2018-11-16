Roles ↔ Groups
==============

Use this screen to add one or more roles to one or more groups. To use this function, at least one role and one group need to have been added to the system. The management screen is available in the *Roles ↔ Groups* module of the *Users, Groups & Roles* group.

.. figure:: images/role-group-management.png
   :alt: Manage Roles-Groups Relations

   Manage Roles-Groups Relations


Manage Roles ↔ Groups Relations
-------------------------------

To assign some groups to a role:

1. Click on a role in the *Roles* column.
2. Select the permissions you would like to connect the role to groups with.
3. Click on the *Save* or *Save and finish* button.

.. figure:: images/role-group-role.png
   :alt: Change Group Relations for Role

   Change Group Relations for Role

To assign some roles to a group:

1. Click on a group in the *Groups* column.
2. Select the permissions you would like to connect the group to roles with.
3. Click on the *Save* or *Save and finish* button.

.. figure:: images/role-group-group.png
   :alt: Change Role Relations for Group

   Change Role Relations for Group

.. note::

   If several roles or groups are added to the system, use the filter box to find a particular role or group by just typing the name to filter.

Multiple roles or groups can be assigned in both screens at the same time. Additionally clicking on a role or clicking on a group will open the edit role screen or the edit group screen for the selected resource.


Roles ↔ Groups Relations Reference
----------------------------------

When assigning a role to a group or vice versa, several permissions can be set as connection between a role and a group. The following permissions are available by default:

ro
   Read only access to the ticket in this group/queue.

move_into
   Permissions to move tickets into this group/queue.

create
   Permissions to create tickets in this group/queue.

note
   Permissions to add notes to tickets in this group/queue.

owner
   Permissions to change the owner of tickets in this group/queue.

priority
   Permissions to change the ticket priority in this group/queue.

chat_observer
   Users with this permission type will only be able to observe chats in a channel after they have been invited.

chat_participant
   Users with this permission type will be able to take part in a chat, but only after they get invited to it.

chat_owner
   Users with this permission type will be able to accept chat customer/public requests and do all kinds of observer and participant actions on a chat.

rw
   Full read and write access to the tickets in this group/queue.

.. seealso::

   Not all available permissions are shown by default. See :sysconfig:`System::Permission <core.html#system-permission>` setting for permissions that can be added. These additional permissions can be added:

   stats
      Gives access to the stats page.

   bounce
      Permissions to bounce an email message (with bounce button in *Ticket Zoom* screen).

   compose
      Permissions to compose an answer for a ticket.

   customer
      Permissions to change the customer of a ticket.

   forward
      Permissions to forward a messages (with the forward button).

   pending
      Permissions to set a ticket to pending.

   phone
      Permissions to add a phone call to a ticket.

   responsible
      Permissions to change the responsible agent for a ticket.

.. note::

   By setting a checkbox in the header of a column will set all the checkboxes in the selected column. By setting the checkbox in the last *rw* column will set all the checkboxes in the selected row.
