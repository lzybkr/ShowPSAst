Set-StrictMode -Version Latest

function Get-ShowPsAstConfig {
    $configFilePath = "$PSScriptRoot\..\..\config.txt"

    if (-not (Test-Path -Path $configFilePath)) {
        return
    }

    $configFromFile = Get-Content -Path $configFilePath -Raw | ConvertFrom-StringData

    $config = [pscustomobject]@{
        FontSize          = 12
        ExtentDetailLevel = 'Normal'
    }

    foreach ($field in $config.psobject.Properties.Name) {
        if ($configFromFile.ContainsKey($field)) {
            $config.$field = $configFromFile[$field]
        }
    }

    [pscustomobject]$config
}
