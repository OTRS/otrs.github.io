How To Extend The Dynamic Fields
================================

There are many ways to extend the dynamic fields. The following sections will try to cover the most common scenarios.

Create a New Dynamic Field Type (for ticket or article objects)
---------------------------------------------------------------

To create a new dynamic field type is necessary to:

1. Create a dynamic field driver. This is the main module of the new field.
2. Create or use an existing admin dialog to have a management interface and set its configuration options.
3. Create a configuration file to register the new field in the back end (or new admin dialogs in the
   framework if needed) and be able to create instances or it.


Create a New Dynamic Field Type (for other objects)
---------------------------------------------------

To create a new dynamic field type for other objects is necessary to:

1. Create a dynamic field driver. This is the main module of the new field.
2. Create an object type delegate. This is necessary, even if the other object does not require any specific data handling in its functions (e.g. after a value is set). All object type delegates must implement the functions that the back end requires.

   Take a look in the current object type delegates to implement the same functions, even if they just return a successful value for the other object.

3. Create or use an existing admin dialog to have a management interface and set its configuration options.
4. Implement dynamic fields in the front end modules to be able to use the dynamic fields.
5. Create a configuration file to register the new field in the back end (or new admin dialogs in the
   framework if needed) and be able to create instances or it.

   And make the needed settings to show, hide or show the dynamic fields as mandatory in the new screens.


Create a New package to Use Dynamic Fields
------------------------------------------

To create a package to use existing dynamic fields is necessary to:

1. Implement dynamic fields in the front end modules to be able to use the dynamic fields.
2. Create a configuration file to give the end user the possibility to show, hide or show the
   dynamic fields as mandatory in the new screens.


Extend Backend and Drivers Functionalities
------------------------------------------

It might be possible that the back end object does not have a needed function for custom developments, or could also be possible that it has the function needed, but the return format does not match the needs of the custom development, or that a new behavior is needed to execute the new or the old functions.

The easiest way to do this, is to extend the current field files. For this it is necessary to create a new back end extension file that defines the new functions and create also drivers extensions that implement these new functions for each field. These new drivers will only need to implement the new functions since the original drivers takes care of the standard functions. All these new files do not need a constructor as they will be loaded as a base for the back end object and the drivers.

The only restrictions are that the functions should be named different than the ones on the back end and drivers, otherwise they will be overwritten with current objects.

Put the new back end extension into the ``DynamicField`` directory (e.g. ``/$OTRS_HOME/Kernel/System/DynamicField/NewPackageBackend.pm`` and its drivers in ``/$OTRS_HOME/Kernel/System/DynamicField/Driver/NewPackage*.pm``).

New behaviors only need a small setting in the extensions configuration file.

To create new back end functions is needed to:

1. Create a new back end extension module to define only the new functions.
2. Create the dynamic fields driver extensions to implement only the new functions.
3. Implement new dynamic fields functions in the front end modules to be able to use the new dynamic fields functions.
4. Create a configuration file to register the new back end and drivers extensions and behaviors.


Other Extensions
----------------

Other extensions could be a combination of the above examples.
