Agents ↔ Groups
===============

Efficient and straightforward management of permissions is essential in a growing business. Easy assignment of a particular user to a group for quick access, or to remove access, to resources is a must in every case.

The OTRS interface provides you with both the possibility to manage an agent's access to one or more particular groups. As well, you can change multiple users access to any one group, efficiently and elegantly.

Use this screen to add one or more agents to one or more groups. To use this function, at least one agent and one group need to have been added to the system. The management screen is available in the *Agents ↔ Groups* module of the *Users, Groups & Roles* group.

.. figure:: images/agent-group-management.png
   :alt: Manage Agent-Group Relations

   Manage Agent-Group Relations


Manage Agents ↔ Groups Relations
--------------------------------

To assign some groups to an agent:

1. Click on an agent in the *Agents* column.
2. Select the permissions you would like to connect the agent to groups with.
3. Click on the *Save* or *Save and finish* button.

.. figure:: images/agent-group-agent.png
   :alt: Change Group Relations for Agent

   Change Group Relations for Agent

To assign some agents to a group:

1. Click on a group in the *Groups* column.
2. Select the permissions you would like to connect the group to agents with.
3. Click on the *Save* or *Save and finish* button.

.. figure:: images/agent-group-group.png
   :alt: Change Agent Relations for Group

   Change Agent Relations for Group

.. note::

   If several agents or groups are added to the system, use the filter box to find a particular agent or group by just typing the name to filter.

Multiple agents or groups can be assigned in both screens at the same time. Additionally clicking on an agent or clicking on a group will open the edit agent screen or the edit group screen for the selected resource.


Agents ↔ Groups Relations Reference
-----------------------------------

When assigning an agent to a group or vice versa, several permissions can be set as connection between an agent and a group. The following permissions are available by default:

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

chat_owner
   Agents have full rights for a chat and can accept chat requests.

chat_participant
   Agents may normally participate in a chat.

chat_observer
   Agents may take part silently in a chat.

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
