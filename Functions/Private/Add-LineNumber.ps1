Set-StrictMode -Version Latest

function Add-LineNumber {
    param (
        [string] $Text,
        [int]    $OriginalStartLineNumber
    )

    $textAsArray = $Text.Clone() -split [System.Environment]::NewLine
    $maxLength = Get-LineNumberWidth -TextArray $textAsArray -OriginalStartLineNumber $OriginalStartLineNumber
    for ($i = 0; $i -lt $textAsArray.Count; $i++) {
        $textAsArray[$i] = "{0,$maxLength}: {1}" -f (($i + $OriginalStartLineNumber)), $textAsArray[$i]
    }

    ($textAsArray -join [System.Environment]::NewLine)
}
