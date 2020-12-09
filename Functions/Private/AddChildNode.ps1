Set-StrictMode -Version Latest

function AddChildNode($Child, $NodeList) {
    # Create the new node to add with the node text of the item type and extent
    $childNode = [Windows.Forms.TreeNode]@{
        Text = $child.GetType().Name + (
            " [{0},{1}/{2},{3}/{4},{5}]: {6}" -f
            $child.Extent.StartLineNumber,
            $child.Extent.EndLineNumber,
            $child.Extent.StartColumnNumber,
            $child.Extent.EndColumnNumber,
            $child.Extent.StartOffset,
            $child.Extent.EndOffset,
            ($child.Extent.Text -split "`r`n")[0]
        )
        Tag  = $child
    }
    $null = $nodeList.Add($childNode)

    # Recursively add the current nodes children
    PopulateNode $child $childNode.Nodes

    # We want the tree fully expanded after construction
    $childNode.Expand()
}
