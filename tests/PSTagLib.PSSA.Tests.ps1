Import-Module PSScriptAnalyzer -ErrorAction Stop

$moduleRoot = Join-Path $PSScriptRoot '../PSTagLib'
$sourceFiles = @(
    Get-ChildItem -Path $moduleRoot -Recurse -File -Include '*.ps1', '*.psm1' |
        Where-Object { $_.Name -notlike '*.Tests.ps1' -and $_.Name -notlike '*.PSSATests.ps1' }
)
$analyzerRules = @(
    Get-ScriptAnalyzerRule |
        Where-Object { $_.RuleName -ne 'PSUseShouldProcessForStateChangingFunctions' } |
        Select-Object -ExpandProperty RuleName
)

Describe 'PSTagLib PSScriptAnalyzer' {
    foreach ($sourceFile in $sourceFiles) {
        foreach ($ruleName in $analyzerRules) {
            It "passes '$ruleName' for '$($sourceFile.Name)'" -TestCases @(@{ SourcePath = $sourceFile.FullName; RuleName = $ruleName }) {
                param ($SourcePath, $RuleName)

                $diagnostics = @(Invoke-ScriptAnalyzer -Path $SourcePath -IncludeRule $RuleName)
                Should-Be -Actual $diagnostics.Count -Expected 0
            }
        }
    }
}