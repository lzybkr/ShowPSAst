Set-StrictMode -Version Latest

function Get-ShowPsAstConfig {
    [CmdletBinding()]
    param (
        [double] $FontSize,
        [string] $ExtentDetailLevel
    )

    # Default configuration
    $config = [pscustomobject]@{
        FontSize          = 12
        ExtentDetailLevel = 'Normal'
    }

    # Override defaults by config file
    $configFilePath = "$PSScriptRoot\..\..\config.txt"

    if (Test-Path -Path $configFilePath) {
        $configFromFile = Get-Content -Path $configFilePath -Raw |
            ConvertFrom-StringData

        Set-ShowPSAstConfig -Source $configFromFile -Destination $config
    }

    # Override defaults/config file by parameters
    Set-ShowPSAstConfig -Source $PSBoundParameters -Destination $config

    [pscustomobject]$config
}
