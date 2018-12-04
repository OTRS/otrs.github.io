Package Building
================

If you want to create an OPM package (``.opm``) you need to create a spec file (``.sopm``) which includes the properties of the package.


Package Spec File
-----------------

The OPM package is XML based. You can create/edit the ``.sopm`` via a text or XML editor. It contains meta data, a file list and database options.

``<Name>`` \*
   The package name.

   .. code-block:: XML

      <Name>Calendar</Name>

``<Version>`` \*
   The package version.

   .. code-block:: XML

      <Version>1.2.3</Version>

``<Framework>`` \*
   The targeted framework version (7.0.x means e.g. 7.0.1 or 7.0.2).

   .. code-block:: XML

      <Framework>7.0.x</Framework>
                   
   Can also be used several times.

   .. code-block:: XML

      <Framework>5.0.x</Framework>
      <Framework>6.0.x</Framework>
      <Framework>7.0.x</Framework>

``<Vendor>`` \*
   The package vendor.

   .. code-block:: XML

      <Vendor>OTRS AG</Vendor>

``<URL>`` \*
   The vendor URL.

   .. code-block:: XML

      <URL>https://otrs.com/</URL>

``<License>`` \*
   The license of the package.

   .. code-block:: XML

      <License>GNU GENERAL PUBLIC LICENSE Version 3, 29 June 2007</License>

``<ChangeLog>``
   The package change log.

   .. code-block:: XML

      <ChangeLog Version="1.1.2" Date="2018-11-15 18:45:21">Added some feature.</ChangeLog>
      <ChangeLog Version="1.1.1" Date="2018-11-15 16:17:51">New package.</ChangeLog>

``<Description>`` \*
   The package description in different languages.

   .. code-block:: XML

      <Description Lang="en">A web calendar.</Description>
      <Description Lang="de">Ein Web Kalender.</Description>

Package Actions
   The possible actions for the package after installation. If one of these actions is not defined on the package, it will be considered as possible.

   .. code-block:: XML

      <PackageIsVisible>1</PackageIsVisible>
      <PackageIsDownloadable>0</PackageIsDownloadable>
      <PackageIsRemovable>1</PackageIsRemovable>

   A special package action is ``PackageAllowDirectUpdate``. Only if it is defined on the package and set to true, a package can be upgraded from a lower major version (earlier than the last one) to the latest version. (e.g. a package for OTRS 5 updated to OTRS 7).

   .. code-block:: XML

      <PackageAllowDirectUpdate>1</PackageAllowDirectUpdate>

``<BuildHost>``
   This will be filled in automatically by OPM.

   .. code-block:: XML

      <BuildHost>?</BuildHost>

``<BuildDate>``
   This will be filled in automatically by OPM.

   .. code-block:: XML

      <BuildDate>?</BuildDate>

``<PackageRequired>``
   Packages that must be installed beforehand. If ``PackageRequired`` is used, a version of the required package must be specified.

   .. code-block:: XML

      <PackageRequired Version="1.0.3">SomeOtherPackage</PackageRequired>
      <PackageRequired Version="5.3.2">SomeotherPackage2</PackageRequired>

``<ModuleRequired>``
   Perl modules that must be installed beforehand.

   .. code-block:: XML

      <ModuleRequired Version="1.03">Encode</ModuleRequired>
      <ModuleRequired Version="5.32">MIME::Tools</ModuleRequired>

``<OS>``
   Required OS.

   .. code-block:: XML

      <OS>linux</OS>
      <OS>darwin</OS>
      <OS>mswin32</OS>

``<Filelist>``
   This is a list of files included in the package.

   .. code-block:: XML

      <Filelist>
          <File Permission="644" Location="Kernel/Config/Files/Calendar.pm"/>
          <File Permission="644" Location="Kernel/System/CalendarEvent.pm"/>
          <File Permission="644" Location="Kernel/Modules/AgentCalendar.pm"/>
          <File Permission="644" Location="Kernel/Language/de_AgentCalendar.pm"/>
      </Filelist>

``<DatabaseInstall>``
   Database entries that have to be created when a package is installed.

   .. code-block:: XML

      <DatabaseInstall>
          <TableCreate Name="calendar_event">
          <Column Name="id" Required="true" PrimaryKey="true" AutoIncrement="true" Type="BIGINT"/>
          <Column Name="title" Required="true" Size="250" Type="VARCHAR"/>
          <Column Name="content" Required="false" Size="250" Type="VARCHAR"/>
          <Column Name="start_time" Required="true" Type="DATE"/>
          <Column Name="end_time" Required="true" Type="DATE"/>
          <Column Name="owner_id" Required="true" Type="INTEGER"/>
          <Column Name="event_status" Required="true" Size="50" Type="VARCHAR"/>
          </TableCreate>
      </DatabaseInstall>

   You also can choose ``<DatabaseInstall Type="post">`` or ``<DatabaseInstall Type="pre">`` to define the time of execution separately (``post`` is default). For more info see :ref:`Package Life Cycle`.

``<DatabaseUpgrade>``
   Information on which actions have to be performed in case of an upgrade.

   Example if already installed package version is below 1.3.4 (e. g. 1.2.6), the defined action will be performed:

   .. code-block:: XML

      <DatabaseUpgrade>
          <TableCreate Name="calendar_event_involved" Version="1.3.4">
              <Column Name="event_id" Required="true" Type="BIGINT"/>
              <Column Name="user_id" Required="true" Type="INTEGER"/>
          </TableCreate>
      </DatabaseUpgrade>

   You also can choose ``<DatabaseUpgrade Type="post">`` or ``<DatabaseUpgrade Type="pre">`` to define the time of execution separately (``post`` is default). For more info see :ref:`Package Life Cycle`.

``<DatabaseReinstall>``
   Information on which actions have to be performed if the package is reinstalled.

   .. code-block:: XML

      <DatabaseReinstall></DatabaseReinstall>

   You also can choose ``<DatabaseReinstall Type="post">`` or ``<DatabaseReinstall Type="pre">`` to define the time of execution separately (``post`` is default). For more info see :ref:`Package Life Cycle`.

``<DatabaseUninstall>``
   Actions to be performed on package uninstall.

   .. code-block:: XML

      <DatabaseUninstall>
          <TableDrop Name="calendar_event" />
      </DatabaseUninstall>

   You also can choose ``<DatabaseUninstall Type="post">`` or ``<DatabaseUninstall Type="pre">`` to define the time of execution separately (``post`` is default). For more info see :ref:`Package Life Cycle`.

``<IntroInstall>``
   To show a pre or post install introduction in installation dialog.

   .. code-block:: XML

      <IntroInstall Type="post" Lang="en" Title="Some Title"><![CDATA[
          Some information formatted in HTML.
      ]]></IntroInstall>

   You can also use the ``Format`` attribute to define if you want to use ``html`` (which is default) or ``plain`` to use automatically a ``<pre></pre>`` tag when intro is shown (to keep the newlines and whitespace of the content).


``<IntroUninstall>``
   To show a pre or post uninstall introduction in uninstallation dialog.

   .. code-block:: XML

      <IntroUninstall Type="post" Lang="en" Title="Some Title"><![CDATA[
          Some information formatted in HTML.
      ]]></IntroUninstall>

   You can also use the ``Format`` attribute to define if you want to use ``html`` (which is default) or ``plain`` to use automatically a ``<pre></pre>`` tag when intro is shown (to keep the newlines and whitespace of the content).

``<IntroReinstall>``
   To show a pre or post reinstall introduction in re-installation dialog.

   .. code-block:: XML

      <IntroReinstall Type="post" Lang="en" Title="Some Title"><![CDATA[
          Some information formatted in HTML.
      ]]></IntroReinstall>

   You can also use the ``Format`` attribute to define if you want to use ``html`` (which is default) or ``plain`` to use automatically a ``<pre></pre>`` tag when intro is shown (to keep the newlines and whitespace of the content).

``<IntroUpgrade>``
   To show a pre or post upgrade introduction in upgrading dialog.

   .. code-block:: XML

      <IntroUpgrade Type="post" Lang="en" Title="Some Title"><![CDATA[
          Some information formatted in HTML.
      ]]></IntroUpgrade>

   You can also use the ``Format`` attribute to define if you want to use ``html`` (which is default) or ``plain`` to use automatically a ``<pre></pre>`` tag when intro is shown (to keep the newlines and whitespace of the content).

``<CodeInstall>``
   Perl code to be executed when the package is installed.

   .. code-block:: XML

      <CodeInstall><![CDATA[
      # log example
      $Kernel::OM->Get('Kernel::System::Log')->Log(
          Priority => 'notice',
          Message => "Some Message!",
      );
      # database example
      $Kernel::OM->Get('Kernel::System::DB')->Do(SQL => "SOME SQL");
      ]]></CodeInstall>

You also can choose ``<CodeInstall Type="post">`` or ``<CodeInstall Type="pre">`` to define the time of execution separately (``post`` is default). For more info see :ref:`Package Life Cycle`.

``<CodeUninstall>``
   Perl code to be executed when the package is uninstalled. On pre or post time of package uninstallation.

   .. code-block:: XML

      <CodeUninstall><![CDATA[
      # Some Perl code.
      ]]></CodeUninstall>

   You also can choose ``<CodeUninstall Type="post">`` or ``<CodeUninstall Type="pre">`` to define the time of execution separately (``post`` is default). For more info see :ref:`Package Life Cycle`.

``<CodeReinstall>``
   Perl code to be executed when the package is reinstalled.

   .. code-block:: XML

      <CodeReinstall><![CDATA[
      # Some Perl code.
      ]]></CodeReinstall>

   You also can choose ``<CodeReinstall Type="post">`` or ``<CodeReinstall Type="pre">`` to define the time of execution separately (``post`` is default). For more info see :ref:`Package Life Cycle`.

``<CodeUpgrade>``
   Perl code to be executed when the package is upgraded (subject to ``version`` tag).

   Example if already installed package version is below 1.3.4 (e. g. 1.2.6), defined action will be performed:

   .. code-block:: XML

      <CodeUpgrade Version="1.3.4"><![CDATA[
      # Some Perl code.
      ]]></CodeUpgrade>

   You also can choose ``<CodeUpgrade Type="post">`` or ``<CodeUpgrade Type="pre">`` to define the time of execution separately (``post`` is default). For more info see :ref:`Package Life Cycle`.

``<PackageMerge>``
   This tag singals that a package has been merged into another package. In this case the original package needs to be removed from the file system and the packages database, but all data must be kept.

   Let's assume that ``PackageOne`` was merged into ``PackageTwo``. Then ``PackageTwo.sopm`` should contain this:

   .. code-block:: XML

      <PackageMerge Name="MergeOne" TargetVersion="2.0.0"></PackageMerge>

   If ``PackageOne`` also contained database structures, we need to be sure that it was at the latest available version of the package to have a consistent state in the database after merging the package. The attribute ``TargetVersion`` does just this: it signifies the last known version of ``PackageOne`` at the time ``PackageTwo`` was created. This is mainly to stop the upgrade process if in the user's system a version of ``PackageOne`` was found that is *newer* than the one specified in ``TargetVersion`` as this could lead to problems.

   Additionally it is possible to add required database and code upgrade tags for ``PackageOne`` to make sure that it gets properly upgraded to the ``TargetVersion`` *before* merging it - to avoid inconsistency problems. Here's how this could look like:

   .. code-block:: XML

      <PackageMerge Name="MergeOne" TargetVersion="2.0.0">
          <DatabaseUpgrade Type="merge">
              <TableCreate Name="merge_package">
                  <Column Name="id" Required="true" PrimaryKey="true" AutoIncrement="true" Type="INTEGER"/>
                  <Column Name="description" Required="true" Size="200" Type="VARCHAR"/>
              </TableCreate>
          </DatabaseUpgrade>
      </PackageMerge>

   As you can see the attribute ``Type="merge"`` needs to be set in this case. These sections will only be executed if a package merge is possible.

.. _package-conditions-ifpackage-ifnotpackage:

Package Conditions
   ``IfPackage`` and ``IfNotPackage`` attributes can be added to the regular ``Database*`` and ``Code*`` sections. If they are present, the section will only be executed if another package is or is not in the local package repository.

   .. code-block:: XML

      <DatabaseInstall IfPackage="AnyPackage">
          # ...
      </DatabaseInstall>

   or

   .. code-block:: XML

      <CodeUpgrade IfNotPackage="OtherPackage">
          # ...
      </CodeUpgrade>

   These attributes can be also set in the ``Database*`` and ``Code*`` sections inside the ``PackageMerge`` tags.


Example .sopm
-------------

This is an example spec file looks with some of the above tags.

.. code-block:: XML

   <?xml version="1.0" encoding="utf-8" ?>
   <otrs_package version="1.0">
       <Name>Calendar</Name>
       <Version>0.0.1</Version>
       <Framework>7.0.x</Framework>
       <Vendor>OTRS AG</Vendor>
       <URL>https://otrs.com/</URL>
       <License>GNU GENERAL PUBLIC LICENSE Version 3, 29 June 2007</License>
       <ChangeLog Version="1.1.2" Date="2018-11-15 18:45:21">Added some feature.</ChangeLog>
       <ChangeLog Version="1.1.1" Date="2018-11-15 16:17:51">New package.</ChangeLog>
       <Description Lang="en">A web calendar.</Description>
       <Description Lang="de">Ein Web Kalender.</Description>
       <IntroInstall Type="post" Lang="en" Title="Thank you!">Thank you for choosing the Calendar module.</IntroInstall>
       <IntroInstall Type="post" Lang="de" Title="Vielen Dank!">Vielen Dank fuer die Auswahl des Kalender Modules.</IntroInstall>
       <BuildDate>?</BuildDate>
       <BuildHost>?</BuildHost>
       <Filelist>
           <File Permission="644" Location="Kernel/Config/Files/Calendar.pm"></File>
           <File Permission="644" Location="Kernel/System/CalendarEvent.pm"></File>
           <File Permission="644" Location="Kernel/Modules/AgentCalendar.pm"></File>
           <File Permission="644" Location="Kernel/Language/de_AgentCalendar.pm"></File>
           <File Permission="644" Location="Kernel/Output/HTML/Standard/AgentCalendar.tt"></File>
           <File Permission="644" Location="Kernel/Output/HTML/NotificationCalendar.pm"></File>
           <File Permission="644" Location="var/httpd/htdocs/images/Standard/calendar.png"></File>
       </Filelist>
       <DatabaseInstall>
           <TableCreate Name="calendar_event">
               <Column Name="id" Required="true" PrimaryKey="true" AutoIncrement="true" Type="BIGINT"/>
               <Column Name="title" Required="true" Size="250" Type="VARCHAR"/>
               <Column Name="content" Required="false" Size="250" Type="VARCHAR"/>
               <Column Name="start_time" Required="true" Type="DATE"/>
               <Column Name="end_time" Required="true" Type="DATE"/>
               <Column Name="owner_id" Required="true" Type="INTEGER"/>
               <Column Name="event_status" Required="true" Size="50" Type="VARCHAR"/>
           </TableCreate>
       </DatabaseInstall>
       <DatabaseUninstall>
           <TableDrop Name="calendar_event"/>
       </DatabaseUninstall>
   </otrs_package>


Package Build
-------------

To build an .opm package from the spec opm.

::

   shell> bin/otrs.Console.pl Dev::Package::Build /path/to/example.sopm /tmp
   Building package...
   Done.
   shell>


Package Life Cycle
------------------

The following image shows you how the life cycle of a package installation, upgrade and uninstallation works in the backend step by step.

.. figure:: images/package-life-cycle.png
   :alt: Package Life Cycle

   Package Life Cycle
