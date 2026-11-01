$moduleRoot = Join-Path $PSScriptRoot '../PSTagLib'
$moduleName = 'PSTagLib'
$modulePath = Join-Path $moduleRoot "$moduleName.psm1"
$manifestPath = Join-Path $moduleRoot "$moduleName.psd1"
$functionFiles = @(Get-ChildItem -Path $moduleRoot -Recurse -File -Include '*.ps1' | Where-Object { $_.DirectoryName -match '[\\/]public$' })
$functionTestCases = foreach ($functionFile in $functionFiles) {
    $tokens = $null
    $parseErrors = $null
    $ast = [System.Management.Automation.Language.Parser]::ParseFile($functionFile.FullName, [ref]$tokens, [ref]$parseErrors)
    $functionAst = $ast.FindAll({ param ($node) $node -is [System.Management.Automation.Language.FunctionDefinitionAst] }, $true) |
        Where-Object Name -EQ $functionFile.BaseName |
        Select-Object -First 1

    @{
        FunctionName    = $functionFile.BaseName
        FunctionPath    = $functionFile.FullName
        FunctionContent = Get-Content -Path $functionFile.FullName -Raw -ErrorAction Stop
        ParseErrorCount = $parseErrors.Count
        FunctionHelp    = $functionAst.GetHelpContent()
    }
}
$moduleTestCases = @(@{ PublicFunctionCount = $functionFiles.Count })

Describe 'PSTagLib module' {
    BeforeAll {
        $script:modulePath = Join-Path $PSScriptRoot '../PSTagLib/PSTagLib.psm1'
        $script:manifestPath = Join-Path $PSScriptRoot '../PSTagLib/PSTagLib.psd1'
        $script:moduleName = 'PSTagLib'
        $script:module = Import-Module $script:manifestPath -Force -PassThru
    }

    It 'imports the module manifest' {
        Should-Be -Actual $script:module.Name -Expected 'PSTagLib'
    }

    It 'exports the functions declared in the manifest' {
        $manifestFunctions = (Test-ModuleManifest $script:manifestPath).ExportedFunctions.Keys | Sort-Object
        $moduleFunctions = $script:module.ExportedFunctions.Keys | Sort-Object

        Should-BeCollection -Actual $moduleFunctions -Expected $manifestFunctions
    }

    It 'has a root module file' {
        Should-Be -Actual (Test-Path $script:modulePath -PathType Leaf) -Expected $true
    }

    It 'has a module manifest file' {
        Should-Be -Actual (Test-Path $script:manifestPath -PathType Leaf) -Expected $true
    }

    It 'has public function files' -TestCases $moduleTestCases {
        param ($PublicFunctionCount)

        Should-Be -Actual ($PublicFunctionCount -gt 0) -Expected $true
    }

    It 'has valid PowerShell syntax' {
        $tokens = $null
        $parseErrors = $null
        $null = [System.Management.Automation.Language.Parser]::ParseFile($script:modulePath, [ref]$tokens, [ref]$parseErrors)
        Should-Be -Actual $parseErrors.Count -Expected 0
    }

    It 'imports without errors' {
        $imported = $false
        try {
            Import-Module $script:modulePath -Force -ErrorAction Stop
            $imported = [bool](Get-Module -Name $script:moduleName)
        } catch {
            $imported = $false
        }
        Should-Be -Actual $imported -Expected $true
    }

    It 'removes without errors' {
        $removed = $false
        try {
            Remove-Module -Name $script:moduleName -ErrorAction Stop
            $removed = -not [bool](Get-Module -Name $script:moduleName)
        } catch {
            $removed = $false
        }
        Should-Be -Actual $removed -Expected $true
    }
}

Describe 'PSTagLib function structure' {
    It "defines '<FunctionName>' as an advanced function" -TestCases $functionTestCases {
        param ($FunctionContent)

        Should-Be -Actual ([regex]::IsMatch($FunctionContent, '(?i)\bfunction\b')) -Expected $true
        Should-Be -Actual ([regex]::IsMatch($FunctionContent, '(?i)\[CmdletBinding')) -Expected $true
        Should-Be -Actual ([regex]::IsMatch($FunctionContent, '(?i)\bparam\s*\(')) -Expected $true
    }

    It "writes verbose messages in '<FunctionName>'" -TestCases $functionTestCases {
        param ($FunctionContent)

        Should-Be -Actual ([regex]::IsMatch($FunctionContent, '(?i)\bWrite-Verbose\b')) -Expected $true
    }

    It "has valid PowerShell syntax in '<FunctionName>'" -TestCases $functionTestCases {
        param ($ParseErrorCount)

        Should-Be -Actual $ParseErrorCount -Expected 0
    }

    It "documents a synopsis for '<FunctionName>'" -TestCases $functionTestCases {
        param ($FunctionHelp)

        Should-Be -Actual ([string]::IsNullOrWhiteSpace($FunctionHelp.Synopsis)) -Expected $false
    }

    It "documents a meaningful description for '<FunctionName>'" -TestCases $functionTestCases {
        param ($FunctionHelp)

        Should-Be -Actual ($FunctionHelp.Description.Length -gt 40) -Expected $true
    }

    It "documents an example for '<FunctionName>'" -TestCases $functionTestCases {
        param ($FunctionHelp, $FunctionName)

        Should-Be -Actual ($FunctionHelp.Examples.Count -gt 0) -Expected $true
        Should-Be -Actual ($FunctionHelp.Examples[0] -match [regex]::Escape($FunctionName)) -Expected $true
        Should-Be -Actual ($FunctionHelp.Examples[0].Length -gt ($FunctionName.Length + 10)) -Expected $true
    }
}