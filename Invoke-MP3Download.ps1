<#
    .SYNOPSIS
        Download links from shell, text file or CSV file using youtube-dl
    .DESCRIPTION
        Download a list of files from a provided list of URLs.
        URLs can be provided as a parameter to the script, or as a .txt or .csv file.
        If using a file, URLs must be provided one per line.
    .INPUTS
        URLs parsable by youtube-dl. See https://github.com/ytdl-org/youtube-dl/ for more information
    .OUTPUTS
        MP3 files downloaded to the local machine
    .EXAMPLE
        ./Invoke-MP3Download.ps1 -InputFile 'C:\Users\user1\Desktop\tracks.txt'
    .EXAMPLE
        ./Invoke-MP3Download.ps1 -InputFile '/Users/user1/Desktop/tracks.csv' -OutputPath '/Users/user1/Music/'
    .EXAMPLE
        ./Invoke-MP3Download.ps1 -InputURL 'https://soundcloud.com/ryland-degregory/sample1' -OutputPath 'C:\Users\user1\Desktop\'
    .EXAMPLE
        ./Invoke-MP3Download.ps1 -InputURL 'https://soundcloud.com/ryland-degregory/sample1', 'https://soundcloud.com/ryland-degregory/sample2'
#>
#region Init
[CmdletBinding()]
param (
    # Fully-qualified filesystem path to the file containing list of URLs to download
    [Parameter()]
    [ValidatePattern('.*\.txt|csv$')]
    [string] $InputFile,

    # Fully-qualified filesystem path to the directory where MP3 files will be downloaded
    # Defaults to the same directory as the script
    [Parameter()]
    [string] $OutputPath = $PSScriptRoot,

    # URL or array of URLs to download
    [Parameter()]
    [ValidatePattern('^https?://')]
    [string[]] $InputURL
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

if (-not $InputFile -and -not $InputURL) {
    # Provide interactive user experience
    $Selection = Read-Host "Would you like to provide [1] a link, or [2] a file containing a list of links (one per line)? Type 1 or 2 and press Enter.`n"

    switch ($Selection) {
        '1' {
            $InputURL = Read-Host "Please enter the link to the MP3 file you want to download and press Enter.`n"
            $InputURL = $InputURL.Trim()
        }
        '2' {
            $InputFile = Read-Host "Please drag and drop the file of links into this window and press Enter.`n"
            $InputFile = $InputFile.Trim()
        }
    }

    Write-Host -ForegroundColor Green -Message "MP3 files will be downloaded to the Desktop."

    if ($PSVersionTable.PSVersion.Major -ge 6) {
        if ($IsWindows) {
            $OutputPath = "$env:USERPROFILE\Desktop\"
        } elseif ($IsMacOS) {
            $OutputPath = "$env:HOME/Desktop/"
        } else {
            $OutputPath = $PSScriptRoot
        }
    } else {
        OutputPath = "$env:USERPROFILE\Desktop\"
    }

}

try {
    # Output youtube-dl version
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

Write-Output "[INFO] Downloading $($TracksForDownload.Count) files to: $OutputPath`n"
foreach ($Item in $TracksForDownload) {
    try {
        # Download the track using the pre-defined output format
        Invoke-Expression "youtube-dl $Item -f $FileFormat -o '$OutputFormat'"
    } catch {
        throw "[ERROR] Error downloading [$Item] using youtube-dl: $_"
    }
}
