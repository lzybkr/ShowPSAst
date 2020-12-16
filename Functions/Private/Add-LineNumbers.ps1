Set-StrictMode -Version Latest

function Add-LineNumber {
    param (
        [string] $Text,
        [int]    $StartLineNumber,
        [int]    $EndLineNumber
    )

    $textAsArray = $Text.Clone() -split [System.Environment]::NewLine
    $maxLength = $EndLineNumber.ToString().Length
    for ($i = 0; $i -lt $textAsArray.Count; $i++) {
        $textAsArray[$i] = "{0,$maxLength}: {1}" -f (($i + $StartLineNumber)), $textAsArray[$i]
    }

    ($textAsArray -join [System.Environment]::NewLine)
}
