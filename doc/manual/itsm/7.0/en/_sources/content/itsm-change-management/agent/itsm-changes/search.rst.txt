Search
======

Use this screen to search for changes.

.. figure:: images/itsm-changes-search.png
   :alt: ITSM Change Search Screen

   ITSM Change Search Screen

To search for changes:

1. Click on the *Search* menu item in the *ITSM Changes* menu.
2. Fill in the required fields.
3. Click on the *Run Search* button.
4. See the search result.

.. figure:: images/itsm-changes-search-result.png
   :alt: Search Result Screen

   Search Result Screen

To limit the number of displayed changes per page:

1. Click on the gear icon in the top right corner of the overview header.
2. Select the maximum number of changes displayed per page.
3. Click on the *Save* button.

To see the details of a change:

1. Click on the row of a change.

.. figure:: images/itsm-changes-zoom.png
   :alt: ITSM Change Zoom Screen

   ITSM Change Zoom Screen

The displayed attributes can be defined via the system configuration. Not all attributes are displayed by default. The possible attributes are:

``ActualEndTime``
   Date and time at which the change implementation was completed.

``ActualStartTime``
   Date and time at which the change implementation began.

``Category``
   Category or type of change.

``ChangeBuilder``
   Name of the change builder.

``ChangeManager``
   Name of the change manager.

``ChangeNumber``
   System generated change number.

``ChangeState``
   Change status.

``ChangeStateSignal``
   Change status indicator to be shown as traffic light.

``ChangeTime``
   Date and time at which the change was modified.

``ChangeTitle``
   Name of the change.

``CreateTime``
   Date and time at which the change was created.

``DynamicField_ChangeFieldName``
   Dynamic field that is associated to the change.

``Impact``
   Expected effect of the change.

``PlannedEndTime``
   Projected change implementation completion date and time.

``PlannedStartTime``
   Planned change implementation start date and time.

``Priority``
   Priority level of the change.

``RequestedTime``
   Customer's desired implementation date.

``Services``
   Services affected by the change.

``WorkOrderCount``
   Number of work orders related to the change.

.. seealso::

   See setting ``ITSMChange::Frontend::AgentITSMChangeSearch###ShowColumns`` to define the displayed attributes.
