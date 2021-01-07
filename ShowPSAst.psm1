Set-StrictMode -Version Latest

Add-Type -Assembly System.Windows.Forms

$ErrorActionPreference = 'Stop'

#Get public and private function definition files.
$public = @( Get-ChildItem -Path "$PSScriptRoot\Functions\Public\*.ps1" -Recurse -ErrorAction SilentlyContinue )
$private = @( Get-ChildItem -Path "$PSScriptRoot\Functions\Private\*.ps1" -Recurse -ErrorAction SilentlyContinue )

#Dot source the files
Foreach ($import in @($public + $private)) {
    Try {
        . $import.fullname
    }
    Catch {
        Write-Error -Message "Failed to import function $($import.fullname): $_"
    }
}

Export-ModuleMember -Function $public.Basename
