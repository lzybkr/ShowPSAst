Set-StrictMode -Version Latest

function Invoke-TreeViewAfterSelect {
    param(
        [System.Windows.Forms.TreeView]          $TreeView,
        [System.Windows.Forms.TreeViewEventArgs] $TreeViewEventArg,
        [System.Windows.Forms.DataGridView]      $DataGridView,
        [System.Windows.Forms.TextBox]           $ScriptView,
        [int]                                    $StartOffset,
        [int]                                    $StartLineNumber,
        [int]                                    $OriginalStartLineNumber,
        [bool]                                   $BufferIsDirty,
        [bool]                                   $TextBoxRefreshed
    )

    $DataGridView.Rows.Clear()
    $selectedObject = $TreeViewEventArg.Node.Tag

    foreach ($property in $selectedObject.PSObject.Properties) {
        $typeName = [Microsoft.PowerShell.ToStringCodeMethods]::Type([type]$property.TypeNameOfValue)
        if ($typeName -match '.*ReadOnlyCollection\[(.*)\]') {
            # Lie about the type to make the display shorter
            $typeName = $matches[1] + '[]'
        }
        # Remove the namespace
        $typeName = $typeName -replace '.*\.', ''
        $value = $property.Value
        if ($typeName -eq 'IScriptExtent') {
            $file = if ($value.File -eq $null) {
                ""
            }
            else {
                Split-Path -Leaf $value.File
            }

            if ($TextBoxRefreshed) {
                $calculatedStartLineNumber =  ($value.StartLineNumber + $OriginalStartLineNumber) - 1
                $calculatedEndLineNumber =  ($value.EndLineNumber + $OriginalStartLineNumber) - 1
            }
            else {
                $calculatedStartLineNumber =  $value.StartLineNumber
                $calculatedEndLineNumber =  $value.EndLineNumber
            }

            $value = "{0} ({1},{2})-({3},{4})" -f
            $file, $calculatedStartLineNumber, $value.StartColumnNumber, $calculatedEndLineNumber, $value.EndColumnNumber
        }
        $DataGridView.Rows.Add($property.Name, $value, $typeName)
    }

    # If the text box has changed, skip doing anything with it until we've updated the tree view.
    if (!$BufferIsDirty) {
        $selectedStartOffset = $selectedObject.Extent.StartOffset - $StartOffset
        $endOffset = $selectedObject.Extent.EndOffset - $StartOffset
        $maxLength = (Get-LineNumberWidth -TextArray $ScriptView.Lines -OriginalStartLineNumber $OriginalStartLineNumber) + 2
        $numberOfLines = ($selectedObject.Extent.EndLineNumber - $selectedObject.Extent.StartLineNumber) + 1
        $selectionLength = if ($numberOfLines -eq 1) {
            $endOffset - $selectedStartOffset
        }
        else {
            ($endOffset - $selectedStartOffset) + ($maxLength * ($numberOfLines - 1))
        }

        $scriptView.SelectionStart = $selectedStartOffset + ((($selectedObject.Extent.StartLineNumber - $StartLineNumber) + 1) * $maxLength)
        $scriptView.SelectionLength = $selectionLength
        $scriptView.ScrollToCaret()
    }
}
