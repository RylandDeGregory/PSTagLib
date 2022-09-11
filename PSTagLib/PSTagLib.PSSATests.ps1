$here = Split-Path -Parent $MyInvocation.MyCommand.Path

$ModulePath = $here
$ModuleName = Split-Path -Path $ModulePath -Leaf

Describe "'$ModuleName' Module Analysis with PSScriptAnalyzer" {
    Context 'Standard Rules' {
        # Define PSScriptAnalyzer rules
        $ScriptAnalyzerRules = Get-ScriptAnalyzerRule | Where-Object { $_.RuleName -ne 'PSUseShouldProcessForStateChangingFunctions' }

        # Perform analysis against each rule
        foreach ($Rule in $ScriptAnalyzerRules) {
            It "should pass '$Rule' rule" {
                Invoke-ScriptAnalyzer -Path "$here\$ModuleName.psm1" -IncludeRule $Rule | Should -BeNullOrEmpty
            }
        }
    }
}

# Dynamically defining the functions to analyze
$FunctionPaths = @()
if (Test-Path -Path "$ModulePath\private\*.ps1") {
    $FunctionPaths += Get-ChildItem -Path "$ModulePath\private\*.ps1" -Exclude "*.Tests.*"
}
if (Test-Path -Path "$ModulePath\public\*.ps1") {
    $FunctionPaths += Get-ChildItem -Path "$ModulePath\public\*.ps1" -Exclude "*.Tests.*"
}

# Running the analysis for each function
foreach ($FunctionPath in $FunctionPaths) {
    $FunctionName = $FunctionPath.BaseName

    Describe "'$FunctionName' Function Analysis with PSScriptAnalyzer" {
        Context 'Standard Rules' {
            # Define PSScriptAnalyzer rules
            $ScriptAnalyzerRules = Get-ScriptAnalyzerRule | Where-Object { $_.RuleName -ne 'PSUseShouldProcessForStateChangingFunctions' }

            # Perform analysis against each rule
            foreach ($Rule in $ScriptAnalyzerRules) {
                It "should pass '$Rule' rule" {
                    Invoke-ScriptAnalyzer -Path $FunctionPath -IncludeRule $Rule | Should -BeNullOrEmpty
                }
            }
        }
    }
}