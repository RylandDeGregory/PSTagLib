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
        .\Set-Mp3Tags.ps1 -Directory "C:\Users\user1\Music\Techno" -ProcessGenre
    .EXAMPLE
        ./Set-Mp3Tags.ps1 -Directory "/home/users/user1/music/anjunabeats/" -ProcessGenre -Genre "Trance"
#>
[CmdletBinding()]
param (
    [Parameter(ValueFromPipeline = $true)]
    [string]
    $Directory,
    [Parameter(ValueFromPipeline = $true)]
    [switch]
    $ProcessGenre,
    [Parameter(ValueFromPipeline = $true)]
    [string]
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
        [Parameter(Mandatory=$true)]
        [string]
        $Directory,
        [Parameter(Mandatory=$false)]
        [switch]
        $ProcessGenre,
        [Parameter(Mandatory=$false)]
        [string]
        $Genre
    )

    begin {
        Write-Output "----------"

        if ($ProcessGenre -and $Genre) {
            Write-Output "Genre for this directory is [$Genre]."
        } elseif ($ProcessGenre -and !$Genre) {
            Write-Output "Genre was not specified, using directory name."
        }

        Write-Output "Processing $Directory with Genre $Genre"
    }
    process {
        # Process all .mp3 files in the directory
        $files = Get-ChildItem $Directory
        foreach ($file in $files) {
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

                    if ($ProcesGenre) {
                        if (!$Genre) {
                            # If a genre wasn't defined by the user, use the name of the folder
                            $fileGenre = $file.DirectoryName | Split-Path -Leaf
                            Write-Output "Genre: $fileGenre"
                            $tag.Tag.Genres = $fileGenre
                        } else {
                            Write-Output "Genre: $Genre"
                            $tag.Tag.Genres = $Genre
                        }
                    }

                    # Commit the changes to the file
                    $tag.Save()
                } catch {
                    Write-Host -ForegroundColor DarkYellow "Error setting MP3 tags for file [$($file.FullName)]"
                    continue
                }
                Write-Output "----------"
            }
        }
    }
    end {
        return
    }
}

Function Get-Dir {
    [CmdletBinding()]
    param (
        [Parameter()]
        [switch]
        $Gui
    )

    begin {
        if ($Gui) {
            Write-Host -ForegroundColor Blue "What is the path to the folder you want to process?"
            Start-Sleep -Milliseconds 500
            [System.Reflection.Assembly]::LoadWithPartialName("System.windows.forms") | Out-Null
            $OpenFileDialog = New-Object System.Windows.Forms.FolderBrowserDialog
            $OpenFileDialog.RootFolder = 'MyComputer'
            $OpenFileDialog.ShowDialog() | Out-Null

            $directory = $OpenFileDialog.SelectedPath
        } else {
            $directory = Read-Host "What is the path to the folder you want to process?"
        }
    }
    process {
        # Ensure that the filesystem path supplied is valid
        try {
            $validDir = Test-Path -Path "$directory"
        } catch {
            Write-Error $Error
        }
    }
    end {
        if ($validDir) {
            return $directory
        } else {
            Write-Host -ForegroundColor Red "Invalid folder path. Try again."
            return $false
        }
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

    $directory = Get-ChildItem -Path $Directory
}

if (!$ProcessGenre) {
    $userProcessGenre = Read-Host "Would you like to set the genre based on folder name? Enter 'Y' or 'N'"
}

if (!$ProcessGenre -and !$Genre -and $userProcessGenre -match '^[nN]') {
    $userGenre = Read-Host "Would you like to set the genre manually? Enter 'Y' or 'N'"
}

try {
    # Invoke function based on Genre switch
    if ($ProcessGenre -and $Genre) {
        Set-Dir -Directory -ProcessGenre -Genre $Genre
    } elseif ($userProcessGenre -match '^[yY]') {
        Set-Dir -Directory $directory -ProcessGenre
    } elseif ($userProcessGenre -match '^[nN]' -and $userGenre -match '^[nN]') {
        Set-Dir -Directory $directory
    } elseif ($userProcessGenre -match '^[nN]' -and $userGenre -match '^[yY]') {
        $genrePref = Read-Host "What genre would you like to set for the songs (must be the same for all files in directory)?"
        Set-Dir -Directory $directory -ProcessGenre -Genre $genrePref
    } else {
        Write-Host -ForegroundColor Yellow "Invalid entry. Using default: Genres will not be added."
        Set-Dir -Directory $directory
    }
    # Inform user of completion
    Write-Host -ForegroundColor Green "Complete."
} catch {
    Write-Host -ForegroundColor Red "Failed. Please review errors. $($error[0])"
}
# Wait for user input to terminate
Read-Host -Prompt "Press [Enter] to exit"