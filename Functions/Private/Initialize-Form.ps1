Set-StrictMode -Version Latest

function Initialize-Form {
    param (
        [Windows.Forms.Form]                        $Form,
        [System.Windows.Forms.SplitContainer]       $SplitContainer1,
        [string]                                    $File
    )

    $filePath = if ([string]::IsNullOrWhiteSpace($File)) {
        ''
    }
    else {
        " - {0}" -f $File
    }

    $Form.ClientSize = [System.Drawing.Size]::new(1200, 700)
    $Form.Controls.Add($splitContainer1)
    $Form.Name = 'Form1'
    $Form.Text = 'AST Explorer' + $filePath
}
