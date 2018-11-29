The CSS and JavaScript Loader
=============================

The CSS and JavaScript code in OTRS grew to a large amount. To be able to satisfy both development concerns (good maintainability by a large number of separate files) and performance issues (making few HTTP requests and serving minified content without unneccessary whitespace and documentation) had to be addressed. To achieve these goals, the Loader was invented.


How it works
------------

To put it simple, the loader:

-  determines for each request precisely which CSS and JavaScript files are needed at the client side by the current application module
-  collects all the relevant data
-  minifies the data, removing unnecessary whitespace and documentation
-  serves it to the client in only a few HTTP requests instead of many individual ones, allowing the client to cache these snippets in the browser cache
-  performs these tasks in a highly performing way, utilizing the caching mechanisms of OTRS

Of course, there is a little bit more detailed involved, but this should suffice as a first overview.


Basic Operation
---------------

With the configuration settings ``Loader::Enabled::CSS`` and ``Loader::Enabled::JavaScript``, the loader can be turned on and off for CSS and JavaScript, respectively (it is on by default).

.. warning::

   Because of rendering problems in Internet Explorer, the loader cannot be turned off for CSS files for this client browser (config setting will be overridden). Up to version 8, Internet Explorer cannot handle   more than 32 CSS files on a page.

To learn about how the loader works, please turn it off in your OTRS installation with the aforementioned configuration settings. Now look at the source code of the application module that you are currently using in this OTRS system (after a reload, of course). You will see that there are many CSS files loaded in the ``<head>`` section of the page, and many JavaScript files at the bottom of the page, just before the closing ``</body>`` element.

Having the content like this in many individual files with a readable formatting makes the development much easier, and even possible at all. However, this has the disadvantage of a large number of HTTP requests (network latency has a big effect) and unnecessary content (whitespace and documentation) which needs to be transferred to the client.

The loader solves this problem by performing the steps outlined in the short description above. Please turn on the Loader again and reload your page now. Now you can see that there are only very few CSS and JavaScript tags in the HTML code, like this:

.. code-block:: HTML

   <script type="text/javascript" src="/otrs30-dev-web/js/js-cache/CommonJS_d16010491cbd4faaaeb740136a8ecbfd.js"></script>

   <script type="text/javascript" src="/otrs30-dev-web/js/js-cache/ModuleJS_b54ba9c085577ac48745f6849978907c.js"></script>

What just happened? During the original request generating the HTML code for this page, the Loader generated these two files (or took them from the cache) and put the shown ``<script>`` tags on the page which link to these files, instead of linking to all relevant JavaScript files separately (as you saw it without the loader being active).

The CSS section looks a little more complicated:

.. code-block:: HTML

       <link rel="stylesheet" type="text/css" href="/otrs30-dev-web/skins/Agent/default/css-cache/CommonCSS_00753c78c9be7a634c70e914486bfbad.css" />

   <!--[if IE 7]>
       <link rel="stylesheet" type="text/css" href="/otrs30-dev-web/skins/Agent/default/css-cache/CommonCSS_IE7_59394a0516ce2e7359c255a06835d31f.css" />
   <![endif]-->

   <!--[if IE 8]>
       <link rel="stylesheet" type="text/css" href="/otrs30-dev-web/skins/Agent/default/css-cache/CommonCSS_IE8_ff58bd010ef0169703062b6001b13ca9.css" />
   <![endif]-->

The reason is that Internet Explorer 7 and 8 need special treatment in addition to the default CSS because of their lacking support of web standard technologies. So we have some normal CSS that is loaded in all browsers, and some special CSS that is inside of so-called *conditional comments* which cause it to be loaded **only** by Internet Explorer 7/8. All other browsers will ignore it.

Now we have outlined how the loader works. Let's look at how you can utilize that in your own OTRS extensions by adding configuration data to the loader, telling it to load additional or alternative CSS or JavaScript content.


Configuring the Loader: JavaScript
----------------------------------

To be able to operate correctly, the loader needs to know which content it has to load for a particular OTRS application module. First, it will look for JavaScript files which *always* have to be loaded, and then it looks for special files which are only relevant for the current application module.


Common JavaScript
~~~~~~~~~~~~~~~~~

The list of JavaScript files to be loaded is configured in the configuration settings ``Loader::Agent::CommonJS`` (for the agent interface) and ``Loader::Customer::CommonJS`` (for the customer interface).

These settings are designed as hashes, so that OTRS extensions can add their own hash keys for additional content to be loaded. Let's look at an example:

.. code-block:: XML

   <Setting Name="Loader::Agent::CommonJS###000-Framework" Required="1" Valid="1">
       <Description Translatable="1">List of JS files to always be loaded for the agent interface.</Description>
       <Navigation>Frontend::Base::Loader</Navigation>
       <Value>
           <Array>
               <Item>thirdparty/jquery-3.2.1/jquery.js</Item>
               <Item>thirdparty/jquery-browser-detection/jquery-browser-detection.js</Item>

               ...

               <Item>Core.Agent.Header.js</Item>
               <Item>Core.UI.Notification.js</Item>
               <Item>Core.Agent.Responsive.js</Item>
           </Array>
       </Value>
   </Setting>

This is the list of JavaScript files which always need to be loaded for the agent interface of OTRS.

To add new content which is supposed to be loaded always in the agent interface, just add an XML configuration file with another hash entry:

.. code-block:: XML

   <Setting Name="Loader::Agent::CommonJS###000-Framework" Required="1" Valid="1">
       <Description Translatable="1">List of JS files to always be loaded for the agent interface.</Description>
       <Navigation>Frontend::Base::Loader</Navigation>
       <Value>
           <Array>
               <Item>thirdparty/jquery-3.2.1/jquery.js</Item>
           </Array>
       </Value>
   </Setting>

Simple, isn't it?


Module Specific JavaScript
~~~~~~~~~~~~~~~~~~~~~~~~~~

Not all JavaScript is usable for all application modules of OTRS. Therefore it is possible to specify module specific JavaScript files. Whenever a certain module is used (such as ``AgentDashboard``), the module specific JavaScript for this module will also be loaded. The configuration is done in the frontend module registration in the XML configurations. Again, an example:

.. code-block:: XML

   <Setting Name="Loader::Module::AgentDashboard###001-Framework" Required="0" Valid="1">
       <Description Translatable="1">Loader module registration for the agent interface.</Description>
       <Navigation>Frontend::Agent::ModuleRegistration::Loader</Navigation>
       <Value>
           <Hash>
               <Item Key="CSS">
                   <Array>
                       <Item>Core.Agent.Dashboard.css</Item>

                       ...

                   </Array>
               </Item>
               <Item Key="JavaScript">
                   <Array>
                       <Item>thirdparty/momentjs-2.18.1/moment.min.js</Item>
                       <Item>thirdparty/fullcalendar-3.4.0/fullcalendar.min.js</Item>
                       <Item>thirdparty/d3-3.5.6/d3.min.js</Item>
                       <Item>thirdparty/nvd3-1.7.1/nvd3.min.js</Item>
                       <Item>thirdparty/nvd3-1.7.1/models/OTRSLineChart.js</Item>
                       <Item>thirdparty/nvd3-1.7.1/models/OTRSMultiBarChart.js</Item>
                       <Item>thirdparty/nvd3-1.7.1/models/OTRSStackedAreaChart.js</Item>
                       <Item>thirdparty/canvg-1.4/rgbcolor.js</Item>
                   </Array>
               </Item>
           </Hash>
       </Value>
   </Setting>

It is possible to put a ``<Item Key="JavaScript">`` tag in the frontend module registrations which may contain ``<Array>`` and one tag ``<Item>`` for each JavaScript file that is supposed to be loaded for
this application module.

Now you have all information you need to configure the way the loader handles JavaScript code.


Configuring the Loader: CSS
---------------------------

The loader handles CSS files very similar to JavaScript files, as described in the previous section, and
extending the settings works in the same way too.


Common CSS
~~~~~~~~~~

The way common CSS is handled is very similar to the way :ref:`Common JavaScript` is loaded.
