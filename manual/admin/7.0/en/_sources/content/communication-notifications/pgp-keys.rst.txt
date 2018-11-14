PGP Keys
========

Secure communications protect your customers and you. In the GDPR encryption is explicitly mentioned as one of the security and personal data protection measures in a few Articles. Although under the GDPR encryption is not mandatory, it is indeed essential in some areas.

OTRS empowers you to encrypt communications where needed by means of :doc:`s-mime-certificates` or :doc:`pgp-keys`

.. note::

	 Setup of services and software required for encryption are not covered here because of independence to this software.

Use this screen to add PGP keys to the system. The PGP management screen is available in the *PGP Keys* module of the *Communication & Notifications* group.

.. figure:: images/pgp-management.png
   :alt: PGP Management Screen

   PGP Management Screen


Manage PGP Keys
---------------

.. note::

   To be able to use PGP keys in OTRS, you have to activate its setting first.

   .. figure:: images/pgp-support-enable.png
      :alt: Enable PGP Support

      Enable PGP Support

To add a PGP key:

1. Click on the *Add PGP Key* button in the left sidebar.
2. Click on *Browse…* button to open the file dialog.
3. Select a PGP key from the file system.
4. Click on the *Add* button.

.. figure:: images/pgp-key-add.png
   :alt: Add PGP Key Screen

   Add PGP Key Screen

To delete a PGP key:

1. Click on the trash icon in the list of PGP keys.
2. Click on the *Confirm* button.

.. figure:: images/pgp-key-delete.png
   :alt: Delete PGP Key Screen

   Delete PGP Key Screen

.. note::

   If several PGP keys are added to the system, a search box is useful to find a particular PGP key.


PGP Configuration Options
-------------------------

:sysconfig:`Core → Crypt → PGP <core.html#core-crypt-pgp>`
