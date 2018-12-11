ITSM Change Management
======================

Change management, according to ITIL, is a service transition process whose purpose is to manage IT changes, including planning, documentation, and implementation upon approval and clearance. The objective is to minimize negative effects on the IT infrastructure, particularly on critical services, resulting from ad-hoc or poorly-managed changes or amendments.

The implementation of OTRS::ITSM requires significant technical specification and preparation. Prior to a technical implementation, key elements of the change management process, such as required workflows, metrics or reports, must be defined. The implementation in OTRS::ITSM defines a change as an alteration of the existing IT landscape, such as the installation of a new mail server.

As changes typically consist of several sub-tasks, OTRS::ITSM allows any number of sub-tasks to be defined per change. These are known as *work orders*. 

.. toctree::
   :maxdepth: 4
   :caption: Contents

   itsm-change-management/install-update-uninstall
   itsm-change-management/admin
   itsm-change-management/agent
   itsm-change-management/external
