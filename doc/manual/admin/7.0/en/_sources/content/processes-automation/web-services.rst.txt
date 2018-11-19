Web Services
============

In a connected world, a ticket system needs to be able to react to requests from other systems and also to send requests or information to other systems:

* CRM systems
* Project Management systems
* Documentation management systems
* and many more

The ticket system must be reachable by other services without manual intervention by an agent.

OTRS supports this requirement by the Generic Interface. It empowers the administrator to create a web service for a specific task without scripting language knowledge. OTRS reacts on incoming REST or SOAP requests and create objects or provides object data to other systems transparently.

A web service is a communication method between two systems, in our case OTRS and a remote system. In its configuration, the :term:`Operation` or :term:`Invoker` determine the direction of communication, and the :term:`Mapping` and :term:`Transport` take care of how the data is received and interpreted.

In its configuration it can be defined what actions the web service can perform internally (operation), what actions the OTRS request can perform remote system (invokers), how data is converted from one system to the other (mapping), and over which protocol the communication will take place (transport).

The generic interface is the framework that makes it possible to create web services for OTRS in a predefined way, using already made building blocks that are independent from each other and interchangeable.

Use this screen to manage web services in the system. A fresh OTRS installation contains no web service by default. The web service management screen is available in the *Web Services* module of the *Processes & Automation* group.

.. figure:: images/web-service-management.png
   :alt: Web Service Management Screen

   Web Service Management Screen


Manage Web Services
-------------------

To create a web service:

1. Click on the *Add Web Service* button in the left sidebar.
2. Fill in the required fields.
3. Click on the *Save* button.

.. figure:: images/web-service-add.png
   :alt: Create New Web Service Screen

   Create New Web Service Screen

To edit a web service:

1. Click on a web service in the list of web services.
2. Modify the fields.
3. Click on the *Save* or *Save and finish* button.

.. figure:: images/web-service-edit.png
   :alt: Edit Web Service Screen

   Edit Web Service Screen

To delete a web service:

1. Click on a web service in the list of web services.
2. Click on the *Delete Web Service* button in the left sidebar.
3. Click on the *Delete* button in the confirmation dialog.

.. figure:: images/web-service-delete.png
   :alt: Delete Web Service Screen

   Delete Web Service Screen

To clone a web service:

1. Click on a web service in the list of web services.
2. Click on the *Clone Web Service* button in the left sidebar.
3. Enter a new name for the web service.

.. figure:: images/web-service-clone.png
   :alt: Clone Web Service Screen

   Clone Web Service Screen

To export a web service:

1. Click on a web service in the list of web services.
2. Click on the *Export Web Service* button in the left sidebar.
3. Choose a location in your computer to save the ``Export_ACL.yml`` file.

.. warning::

   All stored passwords in the web service configuration will be exported in plain text format.

To see the configuration history of a web service:

1. Click on a web service in the list of web services.
2. Click on the *Configuration History* button in the left sidebar.

.. figure:: images/web-service-configuration-history.png
   :alt: Web Service Configuration History Screen

   Web Service Configuration History Screen

To use the debugger for a web service:

1. Click on a web service in the list of web services.
2. Click on the *Debugger* button in the left sidebar.

.. figure:: images/web-service-debugger.png
   :alt: Web Service Debugger Screen

   Web Service Debugger Screen

To import a web service:

1. Click on the *Add Web Service* button in the left sidebar.
2. Click on the *Import Web Service* button in the left sidebar.
3. Click on the *Browse…* button in the dialog.
4. Select a previously exported ``.yml`` file.
5. Add a name for the imported web service (optional). Otherwise the name will be taken from the configuration file name.
6. Click on the *Import* button.


Web Service Settings
--------------------

The following settings are available when adding or editing this resource. The fields marked with an asterisk are mandatory.


General Web Service Settings
~~~~~~~~~~~~~~~~~~~~~~~~~~~~

.. figure:: images/web-service-add-general.png
   :alt: Web Service Settings - General

   Web Service Settings - General

Name \*
   The name of this resource. Any type of characters can be entered to this field including uppercase letters and spaces. The name will be displayed in the overview table.

Description
   Like comment, but longer text can be added here.

Remote system
   .. TODO: what is this?

Debug threshold
   The default value is *Debug*. When configured in this manner all communication logs are registered in the database. Each subsequent debug threshold value is more restrictive and discards communication logs of lower order than the one set in the system.

   Debug threshold levels (from lower to upper):

   - Debug
   - Info
   - Notice
   - Error

Validity
   Set the validity of this resource. Each resource can be used in OTRS only, if this field is set to *valid*. Setting this field to *invalid* or *invalid-temporarily* will disable the use of the resource.


Provider Web Service Settings
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

.. figure:: images/web-service-add-provider.png
   :alt: Web Service Settings - OTRS as Provider

   Web Service Settings - OTRS as Provider

Network transport
   Select which network transport would you like to use with the web service. Possible values are *HTTP::REST* and *HTTP::SOAP*.

   .. note::

      After selecting the transport method, you have to save the configuration with clicking on the *Save* button. A *Configuration* button will be displayed next to this field.

Configuration
   The *Configuration* button is visible only, after a network transport was selected and saved. See the configuration for *OTRS as Provider - HTTP\:\:REST* and *OTRS as Provider - HTTP\:\:SOAP* below.

Add Operation
   This option is visible only, after a network transport was selected and saved. Selecting an operation will open a new screen for its configuration.

   .. figure:: images/web-service-add-operation.png
      :alt: Web Service Settings - OTRS as Provider - Operation

      Web Service Settings - OTRS as Provider - Operation


OTRS as Provider - HTTP\:\:REST
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. figure:: images/web-service-add-provider-rest.png
   :alt: Web Service Settings - OTRS as Provider - HTTP\:\:REST

   Web Service Settings - OTRS as Provider - HTTP\:\:REST


OTRS as Provider - HTTP\:\:SOAP
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. figure:: images/web-service-add-provider-soap.png
   :alt: Web Service Settings - OTRS as Provider - HTTP\:\:SOAP

   Web Service Settings - OTRS as Provider - HTTP\:\:SOAP


Requester Web Service Settings
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

.. figure:: images/web-service-add-requester.png
   :alt: Web Service Settings - OTRS as Requester

   Web Service Settings - OTRS as Requester

Network transport
   Select which network transport would you like to use with the web service. Possible values are *HTTP::REST* and *HTTP::SOAP*.

   .. note::

      After selecting the transport method, you have to save the configuration with clicking on the *Save* button. A *Configuration* button will be displayed next to this field.

Configuration
   The *Configuration* button is visible only, after a network transport was selected and saved. See the configuration for *OTRS as Requester - HTTP\:\:REST* and *OTRS as Requester - HTTP\:\:SOAP* below.

Add error handling module
   This option is visible only, after a network transport was selected and saved. Selecting an operation will open a new screen for its configuration.

   .. figure:: images/web-service-add-error-handling-module.png
      :alt: Web Service Settings - OTRS as Provider - Error Handling Module

      Web Service Settings - OTRS as Provider - Error Handling Module


OTRS as Requester - HTTP\:\:REST
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. figure:: images/web-service-add-requester-rest.png
   :alt: Web Service Settings - OTRS as Requester - HTTP\:\:REST

   Web Service Settings - OTRS as Requester - HTTP\:\:REST


OTRS as Requester - HTTP\:\:SOAP
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. figure:: images/web-service-add-requester-soap.png
   :alt: Web Service Settings - OTRS as Requester - HTTP\:\:SOAP

   Web Service Settings - OTRS as Requester - HTTP\:\:SOAP
