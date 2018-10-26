Auto Responses
==============

Quick and transparent service is vital to maintaining a good working relationship with your customer. Email, fax, social media and other non-real-time communication are patient, but you want to engage your customer immediately upon receipt of a request.

OTRS allows you to respond to a customer immediately upon receipt of a request giving the custmoers instantaneous feedback assuring them that their request is in processing, establishing expectation.

Automatic responses can be sent to customers based on the occurrence of certain events, such as the creation of a ticket in a specific queue, the receipt of a follow-up message in regards to a ticket, the closure or rejection of a ticket, etc.

Use this screen to add automatic responses for use in queues. A fresh OTRS installation contains some automatic responses by default. The automatic response management screen is available in the *Auto Responses* module of the *Ticket Settings* group.

.. figure:: images/auto-response-management.png
   :alt: Auto Response Management Screen

   Auto Response Management Screen


Manage Auto Responses
---------------------

.. note::

   Adding automatic responses requires a valid system address. Create system addresses in the :doc:`../communication-notifications/email-addresses` screen.

To add an automatic response:

1. Click on the *Add Auto Response* button in the left sidebar.
2. Fill in the required fields.
3. Click on the *Save* button.

.. figure:: images/auto-response-add.png
   :alt: Add Auto Response Screen

   Add Auto Response Screen

.. warning::

   Auto responses can not be deleted from the system. They can only be deactivated by setting the *Validity* option to *invalid* or *invalid-temporarily*.

To edit an automatic response:

1. Click on an automatic response in the list of automatic responses.
2. Modify the fields.
3. Click on the *Save* or *Save and finish* button.

.. figure:: images/auto-response-edit.png
   :alt: Edit Auto Response Screen

   Edit Auto Response Screen

.. note::

   If several automatic responses are added to the system, use the filter box to find a particular automatic response by just typing the name to filter.


Auto Response Settings
----------------------

The following settings are available when adding or editing this resource. The fields marked with an asterisk are mandatory.

Name \*
   The name of this resource. Any type of characters can be entered to this field including uppercase letters and spaces. The name will be displayed in the overview table.

Subject \*
   The subject of the email sent to the users.

Response
   The body of the email sent to the users.

Type \*
   The event type that triggers the sending of this automatic response. Only one automatic response can be sent automatically. The following event types are available:

   auto follow up
      Confirms receipt of the follow-up.

   auto reject
      The message rejects a customer follow-up.

   auto remove
      Deletion of a ticket, done by the system.

   auto reply
      A newly raised ticket will trigger this auto response.

   auto reply/new ticket
      This message informs the customer of the new ticket number.

Auto response from \*
   The sender email address, from which the automatic response will be sent.

Validity \*
   Set the validity of this resource. Each resource can be used in OTRS only, if this field is set to *valid*. Setting this field to *invalid* or *invalid-temporarily* will disable the use of the resource.

Comment
   Add additional information to this resource. It is recommended to always fill this field as a description of the resource with a full sentence for better clarity, because the comment will be also displayed in the overview table.


Auto Response Variables
-----------------------

Using variables in automatic responses is possible. Variables, known as OTRS tags, are replaced by OTRS when generating the mail. Find a list of available tags stems for automatic responses at the bottom of both add and edit screens.

.. figure:: images/auto-response-variables.png
   :alt: Auto Response Variables

   Auto Response Variables

For example, the variable ``<OTRS_TICKET_TicketNumber>`` expands to the ticket number allowing a template to include something like the following.

.. code-block:: text

   Ticket#<OTRS_TICKET_TicketNumber>

This tag expands, for example to:

.. code-block:: text

   Ticket#2018101042000012
