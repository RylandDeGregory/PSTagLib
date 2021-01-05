function Set-Artist {
    <#
        .SYNOPSIS
            Set Artist MP3 ID3 tags
        .DESCRIPTION
            Set AlbumArtists and Performers MP3 ID3 tags using TagLibSharp.
            Parameters can be supplied by name, by position, or using the pipeline. See examples.
        .INPUTS
            Fully-qualified filesystem path or array of paths.
        .OUTPUTS
            MP3 ID3 Artist tags are updated on MP3 file(s).
        .PARAMETER Artist
            Name of the artist to be set in the .mp3 file(s) ID3 tags
        .PARAMETER File
            Fully-qualified filesystem path to the .mp3 file(s) being updated
        .EXAMPLE
            Set-Artist -Artist 'Above & Beyond' -File '~/Music/Trance/Above & Beyond/Indonesia.mp3'
        .EXAMPLE
            Set-Artist 'Above & Beyond' './Far From In Love.mp3'
        .EXAMPLE
            (Get-ChildItem -Filter *.mp3 -Path 'C:\Users\user1\Music\Above & Beyond').FullName | Set-Artist 'Above & Beyond'
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, Position = 0)]
        [string] $Artist,

        [Parameter(Mandatory = $true,
        ValueFromPipeline = $true, Position = 1)]
        [string[]] $File
    )

    begin {
        Write-Verbose "[INFO] Entering Set-Artist"
    }

    process {
        foreach ($File in $File) {
            try {
                $FileTags = [TagLib.File]::Create($File)
                $FileTags.Tag.AlbumArtists = $Artist
                $FileTags.Tag.Performers = $Artist
                $FileTags.Save()

                Write-Output "Artist tags set to [$Artist] on MP3 file [$File]"
            } catch {
                if ($Error[0].Exception.ErrorRecord -eq 'Unable to find type [TagLib.File]') {
                    throw '[ERROR] TagLibSharp library is not imported. Please ensure this cmdlet can access [taglib-sharp.dll]'
                } else {
                    throw "[ERROR] Could not set Artist tags: $($Error[0])"
                }
            }
        }
    }

    end {
        Write-Verbose "[INFO] Exiting Set-Artist"
    }
}