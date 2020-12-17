Set-StrictMode -Version Latest

function Show-Ast {
    [CmdletBinding()]
    param (
        [Parameter()]
        [object] $InputObject,
        [double] $FontSize = $showPsAstConfig.FontSize,
        [ValidateSet('Normal', 'Detailed')]
        [string] $ExtentDetailLevel = $showPsAstConfig.ExtentDetailLevel
    )

    $ast = Get-Ast -InputObject $InputObject

    $script:inputObjectStartOffset = $ast.Extent.StartOffset
    $script:inputObjectStartLineNumber = $ast.Extent.StartLineNumber
    $script:inputObjectEndLineNumber = $ast.Extent.EndLineNumber

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

    Initialize-ScriptView -Ast $ast -ScriptView $scriptView $TreeView $treeView `
        -Font $font -ExtentDetailLevel $ExtentDetailLevel

    Initialize-TreeView -Ast $ast -TreeView $treeView -DataGridView $dataGridView `
        -Font $font -ExtentDetailLevel $ExtentDetailLevel

    try {
        Initialize-Form -Form $form -SplitContainer1 $splitContainer1 -Ast $ast `
            -ExtentDetailLevel $ExtentDetailLevel

        $form.ShowDialog() | Out-Null
    }
    finally {
        $form.Dispose()
    }
}
