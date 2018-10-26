Services
========

Requests to your service desk should be categorized based on affected :term:`service` to correctly reach a team of experts to deal with the issue. Because not all your agents can deal with specific problems. Lack of experience or access to resources to fix an issue requires defining the service affected in a ticket helps to categorize the issue and target the correct teams.

OTRS allows adding all services offered by to your customers. These services may be later bound to :doc:`service-level-agreements` to ensure a timely solution based on customer-specific agreements.

Use this screen to add services to the system. A fresh OTRS installation doesn't contain any services by default. The service management screen is available in the *Services* module of the *Ticket Settings* group.

.. figure:: images/service-management.png
   :alt: Service Management Screen

   Service Management Screen

.. warning::

   Services must first be activated via :doc:`../administration/system-configuration` under the *Administration* group to be selectable in the ticket screens. You may click on the link in the warning message to directly jump to the configuration setting.

.. figure:: images/service-activate-warning.png
   :alt: Service Activation Warning

   Service Activation Warning


Manage Services
---------------

To add a service:

1. Click on the *Add Service* button in the left sidebar.
2. Fill in the required fields.
3. Click on the *Save* button.

.. figure:: images/service-add.png
   :alt: Add Service Screen

   Add Service Screen

.. warning::

   Services can not be deleted from the system. They can only be deactivated by setting the *Validity* option to *invalid* or *invalid-temporarily*.

To edit a service:

1. Click on a service in the list of services.
2. Modify the fields.
3. Click on the *Save* or *Save and finish* button.

.. figure:: images/service-edit.png
   :alt: Edit Service Screen

   Edit Service Screen

.. note::

   If several services are added to the system, use the filter box to find a particular service by just typing the name to filter.

.. warning::

   Changing the name of this object should be done with care, the check only provides verification for certain settings and ignores things where the name can't be verified. Some examples are dashboard filters, action control lists (ACLs), and processes (sequence flow actions) to name a few. Documentation of your setup is key to surviving a name change.

Service Settings
----------------

The following settings are available when adding or editing this resource. The fields marked with an asterisk are mandatory.

Service \*
   The name of this resource. Any type of characters can be entered to this field including uppercase letters and spaces. The name will be displayed in the overview table.

Sub-service of
   It is possible to add the new service under an existing one as sub-service. This will be displayed as *Parent Service::Child Service*.

Validity \*
   Set the validity of this resource. Each resource can be used in OTRS only, if this field is set to *valid*. Setting this field to *invalid* or *invalid-temporarily* will disable the use of the resource.

Comment
   Add additional information to this resource. It is recommended to always fill this field as a description of the resource with a full sentence for better clarity, because the comment will be also displayed in the overview table.
