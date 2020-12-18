Set-StrictMode -Version Latest

function Initialize-Form {
    param (
        [Windows.Forms.Form]                        $Form,
        [System.Windows.Forms.SplitContainer]       $SplitContainer1,
        [System.Management.Automation.Language.Ast] $Ast
    )

    $filePath = if ([string]::IsNullOrWhiteSpace($Ast.Extent.File)) {
        ''
    }
    else {
        " - {0}" -f $Ast.Extent.File
    }

    $Form.ClientSize = [System.Drawing.Size]::new(1200, 700)
    $Form.Controls.Add($splitContainer1)
    $Form.Name = 'Form1'
    $Form.Text = 'AST Explorer' + $filePath
}
