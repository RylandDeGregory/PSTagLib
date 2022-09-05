function Set-Album {
    <#
        .SYNOPSIS
            Set Album ID3 tag
        .DESCRIPTION
            Set Album ID3 tag using TagLibSharp.
            Parameters can be supplied by name, by position, or using the pipeline. See examples.
        .INPUTS
            Filesystem path or array of paths.
        .OUTPUTS
            MP3 ID3 Album tag is updated on file(s).
        .EXAMPLE
            Set-Album -Album 'Tri-State' -File '~/Music/Trance/Above & Beyond/Indonesia.mp3'
        .EXAMPLE
            Set-Album 'Anjunabeats Volume 1' './Far From In Love.flac'
        .EXAMPLE
            (Get-ChildItem -Filter *.aiff -Path 'C:\Users\user1\Music\Above & Beyond\Group Therapy').FullName | Set-Album 'Group Therapy'
    #>
    [CmdletBinding()]
    [OutputType([System.Object[]])]
    param (
        # Name of the Album to be set in the Album ID3 tag
        [Parameter(Mandatory, Position = 0)]
        [string] $Album,

        # Filesystem path or array of filesystem path(s)
        [Parameter(Mandatory, ValueFromPipeline, Position = 1)]
        [string[]] $File
    )

    begin {
        Write-Verbose 'Entering Set-Album Function'
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
                try {
                    Write-Verbose "Setting Album tag to [$Album] for file [$File]"
                    $FileTags.Tag.Album = $Album
                    $FileTags.Save()
                } catch {
                    Write-Error "Failed setting Album tag for file [$File]: $_"
                }
            } else {
                Write-Error "File [$File] is not valid filesystem path or does not exist"
                return
            }
        }
    }

    end {
        Write-Verbose 'Exiting Set-Album Function'
    }
}