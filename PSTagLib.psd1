#
# Module manifest for module 'PSTagLib'
#
# Generated by: Ryland DeGregory
#
# Generated on: 9/4/2022
#

@{

# Script module or binary module file associated with this manifest.
RootModule = 'PSTagLib.psm1'

# Version number of this module.
ModuleVersion = '1.0.0'

# Supported PSEditions
CompatiblePSEditions = @('Desktop', 'Core')

# ID used to uniquely identify this module
GUID = '15356db1-e0b3-4f8e-a2d0-e265bcf39269'

# Author of this module
Author = 'Ryland DeGregory'

# Company or vendor of this module
CompanyName = 'ryland.dev'

# Copyright statement for this module
Copyright = '(c) Ryland DeGregory. All rights reserved.'

# Description of the functionality provided by this module
Description = 'Automate media file metadata with PowerShell using the TagLibSharp library for .NET'

# Minimum version of the PowerShell engine required by this module
PowerShellVersion = '5.1'

# Name of the PowerShell host required by this module
# PowerShellHostName = ''

# Minimum version of the PowerShell host required by this module
# PowerShellHostVersion = ''

# Minimum version of Microsoft .NET Framework required by this module. This prerequisite is valid for the PowerShell Desktop edition only.
# DotNetFrameworkVersion = ''

# Minimum version of the common language runtime (CLR) required by this module. This prerequisite is valid for the PowerShell Desktop edition only.
# ClrVersion = ''

# Processor architecture (None, X86, Amd64) required by this module
# ProcessorArchitecture = ''

# Modules that must be imported into the global environment prior to importing this module
# RequiredModules = @()

# Assemblies that must be loaded prior to importing this module
RequiredAssemblies = @('.\lib\TagLibSharp.dll')

# Script files (.ps1) that are run in the caller's environment prior to importing this module.
# ScriptsToProcess = @()

# Type files (.ps1xml) to be loaded when importing this module
# TypesToProcess = @()

# Format files (.ps1xml) to be loaded when importing this module
# FormatsToProcess = @()

# Modules to import as nested modules of the module specified in RootModule/ModuleToProcess
# NestedModules = @()

# Functions to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no functions to export.
FunctionsToExport = @('Get-Album',
                      'Get-Artist',
                      'Get-Genre',
                      'Get-Metadata',
                      'Get-Publisher',
                      'Get-Title',
                      'Set-Album',
                      'Set-Artist',
                      'Set-Genre',
                      'Set-Metadata',
                      'Set-Publisher',
                      'Set-Title')

# Cmdlets to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no cmdlets to export.
CmdletsToExport = @()

# Variables to export from this module
VariablesToExport = '*'

# Aliases to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no aliases to export.
AliasesToExport = @()

# DSC resources to export from this module
# DscResourcesToExport = @()

# List of all modules packaged with this module
# ModuleList = @()

# List of all files packaged with this module
FileList = @('.\lib\TagLibSharp.dll',
             '.\public\Get-Album.ps1',
             '.\public\Get-Artist.ps1',
             '.\public\Get-Genre.ps1',
             '.\public\Get-Metadata.ps1',
             '.\public\Get-Publisher.ps1'
             '.\public\Get-Title.ps1',
             '.\public\Set-Album.ps1',
             '.\public\Set-Artist.ps1',
             '.\public\Set-Genre.ps1',
             '.\public\Set-Metadata.ps1',
             '.\public\Set-Publisher.ps1'
             '.\public\Set-Title.ps1')

# Private data to pass to the module specified in RootModule/ModuleToProcess. This may also contain a PSData hashtable with additional module metadata used by PowerShell.
PrivateData = @{

    PSData = @{

        # Tags applied to this module. These help with module discovery in online galleries.
        Tags = @('TagLibSharp', 'MP3 Tags', 'Metadata')

        # A URL to the license for this module.
        LicenseUri = 'https://github.com/RylandDeGregory/PSTagLib/blob/master/LICENSE'

        # A URL to the main website for this project.
        ProjectUri = 'https://github.com/RylandDeGregory/PSTagLib'

        # A URL to an icon representing this module.
        # IconUri = ''

        # ReleaseNotes of this module
        # ReleaseNotes = ''

        # Prerelease string of this module
        # Prerelease = ''

        # Flag to indicate whether the module requires explicit user acceptance for install/update/save
        RequireLicenseAcceptance = $false

        # External dependent modules of this module
        # ExternalModuleDependencies = @()

    } # End of PSData hashtable

} # End of PrivateData hashtable

# HelpInfo URI of this module
HelpInfoURI = 'https://github.com/RylandDeGregory/PSTagLib/blob/master/README.md'

# Default prefix for commands exported from this module. Override the default prefix using Import-Module -Prefix.
# DefaultCommandPrefix = ''
}