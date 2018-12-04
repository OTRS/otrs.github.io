Log Mechanism
=============

System Log
----------

OTRS comes with a system log backend that can be used for application logging and debugging.

The ``Log`` object can be accessed and used via the object manager like this:

.. code-block:: Perl

   $Kernel::OM->Get('Kernel::System::Log')->Log(
       Priority => 'error',
       Message  => 'Need something!',
   );

Depending on the configured log level via ``MinimumLogLevel`` option in system configuration, logged message will either be saved or not, based on their ``Priority`` flag.

If ``error`` is set, just errors are logged. With ``debug``, you get all logging messages. The order of log levels is:

-  ``debug``
-  ``info``
-  ``notice``
-  ``error``

The output of the system log can be directed to either a syslog daemon or log file, depending on the configured ``LogModule`` option in system configuration.


Communication Log
-----------------

In addition to system log, OTRS provides specialized logging backend for any communication related logging. The system comes with dedicated tables and frontends to track and display communication logs for easier debugging and operational overview.

To take advantage of the new system, first create a non-singleton instance of communication log object:

.. code-block:: Perl

   my $CommunicationLogObject = $Kernel::OM->Create(
       'Kernel::System::CommunicationLog',
       ObjectParams => {
           Transport   => 'Email',     # Transport log module
           Direction   => 'Incoming',  # Incoming|Outgoing
           AccountType => 'POP3',      # Mail account type
           AccountID   => 1,           # Mail account ID
       },
   );

When you have a communication log object instance, you can start an object log for logging individual messages. There are two object logs currently implemented: ``Connection`` and ``Message``.

``Connection`` object log should be used for logging any connection related messages (for example: authenticating on server or retrieving incoming messages).

Simply, start the object log by declaring its type, and you can use it immediately:

.. code-block:: Perl

   $CommunicationLogObject->ObjectLogStart(
       ObjectLogType => 'Connection',
   );

   $CommunicationLogObject->ObjectLog(
       ObjectLogType => 'Connection',
       Priority      => 'Debug',                              # Trace, Debug, Info, Notice, Warning or Error
       Key           => 'Kernel::System::MailAccount::POP3',
       Value         => "Open connection to 'host.example.com' (user-1).",
   );

The communication log object instance handles the current started object logs, so you don't need to remember and bring them around everywhere, but it also means that you can only start one object per type.

If you encounter an unrecoverable error, you can choose to close the object log and mark it as failed:

.. code-block:: Perl

   $CommunicationLogObject->ObjectLog(
       ObjectLogType => 'Connection',
       Priority      => 'Error',
       Key           => 'Kernel::System::MailAccount::POP3',
       Value         => 'Something went wrong!',
   );

   $CommunicationLogObject->ObjectLogStop(
       ObjectLogType => 'Connection',
       Status        => 'Failed',
   );

In turn, you can mark the communication log as failure as well:

.. code-block:: Perl

   $CommunicationLogObject->CommunicationStop(
       Status => 'Failed',
   );

Otherwise, stop the object log and in turn communication log as success:

.. code-block:: Perl

   $CommunicationLogObject->ObjectLog(
       ObjectLogType => 'Connection',
       Priority      => 'Debug',
       Key           => 'Kernel::System::MailAccount::POP3',
       Value         => "Connection to 'host.example.com' closed.",
   );

   $CommunicationLogObject->ObjectLogStop(
       ObjectLogType => 'Connection',
       Status        => 'Successful',
   );

   $CommunicationLogObject->CommunicationStop(
       Status => 'Successful',
   );

``Message`` object log should be used for any log entries regarding specific messages and their processing. It is used in a similar way, just make sure to start it before using it:

.. code-block:: Perl

   $CommunicationLogObject->ObjectLogStart(
       ObjectLogType => 'Message',
   );

   $CommunicationLogObject->ObjectLog(
       ObjectLogType => 'Message',
       Priority      => 'Error',
       Key           => 'Kernel::System::MailAccount::POP3',
       Value         => "Could not process message. Raw mail saved (report it on http://bugs.otrs.org/)!",
   );

   $CommunicationLogObject->ObjectLogStop(
       ObjectLogType => 'Message',
       Status        => 'Failed',
   );

   $CommunicationLogObject->CommunicationStop(
       Status => 'Failed',
   );

You also have the possibility to link the log object and later lookup the communications for a certain object type and ID:

.. code-block:: Perl

   $CommunicationLogObject->ObjectLookupSet(
       ObjectLogType    => 'Message',
       TargetObjectType => 'Article',
       TargetObjectID   => 2,
   );

   my $LookupInfo = $CommunicationLogObject->ObjectLookupGet(
       TargetObjectType => 'Article',
       TargetObjectID   => 2,
   );

You should make sure to always stop communication and flag it as failed, if any log object failed as well. This will allow administrators to see failed communications in the overview, and take any action if needed.

It's important to preserve the communication log for duration of a single process. If your work is spanning over multiple modules and any of them can benefit from logging, make sure to pass the existing communication log instance around so all methods can use the same one. With this approach, you will make sure any log entries spawned for the same process are contained in a single communication.

If passing the communication log instance is not an option (async tasks!), you can also choose to recreate the communication log object in the same state as in previous step. Just get the communication ID and pass it to the new code, and then create the instance with this parameter supplied:

.. code-block:: Perl

   # Get communication ID in parent code.
   my $CommunicationID = $CommunicationLogObject->CommunicationIDGet();

   # Somehow pass communication ID to child code.
   # ...

   # Recreate the instance in child code by using same communication ID.
   my $CommunicationLogObject = $Kernel::OM->Create(
       'Kernel::System::CommunicationLog',
       ObjectParams => {
           CommunicationID => $CommunicationID,
       },
   );

You can then continue to use this instance as previously stated, start any object logs if needed, adding entries and setting status in the end.

If you need to retrieve the communication log data or do something else with it, please also take a look at
``Kernel::System::CommunicationLog::DB.pm``.
