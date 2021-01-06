Set-StrictMode -Version Latest

function Set-ShowPsAstConfig {
    param (
        $Source,
        $Destination
    )

    $propertyNames = $Destination.psobject.Properties.ForEach{$_.Name}

    foreach ($configPropertyName in $propertyNames) {
        if ($Source.ContainsKey($configPropertyName)) {
            if (
                ([string]::IsNullOrWhiteSpace($Source.$configPropertyName) -eq $false) -and
                ($Source.$configPropertyName -ne 0)
            ) {
                $Destination.$configPropertyName = $Source.$configPropertyName
            }
        }
    }
}
