function Get-Artist {
    <#
        .SYNOPSIS
            Get Artist ID3 tag values.
        .DESCRIPTION
            Get AlbumArtists, Artists and Performers ID3 tag values using TagLibSharp.
            Parameter can be supplied by name, by position, or using the pipeline. See examples.
        .INPUTS
            Filesystem path or array of paths.
        .OUTPUTS
            PSCustomObject containing filesystem path and ID3 Artist tag values.
        .EXAMPLE
            Get-Artist -File '~/Music/Trance/Above & Beyond/Indonesia.mp3'
        .EXAMPLE
            Get-Artist './Far From In Love.flac'
        .EXAMPLE
            (Get-ChildItem -Filter *.aiff -Path 'C:\Users\user1\Music\Trance').FullName | Get-Artist
    #>
    [CmdletBinding()]
    [OutputType([System.Object[]])]
    param (
        # Filesystem path or array of filesystem path(s)
        [Parameter(Mandatory, ValueFromPipeline, Position = 0)]
        [string[]] $File
    )

    begin {
        Write-Verbose 'Entering Get-Artist Function'
    }

    process {
        foreach ($File in $File) {
            if (Test-Path $File) {
                try {
                    $FileTags = [TagLib.File]::Create($File)
                } catch {
                    if ($_.Exception.Message -eq 'Unable to find type [TagLib.File].') {
                        Write-Error 'TagLibSharp library is not imported. Please ensure this function can access [TagLibSharp.dll]'
                        return
                    } else {
                        Write-Error "Failed instantiating TagLib.File class for file [$File]: $_"
                        return
                    }
                }
                if ($FileTags.Tag.RemixedBy) {
                    Write-Output "Getting Artist and RemixedBy tags for file [$File]"
                    [PSCustomObject]@{
                        File         = [string]$File
                        AlbumArtists = [string]$FileTags.Tag.AlbumArtists
                        Artists      = [string]$FileTags.Tag.Artists
                        Performers   = [string]$FileTags.Tag.Performers
                        RemixedBy    = [string]$FileTags.Tag.RemixedBy
                    }
                } else {
                    Write-Output "Getting Artist tags for file [$File]"
                    [PSCustomObject]@{
                        File         = [string]$File
                        AlbumArtists = [string]$FileTags.Tag.AlbumArtists
                        Artists      = [string]$FileTags.Tag.Artists
                        Performers   = [string]$FileTags.Tag.Performers
                    }
                }
            } else {
                Write-Error "File [$File] is not valid filesystem path or does not exist"
                return
            }
        }
    }

    end {
        Write-Verbose 'Exiting Get-Artist Function'
    }
}