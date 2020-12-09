Set-StrictMode -Version Latest

function Show-Ast {
    [CmdletBinding()]
    param (
        [Parameter()]
        [object] $InputObject,
        [double] $FontSize = 8.0
    )

    $ast = Get-Ast -InputObject $InputObject

    $font = [System.Drawing.Font]::new('Consolas', $FontSize)
    $form = [Windows.Forms.Form]::new()
    $splitContainer1 = [System.Windows.Forms.SplitContainer]::new()
    $dataGridView = [Windows.Forms.DataGridView]::new()
    $treeView = [System.Windows.Forms.TreeView]::new()
    $splitContainer2 = [System.Windows.Forms.SplitContainer]::new()
    $scriptView = [System.Windows.Forms.TextBox]::new()

    Initialize-SplitContainer1 -SplitContainer1 $splitContainer1 `
        -SplitContainer2 $splitContainer2 -ScriptView $scriptView

    Initialize-SplitContainer2 -SplitContainer2 $splitContainer2 `
        -TreeView $treeView -DataGridView $dataGridView

    Initialize-DataGridView -DataGridView $dataGridView -Font $font

    Initialize-ScriptView -Ast $ast -ScriptView $scriptView $TreeView $treeView -Font $font

    $script:inputObjectStartOffset = $ast.Extent.StartOffset

    Initialize-TreeView -Ast $ast -TreeView $treeView -DataGridView $dataGridView -Font $font

    try {
        Initialize-Form -Form $form -SplitContainer1 $splitContainer1 -InputObject $InputObject

        $form.ShowDialog() | Out-Null
    }
    finally {
        $form.Dispose()
    }
}
