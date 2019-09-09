<#
.SYNOPSIS
Log time to a task, manually specifying the amount (instead of using the timer).

.PARAMETER Id
Id of Task to log time to

.PARAMETER Minutes
Number of minutes to log

.PARAMETER BillingIntervalInMinutes
The multiple to use for logged hours. It defaults to 15. So if 5 minutes are timed, then 15 are logged; if 16 minutes are timed, then 30 are logged.

.PARAMETER AZURE_BASE_URL
Base URL of the Azure DevOps Server instance. Defaults to AZURE_BASE_URL environment variable

.EXAMPLE
Log-TaskTime 1234 23
#>
function Log-Task {
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory = $true)][string]$Id,
        [Parameter()][double]$Minutes,
        [Parameter()][double]$BillingIntervalInMinutes = 15.0,
        [Parameter()][string]$AZURE_BASE_URL = ""
    )
    Process {
        $AZURE_BASE_URL = coalesceParameterWithSetting $AZURE_BASE_URL "AZURE_BASE_URL"

        $url = "$($AZURE_BASE_URL)/_apis/wit/workitems/$($Id)?api-version=5.0"
        [double]$elapsedTimeInHours = [math]::Round(((roundUp $Minutes $BillingIntervalInMinutes) / 60),2)

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

            $currentRev = $response.rev

            if (!$response.fields."Microsoft.VSTS.Scheduling.CompletedWork") {
                $hours = $elapsedTimeInHours
            }
            else {
                $hours = $response.fields."Microsoft.VSTS.Scheduling.CompletedWork" + $elapsedTimeInHours
            }

            if (!$response.fields."Microsoft.VSTS.Scheduling.RemainingWork") {
                $remainingHours = 0
            }
            else {
                $remainingHours = $response.fields."Microsoft.VSTS.Scheduling.RemainingWork" - $elapsedTimeInHours;
            }

            Write-Output "Updating Task $Id with RemainingWork: $remainingHours, CompletedWork: $hours"

            $body = @"
                [
                    {
                        "op": "test",
                        "path": "/rev",
                        "value": $currentRev
                    },
                    {
                        "op": "replace",
                        "path": "/fields/Microsoft.VSTS.Scheduling.CompletedWork",
                        "value": $hours
                    },
                    {
                        "op": "replace",
                        "path": "/fields/Microsoft.VSTS.Scheduling.RemainingWork",
                        "value": $remainingHours
                    }
                ]
"@

            $params = @{
                Method = "patch";
                ContentType = "application/json-patch+json";
                Body = $body
            }

            callApi $url $params | Out-Null
        }
        catch 
        {
            Write-Error $_
        }
    }
}

New-Alias -Name logtask -Value Log-Task