Dynamic Field Interaction With Front End Modules
================================================

Knowing about how front end modules interact with dynamic fields is not strictly necessary to extend dynamic fields for the ticket or article objects, since all the screens that could use the dynamic fields are already prepared. But in case of custom developments or to extend the dynamic fields to other objects is very useful to know how to access dynamic fields framework from a front end module.

The following picture shows a simple example of how the dynamic fields interact with other OTRS framework parts.

.. figure:: images/dfInteraction.png
   :alt: Dynamic Field Interaction

   Dynamic Field Interaction

The first step is that the front end module reads the configured dynamic fields. For example ``AgentTicketNote`` should read ``Ticket::Frontend::AgentTicketNote###DynamicField`` setting. This setting can be used as the filter parameter for ``DynamicField`` core module function ``DynamicFieldListGet()``. The screen can store the results of this function to have the list of the dynamic fields activated for this particular screen.

Next, the screen should try to get the values from the web request. It can use the back end object function ``EditFieldValueGet()`` for this purpose, and can use this values to trigger ACLs. The back end object will use each driver to perform the specific actions for all functions.

To continue, the screen should get the HTML for each field to display it. The back end object function ``EditFieldRender()`` can be used to perform this action and the ACLs restriction as well as the values from
the web request can be passed to this function in order to get better results. In case of a submit the screen could also use the back end object function ``EditFieldValueValidate()`` to check the mandatory fields.

.. note::

   Other screens could use ``DisplayFieldRender()`` instead of ``EditFieldRender()`` if the screen only shows the field value, and in such case no value validation is needed.

To store the value of the dynamic field is necessary to get the object ID. For this example if the dynamic field is linked to a ticket object, the screen should already have the ``TicketID``, otherwise if the field is linked to an article object in order to set the value of the field is necessary to create the article first. ``ValueSet()`` from the back end object can be used to set the dynamic field value.

In summary the front end modules does not need to know how each dynamic field works internally to get or set their values or to display them. It just needs to call the back end object module and use the fields in a
generic way.
