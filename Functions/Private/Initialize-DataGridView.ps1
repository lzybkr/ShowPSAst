Set-StrictMode -Version Latest

function Initialize-DataGridView {
    param (
        [System.Windows.Forms.DataGridView] $DataGridView,
        [System.Drawing.Font]               $Font
    )

    # Data view shows properties of the selected Ast in table form
    $DataGridView.AllowUserToAddRows = $false
    $DataGridView.AllowUserToDeleteRows = $false
    $DataGridView.AllowUserToResizeRows = $false
    $DataGridView.AutoSizeColumnsMode = [System.Windows.Forms.DataGridViewAutoSizeColumnsMode]::Fill
    $DataGridView.AutoSizeRowsMode = [System.Windows.Forms.DataGridViewAutoSizeRowsMode]::AllCells
    $DataGridView.ColumnHeadersVisible = $true
    $DataGridView.Font = $Font
    $DataGridView.ReadOnly = $true;
    $DataGridView.RowHeadersVisible = $false
    $DataGridView.SelectionMode = [System.Windows.Forms.DataGridViewSelectionMode]::FullRowSelect
    $DataGridView.TabIndex = 1
    $DataGridView.Anchor = ([System.Windows.Forms.AnchorStyles]::Top -bor [System.Windows.Forms.AnchorStyles]::Left)
    $DataGridView.Dock = [System.Windows.Forms.DockStyle]::Fill
    $DataGridView.Size = [System.Drawing.Size]::new(200, 300)
    $DataGridView.Columns.AddRange(
        [System.Windows.Forms.DataGridViewTextBoxColumn]@{
            HeaderText   = 'Property'
            ReadOnly     = $true
            Resizable    = [System.Windows.Forms.DataGridViewTriState]::True
            AutoSizeMode = [System.Windows.Forms.DataGridViewAutoSizeColumnMode]::AllCellsExceptHeader

        },
        [System.Windows.Forms.DataGridViewTextBoxColumn]@{
            HeaderText   = 'Value'
            ReadOnly     = $true
            Resizable    = [System.Windows.Forms.DataGridViewTriState]::True
            AutoSizeMode = [System.Windows.Forms.DataGridViewAutoSizeColumnMode]::Fill
        },
        [System.Windows.Forms.DataGridViewTextBoxColumn]@{
            HeaderText   = 'Type'
            ReadOnly     = $true
            Resizable    = [System.Windows.Forms.DataGridViewTriState]::True
            AutoSizeMode = [System.Windows.Forms.DataGridViewAutoSizeColumnMode]::AllCellsExceptHeader
        }
    )
}
