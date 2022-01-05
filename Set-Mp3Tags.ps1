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
    [Parameter()]
    [string] $Directory, # Filesystem path to the directory containing MP3 files for processing
    [Parameter()]
    [switch] $ProcessGenre, # Whether or not the genre tag will be set by the script. If provided without Genre parameter, sets the genre to the name of the directory.
    [Parameter()]
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
$Delimiter = ' - '
#endregion Init

#region Functions
function Get-MP3Directory {
    <#
        .SYNOPSIS
            Determine if a provided filesystem directory is valid. Optionally allow users to launch a graphical filesystem browser to select a directory.
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $false)]
        [switch] $Gui # Compatible with Windows PowerShell ONLY. Whether or not to use a Windows forms graphical interface to browse for a directory.
    )

    begin {
        if ($Gui) {
            Write-Host -ForegroundColor Blue "What is the path to the folder you want to process?"
            Start-Sleep -Milliseconds 500
            [System.Reflection.Assembly]::LoadWithPartialName("System.windows.forms") | Out-Null
            $OpenFileDialog = New-Object System.Windows.Forms.FolderBrowserDialog
            $OpenFileDialog.RootFolder = 'MyComputer'
            $OpenFileDialog.ShowDialog() | Out-Null

            # Save selected filesystem path to variable
            $Directory = $OpenFileDialog.SelectedPath
        } else {
            $Directory = Read-Host "What is the path to the folder you want to process?"
            Write-Host "You entered: '$Directory'"
        }
    }

    process {
        # Ensure that the filesystem path supplied is valid
        try {
            $ValidDirectory = Test-Path -Path "$Directory"
        } catch {
            throw "Error checking filesystem path supplied $($Error[0])"
        }
    }

    end {
        if ($ValidDirectory) {
            return $Directory
        } else {
            Write-Host -ForegroundColor Red 'Invalid folder path. Please validate and try again.'
            return $false
        }
    }
} #endfunction Get-MP3Directory
function Set-MP3MetadataTags {
<#
    .SYNOPSIS
       Add MP3 metadata tags to files based on file naming convention 'Artist${delimiter}Title (Mix)'. Optionally set MP3 genre tag.
#>
    param (
        [Parameter(Mandatory = $true)]
        [string] $Directory, # Filesystem path to the directory containing MP3 files for processing
        [Parameter()]
        [switch] $ProcessGenre, # Whether or not the genre tag will be set by the script. If provided without Genre parameter, sets the genre to the name of the directory.
        [Parameter()]
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
        $Files = Get-ChildItem $Directory
        foreach ($File in $Files) {
            if ($File.Extension -eq ".mp3") {
                # Split on pre-defined delimiter
                $Items = $File.BaseName -Split $Delimiter
                $File.FullName

                # Check if filename is properly formatted
                if ($Items.Count -eq 2) {
                    $Artist = $Items[0].Trim()
                    $Title  = $Items[1].Trim()
                } else {
                    Write-Host -ForegroundColor Red '***Filename improperly formatted. This file will be skipped.***'
                    Write-Output '----------'
                    continue
                }

                try {
                    # Invoke TagLibSharp library to set MP3 metadata tags
                    $Tag = [TagLib.File]::Create($File.FullName)

                    Write-Output "Artist: $Artist"
                    $Tag.Tag.AlbumArtists = $Artist
                    $Tag.Tag.Performers   = $Artist

                    Write-Output "Title: $Title"
                    $Tag.Tag.Title = $Title

                    if ($ProcessGenre) {
                        if (!$Genre) {
                            # If a genre wasn't defined by the user, use the name of the directory
                            $FileGenre = $File.DirectoryName | Split-Path -Leaf
                            Write-Output "Genre: $FileGenre"
                            $Tag.Tag.Genres = $FileGenre
                        } else {
                            Write-Output "Genre: $Genre"
                            $Tag.Tag.Genres = $Genre
                        }
                    }

                    # Commit the MP3 metadata tag changes to the file
                    $Tag.Save()
                } catch {
                    Write-Host -ForegroundColor DarkYellow "Error setting MP3 tags for file [$($File.FullName)]"
                    continue
                }
                Write-Output '----------'
            }
        }
    }

    end {
        Write-Verbose 'Completed'
    }
} #endfunction Set-MP3MetadataTags
#endregion Functions

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
}

if ($Directory -and !$ProcessGenre) {
    $UserProcessGenre = Read-Host 'Would you like to set the genre based on folder name? Enter Y or N'
}

if ($Directory -and !$ProcessGenre -and !$Genre -and ($UserProcessGenre -match '^[nN]')) {
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
