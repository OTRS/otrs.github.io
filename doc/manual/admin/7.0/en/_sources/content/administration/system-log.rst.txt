System Log
==========

Professional systems log their activities in one or more log files to help administrators when troubleshooting or to get an overview of what is going on in their system on a detailed level.

These logs are usually not available to application administrators without a certain level of permissions, and skills, on the operating system.

OTRS allows application administrators to access the system log comfortably by using the graphical interface without the need to have access to the server's command shell. The administrator can decide which level of logging is needed, to make sure that the log files are not unnecessarily filled.

Use this screen to view log entries of OTRS. The log overview screen is available in the *System Log* module of the *Administration* group.

.. figure:: images/system-log.png
   :alt: System Log Screen

   System Log Screen

Each line in the log contains a timestamp, the log priority, the system component and the log entry itself.

.. note::

   If several log entries are displayed in the log, use the filter box to find a particular log entry by just typing the name to filter.

System Log Configuration Options
________________________________

:sysconfig:`Core → Log <core.html#core-log>`
