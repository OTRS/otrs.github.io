Customers
=========

Use this screen to add customer companies to the system. A fresh OTRS installation contains no customers by default. The customer management screen is available in the *Customers* module of the *Users, Groups & Roles* group.

.. figure:: images/customer-management.png
   :alt: Customer Management Screen

   Customer Management Screen


Manage Customers
----------------

.. note::

   Adding or editing a customer is possible only by using database backend. Using external directory services like LDAP will disable the customer management functionality.

To add a customer:

1. Click on the *Add Customer* button in the left sidebar.
2. Fill in the required fields.
3. Click on the *Save* button.

.. figure:: images/customer-add.png
   :alt: Add Customer Screen

   Add Customer Screen

.. warning::

   Customers can not be deleted from the system. They can only be deactivated by setting the *Validity* option to *invalid* or *invalid-temporarily*.

To edit a customer:

1. Click on a customer in the list of customers.
2. Modify the fields.
3. Click on the *Save* or *Save and finish* button.

.. figure:: images/customer-edit.png
   :alt: Edit Customer Screen

   Edit Customer Screen

To find a customer:

1. Enter a search term to the search box in the left sidebar.
2. Click on the magnifying glass icon in the right part of the field or hit an ``Enter``. 

.. note::

   If several customers are added to the system, use the search box to find a particular agent. Only the first 1000 customers are listed by default.


Customer Settings
-----------------

The following settings are available when adding or editing this resource. The fields marked with an asterisk are mandatory.

Customer ID \*
   The internal name of the customer. Should contain only letters, numbers and some special characters.

Customer \*
   The name of this resource. Any type of characters can be entered to this field including uppercase letters and spaces. The name will be displayed in the overview table.

Street
   The street name of the customer.

Zip
   The zip code of the customer.

City
   The headquarter city of the customer.

Country
   The country of the customer. Choose a country from the list.

URL
   The web page or other URL of the customer.

Comment
   Add additional information to this resource. It is recommended to always fill this field as a description of the resource with a full sentence for better clarity, because the comment will be also displayed in the overview table.

Validity \*
   Set the validity of this resource. Each resource can be used in OTRS only, if this field is set to *valid*. Setting this field to *invalid* or *invalid-temporarily* will disable the use of the resource.

