<#
.SYNOPSIS
Creates a Task work item as a child of another work item

.DESCRIPTION
It is assigned to the current user

.PARAMETER ParentId
The ID of the work item for this new task to be assigned to

.PARAMETER Title
The title of the new task

.PARAMETER Description
THe description of the new task

.PARAMETER EstimatedHours
The number of estimated hours for the new task

.PARAMETER AZURE_BASE_URL
The base URL of the Azure website

.PARAMETER StartTask
Switch to automatically start the task after it's created

.EXAMPLE
Create-Task 12627 "test task" -StartTask
#>
function Create-Task {
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory = $true)][string]$ParentId,  
        [Parameter(Mandatory = $true)][string]$Title,  
        [Parameter()][string]$Description = "",  
        [Parameter()][double]$EstimatedHours = 0.0,  
        [Parameter()][string]$AZURE_BASE_URL = "",
        [Parameter()][Switch]$StartTask
    )
    Process {
        $AZURE_BASE_URL = coalesceParameterWithSetting $AZURE_BASE_URL "AZURE_BASE_URL"
        
        try
        {
            $body = @"
            [
                {
                  "op": "add",
                  "path": "/fields/System.Title",
                  "from": null,
                  "value": "$Title"
                },
                {
                    "op": "add",
                    "path": "/fields/System.Description",
                    "from": null,
                    "value": "$Description"
                },
                {
                    "op": "add",
                    "path": "/fields/System.AssignedTo",
                    "from": null,
                    "value": "$($env:userdomain)\\$($env:username)"
                },
                {
                    "op": "add",
                    "path": "/fields/Microsoft.VSTS.Scheduling.RemainingWork",
                    "from": null,
                    "value": "$EstimatedHours"
                },
                {
                    "op": "add",
                    "path": "/fields/Microsoft.VSTS.Scheduling.OriginalEstimate",
                    "from": null,
                    "value": "$EstimatedHours"
                },
                {
                    "op": "add",
                    "path": "/fields/Microsoft.VSTS.Scheduling.CompletedWork",
                    "from": null,
                    "value": "0"
                },
                {
                    "op": "add",
                    "path": "/relations/-",
                    "value": 
                        {
                            "rel": "System.LinkTypes.Hierarchy-Reverse",
                            "url": "$($AZURE_BASE_URL)/bac/_apis/wit/workitems/$($ParentId)",
                            "attributes": 
                            {
                                "comment": "linking parent WIT"
                            }
                        }
                }
            ]
"@

            $params = @{ 
                Method = "patch";
                ContentType = "application/json-patch+json";
                Body = $body;
            }

            $response = callApi "$($AZURE_BASE_URL)/bac/_apis/wit/workitems/`$Task?api-version=5.0" $params

            Write-Output "Task created successfully. Id # $($response.id)."
            if ($StartTask.IsPresent) {
                if (!((Get-CurrentTask) -eq "No task in progress."))
                {
                    Write-Output "Task cannot be started because there is another task currently being timed."
                    return
                }

                Start-Task $response.id -AZURE_BASE_URL $AZURE_BASE_URL
            }
        }
        catch 
        {
            Write-Error $_
        }
    }
}

New-Alias -Name createtask -Value Create-Task