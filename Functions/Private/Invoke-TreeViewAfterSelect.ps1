Set-StrictMode -Version Latest

function Invoke-TreeViewAfterSelect {
    param(
        [object]                                 $Sender,
        [System.Windows.Forms.TreeViewEventArgs] $E,
        [System.Windows.Forms.DataGridView]      $DataGridView
    )

    $DataGridView.Rows.Clear()
    $selectedObject = $E.Node.Tag

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
            $value = "{0} ({1},{2})-({3},{4})" -f
            $file, $value.StartLineNumber, $value.StartColumnNumber, $value.EndLineNumber, $value.EndColumnNumber
        }
        $DataGridView.Rows.Add($property.Name, $value, $typeName)
    }

    # If the text box has changed, skip doing anything with it until we've updated the tree view.
    if (!$script:BufferIsDirty) {
        $startOffset = $selectedObject.Extent.StartOffset - $script:inputObjectStartOffset
        $endOffset = $selectedObject.Extent.EndOffset - $script:inputObjectStartOffset
        $maxLength = ($scriptView.Text -split "`r`n").Count.ToString().Length + 2
        $numberOfLines = ($selectedObject.Extent.EndLineNumber - $selectedObject.Extent.StartLineNumber) + 1
        $selectionLength = if ($numberOfLines -eq 1) {
            $endOffset - $startOffset
        }
        else {
            ($endOffset - $startOffset) + ($maxLength * ($numberOfLines - 1))
        }

        $scriptView.SelectionStart = $startOffset + ($selectedObject.Extent.StartLineNumber * $maxLength)
        $scriptView.SelectionLength = $selectionLength
        $scriptView.ScrollToCaret()
    }
}
