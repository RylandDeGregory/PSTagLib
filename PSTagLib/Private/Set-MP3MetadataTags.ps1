function Set-MP3MetadataTags {
<#
    .SYNOPSIS
       Add MP3 metadata tags to files based on file naming convention 'Artist${delimiter}Title (Mix)'. Optionally set MP3 genre tag.
#>
    param (
        # Filesystem path to the directory containing MP3 files for processing
        [Parameter(Mandatory = $true)]
        [string] $Directory,
        [Parameter]
        # Whether or not the genre tag will be set by the script. If provided without Genre parameter, sets the genre to the name of the directory.
        [switch] $ProcessGenre,
        # The value that will be set for the genre tag (overrides directory name)
        [Parameter]
        [string] $Genre
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