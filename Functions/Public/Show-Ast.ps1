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

    [int]$script:inputObjectStartOffset = $ast.Extent.StartOffset
    [int]$script:inputObjectOriginalStartOffset = $ast.Extent.StartOffset
    [int]$script:inputObjectOriginalStartLineNumber = $ast.Extent.StartLineNumber
    [int]$script:inputObjectStartLineNumber = $ast.Extent.StartLineNumber
    [int]$script:inputObjectOriginalEndLineNumber = $ast.Extent.EndLineNumber
    [int]$script:inputObjectEndLineNumber = $ast.Extent.EndLineNumber
    $script:BufferIsDirty = $false
    $script:TextBoxRefreshed = $false

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
        -Font $font -ExtentDetailLevel $ExtentDetailLevel `
        -OriginalStartLineNumber $ast.Extent.StartLineNumber `
        -OriginalEndLineNumber $ast.Extent.EndLineNumber

    Initialize-TreeView `
        -Ast $ast `
        -TreeView $treeView `
        -DataGridView $dataGridView `
        -ScriptView $scriptView `
        -Font $font `
        -ExtentDetailLevel $ExtentDetailLevel `
        -BufferIsDirty $script:BufferIsDirty `
        -OriginalStartLineNumber $ast.Extent.StartLineNumber `
        -OriginalStartOffset $ast.Extent.StartOffset

    try {
        Initialize-Form -Form $form -SplitContainer1 $splitContainer1 -Ast $ast

        $form.ShowDialog() | Out-Null
    }
    finally {
        $form.Dispose()
    }
}
