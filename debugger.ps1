# FOR DEVELOPMENT PURPOSES ONLY
# ideally we would remove this file and just use the debugger but it's not super reliable so here we are

. $PSScriptRoot\internal\_sharedFunctions.ps1

set-setting "AZURE_BASE_URL" ""

# dot source any ps1 files needed to debug
# . .\functions\Create-Task.ps1