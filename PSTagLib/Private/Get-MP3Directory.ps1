function Get-MP3Directory {
    <#
        .SYNOPSIS
            Determine if a provided filesystem directory is valid. Optionally allow users to launch a graphical filesystem browser to select a directory.
    #>
    [CmdletBinding()]
    param (
        # This parameter is compatible with Windows PowerShell ONLY.
        # Whether or not to use a Windows forms graphical interface to browse for a directory.
        [Parameter(Mandatory = $false)]
        [switch] $Gui
    )

    begin {
        if ($Gui) {
            Write-Host -ForegroundColor Blue "What is the path to the folder you want to process?"
            Start-Sleep -Milliseconds 500
            [System.Reflection.Assembly]::LoadWithPartialName("System.windows.forms") | Out-Null
            $OpenFileDialog = New-Object System.Windows.Forms.FolderBrowserDialog
            $OpenFileDialog.RootFolder = 'MyComputer'
            $OpenFileDialog.ShowDialog() | Out-Null

            # Save selected filesystem path to variable
            $Directory = $OpenFileDialog.SelectedPath
        } else {
            $Directory = Read-Host "What is the path to the folder you want to process?"
        }
    }

    process {
        # Ensure that the filesystem path supplied is valid
        try {
            $ValidDirectory = Test-Path -Path $Directory
        } catch {
            throw "Error checking filesystem path supplied $($Error[0])"
        }
    }

    end {
        if ($ValidDirectory) {
            $Directory
        } else {
            Write-Host -ForegroundColor Red 'Invalid folder path. Please validate and try again.'
            $false
        }
    }
} #endfunction Get-MP3Directory