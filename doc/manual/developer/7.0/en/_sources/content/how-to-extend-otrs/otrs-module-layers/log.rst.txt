Log Module
==========

There is a global log interface for OTRS that provides the possibility to create own log backends.

Writing an own logging backend is as easy as reimplementing the ``Kernel::System::Log::Log()`` method.


Log Module Code Example
-----------------------

In this small example, we'll write a little file logging backend which works similar to ``Kernel::System::Log::File``, but prepends a string to each logging entry.

.. code-block:: Perl

   # --
   # Kernel/System/Log/CustomFile.pm - file log backend
   # Copyright (C) 2001-2018 OTRS AG, https://otrs.com/
   # --
   # This software comes with ABSOLUTELY NO WARRANTY. For details, see
   # the enclosed file COPYING for license information (GPL). If you
   # did not receive this file, see https://www.gnu.org/licenses/gpl-3.0.txt.
   # --

   package Kernel::System::Log::CustomFile;

   use strict;
   use warnings;

   umask "002";

   sub new {
       my ( $Type, %Param ) = @_;

       # allocate new hash for object
       my $Self = {};
       bless( $Self, $Type );

       # get needed objects
       for (qw(ConfigObject EncodeObject)) {
           if ( $Param{$_} ) {
               $Self->{$_} = $Param{$_};
           }
           else {
               die "Got no $_!";
           }
       }

       # get logfile location
       $Self->{LogFile} = '/var/log/CustomFile.log';

       # set custom prefix
       $Self->{CustomPrefix} = 'CustomFileExample';

       # Fixed bug# 2265 - For IIS we need to create a own error log file.
       # Bind stderr to log file, because IIS do print stderr to web page.
       if ( $ENV{SERVER_SOFTWARE} && $ENV{SERVER_SOFTWARE} =~ /^microsoft\-iis/i ) {
           if ( !open STDERR, '>>', $Self->{LogFile} . '.error' ) {
               print STDERR "ERROR: Can't write $Self->{LogFile}.error: $!";
           }
       }

       return $Self;
   }

   sub Log {
       my ( $Self, %Param ) = @_;

       my $FH;

       # open logfile
       if ( !open $FH, '>>', $Self->{LogFile} ) {

           # print error screen
           print STDERR "\n";
           print STDERR " >> Can't write $Self->{LogFile}: $! <<\n";
           print STDERR "\n";
           return;
       }

       # write log file
       $Self->{EncodeObject}->SetIO($FH);
       print $FH '[' . localtime() . ']';
       if ( lc $Param{Priority} eq 'debug' ) {
           print $FH "[Debug][$Param{Module}][$Param{Line}] $Self->{CustomPrefix} $Param{Message}\n";
       }
       elsif ( lc $Param{Priority} eq 'info' ) {
           print $FH "[Info][$Param{Module}]  $Self->{CustomPrefix} $Param{Message}\n";
       }
       elsif ( lc $Param{Priority} eq 'notice' ) {
           print $FH "[Notice][$Param{Module}] $Self->{CustomPrefix} $Param{Message}\n";
       }
       elsif ( lc $Param{Priority} eq 'error' ) {
           print $FH "[Error][$Param{Module}][$Param{Line}] $Self->{CustomPrefix} $Param{Message}\n";
       }
       else {

           # print error messages to STDERR
           print STDERR
               "[Error][$Param{Module}] $Self->{CustomPrefix} Priority: '$Param{Priority}' not defined! Message: $Param{Message}\n";

           # and of course to logfile
           print $FH
               "[Error][$Param{Module}] $Self->{CustomPrefix} Priority: '$Param{Priority}' not defined! Message: $Param{Message}\n";
       }

       # close file handle
       close $FH;
       return 1;
   }

   1;


Log Module Configuration Example
--------------------------------

To activate our custom logging module, the administrator can either set the existing configuration item ``LogModule`` manually to ``Kernel::System::Log::CustomFile``. To realize this automatically, you can provide an XML configuration file which overrides the default setting.

.. code-block:: XML

   <ConfigItem Name="LogModule" Required="1" Valid="1">
       <Description Translatable="1">Set Kernel::System::Log::CustomFile as default logging backend.</Description>
       <Group>Framework</Group>
       <SubGroup>Core::Log</SubGroup>
       <Setting>
           <Option Location="Kernel/System/Log/*.pm" SelectedID="Kernel::System::Log::CustomFile"></Option>
       </Setting>
   </ConfigItem>


Log Module Use Case Example
---------------------------

Useful logging backends could be logging to a web service or to encrypted files.

.. note::

   ``Kernel::System::Log`` has other methods than ``Log()`` which cannot be reimplemented, for example code for working with shared memory segments and log data caching.
