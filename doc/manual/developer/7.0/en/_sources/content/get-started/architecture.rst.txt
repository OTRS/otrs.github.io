Architecture Overview
=====================

The OTRS framework is modular. The following picture shows the basic layer architecture of OTRS.

.. figure:: images/architecture.png
   :alt: OTRS Architecture

   OTRS Architecture

The OTRS Generic Interface continues OTRS modularity. The next picture shows the basic layer architecture of the Generic Interface.

.. figure:: images/giarchitecture.png
   :alt: Generic Interface Architecture

   Generic Interface Architecture


Directories
-----------

+-----------------------------------+-----------------------------------+
| Directory                         | Description                       |
+===================================+===================================+
| bin/                              | command line tools                |
+-----------------------------------+-----------------------------------+
| bin/cgi-bin/                      | web handle                        |
+-----------------------------------+-----------------------------------+
| bin/fcgi-bin/                     | fast CGI web handle               |
+-----------------------------------+-----------------------------------+
| Kernel                            | application code base             |
+-----------------------------------+-----------------------------------+
| Kernel/Config/                    | configuration files               |
+-----------------------------------+-----------------------------------+
| Kernel/Config/Files               | configuration files               |
+-----------------------------------+-----------------------------------+
| Kernel/GenericInterface/          | the Generic Interface API         |
+-----------------------------------+-----------------------------------+
| Kernel/GenericInterface/Invoker/  | invoker modules for Generic       |
|                                   | Interface                         |
+-----------------------------------+-----------------------------------+
| Kernel/GenericInterface/Mapping/  | mapping modules for Generic       |
|                                   | Interface, e.g. Simple            |
+-----------------------------------+-----------------------------------+
| Kernel/GenericInterface/Operation | operation modules for Generic     |
| /                                 | Interface                         |
+-----------------------------------+-----------------------------------+
| Kernel/GenericInterface/Transport | transport modules for Generic     |
| /                                 | Interface, e.g. "HTTP SOAP"       |
+-----------------------------------+-----------------------------------+
| Kernel/Language                   | language translation files        |
+-----------------------------------+-----------------------------------+
| Kernel/Scheduler/                 | Scheduler files                   |
+-----------------------------------+-----------------------------------+
| Kernel/Scheduler/TaskHandler      | handler modules for scheduler     |
|                                   | tasks, e.g. GenericInterface      |
+-----------------------------------+-----------------------------------+
| Kernel/System/                    | core modules, e.g. Log, Ticket    |
+-----------------------------------+-----------------------------------+
| Kernel/Modules/                   | frontend modules, e.g.            |
|                                   | QueueView                         |
+-----------------------------------+-----------------------------------+
| Kernel/Output/HTML/               | html templates                    |
+-----------------------------------+-----------------------------------+
| var/                              | variable data                     |
+-----------------------------------+-----------------------------------+
| var/log                           | logfiles                          |
+-----------------------------------+-----------------------------------+
| var/cron/                         | cron files                        |
+-----------------------------------+-----------------------------------+
| var/httpd/htdocs/                 | htdocs directory with index.html  |
+-----------------------------------+-----------------------------------+
| var/httpd/htdocs/skins/Agent/     | available skins for the Agent     |
|                                   | interface                         |
+-----------------------------------+-----------------------------------+
| var/httpd/htdocs/skins/Customer/  | available skins for the Customer  |
|                                   | interface                         |
+-----------------------------------+-----------------------------------+
| var/httpd/htdocs/js/              | JavaScript files                  |
+-----------------------------------+-----------------------------------+
| scripts/                          | misc files                        |
+-----------------------------------+-----------------------------------+
| scripts/test/                     | unit test files                   |
+-----------------------------------+-----------------------------------+
| scripts/test/sample/              | unit test sample data files       |
+-----------------------------------+-----------------------------------+


Files
-----

- .pl = Perl
- .pm = Perl Module
- .tt = Template::Toolkit template files
- .dist = Default templates of files
- .yaml or .yml = YAML files, used for Web Service configuration


Core Modules
------------

Core modules are located under ``$OTRS_HOME/Kernel/System/*``. This layer is for the logical work. Core modules are used to handle system routines like *lock ticket* and *create ticket*. A few main core modules
are:

-  ``Kernel::System::Config`` (to access configuration options)
-  ``Kernel::System::Log`` (to log into OTRS log backend)
-  ``Kernel::System::DB`` (to access the database backend)
-  ``Kernel::System::Auth`` (to check user authentication)
-  ``Kernel::System::User`` (to manage users)
-  ``Kernel::System::Group`` (to manage groups)
-  ``Kernel::System::Email`` (for sending emails)

For more information, see: http://doc.otrs.com/doc/


Frontend Handle
---------------

The interface between the browser, web server and the frontend modules. A frontend module can be used via the HTTP link.

::

   http://localhost/otrs/index.pl?Action=Module


Frontend Modules
----------------

Frontend modules are located under ``$OTRS_HOME/Kernel/Modules/*.pm``. There are two public functions in there - ``new()`` and ``run()`` - which are accessed from the frontend handle (e.g. ``index.pl``).

``new()`` is used to create a frontend module object. The frontend handle provides the used frontend module with the basic framework objects. These are, for example: ``ParamObject`` (to get web form params), ``DBObject`` (to use existing database connections), ``LayoutObject`` (to use templates and other HTML layout functions), ``ConfigObject`` (to access config settings), ``LogObject`` (to use the framework log system), ``UserObject`` (to get the user functions from the current user), ``GroupObject`` (to get the group functions).

For more information, see: http://doc.otrs.com/doc/


CMD Frontend
------------

The CMD (command line) frontend is like the web frontend handle and the web frontend module in one (just without the ``LayoutObject``) and uses the core modules for some actions in the system.


Generic Interface Modules
-------------------------

Generic interface modules are located under ``$OTRS_HOME/Kernel/GenericInterface/*``. Generic interface modules are used to handle each part of a web service execution on the system. The main modules for the generic interface are:

-  ``Kernel::GenericInterface::Transport`` (to interact with remote systems)
-  ``Kernel::GenericInterface::Mapping`` (to transform data into a required format)
-  ``Kernel::GenericInterface::Requester`` (to use OTRS as a client for the web service)
-  ``Kernel::GenericInterface::Provider`` (to use OTRS as a server for web service)
-  ``Kernel::GenericInterface::Operation`` (to execute provider actions)
-  ``Kernel::GenericInterface::Invoker`` (to execute requester actions)
-  ``Kernel::GenericInterface::Debugger`` (to track web service communication, using log entries)

For more information, see: http://doc.otrs.com/doc/


Generic Interface Invoker Modules
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Generic interface invoker modules are located under ``$OTRS_HOME/Kernel/GenericInterface/Invoker/*``. Each invoker is contained in a folder called ``Controller``. This approach helps to define a name space not only for internal classes and methods but for filenames too. For example: ``$OTRS_HOME/Kernel/GenericInterface/Invoker/Test/`` is the controller for all test type invokers.

Generic interface invoker modules are used as a backend to create requests for remote systems to execute actions.

For more information, see: http://doc.otrs.com/doc/


Generic Interface Mapping Modules
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Generic interface mapping modules are located under ``$OTRS_HOME/Kernel/GenericInterface/Mapping/*``. These modules are used to transform data (keys and values) from one format to another.

For more information, see: http://doc.otrs.com/doc/


Generic Interface Operation Modules
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Generic interface operation modules are located under ``$OTRS_HOME/Kernel/GenericInterface/Operation/*``. Each operation is contained in a folder called ``Controller``. This approach help to define a name space not only for internal classes and methods but for filenames too. For example: ``$OTRS_HOME/Kernel/GenericInterface/Operation/Ticket/`` is the controller for all ticket type operations.

Generic interface operation modules are used as a backend to perform actions requested by a remote system.

For more information, see: http://doc.otrs.com/doc/


Generic Interface Transport Modules
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Generic interface network transport modules are located under ``$OTRS_HOME/Kernel/GenericInterface/Operation/*``. Each transport module should be placed in a directory named as the network protocol used. For example: The HTTP SOAP transport module, located in ``$OTRS_HOME/Kernel/GenericInterface/Transport/HTTP/SOAP.pm``.

Generic interface transport modules are used send data to, and receive data from a remote system.

For more information, see: http://doc.otrs.com/doc/


Scheduler Task Handler Modules
------------------------------

Scheduler task handler modules are located under ``$OTRS_HOME/Kernel/Scheduler/TaskHandler/*``. These modules are used to perform asynchronous tasks. For example, the ``GenericInterface`` task handler perform generic interface requests to remote systems outside the Apache process. This helps the system to be more responsive, preventing possible performance issues.

For more information, see: http://doc.otrs.com/doc/


Database
--------

The database interface supports different databases.

For the OTRS data model please refer to the files in your ``/doc`` directory. Alternatively you can look at the data model on `GitHub <https://github.com/OTRS/otrs/blob/rel-6_0/development/diagrams/Database/OTRSDatabaseDiagram.png>`__.
