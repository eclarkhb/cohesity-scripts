#Variables - This should be changed to match your configuration
    $vcenter = "sv4-cdp-vcenter70-01.eng.cohesity.com"

#Check if the correct powershell module has been installed.
if (Get-Module -ListAvailable -Name VMware.PowerCLI) {
    Write-Host -ForegroundColor "Green" "VMware Powershell is installed"
} 
else {
    Write-Host -ForegroundColor Red "#VMware Powershell is not installed"
    Write-Host -ForegroundColor Red "#Run the following via PowerShell admin on your machine"
    Write-Host -ForegroundColor Blue "Install-Module -Name VMware.PowerCLI -AllowClobber"
    Start-Sleep 15
    exit
}
#Credentials
$credentialsVcenter = Get-Credential

#Connection to vcenter.
Clear-Host
Set-PowerCLIConfiguration -InvalidCertificateAction Ignore -Confirm:$false
Connect-VIServer $vcenter -Credential $credentialsVcenter
Get-VM | Where {$_.PowerState -eq "PoweredOn"} | Select Name, `
@{N="CDP Avg IOPS";E={[math]::Round((Get-Stat -Entity $_ -Start $date -Stat "datastore.numberWriteAveraged.average" |Group-Object -Property Timestamp | %{$_.Group | Measure-Object -Property Value -Sum | Select -ExpandProperty Sum} | Measure-Object -Average | Select -ExpandProperty Average),2)}}, `
@{N="CDP Avg Throughput(MBPs)";E={[math]::Round((Get-Stat -Entity $_ -Start $date -Stat "datastore.write.average" |Group-Object -Property Timestamp | %{$_.Group | Measure-Object -Property Value -Sum | Select -ExpandProperty Sum} | Measure-Object -Average | Select -ExpandProperty Average)/1KB,2)}}, `
@{N="CDP Peak Throughput(MBPs)";E={[math]::Round((Get-Stat -Entity $_ -Start $date -Stat "datastore.write.average" |Group-Object -Property Timestamp | %{$_.Group | Measure-Object -Property Value -Maximum | Select -ExpandProperty Maximum} | Measure-Object -Maximum | Select -ExpandProperty Maximum)/1KB,2)}} |`
Format-Table -AutoSize | Out-File C:\CDPRealTimePerfStats.txt

#Disconnect from Vcenter.
Disconnect-VIServer * -Confirm:$False

Write-Host "Vcenter diskreport is now done" -ForegroundColor Green -ErrorAction Stop
Start-Sleep -s 2