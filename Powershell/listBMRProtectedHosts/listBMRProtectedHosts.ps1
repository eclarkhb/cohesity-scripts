# process commandline arguments
[CmdletBinding()]
param (
    [Parameter(Mandatory = $True)][string]$vip,  # the cluster to connect to (DNS name or IP)
    [Parameter(Mandatory = $True)][string]$username,  # username (local or AD)
    [Parameter()][string]$domain = 'local',
    [Parameter()][switch]$useApiKey,
    [Parameter()][string]$password = $null,
    [Parameter()][string]$scriptname = 'cobmrcfg' # cobmrcfg is the default pre-script name for linux hosts
)

# source the cohesity-api helper code
. $(Join-Path -Path $PSScriptRoot -ChildPath cohesity-api.ps1)

# authenticate
if($useApiKey){
    apiauth -vip $vip -username $username -domain $domain -useApiKey -password $password
}else{
    apiauth -vip $vip -username $username -domain $domain -password $password
}

#find all of the kPhysical Protection Groups
$foundBMR = $false
$jobs = api get -v2 "data-protect/protection-groups?isDeleted=false&isActive=true&environments=kPhysical"
$paramPaths = @{'kFile' = 'fileProtectionTypeParams'; 'kVolume' = 'volumeProtectionTypeParams'}

foreach($job in $jobs.protectionGroups){
    $paramPath = $paramPaths[$job.physicalParams.protectionType]
    if(($job.physicalParams.$paramPath.prePostScript.preScript.path -ieq $scriptname) -or 
    ($job.physicalParams.$paramPath.prePostScript.preScript.path -ieq "$scriptname.bat")){
        foreach($server in $job.physicalParams.$paramPath.objects){
            $foundBMR = $true
            Write-Host $server.name
        }
    }
}

if($foundBMR -eq $false){
        Write-Host "No BMR Protection found in any physical protection group" -ForegroundColor Yellow
    }
