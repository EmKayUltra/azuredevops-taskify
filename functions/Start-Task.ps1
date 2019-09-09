<#
.SYNOPSIS
Start logging time for the Azure Task Work Item specified

.PARAMETER Id
Id of Task to start

.PARAMETER StartingMinutes
Number of minutes already contributed to this task, to be added at the end

.PARAMETER AZURE_BASE_URL
Base URL of the Azure DevOps Server instance. Defaults to AZURE_BASE_URL environment variable

.EXAMPLE
Start-Task 1234
#>
function Start-Task {
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory = $true)][string]$Id,       
        [Parameter()][int]$StartingMinutes = 0, 
        [Parameter()][string]$AZURE_BASE_URL = ""
    )
    Process {
        $AZURE_BASE_URL = coalesceParameterWithSetting $AZURE_BASE_URL "AZURE_BASE_URL"

        if ($script:taskTimer_stopWatch -and ($script:taskTimer_stopWatch.IsRunning -or !($null -eq $script:taskTimer_currentTaskId)))
        {
            Write-Error "Task still in progress. Run Abandon-CurrentTask or Stop-CurrentTask first."
            return
        }
        if ($null -eq $Id)
        {
            Write-Error "No task provided."
            return
        }

        $url = "$($AZURE_BASE_URL)/_apis/wit/workitems/$($Id)?api-version=5.0"
        
        try
        {
            $response = callApi $url
            
            if (!($response.fields."System.WorkItemType" -eq "Task"))
            {
                Write-Error "Work Item $Id is not a Task. It is a $($response.fields."System.WorkItemType")"
                return
            }

            $userResponse = callApi $response.fields."System.AssignedTo".url

            if (!($userResponse.Properties."Account" -eq $env:USERNAME))
            {
                Write-Error "Work Item $Id is not assigned to you. It is assigned to  $($userResponse.Properties."Account")"
                return
            }

            $script:taskTimer_currentTaskId = $Id
            $script:taskTimer_stopWatch = [system.diagnostics.stopwatch]::StartNew()
            $script:taskTimer_startingMinutes = $StartingMinutes

            Write-Output "Timer started for task $Id."
        }
        catch 
        {
            Write-Error $_
        }
    }
}

New-Alias -Name starttask -Value Start-Task