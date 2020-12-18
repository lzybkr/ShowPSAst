Set-StrictMode -Version Latest

# A function when the text box has focus - so we can refresh the Ast
# when asked (by pressing F5).
function OnTextBoxKeyUp {
    param(
        [System.Windows.Forms.TextBox]  $Sender,
        [System.EventArgs]              $KeyEventArg,
        [System.Windows.Forms.TreeView] $TreeView,
        [string]                        $ExtentDetailLevel,
        [int]                           $OriginalStartLinenumber,
        [int]                           $OriginalEndLineNumber,
        [int]                           $OriginalStartOffset
    )1

    if ($KeyEventArg.KeyCode -eq 'F5' -and $KeyEventArg.Alt -eq $false -and
        $KeyEventArg.Control -eq $false -and $KeyEventArg.Shift -eq $false) {

        $KeyEventArg.Handled = $true
        $script:BufferIsDirty = $true

        # Remove line numbers
        $textNoLineNumbers = ($Sender.Text -split "`r`n").foreach( {
                $_ -replace '^\s*[0-9]+: (.*)', '$1'
            }) -join "`r`n"

        $Ast = [System.Management.Automation.Language.Parser]::ParseInput($textNoLineNumbers, [ref]$null, [ref]$null)
        $script:inputObjectStartLineNumber = $Ast.Extent.StartLineNumber
        $script:inputObjectEndLineNumber = $Ast.Extent.EndLineNumber
        $TreeView.Nodes.Clear()

        # Add line numbers
        $Sender.Text = (Add-LineNumber -Text $ast.Extent.Text `
                -OriginalStartLineNumber $OriginalStartLinenumber `
                -OriginalEndLineNumber $OriginalEndLineNumber)

        AddChildNode `
            -Child $Ast `
            -NodeList $TreeView.Nodes `
            -ExtentDetailLevel $ExtentDetailLevel `
            -OriginalStartLineNumber $OriginalStartLinenumber `
            -OriginalStartOffset $OriginalStartOffset `
            -BufferIsDirty $script:BufferIsDirty

        $script:BufferIsDirty = $false
        $script:inputObjectStartOffset = 0
    }
}
