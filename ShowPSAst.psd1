@{
    Description       = 'A graphical explorer for the PowerShell AST'
    RootModule        = 'ShowPSAst.psm1'
    ModuleVersion     = '1.0'
    GUID              = '0f15785e-f6b7-450d-b369-8d2a9767e8bb'
    Author            = 'Jason Shirk'
    Copyright         = '(c) Jason Shirk. All rights reserved.'
    PowerShellVersion = '3.0'
    FunctionsToExport = @('Show-Ast')
    CmdletsToExport   = @()
    AliasesToExport   = @()
    PrivateData       = @{ PSData = @{
            Tags       = @('Ast')
            LicenseUri = 'https://github.com/lzybkr/ShowPSAst/blob/master/LICENSE.txt'
            ProjectUri = 'https://github.com/lzybkr/ShowPSAst'
        } 
    }
}
