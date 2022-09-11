$here = Split-Path -Parent $MyInvocation.MyCommand.Path

$modulePath = $here
$moduleName = Split-Path -Path $modulePath -Leaf

Describe "'$moduleName' Module Analysis with PSScriptAnalyzer" {
    Context 'Standard Rules' {
        # Define PSScriptAnalyzer rules
        $scriptAnalyzerRules = Get-ScriptAnalyzerRule

        # Perform analysis against each rule
        forEach ($rule in $scriptAnalyzerRules) {
            It "should pass '$rule' rule" {
                Invoke-ScriptAnalyzer -Path "$here\$moduleName.psm1" -IncludeRule $rule | Should -BeNullOrEmpty
            }
        }
    }
}

# Dynamically defining the functions to analyze
$FunctionPaths = @()
if (Test-Path -Path "$modulePath\private\*.ps1") {
    $FunctionPaths += Get-ChildItem -Path "$modulePath\private\*.ps1" -Exclude "*.Tests.*"
}
if (Test-Path -Path "$modulePath\public\*.ps1") {
    $FunctionPaths += Get-ChildItem -Path "$modulePath\public\*.ps1" -Exclude "*.Tests.*"
}

# Running the analysis for each function
foreach ($FunctionPath in $FunctionPaths) {
    $FunctionName = $FunctionPath.BaseName

    Describe "'$FunctionName' Function Analysis with PSScriptAnalyzer" {
        Context 'Standard Rules' {
            # Define PSScriptAnalyzer rules
            $ScriptAnalyzerRules = Get-ScriptAnalyzerRule # Just getting all default rules

            # Perform analysis against each rule
            forEach ($Rule in $ScriptAnalyzerRules) {
                It "should pass '$rule' rule" {
                    Invoke-ScriptAnalyzer -Path $FunctionPath -IncludeRule $Rule | Should -BeNullOrEmpty
                }
            }
        }
    }
}