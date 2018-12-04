Creating A New Dynamic Field
============================

To illustrate this process a new dynamic field *Password* will be created. This new dynamic field type will show a new password field to ticket or article objects. Since is very similar to a text dynamic field
we will use the ``Base`` and ``BaseText`` drivers as a basis to build this new field.

.. warning::

   This new password field implementation is just for educational purposes, it does not provide any level of security and is not recommended for production systems.

To create this new dynamic field we will create 4 files:

1. A configuration file (XML) to register the modules.
2. An admin dialog module (Perl) to setup the field options.
3. A template module for the admin dialog.
4. A dynamic field driver (Perl).

File structure:

::

   $HOME (e. g. /opt/otrs/)
   |
   ...
   |--/Kernel/
   |   |--/Config/
   |   |   |--/Files/
   |   |   |   |--/XML/
   |   |   |   |   |DynamicFieldPassword.xml
   ...
   |   |--/Modules/
   |   |   |AdminDynamicFieldPassword.pm
   ...
   |   |--/Output/
   |   |   |--/HTML/
   |   |   |   |--/Standard/
   |   |   |   |   |AdminDynamicFieldPassword.tt
   ...
   |   |--/System/
   |   |   |--/DynamicField/
   |   |   |   |--/Driver/
   |   |   |   |   |Password.pm
   ...


Dynamic Field Password files
----------------------------

Dynamic Field Configuration File Example
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

The configuration files are used to register the dynamic field types (driver) and the object type drivers for the back end object. They also store standard registrations for admin modules in the framework.

In this section a configuration file for password dynamic field is shown and explained.

.. code-block:: XML

   <?xml version="1.0" encoding="utf-8" ?>
   <otrs_config version="2.0" init="Application">

This is the normal header for a configuration file.

.. code-block:: XML

       <ConfigItem Name="DynamicFields::Driver###Password" Required="0" Valid="1">
           <Description Translatable="1">DynamicField backend registration.</Description>
           <Group>DynamicFieldPassword</Group>
           <SubGroup>DynamicFields::Backend::Registration</SubGroup>
           <Setting>
               <Hash>
                   <Item Key="DisplayName" Translatable="1">Password</Item>
                   <Item Key="Module">Kernel::System::DynamicField::Driver::Password</Item>
                   <Item Key="ConfigDialog">AdminDynamicFieldPassword</Item>
               </Hash>
           </Setting>
       </ConfigItem>

This setting registers the password dynamic field driver for the back end module so it can be included in the list of available dynamic fields types. It also specify its own admin dialog in the key ``ConfigDialog``.
This key is used by the master dynamic field admin module to manage this new dynamic field type.

.. code-block:: XML

       <ConfigItem Name="Frontend::Module###AdminDynamicFieldPassword" Required="0" Valid="1">
           <Description Translatable="1">Frontend module registration for the agent interface.</Description>
           <Group>DynamicFieldPassword</Group>
           <SubGroup>Frontend::Admin::ModuleRegistration</SubGroup>
           <Setting>
               <FrontendModuleReg>
                   <Group>admin</Group>
                   <Description>Admin</Description>
                   <Title Translatable="1">Dynamic Fields Text Backend GUI</Title>
                   <Loader>
                       <JavaScript>Core.Agent.Admin.DynamicField.js</JavaScript>
                   </Loader>
               </FrontendModuleReg>
           </Setting>
       </ConfigItem>

This is a standard module registration for the password admin dialog in the admin interface.

.. code-block:: XML

   </otrs_config>

Standard closure of a configuration file.


Dynamic Field Admin Dialog Example
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

The admin dialogs are standard admin modules to manage (add or edit) the dynamic fields.

In this section an admin dialog for password dynamic field is shown and explained.

.. code-block:: Perl

   # --
   # Kernel/Modules/AdminDynamicFieldPassword.pm - provides a dynamic fields password config view for admins
   # Copyright (C) 2001-2018 OTRS AG, https://otrs.com/
   # --
   # This software comes with ABSOLUTELY NO WARRANTY. For details, see
   # the enclosed file COPYING for license information (GPL). If you
   # did not receive this file, see https://www.gnu.org/licenses/gpl-3.0.txt.
   # --

   package Kernel::Modules::AdminDynamicFieldPassword;

   use strict;
   use warnings;

   use Kernel::System::VariableCheck qw(:all);
   use Kernel::System::Valid;
   use Kernel::System::CheckItem;
   use Kernel::System::DynamicField;

This is common header that can be found in common OTRS modules. The class/package name is declared via the ``package`` keyword.

.. code-block:: Perl

   sub new {
       my ( $Type, %Param ) = @_;

       my $Self = {%Param};
       bless( $Self, $Type );

       for (qw(ParamObject LayoutObject LogObject ConfigObject)) {
           if ( !$Self->{$_} ) {
               $Self->{LayoutObject}->FatalError( Message => "Got no $_!" );
           }
       }

       # create additional objects
       $Self->{ValidObject} = Kernel::System::Valid->new( %{$Self} );

       $Self->{DynamicFieldObject} = Kernel::System::DynamicField->new( %{$Self} );

       # get configured object types
       $Self->{ObjectTypeConfig} = $Self->{ConfigObject}->Get('DynamicFields::ObjectType');

       # get the fields config
       $Self->{FieldTypeConfig} = $Self->{ConfigObject}->Get('DynamicFields::Backend') || {};

       $Self->{DefaultValueMask} = '****';
       return $Self;
   }

The constructor ``new`` creates a new instance of the class. According to the coding guidelines objects of other classes that are needed in this module have to be created in ``new``.

.. code-block:: Perl

   sub Run {
       my ( $Self, %Param ) = @_;

       if ( $Self->{Subaction} eq 'Add' ) {
           return $Self->_Add(
               %Param,
           );
       }
       elsif ( $Self->{Subaction} eq 'AddAction' ) {

           # challenge token check for write action
           $Self->{LayoutObject}->ChallengeTokenCheck();

           return $Self->_AddAction(
               %Param,
           );
       }
       if ( $Self->{Subaction} eq 'Change' ) {

           return $Self->_Change(
               %Param,
           );
       }
       elsif ( $Self->{Subaction} eq 'ChangeAction' ) {

           # challenge token check for write action
           $Self->{LayoutObject}->ChallengeTokenCheck();

           return $Self->_ChangeAction(
               %Param,
           );
       }

       return $Self->{LayoutObject}->ErrorScreen(
           Message => "Undefined subaction.",
       );
   }

``Run`` is the default function to be called by the web request. We try to make this function as simple as possible and let the helper functions to do the hard work.

.. code-block:: Perl

   sub _Add {
       my ( $Self, %Param ) = @_;

       my %GetParam;
       for my $Needed (qw(ObjectType FieldType FieldOrder)) {
           $GetParam{$Needed} = $Self->{ParamObject}->GetParam( Param => $Needed );
           if ( !$Needed ) {

               return $Self->{LayoutObject}->ErrorScreen(
                   Message => "Need $Needed",
               );
           }
       }

       # get the object type and field type display name
       my $ObjectTypeName = $Self->{ObjectTypeConfig}->{ $GetParam{ObjectType} }->{DisplayName} || '';
       my $FieldTypeName  = $Self->{FieldTypeConfig}->{ $GetParam{FieldType} }->{DisplayName}   || '';

       return $Self->_ShowScreen(
           %Param,
           %GetParam,
           Mode           => 'Add',
           ObjectTypeName => $ObjectTypeName,
           FieldTypeName  => $FieldTypeName,
       );
   }

``_Add`` function is also pretty simple, it just get some parameters from the web request and call the ``_ShowScreen()`` function. Normally this function is not needed to be modified.

.. code-block:: Perl

   sub _AddAction {
       my ( $Self, %Param ) = @_;

       my %Errors;
       my %GetParam;

       for my $Needed (qw(Name Label FieldOrder)) {
           $GetParam{$Needed} = $Self->{ParamObject}->GetParam( Param => $Needed );
           if ( !$GetParam{$Needed} ) {
               $Errors{ $Needed . 'ServerError' }        = 'ServerError';
               $Errors{ $Needed . 'ServerErrorMessage' } = 'This field is required.';
           }
       }

       if ( $GetParam{Name} ) {

           # check if name is alphanumeric
           if ( $GetParam{Name} !~ m{\A ( ?: [a-zA-Z] | \d )+ \z}xms ) {

               # add server error error class
               $Errors{NameServerError} = 'ServerError';
               $Errors{NameServerErrorMessage} =
                   'The field does not contain only ASCII letters and numbers.';
           }

           # check if name is duplicated
           my %DynamicFieldsList = %{
               $Self->{DynamicFieldObject}->DynamicFieldList(
                   Valid      => 0,
                   ResultType => 'HASH',
                   )
           };

           %DynamicFieldsList = reverse %DynamicFieldsList;

           if ( $DynamicFieldsList{ $GetParam{Name} } ) {

               # add server error error class
               $Errors{NameServerError}        = 'ServerError';
               $Errors{NameServerErrorMessage} = 'There is another field with the same name.';
           }
       }

       if ( $GetParam{FieldOrder} ) {

           # check if field order is numeric and positive
           if ( $GetParam{FieldOrder} !~ m{\A ( ?: \d )+ \z}xms ) {

               # add server error error class
               $Errors{FieldOrderServerError}        = 'ServerError';
               $Errors{FieldOrderServerErrorMessage} = 'The field must be numeric.';
           }
       }

       for my $ConfigParam (
           qw(
           ObjectType ObjectTypeName FieldType FieldTypeName DefaultValue ValidID ShowValue
           ValueMask
           )
           )
       {
           $GetParam{$ConfigParam} = $Self->{ParamObject}->GetParam( Param => $ConfigParam );
       }

       # uncorrectable errors
       if ( !$GetParam{ValidID} ) {

           return $Self->{LayoutObject}->ErrorScreen(
               Message => "Need ValidID",
           );
       }

       # return to add screen if errors
       if (%Errors) {

           return $Self->_ShowScreen(
               %Param,
               %Errors,
               %GetParam,
               Mode => 'Add',
           );
       }

       # set specific config
       my $FieldConfig = {
           DefaultValue => $GetParam{DefaultValue},
           ShowValue    => $GetParam{ShowValue},
           ValueMask    => $GetParam{ValueMask} || $Self->{DefaultValueMask},
       };

       # create a new field
       my $FieldID = $Self->{DynamicFieldObject}->DynamicFieldAdd(
           Name       => $GetParam{Name},
           Label      => $GetParam{Label},
           FieldOrder => $GetParam{FieldOrder},
           FieldType  => $GetParam{FieldType},
           ObjectType => $GetParam{ObjectType},
           Config     => $FieldConfig,
           ValidID    => $GetParam{ValidID},
           UserID     => $Self->{UserID},
       );

       if ( !$FieldID ) {

           return $Self->{LayoutObject}->ErrorScreen(
               Message => "Could not create the new field",
           );
       }

       return $Self->{LayoutObject}->Redirect(
           OP => "Action=AdminDynamicField",
       );
   }

The ``_AddAction`` function gets the configuration parameters from a new dynamic field, and it validates that the dynamic field name only contains letters and numbers. This function could validate any other parameter.

``Name``, ``Label``, ``FieldOrder``, ``Validity`` are common parameters for all dynamic fields and they are required. Each dynamic field has its specific configuration that must contain at least the ``DefaultValue``
parameter. In this case it also have ``ShowValue`` and ``ValueMask`` parameters for password field.

If the field has the ability to store a fixed list of values they should be stored in the ``PossibleValues`` parameter inside the specific configuration hash.

As in other admin modules, if a parameter is not valid this function returns to the add screen highlighting the erroneous form fields.

If all the parameters are correct it creates a new dynamic field.

.. code-block:: Perl

   sub _Change {
       my ( $Self, %Param ) = @_;

       my %GetParam;
       for my $Needed (qw(ObjectType FieldType)) {
           $GetParam{$Needed} = $Self->{ParamObject}->GetParam( Param => $Needed );
           if ( !$Needed ) {

               return $Self->{LayoutObject}->ErrorScreen(
                   Message => "Need $Needed",
               );
           }
       }

       # get the object type and field type display name
       my $ObjectTypeName = $Self->{ObjectTypeConfig}->{ $GetParam{ObjectType} }->{DisplayName} || '';
       my $FieldTypeName  = $Self->{FieldTypeConfig}->{ $GetParam{FieldType} }->{DisplayName}   || '';

       my $FieldID = $Self->{ParamObject}->GetParam( Param => 'ID' );

       if ( !$FieldID ) {

           return $Self->{LayoutObject}->ErrorScreen(
               Message => "Need ID",
           );
       }

       # get dynamic field data
       my $DynamicFieldData = $Self->{DynamicFieldObject}->DynamicFieldGet(
           ID => $FieldID,
       );

       # check for valid dynamic field configuration
       if ( !IsHashRefWithData($DynamicFieldData) ) {

           return $Self->{LayoutObject}->ErrorScreen(
               Message => "Could not get data for dynamic field $FieldID",
           );
       }

       my %Config = ();

       # extract configuration
       if ( IsHashRefWithData( $DynamicFieldData->{Config} ) ) {
           %Config = %{ $DynamicFieldData->{Config} };
       }

       return $Self->_ShowScreen(
           %Param,
           %GetParam,
           %${DynamicFieldData},
           %Config,
           ID             => $FieldID,
           Mode           => 'Change',
           ObjectTypeName => $ObjectTypeName,
           FieldTypeName  => $FieldTypeName,
       );
   }

The ``_Change`` function is very similar to the ``_Add`` function but since this function is used to edit an existing field it needs to validated the ``FieldID`` parameter and gather the current dynamic field data.

.. code-block:: Perl

   sub _ChangeAction {
       my ( $Self, %Param ) = @_;

       my %Errors;
       my %GetParam;

       for my $Needed (qw(Name Label FieldOrder)) {
           $GetParam{$Needed} = $Self->{ParamObject}->GetParam( Param => $Needed );
           if ( !$GetParam{$Needed} ) {
               $Errors{ $Needed . 'ServerError' }        = 'ServerError';
               $Errors{ $Needed . 'ServerErrorMessage' } = 'This field is required.';
           }
       }

       my $FieldID = $Self->{ParamObject}->GetParam( Param => 'ID' );
       if ( !$FieldID ) {

           return $Self->{LayoutObject}->ErrorScreen(
               Message => "Need ID",
           );
       }

       if ( $GetParam{Name} ) {

           # check if name is lowercase
           if ( $GetParam{Name} !~ m{\A ( ?: [a-zA-Z] | \d )+ \z}xms ) {

               # add server error error class
               $Errors{NameServerError} = 'ServerError';
               $Errors{NameServerErrorMessage} =
                   'The field does not contain only ASCII letters and numbers.';
           }

           # check if name is duplicated
           my %DynamicFieldsList = %{
               $Self->{DynamicFieldObject}->DynamicFieldList(
                   Valid      => 0,
                   ResultType => 'HASH',
                   )
           };

           %DynamicFieldsList = reverse %DynamicFieldsList;

           if (
               $DynamicFieldsList{ $GetParam{Name} } &&
               $DynamicFieldsList{ $GetParam{Name} } ne $FieldID
               )
           {

               # add server error class
               $Errors{NameServerError}        = 'ServerError';
               $Errors{NameServerErrorMessage} = 'There is another field with the same name.';
           }
       }

       if ( $GetParam{FieldOrder} ) {

           # check if field order is numeric and positive
           if ( $GetParam{FieldOrder} !~ m{\A ( ?: \d )+ \z}xms ) {

               # add server error error class
               $Errors{FieldOrderServerError}        = 'ServerError';
               $Errors{FieldOrderServerErrorMessage} = 'The field must be numeric.';
           }
       }

       for my $ConfigParam (
           qw(
           ObjectType ObjectTypeName FieldType FieldTypeName DefaultValue ValidID ShowValue
           ValueMask
           )
           )
       {
           $GetParam{$ConfigParam} = $Self->{ParamObject}->GetParam( Param => $ConfigParam );
       }

       # uncorrectable errors
       if ( !$GetParam{ValidID} ) {

           return $Self->{LayoutObject}->ErrorScreen(
               Message => "Need ValidID",
           );
       }

       # get dynamic field data
       my $DynamicFieldData = $Self->{DynamicFieldObject}->DynamicFieldGet(
           ID => $FieldID,
       );

       # check for valid dynamic field configuration
       if ( !IsHashRefWithData($DynamicFieldData) ) {

           return $Self->{LayoutObject}->ErrorScreen(
               Message => "Could not get data for dynamic field $FieldID",
           );
       }

       # return to change screen if errors
       if (%Errors) {

           return $Self->_ShowScreen(
               %Param,
               %Errors,
               %GetParam,
               ID   => $FieldID,
               Mode => 'Change',
           );
       }

       # set specific config
       my $FieldConfig = {
           DefaultValue => $GetParam{DefaultValue},
           ShowValue    => $GetParam{ShowValue},
           ValueMask    => $GetParam{ValueMask},
       };

       # update dynamic field (FieldType and ObjectType cannot be changed; use old values)
       my $UpdateSuccess = $Self->{DynamicFieldObject}->DynamicFieldUpdate(
           ID         => $FieldID,
           Name       => $GetParam{Name},
           Label      => $GetParam{Label},
           FieldOrder => $GetParam{FieldOrder},
           FieldType  => $DynamicFieldData->{FieldType},
           ObjectType => $DynamicFieldData->{ObjectType},
           Config     => $FieldConfig,
           ValidID    => $GetParam{ValidID},
           UserID     => $Self->{UserID},
       );

       if ( !$UpdateSuccess ) {

           return $Self->{LayoutObject}->ErrorScreen(
               Message => "Could not update the field $GetParam{Name}",
           );
       }

       return $Self->{LayoutObject}->Redirect(
           OP => "Action=AdminDynamicField",
       );
   }

``_ChangeAction()`` is very similar to ``_AddAction()``, but adapted for the update of an existing field instead of creating a new one.

.. code-block:: Perl

   sub _ShowScreen {
       my ( $Self, %Param ) = @_;

       $Param{DisplayFieldName} = 'New';

       if ( $Param{Mode} eq 'Change' ) {
           $Param{ShowWarning}      = 'ShowWarning';
           $Param{DisplayFieldName} = $Param{Name};
       }

       # header
       my $Output = $Self->{LayoutObject}->Header();
       $Output .= $Self->{LayoutObject}->NavigationBar();

       # get all fields
       my $DynamicFieldList = $Self->{DynamicFieldObject}->DynamicFieldListGet(
           Valid => 0,
       );

       # get the list of order numbers (is already sorted).
       my @DynamicfieldOrderList;
       for my $Dynamicfield ( @{$DynamicFieldList} ) {
           push @DynamicfieldOrderList, $Dynamicfield->{FieldOrder};
       }

       # when adding we need to create an extra order number for the new field
       if ( $Param{Mode} eq 'Add' ) {

           # get the last element from the order list and add 1
           my $LastOrderNumber = $DynamicfieldOrderList[-1];
           $LastOrderNumber++;

           # add this new order number to the end of the list
           push @DynamicfieldOrderList, $LastOrderNumber;
       }

       my $DynamicFieldOrderSrtg = $Self->{LayoutObject}->BuildSelection(
           Data          => \@DynamicfieldOrderList,
           Name          => 'FieldOrder',
           SelectedValue => $Param{FieldOrder} || 1,
           PossibleNone  => 0,
           Class         => 'W50pc Validate_Number',
       );

       my %ValidList = $Self->{ValidObject}->ValidList();

       # create the Validity select
       my $ValidityStrg = $Self->{LayoutObject}->BuildSelection(
           Data         => \%ValidList,
           Name         => 'ValidID',
           SelectedID   => $Param{ValidID} || 1,
           PossibleNone => 0,
           Translation  => 1,
           Class        => 'W50pc',
       );

       # define config field specific settings
       my $DefaultValue = ( defined $Param{DefaultValue} ? $Param{DefaultValue} : '' );

       # create the Show value select
       my $ShowValueStrg = $Self->{LayoutObject}->BuildSelection(
           Data => [ 'No', 'Yes' ],
           Name => 'ShowValue',
           SelectedValue => $Param{ShowValue} || 'No',
           PossibleNone  => 0,
           Translation   => 1,
           Class         => 'W50pc',
       );

       # generate output
       $Output .= $Self->{LayoutObject}->Output(
           TemplateFile => 'AdminDynamicFieldPassword',
           Data         => {
               %Param,
               ValidityStrg          => $ValidityStrg,
               DynamicFieldOrderSrtg => $DynamicFieldOrderSrtg,
               DefaultValue          => $DefaultValue,
               ShowValueStrg         => $ShowValueStrg,
               ValueMask             => $Param{ValueMask} || $Self->{DefaultValueMask},
           },
       );

       $Output .= $Self->{LayoutObject}->Footer();

       return $Output;
   }

   1;

The ``_ShowScreen`` function is used to set and define the HTML elements and blocks from a template to generate the admin dialog HTML code.


Dynamic Field Template for Admin Dialog Example
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

The template is the place where the HTML code of the dialog is stored.

In this section an admin dialog template for the password dynamic field is shown and explained.

.. code-block:: Perl

   # --
   # AdminDynamicFieldPassword.tt - provides HTML form for AdminDynamicFieldPassword
   # Copyright (C) 2001-2018 OTRS AG, https://otrs.com/
   # --
   # This software comes with ABSOLUTELY NO WARRANTY. For details, see
   # the enclosed file COPYING for license information (GPL). If you
   # did not receive this file, see https://www.gnu.org/licenses/gpl-3.0.txt.
   # --

This is common header that can be found in common OTRS modules.

.. Syntax highlighting not working with HTML because of the quote (") characters in HTML elements.
.. code-block:: none

   <div class="MainBox ARIARoleMain LayoutFixedSidebar SidebarFirst">
       <h1>[% Translate("Dynamic Fields") | html %] - [% Translate(Data.ObjectTypeName) | html %]: [% Translate(Data.Mode) | html %] [% Translate(Data.FieldTypeName) | html %] [% Translate("Field") | html %]</h1>

       <div class="Clear"></div>

       <div class="SidebarColumn">
           <div class="WidgetSimple">
               <div class="Header">
                   <h2>[% Translate("Actions") | html %]</h2>
               </div>
               <div class="Content">
                   <ul class="ActionList">
                       <li>
                           <a href="[% Env("Baselink") %]Action=AdminDynamicField" class="CallForAction"><span>[% Translate("Go back to overview") | html %]</span></a>
                       </li>
                   </ul>
               </div>
           </div>
       </div>

This part of the code has the main box and also the actions side bar. No modifications are needed in this section.

.. Syntax highlighting not working with HTML because of the quote (") characters in HTML elements.
.. code-block:: none

       <div class="ContentColumn">
           <form action="[% Env("CGIHandle") %]" method="post" class="Validate PreventMultipleSubmits">
               <input type="hidden" name="Action" value="AdminDynamicFieldPassword" />
               <input type="hidden" name="Subaction" value="[% Data.Mode | html %]Action" />
               <input type="hidden" name="ObjectType" value="[% Data.ObjectType | html %]" />
               <input type="hidden" name="FieldType" value="[% Data.FieldType | html %]" />
               <input type="hidden" name="ID" value="[% Data.ID | html %]" />

In this section of the code is defined the right part of the dialog. Notice that the value of the ``Action`` hidden input must match with the name of the admin dialog.

.. code-block:: HTML

               <div class="WidgetSimple">
                   <div class="Header">
                       <h2>[% Translate("General") | html %]</h2>
                   </div>
                   <div class="Content">
                       <div class="LayoutGrid ColumnsWithSpacing">
                           <div class="Size1of2">
                               <fieldset class="TableLike">
                                   <label class="Mandatory" for="Name"><span class="Marker">*</span> [% Translate("Name") | html %]:</label>
                                   <div class="Field">
                                       <input id="Name" class="W50pc [% Data.NameServerError | html %] [% Data.ShowWarning | html %]  Validate_Alphanumeric" type="text" maxlength="200" value="[% Data.Name | html %]" name="Name"/>
                                       <div id="NameError" class="TooltipErrorMessage"><p>[% Translate("This field is required, and the value should be alphabetic and numeric characters only.") | html %]</p></div>
                                       <div id="NameServerError" class="TooltipErrorMessage"><p>[% Translate(Data.NameServerErrorMessage) | html %]</p></div>
                                       <p class="FieldExplanation">[% Translate("Must be unique and only accept alphabetic and numeric characters.") | html %]</p>
                                       <p class="Warning Hidden">[% Translate("Changing this value will require manual changes in the system.") | html %]</p>
                                   </div>
                                   <div class="Clear"></div>

                                   <label class="Mandatory" for="Label"><span class="Marker">*</span> [% Translate("Label") | html %]:</label>
                                   <div class="Field">
                                       <input id="Label" class="W50pc [% Data.LabelServerError | html %] Validate_Required" type="text" maxlength="200" value="[% Data.Label | html %]" name="Label"/>
                                       <div id="LabelError" class="TooltipErrorMessage"><p>[% Translate("This field is required.") | html %]</p></div>
                                       <div id="LabelServerError" class="TooltipErrorMessage"><p>[% Translate(Data.LabelServerErrorMessage) | html %]</p></div>
                                       <p class="FieldExplanation">[% Translate("This is the name to be shown on the screens where the field is active.") | html %]</p>
                                   </div>
                                   <div class="Clear"></div>

                                   <label class="Mandatory" for="FieldOrder"><span class="Marker">*</span> [% Translate("Field order") | html %]:</label>
                                   <div class="Field">
                                       [% Data.DynamicFieldOrderSrtg %]
                                       <div id="FieldOrderError" class="TooltipErrorMessage"><p>[% Translate("This field is required and must be numeric.") | html %]</p></div>
                                       <div id="FieldOrderServerError" class="TooltipErrorMessage"><p>[% Translate(Data.FieldOrderServerErrorMessage) | html %]</p></div>
                                       <p class="FieldExplanation">[% Translate("This is the order in which this field will be shown on the screens where is active.") | html %]</p>
                                   </div>
                                   <div class="Clear"></div>
                               </fieldset>
                           </div>
                           <div class="Size1of2">
                               <fieldset class="TableLike">
                                   <label for="ValidID">[% Translate("Validity") | html %]:</label>
                                   <div class="Field">
                                       [% Data.ValidityStrg %]
                                   </div>
                                   <div class="Clear"></div>

                                   <div class="SpacingTop"></div>
                                   <label for="FieldTypeName">[% Translate("Field type") | html %]:</label>
                                   <div class="Field">
                                       <input id="FieldTypeName" readonly="readonly" class="W50pc" type="text" maxlength="200" value="[% Data.FieldTypeName | html %]" name="FieldTypeName"/>
                                       <div class="Clear"></div>
                                   </div>

                                   <div class="SpacingTop"></div>
                                   <label for="ObjectTypeName">[% Translate("Object type") | html %]:</label>
                                   <div class="Field">
                                       <input id="ObjectTypeName" readonly="readonly" class="W50pc" type="text" maxlength="200" value="[% Data.ObjectTypeName | html %]" name="ObjectTypeName"/>
                                       <div class="Clear"></div>
                                   </div>
                               </fieldset>
                           </div>
                       </div>
                   </div>
               </div>

This first widget contains the common form attributes for the dynamic fields. For consistency with other dynamic fields is recommended to leave this part of the code unchanged.

.. code-block:: HTML

               <div class="WidgetSimple">
                   <div class="Header">
                       <h2>[% Translate(Data.FieldTypeName) | html %] [% Translate("Field Settings") | html %]</h2>
                   </div>
                   <div class="Content">
                       <fieldset class="TableLike">

                           <label for="DefaultValue">[% Translate("Default value") | html %]:</label>
                           <div class="Field">
                               <input id="DefaultValue" class="W50pc" type="text" maxlength="200" value="[% Data.DefaultValue | html %]" name="DefaultValue"/>
                               <p class="FieldExplanation">[% Translate("This is the default value for this field.") | html %]</p>
                           </div>
                           <div class="Clear"></div>

                           <label for="ShowValue">[% Translate("Show value") | html %]:</label>
                           <div class="Field">
                               [% Data.ShowValueStrg %]
                               <p class="FieldExplanation">
                                   [% Translate("To reveal the field value in non edit screens ( e.g. Ticket Zoom Screen )") | html %]
                               </p>
                           </div>
                           <div class="Clear"></div>

                           <label for="ValueMask">[% Translate("Hidden value mask") | html %]:</label>
                           <div class="Field">
                               <input id="ValueMask" class="W50pc" type="text" maxlength="200" value="[% Data.ValueMask | html %]" name="ValueMask"/>
                               <p class="FieldExplanation">
                                   [% Translate("This is the alternate value to show if Show value is set to \"No\" ( Default: **** ).") | html %]
                               </p>
                           </div>
                           <div class="Clear"></div>

                       </fieldset>
                   </div>
               </div>

The second widget has the dynamic field specific form attributes. This is the place where new attributes can be set and it could use JavaScript and AJAX technologies to make it more easy or friendly for the end user.

.. Syntax highlighting not working with HTML because of the quote (") characters in HTML elements.
.. code-block:: none

               <fieldset class="TableLike">
                   <div class="Field SpacingTop">
                       <button type="submit" class="Primary" value="[% Translate("Save") | html %]">[% Translate("Save") | html %]</button>
                       [% Translate("or") | html %]
                       <a href="[% Env("Baselink") %]Action=AdminDynamicField">[% Translate("Cancel") | html %]</a>
                   </div>
                   <div class="Clear"></div>
               </fieldset>
           </form>
       </div>
   </div>
   [% WRAPPER JSOnDocumentComplete %]
   <script type="text/javascript">//<![CDATA[
   $('.ShowWarning').bind('change keyup', function (Event) {
       $('p.Warning').removeClass('Hidden');
   });

   Core.Agent.Admin.DynamicField.ValidationInit();
   //]]></script>
   [% END %]

The final part of the file contains the *Save* button and the *Cancel* link, as well as other needed JavaScript code.


Dynamic Field Driver Example
~~~~~~~~~~~~~~~~~~~~~~~~~~~~

The driver *is* the dynamic field. It contains several functions that are used wide in the OTRS framework. A driver can inherit some functions form base classes, for example ``TextArea`` driver inherits most of the functions from ``Base.pm`` and ``BaseText.pm`` and it only implements the functions that requires different logic or results. Checkbox field driver only inherits from ``Base.pm`` as all other functions are very different from any other base driver.

.. seealso::

   Please refer to the Perl online documentation (POD) of the module ``/Kernel/System/DynmicField/Backend.pm`` to have the list of all attributes and possible return data for each function.

In this section the password dynamic field driver is shown and explained. This driver inherits some functions from ``Base.pm`` and ``BaseText.pm`` and only implements the functions that needs different results.

.. code-block:: Perl

   # --
   # Kernel/System/DynamicField/Driver/Password.pm - Driver for DynamicField Password backend
   # Copyright (C) 2001-2018 OTRS AG, https://otrs.com/
   # --
   # This software comes with ABSOLUTELY NO WARRANTY. For details, see
   # the enclosed file COPYING for license information (GPL). If you
   # did not receive this file, see https://www.gnu.org/licenses/gpl-3.0.txt.
   # --

   package Kernel::System::DynamicField::Driver::Password;

   use strict;
   use warnings;

   use Kernel::System::VariableCheck qw(:all);
   use Kernel::System::DynamicFieldValue;

   use base qw(Kernel::System::DynamicField::Driver::BaseText);

   our @ObjectDependencies = (
       'Kernel::Config',
       'Kernel::System::DynamicFieldValue',
       'Kernel::System::Main',
   );

This is the common header that can be found in common OTRS modules. The class/package name is declared via the ``package`` keyword. Notice that ``BaseText`` is used as base class.

.. code-block:: Perl

   sub new {
       my ( $Type, %Param ) = @_;

       # allocate new hash for object
       my $Self = {};
       bless( $Self, $Type );

       # set field behaviors
       $Self->{Behaviors} = {
           'IsACLReducible'               => 0,
           'IsNotificationEventCondition' => 1,
           'IsSortable'                   => 0,
           'IsFiltrable'                  => 0,
           'IsStatsCondition'             => 1,
           'IsCustomerInterfaceCapable'   => 1,
       };

       # get the Dynamic Field Backend custom extensions
       my $DynamicFieldDriverExtensions
           = $Kernel::OM->Get('Kernel::Config')->Get('DynamicFields::Extension::Driver::Password');

       EXTENSION:
       for my $ExtensionKey ( sort keys %{$DynamicFieldDriverExtensions} ) {

           # skip invalid extensions
           next EXTENSION if !IsHashRefWithData( $DynamicFieldDriverExtensions->{$ExtensionKey} );

           # create a extension config shortcut
           my $Extension = $DynamicFieldDriverExtensions->{$ExtensionKey};

           # check if extension has a new module
           if ( $Extension->{Module} ) {

               # check if module can be loaded
               if (
                   !$Kernel::OM->Get('Kernel::System::Main')->RequireBaseClass( $Extension->{Module} )
                   )
               {
                   die "Can't load dynamic fields backend module"
                       . " $Extension->{Module}! $@";
               }
           }

           # check if extension contains more behaviors
           if ( IsHashRefWithData( $Extension->{Behaviors} ) ) {

               %{ $Self->{Behaviors} } = (
                   %{ $Self->{Behaviors} },
                   %{ $Extension->{Behaviors} }
               );
           }
       }

       return $Self;
   }

The constructor ``new`` creates a new instance of the class. According to the coding guidelines objects of other classes that are needed in this module have to be created in ``new``.

It is important to define the behaviors correctly as the field might or might not be used in certain screens, functions that depends on behaviors that are not active for this particular field might not be needed to be implemented.

.. note::

   Drivers are created only by the ``BackendObject`` and not directly from any other module.

.. code-block:: Perl

   sub EditFieldRender {
       my ( $Self, %Param ) = @_;

       # take config from field config
       my $FieldConfig = $Param{DynamicFieldConfig}->{Config};
       my $FieldName   = 'DynamicField_' . $Param{DynamicFieldConfig}->{Name};
       my $FieldLabel  = $Param{DynamicFieldConfig}->{Label};

       my $Value = '';

       # set the field value or default
       if ( $Param{UseDefaultValue} ) {
           $Value = ( defined $FieldConfig->{DefaultValue} ? $FieldConfig->{DefaultValue} : '' );
       }
       $Value = $Param{Value} if defined $Param{Value};

       # extract the dynamic field value from the web request
       my $FieldValue = $Self->EditFieldValueGet(
           %Param,
       );

       # set values from ParamObject if present
       if ( defined $FieldValue ) {
           $Value = $FieldValue;
       }

       # check and set class if necessary
       my $FieldClass = 'DynamicFieldText W50pc';
       if ( defined $Param{Class} && $Param{Class} ne '' ) {
           $FieldClass .= ' ' . $Param{Class};
       }

       # set field as mandatory
       $FieldClass .= ' Validate_Required' if $Param{Mandatory};

       # set error css class
       $FieldClass .= ' ServerError' if $Param{ServerError};

       my $HTMLString = <<"EOF";
   <input type="password" class="$FieldClass" id="$FieldName" name="$FieldName" title="$FieldLabel" value="$Value" />
   EOF

       if ( $Param{Mandatory} ) {
           my $DivID = $FieldName . 'Error';

           # for client side validation
           $HTMLString .= <<"EOF";
       <div id="$DivID" class="TooltipErrorMessage">
           <p>
               \$Text{"This field is required."}
           </p>
       </div>
   EOF
       }

       if ( $Param{ServerError} ) {

           my $ErrorMessage = $Param{ErrorMessage} || 'This field is required.';
           my $DivID = $FieldName . 'ServerError';

           # for server side validation
           $HTMLString .= <<"EOF";
       <div id="$DivID" class="TooltipErrorMessage">
           <p>
               \$Text{"$ErrorMessage"}
           </p>
       </div>
   EOF
       }

       # call EditLabelRender on the common Driver
       my $LabelString = $Self->EditLabelRender(
           %Param,
           DynamicFieldConfig => $Param{DynamicFieldConfig},
           Mandatory          => $Param{Mandatory} || '0',
           FieldName          => $FieldName,
       );

       my $Data = {
           Field => $HTMLString,
           Label => $LabelString,
       };

       return $Data;
   }

This function is the responsible to create the HTML representation of the field and its label, and is used in the edit screens like ``AgentTicketPhone``, ``AgentTicketNote``, etc.

.. code-block:: Perl

   sub DisplayValueRender {
       my ( $Self, %Param ) = @_;

       # set HTMLOutput as default if not specified
       if ( !defined $Param{HTMLOutput} ) {
           $Param{HTMLOutput} = 1;
       }

       my $Value;
       my $Title;

       # check if field is set to show password or not
       if (
           defined $Param{DynamicFieldConfig}->{Config}->{ShowValue}
           && $Param{DynamicFieldConfig}->{Config}->{ShowValue} eq 'Yes'
           )
       {

           # get raw Title and Value strings from field value
           $Value = defined $Param{Value} ? $Param{Value} : '';
           $Title = $Value;
       }
       else {

           # show the mask and not the value
           $Value = $Param{DynamicFieldConfig}->{Config}->{ValueMask} || '';
           $Title = 'The value of this field is hidden.'
       }

       # HTMLOutput transformations
       if ( $Param{HTMLOutput} ) {
           $Value = $Param{LayoutObject}->Ascii2Html(
               Text => $Value,
               Max => $Param{ValueMaxChars} || '',
           );

           $Title = $Param{LayoutObject}->Ascii2Html(
               Text => $Title,
               Max => $Param{TitleMaxChars} || '',
           );
       }
       else {
           if ( $Param{ValueMaxChars} && length($Value) > $Param{ValueMaxChars} ) {
               $Value = substr( $Value, 0, $Param{ValueMaxChars} ) . '...';
           }
           if ( $Param{TitleMaxChars} && length($Title) > $Param{TitleMaxChars} ) {
               $Title = substr( $Title, 0, $Param{TitleMaxChars} ) . '...';
           }
       }

       # create return structure
       my $Data = {
           Value => $Value,
           Title => $Title,
       };

       return $Data;
   }

``DisplayValueRender()`` function returns the field value as a plain text as well as its title (both can be translated). For this particular example we are checking if the password should be revealed or display a predefined mask by a configuration parameter in the dynamic field.

.. code-block:: Perl

   sub ReadableValueRender {
       my ( $Self, %Param ) = @_;

       my $Value;
       my $Title;

       # check if field is set to show password or not
       if (
           defined $Param{DynamicFieldConfig}->{Config}->{ShowValue}
           && $Param{DynamicFieldConfig}->{Config}->{ShowValue} eq 'Yes'
           )
       {

           # get raw Title and Value strings from field value
           $Value = $Param{Value} // '';
           $Title = $Value;
       }
       else {

           # show the mask and not the value
           $Value = $Param{DynamicFieldConfig}->{Config}->{ValueMask} || '';
           $Title = 'The value of this field is hidden.'
       }

       # cut strings if needed
       if ( $Param{ValueMaxChars} && length($Value) > $Param{ValueMaxChars} ) {
           $Value = substr( $Value, 0, $Param{ValueMaxChars} ) . '...';
       }
       if ( $Param{TitleMaxChars} && length($Title) > $Param{TitleMaxChars} ) {
           $Title = substr( $Title, 0, $Param{TitleMaxChars} ) . '...';
       }

       # create return structure
       my $Data = {
           Value => $Value,
           Title => $Title,
       };

       return $Data;
   }

This function is similar to ``DisplayValueRender()`` but is used in places where there is no ``LayoutObject``.


Other Functions
~~~~~~~~~~~~~~~

The following are other functions that are might needed if the new dynamic field does not inherit from other classes. To see the complete code of this functions please take a look directly into the files ``Kernel/System/DynamicField/Driver/Base.pm`` and ``Kernel/System/DynamicField/Driver/BaseText.pm``

.. code-block:: Perl

   sub ValueGet { ... }

This function retrieves the value from the field on a specified object. In this case we are returning the first text value, since the field only stores one text value at time.

.. code-block:: Perl

   sub ValueSet { ... }

This function is used to store a dynamic field value. In this case this field only stores one text type value. Other fields could store more than one value on either ``ValueText``, ``ValueDateTime`` or
``ValueInt`` format.

.. code-block:: Perl

   sub ValueDelete { ... }

This function is used to delete one field value attached to a particular object ID. For example if the instance of an object is to be deleted, then there is no reason to have the field value stored in the database for that particular object instance.

.. code-block:: Perl

   sub AllValuesDelete { ... }

This function is used to delete all values from a certain dynamic field. This function is very useful when a dynamic field is going to be deleted.

.. code-block:: Perl

   sub ValueValidate { ... }

This function is used to check if the value is consistent to its type.

.. code-block:: Perl

   sub SearchSQLGet { ... }

This function is used by ``TicketSearch`` core module to build the internal query to search for a ticket based on this field as a search parameter.

.. code-block:: Perl

   sub SearchSQLOrderFieldGet { ... }

This function is also a helper for ``TicketSearch`` module. ``$Param{TableAlias}`` should be kept and ``value_text`` could be replaced with ``value_date`` or ``value_int`` depending on the field.

.. code-block:: Perl

   sub EditFieldValueGet { ... }

This function is used in the edit screens of OTRS and its purpose is to get the value of the field, either from a template like generic agent profile or from a web request. This function gets the web request in the ``$Param{ParamObject}``, that is a copy of the ``ParamObject`` of the front end module or screen.

There are two return formats for this function. The normal that is just the raw value or a structure that is the pair field name => field value. For example a date dynamic field returns normally the date as string, and if it should return a structure it returns a pair for each part of the date in the hash.

If the result should be a structure then, normally this is used to store its values in a template, like a generic agent profile. For example a date field uses several HTML components to build the field, like the
used checkbox and selects for year, month, day etc.

.. code-block:: Perl

   sub EditFieldValueValidate { ... }

This function should provide at least a method to validate if the field is empty, and return an error if the field is empty and mandatory, but it can also do more validations for other kind of fields, like if the option selected is valid, or if a date should be only in the past etc. It can provide a custom error message also.

.. code-block:: Perl

   sub SearchFieldRender { ... }

This function is used by ticket search dialog and it is similar to ``EditFieldRander()``, but normally on a search screen small changes has to be done for all fields. For this example we use a HTML text input instead of a password input. In other fields like dropdown field is displayed as a multiple select in order to let the user search for more than one value at a time.

.. code-block:: Perl

   sub SearchFieldValueGet { ... }

Very similar to ``EditFieldValueGet()``, but uses a different name prefix, adapted for the search dialog screen.

.. code-block:: Perl

   sub SearchFieldParameterBuild { ... }

This function is used also by the ticket search dialog to set the correct operator and value to do the search on this field. It also returns how the value should be displayed in the used search attributes in the results page.

.. code-block:: Perl

   sub StatsFieldParameterBuild { ... }

This function is used by the stats modules. It includes the field definition in the stats format. For fields with fixed values it also includes all this possible values and if they can be translated, take a look to the ``BaseSelect`` driver code for an example how to implement those.

.. code-block:: Perl

   sub StatsSearchFieldParameterBuild { ... }

This function is very similar to the ``SearchFieldParameterBuild()``. The difference is that the
latter gets the value from the search profile and this one gets the value directly from its parameters.

This function is used by statistics module.

.. code-block:: Perl

   sub TemplateValueTypeGet { ... }

This function is used to know how the dynamic field values stored on a profile should be retrieved, as a scalar or as an array, and it also defines the correct name of the field in the profile.

.. code-block:: Perl

   sub RandomValueSet { ... }

This function is used by ``otrs.FillDB.pl`` script to populate the database with some test and random data. The value inserted by this function is not really relevant. The only restriction is that the value must be compatible with the field value type.

.. code-block:: Perl

   sub ObjectMatch { ... }

Used by the notification modules. This function returns 1 if the field is present in the ``$Param{ObjectAttributes}`` parameter and if it matches the given value.
