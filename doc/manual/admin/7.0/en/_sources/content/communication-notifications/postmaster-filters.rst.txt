PostMaster Filters
==================

Pre-sorting standard mail done in a mail room takes care that not every piece of mail sent to the office goes to the same group of people. After a second look at the envelope, rerouting occurs where needed.

OTRS uses so-called :doc:`postmaster-filters` to read the email's envelope and take further action. Depending upon, for example, a subject or sender, an email bound for the service desk could land in a sub-queue or be redirected to a completely different team to create transparency and give your customer the fastest service possible.

Use this screen to add PostMaster filters to the system. The PostMaster filter management screen is available in the *PostMaster Filters* module of the *Communication & Notifications* group.

.. figure:: images/postmaster-filter-management.png
   :alt: PostMaster Filter Management Screen

   PostMaster Filter Management Screen


Manage PostMaster Filters
-------------------------

.. note::

   When adding or editing a PostMaster filter, please keep in mind that they are evaluated in alphabetical order by name.

To add a PostMaster filter:

1. Click on the *Add PostMaster Filter* button in the left sidebar.
2. Fill in the required fields.
3. Click on the *Save* button.


To edit a PostMaster filter:

1. Click on a PostMaster filter in the list of PostMaster filters.
2. Modify the fields.
3. Click on the *Save* or *Save and finish* button.

To delete a PostMaster filter:

1. Click on the trash icon in the list of PostMaster filters.
2. Click on the *Confirm* button.

.. figure:: images/postmaster-filter-delete.png
   :alt: Delete PostMaster Filter Screen

   Delete PostMaster Filter Screen

.. note::

   If several PostMaster filters are added to the system, a filter box is useful to find a particular PostMaster filter by just typing to filter.


PostMaster Filter Settings
--------------------------

The following settings are available when adding or editing this resource. The fields marked with an asterisk are mandatory.

.. figure:: images/postmaster-filter-settings-example.png
   :alt: PostMaster Filter Settings Example

   PostMaster Filter Settings Example


Basic PostMaster Filter Settings
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. figure:: images/postmaster-filter-settings-basic.png
   :alt: PostMaster Filter Settings - Basic

   PostMaster Filter Settings - Basic

Name \*
   The name of this resource. Any type of characters can be entered to this field including uppercase letters and spaces. The name will be displayed in the overview table.

   .. note::

      When adding or editing one of the PostMaster filters, remember multiple filters may apply to a single mail. The last rule wins. Rules execute and sort by the ASCII value of the names. Based on the sorted order in the overview, they are applied top to bottom. Look to the `ASCI chart <http://www.asciitable.com>`_ to see how to sort your names based on the "ASCII-bet".

Stop after match \*
   PostMaster filters are evaluated in alphabetical order. This setting defines the evaluation of the subsequent PostMaster filters.

   No
      All PostMaster filters are executed.

   Yes
      The current PostMaster filter is still evaluated, but evaluation of the remaining filters is canceled.


Filter Condition
^^^^^^^^^^^^^^^^

.. figure:: images/postmaster-filter-settings-filter-condition.png
   :alt: PostMaster Filter Settings - Filter Condition

   PostMaster Filter Settings - Filter Condition

A PostMaster filter consists of one or more conditions that must be met in order for the defined actions to be executed on the email. Filter conditions can be defined for specific mail header entries or for strings in the mail body.

Search header field
   A list of mail header entries can be found in `RFC5322 <https://tools.ietf.org/html/rfc5322>`_. It is also possible to define ``X-OTRS`` headers as filter condition. The different ``X-OTRS`` headers and their meaning are the following:

   .. warning::

   	  These headers must be manually injected into the mail by means not provided for by OTRS. OTRS only accepts ``X-OTRS`` headers from trusted sources.

   .. seealso::

      The :ref:`Mail Account Settings` defines the trust level.

   X-OTRS-AttachmentCount
      This contains as value the number of attachments which are contained in the email (e.g. *0* for mails without attachments).

   X-OTRS-AttachmentExists
      Depending on whether attachments are included in the email this X-OTRS header is set to *yes*, or it has a *no* value if no attachments are included.

   X-OTRS-BodyDecrypted
      If the incoming mail was encrypted, it is possible to add a search term to look for the body of the incoming encrypted mail.

   X-OTRS-CustomerNo
      Set the customer ID for the ticket.

   X-OTRS-CustomerUser
      Set the customer user for the ticket.

   X-OTRS-DynamicField-<DynamicFieldName>
      Saves an additional information value for the ticket on <DynamicFieldName> dynamic field. The possible values depend on dynamic field configuration (e.g. text: Notebook, date: 2010-11-20 00:00:00, integer: 1).

   X-OTRS-FollowUp-*
      These headers are the same as the ones without the ``FollowUp`` prefix, but these headers are applied only for follow-up mails.

   X-OTRS-FollowUp-State-Keep
      If set to *1*, the incoming follow-up message will not change the ticket state. For this purpose the header can be customized in the system configuration using option ``KeepStateHeader``.

   X-OTRS-Ignore
      If set to *Yes* or *True*, the incoming message will completely be ignored and never delivered to the system.

   X-OTRS-IsVisibleForCustomer
      Controls if the article is shown in the customer interface. Possible values are *0* or *1*.

   X-OTRS-Lock
      Set the lock state of a ticket. Possible values are *locked* or *unlocked*.

   X-OTRS-Loop
      If set to *True*, no auto answer is delivered to the sender of the message (mail loop protection).

   X-OTRS-Owner
      Set the agent as owner for the ticket.

   X-OTRS-OwnerID
      Set the agent ID as owner for the ticket.

   X-OTRS-Priority
      Set the priority for the ticket.

   X-OTRS-Queue
      Set the queue where the ticket shall be sorted. If this is set, all other filter rules that try to sort a ticket into a specific queue are ignored. If you use a sub-queue, specify it as *Parent::Sub*.

   X-OTRS-Responsible
      Set the agent ID as responsible for the ticket.

   X-OTRS-ResponsibleID
      Set the agent ID as responsible for the ticket.

   X-OTRS-SenderType
      Set the sender type for the ticket. Possible values are *agent*, *system* or *customer*.

   X-OTRS-Service
      Set the service for the ticket. If you use a sub-service, specify it as *Parent::Sub*.

   X-OTRS-SLA
      Set the service level agreement for the ticket.

   X-OTRS-State
      Set the state for the ticket.

   X-OTRS-State-PendingTime
      Set the pending time for the ticket (you also should sent a pending state via X-OTRS-State). You can specify absolute dates like *2010-11-20 00:00:00* or relative dates, based on the arrival time of the email. Use the form ``+ $Number $Unit``, where ``$Unit`` can be *s* (seconds), *m* (minutes), *h* (hours) or *d* (days). Only one unit can be specified. Examples of valid settings: *+50s* (pending in 50 seconds), *+30m* (30 minutes), *+12d* (12 days).

      .. note::
         Settings like *+1d 12h* are not possible. You can specify *+36h* instead.

   X-OTRS-Title
      Set the title for the ticket.

   X-OTRS-Type
      Set the type for the ticket.

for value
   Enter a search term to this field. Even regular expressions can be used for extended pattern matching.

Negate
   If checked, the condition will use the negate search term.


Set Email Headers
^^^^^^^^^^^^^^^^^

.. figure:: images/postmaster-filter-settings-set-email-headers.png
   :alt: PostMaster Filter Settings - Set Email Headers

   PostMaster Filter Settings - Set Email Headers

In this section you can choose the actions that are triggered if the filter rules match.

Set email header
   Select an ``X-OTRS`` header. The ``X-OTRS`` headers are already described above.

with value
   Add a value to this field that should be set as value of the selected ``X-OTRS`` header.
