Customer Information Center
===========================

After installation of the package a new widget named *Assign CIs* will be available in the *Customer Information Center*.

.. figure:: images/customers-customer-information-center.png
   :alt: Assign CIs Widget

   Assign CIs Widget

This widget displays the configuration items that are assigned to the customer.

Configuration items can be filtered by clicking on a class name in the header of the overview widget. There is an option *All* to see all configuration items. The numbers after the class names indicates how many configuration items are in each classes.

The assignment is done via attribute ``CustomerID`` by default. If the configuration item uses different attribute for linking, you should change it in the system configuration settings.

.. seealso::

   See ``AgentCustomerInformationCenter::Backend###0060-CIC-ITSMConfigItemCustomerCompany`` system configuration setting for more information.

The default setting is:

.. code-block:: none

   ConfigItemKey → Computer → CustomerID
                   Hardware → CustomerID
                   Location → CustomerID
                   Network  → CustomerID
                   Software → CustomerID

You also need to have this ``CustomerID`` attribute in the class definition to display the assigned configuration items. Check the existing class definitions in the :doc:`../../admin/cmdb-settings/config-items` module.

If your class definition doesn't contain the ``CustomerID`` attribute, then you have to add it manually.

.. code-block:: JavaScript

   {
       Key => 'CustomerID',
       Name => Translatable('Customer Company'),
       Searchable => 1,
       Input => {
           Type => 'CustomerCompany',
       },
   },
