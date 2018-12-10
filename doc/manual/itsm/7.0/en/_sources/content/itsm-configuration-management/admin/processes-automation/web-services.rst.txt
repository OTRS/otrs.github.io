Web Services
============

This package adds some new operations for creating, changing, retrieving, deleting and searching configuration items via generic interface. The following operations are available:

* ``ConfigItemCreate()``
* ``ConfigItemDelete()``
* ``ConfigItemGet()``
* ``ConfigItemSearch()``
* ``ConfigItemUpdate()``

.. seealso::

   For more information please take a look at the WSDL file on `GitHub <https://github.com/OTRS/ITSMConfigurationManagement/blob/rel-6_0/development/webservices/GenericConfigItemConnectorSOAP.wsdl>`__.


New Operations
--------------

These new operations are available in the *Web Services* module of the *Processes & Automation* group:

* ``ConfigItem::ConfigItemCreate``
* ``ConfigItem::ConfigItemDelete``
* ``ConfigItem::ConfigItemGet``
* ``ConfigItem::ConfigItemSearch``
* ``ConfigItem::ConfigItemUpdate``

To use these operations:

1. Add or edit a web service.
2. Select a *Network transport* in the *OTRS as provider* widget and save the web service.
3. The new operations are available in the *Add Operation* field of the *OTRS as provider* widget.
