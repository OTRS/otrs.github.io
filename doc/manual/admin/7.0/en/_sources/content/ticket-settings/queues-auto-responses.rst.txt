Queues ↔ Auto Responses
=======================

Communicating a change in, for example, service times, service levels or other information which would be good for a customer to know when opening a ticket can be a tedious and error-ridden task. Attempting to make sure all departments have the correct information and transmitting this to their customers poses a challenge.

OTRS gives you the power to quickly assign the appropriate automatic responses to any queue, containing pertinent service information, ensuring this information reaches your customers before expectations aren't reached.

Use this screen to add one or more automatic responses to one or more queues. The management screen is available in the *Queues ↔ Auto Responses* module of the *Ticket Settings* group.

.. figure:: images/auto-response-queue-management.png
   :alt: Manage Queue-Auto Response Relations

   Manage Queue-Auto Response Relations


Manage Queues ↔ Auto Responses Relations
----------------------------------------

To assign an automatic response to a queue:

1. Click on a queue in the *Queues* column.
2. Select the automatic responses you would like to add the queue to.
3. Click on the *Save* or *Save and finish* button.

.. figure:: images/auto-response-queue-queue.png
   :alt: Change Auto Response Relations for Queue

   Change Auto Response Relations for Queue

.. note::

   It is not possible to assign multiple queues to an automatic response by clicking on the automatic response name. A click on the automatic response will open to the :doc:`auto-responses` screen.

.. note::

   If several automatic responses or queues are added to the system, use the filter box to find a particular automatic response or queue by just typing the name to filter.


Queues ↔ Auto Responses Settings
--------------------------------

The following settings are available when assigning some automatic responses to a queue.

auto reply
   This automatic response will be sent to users, if they send a message to the queue.

auto reject
   This automatic response will be sent to users, if they send a message to the queue,m but the queue doesn't accept any message.

auto follow up
   This automatic response will be sent to users, if follow up option is enabled.

auto reply/new ticket
   This automatic response will be sent to users, if they send the first message of a new ticket to the queue.

auto remove
   This automatic response will be sent to users, if the remove option is enabled.

.. note::

   *Auto reply*, *auto reject* and *auto reply/new ticket* mutually cancel each other based on the queue settings. Only one will take effect per queue.

