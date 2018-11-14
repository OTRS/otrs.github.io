Process Management
==================

Maximizing performance while minimizing human error is a requirement of organizations of all sizes. This need is covered by defined processes and workflows, for recurring tasks. Ensuring all required information is available in the right place, and contacts are informed about their responsibilities like adding information, approving requests, etc.

OTRS supports this requirement by Process Management. Process tickets help by using the required mandatory and optional fields (see Dynamic Fields) that information is not forgotten upon ticket creation or during later steps of the process. Process tickets are simple to handle for customer users and agents, so no intensive training is required.

Processes are designed completely and efficiently within the OTRS font end to fit the requirements of your organization.

Use this screen to manage processes in the system. The process management screen is available in the *Process Management* module of the *Processes & Automation* group.


Manage Processes
----------------

To create a new process:

1. Click on the *Create New Process* button in the left sidebar.
2. Fill in the required fields.
3. Click on the *Save* button.
4. Add activities, user task activity dialogs, sequence flows and sequence flow actions.
5. Set *State* to *Active*.
6. Deploy all processes.

.. figure:: images/process-management-add.png
   :alt: Create New Process Screen

   Create New Process Screen

To edit a process:

1. Click on a process in the list of processes.
2. Modify the fields and the process path.
3. Click on the *Save* or *Save and finish* button.
4. Deploy all processes.

To copy a process:

1. Click on the copy icon in the fifth column of list of processes.
2. Click on the newly created process to edit it.

To delete a process:

1. Click on a process in the list of processes.
2. Set the *State* option to *Inactive*.
3. Click on the *Save* button. A new *Delete Inactive Process* button will appear in the left sidebar.
4. Click on the *Delete Inactive Process* button.
5. Click on the *Delete* button in the confirmation screen.
6. Deploy all processes.

.. warning::

   Processes are written into file in Perl format. Without deploying, all processes are still in this cache file even if they are deleted or the *State* option is set to *Inactive* or *FadeAway*. Don't forget to deploy all processes after modifications!

To deploy all processes:

1. Click on the *Deploy All Processes* button in the left sidebar.

.. note::

   New or modified processes have to deploy in order to make affect the behavior of the system. Setting the *State* option to *Active* just indicates, which processes should be deployed.

To export a process:

1. Click on the export icon in the fourth column of list of processes.
2. Choose a location in your computer to save the ``Export_ProcessEntityID_xxx.yml`` file.

.. note::

   The exported file contains only the process itself, and doesn't contain the :doc:`../ticket-settings/queues`, :doc:`../users-groups-roles/agents` and :doc:`dynamic-fields`, etc. needed for the process.

To import a process:

1. Click on the *Browse…* button of the *Configuration Import* widget in the left sidebar.
2. Select a previously exported ``.yml`` file.
3. Click on the *Import process configuration* button.
4. Deploy all processes.

.. note::

   Before import a process, it is still necessary to create all :doc:`../ticket-settings/queues`, :doc:`../users-groups-roles/agents` and :doc:`dynamic-fields`, as well as to set :doc:`../administration/system-configuration`, that are needed by each process before the import. If the process requires the use of :doc:`access-control-lists` those are also needed to be set manually.

.. note::

   If several processes are added to the system, use the filter box to find a particular process by just typing the name to filter.


Example process
---------------

Processes are more complex than other resources in OTRS. To create a process, you need to do several steps. The following chapters shows you, how to define a process from the specification and create the needed resources. Let's see an example to make it more demonstrative. We will define a book order process.


Process Specification
~~~~~~~~~~~~~~~~~~~~~

The book order process has four states.

Recording the demand
   Before an order will be placed, the demand for literature by an employee will be recorded. The following book is needed in our example:

   ::

      Title: Prozessmanagement für Dummies
      Autor: Thilo Knuppertz
      ISBN: 3527703713
                
Approval by manager
   The head of the employee's department needs to decide on the order. In case of a denial, a reason should be recorded by the manager. In case of approval, the order is passed to the purchasing department.

Processing by purchasing department
   Purchasing now has the task to find out where the book can be ordered with the best conditions. If it is out of stock, this can be recorded in the order. In case of a successful order purchasing will record the supplier, the price and the delivery date.

Processing by the mail room
   The shipment will arrive at the company. The incoming goods department checks the shipment and records the date of receipt. Now the employee will be informed that their order has arrived and is ready to be collected.


Introduce The Process Elements
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

If we assume that a ticket acts in this workflow like an accompanying document that can receive change notes, we already have a clear picture of process tickets.

From the analysis of the example process we can identify the following necessary items:

- Possibility to record data, let's call this :term:`user task activity dialog`.
- Check which can react to changed data automatically, let's call this :term:`sequence flow`.
- Change which can be applied to a process ticket after successful transitions of a process ticket, let's call this :term:`sequence flow action`. 
- A possibility to offer more than just one user task activity dialog to be available. In our example this is needed when the manager must have the choice between *Approve* and *Deny*. Let's call this :term:`activity`. 

Now, with activities, user task activity dialogs, sequence flows and sequence flow actions we have the necessary tools to model the individual steps of our example. What is still missing is an area where for each workflow the order of the steps can be specified. Let's call this :term:`process`.


Create necessary resources
~~~~~~~~~~~~~~~~~~~~~~~~~~

Before the creation of the process and its parts is necessary to prepare the system. We need to define some :doc:`../ticket-settings/queues`, :doc:`../users-groups-roles/agents` and :doc:`dynamic-fields` as well as set some :doc:`../administration/system-configuration` settings.

Create the following :doc:`../ticket-settings/queues`:

- Management
- Employees
- Purchasing
- Post office

Create the following :doc:`../users-groups-roles/agents`:

- Manager
- Employee

Create the following :doc:`dynamic-fields`:

+--------+----------+---------------+-----------------+---------------------+
| Object | Type     | Name          | Label           | Possible values     |
+========+==========+===============+=================+=====================+
| Ticket | Text     | Title         | Title           |                     |
+--------+----------+---------------+-----------------+---------------------+
| Ticket | Text     | Author        | Author          |                     |
+--------+----------+---------------+-----------------+---------------------+
| Ticket | Text     | ISBN          | ISBN            |                     |
+--------+----------+---------------+-----------------+---------------------+
| Ticket | Dropdown | Status        | Status          | - Approval          |
|        |          |               |                 | - Approval denied   |
|        |          |               |                 | - Approved          |
|        |          |               |                 | - Order denied      |
|        |          |               |                 | - Order placed      |
|        |          |               |                 | - Shipment received |
+--------+----------+---------------+-----------------+---------------------+
| Ticket | Text     | Suplier       | Suplier         |                     |
+--------+----------+---------------+-----------------+---------------------+
| Ticket | Text     | Price         | Price           |                     |
+--------+----------+---------------+-----------------+---------------------+
| Ticket | Date     | DeliveryDate  | Delivery date   |                     |
+--------+----------+---------------+-----------------+---------------------+
| Ticket | Date     | DateOfReceipt | Date of receipt |                     |
+--------+----------+---------------+-----------------+---------------------+

Set the the following :doc:`../administration/system-configuration` settings:

- :sysconfig:`Ticket::Responsible <core.html#ticket-responsible>`

   - Enabled

- :sysconfig:`Ticket::Frontend::AgentTicketZoom###ProcessWidgetDynamicFieldGroups <frontend.html#ticket-frontend-agentticketzoom-processwidgetdynamicfieldgroups>`

   - Book → Title,Author,ISBN
   - General → Status
   - Order → Price,Supplier,DeliveryDate
   - Shipment → DateOfReceipt

- :sysconfig:`Ticket::Frontend::AgentTicketZoom###ProcessWidgetDynamicField <frontend.html#ticket-frontend-agentticketzoom-processwidgetdynamicfield>`

   - Author →  1 - Enabled
   - DateOfReceipt →  1 - Enabled
   - DeliveryDate →  1 - Enabled
   - ISBN →  1 - Enabled
   - Price →  1 - Enabled
   - Status →  1 - Enabled
   - Supplier →  1 - Enabled
   - Title →  1 - Enabled

.. note::

   Don't forget to deploy the modified system configuration settings.

Now, go back to the *Process Management* screen and click on the *Create New Process*. Fill in the required fields.

.. figure:: images/process-management-book-ordering-01-create.png
   :alt: Book Ordering - Create New Process

   Book Ordering - Create New Process

The new process is created. You can add some process element now.


Create User Task Activity Dialogs
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Click on the *User Task Activity Dialogs* item in the *Available Process Elements* widget in the left sidebar. This action will expand the *User Task Activity Dialogs* options and will collapse all others doing an accordion like effect. Click on the *Create New User Task Activity Dialog* button.

.. figure:: images/process-management-book-ordering-02-user-task-activity-dialogs.png
   :alt: Book Ordering - User Task Activity Dialogs

   Book Ordering - User Task Activity Dialogs

In the opened popup screen fill in the *Dialog Name* as well as the *Description (short)* fields. For this example we will leave all other fields as the default.

.. figure:: images/process-management-book-ordering-03-user-task-activity-dialog-add.png
   :alt: Book Ordering - Add User Task Activity Dialog

   Book Ordering - Add User Task Activity Dialog

To assign fields to the user task activity dialog simple drag the required field from the *Available Fields* pool and drop into the *Assigned Fields* pool. The order in the *Assigned Fields* pool is the order as the fields will have in the screen, to modify the order simply drag and drop the field within the pool to rearrange it in the correct place.

In this example we will use:

- *Article* field for comments.
- *DynamicField_Title*, *DynamicField_Author*, *DynamicField_ISBN* fields for the data to be collected for the order.
- *DynamicField_Status* with the possibility to choose *Approval*.

Drag these fields from the *Available Fields* pool and drop into the *Assigned Fields* pool.

.. note::

   In this screen all the dynamic fields has the prefix *DynamicField_* as in *DynamicField_Title*. Do not confuse with the field *Title* that is the ticket title.

.. figure:: images/process-management-book-ordering-04-user-task-activity-dialog-fields.png
   :alt: Book Ordering - Add User Task Activity Dialog Fields

   Book Ordering - Add User Task Activity Dialog Fields

As soon as the fields are dropped into the *Assigned Fields* pool another popup screen is shown with some details about the field. We will leave the default options and only for *Article* fields we should make sure that the *Communication Channel* field is set to *OTRS* and that the *Is visible for customer* is not checked.

 .. figure:: images/process-management-book-ordering-05-user-task-activity-dialog-fields-edit.png
   :alt: Book Ordering - Edit User Task Activity Dialog Fields

   Book Ordering - Edit User Task Activity Dialog Fields

After all fields are filled in, click on the *Save and finish* button to save the changes and go back to the project management screen.

Create the following user task activity dialogs with fields:

- *Recording the demand* (already created before)

   - *Article* field for comments.
   - *DynamicField_Title*, *DynamicField_Author*, *DynamicField_ISBN* fields for the data to be collected for the order.
   - *DynamicField_Status* with the possibility to choose *Approval*.

- *Approval denied*

   - *Article* field for comments.
   - *DynamicField_Status* with the possibility to choose *Approval denied*.

- *Approved*

   - *DynamicField_Status* with the possibility to choose *Approved*.

- *Order denied*

   - *Article* field for comments.
   - *DynamicField_Status* with the possibility to choose *Order denied*.

- *Order placed*

   - *DynamicField_Supplier*, *DynamicField_Price*, *DynamicField_DeliveryDate* fields for purchasing.
   - *DynamicField_Status* with the possibility to choose *Order placed*.

- *Shipment received*

   - *DynamicField_DateOfReceipt* for the mail room.
   - *DynamicField_Status* with the possibility to choose *Shipment received*.


Create Sequence Flows
~~~~~~~~~~~~~~~~~~~~~

Click on the *Sequence Flows* item in the *Available Process Elements* widget in the left sidebar. This action will expand the *Sequence Flows* options and will collapse all others doing an accordion like effect. Click on the *Create New Sequence Flow* button.

.. figure:: images/process-management-book-ordering-06-sequence-flows.png
   :alt: Book Ordering - Sequence Flows

   Book Ordering - Sequence Flows

In the opened popup screen fill in the *Sequence Flow Name*. For this example in the *Condition Expressions* we will use just one condition expression and just one field, for both we can leave the *Type of Linking* as *and* and we will use the filed match type value as *String*.

.. figure:: images/process-management-book-ordering-07-sequence-flow-add.png
   :alt: Book Ordering - Add Sequence Flow

   Book Ordering - Add Sequence Flow

After all fields are filled in, click on the *Save and finish* button to save the changes and go back to the project management screen.

Create the following sequence flows:

- *Approval* (already created before)

   Check if the *DynamicField_Status* is set to *Approval*.

- *Approval denied*

   Check if the *DynamicField_Status* field is set to *Approval denied*.

- *Approved*

   Check if the *DynamicField_Status* field is set to *Approved*.

- *Order denied*

   Check if the *DynamicField_Status* field is set to *Order denied*.

- *Order placed*

   Check if the *DynamicField_Status* field is set to *Order placed*.

- *Shipment received*

   Check if the *DynamicField_Status* field is set to *Shipment received*.


Create Sequence Flow Actions
~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Click on the *Sequence Flow Actions* item in the *Available Process Elements* widget in the left sidebar. This action will expand the *Sequence Flow Actions* options and will collapse all others doing an accordion like effect. Click on the *Create New Sequence Flow Action* button.

.. figure:: images/process-management-book-ordering-08-sequence-flow-actions.png
   :alt: Book Ordering - Sequence Flow Actions

   Book Ordering - Sequence Flow Actions

In the opened popup screen fill in the *Sequence Flow Action Name* and the *Sequence Flow Action module* then click on the *Save* button. A new *Configure* button will appear next to the module field.

.. figure:: images/process-management-book-ordering-09-sequence-flow-action-add.png
   :alt: Book Ordering - Add Sequence Flow Action

   Book Ordering - Add Sequence Flow Action

Click on the *Configure* button and add the needed configuration parameter keys and values.

.. figure:: images/process-management-book-ordering-10-sequence-flow-action-parameters.png
   :alt: Book Ordering - Sequence Flow Action Parameters

   Book Ordering - Sequence Flow Action Parameters

After all fields are filled in, click on the *Save and finish* button to save the changes and go back to the project management screen.

.. seealso::

   Each module has its own and different parameters. Please review the module documentation to learn all require and optional parameters.

   - `DynamicFieldSet <http://doc.otrs.com/doc/api/otrs/7.0/Perl/Kernel/System/ProcessManagement/Modules/DynamicFieldSet.pm.html>`_
   - `TicketArticleCreate <http://doc.otrs.com/doc/api/otrs/7.0/Perl/Kernel/System/ProcessManagement/Modules/TicketArticleCreate.pm.html>`_
   - `TicketCreate <http://doc.otrs.com/doc/api/otrs/7.0/Perl/Kernel/System/ProcessManagement/Modules/TicketCreate.pm.html>`_
   - `TicketCustomerSet <http://doc.otrs.com/doc/api/otrs/7.0/Perl/Kernel/System/ProcessManagement/Modules/TicketCustomerSet.pm.html>`_
   - `TicketLockSet <http://doc.otrs.com/doc/api/otrs/7.0/Perl/Kernel/System/ProcessManagement/Modules/TicketLockSet.pm.html>`_
   - `TicketOwnerSet <http://doc.otrs.com/doc/api/otrs/7.0/Perl/Kernel/System/ProcessManagement/Modules/TicketOwnerSet.pm.html>`_
   - `TicketQueueSet <http://doc.otrs.com/doc/api/otrs/7.0/Perl/Kernel/System/ProcessManagement/Modules/TicketQueueSet.pm.html>`_
   - `TicketResponsibleSet <http://doc.otrs.com/doc/api/otrs/7.0/Perl/Kernel/System/ProcessManagement/Modules/TicketResponsibleSet.pm.html>`_
   - `TicketSendEmail <http://doc.otrs.com/doc/api/otrs/7.0/Perl/Kernel/System/ProcessManagement/Modules/TicketSendEmail.pm.html>`_
   - `TicketServiceSet <http://doc.otrs.com/doc/api/otrs/7.0/Perl/Kernel/System/ProcessManagement/Modules/TicketServiceSet.pm.html>`_
   - `TicketSLASet <http://doc.otrs.com/doc/api/otrs/7.0/Perl/Kernel/System/ProcessManagement/Modules/TicketSLASet.pm.html>`_
   - `TicketStateSet <http://doc.otrs.com/doc/api/otrs/7.0/Perl/Kernel/System/ProcessManagement/Modules/TicketStateSet.pm.html>`_
   - `TicketTitleSet <http://doc.otrs.com/doc/api/otrs/7.0/Perl/Kernel/System/ProcessManagement/Modules/TicketTitleSet.pm.html>`_
   - `TicketTypeSet <http://doc.otrs.com/doc/api/otrs/7.0/Perl/Kernel/System/ProcessManagement/Modules/TicketTypeSet.pm.html>`_

   All the sequence flow action modules are located in the legacy named ``Kernel/System/ProcessManagement/TransitionAction``.

Create the following sequence flow actions:

- *Move the process ticket into the "Management" queue* (already created before)

   This action is supposed to be executed when the sequence flow *Approval* applied.

- *Change ticket responsible to "Manager"*

   To be executed when the sequence flow *Approval* applied.

- *Move process ticket into the "Employees" queue*

   To be executed when:

   - The sequence flow *Approval denied* applied.
   - The sequence flow *Order denied* applied.
   - The sequence flow *Shipment received* applied.

- *Change ticket responsible to "Employee"*

   To be executed when:

   - The sequence flow *Approval denied* applied.
   - The sequence flow *Order denied* applied.
   - The sequence flow *Shipment received* applied.

- *Move process ticket into the "Purchasing" queue*

   To be executed when the sequence flow *Approved* applied.

- *Move process ticket into the "Post office" queue*

   To be executed when the sequence flow *Order placed* applied.

- *Close ticket successfully*

   To be executed when the sequence flow *Shipment received* applied.

- *Close ticket unsuccessfully*

   To be executed when:

   - The sequence flow *Approval denied* applied.
   - The sequence flow *Order denied* applied.

There are places where the same sequence flow actions should be executed. Therefore it is reasonable to make it possible to link sequence flow actions freely with sequence flows to be able to reuse them.


Create Activities
~~~~~~~~~~~~~~~~~

Click on the *Activities* item in the *Available Process Elements* widget in the left sidebar. This action will expand the *Activities* options and will collapse all others doing an accordion like effect. Click on the *Create New Activity* button.

.. figure:: images/process-management-book-ordering-11-activities.png
   :alt: Book Ordering - Activities

   Book Ordering - Activities

In the opened popup screen fill in the *Activity name* field and select *User task activity* from the *Activity type* dropdown.

.. figure:: images/process-management-book-ordering-12-activity-add.png
   :alt: Book Ordering - Add Activity

   Book Ordering - Add Activity

To assign dialogs to the activity simple drag the required dialogs from the *Available User Task Activity Dialogs* pool and drop into the *Assigned User Task Activity Dialogs* pool. The order in the *Assigned User Task Activity Dialogs* pool is the order as the dialogs will be presented in the ticket zoom screen. To modify the order simply drag and drop the field within the pool to rearrange it in the correct place.

.. note::

   This order is specially important in the first activity, since the first user task activity dialog for this activity is the only one that is presented when the process starts.

In this example we need to assign only the *Recording the demand* user task activity dialog. Drag this dialog from the *Available User Task Activity Dialogs* pool and drop into the *Assigned User Task Activity Dialogs* pool.

.. figure:: images/process-management-book-ordering-13-activity-assign-user-task-activity-dialog.png
   :alt: Book Ordering - Assign User Task Activity Dialog

   Book Ordering - Assign User Task Activity Dialog

After all fields are filled in, click on the *Save and finish* button to save the changes and go back to the project management screen.

Create the following activities:

- *Recording the demand* (already created before)

   Assign the user task activity dialog *Recording the demand*.

- *Approval*

   Assign the user task activity dialogs *Approval denied* and *Approved*.

- *Order*

   Assign the user task activity dialogs *Order denied* and *Order placed*.

- *Incoming*

   Assign the user task activity dialog *Shipment received*.

- *Process complete*

   This is an activity without possible user task activity dialogs. It will be set after *Approval denied*, *Order denied* or *Shipment received* and represents the end of the process.

Now we can clearly see that activities are precisely defined states of a process ticket. After a successful sequence flow a process ticket moves from one activity to another.


Create Process Path
~~~~~~~~~~~~~~~~~~~

Let us conclude our example with the last missing piece in the puzzle, the process as the a flow describer. In our case this is the whole ordering workflow. Other processes could be office supply ordering or completely different processes.

The process has a starting point which consists of the start activity and the start user task activity dialog. For any new book order, the first user task activity dialog of the first activity is the first screen that is displayed. If this is completed and saved, the process ticket will be created and can follow the configured workflow.

The process also contains the directions for how the process ticket can move through the process. Let's call this :term:`process path`. It consists of the start activity, one or more sequence flows (possibly with sequence flow actions) and other activities.

Assuming that the activities has already assigned their user task activity dialogs, drag an activity from the accordion in the *Available Process Elements* widget in the left sidebar and drop it into the canvas area below the process information. Notice that an arrow from the process start (white circle) to the activity is placed automatically. This is the first activity and its first user task activity dialog is the first screen that will be shown when the process starts.

.. figure:: images/process-management-book-ordering-14-canvas-first-activity.png
   :alt: Book Ordering - First Activity On Canvas

   Book Ordering - First Activity On Canvas

Next, drag another activity into the canvas too. Now we will have two activities in the canvas. The first one is connected to the start point and the second has no connections. You can hover the mouse over each activity to reveal their own activity dialogs.

.. figure:: images/process-management-book-ordering-15-canvas-second-activity.png
   :alt: Book Ordering - Second Activity On Canvas

   Book Ordering - Second Activity On Canvas

Then let's create the process path (connection) between this two activities. For this we will use the sequence flows. Click on sequence flow in the accordion, drag a sequence flow and drop it inside the first activity. As soon as the sequence flow is dropped the end point of the sequence flow arrow will be placed next to the process start point. Drag the sequence flow arrow end point and drop it inside the other activity to create the connection between the activities.

.. figure:: images/process-management-book-ordering-16-canvas-first-sequence-flow.png
   :alt: Book Ordering - First Sequence Flow On Canvas

   Book Ordering - First Sequence Flow On Canvas

Now that the process path between the actions is defined, then we need to assign the sequence flow actions to the sequence flow. Double click the sequence flow label in the canvas to open a new popup window.

.. figure:: images/process-management-book-ordering-17-assign-first-sequence-flow-action.png
   :alt: Book Ordering - Assign First Sequence Flow Action

   Book Ordering - Assign First Sequence Flow Action

After the sequence flow actions are assigned, click on the *Save* button to go back to the main process edit screen. Click on *Save* button below the canvas to save all other changes.

Complete the process path adding the following activities, sequence flows and sequence flow actions:

- *Recording the demand* (already created before)

   Possible sequence flow: *Approval*

   Starting activity: *Recording the demand*

   Next activity: *Approval*

   If the condition of this activity is fulfilled, the ticket will move to activity *Approval*.

   Additionally, the following sequence flow actions are executed:

      - *Move the process ticket into the "Management" queue*
      - *Change ticket responsible to "Manager"*

   The activity *Recording the demand* is a defined step of the process ticket, where there is the possibility for the sequence flow *Approval*. If this applies, the ticket will move to the next activity *Approval*, and the sequence flow actions *Move the process ticket into the "Management" queue* and *Change ticket responsible to "Manager"* are executed. In the activity *Approval*, the user task activity dialogs *Approval denied* and *Approved* are available.

- *Approval*

   Possible sequence flow: *Approval denied*

   Starting activity: *Approval*

   Next activity: *Process complete*

   If this matches, the process ticket will move to activity *Process complete*.

   Additionally, the following sequence flow actions are executed:

      - *Move process ticket into the "Employees" queue*
      - *Change ticket responsible to "Employee"*
      - *Close ticket unsuccessfully*

   Possible sequence flow: *Approved*

   Starting activity: *Approval*

   Next activity: *Order*

   If this matches, the process ticket will move to activity *Order*.

   Additionally, the following sequence flow actions are executed:

      - *Move process ticket into the "Purchasing" queue*

   We can see that from the current activity, which defines a step of the process ticket, there are one or more possibilities for sequence flow which have exactly one target activity (and possibly one or more sequence flow actions).

- *Order*

   Possible sequence flow: *Order denied*

   Starting activity: *Order*

   Next activity: *Process complete*

   If this matches, the process ticket will move to activity *Process complete*.

   Additionally, the following sequence flow actions are executed:

      - *Move process ticket into the "Employees" queue*
      - *Set ticket responsible to "Employee"*
      - *Close ticket unsuccessfully*

   Possible sequence flow: *Order placed*

   Starting activity: *Order*

   Next activity: *Incoming*

   If this matches, the process ticket will move to activity *Incoming*.

   Additionally, the following sequence flow actions are executed:

      - *Move process ticket into the "Post office" queue*

- *Incoming*

   Possible sequence flow: *Shipment received*

   Starting activity: *Incoming*

   Next activity: *Process complete*

   If this matches, the process ticket will move to activity *Process complete*.

   Additionally, the following sequence flow actions are executed:

      - *Move process ticket into the "Employees" queue*
      - *Set ticket responsible to "Employee"*
      - *Close ticket successfully*

The complete process path for the book ordering process will then look like this:

.. figure:: images/process-management-book-ordering-18-process-complete.png
   :alt: Book Ordering - Process Complete

   Book Ordering - Process Complete

After you finish the process path, click on *Save and finish* button below the canvas to go back to the process management screen.

Click on the *Deploy All Processes* button in the left sidebar. This will gather all processes information form the database and create a cache file (in Perl language). This cache file is actually the processes configuration that the system will use to create or use process tickets.

.. note::

   Any change that is made of the process will require to re-deploy the process in order to get the change reflected in the system.
