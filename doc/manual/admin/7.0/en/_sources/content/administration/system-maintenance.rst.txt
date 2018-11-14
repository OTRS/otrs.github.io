System Maintenance
==================

System maintenance is a crucial part of the work done by all system administrators. Some maintenance tasks require to put the operation on hold. In such cases, pro-active information to users is essential to raise their awareness and understanding.

OTRS supports this with the System Maintenance Module, which allows administrators to schedule maintenance windows in advance and inform users with login messages and notifications about the planned maintenance. Also, during a scheduled maintenance window, only administrators are allowed to log into the system.

Use this screen to schedule system maintenance for the system. The system maintenance management screen is available in the *System Maintenance* module of the *Administration* group.

.. figure:: images/system-maintenance-management.png
   :alt: System Maintenance Management Screen

   System Maintenance Management Screen


Manage System Maintenance
-------------------------

To schedule a system maintenance:

1. Click on the *Add New System Maintenance* button in the left sidebar.
2. Fill in the required fields.
3. Click on the *Save* button.

.. figure:: images/system-maintenance-add.png
   :alt: Schedule New System Maintenance Screen

   Schedule New System Maintenance Screen

To edit a system maintenance:

1. Click on a system maintenance entry in the list of system maintenance entries or you are already redirected here from *Add New System Maintenance* screen.
2. Modify the fields.
3. Click on the *Save* or *Save and finish* button.

.. figure:: images/system-maintenance-edit.png
   :alt: Edit System Maintenance Information Screen

   Edit System Maintenance Information Screen

To delete a system maintenance:

1. Click on the trash icon in the last column of the overview table.
2. Click on the *Confirm* button.

.. figure:: images/system-maintenance-delete.png
   :alt: Delete System Maintenance Screen

   Delete System Maintenance Screen

.. note::

   If several system maintenance entries are added to the system, use the filter box to find a particular system maintenance by just typing the name to filter.


System Maintenance Settings
---------------------------

Start date
   Select a date from when the system maintenance is scheduled.

Stop date
   Select a date when the system maintenance is planned to finish.

Comment \*
   The name of this resource. Any type of characters can be entered to this field including uppercase letters and spaces. The comment will be displayed in the overview table.

Login message
   If this text is given, it will be displayed in the login screen, if the next option is checked.

   .. seealso::

      There are some default system maintenance massage set in the system configuration. For more information see the following system configuration settings:

      - :sysconfig:`SystemMaintenance::IsActiveDefaultLoginErrorMessage <core.html#systemmaintenance-isactivedefaultloginerrormessage>`
      - :sysconfig:`SystemMaintenance::IsActiveDefaultLoginMessage <core.html#systemmaintenance-isactivedefaultloginmessage>`
      - :sysconfig:`SystemMaintenance::IsActiveDefaultNotification <core.html#systemmaintenance-isactivedefaultnotification>`

Show login message
   If checked, the login message is displayed in the login screen of OTRS.

Notify message
   If this text is given, a notification will be displayed in the agent interface before the start of the system maintenance.

   .. seealso::

      Set the minutes a notification is shown for notice about upcoming system maintenance period in system configuration setting:

      - :sysconfig:`SystemMaintenance::TimeNotifyUpcomingMaintenance <core.html#systemmaintenance-timenotifyupcomingmaintenance>`

Validity \*
   Set the validity of this resource. Each resource can be used in OTRS only, if this field is set to *valid*. Setting this field to *invalid* or *invalid-temporarily* will disable the use of the resource.

Manage Sessions
   This widget gives an overview about the currently logged in users. It is possible to kill each sessions by clicking on the *Kill this session* links. You can also kill all sessions except yours by clicking on the *Kill all Sessions, except for your own* button.

   .. figure:: images/system-maintenance-manage-sessions.png
      :alt: Edit System Maintenance - Manage Sessions

      Edit System Maintenance - Manage Sessions
