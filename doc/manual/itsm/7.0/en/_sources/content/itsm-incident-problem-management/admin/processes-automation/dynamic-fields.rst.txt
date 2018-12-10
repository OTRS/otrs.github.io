Dynamic Fields
==============

After installation of the package some new dynamic fields are added to the system. The dynamic field management screen is available in the *Dynamic Fields* module of the *Processes & Automation* group.

.. figure:: images/dynamic-field-management.png
   :alt: Dynamic Field Management Screen

   Dynamic Field Management Screen


New Dynamic Fields
------------------

``ITSMCriticality``
   This is a drop-down dynamic field that contains criticality levels from *1 very low* to *5 very high*.

``ITSMImpact``
   This is a drop-down dynamic field that contains impact levels from *1 very low* to *5 very high*.

``ITSMReviewRequired``
   This is a drop-down dynamic field that contains *Yes* and *No* to indicate if a review is required.

``ITSMDecisionResult``
   This is a drop-down dynamic field that contains some possible results for decisions.

``ITSMRepairStartTime``
   This is a date/time dynamic field for holding the repair start time.

``ITSMRecoveryStartTime``
   This is a date/time dynamic field for holding the recovery start time.

``ITSMDecisionDate``
   This is a date/time dynamic field for holding the decision time.

``ITSMDueDate``
   This is a date/time dynamic field for holding the due date.

The new dynamic fields are activated in many screens by default.

To see the complete list of screens:

1. Go to the system configuration.
2. Filter the settings for ``ITSMIncidentProblemManagement`` group.
3. Navigate to ``Frontend`` → ``Agent`` → ``View`` or ``Frontend`` → ``External`` → ``View`` to see the screens.
