# Get public and private function files
$Public  = Get-ChildItem -Path "$PSScriptRoot\public\*.ps1" -Exclude "*.Tests.*" -ErrorAction SilentlyContinue
$Private = Get-ChildItem -Path "$PSScriptRoot\private\*.ps1" -Exclude "*.Tests.*" -ErrorAction SilentlyContinue

# Get .NET assembly files
$Assembly = Get-ChildItem -Path "$PSScriptRoot\lib\*.dll" -ErrorAction SilentlyContinue

# Get currently-loaded assemblies
$LoadedAssemblies = ([System.AppDomain]::CurrentDomain.GetAssemblies() | ForEach-Object {New-Object -TypeName System.Reflection.AssemblyName -ArgumentList $_.FullName} )

# Import all .NET assembly files and capture any errors
foreach ($Import in $Assembly) {
    try {
        $AssemblyName = [System.Reflection.AssemblyName]::GetAssemblyName($Import.FullName)
        $Match = $LoadedAssemblies | Where-Object { $_.Name -eq $AssemblyName.Name }
    if (-not $Match) {
        Add-Type -Path $Import.FullName -ErrorAction Stop
    } else {
        Write-Warning "Assembly with name $($Import.Name) is already loaded"
    }
    } catch {
        Write-Error "Processing $($Import.Name), Exception: $($_.Exception.Message)"
        $LoaderExceptions = $($_.Exception.LoaderExceptions) | Sort-Object -Unique
        foreach ($Exception in $LoaderExceptions) {
            Write-Error "Processing $($Import.Name), LoaderExceptions: $($Exception.Message)"
        }
    }
}

# Dot-source import all PowerShell functions
foreach ($Import in @($Private + $Public)) {
    try {
        . $Import.FullName
    } catch {
        Write-Error "Failed to import function [$($Import.FullName)]: $_"
    }
}

# Export public functions as module members
Export-ModuleMember -Function $Public.BaseName