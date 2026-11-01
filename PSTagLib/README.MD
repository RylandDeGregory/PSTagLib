# PowerShell Module

## Overview

This directory contains a PowerShell module for interacting with Media File Metadata (ID3) Tags.

This module can be used independently of any scripts in the root repository, and is installed as a standard PowerShell module using PSResourceGet.

The modules uses standard PowerShell cmdlet syntax and native PowerShell objects, and supports standard interaction methods (pipeline, named, and positional parameters).

## Installation

Register the PSTagLib package repository and provide a classic GitHub personal access token with the `read:packages` scope. GitHub Packages requires credentials for all operations, including installing public packages.

```PowerShell
$repositoryName = 'PSTagLib'
Register-PSResourceRepository -Name $repositoryName -Uri 'https://nuget.pkg.github.com/RylandDeGregory/index.json'
$credential = Get-Credential -UserName 'YOUR_GITHUB_USERNAME' -Message 'Enter a classic GitHub PAT with read:packages access'
Install-PSResource -Name 'PSTagLib' -Repository $repositoryName -Credential $credential
Import-Module -Name 'PSTagLib' -Force
```

If `Register-PSResourceRepository` is unavailable, install and import PSResourceGet with `Install-Module Microsoft.PowerShell.PSResourceGet -Scope CurrentUser`.

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
