#Variables - This should be changed to match your configuration
    $vcenter = "xxxxxxxxxxx"
    $vcenter_user = 'administrator@vsphere.local'
    $vcenter_password = 'xxxxxxx'
    $CDP_VMs = 'VM1','VM2'
    $TempCSVlocation = "C:\Users\wkhan\Desktop\pcli_out\CDPRTPerformance.csv"
    $date = (Get-Date).AddMinutes(-20)

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
#$credentialsVcenter = Get-Credential
#Connection to vcenter.
Clear-Host
Set-PowerCLIConfiguration -InvalidCertificateAction Ignore -Confirm:$false
Connect-VIServer $vcenter -User $vcenter_user -Password $vcenter_password -ea silentlycontinue
Get-VM -Name $CDP_VMs | Select Name, `
@{N="DATE";E={((Get-Stat -Realtime -Entity $_ -Start $date -Stat "datastore.numberWriteAveraged.average" |Group-Object -Property Timestamp | %{$_.Group | Measure-Object -Property Timestamp -Maximum | Select -ExpandProperty Maximum} | Measure-Object -Maximum | Select -ExpandProperty Maximum))}}, `
@{N="Avg IOPS";E={[math]::Round((Get-Stat -Realtime -Entity $_ -Start $date -Stat "datastore.numberWriteAveraged.average" |Group-Object -Property Timestamp | %{$_.Group | Measure-Object -Property Value -Sum | Select -ExpandProperty Sum} | Measure-Object -Average | Select -ExpandProperty Average),2)}}, `
@{N="Avg Throughput(MBPs)";E={[math]::Round((Get-Stat -Realtime -Entity $_ -Start $date -Stat "datastore.write.average" |Group-Object -Property Timestamp | %{$_.Group | Measure-Object -Property Value -Sum | Select -ExpandProperty Sum} | Measure-Object -Average | Select -ExpandProperty Average)/1KB,2)}}, `
@{N="Total Throughput(MBPs)";E={[math]::Round((Get-Stat -Realtime -Entity $_ -Start $date -Stat "datastore.write.average" |Group-Object -Property Timestamp | %{$_.Group | Measure-Object -Property Value -Sum | Select -ExpandProperty Sum} | Measure-Object -Sum | Select -ExpandProperty Sum)/1KB,2)}}, `
@{N="Peak Throughput(MBPs)";E={[math]::Round((Get-Stat -Realtime -Entity $_ -Start $date -Stat "datastore.write.average" |Group-Object -Property Timestamp | %{$_.Group | Measure-Object -Property Value -Maximum | Select -ExpandProperty Maximum} | Measure-Object -Maximum | Select -ExpandProperty Maximum)/1KB,2)}} |`
Export-Csv $TempCSVLocation -NoTypeInformation -Append

#Remove the Temp CSV file.
#Remove-Item -Path $TempCSVlocation -Force
#Disconnect from Vcenter.
Disconnect-VIServer * -Confirm:$False

Write-Host "Vcenter diskreport is now done" -ForegroundColor Green -ErrorAction Stop
Start-Sleep -s 2