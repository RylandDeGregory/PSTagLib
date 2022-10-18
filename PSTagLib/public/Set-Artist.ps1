function Set-Artist {
    <#
        .SYNOPSIS
            Set Artist ID3 tags.
        .DESCRIPTION
            Set AlbumArtists and Performers ID3 tags using TagLibSharp.
            Parameters can be supplied by name, by position, or using the pipeline. See examples.
        .INPUTS
            Filesystem path or array of paths.
        .OUTPUTS
            MP3 ID3 Artist tags are updated on file(s).
        .EXAMPLE
            Set-Artist -File '~/Music/Trance/Above & Beyond/Indonesia.mp3' -Artist 'Above & Beyond'
        .EXAMPLE
            Set-Artist './Far From In Love.flac' 'Above & Beyond'
        .EXAMPLE
            (Get-ChildItem -Filter *.aiff -Path 'C:\Users\user1\Music\Above & Beyond').FullName | Set-Artist 'Above & Beyond'
        .EXAMPLE
            Set-Artist -File '~/Music/Trance/Above & Beyond/You Got To Go (Seven Lions Remix).mp3' -Artist 'Above & Beyond' -RemixedBy 'Seven Lions'
    #>
    [CmdletBinding(DefaultParameterSetName = 'Artist')]
    [OutputType([System.Object[]])]
    param (
        # Filesystem path or array of filesystem path(s)
        [Parameter(Mandatory, ValueFromPipeline, Position = 0, ParameterSetName = 'Artist')]
        [Parameter(Mandatory, ValueFromPipeline, Position = 0, ParameterSetName = 'RemixedArtist')]
        [Parameter(Mandatory, ValueFromPipeline, Position = 0, ParameterSetName = 'RemixedBy')]
        [string[]] $File,

        # Name of the artist to be set in the Artists, AlbumArtists, and Performer ID3 tags
        [Parameter(Mandatory, Position = 1, ParameterSetName = 'Artist')]
        [Parameter(Mandatory, Position = 1, ParameterSetName = 'RemixedArtist')]
        [string] $Artist,

        # Name of the artist to be set in the RemixedBy ID3 tag
        [Parameter(Mandatory, Position = 1, ParameterSetName = 'RemixedBy')]
        [Parameter(Mandatory, Position = 2, ParameterSetName = 'RemixedArtist')]
        [string] $RemixedBy
    )

    begin {
        Write-Verbose 'Entering Set-Artist Function'
    }

    process {
        foreach ($File in $File) {
            if (Test-Path $File) {
                $FilePath = Resolve-Path -Path $File
                try {
                    $FileTags = [TagLib.File]::Create($FilePath)
                } catch {
                    if ($_.Exception.Message -eq 'Unable to find type [TagLib.File].') {
                        Write-Error 'TagLibSharp library is not imported. Please ensure this function can access [TagLibSharp.dll]'
                        return
                    } else {
                        Write-Error "Failed instantiating TagLib.File class for file [$File]: $_"
                        return
                    }
                }
                if ($RemixedBy -and $Artist) {
                    try {
                        Write-Verbose "Setting Artist tags to [$Artist] and RemixedBy tag to [$RemixedBy] for file [$File]"
                        $FileTags.Tag.Artists      = $Artist
                        $FileTags.Tag.AlbumArtists = $Artist
                        $FileTags.Tag.Performers   = $Artist
                        $FileTags.Tag.RemixedBy    = $RemixedBy
                        $FileTags.Save()
                    } catch {
                        Write-Error "Failed setting Artist and RemixedBy tags for file [$File]: $_"
                    }
                } elseif ($RemixedBy -and -not $Artist) {
                    try {
                        Write-Verbose "Setting RemixedBy tag to [$RemixedBy] for file [$File]"
                        $FileTags.Tag.RemixedBy = $RemixedBy
                        $FileTags.Save()
                    } catch {
                        Write-Error "Failed setting Artist and RemixedBy tags for file [$File]: $_"
                    }
                } else {
                    try {
                        Write-Verbose "Setting Artist tags to [$Artist] for file [$File]"
                        $FileTags.Tag.Artists      = $Artist
                        $FileTags.Tag.AlbumArtists = $Artist
                        $FileTags.Tag.Performers   = $Artist
                        $FileTags.Save()
                    } catch {
                        Write-Error "Failed setting Artist tags for file [$File]: $_"
                    }
                }
            } else {
                Write-Error "File [$File] is not valid filesystem path or does not exist"
                return
            }
        }
    }

    end {
        Write-Verbose 'Exiting Set-Artist Function'
    }
}