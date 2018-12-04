Using the power of the OTRS module layers
=========================================

OTRS has a large number of so-called *module layers* which make it very easy to extend the system without patching existing code. One example is the number generation mechanism for tickets. It is a *module layer* with `pluggable modules <#ticketnumber-generator>`__, and you can add your own custom number generator modules if you wish to do so. Let's look at the different layers in detail!

.. toctree::
   :maxdepth: 3
   :caption: Authentication and User Management

   otrs-module-layers/agent-auth
   otrs-module-layers/auth-sync
   otrs-module-layers/customer-auth

.. toctree::
   :maxdepth: 3
   :caption: Preferences

   otrs-module-layers/customer-user-preferences
   otrs-module-layers/queue-preferences
   otrs-module-layers/service-preferences
   otrs-module-layers/sla-preferences

.. toctree::
   :maxdepth: 3
   :caption: Other Core Functions

   otrs-module-layers/log
   otrs-module-layers/outputfilter
   otrs-module-layers/stats
   otrs-module-layers/ticketnumber-generator
   otrs-module-layers/ticketevent

.. toctree::
   :maxdepth: 3
   :caption: Frontend Modules

   otrs-module-layers/dashboard
   otrs-module-layers/notify
   otrs-module-layers/ticket-menu

.. toctree::
   :maxdepth: 3
   :caption: Generic Interface Modules

   otrs-module-layers/gi-transport
   otrs-module-layers/gi-mapping
   otrs-module-layers/gi-invoker
   otrs-module-layers/gi-operation

.. toctree::
   :maxdepth: 3
   :caption: Daemon And Scheduler

   otrs-module-layers/daemon/daemon-modules
   otrs-module-layers/daemon/scheduler-task-worker-modules

.. toctree::
   :maxdepth: 3
   :caption: Dynamic Fields

   otrs-module-layers/dynamic-fields/dynamic-fields-overview
   otrs-module-layers/dynamic-fields/dynamic-fields-framework
   otrs-module-layers/dynamic-fields/dynamic-fields-interaction
   otrs-module-layers/dynamic-fields/dynamic-fields-extend-options
   otrs-module-layers/dynamic-fields/dynamic-fields-new-field
   otrs-module-layers/dynamic-fields/dynamic-fields-extend

.. toctree::
   :maxdepth: 3
   :caption: Email Handling

   otrs-module-layers/ticket-postmaster-modules

.. toctree::
   :maxdepth: 3
   :caption: Process Management

   otrs-module-layers/process-management-modules
