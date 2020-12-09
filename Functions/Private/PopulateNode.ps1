Set-StrictMode -Version Latest

function PopulateNode($object, $nodeList) {
    foreach ($child in $object.PSObject.Properties) {
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
            AddChildNode $childObject $nodeList
            continue
        }

        # Several Ast properties are collections of Ast, add them all
        # as children of the current node.
        $collection = $childObject -as [System.Management.Automation.Language.Ast[]]
        if ($collection -ne $null) {
            for ($i = 0; $i -lt $collection.Length; $i++) {
                AddChildNode ($collection[$i]) $nodeList
            }
            continue
        }

        # A little hack for IfStatementAst and SwitchStatementAst - they have a collection
        # of tuples of Ast.  Both items in the tuple are an Ast, so we want to recurse on both.
        if ($childObject.GetType().FullName -match 'ReadOnlyCollection.*Tuple`2.*Ast.*Ast') {
            for ($i = 0; $i -lt $childObject.Count; $i++) {
                AddChildNode ($childObject[$i].Item1) $nodeList
                AddChildNode ($childObject[$i].Item2) $nodeList
            }
            continue
        }
    }
}
