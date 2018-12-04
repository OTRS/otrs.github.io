Date and Time
=============

OTRS comes with its own package to handle date and time which ensures correct calculation and storage of date and time.


Introduction
------------

Date and time are represented by an object of ``Kernel::System::DateTime``. Every ``DateTime`` object holds its own date, time and time zone information. In contrast to the now deprecated ``Kernel::System::Time`` package, this means that you can and should create a ``DateTime`` object for every date/time you want to use.


Creation of a DateTime Object
-----------------------------

The object manager of OTRS has been extended by a ``Create`` method to support packages for which more than one instance can be created:

.. code-block:: Perl

   my $DateTimeObject = $Kernel::OM->Create(
       'Kernel::System::DateTime',
       ObjectParams => {
           TimeZone => 'Europe/Berlin'
       },
   );

The example above will create a ``DateTime`` object for the current date and time in time zone *Europe/Berlin*. There are more options to create a ``DateTime`` object (time components, string, timestamp, cloning), see POD of ``Kernel::System::DateTime``.

.. note::

   You will get an error if you try to retrieve a ``DateTime`` object via ``$Kernel::OM->Get('Kernel::System::DateTime')``.


Time Zones
----------

Time offsets in hours (+2, -10, etc.) have been replaced by time zones (Europe/Berlin, America/New_York, etc.). The conversion between time zones is completely encapsulated within a ``DateTime`` object. If you want to convert to another time zone, simply use the following code:

.. code-block:: Perl

   $DateTimeObject->ToTimeZone( TimeZone => 'Europe/Berlin' );

There is a system configuration option ``OTRSTimeZone``. This setting defines the time zone that OTRS uses internally to store date and time within the database.

.. note::

   You have to ensure to convert a ``DateTime`` object to the OTRS time zone before it gets stored in the database (there's a convenient method for this: ``ToOTRSTimeZone()``). An exception could be that you explicitly want a database column to hold a date/time in a specific time zone. But be aware that the database itself won't provide time zone information by itself when retrieving it.

.. note::

   ``TimeZoneList()`` of ``Kernel::System::DateTime`` provides a list of available time zones.


Method Summary
--------------

The ``Kernel::System::DateTime`` package provides the following methods (this is only a selection, see source code for details).


Object Creation Methods
~~~~~~~~~~~~~~~~~~~~~~~

A ``DateTime`` object can be created either via the object manager's ``Create()`` method or by cloning another ``DateTime`` object with its ``Clone()`` method.


Get Method
~~~~~~~~~~

With ``Get()`` all data of a ``DateTime`` object will be returned as a hash (date and time components including day name, etc. as well as time zone).


Set Method
~~~~~~~~~~

With ``Set()`` you can either change certain components of the ``DateTime`` object (year, month, day, hour, minute, second) or you can set a date and time based on a given string (*2016-05-24 23:04:12*). Note that you cannot change the time zone with this method.


Time Zone Methods
~~~~~~~~~~~~~~~~~

To change the time zone of a ``DateTime`` object use method ``ToTimeZone()`` or as a shortcut for converting to OTRS time zone ``ToOTRSTimeZone()``.

To retrieve the configured OTRS time zone or user default time zone, always use method ``OTRSTimeZoneGet()`` or ``UserDefaultTimeZoneGet()``. Never retrieve these manually via ``Kernel::Config``.


Comparison Operators And Methods
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

``Kernel::System::DateTime`` uses operator overloading for comparisons. So you can simply compare two ``DateTime`` objects with <, <=, ==, !=, >= and >. ``Compare()`` is usable in Perl's sort context as it returns -1, 0 or 1.


Deprecated Package ``Kernel::System::Time``
-------------------------------------------

The now deprecated package ``Kernel::System::Time`` has been extended to fully support time zones instead of time offsets. This has been done to ensure that existing code works without (bigger) changes.

However, there is a case in which you have to change existing code. If you have code that uses the old time offsets to calculate a new date/time or a difference, you have to migrate this code to use the new ``DateTime`` object.

Example (old code):

.. code-block:: Perl

   my $TimeObject     = $Kernel::OM->Get('Kernel::System::Time'); # Assume a time offset of 0 for this time object
   my $SystemTime     = $TimeObject->TimeStamp2SystemTime( String => '2004-08-14 22:45:00' );
   my $UserTimeZone   = '+2'; # normally retrieved via config or param
   my $UserSystemTime = $SystemTime + $UserTimeZone * 3600;
   my $UserTimeStamp  = $TimeObject->SystemTime2TimeStamp( SystemTime => $UserSystemTime );

Example (new code):

.. code-block:: Perl

   my $DateTimeObject = $Kernel::OM->Create('Kernel::System::DateTime'); # This implicitly sets the configured OTRS time zone
   my $UserTimeZone   = 'Europe/Berlin'; # normally retrieved via config or param
   $DateTimeObject->ToTimeZone( TimeZone => $UserTimeZone );
   my $SystemTime    = $DateTimeObject->ToEpoch(); # note that the epoch is independent from the time zone, it's always calculated for UTC
   my $UserTimeStamp = $DateTimeObject->ToString();
