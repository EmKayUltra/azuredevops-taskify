Set-StrictMode -Version latest

. $PSScriptRoot\internal\_sharedFunctions.ps1

# dot source all ps1 files in this directory
# gci "$PSScriptRoot\functions" *-*.ps1 | % { . $_.FullName }

. $PSScriptRoot\functions\Abandon-CurrentTask.ps1
. $PSScriptRoot\functions\Create-Task.ps1
. $PSScriptRoot\functions\Get-CurrentTask.ps1
. $PSScriptRoot\functions\Log-Task.ps1
. $PSScriptRoot\functions\Start-Task.ps1
. $PSScriptRoot\functions\Stop-CurrentTask.ps1
