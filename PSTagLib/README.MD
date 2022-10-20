# PowerShell Module

## Overview

This directory contains a PowerShell module for interacting with Media File Metadata (ID3) Tags.

This module can be used independently of any scripts in the root repository, and is meant to be installed as a standard PowerShell module using PowerShellGet. 

The modules uses standard PowerShell cmdlet syntax and native PowerShell objects, and supports standard interaction methods (pipeline, named, and positional parameters).

## Installation

1. Register the PSTagLib PowerShell Repository on [Azure Artifacts](https://dev.azure.com/rylanddegregory/PSTagLib/_artifacts/feed/PSTagLib).

```PowerShell
Register-PSRepository -Name PSTagLibRepo -SourceLocation 'https://pkgs.dev.azure.com/rylanddegregory/pstaglib/_packaging/pstaglib/nuget/v2' -InstallationPolicy Trusted
```

2. Install the PSTagLib module using PowerShellGet.

```PowerShell
Install-Module PSTagLib -Scope CurrentUser
```
3. Update the module when a new version is available in the repository.

```PowerShell
Update-Module PSTagLib
```

## Usage

List available commands.

```PowerShell
Get-Command -Module PSTagLib
```

Get command usage and examples.

```PowerShell
Get-Help $Command -Full

# Example: Get-Help Set-TagLibProperty -Full
```

## Supported ID3 file metadata tags and properties

### Tags

- Album
- AlbumArtists
- Artists
- BeatsPerMinute
- Comment
- Composers
- Conductor
- Copyright
- DateTagged
- Description
- Disc
- DiscCount
- Genres
- IsCompilation
- Length
- Lyrics
- Performers
- Pictures
- Publisher
- RemixedBy
- Subtitle
- Title
- Track
- Version
- Year

### Properties

- AudioBitrate
- AudioChannels
- AudioSampleRate
- BitsPerSample
- Codecs
- Duration
