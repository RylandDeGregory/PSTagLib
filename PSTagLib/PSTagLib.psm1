Set-StrictMode -Version Latest

# Get public and private function definition files
$Public = @(Get-ChildItem -Path "$PSScriptRoot/Public/*.ps1" -Exclude "*.Tests.*" -ErrorAction SilentlyContinue)
$Private = @(Get-ChildItem -Path "$PSScriptRoot/Private/*.ps1" -Exclude "*.Tests.*" -ErrorAction SilentlyContinue)

# Import all functions
foreach ($Import in @($Public + $Private)) {
    try {
        . $Import.FullName
    }
    catch {
        Write-Error "Failed to import function $($Import.FullName): $_"
    }
}

# Export public functions
Export-ModuleMember -Function $public.BaseName