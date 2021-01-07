Set-StrictMode -Version Latest

function Initialize-SplitContainer1 {
    param (
        [System.Windows.Forms.SplitContainer] $SplitContainer1,
        [System.Windows.Forms.SplitContainer] $SplitContainer2,
        [System.Windows.Forms.TextBox]        $ScriptView
    )

    $SplitContainer1.Dock = [System.Windows.Forms.DockStyle]::Fill
    $splitContainer1.FixedPanel = [System.Windows.Forms.FixedPanel]::Panel1
    $SplitContainer1.Location = [System.Drawing.Point]::new(0, 0)
    $SplitContainer1.Name = 'splitContainer1'
    $SplitContainer1.Size = [System.Drawing.Size]::new(600, 419)
    $SplitContainer1.SplitterDistance = 2400
    $SplitContainer1.TabIndex = 0
    $SplitContainer1.Text = 'splitContainer1'

    $SplitContainer1.Panel1.BackColor = [System.Drawing.SystemColors]::Control
    $SplitContainer1.Panel1.Controls.Add($SplitContainer2)
    $SplitContainer1.Panel1.Name = 'splitterPanel1'
    $SplitContainer1.Panel1.RightToLeft = [System.Windows.Forms.RightToLeft]::No

    $SplitContainer1.Panel2.Controls.Add($ScriptView)
    $SplitContainer1.Panel2.Name = 'splitterPanel2'
}
