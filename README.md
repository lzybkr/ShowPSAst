Show-Ast
========

This module helps visualize the PowerShell Ast with a graphical view.

Note: Because this module is [WinForms](https://learn.microsoft.com/en-us/dotnet/desktop/winforms)-based, it only works on Windows.

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

# Get help
Get-Help Show-Ast
```

If you edit the text in the script view, you can press F5 to refresh the
tree view.

In the script view, pressing F3 will find the current line in the tree view.
This does not work for commented out lines.

There are default values for FontSize and ExtentDetailLevel. The defaults can be
overridden.

Command line, one time override:

`Show-Ast 'c:\Data\PowerShell\sample.ps1' -FontSize 10 -ExtentDetailLevel Detailed`

Configuration file, permanent override:

A file named `config.txt` in the root of the module. The contents should look like
this:

```
FontSize = 12

# Valid values are:
# Normal   = line numbers only
# Detailed = line numbers, column numbers and offset numbers
ExtentDetailLevel = Normal
```
