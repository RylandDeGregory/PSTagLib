<#
    .SYNOPSIS
        Automatically set MP3 metadata tags based on filename
    .DESCRIPTION
        Set MP3 metadata tags for Artist, Title, and Genre based on file name using the TagLibSharp library
    .EXAMPLE
        .\Set-Mp3Tags.ps1 -Directory 'C:\Users\user1\Music\Techno'
    .EXAMPLE
        .\Set-Mp3Tags.ps1 -Directory 'C:\Users\user1\Music\Trance' -ProcessGenre
    .EXAMPLE
        ./Set-Mp3Tags.ps1 -Directory '/Users/user1/music/anjunabeats/' -ProcessGenre -Genre 'Trance'
#>
#region Init
[CmdletBinding()]
param (
    # Filesystem path to the directory containing MP3 files for processing
    [Parameter(Mandatory = $true)]
    [string] $Directory,
    # Whether or not the genre tag will be set by the script. If provided without Genre parameter, sets the genre to the name of the directory.
    [Parameter(Mandatory = $false)]
    [switch] $ProcessGenre,
    # The value that will be set for the genre tag (overrides directory name)
    [Parameter(Mandatory = $false)]
    [string] $Genre
)

# Set delimiter character(s)
# default: ' - ' (space hyphen space)
$Delimiter = ' - '
#endregion Init

#region GetInteractiveParameters
if (!$Directory) {
    # If a directory or genre wasn't specified during execution, prompt user to supply one.
    if ($PSVersionTable.PSVersion.Major -lt 6) {
        $Gui = Read-Host -Prompt 'Would you like to select a folder using the browse window? Enter Y or N'
        if ($Gui -match '^[yY]') {
            $Directory = Get-MP3Directory -Gui
        } else {
            $Directory = Get-MP3Directory
        }

        while ($Directory -eq $false) {
            if ($Gui -match '^[yY]') {
                $Directory = Get-MP3Directory -Gui
            } else {
                $Directory = Get-MP3Directory
            }
        }
    } else {
        $Directory = Get-MP3Directory
        while ($Directory -eq $false) {
            $Directory = Get-MP3Directory
        }
    }

    $Directory = Get-ChildItem -Path $Directory
}

if (!$ProcessGenre) {
    $UserProcessGenre = Read-Host 'Would you like to set the genre based on folder name? Enter Y or N'
}

if (!$ProcessGenre -and !$Genre -and ($UserProcessGenre -match '^[nN]')) {
    $UserGenre = Read-Host 'Would you like to set the genre manually? Enter Y or N'
}
#endregion GetInteractiveParameters

# region ProcessFiles
try {
    # Invoke function based on Genre switch
    if ($ProcessGenre -and $Genre) {
        Set-MP3MetadataTags -Directory -ProcessGenre -Genre $Genre
    } elseif ($UserProcessGenre -match '^[yY]') {
        Set-MP3MetadataTags -Directory $Directory -ProcessGenre
    } elseif (($UserProcessGenre -match '^[nN]') -and ($UserGenre -match '^[nN]')) {
        Set-MP3MetadataTags -Directory $Directory
    } elseif (($UserProcessGenre -match '^[nN]') -and ($UserGenre -match '^[yY]')) {
        $genrePref = Read-Host 'What genre would you like to set for the songs (must be the same for all files in directory)?'
        Set-MP3MetadataTags -Directory $Directory -ProcessGenre -Genre $genrePref
    } else {
        Write-Host -ForegroundColor Yellow 'Invalid entry. Using default: Genre tag will NOT be added.'
        Set-MP3MetadataTags -Directory $Directory
    }

    # Inform user of script completion
    Write-Host -ForegroundColor Green 'Complete.'
} catch {
    throw "Process failed. Please review errors: $Error"
}
# Wait for user input to terminate script
Read-Host -Prompt 'Press [Enter] to exit'
#endregion ProcessFiles
