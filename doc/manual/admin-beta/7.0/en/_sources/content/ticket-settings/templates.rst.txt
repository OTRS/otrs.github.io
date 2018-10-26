Templates
=========

Providing the correct and consistent answer all the time regardless of employee or knowledge-level is important to maintain a professional appearance to your customers. Additionally, speed in sending standard answers is key to wading through the masses of requests in growing service desks.

OTRS templates offer you a variety of ways to deal with standardizing communications and helps to predefine texts so that the customer always receives the same level and quality of service from all agents.

Use this screen to add templates for use in communications. A fresh OTRS installation already contains a template by default. The template management screen is available in the *Templates* module of the *Ticket Settings* group.

.. figure:: images/template-management.png
   :alt: Template Management Screen

   Template Management Screen


Manage Templates
----------------

.. note::

   To add attachments to a template, it needs to create the attachment first in the :doc:`attachments` screen.

To add a template:

1. Click on the *Add Template* button in the left sidebar.
2. Fill in the required fields.
3. Click on the *Save* button.

.. figure:: images/template-add.png
   :alt: Add Template Screen

   Add Template Screen

To edit a template:

1. Click on a template in the list of templates.
2. Modify the fields.
3. Click on the *Save* or *Save and finish* button.

.. figure:: images/template-edit.png
   :alt: Edit Template Screen

   Edit Template Screen

To delete a template:

1. Click on the trash icon in the list of templates.
2. Click on the *Confirm* button.

.. figure:: images/template-delete.png
   :alt: Delete Template Screen

   Delete Template Screen

.. note::

   If several templates are added to the system, a filter box is useful to find a particular template by just typing to filter.


Template Settings
-----------------

The following settings are available when adding or editing this resource. The fields marked with an asterisk are mandatory.

Type \*
   There are different kind of templates that are used for different purposes. A template can be:

   Answer
      To be used as a ticket response or reply.

   Create
      To be used for new phone or email ticket.

   Email
      To be used for writing an email to a customer user.

   Forward
      To be used to forward an article to someone else.

   Note
      To be used to create internal notes.

   Phone call
      To be used for inbound and outbound phone calls.

   Process dialog
      To be used in process management.

Name \*
   The name of this resource. Any type of characters can be entered to this field including uppercase letters and spaces. The name will be displayed in the overview table.

Subject
   The subject of the email sent to the users.

Subject method
   Specify how the current article subject should be dealt with. The following methods are available:

   Combine
      The template subject will be added after the current article subject.

   Keep
      The current article subject will be kept.

   Overwrite
      The current article subject will be replaced with the template subject.

Template
   The body of the email sent to the users.

Attachments
   It is possible to add one ore more attachments to this template. Attachments can be added in the :doc:`attachments` screen.

Validity \*
   Set the validity of this resource. Each resource can be used in OTRS only, if this field is set to *valid*. Setting this field to *invalid* or *invalid-temporarily* will disable the use of the resource.

Comment
   Add additional information to this resource. It is recommended to always fill this field as a description of the resource with a full sentence for better clarity, because the comment will be also displayed in the overview table.


Template Variables
------------------

Using variables in templates is possible. Variables, known as OTRS tags, are replaced by OTRS when generating the mail. Find a list of available tags stems for signatures at the bottom of both add and edit screens.

.. figure:: images/template-variables.png
   :alt: Template Variables

   Template Variables

For example, the variable ``<OTRS_TICKET_TicketNumber>`` expands to the ticket number allowing a template to include something like the following.

.. code-block:: text

   Ticket#<OTRS_TICKET_TicketNumber>

This tag expands, for example to:

.. code-block:: text

   Ticket#2018101042000012
