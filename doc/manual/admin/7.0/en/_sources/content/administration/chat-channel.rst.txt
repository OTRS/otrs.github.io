Chat Channel
============

Being able to offer chat possibilities to customers is a must-have for many organizations. Depending on the amount of customer chat requests and the organization's structure, it must be possible to group chat requests.

OTRS offers chat channels with different permissions per channel, so it is, e.g. possible to have different chat channels for registered contract customers and public prospects.

Use this screen to add chat channels to the system. A fresh OTRS installation contains no chat channels by default. The chat channel management screen is available in the *Chat Channel* module of the *Administration* group.

.. figure:: images/chat-channel-management.png
   :alt: Chat Channel Management Screen

   Chat Channel Management Screen


Manage Chat Channels
--------------------

To add a chat channel:

1. Click on the *Add Chat Channel* button in the left sidebar.
2. Fill in the required fields.
3. Click on the *Save* button.

.. figure:: images/chat-channel-add.png
   :alt: Add Chat Channel Screen

   Add Chat Channel Screen

.. warning::

   Chat channels can not be deleted from the system. They can only be deactivated by setting the *Validity* option to *invalid* or *invalid-temporarily*.

To edit a chat channel:

1. Click on a chat channel in the list of chat channels.
2. Modify the fields.
3. Click on the *Save* or *Save and finish* button.

.. figure:: images/chat-channel-edit.png
   :alt: Edit Chat Channel Screen

   Edit Chat Channel Screen


Chat Channel Settings
---------------------

The following settings are available when adding or editing this resource. The fields marked with an asterisk are mandatory.

Name \*
   The name of this resource. Any type of characters can be entered to this field including uppercase letters and spaces. The name will be displayed in the overview table.

Group \*
   Select which :doc:`../users-groups-roles/groups` can access the chat channel.

Available to customer users
   Select the checkbox if you want to display the chat channel for customer users.

Available to public users
   Select the checkbox if you want to display the chat channel for public users.

Validity \*
   Set the validity of this resource. Each resource can be used in OTRS only, if this field is set to *valid*. Setting this field to *invalid* or *invalid-temporarily* will disable the use of the resource.

Comment
   Add additional information to this resource. It is recommended to always fill this field as a description of the resource with a full sentence for better clarity, because the comment will be also displayed in the overview table.
