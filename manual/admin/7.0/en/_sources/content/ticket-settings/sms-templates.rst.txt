SMS Templates
=============

An On-Call duty should be alarmed about incidents on an email servers, therefore cannot get an email from OTRS. Additionally, in the case where customers have no internet access, it's imperative to ensure good contact.

OTRS provides :term:`SMS` as a cloud service and allows, as with email, management of this communication via templates.

A SMS template is a default text which helps your agents to write faster tickets or answers.

Use this screen to add SMS templates for use in communications. A fresh OTRS installation doesn't contain any SMS templates by default. The :term:`SMS` template management screen is available in the *SMS Templates* module of the *Ticket Settings* group.

.. figure:: images/sms-template-management.png
   :alt: SMS Template Management Screen

   SMS Template Management Screen


Manage SMS Templates
--------------------

.. note::

   To be able to use SMS cloud service in OTRS, you have to activate it first in :doc:`../otrs-group-services/cloud-services` module.

   .. figure:: images/sms-template-cloud-service-activation.png
      :alt: Activate SMS Cloud Service

      Activate SMS Cloud Service

To add an SMS template:

1. Click on the *Add SMS Template* button in the left sidebar.
2. Fill in the required fields.
3. Click on the *Save* button.

.. figure:: images/sms-template-add.png
   :alt: Add SMS Template Screen

   Add SMS Template Screen

To edit an SMS template:

1. Click on an SMS template in the list of SMS templates.
2. Modify the fields.
3. Click on the *Save* or *Save and finish* button.

.. figure:: images/sms-template-edit.png
   :alt: Edit SMS Template Screen

   Edit SMS Template Screen

To delete an SMS template:

1. Click on the trash icon in the list of SMS templates.
2. Click on the *Confirm* button.

.. figure:: images/sms-template-delete.png
   :alt: Delete SMS Template Screen

   Delete SMS Template Screen

.. note::

   If several SMS templates are added to the system, a filter box is useful to find a particular SMS template by just typing to filter.


SMS Template Settings
---------------------

The following settings are available when adding or editing this resource. The fields marked with an asterisk are mandatory.

Type \*
   There are different kind of SMS templates that are used for different purposes. A template can be:

   Answer
      To be used as a ticket response with *Reply via SMS* in the article menu of the ticket screen.

   Create
      To be used for a new SMS ticket.

   SMSOutbound
      To be used for sending a new SMS to a customer user from within the ticket menu of the ticket screen.

Name \*
   The name of this resource. Any type of characters can be entered to this field including uppercase letters and spaces. The name will be displayed in the overview table.

Template
   The body of the email sent to the users.

.. warning::
   The maximum length of text message that you can send is 918 characters. However, if you send more than 160 characters then your message will be broken down in to chunks of 153 characters before being sent to the recipient's handset. We recommend keeping the messages to less than 160 characters.

Flash message
   Show message directly without user interaction and do not store it automatically (support may vary by device and provider).

Validity \*
   Set the validity of this resource. Each resource can be used in OTRS only, if this field is set to *valid*. Setting this field to *invalid* or *invalid-temporarily* will disable the use of the resource.

Comment
   Add additional information to this resource. It is recommended to always fill this field as a description of the resource with a full sentence for better clarity, because the comment will be also displayed in the overview table.


SMS Template Variables
----------------------

Using variables in SMS templates is possible. Variables, known as OTRS tags, are replaced by OTRS when generating the mail. Find a list of available tags stems for signatures at the bottom of both add and edit screens.

.. figure:: images/sms-template-variables.png
   :alt: SMS Template Variables

   SMS Template Variables

For example, the variable ``<OTRS_TICKET_TicketNumber>`` expands to the ticket number allowing an SMS template to include something like the following.

.. code-block:: text

   Ticket#<OTRS_TICKET_TicketNumber> has been raised in <OTRS_Ticket_Queue>.

This tag expands, for example to:

.. code-block:: text

   Ticket#2018101042000012 has been raised in Postmaster.
