# SPDX-License-Identifier: MIT
#
# Project-wide PSScriptAnalyzer configuration.
#
# Excluded rules are not silenced because they are wrong, they are
# either cosmetic or they clash with patterns we deliberately use.
# Each exclusion has a justification.

@{
    Severity = @('Error', 'Warning')

    ExcludeRules = @(
        # Check-Step / Check-InRepo / Check-GitInstalled use the unapproved
        # "Check" verb. Renaming would touch all 20 quest verifier.ps1 files
        # and belongs in its own dedicated rename commit, not a lint sweep.
        'PSUseApprovedVerbs',

        # _Load-ThemeMessages uses a plural noun in a private helper. Same
        # reasoning as above: deferred to a coordinated rename.
        'PSUseSingularNouns',

        # Verifiers are CLI tools that print themed output directly to the
        # user. Write-Host is the correct primitive here, not a pipeline leak.
        'PSAvoidUsingWriteHost',

        # UTF-8 without BOM is the modern convention. PSSA still asks for a
        # BOM on any non-ASCII file, which we consciously reject.
        'PSUseBOMForUnicodeEncodedFile',

        # Verifier steps routinely do `$result = & git ...` to swallow
        # stdout while reading `$LASTEXITCODE`. The variable is assigned
        # but intentionally unread. Rewriting to `| Out-Null` on 20 files
        # would be churn for zero behavioral change.
        'PSUseDeclaredVarsMoreThanAssignments',

        # Verifiers are read-only inspectors. The score state they mutate
        # is internal to the library, not user-visible file system state,
        # so -WhatIf / -Confirm would be misleading.
        'PSUseShouldProcessForStateChangingFunctions'
    )
}
