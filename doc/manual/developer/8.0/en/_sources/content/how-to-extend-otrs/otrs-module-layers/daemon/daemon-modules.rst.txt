OTRS Daemon
===========

The OTRS daemon is a separated process that helps OTRS to execute certain actions asynchronously and detached of the web server process, but sharing the same database.


OTRS Daemon Modules
-------------------

The OTRS daemon ``bin/otrs.Daemon.pl`` main purpose is to call (daemonize) all the registered daemon modules in the system configuration.

Each daemon module must implement a common API in order to be correctly called by the OTRS daemon and be a semi persistent process in the system. Persistent process could grow in size and memory usage over the time and normally they do not respond to changes in the configuration. That is why the daemon modules should implement a discard mechanism to be stopped and re-spawned again from time to time, freeing system resources and re-reading the configuration.

A daemon module could be an all-in-one solution to perform a certain job, but there could be the case that a solution requires different daemon modules due to its complexity. That is exactly the case of the OTRS scheduler daemon that is split into several daemon modules including some daemon modules for task management and task execution.

It is not always necessary to create a new daemon module to perform certain task, usually the OTRS scheduler daemon can deal with the majority of them, either if it is an OTRS function that needs to be executed on a regular basis (CRON like) or if it's triggered by an OTRS event, the OTRS scheduler should be capable to deal with it out of the box or by adding a new scheduler task worker module.


Creating A New Daemon Module
~~~~~~~~~~~~~~~~~~~~~~~~~~~~

All daemon modules requires to be registered in the system configuration in order to be called by the main OTRS daemon.


Daemon Module Registration Code Example
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. code-block:: XML

   <Setting Name="DaemonModules###TestDaemon" Required="1" Valid="1">
       <Description Translatable="1">The daemon registration for the scheduler generic agent task manager.</Description>
       <Navigation>Daemon::ModuleRegistration</Navigation>
       <Value>
           <Hash>
               <Item Key="Module">Kernel::System::Daemon::DaemonModules::TestDaemon</Item>
           </Hash>
       </Value>
   </Setting>


Daemon Module Code Example
^^^^^^^^^^^^^^^^^^^^^^^^^^

The following code implements a daemon module that displays the system time every 2 seconds.

.. code-block:: Perl

   # --
   # Copyright (C) 2001-2018 OTRS AG, https://otrs.com/
   # --
   # This software comes with ABSOLUTELY NO WARRANTY. For details, see
   # the enclosed file COPYING for license information (GPL). If you
   # did not receive this file, see https://www.gnu.org/licenses/gpl-3.0.txt.
   # --

   package Kernel::System::Daemon::DaemonModules::TestDaemon;

   use strict;
   use warnings;
   use utf8;

   use Kernel::System::VariableCheck qw(:all);

   use parent qw(Kernel::System::Daemon::BaseDaemon);

   our @ObjectDependencies = (
       'Kernel::Config',
       'Kernel::System::Cache',
       'Kernel::System::DB',
   );

This is common header that can be found in most OTRS modules. The class/package name is declared via the ``package`` keyword.

In this case we are inheriting from ``BaseDaemon`` class, and the object manager dependencies are set.

.. code-block:: Perl

   sub new {
       my ( $Type, %Param ) = @_;

       # Allocate new hash for object.
       my $Self = {};
       bless $Self, $Type;

       # Get objects in constructor to save performance.
       $Self->{ConfigObject} = $Kernel::OM->Get('Kernel::Config');
       $Self->{CacheObject}  = $Kernel::OM->Get('Kernel::System::Cache');
       $Self->{DBObject}     = $Kernel::OM->Get('Kernel::System::DB');

       # Disable in memory cache to be clusterable.
       $Self->{CacheObject}->Configure(
           CacheInMemory  => 0,
           CacheInBackend => 1,
       );

       $Self->{SleepPost} = 2;          # sleep 2 seconds after each loop
       $Self->{Discard}   = 60 * 60;    # discard every hour

       $Self->{DiscardCount} = $Self->{Discard} / $Self->{SleepPost};

       $Self->{Debug}      = $Param{Debug};
       $Self->{DaemonName} = 'Daemon: TestDaemon';

       return $Self;
   }

The constructor ``new`` creates a new instance of the class. Some used objects are also created here. It is highly recommended to disable in-memory cache in daemon modules especially if OTRS runs in a cluster environment.

In order to make this daemon module to be executed every two seconds it is necessary to define a sleep time accordingly, otherwise it will be executed as soon as possible.

Refreshing the daemon module from time to time is necessary in order to define when it should be discarded.

For the following functions (``PreRun``, ``Run`` and ``PostRun``) if they return false, the main OTRS daemon will discard the object and create a new one as soon as possible.

.. code-block:: Perl

   sub PreRun {
       my ( $Self, %Param ) = @_;

       # Check if database is on-line.
       return 1 if $Self->{DBObject}->Ping();

       sleep 10;

       return;
   }

The ``PreRun`` method is executed before the main daemon module method, and the its purpose is to perform some test before the real operation. In this case a check to the database is done (always recommended), otherwise it sleeps for 10 seconds. This is needed in order to wait for DB connection to be reestablished.

.. code-block:: Perl

   sub Run {
       my ( $Self, %Param ) = @_;

       print "Current time " . localtime . "\n";

       return 1;
   }

The ``Run`` method is where the main daemon module code resides, in this case it only prints the current time.

.. code-block:: Perl

   sub PostRun {
       my ( $Self, %Param ) = @_;
       sleep $Self->{SleepPost};
       $Self->{DiscardCount}--;

       if ( $Self->{Debug} ) {
           print "  $Self->{DaemonName} Discard Count: $Self->{DiscardCount}\n";
       }

       return if $Self->{DiscardCount} <= 0;

       return 1;
   }

The ``PostRun`` method is used to perform the sleeps (preventing the daemon module to be executed too often) and also to manage the safe discarding of the object. Other operations like verification or cleanup can be done here.

.. code-block:: Perl

   sub Summary {
       my ( $Self, %Param ) = @_;

       my %Summary = (
           Header => 'Test Daemon Summary:',
           Column => [
               {
                   Name        => 'SomeColumn',
                   DisplayName => 'Some Column',
                   Size        => 15,
               },
               {
                   Name        => 'AnotherColumn',
                   DisplayName => 'Another Column',
                   Size        => 15,
               },
               # ...
           ],
           Data => [
               {
                   SomeColumn    => 'Some Data 1',
                   AnotherColumn => 'Another Data 1',
               },
               {
                   SomeColumn    => 'Some Data 2',
                   AnotherColumn => 'Another Data 2',
               },
               # ...
           ],
           NoDataMesssage => '',
       );

       return \%Summary;
   }

The ``Summary`` method is called by the console command ``Maint::Daemon::Summary`` and it's required to return ``Header``, ``Column``, ``Data`` and ``NoDataMessages`` keys. ``Column`` and ``Data`` needs to be an array of hashes. It is used to display useful information of what the daemon module is currently doing, or what has been done so far. This method is optional.

.. code-block:: Perl

   1;

End of file.
