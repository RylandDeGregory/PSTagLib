# PSTagLib

A collection of PowerShell utilities for downloading and tagging MP3 files with [TagLibSharp](https://github.com/mono/taglib-sharp).

[![Build Status](https://dev.azure.com/rylanddegregory/PSTagLib/_apis/build/status/Build%20%26%20Publish?branchName=master)](https://dev.azure.com/rylanddegregory/PSTagLib/_build/latest?definitionId=13&branchName=master) [![PSTagLib package in PSTagLib feed in Azure Artifacts](https://feeds.dev.azure.com/rylanddegregory/702532c8-d17b-41e2-a97f-826f1f04b525/_apis/public/Packaging/Feeds/PSTagLib/Packages/7067aeb7-4e50-4c15-ac18-f8b2673848b6/Badge)](https://dev.azure.com/rylanddegregory/PSTagLib/_artifacts/feed/PSTagLib/NuGet/PSTagLib?preferRelease=true)

> PSTagLib [PowerShell module](https://dev.azure.com/rylanddegregory/PSTagLib/_artifacts/feed/PSTagLib/NuGet/PSTagLib/overview/) source is located in the `PSTagLib/` directory.

* [Installation](#installation)
* [Download MP3 files](#download-mp3-files)
* [Set MP3 tags](#set-mp3-metadata-tags)
* [Troubleshooting](#troubleshooting)
* [License](#license)

## Installation

1. Install PowerShell
    * If you have a Windows computer, launch it by pressing the Windows key and typing PowerShell. Click on **Windows PowerShell** (not ISE).
    * If you have a MacOS computer, install [PowerShell](https://github.com/PowerShell/PowerShell#get-powershell). Launch PowerShell by pressing <kbd>Cmd</kbd> + <kbd>Space</kbd> and typing PowerShell.
1. Download this repo to your local machine by clicking the Green **Code** button and choosing **Download ZIP**.
1. Unzip `PSTagLib.zip` to any folder on your computer.

## Download MP3 files

The script `Invoke-MP3Download.ps1` will enable you to programmatically download MP3 files from certain websites. Downloading videos or audio from videos is currently unsupported unless you already have a working installation of `ffmpeg`.

### Download youtube-dl

* `Invoke-MP3Download.ps1` can be utilized to programmatically download MP3 files using the [youtube-dl](https://ytdl-org.github.io/youtube-dl/index.html) command-line tool. If you do not have youtube-dl installed, follow the steps below taken from the youtube-dl [download page](https://ytdl-org.github.io/youtube-dl/download.html).

#### Windows

Open PowerShell as **Administrator** and copy the following code into the window. Press <kbd>Enter</kbd>.

```PowerShell
Invoke-RestMethod 'https://download.microsoft.com/download/1/6/5/165255E7-1014-4D0A-B094-B6A430A6BFFC/vcredist_x86.exe' -OutFile "$env:USERPROFILE\Desktop\vcredist_x86.exe"
Start-Process "$env:USERPROFILE\Desktop\vcredist_x86.exe" -ArgumentList '/Q' -Wait
Remove-Item "$env:USERPROFILE\Desktop\vcredist_x86.exe" -Force -ErrorAction SilentlyContinue
Invoke-WebRequest 'https://yt-dl.org/downloads/2021.12.17/youtube-dl.exe' -OutFile "$env:USERPROFILE\AppData\Local\Microsoft\WindowsApps\youtube-dl.exe"
$env:Path = [System.Environment]::GetEnvironmentVariable('PATH')
```

#### MacOS and Linux

Open PowerShell and copy the following code into the window. Press <kbd>Enter</kbd>.
> You will be prompted for your password. Type it in and press Enter. Don't worry if there aren't dots indicating that you are typing, your input is still being received.

```PowerShell
Invoke-RestMethod -Method Get -Uri 'https://yt-dl.org/downloads/latest/youtube-dl' -OutFile '/usr/local/bin/youtube-dl'
sudo chmod a+rx '/usr/local/bin/youtube-dl'
$env:Path = [System.Environment]::GetEnvironmentVariable('PATH')
```

### Download MP3 files using PowerShell and youtube-dl

1. Determine the files you want to download by collecting their URLs from the website(s) you want to download them from.
1. If you have multiple URLs, paste the URLs into a `.txt` or `.csv` file **one per line**, and save the file into the `PSTagLib` directory.
1. Open PowerShell. See the [Installation](#installation) section for details.

#### Interactive download

1. Drag and drop `Invoke-MP3Download.ps1` into the PowerShell window. Press Enter.
1. At the first question, select the mode you want the script to run in by typing `1` or `2`. Press Enter, then do the following based on your choice:
    * `1`: Paste the link into the PowerShell window. Press Enter.
    * `2`: Drag and drop the `.txt` or `.csv` file you created above into the PowerShell window. Press Enter.
1. The MP3 files corresponding to the link(s) provided will be downloaded to the Desktop, and a log of operations (including any errors, see [Troubleshooting](#troubleshooting)) will be written to the PowerShell window.

> If you are satisfied with the results of your MP3 file download(s), proceed to the [Set MP3 tags](#set-mp3-metadata-tags) section to set the metadata tags for the newly-downloaded MP3 files.

#### Programmatic download

PowerShell [Comment-based Help](https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_comment_based_help?view=powershell-7.1) is provided for `Invoke-MP3Download.ps1`. To view, type the following into a PowerShell window and press Enter (*your path to the script may be different*):

```PowerShell
Get-Help -Full ./Invoke-MP3Download.ps1
```

* **Example 1:** Download a list of links from a `.txt` file on the Desktop and save to them to the current directory.

```powershell
./Invoke-MP3Download.ps1 -InputFile 'C:\Users\user1\Desktop\tracks.txt'
```

* **Example 2:** Download a list of links from a `.csv` file and save them to the *Music* folder.

```powershell
./Invoke-MP3Download.ps1 -InputFile '/Users/user1/Desktop/tracks.csv' -OutputPath '/Users/user1/Music/'
```

* **Example 3:** Download a single link and save it to the Desktop.

```powershell
./Invoke-MP3Download.ps1 -InputURL 'https://soundcloud.com/ryland-degregory/sample1' -OutputPath 'C:\Users\user1\Desktop\'
```

* **Example 4:** Download multiple links and save them to the current directory.

```powershell
./Invoke-MP3Download.ps1 -InputURL 'https://soundcloud.com/ryland-degregory/sample1', 'https://soundcloud.com/ryland-degregory/sample2'
```

The MP3 files corresponding to the link(s) provided will be downloaded, and a log of operations (including any errors, see [Troubleshooting](#troubleshooting)) will be written to the PowerShell window.

> If you are satisfied with the results of your MP3 file download(s), proceed to the [Set MP3 tags](#set-mp3-metadata-tags) section to set the metadata tags for the newly-downloaded MP3 files.

## Set MP3 Metadata tags

Ensure that both `Set-MP3Tags.ps1` and `taglib-sharp.dll` are in the same folder.

* `Set-MP3Tags.ps1` can be utilized either interactively or programmatically.
* It expects files to adhere to the following naming convention:

```text
<Artist> - <Title> (<mix>)

Example: Above & Beyond, OceanLab - Satellite (Trance Wax Extended Mix)
```

* The delimiter between artist and title is ' - ' (space, hyphen, space).
* Any files that fail to adhere to the naming convention will not be processed.

```text
C:\Users\Ryland\Music\Trance\Factor B feat. Cat Martin Crashing Over (Extended Mix).mp3
***Filename improperly formatted. This file will be skipped.***
```

### Interactively

#### Example 1

1. Open PowerShell. See the [Installation](#installation) section for details.
1. Drag and drop `Set-MP3Tags.ps1` into the PowerShell window. Press Enter.
1. Follow prompt to select the folder it will process.

```text
What is the path to the folder you want to process?: C:\Users\Ryland\Music\Trance
```

1. Select if you want the Genre set or not during processing.
    * The Genre will be the name of the leaf folder. In this example, it would be `Trance`.

```text
Would you like to set the genre based on folder name? Enter 'Y' or 'N': Y
```

#### Output 1

```text
----------
C:\Users\RylandMusic\Trance\Above & Beyond, OceanLab - Satellite (Trance Wax Extended Mix).mp3
Artist: Above & Beyond, OceanLab
Title: Satellite (Trance Wax Extended Mix)
Genre: Trance
----------
Completed.
```

### Programmatically

#### Example 2

1. Execute the script from a PowerShell session, specifying the directory as a parameter.

```powershell
./Set-MP3Tags.ps1 -Directory "C:\Users\Ryland\Music\Trance"
```

1. Execute the script from PowerShell, specifying a directory and for Genre to be processed.
    * The Genre will be the name of the leaf folder. In this example, it would be `Trance`.

```powershell
./Set-MP3Tags.ps1 -Directory "C:\Users\Ryland\Music\Trance" -Genre
```

#### Output 2

```text
PS C:\Users\Ryland\Documents\Code\PSTagLib> .\Set-MP3Tags.ps1 -Directory C:\Users\Ryland\Music\Trance -Genre
----------
C:\Users\Ryland\Music\Trance\Above & Beyond, OceanLab - Satellite (Trance Wax Extended Mix).mp3
Artist: Above & Beyond, OceanLab
Title: Satellite (Trance Wax Extended Mix)
Genre: Trance
----------
C:\Users\Ryland\Music\Trance\Factor B feat. Cat Martin - Crashing Over (Extended Mix).mp3
Artist: Factor B feat. Cat Martin
Title: Crashing Over (Extended Mix)
Genre: Trance
----------
Completed.
Press Enter to exit:
```

## Troubleshooting

### Script won't execute

![WindowsTerminal_EVBHp0icto](https://user-images.githubusercontent.com/18073815/167960282-830a55cb-9d11-4b1a-99a3-f055050febc0.png)

* Ensure that you can execute scripts on your machine. Enter an **Administrator** PowerShell session and paste the following command:

```powershell
Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process
```

* If you change this setting, you **MUST** change it back when you are done using this tool.

```powershell
Set-ExecutionPolicy -ExecutionPolicy Default
```

### Invalid folder path

![WindowsTerminal_soOeUqTpkg](https://user-images.githubusercontent.com/18073815/167960528-e0e0051b-5c47-43c8-91d3-4fde66d6663a.png)

* If your folder path has a space, you may have to wrap the path in quotes ("").
    * `"C:\Users\Ryland\New Music\Trance"`

### Filename improperly formatted

* If you receive the following error message on any of your files, review the naming convention (default `Artist - Title`).
    * If you desire, you may modify the delimiter by which the script processes files. In `Set-MP3Tags.ps1`, modify the value of `$delimiter` at the top of the script.

```text
----------
C:\Users\Ryland\Desktop\Music\Trance\Factor B feat. Cat Martin Crashing Over (Extended Mix).mp3
***Filename improperly formatted. This file will be skipped.***
----------
```

* Once you have updated the incorrect filenames, you can safely run the script again with no impact to the already-correct files.

## License

This code is distributed under the [MIT License](http://opensource.org/licenses/mit-license.php).
