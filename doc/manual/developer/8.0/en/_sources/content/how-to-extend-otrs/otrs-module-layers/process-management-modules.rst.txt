Process Management
==================

Since OTRS 7 process management can use script modules to perform activities (script tasks) and/or sequence flow actions (know before as transition actions). This modules are located in ``Kernel::System::ProcessManagement::Modules``.


Process Management Modules
--------------------------

The process management modules are scripts written in Perl language to perform certain action or actions over the process ticket like set a dynamic field or change a queue etc. Or any other part of the system like create new tickets.

By default modules uses a set of key value pairs to use them as parameters for the action e.g. to change queue of the process ticket, the queue or queue id and its corresponding value is needed.

Some scripts might require more than a simple key value pairs as parameters or its configuration might need to have a more user friendly GUI, in such cases OTRS provides some configuration field types that can be also extended if needed.

Current field types:

Dropdown
   Shows a drop down list with predefined values.

Key-value list
   Shows a list of simple key value pairs (text inputs). Pairs can be added or deleted.

Multi language Rich Text
   Shows a Rich Text editor associated to a system language, also shows a language selector to add rich text fields for the proper selected language.

Recipients
   Shows a multi select field pre-filled with agents to be used as email recipients, also displays a free input field to be used to specify external email addresses to be added to the recipients list.

Rich Text
   Shows a single Rich Text field.


Creating a New Process Management Module
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

The following is an example of how to create a process management module, it includes a section where all possible fields are defined as a reference, to create a new module only one field type is needed but consider that by convention the parameter user ID is used to impersonate all the actions in the module with another user than the one that triggers the action, then it is a good practice to always include the key-value list field type along with any other needed field.

Process Management Module Code Example
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The following code implements a dummy process management module that can be used in script task activities or sequence flow actions.

.. code-block:: Perl

   # --
   # Copyright (C) 2001-2018 OTRS AG, https://otrs.com/
   # --
   # This software comes with ABSOLUTELY NO WARRANTY. For details, see
   # the enclosed file COPYING for license information (GPL). If you
   # did not receive this file, see https://www.gnu.org/licenses/gpl-3.0.txt.
   # --

   package Kernel::System::ProcessManagement::Modules::Test;

   use strict;
   use warnings;
   use utf8;

   use Kernel::System::VariableCheck qw(:all);

   use parent qw(Kernel::System::ProcessManagement::Modules::Base);

   our @ObjectDependencies = ( );

This is common header that can be found in most OTRS modules. The class/package name is declared via the ``package`` keyword.

In this case we are inheriting from ``Base`` class, and the object manager dependencies are set.

.. code-block:: Perl

   sub new {
       my ( $Type, %Param ) = @_;

       # Allocate new hash for object.
       my $Self = {};
       bless( $Self, $Type );

       $Self->{Config} = {
           Description => 'Description for the module.',
           ConfigSets  => [
               {
                   Type        => 'Dropdown',
                   Description => 'Description for Dropdown.',
                   Mandatory   => 1,
                   Config      => {
                       Data => {
                           Internal1 => 'Display 1',
                           Internal2 => 'Display 2',
                       },
                       Name         => 'Test-DropDown',
                       Multiple     => 1,
                       PossibleNone => 1,
                       Sort         => 'AlphanumericValue',
                       Translation  => 1,
                   },
               },
               {
                   Type        => 'KeyValueList',
                   Description => 'Description of the Key/Value pairs',
                   Defaults    => [
                       {
                           Key       => 'Test-Param1',
                           Value     => 'Hello',
                           Mandatory => 1,
                       },
                       {
                           Key       => 'Test-Param2',
                           Mandatory => 1,
                       },
                       {
                           Key       => 'Test-Param3',
                           Value     => 'World',
                           Mandatory => 0,
                       },
                   ],
               },
               {
                   Type        => 'MultiLanguageRichText',
                   Description => "Description for Mutli-Language Rich Text.",
                   Defaults    => [
                       {
                           Key   => 'en_Subject',
                           Value => 'Hello',
                       },
                       {
                           Key   => 'en_Body',
                           Value => 'World',
                       },

                   ],
               },
               {
                   Type        => 'Recipients',
                   Description => "Description for Recipients."
               },
               {
                   Type        => 'RichText',
                   Description => "Description for Rich Text.",
                   Defaults    => [
                       {
                           Value     => 'Hello World',
                           Mandatory => 1,
                       },
                   ],
               },
           ],
       };

       return $Self;
   }

The constructor ``new()`` creates a new instance of the class. The configuration fields are defined here and they are set in ``$Self->{Config}``.

The configuration has two main entries:

``Description``
   Is is used to to explain the administrators what does the module do and/or considerations for its configuration.

``ConfigSets``
   This is just a container for the actual configuration fields.

All configuration fields requires a type that defines the kind of field and they could also have an internal description to be used a the title of the field widget, if its not defined a default description is used.

Each field defines its configuration parameters and capabilities, the following is a small reference for the fields provided my OTRS out of the box.

- ``Dropdown``

   ``Mandatory``
      Used to define if a value is required to be set.
   ``Config``
      Holds the information to display the drop-down field

      ``Data``
         Simple hash that defines the options for the dropdown, the keys are used internally, and the values are the options that the user see in the screen.

      ``Name``
         The name of the parameter.

      ``Multiple``
         To define if only one or multiple values can be selected.

      ``PossibleNone``
         Defines if the list of values offer an empty value or not.

      ``Sort``
         Defines how the options will be sorted when the field is render, the possible values are: ``AlphanumericValue``, ``NumericValue``, ``AlphanumericKey`` and ``NumericKey``.

      ``Translation``:
         Set if the display values should be translated.

- ``KeyValueList``

   ``Defaults``
      Array of hashes that holds the default configuration for its key value pairs.

      ``Key``
         The name of a parameter.

      ``Value``
         The default value of the parameter (optional).

      ``Mandatory``
         Mandatory parameters can not be renamed or removed (optional).

-  ``MultiLanguageRichText``

   ``Defaults``
      Array of hashes that holds the default configuration each language and field part.

      ``Key``
         Its composed by language such as ``en`` or ``es_MX``, followed by a '_' (underscore character) and then ``Subject`` or ``Body`` for the corresponding part of the field.

      ``Value``
         The default value of the field part (optional).

- ``Recipients``

   No further configuration is provided for this kind of field.

- ``RichText``

   ``Defaults``
      Array of hashes that holds the default configuration field (only the first element is used).

      ``Value``
         The default value of the field.

      ``Mandatory``
         Used to define if a value is required to be set.

.. code-block:: Perl

   sub Run {
       my ( $Self, %Param ) = @_;

       # Define a common message to output in case of any error.
       my $CommonMessage = "Process: $Param{ProcessEntityID} Activity: $Param{ActivityEntityID}";

       # Add SequenceFlowEntityID to common message if available.
       if ( $Param{SequenceFlowEntityID} ) {
           $CommonMessage .= " SequenceFlow: $Param{SequenceFlowEntityID}";
       }

       # Add SequenceFlowActionEntityID to common message if available.
       if ( $Param{SequenceFlowActionEntityID} ) {
           $CommonMessage .= " SequenceFlowAction: $Param{SequenceFlowActionEntityID}";
       }

       # Check for missing or wrong params.
       my $Success = $Self->_CheckParams(
           %Param,
           CommonMessage => $CommonMessage,
       );
       return if !$Success;

       # Override UserID if specified as a parameter in the TA config.
       $Param{UserID} = $Self->_OverrideUserID(%Param);

       # Use ticket attributes if needed.
       $Self->_ReplaceTicketAttributes(%Param);
       $Self->_ReplaceAdditionalAttributes(%Param);

       # Get module configuration.
       my $ModuleConfig = $Param{Config};

       # Add module logic here!

       return 1;
   }

The ``Run`` method Is the main part of the module. First sets a common message that can be used in error logs or any other purpose, for consistency its highly recommended to use it as described above.

Next step is to check if the global parameters was sent correctly.

By convention all modules should be able to override the current user ID is one is provided in the parameters (if any), this passed user ID should be used in any function call that requires it.

User defined attribute values can use current ticket values by using OTRS smart tags, ``_ReplaceTicketAttributes`` is used for normal text attributes, while ``_ReplaceAdditionalAttributes`` for Rich Texts. For more complex parameters it might need customized functions to replace this smart tags

The following is the proper logic of the module.

If everything was OK it must return 1.


Creating a New Process Management Module Configuration Field
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

The following is an example of how to create a process management module configuration field, this field can be used by any process management module after its configuration.


Process Management Module Configuration Field Code Example
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The following code implements a simple input process management module configuration field (test). The name of the field and its default value can be set trough a process management module ``ConfigSets``.

.. code-block:: Perl

   # --
   # Copyright (C) 2001-2018 OTRS AG, https://otrs.com/
   # --
   # This software comes with ABSOLUTELY NO WARRANTY. For details, see
   # the enclosed file COPYING for license information (GPL). If you
   # did not receive this file, see https://www.gnu.org/licenses/gpl-3.0.txt.
   # --

   package Kernel::Output::HTML::ProcessManagement::ModuleConfiguration::Test;

   use strict;
   use warnings;

   use Kernel::System::VariableCheck qw(:all);
   use Kernel::Language qw(Translatable);

   our @ObjectDependencies = (
       'Kernel::Output::HTML::Layout',
       'Kernel::System::Web::Request',
   );

This is common header that can be found in most OTRS modules. The class/package name is declared via the ``package`` keyword.

.. code-block:: Perl

   sub new {
       my ( $Type, %Param ) = @_;

       # allocate new hash for object
       my $Self = {%Param};
       bless( $Self, $Type );

       return $Self;
   }

The constructor ``new`` creates a new instance of the class.

Every configuration field requires to implement at least 2 main methods: ``Render`` and ``GetParams``.

.. code-block:: Perl

   sub Render {
       my ( $Self, %Param ) = @_;

       my $ConfigSet = $Param{ConfigSet} // {};
       my $EntityConfig = $Param{EntityData}->{Config}->{Config}->{ConfigTest} // {};

       my %Data;

       $Data{Description} = $ConfigSet->{Description} || 'Config Parameters (Test)';
       $Data{Name} = $ConfigSet->{Config}->{Name} // 'Test';
       $Data{Value} = $EntityConfig->{ $ConfigSet->{Config}->{Name} } // $ConfigSet->{Defaults}->[0]->{Value} // '';

       return {
           Success => 1,
           HTML    => $Kernel::OM->Get('Kernel::Output::HTML::Layout')->Output(
               TemplateFile => 'ProcessManagement/ModuleConfiguration/Test',
               Data         => \%Data,
           ),
       };
   }

``Render`` method is responsible to create the required HTML for the field.

In this example it first localize some parameters for more easy read and maintain.

The following lines sets the data to display, the field widget title ``Description`` is gather from the ``ConfigSet`` if defined, otherwise it uses a default text. Similar to the field ``Name``, for the ``Value`` it first checks if the activity or sequence flow action already have an stored value, if not it tries to use the default value from the ``ConfigSet``, or use empty otherwise.

At the end it returns a structure with the HTML code from a template filled with the gathered data.

.. code-block:: Perl

   sub GetParams {
       my ( $Self, %Param ) = @_;

       my %GetParams;
       my $Config = $Param{ConfigSet}->{Config} // 'Test';

       $GetParams{ $Config->{Name} } = $Kernel::OM->Get('Kernel::System::Web::Request')->GetParam( Param => $Config->{Name} );

       return \%GetParams;
   }

For this example the ``GetParams`` method is very straight forward, it get the name of the field from the ``ConfigSet`` or use a default, and gets the value from the web request.


Process Management Module Configuration Field Template Example
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The following code implements a basic HTML template for the test process management module configuration field.

.. code-block:: Perl

   # --
   # Copyright (C) 2001-2018 OTRS AG, https://otrs.com/
   # --
   # This software comes with ABSOLUTELY NO WARRANTY. For details, see
   # the enclosed file COPYING for license information (GPL). If you
   # did not receive this file, see https://www.gnu.org/licenses/gpl-3.0.txt.
   # --

This is common header that can be found in most OTRS modules.

.. Syntax highlighting not working with HTML because of the quote (") characters in HTML elements.
.. code-block:: none

   <div id="TestConfig" class="WidgetSimple Expanded">
       <div class="Header">
           <div class="WidgetAction Toggle">
               <a href="#" title="[% Translate("Show or hide the content") | html %]"><i class="fa fa-caret-right"></i><i class="fa fa-caret-down"></i></a>
           </div>
           <h2 for="Config">[% Translate(Data.Description) | html %]</h2>
       </div>
       <div class="Content" id="TestParams">
           <fieldset class="TableLike">
               <label for="[% Data.Name | html %]">[% Data.Name | html %]</label>
               <div class="Field">
                   <input type="text" value="[% Data.Value | html %]" name="[% Data.Name | html %]" id="[% Data.Name | html %]" />
               </div>
           </fieldset>
       </div>
   </div>

The template shows a simple text input element with its associated label.
