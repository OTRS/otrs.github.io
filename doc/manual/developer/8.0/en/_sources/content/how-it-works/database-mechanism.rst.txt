Database Mechanism
==================

OTRS comes with a database layer that supports different databases.

The database layer ``Kernel::System::DB`` has two input options: *SQL* and *XML*.


SQL
---

The SQL interface should be used for normal database actions (``SELECT``, ``INSERT``, ``UPDATE``, etc.). It can be used like a normal Perl DBI interface.


INSERT/UPDATE/DELETE statements
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

.. code-block:: Perl

   $Kernel::OM->Get('Kernel::System::DB')->Do(
       SQL=> "INSERT INTO table (name, id) VALUES ('SomeName', 123)",
   );

   $Kernel::OM->Get('Kernel::System::DB')->Do(
       SQL=> "UPDATE table SET name = 'SomeName', id = 123",
   );

   $Kernel::OM->Get('Kernel::System::DB')->Do(
       SQL=> "DELETE FROM table WHERE id = 123",
   );


SELECT statement
~~~~~~~~~~~~~~~~

.. code-block:: Perl

   my $SQL = "SELECT id FROM table WHERE tn = '123'";

   $Kernel::OM->Get('Kernel::System::DB')->Prepare(SQL => $SQL, Limit => 15);

   while (my @Row = $Kernel::OM->Get('Kernel::System::DB')->FetchrowArray()) {
       $Id = $Row[0];
   }
   return $Id;
               
.. note::

   Take care to use ``Limit`` as param and not in the SQL string because not all databases support ``LIMIT`` in SQL strings.

.. code-block:: Perl

   my $SQL = "SELECT id FROM table WHERE tn = ? AND group = ?";

   $Kernel::OM->Get('Kernel::System::DB')->Prepare(
       SQL   => $SQL,
       Limit => 15,
       Bind  => [ $Tn, $Group ],
   );

   while (my @Row = $Kernel::OM->Get('Kernel::System::DB')->FetchrowArray()) {
       $Id = $Row[0];
   }
   return $Id;
               
.. note::

   Use the ``Bind`` attribute where ever you can, especially for long statements. If you use ``Bind`` you do not need the function ``Quote()``.


QUOTE
~~~~~

String:

.. code-block:: Perl

   my $QuotedString = $Kernel::OM->Get('Kernel::System::DB')->Quote("It's a problem!");
                       

Integer:

.. code-block:: Perl

   my $QuotedInteger = $Kernel::OM->Get('Kernel::System::DB')->Quote('123', 'Integer');
                       

Number:

.. code-block:: Perl

   my $QuotedNumber = $Kernel::OM->Get('Kernel::System::DB')->Quote('21.35', 'Number');
                       
.. note::

   Please use the ``Bind`` attribute instead of ``Quote()`` where ever you can.


XML
---

The XML interface should be used for ``INSERT``, ``CREATE TABLE``, ``DROP TABLE`` and ``ALTER TABLE``. As this syntax is different from database to database, using it makes sure that you write applications that can be used in all of them.


INSERT
~~~~~~

.. code-block:: XML

   <Insert Table="some_table">
       <Data Key="id">1</Data>
       <Data Key="description" Type="Quote">exploit</Data>
   </Insert>


CREATE TABLE
~~~~~~~~~~~~

Possible data types are: ``BIGINT``, ``SMALLINT``, ``INTEGER``, ``VARCHAR`` (Size=1-1000000), ``DATE`` (format: yyyy-mm-dd hh:mm:ss) and ``LONGBLOB``.

.. code-block:: XML

   <TableCreate Name="calendar_event">
       <Column Name="id" Required="true" PrimaryKey="true" AutoIncrement="true" Type="BIGINT"/>
       <Column Name="title" Required="true" Size="250" Type="VARCHAR"/>
       <Column Name="content" Required="false" Size="250" Type="VARCHAR"/>
       <Column Name="start_time" Required="true" Type="DATE"/>
       <Column Name="end_time" Required="true" Type="DATE"/>
       <Column Name="owner_id" Required="true" Type="INTEGER"/>
       <Column Name="event_status" Required="true" Size="50" Type="VARCHAR"/>
       <Index Name="calendar_event_title">
           <IndexColumn Name="title"/>
       </Index>
       <Unique Name="calendar_event_title">
           <UniqueColumn Name="title"/>
       </Unique>
       <ForeignKey ForeignTable="users">
           <Reference Local="owner_id" Foreign="id"/>
       </ForeignKey>
   </TableCreate>

``LONGBLOB`` columns need special treatment. Their content needs to be base64 transcoded if the database driver does not support the feature ``DirectBlob``. Please see the following example:

.. code-block:: Perl

   my $Content = $StorableContent;
   if ( !$DBObject->GetDatabaseFunction('DirectBlob') ) {
       $Content = MIME::Base64::encode_base64($StorableContent);
   }

Similarly, when reading from such a column, the content must not automatically be decoded as UTF-8 by passing the ``Encode => 0`` flag to ``Prepare()``:

.. code-block:: Perl

   return if !$DBObject->Prepare(
       SQL => '
           SELECT content_type, content, content_id, content_alternative, disposition, filename
           FROM article_data_mime_attachment
           WHERE id = ?',
       Bind   => [ \$AttachmentID ],
       Encode => [ 1, 0, 0, 0, 1, 1 ],
   );

   while ( my @Row = $DBObject->FetchrowArray() ) {

       $Data{ContentType} = $Row[0];

       # Decode attachment if it's e. g. a postgresql backend.
       if ( !$DBObject->GetDatabaseFunction('DirectBlob') ) {
           $Data{Content} = decode_base64( $Row[1] );
       }
       else {
           $Data{Content} = $Row[1];
       }
       $Data{ContentID}          = $Row[2] || '';
       $Data{ContentAlternative} = $Row[3] || '';
       $Data{Disposition}        = $Row[4];
       $Data{Filename}           = $Row[5];
   }


DROP TABLE
~~~~~~~~~~

.. code-block:: XML

   <TableDrop Name="calendar_event"/>


ALTER TABLE
~~~~~~~~~~~

The following shows an example of add, change and drop columns.

.. code-block:: XML

   <TableAlter Name="calendar_event">
       <ColumnAdd Name="test_name" Type="varchar" Size="20" Required="true"/>

       <ColumnChange NameOld="test_name" NameNew="test_title" Type="varchar" Size="30" Required="true"/>

       <ColumnChange NameOld="test_title" NameNew="test_title" Type="varchar" Size="100" Required="false"/>

       <ColumnDrop Name="test_title"/>

       <IndexCreate Name="index_test3">
           <IndexColumn Name="test3"/>
       </IndexCreate>

       <IndexDrop Name="index_test3"/>

       <UniqueCreate Name="uniq_test3">
           <UniqueColumn Name="test3"/>
       </UniqueCreate>

       <UniqueDrop Name="uniq_test3"/>
   </TableAlter>

The next shows an example how to rename a table.

.. code-block:: XML

   <TableAlter NameOld="calendar_event" NameNew="calendar_event_new"/>


Code to Process XML
~~~~~~~~~~~~~~~~~~~

.. code-block:: Perl

   my @XMLARRAY = @{$Self->ParseXML(String => $XML)};

   my @SQL = $Kernel::OM->Get('Kernel::System::DB')->SQLProcessor(
       Database => \@XMLARRAY,
   );
   push(@SQL, $Kernel::OM->Get('Kernel::System::DB')->SQLProcessorPost());

   for (@SQL) {
       $Kernel::OM->Get('Kernel::System::DB')->Do(SQL => $_);
   }


Database Drivers
----------------

The database drivers are located under ``$OTRS_HOME/Kernel/System/DB/*.pm``.


Supported Databases
-------------------

-  MySQL
-  PostgreSQL
-  Oracle
-  Microsoft SQL Server (only for external database connections, not as OTRS database)
