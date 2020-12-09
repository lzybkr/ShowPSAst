Set-StrictMode -Version Latest

# A function when the text box has focus - so we can refresh the Ast
# when asked (by pressing F5).
function OnTextBoxKeyUp {
    param(
        $Sender,
        $KeyEventArg,
        $ScriptView,
        $TreeView
    )

    if ($KeyEventArg.KeyCode -eq 'F5' -and $KeyEventArg.Alt -eq $false -and
        $KeyEventArg.Control -eq $false -and $KeyEventArg.Shift -eq $false) {
        $KeyEventArg.Handled = $true

        # Remove line numbers
        $textNoLineNumbers = ($ScriptView.Text -split "`r`n").foreach( {
                $_ -replace '^\s*[0-9]+: (.*)', '$1'
            }) -join "`r`n"

        $Ast = [System.Management.Automation.Language.Parser]::ParseInput($textNoLineNumbers, [ref]$null, [ref]$null)
        $TreeView.Nodes.Clear()

        # Add line numbers
        # $textWithLineNumbers = $ast.Extent.Text.Clone() -split "`r`n"
        # $maxLength = $textWithLineNumbers.Count.ToString().Length
        # for ($i = 0; $i -lt $textWithLineNumbers.Count; $i++) {
        #     $textWithLineNumbers[$i] = "{0,$maxLength}: {1}" -f ($i + 1), $textWithLineNumbers[$i]
        # }
        $ScriptView.Text = (Add-LineNumber -Text $ast.Extent.Text)
        # $ScriptView.Text = ($textWithLineNumbers -join "`r`n")

        AddChildNode $Ast $TreeView.Nodes
        $script:BufferIsDirty = $false
        $script:inputObjectStartOffset = 0
    }
}
