function Set-TagLibProperty {
    <#
        .SYNOPSIS
            Set ID3 tag values.
        .DESCRIPTION
            Set ID3 tag values using TagLibSharp.
            Parameters can be supplied by name, by position, or using the pipeline. See examples.
        .INPUTS
            Filesystem path, hashtable of ID3 tag names and values.
        .OUTPUTS
            PSCustomObject containing filesystem path and updated ID3 tag values.
        .EXAMPLE
            Set-TagLibProperty -File '~/Music/Trance/Above & Beyond/Tri-State/Indonesia.mp3' -Property @{'Year' = '2005'; 'Publisher' = 'Anjunabeats'}
        .EXAMPLE
            Set-TagLibProperty './Download.flac' -Property @{'Album' = 'Counting The Points'; 'Artist' = 'Andrew Bayer'}
   #>
    [CmdletBinding()]
    [OutputType([System.Object[]])]
    param (
        # Filesystem path
        [Parameter(Mandatory, ValueFromPipeline, Position = 0)]
        [string] $File,

        # Property or list of properties to return from the file
        [Parameter(Mandatory, Position = 1)]
        [hashtable] $Property
    )

    begin {
        Write-Verbose 'Entering Set-TagLibProperty Function'

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
                Write-Verbose "Setting ID3 metadata tags for file [$File]"
                $MetadataObject = [PSCustomObject]@{
                    File = [string]$File
                }
                foreach ($MetadataProperty in $Property.GetEnumerator()) {
                    if ($MetadataProperty -in $ValidProperties) {
                        Write-Verbose "Setting [$($MetadataProperty.Key)] property to [$($MetadataProperty.Value)] for file [$File]"
                        $FileTags.Property.$($MetadataProperty.Key) = $MetadataProperty.Value
                    } elseif ($MetadataProperty -in $ValidTags) {
                        Write-Verbose "Setting [$($MetadataProperty.Key)] tag to [$($MetadataProperty.Value)] for file [$File]"
                        $FileTags.Tag.$($MetadataProperty.Key) = $MetadataProperty.Value
                    }  elseif ($MetadataProperty.Key -eq 'Artist') {
                        $FileTags.Tag.Artists = $MetadataProperty.Value
                        $FileTags.Tag.Performers = $MetadataProperty.Value
                    } elseif ($MetadataProperty.Key -eq 'Genre') {
                        $FileTags.Tag.Genres = $MetadataProperty.Value
                    } else {
                        Write-Warning "Property [$($MetadataProperty.Key)] is not a valid property or tag for file [$File]."
                        Write-Warning "Valid Properties: '$($ValidProperties -join ', ')'. Valid Tags: '$($ValidTags -join ', ')'."
                    }
                    Add-Member -InputObject $MetadataObject -NotePropertyName $MetadataProperty.Key -NotePropertyValue $MetadataProperty.Value
                }
                try {
                    $FileTags.Save()
                } catch {
                    Write-Error "Failed setting metadata tags for file [$File]: $_"
                    return
                }
                return $MetadataObject
        } else {
            Write-Error "File [$File] is not valid filesystem path or does not exist"
            return
        }
    }

    end {
        Write-Verbose 'Exiting Get-Metadata Function'
    }
}