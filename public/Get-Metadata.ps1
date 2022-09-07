function Get-Metadata {
    <#
        .SYNOPSIS
            Get ID3 tag values.
        .DESCRIPTION
            Get ID3 tag values using TagLibSharp.
            Parameters can be supplied by name, by position, or using the pipeline. See examples.
        .INPUTS
            Filesystem path or array of paths, ID3 tag name or array of tag names.
        .OUTPUTS
            PSCustomObject containing filesystem path and ID3 tag values.
        .EXAMPLE
            Get-Metadata -File '~/Music/Trance/Above & Beyond/Tri-State/Indonesia.mp3' -All
        .EXAMPLE
            Get-Metadata './Download.flac' -Property 'Album', 'Artists', 'Title'
        .EXAMPLE
            (Get-ChildItem -Filter *.aiff -Path 'C:\Users\user1\Music\Beatport-20220904').FullName | Get-Metadata -Property 'Title', 'Duration', 'BeatsPerMinute'
    #>
    [CmdletBinding(DefaultParameterSetName = 'Properties')]
    [OutputType([System.Object[]])]
    param (
        # Filesystem path or array of filesystem path(s)
        [Parameter(Mandatory, ValueFromPipeline, Position = 0, ParameterSetName = 'Properties')]
        [Parameter(Mandatory, ValueFromPipeline, Position = 0, ParameterSetName = 'AllProperties')]
        [string[]] $File,

        # Property or list of properties to return from the file
        [Parameter(Mandatory, Position = 1, ParameterSetName = 'Properties')]
        [string[]] $Property,

        # Return all available properties on file
        [Parameter(Mandatory, ParameterSetName = 'AllProperties')]
        [switch] $All
    )

    begin {
        Write-Verbose 'Entering Get-Metadata Function'

        $ValidProperties = @(
            'AudioBitrate',
            'AudioChannels',
            'AudioSampleRate',
            'BitsPerSample',
            'Codecs',
            'Duration'
        )

        $ValidTags = @(
            'Album',
            'AlbumArtists',
            'Artists',
            'BeatsPerMinute',
            'Comment',
            'Composers',
            'Conductor',
            'Copyright',
            'DateTagged',
            'Description',
            'Disc',
            'DiscCount',
            'Genres',
            'IsCompilation',
            'Length',
            'Lyrics',
            'Performers',
            'Pictures',
            'Publisher',
            'RemixedBy',
            'Subtitle',
            'Title',
            'Track',
            'Version',
            'Year'
        )
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
                    Write-Verbose "Getting ID3 metadata tags for file [$File]"
                    $MetadataObject = [PSCustomObject]@{
                        File = [string]$File
                    }
                    if (-not $All) {
                        foreach ($MetadataProperty in $Property) {
                            if ($MetadataProperty -in $ValidProperties) {
                                Add-Member -InputObject $MetadataObject -NotePropertyName $MetadataProperty -NotePropertyValue $FileTags.Properties.$($MetadataProperty)
                            } elseif ($MetadataProperty -in $ValidTags) {
                                Add-Member -InputObject $MetadataObject -NotePropertyName $MetadataProperty -NotePropertyValue $FileTags.Tag.$($MetadataProperty)
                            } elseif ($MetadataProperty -eq 'Artist') {
                                Add-Member -InputObject $MetadataObject -NotePropertyName $MetadataProperty -NotePropertyValue $($FileTags.Tag.Artists -join ', ')
                            } else {
                                Write-Warning "Property [$MetadataProperty] is not a valid property or tag for file [$File]."
                                Write-Warning "Valid Properties: '$($ValidProperties -join ', ')'. Valid Tags: '$($ValidTags -join ', ')'."
                            }
                        }
                    } else {
                        foreach ($MetadataProperty in ($ValidTags + $ValidProperties)) {
                            if ($MetadataProperty -in $ValidProperties) {
                                Add-Member -InputObject $MetadataObject -NotePropertyName $MetadataProperty -NotePropertyValue $FileTags.Properties.$($MetadataProperty)
                            } elseif ($MetadataProperty -in $ValidTags) {
                                Add-Member -InputObject $MetadataObject -NotePropertyName $MetadataProperty -NotePropertyValue $FileTags.Tags.$($MetadataProperty)
                            }
                        }
                    }
                    return $MetadataObject
            } else {
                Write-Error "File [$File] is not valid filesystem path or does not exist"
                return
            }
        }
    }

    end {
        Write-Verbose 'Exiting Get-Metadata Function'
    }
}