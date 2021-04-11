# PSTagLib

A collection of PowerShell utilities for downloading and tagging MP3 files with [TagLibSharp](https://github.com/mono/taglib-sharp).

* [Installation](#installation)
* [Download MP3 files](#download-mp3-files)
* [Set MP3 tags](#Set-MP3-metadata-tags)
* [Troubleshooting](#troubleshooting)
* [License](#license)

## Installation

1. Install PowerShell
    * If you have a Windows computer, launch it by pressing the Windows key and typing PowerShell. Click on **Windows PowerShell** (not ISE).
    * If you have a MacOS computer, install [PowerShell](https://github.com/PowerShell/PowerShell#get-powershell). Lanuch PowerShell by pressing `Command` + `Space` and typing PowerShell.
2. Download this repo to your local machine by clicking the Green button and choosing **Download ZIP**.
3. Extract `PSTagLib.zip` to a folder.

## Download MP3 files

The script `Invoke-MP3Download.ps1` will enable you to programmatically download MP3 files from certain websites. Downloading videos or audio from videos is currently unsupported unless you already have a working installation of `ffmpeg`.

### Download youtube-dl

* `Invoke-MP3Download.ps1` can be utilized to programmatically download MP3 files using the [youtube-dl](https://ytdl-org.github.io/youtube-dl/index.html) command-line tool. If you do not have youtube-dl installed, follow the steps below taken from the youtube-dl [download page](https://ytdl-org.github.io/youtube-dl/download.html).

#### Windows

* Go to the `youtube-dl` download page -- linked above -- and click on the "Windows exe" link. Once the file is downloaded, double-click it to install.

#### MacOS and Linux

> You will be prompted for your password. Type it in and press Enter. Don't worry if there aren't dots indicating that you are typing, your input is still being received.

```shell
sudo curl -L https://yt-dl.org/downloads/latest/youtube-dl -o /usr/local/bin/youtube-dl
sudo chmod a+rx /usr/local/bin/youtube-dl
```

### Download MP3 files using PowerShell and youtube-dl

1. Determine the files you want to download by collecting their URLs from the website(s) you want to download them from.
1. If you have multiple URLs, paste the URLs into a `.txt` or `.csv` file **one per line**, and save the file into the `PSTagLib` directory.
1. Open PowerShell. See the [Installation](#Installation) section for details.

#### Interactive download

1. Drag and drop `Invoke-MP3Download.ps1` into the PowerShell window. Press Enter.
1. At the first question, select the mode you want the script to run in by typing `1` or `2`. Press Enter, then do the following based on your choice:
    * `1`: Paste the link into the PowerShell window. Press Enter.
    * `2`: Drag and drop the `.txt` or `.csv` file you created above into the PowerShell window. Press Enter.
1. The MP3 files corresponding to the link(s) provided will be downloaded to the Desktop, and a log of operations (including any errors, see [Troubleshooting](#troubleshooting)) will be written to the PowerShell window.

> If you are satisfied with the results of your MP3 file download(s), proceed to the [Set MP3 tags](#Set-MP3-metadata-tags) section to set the metadata tags for the newly-downloaded MP3 files.

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

> If you are satisfied with the results of your MP3 file download(s), proceed to the [Set MP3 tags](#Set-MP3-metadata-tags) section to set the metadata tags for the newly-downloaded MP3 files.

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

1. Open PowerShell. See the [Installation](#Installation) section for details.
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

* Ensure that you can execute scripts on your machine. Enter an **Administrator** PowerShell session and paste the following command:

```powershell
Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope CurrentUser
```

* If you change this setting, you **MUST** change it back when you are done using this tool.

```powershell
Set-ExecutionPolicy -ExecutionPolicy Default
```

### Invalid folder path

* If your folder path has a space, you may have to wrap the path in quotes ("").
    * `"C:\Users\Ryland\New Music\Trance"`

### Filename improperly formatted

* If you receive the following error message on any of your files, review the naming convention defined at the top of the [Use](#Use) section.
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
