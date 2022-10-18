function Set-Publisher {
    <#
        .SYNOPSIS
            Set Publisher ID3 tag.
        .DESCRIPTION
            Set Publisher ID3 tag using TagLibSharp.
            Parameters can be supplied by name, by position, or using the pipeline. See examples.
        .INPUTS
            Filesystem path or array of paths.
        .OUTPUTS
            MP3 ID3 Publisher tag is updated on file(s).
        .EXAMPLE
            Set-Publisher -Publisher 'Anjunabeats' -File '~/Music/Trance/Above & Beyond/Indonesia.mp3'
        .EXAMPLE
            Set-Publisher 'FSOE Fables' './Concorde (Cold Blue Remix).flac'
        .EXAMPLE
            (Get-ChildItem -Filter *.aiff -Path 'C:\Users\user1\Music\Enrico Sangiuliano\Biomorph').FullName | Set-Publisher 'Drumcode'
    #>
    [CmdletBinding()]
    [OutputType([System.Object[]])]
    param (
        # Name of the Publisher to be set in the Publisher ID3 tag
        [Parameter(Mandatory, Position = 0)]
        [string] $Publisher,

        # Filesystem path or array of filesystem path(s)
        [Parameter(Mandatory, ValueFromPipeline, Position = 1)]
        [string[]] $File
    )

    begin {
        Write-Verbose 'Entering Set-Publisher Function'
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
                try {
                    Write-Verbose "Setting Publisher tag to [$Publisher] for file [$File]"
                    $FileTags.Tag.Publisher = $Publisher
                    $FileTags.Save()
                } catch {
                    Write-Error "Failed setting Publisher tag for file [$File]: $_"
                }
            } else {
                Write-Error "File [$File] is not valid filesystem path or does not exist"
                return
            }
        }
    }

    end {
        Write-Verbose 'Exiting Set-Publisher Function'
    }
}