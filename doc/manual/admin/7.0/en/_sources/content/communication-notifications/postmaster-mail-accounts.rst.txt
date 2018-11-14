PostMaster Mail Accounts
========================

Just as a company doesn't just have one department which receives traditional mail, your service desk will also serve multiple teams. Each team can have its physical email mailbox.

OTRS eases setup for email mailboxes. OTRS manages polling one or multiple email mailboxes of any internet standard type.

Use this screen to add mail accounts to the system. The mail account management screen is available in the *PostMaster Mail Accounts* module of the *Communication & Notifications* group.

.. figure:: images/postmaster-mail-account-management.png
   :alt: Mail Account Management Screen

   Mail Account Management Screen

.. warning::
   When fetching mail, OTRS deletes the mail from the POP or IMAP server. There is no option to also keep a copy on the server. If you want to retain a copy on the server, you should create forwarding rules on your mail server. Please consult your mail server documentation for details.

.. note::

   If you choose IMAP, you can specify a folder for collection. Selective dispatching of mails is then possible.

All data for the mail accounts are saved in the OTRS database. The ``bin/otrs.Console.pl Maint::PostMaster::MailAccountFetch`` command uses the settings in the database and fetches the mail. You can execute it manually to check if all your mail settings are working properly.

On a default installation, the mail is fetched every 10 minutes when the OTRS Daemon is running.


Manage Mail Accounts
--------------------

To add a mail account:

1. Click on the *Add Mail Account* button in the left sidebar.
2. Fill in the required fields.
3. Click on the *Save* button.

.. figure:: images/postmaster-mail-account-add.png
   :alt: Add Mail Account Screen

   Add Mail Account Screen

To edit a mail account:

1. Click on a mail account in the list of mail accounts.
2. Modify the fields.
3. Click on the *Save* or *Save and finish* button.

.. figure:: images/postmaster-mail-account-edit.png
   :alt: Edit Mail Account Screen

   Edit Mail Account Screen

To delete a mail account:

1. Click on the trash icon in the list of mail accounts.
2. Click on the *Confirm* button.

.. figure:: images/postmaster-mail-account-delete.png
   :alt: Delete Mail Account Screen

   Delete Mail Account Screen

.. note::

   If several mail accounts are added to the system, a filter box is useful to find a particular mail account by just typing to filter.


Mail Account Settings
---------------------

The following settings are available when adding or editing this resource. The fields marked with an asterisk are mandatory.

Type \*
   There are different kind of protocols that are used for fetching mail. The following protocols are supported:

   - IMAP
   - IMAPS
   - IMAPTLS
   - POP3
   - POP3S
   - POP3TLS

Username \*
   The username of the mail account.

Password \*
   The password of the mail account.

Host \*
   The host name of the mail account.
   Specify how the current article subject should be dealt with. The following methods are available:

IMAP Folder
   The folder in the mail account to be fetched. Other folders remain untouched.

Trusted
   If *Yes* is selected, any ``X-OTRS`` headers attached to an incoming message are evaluated and executed. Because the ``X-OTRS`` header can execute some actions in the ticket system, you should set this option to *Yes* only for known senders.

   .. seealso::
      The ``X-OTRS`` headers are explained in the filter conditions of :doc:`postmaster-filters`.

Dispatching
   The distribution of incoming messages can be controlled if they need to be sorted by queue or by the content of the *To:* field.

   Dispatching by email To: field
      The system checks if a queue is linked with the address in the *To:* field of the incoming mail. You can link an address to a queue in the :doc:`email-addresses` screen. If the address in the *To:* field is linked with a queue, the new message will be sorted into the linked queue. If no link is found between the address in the *To:* field and any queue, then the message flows into the *Raw* queue in the system, which is the ``PostmasterDefaultQueue`` after a default installation.

   Dispatching by selected Queue
      All incoming messages will be sorted into the specified queue. The address where the mail was sent to is disregarded in this case.

Validity \*
   Set the validity of this resource. Each resource can be used in OTRS only, if this field is set to *valid*. Setting this field to *invalid* or *invalid-temporarily* will disable the use of the resource.

Comment
   Add additional information to this resource. It is recommended to always fill this field as a description of the resource with a full sentence for better clarity, because the comment will be also displayed in the overview table.
