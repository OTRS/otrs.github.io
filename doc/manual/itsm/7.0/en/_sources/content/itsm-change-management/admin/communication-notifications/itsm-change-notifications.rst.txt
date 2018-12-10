ITSM Change Notifications
=========================

Use this screen to add ITSM change notifications to the system. After installing the package several notifications are added to the system. The ITSM change notification management screen is available in the *ITSM Change Notifications* module of the *Communication & Notifications* group.

.. figure:: images/itsm-change-notification-management.png
   :alt: ITSM Change Notification Management Screen

   ITSM Change Notification Management Screen


Manage ITSM Change Notifications
--------------------------------

To add an ITSM change notification:

1. Click on the *Add Notification Rule* button in the left sidebar.
2. Fill in the required fields.
3. Click on the *Save* button.

.. figure:: images/itsm-change-notification-add.png
   :alt: Add ITSM Change Notification Screen

   Add ITSM Change Notification Screen

To edit an ITSM change notification:

1. Click on an ITSM change notification in the list of ITSM change notifications.
2. Modify the fields.
3. Click on the *Save* or *Save and finish* button.

.. figure:: images/itsm-change-notification-edit.png
   :alt: Edit ITSM Change Notification Screen

   Edit ITSM Change Notification Screen

To delete an ITSM change notification:

1. Click on the trash icon in the list of ITSM change notifications.
2. Click on the *OK* button.

.. figure:: images/itsm-change-notification-delete.png
   :alt: Delete ITSM Change Notification Screen

   Delete ITSM Change Notification Screen

To copy an ITSM change notification:

1. Click on the copy icon in the list of ITSM change notifications.


ITSM Change Notification Settings
---------------------------------

The following settings are available when adding or editing this resource. The fields marked with an asterisk are mandatory.


Basic ITSM Change Notification Settings
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. figure:: images/itsm-change-notification-add.png
   :alt: ITSM Change Notification Settings - Basic

   ITSM Change Notification Settings - Basic

Name \*
   The name of this resource. Any type of characters can be entered to this field including uppercase letters and spaces. The name will be displayed in the overview table.

Event \*
   Here you can choose which events will trigger this notification.

Attribute
   The field, that should be listen for the notification.

Rule
   The content of the field, that are set as *Attribute*.

Recipients
   Here you can select the groups, that can receive the notification.

Validity \*
   Set the validity of this resource. Each resource can be used in OTRS only, if this field is set to *valid*. Setting this field to *invalid* or *invalid-temporarily* will disable the use of the resource.

Comment
   Add additional information to this resource. It is recommended to always fill this field as a description of the resource with a full sentence for better clarity, because the comment will be also displayed in the overview table.


Notification (Agent)
^^^^^^^^^^^^^^^^^^^^

.. figure:: images/itsm-change-notification-settings-agent.png
   :alt: ITSM Change Notification Settings - Notification for Agents

   ITSM Change Notification Settings - Notification for Agents

The main content of a notification can be added for each languages with localized subject and body text. It is also possible to define static text content mixed with OTRS smart tags.

Subject \*
   The localized subject for a specific language.

Text \*
   The localized body text for a specific language.

Add new notification language
   Select which languages should be added to create localized notifications.

.. warning::

   Deleting a language in :sysconfig:`DefaultUsedLanguages <frontend.html#defaultusedlanguages>` setting that already has a notification text here will make the notification text unusable. If a language is not present or enabled on the system, the corresponding notification text could be deleted if it is not needed anymore.


Notification (Customer)
^^^^^^^^^^^^^^^^^^^^^^^

.. figure:: images/itsm-change-notification-settings-customer.png
   :alt: ITSM Change Notification Settings - Notification for Customers

   ITSM Change Notification Settings - Notification for Customers

The main content of a notification can be added for each languages with localized subject and body text. It is also possible to define static text content mixed with OTRS smart tags.

Subject \*
   The localized subject for a specific language.

Text \*
   The localized body text for a specific language.

Add new notification language
   Select which languages should be added to create localized notifications.

.. warning::

   Deleting a language in :sysconfig:`DefaultUsedLanguages <frontend.html#defaultusedlanguages>` setting that already has a notification text here will make the notification text unusable. If a language is not present or enabled on the system, the corresponding notification text could be deleted if it is not needed anymore.


ITSM Change Notification Variables
----------------------------------

Using variables in ticket notifications is possible. Variables, known as OTRS tags, are replaced by OTRS when generating the mail. .. TODO: MISSING! Find a list of available tags stems for signatures at the bottom of both add and edit screens.

.. seealso::

   Please check the existing notifications for the list of OTRS tags, that can be used in ITSM change notifications.

.. TODO: this is missing!
   .. figure:: images/ticket-notification-variables.png
      :alt: Ticket Notification Variables

      Ticket Notification Variables

For example, the variable ``<OTRS_CHANGE_ChangeManager>`` expands to the change manager allowing a template to include something like the following.

.. code-block:: text

   Change manager: <OTRS_CHANGE_ChangeManager>

This tag expands, for example to:

.. code-block:: text

   Change manager: John Smith
