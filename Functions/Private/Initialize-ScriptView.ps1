Set-StrictMode -Version Latest

function Initialize-ScriptView {
    param (
        [object]                        $Ast,
        [System.Windows.Forms.TextBox]  $ScriptView,
        [System.Windows.Forms.TreeView] $TreeView,
        [System.Drawing.Font]           $Font,
        [string]                        $ExtentDetailLevel
    )

    # The script view is a text box that displays the text of the script.
    # If the text box has not been edited, selecting an ast in the tree view
    # will select the matching text in the script view.
    $ScriptView.Font = $Font
    $ScriptView.HideSelection = $false
    $ScriptView.Multiline = $true
    $ScriptView.ScrollBars = 'Both'
    $ScriptView.TabIndex = 2
    $ScriptView.Text = (Add-LineNumber -Text $Ast.Extent.Text -StartLineNumber `
            $Ast.Extent.StartLineNumber -EndLineNumber $Ast.Extent.EndLineNumber)
    $ScriptView.WordWrap = $false
    $ScriptView.Anchor = ([System.Windows.Forms.AnchorStyles]::Top -bor [System.Windows.Forms.AnchorStyles]::Left)
    $ScriptView.Dock = [System.Windows.Forms.DockStyle]::Fill
    $ScriptView.Size = [System.Drawing.Size]::new(200, 400)

    $ScriptView.Add_TextChanged( { $script:BufferIsDirty = $true })
    $ScriptView.Add_KeyUp( {
            param (
                $Sender,
                $KeyEventArg
            )
            OnTextBoxKeyUp -Sender $Sender -KeyEventArg $KeyEventArg -scriptView `
                $ScriptView -TreeView $TreeView -ExtentDetailLevel $ExtentDetailLevel
        })

    $script:BufferIsDirty = $false
}
