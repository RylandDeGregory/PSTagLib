function Set-Title {
    <#
        .SYNOPSIS
            Set Title ID3 tag.
        .DESCRIPTION
            Set Title ID3 tag using TagLibSharp.
            Parameters can be supplied by name, by position, or using the pipeline. See examples.
        .INPUTS
            Filesystem path.
        .OUTPUTS
            MP3 ID3 Title tag is updated on file.
        .EXAMPLE
            Set-Title -Title 'World On Fire - 12 Inch Mix' -File '~/Music/Trance/Above & Beyond/world on fire.mp3'
        .EXAMPLE
            Set-Title 'Far From In Love (San Francisco Mix)' './Far From In Love.flac'
        .EXAMPLE
            'C:\Users\user1\Music\Enrico Sangiuliano\Biomorph\2.aiff' | Set-Title 'Multicellular'
    #>
    [CmdletBinding()]
    [OutputType([System.Object[]])]
    param (
        # Name of the Title to be set in the Title ID3 tag
        [Parameter(Mandatory, Position = 0)]
        [string] $Title,

        # Filesystem path
        [Parameter(Mandatory, ValueFromPipeline, Position = 1)]
        [string] $File
    )

    begin {
        Write-Verbose 'Entering Set-Title Function'
    }

    process {
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
                Write-Verbose "Setting Title tag to [$Title] for file [$File]"
                $FileTags.Tag.Title = $Title
                $FileTags.Save()
            } catch {
                Write-Error "Failed setting Title tag for file [$File]: $_"
            }
        } else {
            Write-Error "File [$File] is not valid filesystem path or does not exist"
            return
        }
    }

    end {
        Write-Verbose 'Exiting Set-Title Function'
    }
}