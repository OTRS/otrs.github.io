Queues
======

Teams need a workspace and the ability to dispatch work based on skill level, security level, department or responsibility just to name a few. Other teams may also need to view or react in these requests as well.

OTRS uses Queues to provide your teams with structure. Queues provide a powerful way to divide and disperse the work to the responsible group of people.

Use this screen to add queues to the system. In a fresh OTRS installation there are 4 default queues: *Raw*, *Junk*, *Misc* and *Postmaster*. All incoming messages will be stored in the *Raw* queue if no filter rules are defined. The *Junk* queue can be used to store spam messages. The queue management screen is available in the *Queues* module of the *Ticket Settings* group.

.. figure:: images/queue-management.png
   :alt: Queue Management Screen

   Queue Management Screen


Manage Queues
-------------

To add a queue:

1. Click on the *Add Queue* button in the left sidebar.
2. Fill in the required fields.
3. Click on the *Save* button.

.. figure:: images/queue-add.png
   :alt: Add Queue Screen

   Add Queue Screen

.. warning::

   Queues can not be deleted from the system. They can only be deactivated by setting the *Validity* option to *invalid* or *invalid-temporarily*.

To edit a queue:

1. Click on a queue in the list of queues.
2. Modify the fields.
3. Click on the *Save* or *Save and finish* button.

.. figure:: images/queue-edit.png
   :alt: Edit Queue Screen

   Edit Queue Screen

.. note::

   If several priorities are added to the system, use the filter box to find a particular priority by just typing the name to filter.

If you change the name of a queue which is used in the system configuration, a validation check will warn you and give you the option to apply your changes now by clicking on *Save and update automatically*, manually make the changes your self by choosing another default later by clicking on *Don't save, update manually* or canceling the action by clicking on *Cancel*.

.. figure:: images/queue-system-config-validation.png
  :alt: System Queue Validation Check Screen

  System Queue Validation Check Screen

.. warning::

   Changing the name of this object should be done with care, the check only provides verification for certain settings and ignores things where the name can't be verified. Some examples are dashboard filters, action control lists (ACLs), and processes (sequence flow actions) to name a few. Documentation of your setup is key to surviving a name change.


Queue Settings
--------------

The following settings are available when adding or editing this resource. The fields marked with an asterisk are mandatory.

Name \*
   The name of this resource. Any type of characters can be entered to this field including uppercase letters and spaces. The name will be displayed in the overview table.

Sub-queue of
   It is possible to add the new queue under an existing one as sub-queue. This will be displayed as *Parent Queue::Child Queue*.

Group \*
   It is possible to limit access to the selected group. The group creates a permission link between the queue and an agent or a customer user.

Unlock timeout minutes
   Any ticket on open, which is locked, in this queue will automatically unlock after the set amount of minutes. The value *0* (default) means tickets in this queue remain locked.

Escalation - first response time (minutes)
   The maximum amount of working time allowed before agent contact with the customer.

   .. note::

      First response time will not trigger for an email ticket or telephone ticket created by an agent.

Escalation - update time (minutes)
   The maximum amount of working time allowed between agent contact with the customer.

Escalation - solution time (minutes)
   The maximum amount of working time allowed until the ticket is marked as solved.

   .. note::

      Solution time will not reset if the ticket is reopened.

Follow up Option \*
   Specify the handling of a follow up on closed tickets. Possible values:

   new ticket
      The follow up will create a new ticket.

   possible
      The follow up will re-open the already closed ticket.

   reject
      The follow up will be rejected. See :doc:`auto-responses` chapter for more information.

Ticket lock after a follow up \*
   Only applicable if the *Follow up Option* is set to *possible*. Locks the previously closed ticket, upon re-opening, to the last owner. This ensures that a follow up for a ticket is processed by the agent that has previously handled that ticket.

   .. warning::

      This does not take out-of-office into account. Use this setting with care to ensure or in combination with *Unlock timeout minutes*.

System address \*
   Select one of the :doc:`../communication-notifications/email-addresses` as the sender identity for this queue.

   .. note::

      This is an ID in the database. Making changes to the :doc:`../communication-notifications/email-addresses` can have adverse effects here.

Default sign key
   This is only active if :doc:`../communication-notifications/pgp-keys` or :doc:`../communication-notifications/s-mime-certificates` is enabled in the :doc:`../administration/system-configuration`. Choose the key to sign emails per default.

Salutation \*
   Select one of the defined :doc:`salutations`.

Signature \*
   Select one of the defined :doc:`signatures`.

Calendar
   Select the calendar which defines working hours for this queue. Calendars are defined in the :doc:`../administration/system-configuration`.

Validity \*
   Set the validity of this resource. Each resource can be used in OTRS only, if this field is set to *valid*. Setting this field to *invalid* or *invalid-temporarily* will disable the use of the resource.

Comment
   Add additional information to this resource. It is recommended to always fill this field as a description of the resource with a full sentence for better clarity, because the comment will be also displayed in the overview table.

Chat Channel
   Chat channel that will be used for communication related to the tickets in this queue.
