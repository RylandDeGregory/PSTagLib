# PSTagLib

A PowerShell script for manipulating metadata in MP3 files with [TagLibSharp](https://github.com/mono/taglib-sharp).

* [Installation](#installation)
* [Use](#Use)
* [Troubleshooting](#Troubleshooting)
* [License](#license)

## Installation

1. Install PowerShell
    * If you have a Windows computer, launch it by pressing the Windows key and typing PowerShell. Click on **Windows PowerShell** (not ISE).
    * If you have a MacOS computer, install [PowerShell Core](https://github.com/PowerShell/PowerShell#get-powershell). Lanuch PowerShell by pressing `Command` + `Space` and typing PowerShell.
2. Download this repo to your local machine by clicking the Green button and choosing **Download ZIP**.
3. Extract `PSTagLib.zip` to a folder.
    * Ensure that both `Set-Mp3Tags.ps1` and `taglib-sharp.dll` are in the same folder.

## Use

* This script can be utilized either interactively or programmatically.
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

#### Example

1. Open PowerShell. See the [Installation](#Installation) section for details.
1. Drag and drop `Set-Mp3Tags.ps1` into the PowerShell window. Press Enter.
2. Follow prompt to select the folder it will process.

```text
What is the path to the folder you want to process?: C:\Users\Ryland\Music\Trance
```

3. Select if you want the Genre set or not during processing.
    * The Genre will be the name of the leaf folder. In this example, it would be `Trance`.

```text
Would you like to set the genre based on folder name? Enter 'Y' or 'N': Y
```

#### Output

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

#### Example

1. Execute the script from a PowerShell session, specifying the directory as a parameter.

```powershell
./Set-Mp3Tags.ps1 -Directory "C:\Users\Ryland\Music\Trance"
```

2. Execute the script from PowerShell, specifying a directory and for Genre to be processed.
    * The Genre will be the name of the leaf folder. In this example, it would be `Trance`.

```powershell
./Set-Mp3Tags.ps1 -Directory "C:\Users\Ryland\Music\Trance" -Genre
```

#### Output

```text
PS C:\Users\Ryland\Documents\Code\PSTagLib> .\Set-Mp3Tags.ps1 -Directory C:\Users\Ryland\Music\Trance -Genre
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
  * If you desire, you may modify the delimiter by which the script processes files. In `Set-Mp3Tags.ps1`, modify the value of `$delimiter` at the top of the script.

```text
----------
C:\Users\Ryland\Desktop\Music\Trance\Factor B feat. Cat Martin Crashing Over (Extended Mix).mp3
***Filename improperly formatted. This file will be skipped.***
----------
```

* Once you have updated the incorrect filenames, you can safely run the script again with no impact to the already-correct files.

## License

This code is distributed under the [MIT License](http://opensource.org/licenses/mit-license.php).
