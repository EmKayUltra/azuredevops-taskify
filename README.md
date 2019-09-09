# AzureDevOps Taskify CLI

## Requirements
Requires an installation of Azure DevOps Server. Currently, it only supports integrated Windows authentication.

## Overview
Very basic task time tracker/logger for tasks.

Install the module as you would any other from the Powershell Admin terminal.  

It's recommended that you set an environment variable ("azuredevops-taskify.AZURE_BASE_URL") to hold the URL to your Azure OnPrem instance.

`> $urlToYourAzDevOServerInstance = ""`

`> [System.Environment]::SetEnvironmentVariable("azuredevops-taskify.AZURE_BASE_URL", $urlToYourAzDevOServerInstance, [System.EnvironmentVariableTarget]::User) | Write-Verbose;`

Once installed, you'll be able to pretty quickly log your hours into your workitems with a timer.

When logging time, the tool will round to 15 minute intervals (configurable).

## Example with Timer
If you are about to help someone on the team on an item, you find out the US work item ID.  In this example, it's 1234.  From the powershell terminal:

1. `> create-task 1234 "helping dev with weird issue" -estimatedhours 1.0` 
    - it will return the task ID. for this example, it's 5678
    - the `-starttask` switch takes care of step 2 if you specify it.  if not...
2. `> start-task 5678` 
    - timer starts
3. `> get-currenttask`
    - i forget what i'm working on, what is it?
4. `> stop-currenttask`
    - i'm done working on it now, stop timer and log the elapsed time to the Task 5678
    - alternatively, `> abandon-currenttask` 
        + if you want change tasks without logging anything to the Task, you need to abandon it
	

## Example without Timer
You can also call a function directly to report time to the work item instead of using the timer:

`> log-task 5678 60`
&nbsp;&nbsp;&nbsp;- 60 here is minutes


## Aliases Available
There's aliases available for all of these commands - please see man pages


## Other Tools
For a far more comprehensive CLI tool for AzureDevOps Server installs, check out [VSTeam](https://github.com/DarqueWarrior/vsteam)
