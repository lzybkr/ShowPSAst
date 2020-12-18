Set-StrictMode -Version Latest

function AddChildNode {
    param (
        [System.Management.Automation.Language.Ast] $Child,
        [System.Windows.Forms.TreeNodeCollection]   $NodeList,
        [string]                                    $ExtentDetailLevel,
        [int]                                       $OriginalStartLinenumber,
        [int]                                       $OriginalStartOffset,
        [bool]                                      $BufferIsDirty
    )

    # Create the new node to add with the node text of the item type and extent
    if ($BufferIsDirty) {
        $calculatedStartLineNumber = $Child.Extent.StartLineNumber + ($OriginalStartLineNumber - 1)
        $calculatedStartOffset = $OriginalStartOffset + $Child.Extent.StartOffset
        $calculatedEndOffset = $OriginalStartOffset + $Child.Extent.EndOffset
    }
    else {
        $calculatedStartLineNumber = $Child.Extent.StartLineNumber
        $calculatedStartOffset = $Child.Extent.StartOffset
        $calculatedEndOffset = $Child.Extent.EndOffset
    }

    $calculatedEndLineNumber = $calculatedStartLineNumber +
    ($Child.Extent.EndLineNumber - $Child.Extent.StartLineNumber)

    $text = $Child.GetType().Name + (
        " [{0},{1}" -f
        $calculatedStartLineNumber,
        $calculatedEndLineNumber
    )

    if ($ExtentDetailLevel -eq 'Detailed') {
        $text += (
            "/{0},{1}/{2},{3}" -f
            $Child.Extent.StartColumnNumber,
            $Child.Extent.EndColumnNumber,
            $calculatedStartOffset,
            $calculatedEndOffset
        )
    }

    $childNode = [Windows.Forms.TreeNode]@{
        Text = $text + "]: " + ($Child.Extent.Text -split "`r`n")[0]
        Tag  = $child
    }
    $null = $NodeList.Add($childNode)

    # Recursively add the current nodes children
    PopulateNode -Ast $child -NodeList $childNode.Nodes `
        -ExtentDetailLevel $ExtentDetailLevel `
        -OriginalStartLineNumber $OriginalStartLineNumber `
        -OriginalStartOffset $OriginalStartOffset `
        -BufferIsDirty $BufferIsDirty

    # We want the tree fully expanded after construction
    $childNode.Expand()
}
