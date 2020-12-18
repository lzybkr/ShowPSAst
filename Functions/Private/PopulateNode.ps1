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
            AddChildNode -Child $childObject -NodeList $NodeList `
                -ExtentDetailLevel $ExtentDetailLevel `
                -OriginalStartLineNumber $OriginalStartLineNumber `
                -OriginalStartOffset $OriginalStartOffset `
                -BufferIsDirty $BufferIsDirty
            continue
        }

        # Several Ast properties are collections of Ast, add them all
        # as children of the current node.
        $collection = $childObject -as [System.Management.Automation.Language.Ast[]]
        if ($collection -ne $null) {
            for ($i = 0; $i -lt $collection.Length; $i++) {
                AddChildNode -Child ($collection[$i]) -NodeList $NodeList `
                    -ExtentDetailLevel $ExtentDetailLevel `
                    -OriginalStartLineNumber $OriginalStartLineNumber `
                    -OriginalStartOffset $OriginalStartOffset `
                    -BufferIsDirty $BufferIsDirty
            }
            continue
        }

        # A little hack for IfStatementAst and SwitchStatementAst - they have a collection
        # of tuples of Ast.  Both items in the tuple are an Ast, so we want to recurse on both.
        if ($childObject.GetType().FullName -match 'ReadOnlyCollection.*Tuple`2.*Ast.*Ast') {
            for ($i = 0; $i -lt $childObject.Count; $i++) {
                AddChildNode -Child ($childObject[$i].Item1) -NodeList $NodeList `
                    -ExtentDetailLevel $ExtentDetailLevel `
                    -OriginalStartLineNumber $OriginalStartLineNumber `
                    -OriginalStartOffset $OriginalStartOffset `
                    -BufferIsDirty $BufferIsDirty
                AddChildNode -Child ($childObject[$i].Item2) -NodeList $NodeList `
                    -ExtentDetailLevel $ExtentDetailLevel `
                    -OriginalStartLineNumber $OriginalStartLineNumber `
                    -OriginalStartOffset $OriginalStartOffset `
                    -BufferIsDirty $BufferIsDirty
            }
            continue
        }
    }
}
