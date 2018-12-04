Code Style Guide
================

In order to preserve the consistent development of the OTRS project, we have set up guidelines regarding style for the different programming languages.

.. _code-style-guide-perl:

Perl
----

Whitespace
~~~~~~~~~~

TAB: We use 4 spaces. Examples for braces:

.. code-block:: Perl

   if ($Condition) {
       Foo();
   }
   else {
       Bar();
   }

   while ($Condition == 1) {
       Foo();
   }


Length of Lines
~~~~~~~~~~~~~~~

Lines should generally not be longer than 120 characters, unless it is necessary for special reasons.


Spaces and Parentheses
~~~~~~~~~~~~~~~~~~~~~~

To gain more readability, we use spaces between keywords and opening parenthesis.

.. code-block:: Perl

   if ()...
   for ()...

If there is just one single variable, the parenthesis enclose the variable with no spaces inside.

.. code-block:: Perl

   if ($Condition) { ... }

   # instead of

   if ( $Condition ) { ... }

If the condition is not just one single variable, we use spaces between the parenthesis and the condition. And there is still the space between the keyword (e.g. ``if``) and the opening parenthesis.

.. code-block:: Perl

   if ( $Condition && $ABC ) { ... }

Note that for Perl builtin functions, we do not use parentheses:

.. code-block:: Perl

   chomp $Variable;


Source Code Header and Charset
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Attach the following header to every source file. Source files are saved in UTF-8 charset.

.. code-block:: Perl

   # --
   # Copyright (C) 2001-2018 OTRS AG, https://otrs.com/
   # --
   # This software comes with ABSOLUTELY NO WARRANTY. For details, see
   # the enclosed file COPYING for license information (GPL). If you
   # did not receive this file, see https://www.gnu.org/licenses/gpl-3.0.txt.
   # --

Executable files (``*.pl``) have a special header.

.. code-block:: Perl

   #!/usr/bin/perl
   # --
   # Copyright (C) 2001-2018 OTRS AG, https://otrs.com/
   # --
   # This program is free software: you can redistribute it and/or modify
   # it under the terms of the GNU General Public License as published by
   # the Free Software Foundation, either version 3 of the License, or
   # (at your option) any later version.
   #
   # This program is distributed in the hope that it will be useful,
   # but WITHOUT ANY WARRANTY; without even the implied warranty of
   # MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
   # GNU General Public License for more details.
   #
   # You should have received a copy of the GNU General Public License
   # along with this program. If not, see https://www.gnu.org/licenses/gpl-3.0.txt.
   # --


Conditions
~~~~~~~~~~

Conditions can be quite complex and there can be *chained* conditions (linked with logical *or* or *and* operations). When coding for OTRS, you have to be aware of several situations.

Perl best practices says, that high precedence operators (``&&`` and ``||``) shouldn't mixed up with low precedence operators (``and`` and ``or``). To avoid confusion, we always use the high precedence operators.

.. code-block:: Perl

   if ( $Condition1 && $Condition2 ) { ... }

   # instead of

   if ( $Condition and $Condition2 ) { ... }

This means that you have to be aware of traps. Sometimes you need to use parenthesis to make clear what you want.

If you have long conditions (line is longer than 120 characters over all), you have to break it in several lines. And the start of the conditions is in a new line (not in the line of the ``if``).

.. code-block:: Perl

   if (
       $Condition1
       && $Condition2
       )
   { ... }

   # instead of

   if ( $Condition1
       && $Condition2
       )
   { ... }

Also note, that the right parenthesis is in a line on its own and the left curly bracket is also in a new line and with the same indentation as the ``if``. The operators are at the beginning of a new line! The subsequent examples show how to do it.

.. code-block:: Perl

   if (
       $XMLHash[0]->{otrs_stats}[1]{StatType}[1]{Content}
       && $XMLHash[0]->{otrs_stats}[1]{StatType}[1]{Content} eq 'static'
       )
   { ... }

   if ( $TemplateName eq 'AgentTicketCustomer' ) {
       ...
   }

   if (
       ( $Param{Section} eq 'Xaxis' || $Param{Section} eq 'All' )
       && $StatData{StatType} eq 'dynamic'
       )
   { ... }

   if (
       $Self->{TimeObject}->TimeStamp2SystemTime( String => $Cell->{TimeStop} )
       > $Self->{TimeObject}->TimeStamp2SystemTime(
           String => $ValueSeries{$Row}{$TimeStop}
       )
       || $Self->{TimeObject}->TimeStamp2SystemTime( String => $Cell->{TimeStart} )
       < $Self->{TimeObject}->TimeStamp2SystemTime(
           String => $ValueSeries{$Row}{$TimeStart}
       )
       )
   { ... }


Postfix ``if``
~~~~~~~~~~~~~~

Generally we use *postfix ``if``* statements to reduce the number of levels. But we don't use it for multiline statements and is only allowed when involves return statements in functions or to end a loop or to go next iteration.

This is correct:

.. code-block:: Perl

   next ITEM if !$ItemId;

This is wrong:

.. code-block:: Perl

   return $Self->{LogObject}->Log(
       Priority => 'error',
       Message  => 'ItemID needed!',
   ) if !$ItemId;

This is less maintainable than this:

.. code-block:: Perl

   if( !$ItemId ) {
       $Self->{LogObject}->Log( ... );
       return;
   }

This is correct:

.. code-block:: Perl

   for my $Needed ( 1 .. 10 ) {
       next if $Needed == 5;
       last  if $Needed == 9;
   }

This is wrong:

.. code-block:: Perl

   my $Var = 1 if $Something == 'Yes';


Restrictions for the Use of Some Perl Builtins
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Some builtin subroutines of Perl may not be used in every place:

-  Don't use ``die`` and ``exit`` in ``.pm`` files.
-  Don't use the ``Dumper`` function in released files.
-  Don't use ``print`` in ``.pm`` files.
-  Don't use ``require``, use ``Main::Require()`` instead.
-  Use the functions of the ``DateTimeObject`` instead of the builtin functions like ``time()``, ``localtime()``, etc.


Regular Expressions
~~~~~~~~~~~~~~~~~~~

For regular expressions *in the source code*, we always use the ``m//`` operator with curly braces as delimiters. We also use the modifiers ``x``, ``m`` and ``s`` by default. The ``x`` modifier allows you to comment your regex and use spaces to visually separate logical groups.

.. code-block:: Perl

   $Date =~ m{ \A \d{4} - \d{2} - \d{2} \z }xms
   $Date =~ m{
       \A      # beginning of the string
       \d{4} - # year
       \d{2} - # month
       [^\n]   # everything but newline
       #..
   }xms;

As the space no longer has a special meaning, you have to use a single character class to match a single space (``[ ]``). If you want to match any whitespace you can use ``\s``.

In the regex, the dot (``.``) includes the newline (whereas in regex without ``s`` modifier the dot means 'everything but newline'). If you want to match anything but newline, you have to use the negated single character class (``[^\n]``).

.. code-block:: Perl

   $Text =~ m{
       Test
       [ ]    # there must be a space between 'Test' and 'Regex'
       Regex
   }xms;

An exception to the convention above applies to all cases where regular expressions are not written statically in the code but instead are *supplied by users* in one form or another (for example via system configuration or in a Postmaster filter configuration). Any evaluation of such a regular expression has to be done without any modifiers (e.g. ``$Variable =~ m{$Regex}``) in order to match the expectation of (mostly inexperienced) users and also to be backwards compatible.

If modifiers are strictly necessary for user supplied regular expressions, it is always possible to use embedded modifiers (e.g. ``(?:(?i)SmAlL oR lArGe)``). For details, please see `perlretut <http://perldoc.perl.org/perlretut.html#Embedding-comments-and-modifiers-in-a-regular-expression>`__.

Usage of the ``r`` modifier is encouraged, e.g. if you need to extract part of a string into another variable. This modifier keeps the matched variable intact and instead provides the substitution result as a return value.

Use this:

.. code-block:: Perl

   my $NewText = $Text =~ s{
       \A
       Prefix
       (
           Text
       )
   }
   {NewPrefix$1Postfix}xmsr;

Instead of this:

.. code-block:: Perl

   my $NewText = $Text;
   $NewText =~ s{
       \A
       Prefix
       (
           Text
       )
   }
   {NewPrefix$1Postfix}xms;

If you want to match for start and end of a **string**, you should generally use ``\A`` and ``\z`` instead of the more generic ``^`` and ``$`` unless you really need to match start or end of **lines** within a multiline string.

.. code-block:: Perl

   $Text =~ m{
       \A      # beginning of the string
       Content # some string
       \z      # end of the string
   }xms;

   $MultilineText =~ m{
       \A                      # beginning of the string
       .*
       (?: \n Content $ )+      # one or more lines containing the same string
       .*
       \z                      # end of the string
   }xms;

Usage of named capture groups is also encouraged, particularly for multi-matches. Named capture groups are easier to read/understand, prevent mix-ups when matching more than one capture group and allow extension without accidentally introducing bugs.

Use this:

.. code-block:: Perl

   $Contact =~ s{
       \A
       [ ]*
       (?'TrimmedContact'
           (?'FirstName' \w+ )
           [ ]+
           (?'LastName' \w+ )
       )
       [ ]+
       (?'Email' [^ ]+ )
       [ ]*
       \z
   }
   {$+{TrimmedContact}}xms;
   my $FormattedContact = "$+{LastName}, $+{FirstName} ($+{Email})";

Instead of this:

.. code-block:: Perl

   $Contact =~ s{
       \A
       [ ]*
       (
           ( \w+ )
           [ ]+
           ( \w+ )
       )
       [ ]+
       ( [^ ]+ )
       [ ]*
       \z
   }
   {$1}xms;
   my $FormattedContact = "$3, $2 ($4)";


Naming
~~~~~~

Names and comments are written in English. Variables, objects and methods must be descriptive nouns or noun phrases with the first letter set upper case (`CamelCase <https://en.wikipedia.org/wiki/CamelCase>`__).

Names should be as descriptive as possible. A reader should be able to say what is meant by a name without digging too deep into the code. E.g. use ``$ConfigItemID`` instead of ``$ID``. Examples: ``@TicketIDs``, ``$Output``, ``StateSet()``, etc.


Variable Declaration
~~~~~~~~~~~~~~~~~~~~

If you have several variables, you can declare them in one line if they *belong together*:

.. code-block:: Perl

   my ( $Minute, $Hour, $Year );

Otherwise break it into separate lines:

.. code-block:: Perl

   my $Minute;
   my $ID;

Do not set to ``undef`` or ``''`` in the declaration as this might hide mistakes in code.

.. code-block:: Perl

   my $Variable = undef;

   # is the same as

   my $Variable;

You can set a variable to ``''`` if you want to concatenate strings:

.. code-block:: Perl

   my $SqlStatement = '';
   for my $Part (@Parts) {
       $SqlStatement .= $Part;
   }

Otherwise you would get an *uninitialized* warning.


Handling of Parameters
~~~~~~~~~~~~~~~~~~~~~~

To fetch the parameters passed to subroutines, OTRS normally uses the hash ``%Param`` (not ``%Params``). This leads to more readable code as every time we use ``%Param`` in the subroutine code we know it is the parameter hash passed to the subroutine.

Just in some exceptions a regular list of parameters should be used. So we want to avoid something like this:

.. code-block:: Perl

   sub TestSub {
       my ( $Self, $Param1, $Param2 ) = @_;
   }

We want to use this instead:

.. code-block:: Perl

   sub TestSub {
       my ( $Self, %Param ) = @_;
   }

This has several advantages:

- We do not have to change the code in the subroutine when a new parameter should be passed.
- Calling a function with named parameters is much more readable.


Multiple Named Parameters
~~~~~~~~~~~~~~~~~~~~~~~~~

If a function call requires more than one named parameter, split them into multiple lines.

Use this:

.. code-block:: Perl

   $Self->{LogObject}->Log(
       Priority => 'error',
       Message  => "Need $Needed!",
   );

Instead of this:

.. code-block:: Perl

   $Self->{LogObject}->Log( Priority => 'error', Message  => "Need $Needed!", );


``return`` Statements
~~~~~~~~~~~~~~~~~~~~~

Subroutines have to have a ``return`` statement. The explicit ``return`` statement is preferred over the implicit way (result of last statement in subroutine) as this clarifies what the subroutine returns.

.. code-block:: Perl

   sub TestSub {
       ...
       return; # return undef, but not the result of the last statement
   }


Explicit Return Values
~~~~~~~~~~~~~~~~~~~~~~

Explicit return values means that you should not have a ``return`` statement followed by a subroutine call.

.. code-block:: Perl

   return $Self->{DBObject}->Do( ... );

The following example is better as this says explicitly what is returned. With the example above the reader doesn't know what the return value is as he might not know what ``Do()`` returns.

.. code-block:: Perl

   return if !$Self->{DBObject}->Do( ... );
   return 1;

If you assign the result of a subroutine to a variable, a *good* variable name indicates what was returned:

.. code-block:: Perl

   my $SuccessfulInsert = $Self->{DBObject}->Do( ... );
   return $SuccessfulInsert;


``use`` Statements
~~~~~~~~~~~~~~~~~~

``use strict`` and ``use warnings`` have to be the first two *uses* in a module.

This is correct:

.. code-block:: Perl

   package Kernel::System::ITSMConfigItem::History;

   use strict;
   use warnings;

   use Kernel::System::User;
   use Kernel::System::DateTime;

This is wrong:

.. code-block:: Perl

   package Kernel::System::ITSMConfigItem::History;

   use Kernel::System::User;
   use Kernel::System::DateTime;

   use strict;
   use warnings;


Objects and Their Allocation
~~~~~~~~~~~~~~~~~~~~~~~~~~~~

In OTRS many objects are available. But you should not use every object in every file to keep the front end/back end separation.

-  Don't use the ``LayoutObject`` in core modules (``Kernel/System``).
-  Don't use the ``ParamObject`` in core modules (``Kernel/System``).
-  Don't use the ``DBObject`` in frontend modules (``Kernel/Modules``).


Documenting Back End Modules
~~~~~~~~~~~~~~~~~~~~~~~~~~~~

``NAME`` section
   This section should include the module name, `` - `` as separator and a brief description of the module purpose.

   .. code-block:: Perl

      =head1 NAME

      Kernel::System::MyModule - Functions to read from and write to files

``SYNOPSIS`` section
   This section should give a short usage example of commonly used module functions.

   Usage of this section is optional.

   .. code-block:: Perl

      =head1 SYNOPSIS

      my $Object = $Kernel::OM->Get('Kernel::System::MyModule');

      Read data

          my $FileContent = $Object->Read(
              File => '/tmp/testfile',
          );

      Write data

          $Object->Write(
              Content => 'my file content',
              File    => '/tmp/testfile',
          );

``DESCRIPTION`` section
   This section should give more in-depth information about the module if deemed necessary (instead of having a long ``NAME`` section).

   Usage of this section is optional.

   .. code-block:: Perl

      =head1 DESCRIPTION

      This module does not only handle files.

      It is also able to:
      - brew coffee
      - turn lead into gold
      - bring world peace

``PUBLIC INTERFACE`` section
   This section marks the begin of all functions that are part of the API and therefore meant to be used by other modules.

   .. code-block:: Perl

      =head1 PUBLIC INTERFACE

``PRIVATE FUNCTIONS`` section
   This section marks the begin of private functions.

   Functions below are not part of the API, to be used only within the module and therefore not considered stable.

   It is advisable to use this section whenever one or more private functions exist.

   .. code-block:: Perl

      =head1 PRIVATE FUNCTIONS


Documenting Subroutines
~~~~~~~~~~~~~~~~~~~~~~~

Subroutines should always be documented. The documentation contains a general description about what the subroutine does, a sample subroutine call and what the subroutine returns. It should be in this order. A sample documentation looks like this:

.. code-block:: Perl

   =head2 LastTimeObjectChanged()

   Calculates the last time the object was changed. It returns a hash reference with
       information about the object and the time.

       my $Info = $Object->LastTimeObjectChanged(
           Param => 'Value',
       );

   This returns something like:

       my $Info = {
           ConfigItemID    => 1234,
           HistoryType     => 'foo',
           LastTimeChanged => '08.10.2009',
       };

   =cut

You can copy and paste a ``Data::Dumper`` output for the return values.


Code Comments in Perl
~~~~~~~~~~~~~~~~~~~~~

In general, you should try to write your code as readable and self-explaining as possible. Don't write a comment to explain what obvious code does, this is unnecessary duplication. Good comments should explain **why** there is some code, possible side effects and anything that might be special or unusually complicated about the code.

Please adhere to the following guidelines:

Make the code so readable that comments are not needed, if possible.
   It's always preferable to write code so that it is very readable and self-explaining, for example with precise variable and function names.

Don't say what the code says (DRY -> Don't repeat yourself).
   Don't repeat (obvious) code in the comments.

   .. code-block:: Perl

      # WRONG:

      # get config object
      my $ConfigObject = $Kernel::OM->Get('Kernel::Config');

Document **why** the code is there, not how it works.
   Usually, code comments should explain the *purpose* of code, not how it works in detail. There might be exceptions for specially complicated code, but in this case also a refactoring to make it more readable could be commendable.

Document pitfalls.
   Everything that is unclear, tricky or that puzzled you during development should be documented.

Use full-line sentence-style comments to document algorithm paragraphs.
   Always use full sentences (uppercase first letter and final period). Subsequent lines of a sentence should be indented.

   .. code-block:: Perl

      # Check if object name is provided.
      if ( !$_[1] ) {
          $_[0]->_DieWithError(
              Error => "Error: Missing parameter (object name)",
          );
      }

      # Record the object we are about to retrieve to potentially build better error messages.
      # Needs to be a statement-modifying 'if', otherwise 'local' is local
      #   to the scope of the 'if'-block.
      local $CurrentObject = $_[1] if !$CurrentObject;

Use short end-of-line comments to add detail information.
   These can either be a complete sentence (capital first letter and period) or just a phrase (lowercase first letter and no period).

   .. code-block:: Perl

      $BuildMode = oct $Param{Mode};   # *from* octal, not *to* octal

      # or

      $BuildMode = oct $Param{Mode};   # Convert *from* octal, not *to* octal.


Declaration of SQL Statements
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

If there is no chance for changing the SQL statement, it should be used in the ``Prepare`` function. The reason for this is, that the SQL statement and the bind parameters are closer to each other. 

The SQL statement should be written as one nicely indented string without concatenation like this:

.. code-block:: Perl

   return if !$Self->{DBObject}->Prepare(
       SQL => '
           SELECT art.id
           FROM article art, article_sender_type ast
           WHERE art.ticket_id = ?
               AND art.article_sender_type_id = ast.id
               AND ast.name = ?
           ORDER BY art.id',
       Bind => [ \$Param{TicketID}, \$Param{SenderType} ],
   );

This is easy to read and modify, and the whitespace can be handled well by our supported DBMSs. For auto-generated SQL code (like in ``TicketSearch``), this indentation is not necessary.


Returning on Errors
~~~~~~~~~~~~~~~~~~~

Whenever you use database functions you should handle errors. If anything goes wrong, return from subroutine:

.. code-block:: Perl

   return if !$Self->{DBObject}->Prepare( ... );


Using Limit
~~~~~~~~~~~

Use ``Limit => 1`` if you expect just one row to be returned.

.. code-block:: Perl

   $Self->{DBObject}->Prepare(
       SQL   => 'SELECT id FROM users WHERE username = ?',
       Bind  => [ \$Username ],
       Limit => 1,
   );


Using the ``while`` loop
~~~~~~~~~~~~~~~~~~~~~~~~

Always use the ``while`` loop, even when you expect one row to be returned, as some databases do not release the statement handle and this can lead to weird bugs.


JavaScript
----------

All JavaScript is loaded in all browsers (no browser hacks in the template files). The code is responsible to decide if it has to skip or execute certain parts of itself only in certain browsers.


Directory Structure
~~~~~~~~~~~~~~~~~~~

Directory structure inside the ``var/httpd/htdocs/js/`` folder:

.. code-block:: none

   * js
       * thirdparty              # thirdparty libs always have the version number inside the directory
           * ckeditor-3.0.1
           * jquery-1.3.2
       * Core.Agent.*            # stuff specific to the agent interface
       * Core.Customer.*         # customer interface
       * Core.*                  # common API


Thirdparty Code
~~~~~~~~~~~~~~~

Every thirdparty module gets its own subdirectory: *module name-version number* (e.g. ckeditor-4.7.0, jquery-3.2.1). Inside of that, file names should not have a version number or postfix included (wrong: ``jquery/jquery-3.2.1.min.js``, right: ``jquery-3.2.1/jquery.js``).


JavaScript Variables
~~~~~~~~~~~~~~~~~~~~

Variable names should be CamelCase, just like in Perl.

Variables that hold a jQuery object should start with ``$``, for example: ``$Tooltip``.


Functions
~~~~~~~~~

Function names should be CamelCase, just like in Perl.


Namespaces
~~~~~~~~~~

.. TODO...


Code Comments in JavaScript
~~~~~~~~~~~~~~~~~~~~~~~~~~~

The :ref:`Code Comments in Perl` also apply to JavaScript.

-  Single line comments are done with ``//``.
-  Longer comments are done with ``/* ... */``.
-  If you comment out parts of your JavaScript code, only use ``//`` because ``/* ... */`` can cause  problems with regular expressions in the code.


Event Handling
~~~~~~~~~~~~~~

Always use ``$.on()`` instead of the event-shorthand methods of jQuery for better readability (wrong: ``$SomeObject.click(...)``, right: ``$SomeObject.on('click', ...``).

If you ``$.on()`` events, make sure to ``$.off()`` them beforehand, to make sure that events will not be bound twice, should the code be executed another time.

Make sure to use ``$.on()`` with namespacing, such as ``$.on('click.<Name>')``.


HTML
----

Use HTML 5 notation. Don't use self-closing tags for non-void elements (such as div, span, etc.).

Use proper intendation. Elements which contain other non-void child elements should not be on the same level as their children.

Don't use HTML elements for layout reasons (e.g. using ``br`` elements for adding space to the top or bottom of other elements). Use the proper CSS classes instead.

Don't use inline CSS. All CSS should either be added by using predefined classes or (if necessary) using JavaScript (e.g. for showing/hiding elements).

Don't use JavaScript in templates. All needed JavaScript should be part of the proper library for a certain frontend module or of a proper global library. If you need to pass JavaScript data to the front end, use ``$LayoutObject->AddJSData()``.


CSS
---

Minimum resolution is 1024x768px.

The layout is liquid, which means that if the screen is wider, the space will be used.

Absolute size measurements should be specified in px to have a consistent look on many platforms and browsers.

Documentation is made with CSSDOC (see CSS files for examples). All logical blocks should have a CSSDOC comment.


CSS Architecture
~~~~~~~~~~~~~~~~

We follow the `Object Oriented CSS <http://wiki.github.com/stubbornella/oocss/>`__ approach. In essence, this means that the layout is achieved by combining different generic building blocks to realize a particular design.

Wherever possible, module specific design should not be used. Therefore we also do not work with IDs on the ``body`` element, for example, if it can be avoided.


CSS Style
~~~~~~~~~

All definitions have a ``{`` in the same line as the selector, all rules are defined in one row per rule, the definition ends with a row with a single ``}`` in it.

See the following example:

.. code-block:: CSS

   #Selector {
       width: 10px;
       height: 20px;
       padding: 4px;
   }

- Between ``:`` and the rule value, there is a space.
- Every rule has an indent of 4 spaces.
- If multiple selectors are specified, separate them with comma and put each one on an own line:

   .. code-block:: CSS

      #Selector1,
      #Selector2,
      #Selector3 {
          width: 10px;
      }

- If rules are combinable, combine them (e.g. combine ``background-position``, ``background-image``, etc. into ``background``).

- Rules should be in a logical order within a definition (all color specific rule together, all positioning rules together, etc.).
- All IDs and names are written in CamelCase notation:

   .. code-block:: HTML

      <div class="NavigationBar" id="AdminMenu"></div>
