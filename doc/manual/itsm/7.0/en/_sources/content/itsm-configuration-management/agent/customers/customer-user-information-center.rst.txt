Customer User Information Center
================================

After installation of the package a new widget named *Assign CIs* will be available in the *Customer User Information Center*.

.. figure:: images/customers-customer-user-information-center.png
   :alt: Assign CIs Widget

   Assign CIs Widget

This widget displays the configuration items that have this customer user as owner.

Configuration items can be filtered by clicking on a class name in the header of the overview widget. There is an option *All* to see all configuration items. The numbers after the class names indicates how many configuration items are in each classes.

The assingment is done via attribute ``Owner``. If the configuration item uses different attribute for linking, you should change it in the system configuration settings.

.. seealso::

   See ``AgentCustomerUserInformationCenter::Backend###0060-CUIC-ITSMConfigItemCustomerUser`` system configuration setting for more information.

The default setting is:

.. code-block:: none

   ConfigItemKey → Computer → Owner
                   Hardware → Owner
                   Location → Owner
                   Network  → Owner
                   Software → Owner

You also need to have this ``Owner`` attribute in the class definition to display the assigned configuration items. Check the existing class definitions in the :doc:`../../admin/cmdb-settings/config-items` module.

If your class definition doesn't contain the ``Owner`` attribute, then you have to add it manually.

.. code-block:: JavaScript

   {
       Key => 'Owner',
       Name => Translatable('Owner'),
       Searchable => 1,
       Input => {
           Type => 'Customer',
       },
   },
