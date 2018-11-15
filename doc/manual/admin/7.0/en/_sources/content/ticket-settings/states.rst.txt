States
======

Active tracking of tickets leads to a better sense of workload and provides metrics as a key performance indicator. Sorting tasks and setting appointments can help to level-off the workload and keep your service desk running.

OTRS uses ticket states to ensure that your agents always know which tickets are being attended to and which not. Additionally, detailed reports on the states of your tickets can be provided by ticket search or reports and personalized sorting is possible using dashboards and queue and service overviews.

Nine states are pre-defined. More states can be added, but the default states are enough to get you going and mostly enough for any situation.

closed successful
   A ticket is complete. The customer received a solution which worked.

closed unsuccessful
   A ticket is complete. The customer received no solution or the solution was not appropriate.

merged
   The ticket content is found in a different ticket.

new
   The ticket is created by the customer without contact with an agent.

open
   The ticket is currently in progress. Customer and agent are in contact with one another.

pending auto close+
   The ticket will be marked *closed successful* upon reaching the set pending time.

pending auto close-
   The ticket will *closed unsuccessful* upon reaching the pending time.

pending reminder
   The ticket should be worked on again upon reaching the pending time.

removed
   The ticket has been removed from the system.

.. note::

   Pending jobs are checked per default every two hours and forty-five minutes. This time is a static time, which means the times are 02:45, 4:45, 6:45 and so on. The job can be run more often or seldom and are configured in the *System Configuration* module of the *Administration* group.

Use this screen to add states to the system. A fresh OTRS installation contains several states by default. The state management screen is available in the *States* module of the *Ticket Settings* group.

.. figure:: images/state-management.png
   :alt: State Management Screen

   State Management Screen


Manage States
-------------

To add a state:

1. Click on the *Add State* button in the left sidebar.
2. Fill in the required fields.
3. Click on the *Save* button.

.. figure:: images/state-add.png
   :alt: Add State Screen

   Add State Screen

.. warning::

   States can not be deleted from the system. They can only be deactivated by setting the *Validity* option to *invalid* or *invalid-temporarily*.

To edit a state:

1. Click on a state in the list of state.
2. Modify the fields.
3. Click on the *Save* or *Save and finish* button.

.. figure:: images/state-edit.png
   :alt: Edit State Screen

   Edit State Screen

.. note::

   If several states are added to the system, use the filter box to find a particular state by just typing the name to filter.

If you change the name of a queue which is used in the system configuration, a validation check will warn you and give you the option to apply your changes now by clicking on *Save and update automatically*, manually make the changes your self by choosing another default later by clicking on *Don't save, update manually* or canceling the action by clicking on *Cancel*.

.. figure:: images/queue-system-state-validation.png
   :alt: System State Validation Check Screen

   System State Validation Check Screen

.. warning::

   Changing the name of this object should be done with care, the check only provides verification for certain settings and ignores things where the name can't be verified. Some examples are dashboard filters, action control lists (ACLs), and processes (sequence flow actions) to name a few. Documentation of your setup is key to surviving a name change.

State Settings
--------------

The following settings are available when adding or editing this resource. The fields marked with an asterisk are mandatory.

Name \*
   The name of this resource. Any type of characters can be entered to this field including uppercase letters and spaces. The name will be displayed in the overview table.

State type \*
   Every state is linked to a type, which needs to be specified if a new state is created or an existing one is edited. The following types are available:

   - closed
   - merged
   - new
   - open
   - pending auto
   - pending reminder
   - removed

   .. note::

      State types are predefined and cannot be changed in the software due to their special mechanics. When adding new states for *pending auto* and *pending reminder* state types you must make further configurations in the *System Configuration* module of the *Administration* group.

Validity \*
   Set the validity of this resource. Each resource can be used in OTRS only, if this field is set to *valid*. Setting this field to *invalid* or *invalid-temporarily* will disable the use of the resource.

Comment
   Add additional information to this resource. It is recommended to always fill this field as a description of the resource with a full sentence for better clarity, because the comment will be also displayed in the overview table.


State Configuration Options
---------------------------

The following options are relevant and noteworthy. Please review these when managing states:

- :sysconfig:`Daemon::SchedulerCronTaskManager::Task###TicketPendingCheck <daemon.html#daemon-schedulercrontaskmanager-task-ticketpendingcheck>`
- :sysconfig:`Ticket::StateAfterPending <core.html#ticket-stateafterpending>`
