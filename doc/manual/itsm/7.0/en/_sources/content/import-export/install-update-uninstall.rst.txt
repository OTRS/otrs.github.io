Install, Update and Uninstall
=============================

This package can be installed, updated or uninstalled with the package manager in the administrator interface or using the command line tool.

.. note::

   You need to be in the *admin* group to access the administrator interface and use the `Package Manager <http://doc.otrs.com/doc/manual/admin/7.0/en/content/administration/package-manager.html>`__, which is described in the administration manual more detailed.

.. note::

   We assumed that username ``otrs`` is created for OTRS and it is installed to ``/opt/otrs``. If you use different user or install location, you need to change the install command. For more information about the command line tool execute this command:

   .. code-block:: bash

      otrs> /opt/otrs/bin/otrs.Console.pl Search 'Admin::Package'

   Then execute the needed command with ``--help`` option to see its possibilities.


Requirements
------------

- OTRS Framework 7.0.x
- :doc:`../itsm-configuration-management` or any other package that provides back end for objects to be imported and exported


Install
-------

Install Via Administrator Interface
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

To install this package from the package manager:

1. Open the *Package Manager* module in the administrator interface.
2. Click on the *Browse…* button in the left sidebar.
3. Select an ``.opm`` file from your local file system.
4. Click on the *Install Package* button.
5. Follow the installation instructions.
6. After installation, the package is displayed in the *Local Repository* widget.


Install Via Command Line
~~~~~~~~~~~~~~~~~~~~~~~~

To install this package from the command line:

1. Save the ``.opm`` file to a folder where ``otrs`` user has read permission.
2. Execute this command:

   .. code-block:: bash

      otrs> /opt/otrs/bin/otrs.Console.pl Admin::Package::Install /path/to/Package-x.y.z.opm


Update
------

Update Via Administrator Interface
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

To update this package from the package manager:

1. Open the *Package Manager* module in the administrator interface.
2. Click on the *Browse…* button in the left sidebar.
3. Select an ``.opm`` file which is newer than the installed package.
4. Click on the *Install Package* button.
5. Follow the update instructions.
6. After updating, the package is displayed in the *Local Repository* widget.


Update Via Command Line
~~~~~~~~~~~~~~~~~~~~~~~

To update this package from the command line:

1. Save the ``.opm`` file to a folder where ``otrs`` user has read permission.
2. Execute this command:

   .. code-block:: bash

      otrs> /opt/otrs/bin/otrs.Console.pl Admin::Package::Upgrade /path/to/Package-x.y.z.opm


Uninstall
---------

.. warning::

   If you uninstall this package, all database tables that were created during installation will be deleted. All data from these tables **will be irrevocably lost**! 


Uninstall Via Administrator Interface
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

To uninstall this package from the package manager:

1. Open the *Package Manager* module in the administrator interface.
2. Select the package from the *Local Repository* widget.
3. Click on the *Uninstall* link in the *Action* column.
4. Follow the uninstall instructions.


Uninstall Via Command Line
~~~~~~~~~~~~~~~~~~~~~~~~~~

To uninstall this package from the command line:

1. Execute this command:

   .. code-block:: bash

      otrs> /opt/otrs/bin/otrs.Console.pl Admin::Package::Uninstall PACKAGE_NAME
