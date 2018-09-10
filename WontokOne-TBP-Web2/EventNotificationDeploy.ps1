$TaskName = "EventNotification"
$SourcePath = "c:\Wontok.Tools"
$TargetPath = "c:\ScheduledTasks\EventNotification"
$LocalUserName = "LocalTaskUser"
$LocalUserPassword = "qnhMP@1Abc"
$AdminGroup = "Administrators"


# unregister task if exists already
$task = Get-ScheduledTask | Where-Object TaskName -EQ $TaskName

if ($task)
{
    Write-Output "Task already registered: $TaskName. Exit."
    return
}

# copy files from source to target
if(Test-Path $TargetPath)
{
    Remove-Item $TargetPath -Recurse -Force
}

New-Item -ItemType Directory -Force -Path $TargetPath

Copy-Item -Path $SourcePath\* -Destination $TargetPath -recurse -Force


# Create local user if needed
$adsi = [ADSI]"WinNT:COMPUTERNAME"
$existing = $adsi.Children | Where-Object {$_.SchemaClassName -eq 'user' -and $_.Name -eq $LocalUserName}

if ($existing -eq $null) {
    Write-Host "Create new local user $LocalUserName $LocalUserPassword."

    & NET USER /ADD $LocalUserName $LocalUserPassword /expires:never

    WMIC USERACCOUNT WHERE "Name=""$LocalUserName""" SET PasswordExpires=FALSE

    & NET LOCALGROUP $AdminGroup $LocalUserName /add

} else {

    Write-Host "User already exists $LocalUserName."
}

# register scheduled task

Write-Output "Start to register task: $TaskName ..." 

$action = New-ScheduledTaskAction -Execute $TargetPath\'Wontok.Tools.exe' -WorkingDirectory $TargetPath
$trigger =  New-ScheduledTaskTrigger -Daily -At 1am
$settings = New-ScheduledTaskSettingsSet -MultipleInstances Parallel
Register-ScheduledTask  -Action $action `
                        -Trigger $trigger `
                        -TaskName $TaskName `
                        -Description $TaskName `
                        -RunLevel Highest `
                        -User $LocalUserName `
                        -Password $LocalUserPassword `
                        -Settings $settings `


