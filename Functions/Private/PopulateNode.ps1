Set-StrictMode -Version Latest

function PopulateNode {
    param (
        [System.Management.Automation.Language.Ast] $Ast,
        [System.Windows.Forms.TreeNodeCollection]   $NodeList,
        [string]                                    $ExtentDetailLevel,
        [int]                                       $OriginalStartLinenumber,
        [int]                                       $OriginalStartOffset,
        [bool]                                      $BufferIsDirty
    )

    $astCollection = [System.Collections.ArrayList]::new()

    foreach ($child in $Ast.PSObject.Properties) {
        # Skip the Parent node, it's not useful here
        if ($child.Name -eq 'Parent') {
            continue
        }

        $childObject = $child.Value

        if ($null -eq $childObject) {
            continue
        }

        # Recursively add only Ast nodes.
        if ($childObject -is [System.Management.Automation.Language.Ast]) {
            $astCollection.Add($childObject) | Out-Null
            continue
        }

        # Several Ast properties are collections of Ast, add them all
        # as children of the current node.
        $collection = $childObject -as [System.Management.Automation.Language.Ast[]]
        if ($collection -ne $null) {
            for ($i = 0; $i -lt $collection.Length; $i++) {
                $astCollection.Add($collection[$i]) | Out-Null
            }
            continue
        }

        # A little hack for IfStatementAst and SwitchStatementAst - they have a collection
        # of tuples of Ast.  Both items in the tuple are an Ast, so we want to recurse on both.
        if ($childObject.GetType().FullName -match 'ReadOnlyCollection.*Tuple`2.*Ast.*Ast') {
            for ($i = 0; $i -lt $childObject.Count; $i++) {
                $astCollection.Add($childObject[$i].Item1) | Out-Null
                $astCollection.Add($childObject[$i].Item2) | Out-Null
            }
            continue
        }
    }

    # Without sorting the AST items can be in the wrong order. The result is
    # the cursor in the textbox jumping back and forth as the user scrolls
    # through the treeview.
    $astCollection |
        Sort-Object -Property @{Expression = {$_.Extent.StartLineNumber}},
        @{Expression = {$_.Extent.StartColumnNumber}},
        @{Expression = {$_.Extent.EndOffset}} |
        ForEach-Object -Process {
            AddChildNode -Child $_ -NodeList $NodeList `
                -ExtentDetailLevel $ExtentDetailLevel `
                -OriginalStartLineNumber $OriginalStartLineNumber `
                -OriginalStartOffset $OriginalStartOffset `
                -BufferIsDirty $BufferIsDirty
        }
}
