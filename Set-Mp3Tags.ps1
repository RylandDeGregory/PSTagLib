<#
    .SYNOPSIS
        Automatically set MP3 metadata tags based on filename
    .DESCRIPTION
        Set MP3 metadata tags for Artist, Title, and Genre based on file name using the TagLibSharp library
    .EXAMPLE
        .\Set-Mp3Tags.ps1 -Directory 'C:\Users\user1\Music\Techno'
    .EXAMPLE
        .\Set-Mp3Tags.ps1 -Directory 'C:\Users\user1\Music\Techno' -ProcessGenre
    .EXAMPLE
        ./Set-Mp3Tags.ps1 -Directory '/Users/user1/music/anjunabeats/' -ProcessGenre -Genre 'Trance'
#>
[CmdletBinding()]
param (
    [Parameter(ValueFromPipeline = $true)]
    [string] $Directory, # Filesystem path to the directory containing MP3 files for processing
    [Parameter(ValueFromPipeline = $true)]
    [switch] $ProcessGenre, # Whether or not the genre tag will be set by the script. If provided without Genre parameter, sets the genre to the name of the directory.
    [Parameter(ValueFromPipeline = $true)]
    [string] $Genre # The value that will be set for the genre tag (overrides directory name)
)

# Import the TagLibSharp library
if ($(Test-Path -Path $PSScriptRoot\taglib-sharp.dll)) {
    try {
        Add-Type -Path $PSScriptRoot\taglib-sharp.dll
    } catch {
        throw "Error importing TagLibSharp library: $($Error[0])"
    }
} else {
    throw 'Error importing TagLibSharp library. Ensure that taglib-sharp.dll is in the same directory as this script.'
}

# Set delimiter character(s)
# default: ' - ' (space hyphen space)
$delimiter = ' - '

function Set-Dir {
<#
    .SYNOPSIS
        Automatically process all files in a directory based on filename
#>
    param (
        [Parameter(ValueFromPipeline = $true)]
        [string] $Directory, # Filesystem path to the directory containing MP3 files for processing
        [Parameter(ValueFromPipeline = $true)]
        [switch] $ProcessGenre, # Whether or not the genre tag will be set by the script. If provided without Genre parameter, sets the genre to the name of the directory.
        [Parameter(ValueFromPipeline = $true)]
        [string] $Genre # The value that will be set for the genre tag (overrides directory name)
    )

    begin {
        Write-Output '----------'

        if ($ProcessGenre -and $Genre) {
            Write-Output "Genre for this directory is [$Genre]."
        } elseif ($ProcessGenre -and !$Genre) {
            Write-Output 'Genre was not specified, using directory name.'
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
                $file.FullName

                # Check if filename is properly formatted
                if ($items.Count -eq 2) {
                    $artist = $items[0].Trim()
                    $title  = $items[1].Trim()
                } else {
                    Write-Host -ForegroundColor Red '***Filename improperly formatted. This file will be skipped.***'
                    Write-Output '----------'
                    continue
                }

                # Invoke TagLibSharp library to set MP3 tags
                try {
                    $tag = [TagLib.File]::Create($file.FullName)

                    Write-Output "Artist: $artist"
                    $tag.Tag.AlbumArtists = $artist
                    $tag.Tag.Performers   = $artist

                    Write-Output "Title: $title"
                    $tag.Tag.Title = $title

                    if ($ProcessGenre) {
                        if (!$Genre) {
                            # If a genre wasn't defined by the user, use the name of the directory
                            $fileGenre = $file.DirectoryName | Split-Path -Leaf
                            Write-Output "Genre: $fileGenre"
                            $tag.Tag.Genres = $fileGenre
                        } else {
                            Write-Output "Genre: $Genre"
                            $tag.Tag.Genres = $Genre
                        }
                    }

                    # Commit the metadata changes to the file
                    $tag.Save()
                } catch {
                    Write-Host -ForegroundColor DarkYellow "Error setting MP3 tags for file [$($file.FullName)]"
                    continue
                }
                Write-Output '----------'
            }
        }
    }

    end {
        Write-Verbose 'Completed'
    }
}

Function Get-Dir {
<#
    .SYNOPSIS
        Determine if a provided filesystem directory is valid. Optionally allow users to launch a graphical filesystem browser to select a directory.
#>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $false)]
        [switch] $Gui # ONLY WORKS ON WINDOWS OS. Whether or not to use a Windows form graphical interface to browse for a directory.
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
            throw "Error checking filesystem path supplied $($Error[0])"
        }
    }
    end {
        if ($validDir) {
            return $directory
        } else {
            Write-Host -ForegroundColor Red 'Invalid folder path. Please validate and try again.'
            return $false
        }
    }
}

# If a directory or genre wasn't specified during execution, prompt user to supply one.
if (!$Directory) {
    if ($PSVersionTable.PSVersion.Major -lt 6) {
        $gui = Read-Host -Prompt 'Would you like to select a folder using the browse window? Enter Y or N'
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
    $userProcessGenre = Read-Host 'Would you like to set the genre based on folder name? Enter Y or N'
}

if (!$ProcessGenre -and !$Genre -and ($userProcessGenre -match '^[nN]')) {
    $userGenre = Read-Host 'Would you like to set the genre manually? Enter Y or N'
}

try {
    # Invoke function based on Genre switch
    if ($ProcessGenre -and $Genre) {
        Set-Dir -Directory -ProcessGenre -Genre $Genre
    } elseif ($userProcessGenre -match '^[yY]') {
        Set-Dir -Directory $directory -ProcessGenre
    } elseif (($userProcessGenre -match '^[nN]') -and ($userGenre -match '^[nN]')) {
        Set-Dir -Directory $directory
    } elseif (($userProcessGenre -match '^[nN]') -and ($userGenre -match '^[yY]')) {
        $genrePref = Read-Host 'What genre would you like to set for the songs (must be the same for all files in directory)?'
        Set-Dir -Directory $directory -ProcessGenre -Genre $genrePref
    } else {
        Write-Host -ForegroundColor Yellow 'Invalid entry. Using default: Genres will not be added.'
        Set-Dir -Directory $directory
    }
    # Inform user of completion
    Write-Host -ForegroundColor Green "Complete."
} catch {
    Write-Host -ForegroundColor Red "Failed. Please review errors: $($Error[0])"
}
# Wait for user input to terminate
Read-Host -Prompt 'Press [Enter] to exit'
