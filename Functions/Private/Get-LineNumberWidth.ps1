Set-StrictMode -Version Latest

function Get-LineNumberWidth {
    param (
        $TextArray,
        [int] $OriginalStartLineNumber
    )

    ($TextArray.Length + ($OriginalStartLineNumber - 1)).ToString().Length
}
