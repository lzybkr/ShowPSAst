Set-StrictMode -Version Latest

function Initialize-Form {
    param (
        [Windows.Forms.Form]                  $Form,
        [System.Windows.Forms.SplitContainer] $SplitContainer1,
        [object]                              $InputObject
    )

    $text = [string]$InputObject
    $filePath = ' - ' + ((Test-Path -LiteralPath $text) ? (Resolve-Path $text) : '')

    $Form.ClientSize = [System.Drawing.Size]::new(1200, 700)
    $Form.Controls.Add($splitContainer1)
    $Form.Name = 'Form1'
    $Form.Text = 'AST Explorer' + $filePath
}