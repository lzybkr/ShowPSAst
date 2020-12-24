Set-StrictMode -Version Latest

<#
.SYNOPSIS
This module helps visualize the PowerShell AST with a graphical view.

.DESCRIPTION
This module helps visualize the PowerShell AST with a graphical view.

The AST is fully expanded in tree view, selecting a node in the tree view will
display the corresponding text in the script and the properties of the node.

If you edit the text in the script view, you can press F5 to refresh the
tree view.

There are default values for FontSize and ExtentDetailLevel. The defaults can be
overridden.

Command line, one time override:
Show-Ast 'c:\Data\PowerShell\sample.ps1' -FontSize 10 -ExtentDetailLevel Detailed

Configuration file, permanent override:
A file named config.txt in the root of the module. The contents should look like
this:

FontSize = 12

# Valid values are:
# Normal   = line numbers only
# Detailed = line numbers, column numbers and offset numbers
ExtentDetailLevel = Normal


.PARAMETER InputObject
Either a scriptblock or a path to a file.

.PARAMETER FontSize
The font size for text. The default is 12 (point).

.PARAMETER ExtentDetailLevel
The level of details displayed for the current AST Extent. This is displayed
in square brackets in the tree view. The default is Normal.

Normal = Line numbers
Detailed = Line numbers, column numbers and offset numbers

.EXAMPLE
Show-Ast -InputObject c:\Data\PowerShell\sample.ps1

Show the AST of a script.

.EXAMPLE
$param @{
    InputObject = 'c:\Data\PowerShell\sample.ps1'
    FontSize = 10
    ExtentDetailLevel = 'Detailed'
}
Show-Ast @params

Show the AST of a script. Customise the font size and extent detail level.


.EXAMPLE
Show-Ast { echo -InputObject "Name is $name" }

Show the AST of a script block.
#>
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

    $paramList = @(
        $ast.Extent.Text,
        $ast.Extent.File,
        $ast.Extent.StartLineNumber,
        $ast.Extent.EndLineNumber,
        $ast.Extent.StartOffset,
        $FontSize,
        $ExtentDetailLevel,
        (Split-Path -Path (Get-PSCallStack)[0].ScriptName -Parent)
    )

    $PowerShell = [PowerShell]::Create()
    $RunSpace = [Runspacefactory]::CreateRunspace()
    $RunSpace.Open()

    $PowerShell.Runspace = $RunSpace

    $null = $PowerShell.AddScript(
        {
            param (
                $InputObject,
                $File,
                $OriginalStartLineNumber,
                $OriginalEndLineNumber,
                $OriginalStartOffset,
                $FontSize,
                $ExtentDetailLevel,
                $ModuleFunctionsPublicPath
            )

            (Get-ChildItem -Path "$ModuleFunctionsPublicPath\..\Private\*.ps1").foreach{
                . $_.FullName
            }

            $ast = Get-Ast -InputObject $InputObject

            [int]$script:inputObjectStartOffset = $ast.Extent.StartOffset
            [int]$script:inputObjectOriginalStartOffset = $OriginalStartOffset
            [int]$script:inputObjectOriginalStartLineNumber = $OriginalStartLineNumber
            [int]$script:inputObjectStartLineNumber = $ast.Extent.StartLineNumber
            [int]$script:inputObjectOriginalEndLineNumber = $OriginalEndLineNumber
            [int]$script:inputObjectEndLineNumber = $ast.Extent.EndLineNumber
            $script:BufferIsDirty = $true
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
                -OriginalStartLineNumber $OriginalStartLineNumber `
                -OriginalEndLineNumber $OriginalEndLineNumber

            Initialize-TreeView `
                -Ast $ast `
                -TreeView $treeView `
                -DataGridView $dataGridView `
                -ScriptView $scriptView `
                -Font $font `
                -ExtentDetailLevel $ExtentDetailLevel `
                -BufferIsDirty $script:BufferIsDirty `
                -OriginalStartLineNumber $OriginalStartLineNumber `
                -OriginalStartOffset $OriginalStartOffset

            $script:BufferIsDirty = $false

            try {
                Initialize-Form -Form $form -SplitContainer1 $splitContainer1 -File "$File"

                $form.ShowDialog() | Out-Null
            }
            catch {
                throw
            }
            finally {
                $form.Dispose()
            }

        }
    ).AddParameters($paramList)

    $null = Register-ObjectEvent -InputObject $PowerShell -EventName InvocationStateChanged -Action {
        param([System.Management.Automation.PowerShell] $ps)

        $state = $EventArgs.InvocationStateInfo.State
        $reason = $EventArgs.InvocationStateInfo.Reason

        if ($state -in 'Completed', 'Failed') {
            if ($state -eq 'Failed') {
                Write-Host "Failed: $reason"
            }

            $ps.Runspace.Dispose()

            $EventSubscriber | Unregister-Event -Force
        }
    }

    $asyncResult = $PowerShell.BeginInvoke()
}
