<#
    .SYNOPSIS
        Automatically set MP3 tags based on filename
    .DESCRIPTION
        Set MP3 tags for Artist, Title, and Genre based on filename using TagLibSharp library
    .PARAMETER Directory
        [string] Filesystem path to the folder being processed
    .PARAMETER Genre
        [switch] Whether or not the Genre tag will be set
    .INPUTS
        None
    .OUTPUTS
        None
    .EXAMPLE
        .\Set-Mp3Tags.ps1 -Directory "C:\Users\user1\Music\Techno"
    .EXAMPLE
        .\Set-Mp3Tags.ps1 -Directory "C:\Users\user1\Music\Techno" -Genre
    .NOTES
        Date        Ver     Author  Notes
        ------------------------------------------------------------------------------------------------------
        28DEC19     1.0     RD      - Initial script release
        29DEC19     1.1     RD      - Removed reliance on module, load assembly inline
#>
[CmdletBinding()]
param (
    [Parameter(ValueFromPipeline = $true)]
    [string]
    $Directory,
    [Parameter(ValueFromPipeline = $true)]
    [switch]
    $Genre
)

# Import the TagLibSharp library
try {
    Add-Type -Path $PSScriptRoot\taglib-sharp.dll
} catch {
    Write-Error "Error accessing TagLibSharp library. Ensure that taglib-sharp.dll is in the same folder as this script."
}

# Set delimiter character(s)
# default: ' - ' (space hyphen space)
$delimiter = ' - '

function Set-Dir {
# Automatically process all files in a folder based on filename
    [CmdletBinding()]
    param (
        [Parameter()]
        [string]
        $Directory,
        [Parameter()]
        [switch]
        $Genre
    )

    Write-Output "----------"

    # Process all .mp3 files in the directory
    foreach ($file in $folder) {
        if ($file.Extension -eq ".mp3") {
            # Split on pre-defined delimiter
            $items = $file.BaseName -Split $delimiter
            Write-Output "$($file.FullName)"

            # Check if filename is properly formatted
            if ($items.Count -eq 2) {
                $artist = $items[0].Trim()
                $title = $items[1].Trim()
            } else {
                Write-Host -ForegroundColor Red "***Filename improperly formatted. This file will be skipped.***"
                Write-Output "----------"
                continue
            }

            # Invoke TagLibSharp library to set MP3 tags
            try {
                $tag = [TagLib.File]::Create($file.FullName)

                Write-Output "Artist: $artist"
                $tag.Tag.AlbumArtists = $artist
                $tag.Tag.Performers = $artist

                Write-Output "Title: $title"
                $tag.Tag.Title = $title

                if ($Genre) {
                    $fileGenre = $file.DirectoryName | Split-Path -Leaf
                    Write-Output "Genre: $fileGenre"
                    $tag.Tag.Genres = $fileGenre
                }

                $tag.Save()
            } catch {
                Write-Error "Error setting MP3 tags."
            }

            Write-Output "----------"
        }
    }
}

Function Get-Dir {
    [CmdletBinding()]
    param (
        [Parameter()]
        [switch]
        $Gui
    )
    if ($Gui) {
        Write-Host "What is the path to the folder you want to process?"
        Start-Sleep -Milliseconds 500
        [System.Reflection.Assembly]::LoadWithPartialName("System.windows.forms") | Out-Null
        $OpenFileDialog = New-Object System.Windows.Forms.FolderBrowserDialog
        $OpenFileDialog.RootFolder = 'MyComputer'
        $OpenFileDialog.ShowDialog() | Out-Null

        $directory = $OpenFileDialog.SelectedPath
    } else {
        $directory = Read-Host "What is the path to the folder you want to process?"
    }

    # Ensure that the filesystem path supplied is valid
    try {
        $validDir = Test-Path -Path "$directory"
    } catch {}

    if ($validDir) {
        return $directory
    } else {
        Write-Host -ForegroundColor Red "Invalid folder path. Try again."
        return $false
    }
}

# If a directory or genre wasn't specified during execution, prompt user to supply one.
if (!$Directory) {
    if ($PSVersionTable.PSVersion.Major -lt 6) {
        $gui = Read-Host -Prompt "Would you like to select a folder using the browse window? Enter 'Y' or 'N'"
        if ($gui -match '^[yY]') {
            $directory = Get-Dir -Gui
        } else {
            $directory = Get-Dir
        }
        while ($directory -eq $false) {
            if ($gui -match '^[yY]') {
                $directory = Get-Dir -Gui
            } else {
                $directory = Get-Dir
            }
        }
    } else {
        $directory = Get-Dir
        while ($directory -eq $false) {
            $directory = Get-Dir
        }
    }

    $folder = Get-ChildItem -Path $Directory
}

if (!$Genre) {
    $userGenre = Read-Host "Would you like to set the genre based on folder name? Enter 'Y' or 'N'"
}

try {
    # Invoke function based on Genre switch
    if ($Genre -or $userGenre -match '^[yY]') {
        Set-Dir -Directory $directory -Genre
    } elseif ($userGenre -match '^[nN]') {
        Set-Dir -Directory $directory
    } else {
        Write-Host -ForegroundColor Yellow "Invalid entry. Using default: Genres will not be added."
        Set-Dir -Directory $directory
    }
    # Inform user of completion
    Write-Host -ForegroundColor Green "Complete."
} catch {
    Write-Host -ForegroundColor Red "Failed. Please review errors."
}
# Wait for user input to terminate
Read-Host -Prompt "Press Enter to exit"