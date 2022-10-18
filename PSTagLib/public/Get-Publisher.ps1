function Get-Publisher {
    <#
        .SYNOPSIS
            Get Publisher ID3 tag value.
        .DESCRIPTION
            Get Publisher ID3 tag value using TagLibSharp.
            Parameter can be supplied by name, by position, or using the pipeline. See examples.
        .INPUTS
            Filesystem path or array of paths.
        .OUTPUTS
            PSCustomObject containing filesystem path and ID3 Publisher tag value.
        .EXAMPLE
            Get-Publisher -File '~/Music/Trance/Above & Beyond/Indonesia.mp3'
        .EXAMPLE
            Get-Publisher './Far From In Love.flac'
        .EXAMPLE
            (Get-ChildItem -Filter *.aiff -Path 'C:\Users\user1\Music\Enrico Sangiuliano').FullName | Get-Publisher
    #>
    [CmdletBinding()]
    [OutputType([System.Object[]])]
    param (
        # Filesystem path or array of filesystem path(s)
        [Parameter(Mandatory, ValueFromPipeline, Position = 0)]
        [string[]] $File
    )

    begin {
        Write-Verbose 'Entering Get-Publisher Function'
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
                    Write-Verbose "Getting Publisher tag for file [$File]"
                    [PSCustomObject]@{
                        File      = [string]$File
                        Publisher = [string]$FileTags.Tag.Publisher
                    }
            } else {
                Write-Error "File [$File] is not valid filesystem path or does not exist"
                return
            }
        }
    }

    end {
        Write-Verbose 'Exiting Get-Publisher Function'
    }
}