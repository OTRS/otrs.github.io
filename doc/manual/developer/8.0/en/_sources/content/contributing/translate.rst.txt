Translating
===========

The OTRS framework allows for different languages to be used in the front end. The translations are contributed and maintained mainly by OTRS users, so *your* help is needed.


Updating Translations
---------------------

All translations of the OTRS GUI, the public extension modules and the documentations are managed via
`Transifex <https://www.transifex.com/otrs/OTRS/>`__.

To contribute to translations:

1. Sign up for a free translators account on `Transifex <https://www.transifex.com>`__.
2. Join your language team and wait for the acceptance.
3. Start updating your translation. No additional software or files required.

The OTRS developers will download the translations from time to time into the OTRS source code repositories, you don't have to submit them anywhere.


Adding New Language
-------------------

If you want to translate the OTRS framework into a new language, you can propose a new language translation on `the Transifex OTRS project page <https://www.transifex.com/otrs/OTRS/>`__. After it is approved, you can just start translating.


Translating the Documentation
-----------------------------

From OTRS 7 the documentations are available in reStructuredText, that replaced the old DocBook XML format.

It is important that the structure of the generated XML stays intact. So if the original string is ``Edit <filename>Kernel/Config.pm</filename>``, then the German translation has to be ``<filename>Kernel/Config.pm</filename> bearbeiten``, keeping the XML tags intact. Regular ``<`` and ``>`` signs that are escaped in the source text must also be escaped in the translations (like ``&lt;someone@example.com&gt;``). Scripts and examples usually do not have to be translated (so you can just copy the source text to the translation text field in this case).

The new reStructuredText format has also special tags to format the documentation. For more information, please check the `reStructuredText user manual <http://docutils.sourceforge.net/docs/user/rst/quickref.html>`__. So if the original string is ``Edit **Kernel/Config.pm**``, then the German translation has to be ``**Kernel/Config.pm** bearbeiten``, keeping the reStructuredText tags intact.
