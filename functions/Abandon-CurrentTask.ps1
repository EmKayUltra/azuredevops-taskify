<#
.SYNOPSIS
Stops timing the current task.

.EXAMPLE
Abandon-CurrentTask
#>
function Abandon-CurrentTask {
    [CmdletBinding()]
    Param ()
    Process {        
        if ($null -eq $script:taskTimer_stopWatch -or !$script:taskTimer_stopWatch.IsRunning -or $null -eq $script:taskTimer_currentTaskId) 
        {
            Write-Output "No task in progress."
            return
        }

        Write-Output "Task $($script:taskTimer_currentTaskId) abandoned. Timer reset."

        $script:taskTimer_stopWatch.Stop()
                
        $script:taskTimer_stopWatch = $null
        $script:taskTimer_currentTaskId = $null
        $script:taskTimer_startingMinutes = 0
    }
}

New-Alias -Name abandontask -Value Abandon-CurrentTask