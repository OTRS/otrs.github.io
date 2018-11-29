Package Porting
===============

With every new minor or major version of OTRS, you need to port your packages and make sure they still work with the OTRS API.

This section lists changes that you need to examine when porting your package from OTRS 6 to 7.


Sessions Always Require Cookies
-------------------------------

Starting from OTRS 7, `sessions always require cookies to be enabled <https://github.com/OTRS/otrs/commit/831aba1cfe6893d0633af6f18584216e89198072>`__. Therefore, the ``SessionIDCookie`` value was removed from ``LayoutObject``, :doc:`../how-it-works/templates` and JavaScript. It is no longer necessary to append session variables to URLs or HTTP request payloads.

The ``groups`` Table Was Renamed
--------------------------------

Due to a change in MySQL 8, the table ``groups`` had to be renamed to ``groups_table``. If you use this table directly in any SQL statements, they will need to be adapted. For more information, see `bug#13866 <https://bugs.otrs.org/show_bug.cgi?id=13866>`__.


New External Interface
----------------------

The existing customer (``customer.pl``) and public (``public.pl``) interfaces were replaced by a new REST backend (``Kernel/WebApp``) and a modern Vue.js based frontend application. This means that all related code has to be ported and/or rewritten.

There is one special case for public front end modules that don't serve an HTML application. These can be ported rather easily to the new REST backend (see also `the REST API docs <http://doc.otrs.com/doc/api/otrs/7.0/REST/>`__). See for example ``Kernel/WebApp/Controller/API/Public/Package/Repository.pm``. This example also shows how endpoints can support both new REST-like URLs but at the same time the legacy URLs based on the ``/otrs/customer.pl?Action=MyAction`` routes at the same time.

For some important URLs in the customer interface that are linked from legacy systems, redirect controllers may need to be provided to make sure the old URLs keep working.


Changes in Process Management
-----------------------------

The migration script ``scripts/DBUpdate-to-7.pl`` will upgrade all processes that are already in the database. Manual action is only needed to make use of any new features that OTRS 7 provides.


New Activity Types
~~~~~~~~~~~~~~~~~~

Since OTRS 7 is capable of managing more activity types, all existing activities now become *User Task* activities. To update a task definition on a YAML file, please add ``Type: UserTask`` with the same indentation as ``Name`` or ``ID``.


Renamed Process Management Components 
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

``Transition`` to ``SequenceFlow``
   This process component was renamed to be more aligned with BPMN. Files, classes and methods has been renamed accordingly. Customized files needs to be updated following the new conventions.

``TransitionAction`` to ``SequenceFlowAction``
   This process component does not exists in BPMN but has to be also renamed to be consistent with the other changes. Files, classes and methods has been renames accordingly. Customized files needs to be updated following the new conventions.

``TransitionActionModules`` to ``ProcessManagementModules``
   This process components are not only used by *Sequence Flow Actions* but also for *Script Tasks* activities and has been moved from ``Kernel/System/ProcessManagement/TransitionAction`` to ``Kernel/System/ProcessManagement/Modules``.

The new process management modules can offer more field types and options to present the parameters to the process designer, please follow the instructions in the :doc:`../how-to-extend-otrs/otrs-module-layers/process-management-modules` documentation to learn more about this new feature and how to improve existing modules.

It is needed to update any shipped process definitions to use the new name schema.

- Replace ``Transition`` with ``SequenceFlow``.
- Replace ``Transitions`` with ``SequenceFlows``.
- Replace ``TransitionAction`` with ``SequenceFlowAction``.
- Replace ``TransitionActions`` with ``SequenceFlowActions``.
- Remove ``Kernel::System::ProcessManagement::TransitionAction`` from the ``Module:`` on all ``SequenceFlowAction``. For example: ``Module: Kernel::System::ProcessManagement::TransitionAction::TicketLockSet`` should become ``Module: TicketLockSet``.


Changes in the ``LayoutObject``
-------------------------------

There are changes in ``Kernel/Output/HTML/Layout.pm`` which are necessary to properly render content using Mojolicious real-time web framework.


Not Shown/Empty Tables in Screens
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Please make sure to check every screen which produces table-like output (e.g. ``Kernel/Modules/AgentTicketStatusView.pm``). If the list of e.g. tickets is empty or even not shown at all, check if the parameter ``Output => 1`` is used in creating the output for the page.


Encoding Issues in Legacy Front End Modules
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

If you are getting into trouble with broken characters like umlauts, it could be that the content which is meant to be shown is rendered by the ``Print()`` method. To fix this, please switch the code from using the ``Print()`` method to the normal way of returning the complete response from the frontend module.
