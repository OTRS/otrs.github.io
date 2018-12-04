Package Management
==================

The OPM (OTRS Package Manager) is a mechanism to distribute software packages for the OTRS framework via HTTP, FTP or file upload.

For example, the OTRS project offers OTRS modules like a calendar, a file manager or web mail in OTRS packages via online repositories on our FTP servers. The packages can be managed (install, upgrade and uninstall) via the admin interface.


Package Distribution
--------------------

If you want to create an OPM online repository, just tell the OTRS framework where the location is by activating the system configuration setting ``Package::RepositoryList`` and adding the new location there. Then you will have a new select option in the package manager.

In your repository, create an index file for your OPM packages. OTRS just reads this index file and knows what packages are available.

::

   shell> bin/otrs.Console.pl Dev::Package::RepositoryIndex /path/to/repository/ > /path/to/repository/otrs.xml


Package Commands
----------------

You can use the following OPM commands over the admin interface or over ``bin/otrs.Console.pl`` to manage admin jobs for OPM packages.


Install
~~~~~~~

Install OPM packages.

-  Web: http://localhost/otrs/index.pl?Action=AdminPackageManager

-  CMD: ``bin/otrs.Console.pl Admin::Package::Install /path/to/package.opm``


Uninstall
~~~~~~~~~

Uninstall OPM packages.

-  Web: http://localhost/otrs/index.pl?Action=AdminPackageManager

-  CMD: ``bin/otrs.Console.pl Admin::Package::Uninstall /path/to/package.opm``


Upgrade
~~~~~~~

Upgrade OPM packages.

-  Web: http://localhost/otrs/index.pl?Action=AdminPackageManager

-  CMD: ``bin/otrs.Console.pl Admin::Package::Upgrade /path/to/package.opm``


List
~~~~

List all OPM packages.

-  Web: http://localhost/otrs/index.pl?Action=AdminPackageManager

-  CMD: ``bin/otrs.Console.pl Admin::Package::List``
