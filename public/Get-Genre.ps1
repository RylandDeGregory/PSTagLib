function Get-Genre {
    <#
        .SYNOPSIS
            Get Genre ID3 tag value
        .DESCRIPTION
            Get Genre ID3 tag value using TagLibSharp.
            Parameter can be supplied by name, by position, or using the pipeline. See examples.
        .INPUTS
            Filesystem path or array of paths.
        .OUTPUTS
            PSCustomObject containing filesystem path and ID3 Genre tag value.
        .EXAMPLE
            Get-Genre -File '~/Music/Trance/Above & Beyond/Indonesia.mp3'
        .EXAMPLE
            Get-Genre './Far From In Love.flac'
        .EXAMPLE
            (Get-ChildItem -Filter *.aiff -Path 'C:\Users\user1\Music\Beatport-20220904').FullName | Get-Genre
    #>
    [CmdletBinding()]
    [OutputType([System.Object[]])]
    param (
        # Filesystem path or array of filesystem path(s)
        [Parameter(Mandatory, ValueFromPipeline, Position = 0)]
        [string[]] $File
    )

    begin {
        Write-Verbose 'Entering Get-Genre Function'
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
                    Write-Verbose "Getting Genre tag for file [$File]"
                    [PSCustomObject]@{
                        File  = [string]$File
                        Genre = [string]$FileTags.Tag.Genre
                    }
            } else {
                Write-Error "File [$File] is not valid filesystem path or does not exist"
                return
            }
        }
    }

    end {
        Write-Verbose 'Exiting Get-Genre Function'
    }
}