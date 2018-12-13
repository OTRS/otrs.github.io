PIR
===

Use this screen to filter work orders based on certain criteria. This overview screen is available in the *PIR* menu item of the *ITSM Changes* menu.

.. figure:: images/itsm-changes-pir.png
   :alt: Post Implementation Review Screen

   Post Implementation Review Screen

Work orders can be filtered by clicking on a state name in the header of the overview widget. The numbers after the state names indicates how many work orders are in each states.

.. seealso::

   See setting ``ITSMChange::Frontend::AgentITSMChangePIR###Filter::WorkOrderStates`` to define the work order states that will be used as filters in the overview.

To limit the number of displayed work orders per page:

1. Click on the gear icon in the top right corner of the overview header.
2. Select the maximum number of work orders displayed per page.
3. Click on the *Save* button.

To see the details of a work order:

1. Click on the row of a work order.

.. figure:: images/itsm-changes-work-order-zoom.png
   :alt: Work Order Zoom Screen

   Work Order Zoom Screen

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

``DynamicField_WorkOrderFieldName``
   Dynamic field that is associated to the work order.

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

``WorkOrderAgent``
   Agent assigned to the PIR.

``WorkOrderCount``
   Number of work orders related to the change.

``WorkOrderNumber``
   System generated work order number.

``WorkOrderState``
   Status of the work order.

``WorkOrderStateSignal``
   Work order status indicator to be shown as traffic light.

``WorkOrderTitle``
   Name of the work order.

``WorkOrderType``
   Type of the work order.

.. seealso::

   See setting ``ITSMChange::Frontend::AgentITSMChangePIR###ShowColumns`` to define the displayed attributes.
