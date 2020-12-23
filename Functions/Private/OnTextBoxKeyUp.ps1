Set-StrictMode -Version Latest

function OnTextBoxKeyUp {
    param(
        [System.Windows.Forms.TextBox]  $TextBox,
        [System.EventArgs]              $KeyEventArg,
        [System.Windows.Forms.TreeView] $TreeView,
        [string]                        $ExtentDetailLevel,
        [int]                           $OriginalStartLinenumber,
        [int]                           $OriginalEndLineNumber,
        [int]                           $OriginalStartOffset
    )

    function GetNode([System.Windows.Forms.TreeNodeCollection] $nodes) {
        foreach ($n in $nodes) {
            $n
            GetNode($n.Nodes)
        }
    }

    # A function when the text box has focus - so we can refresh the Ast
    # when asked (by pressing F5).
    if ($KeyEventArg.KeyCode -eq 'F5' -and $KeyEventArg.Alt -eq $false -and
        $KeyEventArg.Control -eq $false -and $KeyEventArg.Shift -eq $false) {

        $KeyEventArg.Handled = $true
        $script:BufferIsDirty = $true
        $script:TextBoxRefreshed = $true

        # Remove line numbers
        $textNoLineNumbers = ($TextBox.Text -split "`r`n").foreach( {
                $_ -replace '^\s*[0-9]+: (.*)', '$1'
            }) -join "`r`n"

        $Ast = [System.Management.Automation.Language.Parser]::ParseInput($textNoLineNumbers, [ref]$null, [ref]$null)
        $script:inputObjectStartLineNumber = $Ast.Extent.StartLineNumber
        $script:inputObjectEndLineNumber = $Ast.Extent.EndLineNumber
        $TreeView.Nodes.Clear()

        # Add line numbers
        $TextBox.Text = (Add-LineNumber -Text $ast.Extent.Text `
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

    # Find/highlight line in treeview
    if ($KeyEventArg.KeyCode -eq 'F3' -and $KeyEventArg.Alt -eq $false -and
        $KeyEventArg.Control -eq $false -and $KeyEventArg.Shift -eq $false) {

        $KeyEventArg.Handled = $true

        $nodes = GetNode($TreeView.Nodes)

        $selectionStartLineNumber = $TextBox.GetLineFromCharIndex($TextBox.SelectionStart)
        $selectionLineNumber = ($OriginalStartLinenumber + $selectionStartLineNumber) #-1

        $nodes.Where( {$_.Text -like "*[[]$selectionLineNumber,*"}) |
            Select-Object -First 1 | ForEach-Object -Process {
                $TreeView.SelectedNode = $_
                $_.EnsureVisible()
                $TreeView.Focus()
            }
    }
}
