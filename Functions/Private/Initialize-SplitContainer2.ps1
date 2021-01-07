Set-StrictMode -Version Latest

function Initialize-SplitContainer2 {
    param (
        [System.Windows.Forms.SplitContainer] $SplitContainer2,
        [System.Windows.Forms.TreeView]       $TreeView,
        [System.Windows.Forms.DataGridView]   $DataGridView
    )

    # Basic SplitContainer properties.
    # This is a horizontal splitter whose top and bottom panels are ListView controls. The top panel is fixed.
    $splitContainer2.Dock = [System.Windows.Forms.DockStyle]::Fill
    # The top panel remains the same size when the form is resized.
    $splitContainer2.FixedPanel = [System.Windows.Forms.FixedPanel]::Panel2
    $splitContainer2.Location = [System.Drawing.Point]::new(0, 0)
    $splitContainer2.Name = 'splitContainer2'
    # Create the horizontal splitter.
    $splitContainer2.Orientation = [System.Windows.Forms.Orientation]::Horizontal
    $splitContainer2.Size = [System.Drawing.Size]::new(207, 350)
    # $splitContainer2.SplitterDistance = 125
    # $splitContainer2.SplitterWidth = 6
    # splitContainer2 is the third control in the tab order.
    $splitContainer2.TabIndex = 2
    $splitContainer2.Text = 'splitContainer2'

    # This splitter panel contains the top ListView control.
    $splitContainer2.Panel1.Controls.Add($TreeView)
    $splitContainer2.Panel1.Name = 'splitterPanel3'

    # This splitter panel contains the bottom ListView control.
    $splitContainer2.Panel2.Controls.Add($DataGridView)
    $splitContainer2.Panel2.Name = 'splitterPanel4'
}
