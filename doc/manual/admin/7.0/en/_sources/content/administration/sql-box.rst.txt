SQL Box
=======

In a ticket system, it is usually possible to have statistics that show a summarized view of ticket information when needed. Sometimes, it is however required to access the database directly to have even more individual reports, allow external statistic tools to query information from the system or perform in-depth analysis of a ticket behavior.

Direct access to the database requires access to the command line which an administrator may not have. In addition to the username and password for the command line access, which is not given by all organizations, the username and password for the database are needed. These hurdles can prevent an administrator from using the database for more complex searches and operations.

OTRS offers application administrators the SQL Box in the graphical interface. It allows read access to the database. All results can be seen in the GUI or exported to CSV/Excel files.

Use this screen to query SQL statements in the system. The SQL box screen is available in the *SQL Box* module of the *Administration* group.

.. figure:: images/sql-box.png
   :alt: SQL Box Screen

   SQL Box Screen


Query SQL statements
--------------------

.. note::

   The SQL statements entered here are sent directly to the application database. By default, it is not possible to change the content of the tables, only SELECT queries are allowed.

.. seealso::

   It is possible to modify the application database via SQL box. To do this, you have to enabled the system configuration setting :sysconfig:`AdminSelectBox::AllowDatabaseModification <frontend.html#adminselectbox-allowdatabasemodification>`. Activate it to your own risk!

To execute an SQL statement:

1. Enter the SQL statement into the SQL box.
2. Select the result format.
3. Click on the *Run Query* button.

.. figure:: images/sql-box-settings.png
   :alt: SQL Box Widget

   SQL Box Widget


SQL Settings
------------

The following settings are available when adding or editing this resource. The fields marked with an asterisk are mandatory.

SQL \*
   The SQL statement to be queried.

Limit
   Enter a number to limit the result to at most this number of rows. Leaving this field empty means there is no limit.

   .. note::

      Don't use ``LIMIT`` inside the SQL statement. Always use this field to limit the number of results.

Result format
   The format of the SQL statement result.

   HTML
      The results are visible below the SQL box in a new widget.

   CSV
      The results can be downloaded in comma separated plain text format.

   Excel
      The results can be downloaded as Microsoft Excel spreadsheet.


SQL Examples
------------

To list some information about agents and output the results as HTML:

.. code-block:: SQL

   SELECT id, login , first_name, last_name, valid_id FROM users

.. figure:: images/sql-box-result.png
   :alt: SQL Box Result

   SQL Box Result

To list all tables, you need to leave empty the *Limit* field and run the following query:

.. code-block:: SQL

   SHOW TABLES

To show the structure of the ``users`` table, you need to limit the results to 1 and run the following query (see the table header for the columns):

.. code-block:: SQL

   SELECT * FROM users
