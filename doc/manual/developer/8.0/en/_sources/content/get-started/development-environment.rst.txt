Development Environment
=======================

To facilitate the writing of OTRS expansion modules, the creation of a development environment is necessary. The source code of OTRS and additional public modules can be found on `github <http://otrs.github.io>`__.


Framework checkout
------------------

First of all a directory must be created in which the modules can be stored. Then switch to the new directory using the command line and check them out by using the following command:

::

   # for git master
   shell> git clone git@github.com:OTRS/otrs.git -b master
   # for a specific branch like OTRS 3.3
   shell> git clone git@github.com:OTRS/otrs.git -b rel-3_3
               

Check out the ``module-tools`` module (from github) too, for your development
environment. It contains a number of useful tools:

::

   shell> git clone git@github.com:OTRS/module-tools.git
               

Please configure the OTRS system according to the `installation instructions <http://doc.otrs.com/doc/manual/installation/stable/en/index.html>`__.


Useful Tools
------------

There are two modules that are highly recommended for OTRS development:

- `OTRSCodePolicy <https://github.com/OTRS/otrscodepolicy>`__
- `Fred <https://github.com/OTRS/Fred>`__

*OTRSCodePolicy* is a code quality checker that enforces the use of common coding standards also for the OTRS development team. It is highly recommended to use it if you plan to make contributions. You can use it as a standalone test script or even register it as a git commit hook that runs every time that you create a commit. Please see `the module documentation <https://github.com/OTRS/otrscodepolicy/blob/master/doc/en/OTRSCodePolicy.xml>`__ for details.

*Fred* is a little development helper module that you can actually install or link (as described below) into your development system. It features several helpful modules that you can activate, such as an SQL logger or an STDERR console. You can find some more details in its `module documentation <https://github.com/OTRS/Fred/blob/master/doc/en/Fred.xml>`__.

By the way, these tools are also open source, and we will be happy about any improvements that you can contribute.


Linking Expansion Modules
-------------------------

A clear separation between OTRS and the modules is necessary for proper developing. Particularly when using a git clone, a clear separation is crucial. In order to facilitate the OTRS access the files, links must be created. This is done by a script in the directory module tools repository.

Example: linking the *Calendar* module:

::

   shell> ~/src/module-tools/link.pl ~/src/Calendar/ ~/src/otrs/
               

Whenever new files are added, they must be linked as described above.

As soon as the linking is completed, the system configuration must be rebuilt to register the module in OTRS. Additional SQL or Perl code from the module must also be executed.

Example:

::

   shell> ~/src/otrs/bin/otrs.Console.pl Maint::Config::Rebuild
   shell> ~/src/module-tools/DatabaseInstall.pl -m Calendar.sopm -a install
   shell> ~/src/module-tools/CodeInstall.pl -m Calendar.sopm -a install
               

To remove links from OTRS enter the following command:

::

   shell> ~/src/module-tools/remove_links.pl ~/src/otrs/
               
