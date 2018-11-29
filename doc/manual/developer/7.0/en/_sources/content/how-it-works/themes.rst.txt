Creating Your Own Themes
========================

You can create your own themes so as to use the layout you like in the OTRS web frontend. To create custom themes, you should customize the output templates to your needs. More information on the syntax and structure of output templates can be found in the :doc:`templates`.

As an example, perform the following steps to create a new theme called *Company*:

1. Create a directory called ``Kernel/Output/HTML/Templates/Company`` and copy all files that you like to change from ``Kernel/Output/HTML/Templates/Standard`` into the new folder.

   .. note::

      Only copy over the files you're planning to change. OTRS will automatically get the missing files from the Standard theme. This will make upgrading at a later stage much easier.

2. Customize the files in the directory ``Kernel/Output/HTML/Templates/Company`` and change the layout to your needs.
3. To activate the new theme, add them in system configuration under ``Frontend::Themes``.

Now the new theme should be usable. You can select it via your personal preferences.

.. warning::

   Do not change the theme files shipped with OTRS, since these changes will be lost after an update. Create your own themes only by performing the steps described above.
