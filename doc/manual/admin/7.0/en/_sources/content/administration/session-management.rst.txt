Session Management
==================

Administrators of web-based applications need to have access to the information who's connected to the system and, if required, delete unwanted sessions.

OTRS offers the session management to quickly get an overview of agent and customer sessions, unique agents and customers currently logged in and the ability to kill sessions with just a mouse click.

Use this screen to manage logged in user sessions in the system. The session management screen is available in the *Session Management* module of the *Administration* group.

.. figure:: images/session-management.png
   :alt: Session Management Screen

   Session Management Screen


Manage Sessions
---------------

To see a logged in user session:

1. Select a logged in user from the list of sessions.
2. Click on the token.
3. See the details.

.. figure:: images/session-management-details.png
   :alt: Session Management Details Screen

   Session Management Details Screen

To kill a session:

1. Select a logged in user from the list of sessions.
2. Click on the *Kill this session* link in the *Kill* column.

.. figure:: images/session-management-kill.png
   :alt: Session Kill Screen

   Session Kill Screen

.. warning::

   Clicking the *Kill this session* link removes the session immediately without confirmation. The unsaved work of the user will be lost!

To kill all sessions:

1. Click on the *Kill all sessions* button in the left sidebar.

.. warning::

   Clicking the *Kill all session* link removes all sessions immediately without confirmation. The unsaved work of the users will be lost!

.. note::

   If several users are logged in to the system, use the filter box to find a particular session by just typing the name to filter.
