Set-StrictMode -Version Latest

function AddChildNode($Child, $NodeList, $ExtentDetailLevel) {
    # Create the new node to add with the node text of the item type and extent
    $text = $child.GetType().Name + (
        " [{0},{1}" -f
        $child.Extent.StartLineNumber,
        $child.Extent.EndLineNumber
    )

    if ($ExtentDetailLevel -eq 'Detailed') {
        $text += (
            "/{0},{1}/{2},{3}" -f
            $child.Extent.StartColumnNumber,
            $child.Extent.EndColumnNumber,
            $child.Extent.StartOffset,
            $child.Extent.EndOffset
        )
    }

    $childNode = [Windows.Forms.TreeNode]@{
        Text = $text + "]: " + ($child.Extent.Text -split "`r`n")[0]
        Tag  = $child
    }
    $null = $nodeList.Add($childNode)

    # Recursively add the current nodes children
    PopulateNode $child $childNode.Nodes -ExtentDetailLevel $ExtentDetailLevel

    # We want the tree fully expanded after construction
    $childNode.Expand()
}
