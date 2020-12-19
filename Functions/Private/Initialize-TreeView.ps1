Set-StrictMode -Version Latest

function Initialize-TreeView {
    param (
        [System.Management.Automation.Language.Ast] $Ast,
        [System.Windows.Forms.TreeView]             $TreeView,
        [System.Windows.Forms.DataGridView]         $DataGridView,
        [System.Windows.Forms.TextBox]              $ScriptView,
        [System.Drawing.Font]                       $Font,
        [string]                                    $ExtentDetailLevel,
        [bool]                                      $BufferIsDirty,
        [int]                                       $OriginalStartLinenumber,
        [int]                                       $OriginalStartOffset
    )

    $TreeView.Dock = [System.Windows.Forms.DockStyle]::Fill
    $TreeView.ForeColor = [System.Drawing.SystemColors]::InfoText
    $TreeView.ImageIndex = -1
    $TreeView.Location = [System.Drawing.Point]::new(0, 0)
    $TreeView.Name = 'treeView'
    $TreeView.SelectedImageIndex = -1
    $TreeView.Size = [System.Drawing.Size]::new(79, 273)
    $TreeView.TabIndex = 1
    $TreeView.Font = $Font
    $TreeView.Add_AfterSelect(
        {
            param (
                [object] $Sender,
                [System.Windows.Forms.TreeViewEventArgs] $E
            )
            Invoke-TreeViewAfterSelect -Sender $Sender -E $E `
                -DataGridView $DataGridView `
                -ScriptView $ScriptView `
                -StartOffset $script:inputObjectStartOffset `
                -StartLinenumber $script:inputObjectStartLineNumber `
                -OriginalStartLineNumber $script:inputObjectOriginalStartLineNumber `
                -OriginalEndLineNumber $script:inputObjectOriginalEndLineNumber `
                -BufferIsDirty $script:BufferIsDirty
        }
    )

    AddChildNode `
        -Child $Ast `
        -NodeList $TreeView.Nodes `
        -ExtentDetailLevel $ExtentDetailLevel `
        -OriginalStartLineNumber $OriginalStartLinenumber `
        -OriginalStartOffset $OriginalStartOffset `
        -BufferIsDirty $BufferIsDirty
}
