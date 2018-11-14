Access Control Lists (ACL)
==========================

Working with tickets can become a bewildering task. Many options are given to process, or close tickets, even if they are not needed in the current state of a ticket or due to the role of the current agent. Hiding unneeded entries cleans up the menu bar and gets it easier to work with, hiding values from dynamic fields or next queues lowers chance of human error.

OTRS uses Access Control Lists (ACL) to restrict agents and customer users on ticket options, allowing only correct and meaningful activities with a ticket. OTRS administrators can easily in the graphical interface generate ACLs to prevent ticket closure until meeting specific requirements, prevent tickets from being moved to queues before adding the defined information and much more.

Use this screen to manage access control lists in the system. A fresh OTRS installation contains no access control lists by default. The access control lists management screen is available in the *Access Control Lists (ACL)* module of the *Processes & Automation* group.

.. figure:: images/acl-management.png
   :alt: ACL Management Screen

   ACL Management Screen


Manage Access Control Lists
---------------------------

.. note::

   When creating some access control lists, please keep in mind that they are executed alphabetically as displayed in the access control lists overview.

.. warning::

   ACL restrictions will be ignored for the superuser account (UserID 1).

To create a new ACL:

1. Click on the *Create New ACL* button in the left sidebar.
2. Fill in the required fields.
3. Click on the *Save* button.
4. You will be redirected to *Edit ACL* screen to edit the ACL structure.

.. figure:: images/acl-add.png
   :alt: Create New ACL Screen

   Create New ACL Screen

To edit an ACL:

1. Click on an ACL in the list of ACLs or you are already redirected here from *Create New ACL* screen.
2. Modify the fields and the ACL structure.
3. Click on the *Save* or *Save and finish* button.
4. Deploy all ACLs.

.. figure:: images/acl-edit.png
   :alt: Edit ACL Structure Screen

   Edit ACL Structure Screen

To delete an ACL:

1. Click on an ACL in the list of ACLs.
2. Set the *Validity* option to *invalid* or *invalid-temporarily*.
3. Click on the *Save* button. A new *Delete Invalid ACL* button will appear in the left sidebar.
4. Click on the *Delete Invalid ACL* button.
5. Click on the *Delete* button in the confirmation screen.
6. Deploy all ACLs.

.. warning::

   ACLs are written into ``ZZZACL.pm`` file in Perl format. Without deploying, all ACLs are still in this cache file even if they are deleted or the *Validity* option is set to *invalid* or *invalid-temporarily*. Don't forget to deploy all ACLs after modifications!

To deploy all ACLs:

1. Click on the *Deploy ACLs* button in the left sidebar.

.. note::

   New or modified ACLs have to deploy in order to make affect the behavior of the system. Setting the *Validity* option to *valid* just indicates, which ACLs should be deployed.

To export all ACLs:

1. Click on the *Export ACLs* button in the left sidebar.
2. Choose a location in your computer to save the ``Export_ACL.yml`` file.

To import ACLs:

1. Click on the *Browse…* button in the left sidebar.
2. Select a previously exported ``.yml`` file.
3. Click on the *Overwrite existing ACLs?* checkbox, if you would like to overwrite the existing ACLs.
4. Click on the *Import ACL configuration(s)* button.
5. Deploy the imported ACLs with *Deploy ACLs* button.

.. note::

   If several ACLs are added to the system, use the filter box to find a particular ACL by just typing the name to filter.

.. warning::

   Changing the name of this object should be done with care, the check only provides verification for certain settings and ignores things where the name can't be verified. Some examples are dashboard filters, action control lists (ACLs), and processes (sequence flow actions) to name a few. Documentation of your setup is key to surviving a name change.


ACL Settings
------------

The following settings are available when adding or editing this resource. The fields marked with an asterisk are mandatory.

Name \*
   The name of this resource. Any type of characters can be entered to this field including uppercase letters and spaces. The name will be displayed in the overview table.

Comment
   Add additional information to this resource. It is recommended to always fill this field as a description of the resource with a full sentence for better clarity, because the comment will be also displayed in the overview table.

Description
   Like comment, but longer text can be added here.

Stop after match
   ACLs are evaluated in alphabetical order. This setting disables the evaluation of the subsequent ACLs.

Validity \*
   Set the validity of this resource. Each resource can be used in OTRS only, if this field is set to *valid*. Setting this field to *invalid* or *invalid-temporarily* will disable the use of the resource.


Edit ACL Structure
------------------

The ACL definition can be split into two big parts, *Match settings* and *Change settings*. In the matching sections the ACLs contains attributes that has to be met in order to use the ACL. If the attributes defined in the ACL does not match with the attributes that are sent, then the ACL does not take any affect, but any other match ACL will. The change sections contains the rules to reduce the possible options for a ticket.


Match settings
~~~~~~~~~~~~~~

``Properties``
   This section contains matching options that can be changed on the fly. For example on a ticket creation time the data of the ticket changes dynamically as the agent sets the information. If an ACL is set to match a ticket attribute then only when the matching attribute is selected the ACL will be active and might reduce other ticket attributes, but as soon as another value is selected the ACL will not take any affect.

``PropertiesDatabase``
   This section is similar to Properties but does not take changes in ticket attributes that are not saved into the database, this means that changing an attribute without submit will not make any effect. This section is not use for ticket creation screens (as tickets are not yet created in the database).


Change settings
~~~~~~~~~~~~~~~

``Possible``
   Possible section resets the data to be reduce to only the elements that are set in this section.

``PossibleAdd``
   Elements in ``PossibleAdd`` section add missing elements that were reduced in other ACLs. ``PossibleAdd`` is only used in together with other ACLs that have ``Possible`` or ``PossibleNot`` sections.

``PossibleNot``
   This section is used to remove specific elements from the current data. It could be used stand alone or together with other ACLs with a ``Possible`` or ``PossibleAdd`` sections.


Modifiers
~~~~~~~~~

In order to make the development of ACLs easier and more powerful there is a set of so called modifiers for the attributes on each section. This modifiers are explained below:

``[Not]``
   This modifier is used to negate a value, for example ``[Not]2 low``. Talking about priorities will be the same as to have: *1 very low*, *3 normal*, *4 high*, *5 very high*.

``[RegExp]``
   It is used to define a regular expression for matching several values, for example ``[RegExp]low``. In this case talking about priorities is the same as *1 very low*, *2 low*.

``[regexp]``
   It is very similar to ``[RegExp]`` but it is case insensitive.

``[NotRegExp]``
   Negated regular expressions, for example ``[NotRegExp]low``. Talking about priorities is the same as *3 normal*, *4 high*, *5 very high*.

``[Notregexp]``
   It is very similar to ``[NotRegExp]`` but it is case insensitive.


ACL Examples
------------


Move Ticket to Queue Based on Priority
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

This example shows you how to allow movement into a queue of only those tickets with ticket priority *5 very high*.

First, it needs to have a name. In this case, it is *100-Example-ACL*. Note that the ACLs will be numerically sorted before execution, so you should use the names carefully. The comment and the description fields are optional.

.. figure:: images/acl-100-example-acl-basic-settings.png
   :alt: 100-Example-ACL - Basic Settings

   100-Example-ACL - Basic Settings

Secondly, you have a *Properties* section which is a filter for your tickets. All the criteria defined here will be applied to a ticket to determine if the ACL must be applied or not. In our example, a ticket will match if it is in the queue *Raw* and has priority *5 very high*. This is also affected by changes in the form (e. g. if the ticket is the queue *Raw* and had a priority *3 normal* at this moment the ACL will not match, but then priority drop-down is selected and the priority is changed now to *5 very high* then will also match).

.. figure:: images/acl-100-example-acl-match-settings.png
   :alt: 100-Example-ACL - Match Settings

   100-Example-ACL - Match Settings

Lastly, a section *Possible* defines modifications to the screens. In this case, from the available queues, only the queue *Alert* can be selected in a ticket screen.

.. figure:: images/acl-100-example-acl-change-settings.png
   :alt: 100-Example-ACL - Change Settings

   100-Example-ACL - Change Settings

.. note::

   Don't forget to set *Validity* to *valid* and deploy the newly created ACL.


Move Ticket to Queue Based on Priority Stored in Database
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

This example is very similar to the first one, but in this case only tickets in the queue *Raw* and with a priority *5 very high*, both stored in the database will match. This kind of ACLs does not consider changes in the form before the ticket is really updated in the database.

.. figure:: images/acl-101-example-acl.png
   :alt: 101-Example-ACL

   101-Example-ACL


Disable Ticket Close in Queue and Hide Close Button
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

This example shows how to disable the closing of tickets in the queue *Raw*, and hide the close button. It is possible to filter a ticket field (state) with more than one possible values to select from. It is also possible to limit the actions that can be executed for a certain ticket. In this case, the ticket cannot be closed.

.. figure:: images/acl-102-example-acl.png
   :alt: 102-Example-ACL

   102-Example-ACL


Remove State
~~~~~~~~~~~~

This example shows how it is possible to define negative filters (the state *closed successful* will be removed). You can also see that not defining match properties for a ticket will match any ticket, i. e. the ACL will always be applied. This may be useful if you want to hide certain values by default, and only enable them in special circumstances (e. g. if the agent is in a specific group).

.. figure:: images/acl-103-example-acl.png
   :alt: 103-Example-ACL

   103-Example-ACL


Using Regular Expressions
~~~~~~~~~~~~~~~~~~~~~~~~~

This example shows you how you can use regular expressions for matching tickets and for filtering the available options. This ACL only shows *Hardware* services for tickets that are created in queues that start with *HW*.

.. figure:: images/acl-104-example-acl.png
   :alt: 104-Example-ACL

   104-Example-ACL


Disallow Process For Customer
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

This ACL restricts the process *P14* in the external interface using the customer ID *TheCustomerID*.

.. figure:: images/acl-105-example-acl.png
   :alt: 105-Example-ACL

   105-Example-ACL
