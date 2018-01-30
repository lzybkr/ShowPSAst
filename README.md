Show-Ast
========

This module helps visualize the PowerShell Ast with a graphical view.

The Ast is fully expanded in tree view, selecting a node in the tree
view will display the corresponding text in the script and the properties
of the node.

Example:

```
# Install the module first, then import
Install-Module ShowPSAst
Import-Module ShowPSAst

# Show the ast of a script or script module
Show-Ast $pshome\Modules\Microsoft.PowerShell.Utility\Microsoft.PowerShell.Utility.psm1
Show-Ast ~\Documents\WindowsPowerShell\profile.ps1

# Show the ast of a script block
Show-Ast { echo -InputObject "Name is $name" }
```

If you edit the text in the script view, you can press F5 to refresh the tree view.
