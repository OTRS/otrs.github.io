Backup and Restore
==================

OTRS has built-in scripts for backup and restore. Execute the scripts with ``-h`` option for more information.

Backup
------

.. note::

   To create a backup, write permission is needed for ``otrs`` user for the destination directory.

.. code-block:: bash

   otrs> /opt/otrs/scripts/backup.pl -h

The output of the script:

.. code-block:: none

   Backup an OTRS system.
   
   Usage:
    backup.pl -d /data_backup_dir [-c gzip|bzip2] [-r DAYS] [-t fullbackup|nofullbackup|dbonly]
   
   Options:
    -d                     - Directory where the backup files should place to.
    [-c]                   - Select the compression method (gzip|bzip2). Default: gzip.
    [-r DAYS]              - Remove backups which are more than DAYS days old.
    [-t]                   - Specify which data will be saved (fullbackup|nofullbackup|dbonly). Default: fullbackup.
    [-h]                   - Display help for this command.
   
   Help:
   Using -t fullbackup saves the database and the whole OTRS home directory (except /var/tmp and cache directories).
   Using -t nofullbackup saves only the database, /Kernel/Config* and /var directories.
   With -t dbonly only the database will be saved.

   Output:
    Config.tar.gz          - Backup of /Kernel/Config* configuration files.
    Application.tar.gz     - Backup of application file system (in case of full backup).
    VarDir.tar.gz          - Backup of /var directory (in case of no full backup).
    DataDir.tar.gz         - Backup of article files.
    DatabaseBackup.sql.gz  - Database dump.


Restore
-------

.. code-block:: bash

   otrs> /opt/otrs/scripts/restore.pl -h

The output of the script:

.. code-block:: none

   Restore an OTRS system from backup.
   
   Usage:
    restore.pl -b /data_backup/<TIME>/ -d /opt/otrs/
   
   Options:
    -b                     - Directory of the backup files.
    -d                     - Target OTRS home directory.
    [-h]                   - Display help for this command.
