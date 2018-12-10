State Machine
=============

OTRS::ITSM features state machines which define valid statuses and possible result statuses for a change and for a work order.

Use this screen to manage the state machines. The state machine management screen is available in the *State Machine* module of the *Change Settings* group.

.. figure:: images/state-machine-management.png
   :alt: State Machine Management Screen

   State Machine Management Screen


Manage State Machines
---------------------

The statuses and possible result statuses should be defined as *transitions*. In OTRS::ITSM, this is illustrated as a table.

To add a new transition:

1. Select the state machine to add the new transition to from the *Action* widget of the left sidebar.
2. Select a state from the transition should start.
3. Select a state to the transition should go.
4. Click on the *Save* or *Save and finish* button.

.. figure:: images/state-machine-transition-add.png
   :alt: Add New State Transition Screen

   Add New State Transition Screen

To edit a transition:

1. Click on a state machine in the list of state machines.
2. Click on a transition name.
3. Modify the *Next state*.
4. Click on the *Save* or *Save and finish* button.

.. figure:: images/state-machine-transition-edit.png
   :alt: Edit State Transition Screen

   Edit State Transition Screen

To delete a transition:

1. Click on a state machine in the list of state machines.
2. Click on the trash icon in the last column of transition table.
3. Click on the *Yes* button in the confirmation screen.

.. figure:: images/state-machine-transition-delete.png
   :alt: Delete State Transition Screen

   Delete State Transition Screen


Change State Machine
--------------------

The standard installation generates suggestions based on the following logic model.

.. figure:: images/state-machine-change.png
   :alt: Change State Machine Model

   Change State Machine Model

To see the state machine transitions, click on the *ITSM::ChangeManagement::Change::State* item in the list of state machines.

.. figure:: images/state-machine-change-transitions.png
   :alt: Change State Machine Transitions

   Change State Machine Transitions

.. seealso::

   The states of the change state machine are defined in the *ITSM::ChangeManagement::Change::State* class in the :doc:`../../../general-catalog`.


Work Order State Machine
------------------------

The standard installation generates suggestions based on the following logic model.

.. figure:: images/state-machine-work-order.png
   :alt: Work Order State Machine Model

   Work Order State Machine Model

To see the state machine transitions, click on the *ITSM::ChangeManagement::WorkOrder::State* item in the list of state machines.

.. figure:: images/state-machine-work-order-transitions.png
   :alt: Work Order State Machine Transitions

   Work Order State Machine Transitions

.. seealso::

   The states of the work order state machine are defined in the *ITSM::ChangeManagement::WorkOrder::State* class in the :doc:`../../../general-catalog`.
