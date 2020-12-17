Set-StrictMode -Version Latest

function Get-ShowPsAstConfig {
    # Default configuration that can be overridden by a config.txt file
    $config = [pscustomobject]@{
        FontSize          = 12
        ExtentDetailLevel = 'Normal'
    }

    $configFilePath = "$PSScriptRoot\..\..\config.txt"

    if (-not (Test-Path -Path $configFilePath)) {
        return
    }

    $configFromFile = Get-Content -Path $configFilePath -Raw | ConvertFrom-StringData

    foreach ($field in $config.psobject.Properties.Name) {
        if ($configFromFile.ContainsKey($field)) {
            $config.$field = $configFromFile[$field]
        }
    }

    [pscustomobject]$config
}
