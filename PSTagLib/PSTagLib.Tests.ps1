$here = Split-Path -Parent $MyInvocation.MyCommand.Path

#region Reloading SUT
# Ensuring that we are testing this version of module and not any other version that could be in memory
$ModulePath = "$($MyInvocation.MyCommand.Path -replace '.Tests.ps1$', '').psm1"
$ModuleName = (($ModulePath | Split-Path -Leaf) -replace '.psm1')
@(Get-Module -Name $ModuleName).where({ $_.version -ne '0.0' }) | Remove-Module # Removing all module versions from the current context if there are any
Import-Module -Name $ModulePath -Force -ErrorAction Stop # Loading module explicitly by path and not via the manifest
#endregion

Describe "'$ModuleName' Module Tests" {

    Context 'Module Setup' {
        It 'should have a root module' {
            Test-Path $ModulePath | Should -Be $true
        }

        It 'should have an associated manifest' {
            Test-Path "$here\$ModuleName.psd1" | Should -Be $true
        }

        It 'should have public functions' {
            Test-Path "$here\public\*.ps1" | Should -Be $true
        }

        It 'should be a valid PowerShell code' {
            $PSFile = Get-Content -Path $ModulePath -ErrorAction Stop
            $errors = $null
            $null = [System.Management.Automation.PSParser]::Tokenize($PSFile, [ref]$errors)
            $errors.Count | Should -Be 0
        }
    }

    Context 'Module Control' {
        It 'should import without errors' {
            { Import-Module -Name $ModulePath -Force -ErrorAction Stop } | Should -Not -Throw
            Get-Module -Name $ModuleName | Should -Not -BeNullOrEmpty
        }

        It 'should remove without errors' {
            { Remove-Module -Name $ModuleName -ErrorAction Stop } | Should -Not -Throw
            Get-Module -Name $ModuleName | Should -BeNullOrEmpty
        }
    }
}

# Dynamically defining the functions to test
$FunctionPaths = @()
if (Test-Path -Path "$here\private\*.ps1") {
    $FunctionPaths += Get-ChildItem -Path "$here\private\*.ps1" -Exclude '*.Tests.*'
}
if (Test-Path -Path "$here\public\*.ps1") {
    $FunctionPaths += Get-ChildItem -Path "$here\public\*.ps1" -Exclude '*.Tests.*'
}


# Running the tests for each function
foreach ($FunctionPath in $FunctionPaths) {

    $FunctionName = $FunctionPath.BaseName

    Describe "'$FunctionName' Function Tests" {
        Context 'Function Code Style Tests' {
            It 'should be an advanced function' {
                $FunctionPath | Should -FileContentMatch 'Function'
                $FunctionPath | Should -FileContentMatch 'CmdletBinding'
                $FunctionPath | Should -FileContentMatch 'Param'
            }

            It 'should contain Write-Verbose blocks' {
                $FunctionPath | Should -FileContentMatch 'Write-Verbose'
            }

            It 'should be a valid PowerShell code' {
                $PSFile = Get-Content -Path $FunctionPath -ErrorAction Stop
                $errors = $null
                $null = [System.Management.Automation.PSParser]::Tokenize($PSFile, [ref]$errors)
                $errors.Count | Should -Be 0
            }

            # It 'should have tests' {
            #     Test-Path ($FunctionPath -replace '.ps1', '.Tests.ps1') | Should -Be $true
            #     ($FunctionPath -replace '.ps1', '.Tests.ps1') | Should -FileContentMatch "Describe `"'$FunctionName'"
            # }
        }

        Context 'Function Help Quality Tests' {
            # Getting function help
            $AbstractSyntaxTree = [System.Management.Automation.Language.Parser]::
            ParseInput((Get-Content -Raw $FunctionPath), [ref]$null, [ref]$null)
            $AstSearchDelegate = { $args[0] -is [System.Management.Automation.Language.FunctionDefinitionAst] }
            $ParsedFunction = $AbstractSyntaxTree.FindAll( $AstSearchDelegate, $true ) | Where-Object Name -EQ $FunctionName
            $FunctionHelp = $ParsedFunction.GetHelpContent()

            It 'should have a SYNOPSIS' {
                $FunctionHelp.Synopsis | Should -Not -BeNullOrEmpty
            }

            It 'should have a DESCRIPTION with length > 40 symbols' {
                $FunctionHelp.Description.Length | Should -BeGreaterThan 40
            }

            It 'should have at least one EXAMPLE' {
                $FunctionHelp.Examples.Count | Should -BeGreaterThan 0
                $FunctionHelp.Examples[0] | Should -Match ([regex]::Escape($FunctionName))
                $FunctionHelp.Examples[0].Length | Should -BeGreaterThan ($FunctionName.Length + 10)
            }
        }
    }
}