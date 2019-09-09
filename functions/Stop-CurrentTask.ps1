<#
.SYNOPSIS
Stops the timing of the current task and updates Azure with the time logged.

.DESCRIPTION
RemainingWork and CompletedWork are updated. The # of minutes logged is normalized to a multiple of $BillingIntervalInMinutes

.PARAMETER BillingIntervalInMinutes
The multiple to use for logged hours. It defaults to 15. So if 5 minutes are timed, then 15 are logged; if 16 minutes are timed, then 30 are logged.

.EXAMPLE
Stop-CurrentTask
#>

function Stop-CurrentTask  {
    [CmdletBinding()]
    Param (
        [Parameter()][double]$BillingIntervalInMinutes = 15.0
    )
    Process {
        if ($null -eq $script:taskTimer_stopWatch -or !$script:taskTimer_stopWatch.IsRunning -or $null -eq $script:taskTimer_currentTaskId) 
        {
            Write-Output "No task in progress."
            return
        }

        $script:taskTimer_stopWatch.Stop()
        $elapsedMinutes = $script:taskTimer_stopWatch.Elapsed.TotalMinutes
        $elapsedMinutes += $script:taskTimer_startingMinutes

        Log-Task $script:taskTimer_currentTaskId $elapsedMinutes $BillingIntervalInMinutes

        Write-Output "Timer for task $script:taskTimer_currentTaskId stopped. Time has been logged to Azure."

        $script:taskTimer_stopWatch = $null
        $script:taskTimer_currentTaskId = $null
        $script:taskTimer_startingMinutes = 0
    }
}

New-Alias -Name stoptask -Value Stop-CurrentTask