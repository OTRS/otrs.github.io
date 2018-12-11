ITSM Changes
============

After installation of the package a new menu will be available in the agent interface.

.. note::

   In order to grant users access to the *ITSM Changes* menu, you need to add them as member to the group *itsm-change*.

   The menu items that were added by this package will be visible after you log-in to the system again.

The implementation of a change, including all required work orders, follows the underlying workflow shown below:

1. Creation of a change.
2. Creation of needed work orders.
3. Definition of conditions and actions.
4. Execution of a change.

.. toctree::
   :maxdepth: 4
   :caption: Contents

   itsm-changes/overview
   itsm-changes/new
   itsm-changes/new-from-template
   itsm-changes/schedule
   itsm-changes/projected-service-availability
   itsm-changes/pir
   itsm-changes/templates
   itsm-changes/search
