Ticket Notifications
====================

Streamlining communication can save hours of labor and prevent mistakes. Sending certain messages at pre-defined stages of communication not only keeps the customer and agents informed about specific events, but it can also aid your agents by programmatically doing automated updates to the customer.

The flexibility OTRS is an industry leader in email communication and offers you complete control of notifications based on any event in your system.

Use this screen to add ticket notifications to the system. In a fresh OTRS installation several ticket notifications are already added by default. The ticket notification management screen is available in the *Ticket Notifications* module of the *Communication & Notifications* group.

.. figure:: images/ticket-notification-management.png
   :alt: Ticket Notification Management Screen

   Ticket Notification Management Screen


Manage Ticket Notifications
---------------------------

To add a ticket notification:

1. Click on the *Add Notification* button in the left sidebar.
2. Fill in the required fields as explained in :ref:`Ticket Notification Settings`.
3. Click on the *Save* button.

To edit a ticket notification:

1. Click on a ticket notification in the list of ticket notifications.
2. Modify the fields as explained in :ref:`Ticket Notification Settings`.
3. Click on the *Save* or *Save and finish* button.

To delete a ticket notification:

1. Click on the trash icon in the list of ticket notifications.
2. Click on the *Confirm* button.

.. figure:: images/ticket-notification-delete.png
   :alt: Delete Ticket Notification Screen

   Delete Ticket Notification Screen

To export all ticket notifications:

1. Click on the *Export Notifications* button in the left sidebar.
2. Choose a location in your computer to save the ``Export_Notification.yml`` file.

.. warning::

	 Certain settings are exported as numeric ids and will break when importing to a system where these settings do not appear or reference other named items.

To import ticket notifications:

1. Click on the *Browse…* button in the left sidebar.
2. Select a previously exported ``.yml`` file.
3. Click on the *Overwrite existing notifications?* checkbox, if you would like to overwrite the existing notifications.
4. Click on the *Import Notification configuration* button.


Ticket Notification Settings
----------------------------

The following settings are available when adding or editing this resource. The fields marked with an asterisk are mandatory.

.. seealso::

   For an example, see a default ticket notification which is included in a fresh OTRS installation.


Basic Ticket Notification Settings
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. figure:: images/ticket-notification-settings-basic.png
   :alt: Ticket Notification Settings - Basic

   Ticket Notification Settings - Basic

Name \*
   The name of this resource. Any type of characters can be entered to this field including uppercase letters and spaces. The name will be displayed in the overview table.

Comment
   Add additional information to this resource. It is recommended to always fill this field as a description of the resource with a full sentence for better clarity, because the comment will be also displayed in the overview table.

Show in agent preferences
   Define how the notification should be displayed in agent preferences. The following options are available:

   No
      The notification won't be displayed in agent preferences. The notification is sent to all appropriate agents by the defined method.

   Yes
      The notification will be displayed in agent preferences for selection. The agents may opt-in or opt-out.

   Yes, but require at least one active notification method.
      The notification will be displayed in agent preferences, but require at least one active notification method. This is annotated by an asterisk next to the name.

   .. figure:: images/ticket-notification-persnoal-setting.png
      :alt: Personal Ticket Notification Settings

      Personal Ticket Notification Settings


Agent preferences tooltip
   This message will be shown on the agent preferences screen as a tooltip for this notification.

Validity \*
   Set the validity of this resource. Each resource can be used in OTRS only, if this field is set to *valid*. Setting this field to *invalid* or *invalid-temporarily* will disable the use of the resource.


Events
^^^^^^

.. figure:: images/ticket-notification-settings-events.png
   :alt: Ticket Notification Settings - Events

   Ticket Notification Settings - Events

Event
   Here you can choose which events will trigger this notification. An additional ticket filter can be applied below to only send for tickets with certain criteria.


Ticket Filter [1]_
^^^^^^^^^^^^^^^^^^

.. figure:: images/ticket-notification-settings-ticket-filter.png
   :alt: Ticket Notification Settings - Ticket Filter

   Ticket Notification Settings - Ticket Filter

This widget can optionally be used to narrow the list of tickets by matching configured values:

.. note::

	 The values in this list can grow as your system grows. The more :doc:`../processes-automation/dynamic-fields` are and features you have in your system, the longer the list will be.

State
   Filter for a state of the ticket.

Priority
   Filter for a priority of the ticket.

Queue
   Filter for a queue in which the ticket is located.

Lock
   Filter for a lock state of the ticket.

Customer ID
   Filter for a customer ID of the ticket.

Customer User ID
   Filter for a customer user ID of the ticket.

Dynamic Fields
   Filter for some dynamic fields added to the system. For the complete list of dynamic fields see the the :doc:`../processes-automation/dynamic-fields` chapter.


Article Filter [1]_
^^^^^^^^^^^^^^^^^^^

.. figure:: images/ticket-notification-settings-article-filter.png
   :alt: Ticket Notification Settings - Article Filter

   Ticket Notification Settings - Article Filter

.. note::

   This widget works only if ``ArticleCreate`` or ``ArticleSend`` is selected in the *Events* widget.

Article sender type
   Filter for the sender type of the ticket. Possible values are *agent*, *system* or *customer*.

Customer visibility
   Filter for the customer visibility. Possible values are *Invisible to customer* or *Visible to customer*.

Communication channel
   Filter for the communication channel. Possible values are *Chat*, *Email*, *OTRS*, *Phone* or *SMS*.

Include attachments to notification
   If *Yes* is selected, attachments will be included to notification. Selecting *No* will not use this feature.

Attachment Name
   Filter for attachment name.

Bcc
   Filter for blind carbon copy field.

Body
   Filter for body text.

Cc
   Filter for carbon copy field.

From
   Filter for the sender field.

Subject
   Filter for the subject field.

To
   Filter for the main recipients field.

SMS phone number
   Filter for an SMS phone number.

SMS text
   Filter for the SMS text.

SMS transaction number
   Filter for an SMS transaction number.


Ticket Notification Recipients
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. figure:: images/ticket-notification-settings-recipients.png
   :alt: Ticket Notification Settings - Recipients

   Ticket Notification Settings - Recipients

Send to
   Select which agents should receive the notifications. Possible values are:

   - Agent who created the ticket
   - Agent who is responsible for the ticket
   - Agent who owns the ticket
   - All agents subscribed to both the ticket's queue and service
   - All agents subscribed to the ticket's queue
   - All agents subscribed to the ticket's service
   - All agents watching the ticket
   - All agents with write permission for the ticket
   - All recipients of the first article
   - All recipients of the last article
   - Customer user of the ticket

Send to these agents
   One or more agents can be selected who should receive the notifications.

Send to all group members (agents only)
   One or more groups can be selected whom agents should receive the notifications.

Send to all role members
   One or more roles can be selected whom agents should receive the notifications.

Send on out of office
   If this option is checked, the notification will be sent even if the agent is currently out of office.

Once per day
   Notify users just once per day about a single ticket using a selected transport.


Ticket Notification Methods
^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. figure:: images/ticket-notification-settings-notification-methods.png
   :alt: Ticket Notification Settings - Notification Methods

   Ticket Notification Settings - Notification Methods

Enable this notification method
   Enable or disable this notification method. A notification method can be email, web view or SMS.

   .. note::

      To use the SMS notification method, :doc:`../otrs-group-services/cloud-services` need to be enabled.

Additional recipient email addresses
   Additional recipients can be added here.

Article visible for customer
   An article will be created if the notification is sent to the customer or an additional email address.

Email template
   Select which email template should be used for the notification.

   .. note::

      Additional email templates can be added by placing a ``.tt`` file into the folder ``<OTRS_Home>/Kernel/Output/HTML/Templates/Standard/NotificationEvent/Email/``. See the existing email templates for an example.

Enable email security
   Checking this option will encrypt the notification email.

   .. note::

      To use this feature, :doc:`pgp-keys` or :doc:`s-mime-certificates` need to be enabled.

Email security level
   If *Enable email security* is checked, then this setting is activated. The following options are available:

   PGP sign only
      Sign only the notification email with PGP key. If no PGP keys have been added to the system, this option is not visible.

   PGP encrypt only
      Encrypt only the notification email with PGP key. If no PGP keys have been added to the system, this option is not visible.

   PGP sign and encrypt
      Sign and encrypt the notification email with PGP key. If no PGP keys have been added to the system, this option is not visible.

   SMIME sign only
      Sign only the notification email with S/MIME certificate. If no S/MIME certificates have been added to the system, this option is not visible.

   SMIME encrypt only
      Encrypt only the notification email with S/MIME certificate. If no S/MIME certificates have been added to the system, this option is not visible.

   SMIME sign and encrypt
      Sign and encrypt the notification email with S/MIME certificate. If no S/MIME certificates have been added to the system, this option is not visible.

   .. note::

      To use this feature, :doc:`pgp-keys` or :doc:`s-mime-certificates` need to be enabled.

If signing key/certificate is missing
   Select the method, that should be used if signing key or certificate is missing.

If encryption key/certificate is missing:
   Select the method, that should be used if encryption key or certificate is missing.


Notification Text
^^^^^^^^^^^^^^^^^

.. figure:: images/ticket-notification-settings-notification-text.png
   :alt: Ticket Notification Settings - Notification Text

   Ticket Notification Settings - Notification Text

The main content of a notification can be added for each languages with localized subject and body text. It is also possible to define static text content mixed with OTRS smart tags.

Subject \*
   The localized subject for a specific language.

Text \*
   The localized body text for a specific language.

Add new notification language
   Select which languages should be added to create localized notifications.

.. warning::

   Deleting a language in :sysconfig:`DefaultUsedLanguages <frontend.html#defaultusedlanguages>` setting that already has a notification text here will make the notification text unusable. If a language is not present or enabled on the system, the corresponding notification text could be deleted if it is not needed anymore.


Ticket Notification Variables
-----------------------------

Using variables in ticket notifications is possible. Variables, known as OTRS tags, are replaced by OTRS when generating the mail. Find a list of available tags stems for signatures at the bottom of both add and edit screens.

.. figure:: images/ticket-notification-variables.png
   :alt: Ticket Notification Variables

   Ticket Notification Variables

For example, the variable ``<OTRS_TICKET_TicketNumber>`` expands to the ticket number allowing a template to include something like the following.

.. code-block:: text

   Ticket#<OTRS_TICKET_TicketNumber>

This tag expands, for example to:

.. code-block:: text

   Ticket#2018101042000012

.. [1] Use of regular expressions as a filter do not work here.
