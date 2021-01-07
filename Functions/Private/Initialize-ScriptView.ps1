Set-StrictMode -Version Latest

function Initialize-ScriptView {
    param (
        [System.Management.Automation.Language.Ast] $Ast,
        [System.Windows.Forms.TextBox]              $ScriptView,
        [System.Windows.Forms.TreeView]             $TreeView,
        [System.Drawing.Font]                       $Font,
        [string]                                    $ExtentDetailLevel,
        [int]                                       $OriginalStartLineNumber,
        [int]                                       $OriginalEndLineNumber
    )

    # The script view is a text box that displays the text of the script.
    # If the text box has not been edited, selecting an ast in the tree view
    # will select the matching text in the script view.
    $ScriptView.Font = $Font
    $ScriptView.HideSelection = $false
    $ScriptView.Multiline = $true
    $ScriptView.ScrollBars = 'Both'
    $ScriptView.TabIndex = 2
    $ScriptView.Text = (Add-LineNumber -Text $Ast.Extent.Text `
            -OriginalStartLineNumber $OriginalStartLineNumber `
            -OriginalEndLineNumber $OriginalEndLineNumber)
    $ScriptView.WordWrap = $false
    $ScriptView.Anchor = ([System.Windows.Forms.AnchorStyles]::Top -bor [System.Windows.Forms.AnchorStyles]::Left)
    $ScriptView.Dock = [System.Windows.Forms.DockStyle]::Fill
    $ScriptView.Size = [System.Drawing.Size]::new(200, 400)

    $ScriptView.Add_TextChanged( { $script:BufferIsDirty = $true })
    $ScriptView.Add_KeyUp( {
            param (
                $SenderTextBox,
                $KeyEventArg
            )
            OnTextBoxKeyUp `
                -TextBox $SenderTextBox `
                -KeyEventArg $KeyEventArg `
                -TreeView $TreeView `
                -ExtentDetailLevel $ExtentDetailLevel `
                -OriginalStartLineNumber $script:inputObjectOriginalStartLineNumber `
                -OriginalEndLineNumber $script:inputObjectOriginalEndLineNumber `
                -OriginalStartOffset $script:inputObjectOriginalStartOffset
        })
}
