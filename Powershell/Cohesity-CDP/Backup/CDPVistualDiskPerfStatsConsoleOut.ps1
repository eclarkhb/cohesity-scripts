#This script captures CDP IOPS, CDP Throughput & CDP Peak Throughput over period of time.
#This script requires powercli to be pre-installed on machine from where stats are being collected.
#Statistics level at vcenter should be set to at least level 2
#Vcenter Credentials(Edit as per your environment)
$VCenter = "192.168.151.30"
$VCUser = "administrator@vsphere.local"
$VCPwd = "*******"
#Stats will be collected for last five minutes, this can be changed to last few days by modifying date variable eg (Get-Date).AddDays(-5)
$date = (Get-Date).AddMinutes(-5)
#Output CSV File Name & Location
$strCSVName = "Stats-AvgHostDiskWriteStats"
$strCSVLocation = "c:\" 
$strCSVSuffix = (get-date).toString('yyyyMMddhhmm')
$strCSVFile = $strCSVLocation + $strCSVName + "_" + $strCSVSuffix + ".csv"
#Connect to VC
Connect-VIServer $VCenter -User $VCUser -Password $VCPwd  -ea silentlycontinue
Get-VM | Where {$_.PowerState -eq "PoweredOn"} | Select Name, `
@{N="CDP Avg IOPS";E={[math]::Round((Get-Stat -Entity $_ -Start $date -Stat "virtualDisk.numberWriteAveraged.average" |Group-Object -Property Timestamp | %{$_.Group | Measure-Object -Property Value -Sum | Select -ExpandProperty Sum} | Measure-Object -Average | Select -ExpandProperty Average),2)}}, `
@{N="CDP Avg Throughput(MBPs)";E={[math]::Round((Get-Stat -Entity $_ -Start $date -Stat "virtualDisk.write.average" |Group-Object -Property Timestamp | %{$_.Group | Measure-Object -Property Value -Sum | Select -ExpandProperty Sum} | Measure-Object -Average | Select -ExpandProperty Average)/1KB,2)}}, `
@{N="CDP Peak Throughput(MBPs)";E={[math]::Round((Get-Stat -Entity $_ -Start $date -Stat "virtualDisk.write.average" |Group-Object -Property Timestamp | %{$_.Group | Measure-Object -Property Value -Maximum | Select -ExpandProperty Maximum} | Measure-Object -Maximum | Select -ExpandProperty Maximum)/1KB,2)}} |
Format-Table -AutoSize 
