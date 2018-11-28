Performance Tuning
==================

There is a list of performance enhancing techniques for your OTRS installation, including configuration, coding, memory use, and more.


Ticket Index Module
-------------------

Ticket index module can be set in system configuration setting ``Ticket::IndexModule``. There are two backend modules for the index for the ticket queue view:

``Kernel::System::Ticket::IndexAccelerator::RuntimeDB``
   This is the default option, and will generate each queue view on the fly from the ticket table. You will not have performance trouble until you have about 60,000 open tickets in your system.

``Kernel::System::Ticket::IndexAccelerator::StaticDB``
   The most powerful module, should be used when you have above 80,000 open tickets. It uses an extra ``ticket_index`` table, which will be populated with keywords based on ticket data. Use the following command for generating an initial index after switching backends:

   .. code-block:: bash

      otrs> /opt/otrs/bin/otrs.Console.pl Maint::Ticket::QueueIndexRebuild


Ticket Search Index
-------------------

OTRS uses a special search index to perform full-text searches across fields in articles from different communication channels.

To create an initial index, use this command:

.. code-block:: bash

   otrs> /opt/otrs/bin/otrs.Console.pl Maint::Ticket::FulltextIndex --rebuild

.. note::

   Actual article indexing happens via an OTRS daemon job in the background. While articles which were just added in the system are marked for indexing immediately, it could happen their index is available within a few minutes.

There are some options available for fine tuning the search index:

``Ticket::SearchIndex::IndexArchivedTickets``
   Defines if archived tickets will be included in the search index (not enabled by default). This is advisable to keep the index small on large systems with archived tickets. If this is enabled, archived tickets will not be found by full-text searches.

``Ticket::SearchIndex::Attribute``
   Basic fulltext index settings.

   .. figure:: images/sysconfig-ticket-searchindex-attribute.png
      :alt: ``Ticket::SearchIndex::Attribute`` Setting

      ``Ticket::SearchIndex::Attribute`` Setting

   .. note::

      Run the following command in order to generate a new index:

      .. code-block:: bash

         otrs> /opt/otrs/bin/otrs.Console.pl Maint::Ticket::FulltextIndexRebuild

   ``WordCountMax``
      Defines the maximum number of words which will be processed to build up the index. For example only the first 1000 words of an article body are stored in the article search index.

   ``WordLengthMin`` and ``WordLengthMax``
      Used as word length boundaries. Only words with a length between these two values are stored in the article search index.

``Ticket::SearchIndex::Filters``
   Fulltext index regex filters to remove parts of the text.

   .. figure:: images/sysconfig-ticket-searchIndex-filters.png
      :alt: ``Ticket::SearchIndex::Filters`` Setting

      ``Ticket::SearchIndex::Filters`` Setting

   There are three default filters defined:

   - The first filter strips out special chars like: , & < > ? " ! * | ; [ ] ( ) + $ ^ =
   - The second filter strips out words which begin or ends with one of following chars: ' : .
   - The third filter strips out words which do not contain a word-character: a-z, A-Z, 0-9, _

``Ticket::SearchIndex::StopWords``
   English stop words for fulltext index. These words will be removed from the search index.

   .. figure:: images/sysconfig-ticket-searchindex-stopwords.png
      :alt: ``Ticket::SearchIndex::StopWords###en`` Setting

      ``Ticket::SearchIndex::StopWords###en`` Setting

   There are so-called stop-words defined for some languages. These stop-words will be skipped while creating the search index.

   .. seealso::
      If your language is not in the system configuration settings or you want to add more words, you can add them to this setting:

      - ``Ticket::SearchIndex::StopWords###Custom``


Article Storage
---------------

There are two different backend modules for the article storage of phone, email and internal articles. The used article storage can be configured in the setting ``Ticket::Article::Backend::MIMEBase::ArticleStorage``.

``Kernel::System::Ticket::Article::Backend::MIMEBase::ArticleStorageDB``
   This default module will store attachments in the database. It also works with multiple front end servers, but requires much storage space in the database.

   .. note::

      Don't use this with large setups.

``Kernel::System::Ticket::Article::Backend::MIMEBase::ArticleStorageFS``
   Use this module to store attachments on the local file system. It is fast, but if you have multiple front end servers, you must make sure the file system is shared between the servers. Place it on an NFS share or preferably a SAN or similar solution.

   .. note::

      Recommended for large setups.

You can switch from one back-end to the other on the fly. You can switch the backend in the system configuration, and then run this command line utility to put the articles from the database onto the filesystem or the other way around:

.. code-block:: bash

   otrs> /opt/otrs/bin/otrs.Console.pl Admin::Article::StorageSwitch --target ArticleStorageFS

You can use the ``--target`` option to specify the target backend.

.. note::

   The entire process can take considerable time to run, depending on the number of articles you have and the available CPU power and/or network capacity.

If you want to keep old attachments in the database, you can activate the system configuration option ``Ticket::Article::Backend::MIMEBase::CheckAllStorageBackends`` to make sure OTRS will still find them.


Archiving Tickets
-----------------

As OTRS can be used as an audit-proof system, deleting closed tickets may not be a good idea. Therefore we implemented a feature that allows you to archive tickets.

Tickets that match certain criteria can be marked as archived. These tickets are not accessed if you do a regular ticket search or run a generic agent job. The system itself does not have to deal with a huge amount of tickets any longer as only the latest tickets are taken into consideration when using OTRS. This can result in a huge performance gain on large systems.

To use the archive feature:

1. Activate the ``Ticket::ArchiveSystem`` setting in the system configuration.
2. Define a generic agent job:
   - Click on the *Add Job* button in the *Generic Agent* screen.
   - *Job Settings*: provide a name for the archiving job.
   - *Automatic Execution*: select proper options to schedule this job.
   - *Select Tickets*: it might be a good idea to only archive those tickets in a closed state that have been closed a few months before.
   - *Update/Add Ticket Attributes*: set the field *Archive selected tickets* to *archive tickets*.
   - Save the job at the end of the page.
   - Click on the *Run this task* link in the overview table to see the affected tickets.
   - Click on the *Run Job* button.

   .. note::

      There is only 5000 tickets can be modified by running this job manually.

When you search for tickets, the system default is to search tickets which are not archived.

To search for archived tickets:

1. Open the ticket search screen.
2. Set *Archive search* to *Archived tickets* or *All tickets*.
3. Perform the search.


Caching
-------

OTRS caches a lot of temporary data in ``/opt/otrs/var/tmp``. Please make sure that this uses a high performance file system and storage. If you have enough RAM, you can also try to put this directory on a ramdisk like this:

.. code-block:: bash

   otrs> /opt/otrs/bin/otrs.Console.pl Maint::Session::DeleteAll
   otrs> /opt/otrs/bin/otrs.Console.pl Maint::Cache::Delete
   root> mount -o size=16G -t tmpfs none /opt/otrs/var/tmp

.. note::

   Add persistent mount point in ``/etc/fstab``.

.. warning::

   This will be a non-permanent storage that will be lost on server reboot. All your sessions (if you store them in the filesystem) and your cache data will be lost.

.. seealso::

   There is also a centralized `memcached based cache backend <https://otrs.com/otrs-feature/feature-add-on-cache-memcached-fast/>`__ available for purchase from OTRS Group.
