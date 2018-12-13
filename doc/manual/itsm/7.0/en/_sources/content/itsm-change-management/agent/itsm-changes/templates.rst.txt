Templates
=========

Use this screen to manage templates for ITSM changes. The template management screen is available in the *Templates* menu item of the *ITSM Changes* menu.

.. figure:: images/itsm-changes-template-management.png
   :alt: Template Management Screen

   Template Management Screen

Templates can be filtered by clicking on a type name in the header of the overview widget. There is an option *All* to see all templates. The numbers after the type names indicates how many templates are in each types.

.. seealso::

   See setting ``ITSMChange::Frontend::AgentITSMTemplateOverview###Filter::TemplateTypes`` to define the template types that will be used as filters in the overview.

To add a new template:

1. Go to the :doc:`new` ITSM change screen.
2. Create new changes, work orders or CABs.
3. Click on the *Template* menu item to save it as template.

To edit basic information of a template:

1. Click on the template name in the list of templates.
2. Modify the fields.
3. Click on the *Save* button.

.. figure:: images/itsm-changes-template-edit-basic.png
   :alt: Edit Template Basic Information Screen

   Edit Template Basic Information Screen

To edit the content of a template:

1. Click on the pencil icon in the *Edit Content* column.
2. Click on the *Yes* button in the confirmation dialog.
3. Modify the created change.
4. Click on the *Template* menu item to save it as template.

.. figure:: images/itsm-changes-template-edit-content.png
   :alt: Edit Template Content Screen

   Edit Template Content Screen

.. note::

   This will create a new change from this template, so you can edit and save it. The new change will be deleted automatically after it has been saved as template. 

To delete a template:

1. Click on the trash icon in the list of templates.
2. Click on the *Yes* button.

.. figure:: images/itsm-changes-template-delete.png
   :alt: Delete Template Screen

   Delete Template Screen

The displayed attributes can be defined via the system configuration. Not all attributes are displayed by default. The possible attributes are:

``ChangeBy``
   Username of the agent who last modified the template.

``ChangeTime``
   Date and time at which the template was modified.

``Comment``
   Comments or description of the template.

``CreateBy``
   Username of the agent who created the template.

``CreateTime``
   Date and time at which the template was created.

``Delete``
   Option to delete a chosen template.

``EditContent``
   Option to edit the content of a chosen template.

``Name``
   Name of the template.

``Type``
   Type of the template.

``Valid``
   Validity of the template. Templates with *invalid* or *invalid-temporarily* validity cannot be used by change builders.

.. seealso::

   See setting ``ITSMChange::Frontend::AgentITSMTemplateOverview###ShowColumns`` to define the displayed attributes.
