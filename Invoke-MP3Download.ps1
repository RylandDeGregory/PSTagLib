<#
    .SYNOPSIS
        Download links from shell, text file or CSV file using youtube-dl
    .DESCRIPTION
        Download a list of files from a provided list of URLs.
        URLs can be provided as a parameter to the script, or as a .txt or .csv file.
    .INPUTS
        URLs parsable by youtube-dl. See https://github.com/ytdl-org/youtube-dl/ for more information
    .OUTPUTS
        MP3 files downloaded to the local machine
    .EXAMPLE
        .\Invoke-MP3Download.ps1 -InputFile 'C:\Users\user1\Desktop\tracks.txt'
    .EXAMPLE
        ./Invoke-MP3Download.ps1 -InputFile '~/Desktop/tracks.csv' -OutputPath '~/Music/'
    .EXAMPLE
        .\Invoke-MP3Download.ps1 -InputURL 'https://soundcloud.com/ryland-degregory/sample1'
    .EXAMPLE
        ./Invoke-MP3Download.ps1 -InputURL 'https://soundcloud.com/ryland-degregory/sample1', 'https://soundcloud.com/ryland-degregory/sample2'
#>
#region Init
[CmdletBinding()]
param (
    # Fully-qualified filesystem path to the directory containing list of URLs
    [Parameter()]
    [ValidatePattern('.*\.txt|csv$')]
    [string] $InputFile,

    # Fully-qualified filesystem path to the directory where MP3 files will be downloaded to
    # Defaults to the same directory as the script
    [Parameter()]
    [string] $OutputPath = $PSScriptRoot,

    # URL or array of URLs to download
    [Parameter()]
    [ValidatePattern('^https?://')]
    [string[]] $InputURL,

    # Optionally install youtube-dl on MacOS / Linux
    [Parameter()]
    [switch] $Install
)

$FileFormat = 'bestaudio'

# Ensure that Output Path directory has trailing slash
if ($OutputPath[-1] -notin '/', '\' -and $OutputPath -ne '.') {
    if ($OutputPath -like '*/*') {
        $OutputPath = $OutputPath + '/'
    } elseif ($OutputPath -like '*\*') {
        $OutputPath = $OutputPath + '\'
    }
}

# Set output format
$OutputFormat = "$OutputPath%(title)s.%(ext)s"

if ($InputFile -and $InputURL) {
    throw '[ERROR] You cannot specify both -InputFile and -InputURL parameters.'
}

if ($Install -and -not $IsWindows) {
    try {
        # Install youtube-dl if install parameter is specified
        if (-not $(Test-Path -Path '/usr/local/bin/youtube-dl')) {
            Invoke-WebRequest -Uri 'https://yt-dl.org/downloads/latest/youtube-dl' -OutFile '/usr/local/bin/youtube-dl'
            Invoke-Expression 'sudo chmod a+rx /usr/local/bin/youtube-dl'
        } else {
            Write-Warning '[WARN] youtube-dl is already installed'
        }
    } catch {
        throw "[ERROR] Error downloading and installing youtube-dl: $_"
    }
}

try {
    # Display youtube-dl version
    Write-Output '[INFO] youtube-dl version:'
    Invoke-Expression 'youtube-dl --version'
} catch {
    throw "[ERROR] YouTube DL is not installed or not configured correctly for access by this script. Please see installation instructions: $_"
}

if ($InputFile) {
    # The user provided a file
    if ($InputFile -like '*.txt') {
        $TracksForDownload = Get-Content -Path $InputFile
    } elseif ($InputFile -like '*.csv') {
        $TracksForDownload = Import-Csv -Path $InputFile -Header 'Tracks' | Select-Object -Expand 'Tracks'
    }
}

if ($InputURL) {
    # The user provided a string or array of strings
    $TracksForDownload = @()
    $InputURL | ForEach-Object {
        $TracksForDownload += $_
    }
}

Write-Output "[INFO] Downloading $($TracksForDownload.Count) files to: $OutputFormat`n"
foreach ($Item in $TracksForDownload) {
    try {
        # Download the track using the pre-defined output format
        Invoke-Expression "youtube-dl $Item -f $FileFormat -o '$OutputFormat'"
    } catch {
        throw "[ERROR] Error downloading [$Item] using youtube-dl: $_"
    }
}