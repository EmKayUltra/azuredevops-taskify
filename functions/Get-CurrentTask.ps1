<#
.SYNOPSIS
View what task is currently being timed.

.EXAMPLE
Get-CurrentTask
#>
function Get-CurrentTask {
    [CmdletBinding()]
    Param ()
    Process {    
        if ($null -eq $script:taskTimer_stopWatch -or !$script:taskTimer_stopWatch.IsRunning -or $null -eq $script:taskTimer_currentTaskId) 
        {
            Write-Output "No task in progress."
        }
        else 
        {
            Write-Output "Task $script:taskTimer_currentTaskId is in progress. It was started $($script:taskTimer_stopWatch.Elapsed.TotalMinutes+$script:taskTimer_startingMinutes) minutes ago."
        }
    }
}

New-Alias -Name gettask -Value Get-CurrentTask