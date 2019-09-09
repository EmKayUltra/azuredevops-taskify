$script:taskTimer_stopWatch = $null
$script:taskTimer_currentTaskId = $null
$script:taskTimer_startingMinutes = 0

function get-setting([string]$name) {
    return [System.Environment]::GetEnvironmentVariable("azuredevops-taskify.$name", [System.EnvironmentVariableTarget]::User);
}

function set-setting([string]$name, [string]$value) {
    [System.Environment]::SetEnvironmentVariable("azuredevops-taskify.$name", $value, [System.EnvironmentVariableTarget]::User) | Write-Verbose;
}

function callApi($url, $params = @{}) {
    # TODO implement PAT and other auth options
    # $token = [System.Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes(":$($AZURE_PAT)"))
    # $header = @{authorization = "Basic $token"} 
    Invoke-RestMethod $url -UseDefaultCredentials @params # -headers $header
}

function roundUp([double]$num, [double]$multiple) {
    if ($num -eq 0) {
        return 0
    }
    [double]$t = $multiple + $num - 1 
    return ($t - ($t % $multiple))
}

function coalesceParameterWithSetting($value, $settingName)
{
    if ($value -eq "" -or $null -eq $value)
    {
        $setting = get-setting $settingName

        if ($setting)
        {
            Write-Verbose "$settingName loaded from Environment: $setting"
            return $setting
        }
        else 
        {
            throw "$settingName not provided and not found in settings."
        }
    }
    else 
    {
        return $value
    }
}