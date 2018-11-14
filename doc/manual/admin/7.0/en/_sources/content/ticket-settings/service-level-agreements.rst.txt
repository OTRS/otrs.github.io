Service Level Agreements
========================

Your organization must meet the time demands of your customers. Timely service matters. Response to questions, updates on issues, and solutions must be provided it an agreed amount of time. The agent must receive notification of possible breaches, to prevent ticket escalation.

OTRS scales well with your needs and offers management of Service Level Agreements (SLAs). OTRS provides you with the possibility to create numerous service level agreements covering all of your service and customer need. Each :term:`SLA` can cover multiple services and define the availability of service and escalation periods.

Use this screen to add service level agreements to the system. A fresh OTRS installation doesn't contain any service level agreements by default. The service level agreement management screen is available in the *Service Level Agreements* module of the *Ticket Settings* group.

.. figure:: images/sla-management.png
   :alt: Service Level Agreement Management Screen

   Service Level Agreement Management Screen

.. warning::

   Services must first be activated via :doc:`../administration/system-configuration` under the *Administration* group to be selectable in the ticket screens. You may click on the link in the warning message to directly jump to the configuration setting.

.. figure:: images/service-activate-warning.png
   :alt: Service Activation Warning

   Service Activation Warning


Manage Service Level Agreements
-------------------------------

.. note::

   Adding service level agreements requires, that at least one service is added to the system. Create services in the :doc:`services` screen.

To add a service level agreement:

1. Click on the *Add SLA* button in the left sidebar.
2. Fill in the required fields.
3. Click on the *Save* button.

.. figure:: images/sla-add.png
   :alt: Add Service Level Agreement Screen

   Add Service Level Agreement Screen

.. warning::

   Service level agreements can not be deleted from the system. They can only be deactivated by setting the *Validity* option to *invalid* or *invalid-temporarily*.

To edit a service level agreement:

1. Click on a service level agreement in the list of service level agreements.
2. Modify the fields.
3. Click on the *Save* or *Save and finish* button.

.. figure:: images/sla-edit.png
   :alt: Edit Service Level Agreement Screen

   Edit Service Level Agreement Screen

.. note::

   If several service level agreements are added to the system, use the filter box to find a particular service level agreement by just typing the name to filter.


Service Level Agreement Settings
--------------------------------

The following settings are available when adding or editing this resource. The fields marked with an asterisk are mandatory.

SLA \*
   The name of this resource. Any type of characters can be entered to this field including uppercase letters and spaces. The name will be displayed in the overview table.

Service
   Select one or more of the :doc:`services` to be assigned to this SLA.

Calendar
   Select the calendar which defines working hours for this queue. Calendars are defined in the :doc:`../administration/system-configuration`.

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

Validity \*
   Set the validity of this resource. Each resource can be used in OTRS only, if this field is set to *valid*. Setting this field to *invalid* or *invalid-temporarily* will disable the use of the resource.

Comment
   Add additional information to this resource. It is recommended to always fill this field as a description of the resource with a full sentence for better clarity, because the comment will be also displayed in the overview table.

Dialog message
   Is being displayed if a customer chooses this SLA on ticket creation (only in the external interface).
