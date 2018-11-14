Appointment Notifications
=========================

Missing appointments can damage your image with a customer. Once there is an appointment assigned in the calendar, it’s normal to receive notification:

- Upon a new or changed event
- Upon cancellation of an event
- Before the event, as a reminder

Notification relieves the agent the stress of mentally tracking appointments.

OTRS Appointment Notifications satisfies this need. Here a person can easily set notifications with general rules, including trigger events and filters. Afterward, appointments fitting the bill notify the correct users at the correct time.

Use this screen to add appointment notifications to the system. In a fresh OTRS installation an appointment reminder notification is already added by default. The appointment notification management screen is available in the *Appointment Notifications* module of the *Communication & Notifications* group.

.. figure:: images/appointment-notification-management.png
   :alt: Appointment Notification Management Screen

   Appointment Notification Management Screen


Manage Appointment Notifications
--------------------------------

To add an appointment notification:

1. Click on the *Add Notification* button in the left sidebar.
2. Fill in the required fields as explained in :ref:`Appointment Notification Settings`.
3. Click on the *Save* button.

To edit an appointment notification:

1. Click on an appointment notification in the list of appointment notifications.
2. Modify the fields as explained in :ref:`Appointment Notification Settings`.
3. Click on the *Save* or *Save and finish* button.

To delete an appointment notification:

1. Click on the trash icon in the list of appointment notifications.
2. Click on the *Confirm* button.

.. figure:: images/appointment-notification-delete.png
   :alt: Delete Appointment Notification Screen

   Delete Appointment Notification Screen

To export all appointment notifications:

1. Click on the *Export Notifications* button in the left sidebar.
2. Choose a location in your computer to save the ``Export_Notification.yml`` file.

To import appointment notifications:

1. Click on the *Browse…* button in the left sidebar.
2. Select a previously exported ``.yml`` file.
3. Click on the *Overwrite existing notifications?* checkbox, if you would like to overwrite the existing notifications.
4. Click on the *Import Notification configuration* button.


Appointment Notification Settings
---------------------------------

The following settings are available when adding or editing this resource. The fields marked with an asterisk are mandatory.

.. seealso::

   For an example, see the default appointment reminder notification which is included in a fresh OTRS installation.


Basic Appointment Notification Settings
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. figure:: images/appointment-notification-settings-basic.png
   :alt: Appointment Notification Settings - Basic

   Appointment Notification Settings - Basic

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

   .. figure:: images/appointment-notification-persnoal-setting.png
      :alt: Personal Appointment Notification Settings

      Personal Appointment Notification Settings

Agent preferences tooltip
   This message will be shown on the agent preferences screen as a tooltip for this notification.

Validity \*
   Set the validity of this resource. Each resource can be used in OTRS only, if this field is set to *valid*. Setting this field to *invalid* or *invalid-temporarily* will disable the use of the resource.


Appointment Events
^^^^^^^^^^^^^^^^^^

.. figure:: images/appointment-notification-settings-events.png
   :alt: Appointment Notification Settings - Events

   Appointment Notification Settings - Events

Event
   Here you can choose which events will trigger this notification. An additional appointment filter can be applied below to only send for appointments with certain criteria.

   Possible events are:

   ``AppointmentCreate``
      Executed after an appointment has been created.

   ``AppointmentUpdate``
      Executed after an appointment has been updated.

   ``AppointmentDelete``
     Executed after an appointment has been deleted.

   ``AppointmentNotification``
     This is a special appointment event that will be executed by the OTRS daemon in time. If an appointment contains a date/time value for notifications, as already described in this documentation, and such a notification date is reached, the OTRS daemon will execute this kind of event for every related appointment separately.

   ``CalendarCreate``
     Executed after a calendar has been created.

   ``CalendarUpdate``
     Executed after a calendar has been updated.


Appointment Filter
^^^^^^^^^^^^^^^^^^

.. figure:: images/appointment-notification-settings-appointment-filter.png
   :alt: Appointment Notification Settings - Appointment Filter

   Appointment Notification Settings - Appointment Filter

This widget can optionally be used to narrow the list of appointments by matching configured values:

Calendar
   Select which calendar the related appointment needs to be part of.

Title
   Filter for a part or complete title of the appointment.

Location
   Filter for a part or complete location of the appointment.

Resource
   Choose from a list of teams or resources assigned to the appointments.


Appointment Notification Recipients
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. figure:: images/appointment-notification-settings-recipients.png
   :alt: Appointment Notification Settings - Recipients

   Appointment Notification Settings - Recipients

Send to
   Select which agents should receive the notifications. Possible values are:

   - Agent (resources), who are selected within the appointment
   - All agents with (at least) read permission for the appointment (calendar)
   - All agents with write permission for the appointment (calendar)

Send to these agents
   One or more agents can be selected who should receive the notifications.

Send to all group members (agents only)
   One or more groups can be selected whom agents should receive the notifications.

Send to all role members
   One or more roles can be selected whom agents should receive the notifications.

Send on out of office
   If this option is checked, the notification will be sent even if the agent is currently out of office.

Once per day
   Notify users just once per day about a single appointment using a selected transport.


Appointment Notification Methods
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. figure:: images/appointment-notification-settings-notification-methods.png
   :alt: Appointment Notification Settings - Notification Methods

   Appointment Notification Settings - Notification Methods

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

      Only for OnPremise users: Additional email templates can be added by placing a ``.tt`` file into the folder ``<OTRS_Home>/Kernel/Output/HTML/Templates/Standard/NotificationEvent/Email/``. See the existing email templates for an example. If your system is hosted by OTRS Group, please contact your Sales associate for an offer "Sales <sales@otrs.com>"

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


Appointment Notification Text
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. figure:: images/appointment-notification-settings-notification-text.png
   :alt: Appointment Notification Settings - Notification Text

   Appointment Notification Settings - Notification Text

The main content of a notification can be added for each languages with localized subject and body text. It is also possible to define static text content mixed with OTRS smart tags.

Subject \*
   The localized subject for a specific language.

Text \*
   The localized body text for a specific language.

Add new notification language
   Select which languages should be added to create localized notifications. The language of the customer or agent will be used as found in the customer and agent preferences. Secondarily, the system default language will be chosen. The fall back will always be english.

.. warning::

   Deleting a language in :sysconfig:`DefaultUsedLanguages <frontend.html#defaultusedlanguages>` setting that already has a notification text here will make the notification text unusable. If a language is not present or enabled on the system, the corresponding notification text could be deleted if it is not needed anymore.


Appointment Notification Variables
----------------------------------

Using variables in appointment notifications is possible. Variables, known as OTRS tags, are replaced by OTRS when generating the mail. Find a list of available tags stems for signatures at the bottom of both add and edit screens.

.. figure:: images/appointment-notification-variables.png
   :alt: Appointment Notification Variables

   Appointment Notification Variables

For example, the variable ``<OTRS_APPOINTMENT_TITLE[20]>`` expands to the first 20 characters of the title allowing a template to include something like the following.

.. code-block:: text

   Title: <OTRS_APPOINTMENT_TITLE[20]>

This tag expands, for example to:

.. code-block:: text

   Title: Daily meeting in the…
