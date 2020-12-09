Set-StrictMode -Version Latest

function Add-LineNumber {
    param (
        [string] $Text
    )

    $textAsArray = $Text.Clone() -split [System.Environment]::NewLine
    $maxLength = $textAsArray.Count.ToString().Length
    for ($i = 0; $i -lt $textAsArray.Count; $i++) {
        $textAsArray[$i] = "{0,$maxLength}: {1}" -f ($i + 1), $textAsArray[$i]
    }

    ($textAsArray -join [System.Environment]::NewLine)
}
