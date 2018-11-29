OTRS Scheduler
==============

The OTRS scheduler is a conjunction of daemon modules and task workers that runs together in order to perform all needed OTRS tasks asynchronously from the web server process.


OTRS Scheduler Task Managers
----------------------------

``SchedulerCronTaskManager``
   This reads registered cron tasks from the OTRS system configuration and determines the correct time to create a task to be executed.

``SchedulerFutureTaskManager``
   This checks the tasks that are set to be executed just one time in the future and sets this task to be executed in time. For example, when a generic interface invoker can not reach the remote server, it can self schedule to be run again 5 minutes later.

``SchedulerGenericAgentTaskManager``
   This continuously reads the generic agent tasks that are set to be run on regular time basis and sets their execution accordingly.

Whenever these tasks managers are not enough, a new daemon module can be created. At a certain point of its ``Run()`` method it needs to call ``TaskAdd()`` from the ``chedulerDB`` object to register a task, and as soon as it is registered, it will be executed in the next free slot by the ``SchedulerTaskWorker``.


OTRS Scheduler Task Workers
---------------------------

``SchedulerTaskWorker``
   This executes all tasks planned by the previous tasks managers plus the ones that come directly from the code by using the asynchronous executor.

In order to execute each task, the ``SchedulerTaskWorker`` calls a backend module (task worker) to perform the specific task. The worker module is determined by the task type. If a new task type is added, it will require a new task worker.


Creating A New Scheduler Task Worker
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

All files placed under ``Kernel/System/Daemon/DaemonModules/SchedulerTaskWorker`` could potentially be task workers and they do not require any registration in the system configuration.


Scheduler Task Worker Code Example
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. code-block:: Perl

   # --
   # Copyright (C) 2001-2018 OTRS AG, https://otrs.com/
   # --
   # This software comes with ABSOLUTELY NO WARRANTY. For details, see
   # the enclosed file COPYING for license information (GPL). If you
   # did not receive this file, see https://www.gnu.org/licenses/gpl-3.0.txt.
   # --

   package Kernel::System::Daemon::DaemonModules::SchedulerTaskWorker::TestWorker;

   use strict;
   use warnings;

   use parent qw(Kernel::System::Daemon::DaemonModules::BaseTaskWorker);

   our @ObjectDependencies = (
       'Kernel::System::Log',
   );

This is common header that can be found in most OTRS modules. The class/package name is declared via the ``package`` keyword.

In this case we are inheriting from ``BaseTaskWorker`` class, and the object manager dependencies are set.

.. code-block:: Perl

   sub new {
       my ( $Type, %Param ) = @_;

       my $Self = {};
       bless( $Self, $Type );

       $Self->{Debug}      = $Param{Debug};
       $Self->{WorkerName} = 'Worker: Test';

       return $Self;
   }

The constructor ``new`` creates a new instance of the class.

.. code-block:: Perl

   sub Run {
       my ( $Self, %Param ) = @_;

       # Check task params.
       my $CheckResult = $Self->_CheckTaskParams(
           %Param,
           NeededDataAttributes => [ 'NeededAtrribute1', 'NeededAtrribute2' ],
           DataParamsRef        => 'HASH', # or 'ARRAT'
       );

       # Stop execution if an error in params is detected.
       return if !$CheckResult;

       my $Success;
       my $ErrorMessage;

       if ( $Self->{Debug} ) {
           print "    $Self->{WorkerName} executes task: $Param{TaskName}\n";
       }

       do {

           # Localize the standard error.
           local *STDERR;

           # Redirect the standard error to a variable.
           open STDERR, ">>", \$ErrorMessage;

           $Success = $Kernel::OM->Get('Kernel::System::MyPackage')->Run(
               Param1 => 'someparam',
           );
       };

       if ( !$Success ) {

           $ErrorMessage ||= "$Param{TaskName} execution failed without an error message!";

           $Self->_HandleError(
               TaskName     => $Param{TaskName},
               TaskType     => 'Test',
               LogMessage   => "There was an error executing $Param{TaskName}: $ErrorMessage",
               ErrorMessage => "$ErrorMessage",
           );
       }

       return $Success;
   }

The ``Run`` is the main method. A call to ``_CheckTaskParams()`` from the base class will save some lines of code. Executing the task while capturing the STDERR is a very good practice, since the OTRS scheduler runs normally unattended, and saving all errors to a variable will make it available for further processing. ``_HandleError()`` provides a common interface to send the error messages as email to the recipient specified in the system configuration.

.. code-block:: Perl

   1;

End of file.
