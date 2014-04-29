
#
# .SYNOPSIS
#
#     Provides a graphical interface to explore PowerShell AST.
#
# .EXAMPLE
#
#     PS> $ast = { if (Test-Path $profile) { echo "Profile exists" } }.Ast
#     PS> Show-Ast $ast
# 
function Show-Ast
{
    param(
        ## The object to examine
        [Parameter(ValueFromPipeline = $true)]
        $InputObject
    )

    process
    {
        Set-StrictMode -Version 3

        Add-Type -Assembly System.Windows.Forms

        $font = New-Object System.Drawing.Font ("Consolas", 12.0)

        # This a helper function to recursively walk the tree
        # and add all children to the given node list.
        function AddChildNode($child, $nodeList)
        {
            # A function to add an object to the display tree
            function PopulateNode($object, $nodeList)
            {
                foreach ($child in $object.PSObject.Properties)
                {
                    # Skip the Parent node, it's not useful here
                    if ($child.Name -eq 'Parent') { continue }

                    $childObject = $child.Value
        
                    if ($null -eq $childObject) { continue }

                    # Recursively add only Ast nodes.
                    if ($childObject -is [System.Management.Automation.Language.Ast])
                    {
                        AddChildNode $childObject $nodeList
                        continue
                    }

                    # Several Ast properties are collections of Ast, add them all
                    # as children of the current node.
                    $collection = $childObject -as [System.Management.Automation.Language.Ast[]]
                    if ($collection -ne $null)
                    {
                        for ($i = 0; $i -lt $collection.Length; $i++)
                        {
                            AddChildNode ($collection[$i]) $nodeList
                        }
                        continue
                    }

                    # A little hack for IfStatementAst and SwitchStatementAst - they have a collection
                    # of tuples of Ast.  Both items in the tuple are an Ast, so we want to recurse on both.
                    if ($childObject.GetType().FullName -match 'ReadOnlyCollection.*Tuple`2.*Ast.*Ast')
                    {
                        for ($i = 0; $i -lt $childObject.Count; $i++)
                        {
                            AddChildNode ($childObject[$i].Item1) $nodeList
                            AddChildNode ($childObject[$i].Item2) $nodeList
                        }
                        continue
                    }
                }
            }

            # Create the new node to add with the node text of the item type and extent
            $childNode = [Windows.Forms.TreeNode]@{
                Text = $child.GetType().Name + (" [{0},{1})" -f $child.Extent.StartOffset,$child.Extent.EndOffset)
                Tag = $child
            }
            $null = $nodeList.Add($childNode)

            # Recursively add the current nodes children
            PopulateNode $child $childNode.Nodes

            # We want the tree fully expanded after construction
            $childNode.Expand()
        }

        # A function invoked when a node in the tree view is selected.
        function OnAfterSelect
        {
            param($Sender, $TreeViewEventArgs)

            $dataView.Rows.Clear()
            $selectedObject = $TreeViewEventArgs.Node.Tag

            foreach ($property in $selectedObject.PSObject.Properties)
            {
                $typeName = [Microsoft.PowerShell.ToStringCodeMethods]::Type([type]$property.TypeNameOfValue)
                if ($typeName -match '.*ReadOnlyCollection\[(.*)\]')
                {
                    # Lie about the type to make the display shorter
                    $typeName = $matches[1] + '[]'
                }
                # Remove the namespace
                $typeName = $typeName -replace '.*\.',''
                $value = $property.Value
                if ($typeName -eq 'IScriptExtent')
                {
                    $file = if ($value.File -eq $null) { "" } else { Split-Path -Leaf $value.File }
                    $value = "{0} ({1},{2})-({3},{4})" -f
                        $file, $value.StartLineNumber, $value.StartColumnNumber, $value.EndLineNumber, $value.EndColumnNumber
                }
                $dataView.Rows.Add($property.Name, $value, $typeName)
            }

            # If the text box has changed, skip doing anything with it until we've updated the tree view.
            if (!$script:BufferIsDirty)
            {
                $startOffset = $selectedObject.Extent.StartOffset - $script:inputObjectStartOffset
                $endOffset = $selectedObject.Extent.EndOffset - $script:inputObjectStartOffset
                $scriptView.SelectionStart = $startOffset
                $scriptView.SelectionLength = $endOffset - $startOffset
                $scriptView.ScrollToCaret()
            }
        }

        # A function when the text box has focus - so we can refresh the Ast
        # when asked (by pressing F5).
        function OnTextBoxKeyUp
        {
            param($Sender, $KeyEventArgs)

            if ($KeyEventArgs.KeyCode -eq 'F5' -and $KeyEventArgs.Alt -eq $false -and
                $KeyEventArgs.Control -eq $false -and $KeyEventArgs.Shift -eq $false)
            {
                $KeyEventArgs.Handled = $true

                $Ast = [System.Management.Automation.Language.Parser]::ParseInput($scriptView.Text, [ref]$null, [ref]$null)
                $script:BufferIsDirty = $false
                $treeView.Nodes.Clear()

                AddChildNode $Ast $treeView.Nodes
                $script:inputObjectStartOffset = 0
            }
        }

        # Create the TreeView for the Ast
        $treeView = [Windows.Forms.TreeView]@{
            Location = [System.Drawing.Point]@{X = 12; Y = 12}
            Size = [System.Drawing.Size]@{Width = 600; Height = 400}
            Font = $font
            TabIndex = 0;
            PathSeparator = "."
        }
        $treeView.Add_AfterSelect( { OnAfterSelect @args } )

        # Create the root node for the Ast
        if ($InputObject -is [scriptblock])
        {
            $InputObject = $InputObject.Ast
        }
        elseif ($InputObject -is [System.Management.Automation.FunctionInfo] -or
                $InputObject -is [System.Management.Automation.ExternalScriptInfo])
        {
            $InputObject = $InputObject.ScriptBlock.Ast
        }
        elseif ($InputObject -isnot [System.Management.Automation.Language.Ast])
        {
            $text = [string]$InputObject
            if (Test-Path -LiteralPath $text)
            {
                $path = Resolve-Path $text
                $InputObject = [System.Management.Automation.Language.Parser]::ParseFile($path.ProviderPath, [ref]$null, [ref]$null)
            }
            else
            {
                $InputObject = [System.Management.Automation.Language.Parser]::ParseInput($text, [ref]$null, [ref]$null)
            }
        }
        AddChildNode $InputObject $treeView.Nodes

        # Data view shows properties of the selected Ast in table form
        $dataView = [Windows.Forms.DataGridView]@{
            AllowUserToAddRows = $false
            AllowUserToDeleteRows = $false
            AllowUserToResizeRows = $false
            AutoSizeColumnsMode = [System.Windows.Forms.DataGridViewAutoSizeColumnsMode]::Fill
            AutoSizeRowsMode = [System.Windows.Forms.DataGridViewAutoSizeRowsMode]::AllCells
            ColumnHeadersHeightSizeMode = [System.Windows.Forms.DataGridViewColumnHeadersHeightSizeMode]::AutoSize
            ColumnHeadersVisible = $true
            Font = $font
            Location = [System.Drawing.Point]@{X = 12; Y = 424}
            ReadOnly = $true;
            RowHeadersVisible = $false
            SelectionMode = [System.Windows.Forms.DataGridViewSelectionMode]::FullRowSelect
            Size = [System.Drawing.Size]@{Width = 600; Height = 256}
            TabIndex = 1
        }
        $dataView.Columns.AddRange(
            [System.Windows.Forms.DataGridViewTextBoxColumn]@{
                HeaderText = 'Property'        
                ReadOnly = $true
                AutoSizeMode = [System.Windows.Forms.DataGridViewAutoSizeColumnMode]::AllCellsExceptHeader},
            [System.Windows.Forms.DataGridViewTextBoxColumn]@{
                HeaderText = 'Value'
                ReadOnly = $true
                Resizable = [System.Windows.Forms.DataGridViewTriState]::True
                AutoSizeMode = [System.Windows.Forms.DataGridViewAutoSizeColumnMode]::Fill},
            [System.Windows.Forms.DataGridViewTextBoxColumn]@{
                HeaderText = 'Type'
                ReadOnly = $true
                AutoSizeMode = [System.Windows.Forms.DataGridViewAutoSizeColumnMode]::AllCellsExceptHeader
        })

        # The script view is a text box that displays the text of the script.
        # If the text box has not been edited, selecting an ast in the tree view
        # will select the matching text in the script view.
        $scriptView = [System.Windows.Forms.TextBox]@{
            Font = $font
            HideSelection = $false
            Location = [System.Drawing.Point]@{X = 624; Y = 12}
            Multiline = $true
            ScrollBars = 'Both'
            Size = [System.Drawing.Size]@{Width = 561; Height = 668}
            TabIndex = 2
            Text = $InputObject.Extent.Text
            WordWrap = $false
        }

        $script:BufferIsDirty = $false
        $scriptView.Add_TextChanged({ $script:BufferIsDirty = $true })
        $scriptView.Add_KeyUp({ OnTextBoxKeyUp @args })

        $script:inputObjectStartOffset = $InputObject.Extent.StartOffset

        try
        {
            # Create the main form and show it.
            $form = [Windows.Forms.Form]@{
                Text = "Ast Explorer"
                ClientSize = [System.Drawing.Size]@{Width = 1200; Height = 700}
            }
            $form.Controls.Add($dataView)
            $form.Controls.Add($treeView)
            $form.Controls.Add($scriptView)
            $null = $form.ShowDialog()
        } finally {
            $form.Dispose()
        }
    }
}

