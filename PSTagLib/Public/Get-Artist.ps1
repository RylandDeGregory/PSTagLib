function Get-Artist {
    <#
        .SYNOPSIS
            Get Artist MP3 ID3 tag values
        .DESCRIPTION
            Get AlbumArtists and Performers MP3 ID3 tag values using TagLibSharp.
            Parameter can be supplied by name, by position, or using the pipeline. See examples.
        .INPUTS
            Fully-qualified filesystem path or array of paths.
        .OUTPUTS
            PSCustomObject containing filesystem path and MP3 ID3 Artist tag values.
        .EXAMPLE
            Get-Artist -File '~/Music/Trance/Above & Beyond/Indonesia.mp3'
        .EXAMPLE
            Get-Artist './Far From In Love.mp3'
        .EXAMPLE
            (Get-ChildItem -Filter *.mp3 -Path 'C:\Users\user1\Music\Trance').FullName | Get-Artist
    #>
    [CmdletBinding()]
    [OutputType([System.Object])]
    param (
        # Fully-qualified filesystem path to the .mp3 file(s) being updated
        # Accepts single path or string array of paths
        [Parameter(Mandatory = $true, ValueFromPipeline = $true, Position = 1)]
        [string[]] $File
    )

    begin {
        Write-Verbose "[INFO] Entering Get-Artist"
    }

    process {
        foreach ($File in $File) {
            try {
                $FileTags = [TagLib.File]::Create($File)
            } catch {
                if ($Error[0].Exception.Message -eq 'Unable to find type [TagLib.File].') {
                    throw '[ERROR] TagLibSharp library is not imported. Please ensure this cmdlet can access [taglib-sharp.dll]'
                } else {
                    throw "[ERROR] Could not get Artist tags: $($Error[0])"
                }
            }
            [PSCustomObject]@{
                File         = [string]$File
                AlbumArtists = [string]$FileTags.Tag.AlbumArtists
                Performers   = [string]$FileTags.Tag.Performers
            }
        }
    }

    end {
        Write-Verbose "[INFO] Exiting Get-Artist"
    }
}