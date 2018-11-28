Updating
========

.. note::

   It is highly recommended to perform a test update on a separate testing machine first.

Updating from an earlier version of OTRS 7
   You can update directly from any previous to the latest available patch level release.

Updating from OTRS 6
   You can update from any OTRS 6 patch level to the latest available OTRS 7 patch level release.

Updating from OTRS 5 or earlier
   You cannot update from OTRS 5 or earlier directly to OTRS 7. Full updates to all available minor versions have to be made sequentially instead. For example, if you come from OTRS 4.0, you first have to perform a full update to OTRS 5, then to 6 and finally to OTRS 7.

   .. seealso::

      See the admin manual of the previous versions of OTRS for the update instructions.


Step 1: Stop All Relevant Services and the OTRS Daemon
------------------------------------------------------

Please make sure there are no more running services or cron jobs that try to access OTRS. This will depend on your service configuration and OTRS version.

.. code-block:: bash

   root> systemctl stop postfix
   root> systemctl stop apache2

If you do a major update form OTRS 6, you need to stop the old OTRS cron jobs and daemon (in this order):

.. code-block:: bash

   otrs> /opt/otrs/bin/Cron.sh stop
   otrs> /opt/otrs/bin/otrs.Daemon.pl stop
            
If you do a patch level update within OTRS 7 (using the new systemd files), stop the OTRS services via systemd:

.. code-block:: bash

   root> systemctl stop otrs-daemon
   root> systemctl stop otrs-webserver


Step 2: Backup Files and Database
---------------------------------

Create a backup of the following files and folders:

- ``Kernel/Config.pm``
- ``Kernel/WebApp.conf`` (only in case of a patch level update of OTRS 7, and only if the file was modified)
- ``var/*``
- as well as the database

.. warning::

   Don't proceed without a complete backup of your system. Use the :ref:`backup` script for this.


Step 3: Install the New Release
-------------------------------

.. note::

   With OTRS 7 RPMs are no longer provided. RPM based installations need to switch by uninstalling the RPM (this will not drop your database) and using the source archives instead.

.. code-block:: bash

   root> cd /opt
   root> mv otrs otrs-old
   root> tar -xzf otrs-x.x.x.tar.gz
   root> mv otrs-x.x.x otrs


Restore Old Configuration Files
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

- ``Kernel/Config.pm``
- ``Kernel/WebApp.conf`` (only in case of a patch level update of OTRS 7, and only if the file was modified)


Restore Article Data
~~~~~~~~~~~~~~~~~~~~

If you configured OTRS to store article data in the file system you have to restore the ``article`` folder to ``/opt/otrs/var/`` or the folder specified in the system configuration.


Restore Already Installed Default Statistics
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

If you have additional packages with default statistics you have to restore the stats XML files with the suffix ``*.installed`` to ``/opt/otrs/var/stats``.

.. code-block:: bash

   root> cd OTRS-BACKUP/var/stats
   root> cp *.installed /opt/otrs/var/stats


Set File Permissions
~~~~~~~~~~~~~~~~~~~~

Please execute the following command as root user to set the file and directory permissions for OTRS. It will try to detect the correct user and group settings needed for your setup.

.. code-block:: bash

   root> /opt/otrs/bin/otrs.SetPermissions.pl


Install Required Programs and Perl Modules
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Please refer to the `section in the installation guide <#installation-of-perl-modules>`__ that explains how to verify external dependencies such as Perl modules and Node.js.

In addition to that, OTRS 7 also requires an active cluster of Elasticsearch 6.0 or higher. Please refer to the `Setup Elasticsearch Cluster <#installation-setup-elasticsearch-cluster>`__ section in the installation guide.


Step 4: Run the Migration Script
--------------------------------

.. note::

   If you have any custom Perl or XML configuration files in ``Kernel/Config/Files``, these need to be `converted to the new formats supported by OTRS 7 <http://doc.otrs.com/doc/manual/developer/6.0/en/html/package-porting.html#packge-porting-5-to-6-configuration-files>`__ before running the migration script.

The migration script will perform many checks on your system and give you advice on how to install missing Perl modules etc., if that is required. If all checks succeeded, the necessary migration steps will be performed. Please also run this script in case of patch level updates.

Run the migration script:

.. code-block:: bash

   otrs> /opt/otrs/scripts/DBUpdate-to-7.pl

.. warning::

   Do not continue the upgrading process if this script did not work properly for you. Otherwise malfunction or data loss may occur.

The migration script also checks if ACLs and system configuration settings are correct. In case of an invalid system configuration setting, script will offer you an opportunity to fix it by choosing from a list of possible values. In case the script runs in a non-interactive mode, it will try to automatically fix invalid settings. If this fails, you will be asked to manually update the setting after the migration.

If there are outdated ACLs, the system will not be able to fix them automatically, and they need to be corrected by the administrator. Please see the last step for manual changes for details. 


Step 5: Update Installed Packages
---------------------------------

.. note::

   Packages for OTRS 6 are not compatible with OTRS 7 and have to be updated.

You can use the command below to update all installed packages. This works for all packages that are available from online repositories. You can update other packages later via the package manager (this requires a running OTRS Daemon).

.. code-block:: bash

   otrs> /opt/otrs/bin/otrs.Console.pl Admin::Package::UpgradeAll


Step 6: Restart your Services
-----------------------------

OTRS 7 comes with an own built-in web server that is used behind apache as a reverse proxy (or any other reverse proxy server). For major updates from OTRS 6, the apache configuration must be updated with the new version in ``/opt/otrs/scripts/apache2-httpd.include.conf``, if it was copied and not just linked. Please also note that while ``mod_perl`` is no longer needed, other Apache modules are required now: ``proxy_module``, ``proxy_http_module`` and ``proxy_wstunnel_module``.

After that, the services can be restarted. This will depend on your service configuration, here is an example:

.. code-block:: bash

   root> systemctl stop postfix
   root> systemctl stop apache2

.. note::

   The OTRS Daemon is required for correct operation of OTRS such as sending emails. Please activate it as described in the next step.


Step 7: Start the OTRS Daemon, Web Server and Cron Job
------------------------------------------------------

The OTRS Daemon is responsible for handling any asynchronous and recurring tasks in OTRS. The daemon and its keepalive cron job must be started as the ``otrs`` user. The built-in OTRS web server process handles the web requests handed over from Apache.

.. code-block:: bash

   otrs> /opt/otrs/bin/otrs.Daemon.pl start
   otrs> /opt/otrs/bin/Cron.sh start
   otrs> /opt/otrs/bin/otrs.WebServer.pl

OTRS comes with example systemd configuration files that can be used to make sure that the OTRS Daemon and web server are started automatically after the system starts.

.. code-block:: bash

   root> cd /opt/otrs/scripts/systemd
   root> for UNIT in *.service; do cp -vf $UNIT /usr/lib/systemd/system/; systemctl enable $UNIT; done

Now you can log into your system.


Step 8: Manual Migration Tasks and Changes
------------------------------------------

.. warning::

   This step is required only for major updates from OTRS 6.

Since the old customer interface screens are no longer present, some ACLs need to be corrected manually by the administrator. The migration script already informed you if this is the case.

Affected ACLs are those that refer to a non-existing customer interface screen in their ``Action`` setting. This frontend ``Action`` rule needs to be replaced with a corresponding ``Endpoint`` rule. A table with possible mapping is included below.

+---------------------------+----------------------------------------------+
| Action                    | Endpoint                                     |
+===========================+==============================================+
| ``CustomerTicketPrint``   | No replacement (feature dropped)             |
+---------------------------+----------------------------------------------+
| ``CustomerTicketZoom``    | ``ExternalFrontend::TicketDetailView``       |
+---------------------------+----------------------------------------------+
| ``CustomerTicketProcess`` | ``ExternalFrontend::ProcessTicketCreate`` or |
|                           | ``ExternalFrontend::ProcessTicketNextStep``  |
+---------------------------+----------------------------------------------+
| ``CustomerTicketMessage`` | ``ExternalFrontend::TicketCreate``           |
+---------------------------+----------------------------------------------+
