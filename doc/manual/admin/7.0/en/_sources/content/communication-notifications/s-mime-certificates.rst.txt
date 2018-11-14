S/MIME Certificates
===================

Faculty and staff have key roles safeguarding critical information by implementing information security policies, standards, and controls. Safe email communication is a vital part of protecting this communication.

OTRS empowers you to encrypt communications where needed by means of :doc:`s-mime-certificates` or :doc:`pgp-keys`

.. note::

	 Setup of services and software required for encryption are not covered here because of independence to this software.

Use this screen to add S/MIME certificates to the system. The S/MIME management screen is available in the *S/MIME Certificates* module of the *Communication & Notifications* group.

.. figure:: images/smime-management.png
   :alt: S/MIME Management Screen

   S/MIME Management Screen


Manage S/MIME Certificates
--------------------------

.. note::

   To be able to use S/MIME certificates in OTRS, you have to activate its setting first.

   .. figure:: images/smime-support-enable.png
      :alt: Enable S/MIME Support

      Enable S/MIME Support

To add an S/MIME certificate:

1. Click on the *Add Certificate* button in the left sidebar.
2. Click on *Browse…* button to open the file dialog.
3. Select an S/MIME certificate from the file system.
4. Click on the *Add* button.

.. figure:: images/smime-certificate-add.png
   :alt: Add S/MIME Certificate Screen

   Add S/MIME Certificate Screen

.. note::

	 Only non binary keys contain ASCII (Base64) armored data prefixed with a “—– BEGIN …” line can be uploaded which are most commonly ``key.pem`` or ``root.crt``. Conversion of other formats like ``cert.p7b`` must be done using openssl.

To add a private key:

1. Click on the *Add Private Key* button in the left sidebar.
2. Click on *Browse…* button to open the file dialog.
3. Select a private key from the file system.
4. Click on the *Submit* button.

.. figure:: images/smime-private-key-add.png
   :alt: Add S/MIME Private Key Screen

   Add S/MIME Private Key Screen

To delete an S/MIME certificate:

1. Click on the trash icon in the list of S/MIME certificates.
2. Click on the *Confirm* button.

.. figure:: images/smime-certificate-delete.png
   :alt: Delete S/MIME Certificate Screen

   Delete S/MIME Certificate Screen

.. note::

   If several S/MIME certificates are added to the system, use the filter box to find a particular S/MIME certificate by just typing the name to filter.

S/MIME Configuration Options
----------------------------

:sysconfig:`Core → Crypt → SMIME <core.html#core-crypt-smime>`
