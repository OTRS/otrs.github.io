Writing A New OTRS Frontend Component
=====================================

In this example, we will try to write a new OTRS frontend component. Starting with OTRS 7, the framework supports single page application frontends written in Vue.js and based on a new JavaScript toolchain. First iteration contains the new external interface, for which we will try to write a custom component. You will need to have a running OTRS development environment as specified in the chapter of the same name.


The Goal
--------

We want to write a small frontend component that displays the text *Hello World* when called up. This will be a route component, meaning it will be available in the external interface when called with a carefully crafted URL.


Using The Skeleton Command
--------------------------

To speed up the development, we should use a skeleton command to get a boilerplate template file which we can build upon.

On a running OTRS instance, call the following command to generate the template. We will use ``HelloWorld`` as the name of our new component:

.. code-block:: bash

   bin/otrs.Console.pl Dev::Code::Generate::VueComponent --component-directory /ws/MyPackage --component-subdirectory Apps/External/Components/Route --no-docs HelloWorld

where ``--component-directory`` is the directory of your module, ``--component-subdirectory`` path under ``Frontend/`` folder that will house the component file. For now, use ``--no-docs`` switch to skip creation of the documentation component for the design system.

This command will generate two files with following paths:

::

   Generated: /ws/MyPackage/Frontend/Apps/External/Components/Route/HelloWorld.vue
   Generated: /ws/MyPackage/Frontend/Tests/Apps/External/Components/Route/HelloWorld.js
   Skipped creating documentation component.


The Route Configuration
-----------------------

In order to allow the route in the external interface application, we need to add a correct route configuration that points to our component. Therefore we create a file ``Kernel/Config/Files/XML/HelloWorld.xml`` with following definition:

.. code-block:: XML

   <?xml version="1.0" encoding="utf-8" ?>
   <otrs_config version="2.0" init="Application">
       <Setting Name="ExternalFrontend::Route###420-HelloWorld" Required="0" Valid="1">
           <Description Translatable="1">Defines the application routes for the external interface. Additional routes are defined by adding new items and specifying their parameters. 'Group' and 'GroupRo' arrays can be used to limit access of the route to members of certain groups with RW and RO permissions respectively. 'Path' defines the relative path of the route, and 'Alias' can be used for specifying an alternative path. 'Component' is the path of the Vue component responsible for displaying the route content, relative to the Components/Route folder in the app. 'IsPublic' defines if the route will be accessible for unauthenticated users and in case this is set to '1', 'Group' and 'GroupRo' parameters will be ignored. 'Props' can be used to signal that the path contain dynamic segments, and that their values should be bound to the component as props (use '1' to turn on this feature).</Description>
           <Navigation>Frontend::External::Route</Navigation>
           <Value>
               <Array>
                   <DefaultItem ValueType="ApplicationRoute">
                       <Hash>
                       </Hash>
                   </DefaultItem>
                   <Item>
                       <Hash>
                           <Item Key="Group">
                               <Array>
                               </Array>
                           </Item>
                           <Item Key="GroupRo">
                               <Array>
                               </Array>
                           </Item>
                           <Item Key="Path">/hello-world/:headingText?</Item>
                           <Item Key="Alias"></Item>
                           <Item Key="Component">HelloWorld</Item>
                           <Item Key="IsPublic">1</Item>
                           <Item Key="Props">1</Item>
                       </Hash>
                   </Item>
               </Array>
           </Value>
       </Setting>
   </otrs_config>

- ``Group`` and ``GroupRo`` can be used to limit the route screen to users with certain groups. Please note that this only concerns the authenticated customer users.
- ``Path`` is actually the slug under which the route component will be available. The full URL in this case will be ``/external/hello-world``, and any subsequent path component will be passed as a parameter named ``headingText``. If your system has ``Frontend::PrefixPath`` configured, full URL will be prepended by it.
- ``Alias`` can be used to provide an alias for the same route. I.e. ``/hello-world-alt``. It will point to the same component.
- ``Component`` is the component identifier, first part of the filename, without the ``.vue`` extension. In case of component folders, it's the name of the root folder (see :ref:`component folders` for more information).
- ``IsPublic`` defines if the route will be accessible by unauthenticated users (0/Empty - not accessible, 1 - accessible).
- ``Props`` defines if the route will be passed URI parameters as prop values (0/Empty - not passed, 1 - passed). See `here <#passing-parameters>`__ for more info).


Component Template Code
-----------------------

Let's fire up the code editor now and take a closer look at the ``HelloWorld.vue`` file that our skeleton command created.

Top part of the file contains a template section which should contain Vue.js template code. For example, let's modify it so it displays a heading with a text variable:

.. code-block:: XML

   <template>
       <main class="HelloWorld">
           <b-container>
               <b-row>
                   <b-col>
                       <h1 class="HelloWorld__Heading">
                           {{ headingText | translate }}
                       </h1>
                   </b-col>
               </b-row>
           </b-container>
       </main>
   </template>

OTRS supports number of filters, with ``translate`` being one of them. It even supports translation of string literals with placeholder values, you can use it like this:

::

   {{ 'This is a %s.' | translate('string') }}


Component Core Code
-------------------

Next, we add a support for a prop to our component core code block, following is a modified and abridged version suitable for an example:

.. code-block:: HTML

   <script>
   export default {
       name: 'HelloWorld',

       props: {
           headingText: {
               type: String,
               default: translatable('Hello, world!'),
           },
       },
   };
   </script>

This adds a prop with the name ``headingText`` to our component, which is of type string and has a sensible default value.

Usage of ``translatable()`` no-op method is limited to marking translatable strings which appear in the code. Please note that this is not required for string literals which are piped to the translate filter, as this will be assumed from the start. Rule of thumb is to use the marker anywhere where the string is not translated at the place where it is defined.


Component Style Code
--------------------

Last, but not the least, we have an option to specify styles used by the component. For this we have access to the SCSS, which is a flavor of SASS CSS extension set. To leverage it, just add a style tag at the end of the component file:

.. Syntax highlighting not working with CSS, SCSS nor HTML.
.. code-block:: none

   <style lang="scss">
   .HelloWorld {
       &__Heading {
           color: $primary;
       }
   }
   </style>

Inside the style block, you will have access to certain set of global variables and mixins. Please refer to the framework code for details (take a look at the ``Frontend/Styles/globals.js``).

Please note that while the styles will be loaded only when your component is referenced, these will be globally available afterwards since the CSS is inherently global for the same page. There is an option to scope the styles just to your component, you can do this via the ``scoped`` attribute on the style tag, but this might not be necessary with clever usage of BEM approach in designing your class names.


Passing Parameters to the Route Component
-----------------------------------------

In the route configuration above, we defined the route path that contains a parameter placeholder (``headingText``). By activating the ``Props`` flag, we made sure that the value of this parameter will be bound to our component prop with the same name every time a route is entered.

For example, if we enter the route via the ``/external/hello-world`` URL, our component prop will be undefined and therefore will get its default value.

.. figure:: images/passing-parameters-default-prop-value.png
   :alt: Passing Parameters - Default Prop Value

   Passing Parameters - Default Prop Value

But, if we access the route via the ``/external/hello-world/Value``, the prop will be set to string ``Value``, and even automatically translated in the current user language (where applicable).

.. figure:: images/passing-parameters-translated-prop-value.png
   :alt: Passing Parameters - Translated Prop Value

   Passing Parameters - Translated Prop Value


Component Folders
-----------------

In case of self-enclosed components, you might want to ship some additional files with it. Sometimes it's better to modularize the code base since it's easier to maintain. In case of frontend components you have a really simple way of doing this: component folders. Instead of a single ``.vue`` file for a component, enclose the file named ``index.vue`` in a folder named as your component. Something like this:

::

   HelloWorld/
   HelloWorld/index.vue

Then, simply add new files in the same folder, following a sane structure:

::

   HelloWorld/
   HelloWorld/index.vue
   HelloWorld/Styles/_mystyles.scss
   HelloWorld/Images/foobar.png
   HelloWorld/Fonts/awesome-font.woff
   HelloWorld/Fonts/awesome-font.woff2
   HelloWorld/ChildComponent1.vue
   HelloWorld/ChildComponent2/index.vue
   HelloWorld/ChildComponent2/Styles/_childstyles2.scss

You get the idea. It will then be possible to reference the new files via relative paths, in order to achieve something like this in the parent component (``index.vue``):

.. code-block:: HTML

   <template>
       <img src="./Images/foobar.png" alt="Foobar" />
   </template>

Or, something like this:

::

   <script>
   export default {
       name: 'HelloWorld',

       components: {
           ChildComponent1: () => import('./ChildComponent1'),
           ChildComponent2: () => import('./ChildComponent2'),
       },
   ...

Even external styles can be referenced in the correct block:

::

   <style lang="scss">
   @import './Styles/mystyles';
   </style>

With this approach you will be left with a packaged component in a single folder that follows the logical tree hierarchy, and makes all resources easily findable when needed.


Packaging Additional Vendor Modules
-----------------------------------

In certain cases, you might need to ship additional Node.js modules with your package. Unfortunately, both NPM and OTRS do not support easy addition of modules to the root ``node_modules/`` folder, but there is a mechanism to provide pre-packaged module files.

Simply create a ``Frontend/Vendor`` folder in your package, and add your module resources in sub-folders within it.

For example, let us assume we want to ship a useful ``vue-full-calendar`` component and its dependencies as part of our package. This component has following NPM dependencies:

::

   $ npm view vue-full-calendar dependencies
   { 'babel-plugin-transform-runtime': '^6.23.0', fullcalendar: '^3.4.0', 'lodash.defaultsdeep': '^4.6.0' }

However, some of its dependencies have even more dependencies and we can inspect them too:

::

   $ npm view babel-plugin-transform-runtime dependencies
   { 'babel-runtime': '^6.22.0' }

   $ npm view fullcalendar dependencies
   { jquery: '2 - 3', moment: '^2.20.1' }

   $ npm view lodash.defaultsdeep dependencies

Quick check will inform us that both babel-runtime and moment are actually part of the OTRS framework dependencies:

::

   /opt/otrs $ npm list babel-runtime
   otrs-frontend@7.0.0-dev /ws/otrs7-mojo
   ├─┬ bootstrap-vue@2.0.0-rc.11
   │ └─┬ opencollective@1.0.3
   │   └─┬ babel-polyfill@6.23.0
   │     └── babel-runtime@6.26.0  deduped
   ├─┬ esdoc2@2.1.5
   │ ├─┬ babel-generator@6.26.0
   │ │ ├─┬ babel-messages@6.23.0
   │ │ │ └── babel-runtime@6.26.0  deduped
   ...

   /opt/otrs $ npm list moment
   otrs-frontend@7.0.0-dev /ws/otrs7-mojo
   └─┬ moment-timezone@0.5.21
     └── moment@2.22.2

This means that we don't have to ship those modules too, since they will be available out-of-box. While it's cumbersome to check all dependencies, it will be worthwhile because our package will be smaller. We will also prevent issues with overriding framework dependencies, since Frontend/Vendor wins always.

Let's now install what we need and discard what we don't need. The easiest way to do it is via the following NPM command:

::

   /ws/MyPackage $ npm install vue-full-calendar --no-save
   + vue-full-calendar@2.7.0
   added 9 packages from 14 contributors in 1.883s

   /ws/MyPackage $ ls -1 node_modules/
   babel-plugin-transform-runtime
   babel-runtime
   core-js
   fullcalendar
   jquery
   lodash.defaultsdeep
   moment
   regenerator-runtime
   vue-full-calendar

Now we remove those modules which we know are provided by the framework:

::

   /ws/MyPackage $ rm -rf node_modules/babel-runtime node_modules/core-js node_modules/moment node_modules/regenerator-runtime

   /ws/MyPackage $ ls -1 node_modules/
   babel-plugin-transform-runtime
   fullcalendar
   jquery
   lodash.defaultsdeep
   vue-full-calendar

Much better. Now we move the modules to their correct place:

::

   /ws/MyPackage $ mkdir -p Frontend/Vendor
   /ws/MyPackage $ mv node_modules/* Frontend/Vendor/
   /ws/MyPackage $ rmdir node_modules/

Final optimization would be to remove unneeded files from the specific module folders. This might prove to be complicated, but it's worth it since it will further reduce size of the modules and number of files that need to be included in the package.

For example, let's remove minimized JS files from the ``fullcalendar`` module because we identified that the Vue component uses full dist files only:

::

   /ws/MyPackage $ rm Frontend/Vendor/fullcalendar/dist/*.min.*

It's also safe to remove jQuery source and minimized files as well, since the ``fullcalendar`` uses original dist files too:

::

   /ws/MyPackage $ rm Frontend/Vendor/jquery/dist/*.min.*
   /ws/MyPackage $ rm Frontend/Vendor/jquery/external/sizzle/dist/*.min.*
   /ws/MyPackage $ rm -rf Frontend/Vendor/jquery/src

We are left with approx. 100+ files which we need to include in our SOPM files, like any other regular package file. Once we do this, these dependencies will be present and resolvable in the target system:

::

   /ws/MyPackage $ ls -la Frontend/Vendor
   Frontend/Vendor
   Frontend/Vendor/vue-full-calendar
   Frontend/Vendor/vue-full-calendar/.babelrc
   Frontend/Vendor/vue-full-calendar/LICENSE
   Frontend/Vendor/vue-full-calendar/tests
   Frontend/Vendor/vue-full-calendar/tests/fullcalendar.spec.js
   Frontend/Vendor/vue-full-calendar/index.js
   ...
