Package Manager
===============

Modular systems can be extended by adding additional software packages to the framework. Administrators need an easy way to see which features are installed in which version and for sure to add, update and remove packages.

OTRS uses the package manager to perform all package-related activities as mentioned above in the graphical interface.

.. note::

	This module is only available when using On-Pemise or the ((otrs)) Community Edition. To see a list of installed modules, you may also see the :doc:`../otrs-group-services/support-data-collector`

Use this screen to install and manage packages that extend the functionality of OTRS. The package manager screen is available in the *Package Manager* module of the *Administration* group.

.. figure:: images/package-manager.png
   :alt: Package Manager Screen

   Package Manager Screen


Manage Packages
---------------

.. warning::

   The installation of packages which are not verified by the OTRS Group is not possible by default.

.. seealso::

   You can activate the installation of not verified packages in the system configuration setting :sysconfig:`Package::AllowNotVerifiedPackages <core.html#package-allownotverifiedpackages>`.


Install Packages
~~~~~~~~~~~~~~~~

To install a package from online repository:

1. Select an online repository from the dropdown in the left sidebar.
2. Click on the *Update repository information* button to refresh the available package list.
3. Select a package from the *Online Repository* widget and click on the *Install* in the last column.
4. Follow the installation instructions.
5. After installation, the package is displayed in the *Local Repository* widget.

.. figure:: images/package-manager-online-repository.png
   :alt: Online Repository Widget

   Online Repository Widget

.. seealso::

   The repository list can be changed in system configuration setting :sysconfig:`Package::RepositoryList <core.html#package-repositorylist>`.

To install a package from file:

1. Click on the *Browse…* button in the left sidebar.
2. Select an ``.opm`` file from your local file system.
3. Click on the *Install Package* button.
4. Follow the installation instructions.
5. After installation, the package is displayed in the *Local Repository* widget.

.. figure:: images/package-manager-local-repository.png
   :alt: Local Repository Widget

   Local Repository Widget


Update Packages
~~~~~~~~~~~~~~~

To update a package from online repository:

1. Check the available packages in the *Online Repository* widget if there is *Update* in the *Action* column.
2. Click on the *Update* link.
3. Follow the update instructions.
4. After updating, the package is displayed in the *Local Repository* widget.

To update a package from file:

1. Click on the *Browse…* button in the left sidebar.
2. Select an ``.opm`` file which is newer than the installed package.
3. Click on the *Install Package* button.
4. Follow the update instructions.
5. After updating, the package is displayed in the *Local Repository* widget.

To update all packages:

1. Click on the *Update all installed packages* button in the left sidebar.
2. Follow the update instructions.
3. After updating, the package is displayed in the *Local Repository* widget.

This feature reads the information of all defined package repositories and determines if there is a new version for every installed package in the system and calculates the correct order to update the packages respecting all other package dependencies, even if new versions of existing packages require new packages not yet installed in the system.

.. note::

   If there are packages installed that do not have a corresponding repository defined in the system, they can not be updated by this feature and will be marked as failed (due to the missing on-line repository).


Reinstall Packages
~~~~~~~~~~~~~~~~~~

If at least one of the package files are modified locally, the package manager marks the package as broken, and need to reinstall.

To reinstall a package:

1. Select the package from the *Local Repository* widget that are marked for reinstall.
2. Click on the *Reinstall* link in the *Action* column.
3. Follow the installation instructions.


Uninstall Packages
~~~~~~~~~~~~~~~~~~

To uninstall a package:

1. Select the package from the *Local Repository* widget.
2. Click on the *Uninstall* link in the *Action* column.
3. Follow the uninstall instructions.

.. figure:: images/package-manager-local-repository.png
   :alt: Local Repository Widget

   Local Repository Widget
