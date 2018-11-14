Communication Log
=================

Managers, leaders, team leads, and system administrators may need to track past communication to follow up specific messages. In some cases, issues arise, and a target recipient did not receive a message. Without access to the mail server logs, tracking the communication is difficult.

OTRS introduces the Communication Log module. It’s designed to track the communication: building and spooling the mail and the connection between client and server.

Use this screen to inspect the internal logs about communication handling. The communication log overview screen is available in the *Communication Log* module of the *Communication & Notifications* group.

.. figure:: images/communication-log-overview.png
   :alt: Communication Log Overview Screen

   Communication Log Overview Screen


Communication Log Overview
--------------------------

The communication log overview page is a dashboard-like screen with several metrics indicating the overall health of the system, depending on filtered communications.

.. figure:: images/communication-log-account-status.png
   :alt: Account Status Screen

   Account Status Screen

Account status
   This widget will signal if you have any issues with configured accounts used for fetching or sending messages.

Communication status
   This widget will notify you if there are any errors with either account connections or message processing.

Communication state
   This widget will display if there are any active communications currently in the system.

Average processing time
   This is a cumulative time statistic that is needed to complete a communication.

You can select the time range in the left sidebar in order to filter communications depending on their creation time. In addition to this, you can also dynamically filter for any keywords, state of the communication, and you can sort the overview table by all columns.

If you click on a communication row in any table, you will be presented with a detailed view screen.

.. figure:: images/communication-log-detailed-view.png
   :alt: Communication Log Detailed View Screen

   Communication Log Detailed View Screen

Every communication can contain one or more logs, which can be of *Connection* or *Message* type.

Connection
   This type of logs will contain any log messages coming from the modules responsible for connecting to your accounts and fetching/receiving messages.

Message
   This type of logs will contain any log messages related to specific message processing. Any module working on message themselves can log their actions in this log, giving you a clear overview of what's going on.

You can filter log entries based on their priority, by choosing desired priority in the left sidebar. Log level rules apply: by selecting a specific priority, you will get log entries that have that priority set and higher, with *Error* being the highest.
