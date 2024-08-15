#Tabular Output to txtfile
#This script requires powercli to be pre-installed on system.
#Statistics level at vcenter should be set to atleast level 2
# Vcenter Credntials( Edit as per your environment)
$VCentre = "192.168.151.30"
$VCUser = "administrator@vsphere.local"
$VCPwd = "xxxxxxx"
#Stats will be collected for last five minutes, this can be changed to last few days by using paramter AddDyas
$date = (Get-Date).AddMinutes(-5)
#Output CSV File Name & Location
$strTXTName = "Stats-AvgHostDiskWriteStatsWorkingDay"
$strTXTLocation = "c:\" 
$strTXTsuffix = (get-date).toString('yyyyMMddhhmm')
$strTXTFile = $strTXTLocation + $strCSVName + "_" + $strTXTSuffix + ".txt"
#Connect to VC
Connect-VIServer $VCentre -User $VCUser -Password $VCPwd  -ea silentlycontinue
Get-VM | Where {$_.PowerState -eq "PoweredOn"} | Select Name, `
@{N="Throughput MBPs";E={[math]::Round((Get-Stat -Entity $_ -Start $date -Stat "virtualDisk.throughput.usage.average" |Group-Object -Property Timestamp | %{$_.Group | Measure-Object -Property Value -Sum | Select -ExpandProperty Sum} | Measure-Object -Average | Select -ExpandProperty Average)/1KB,2)}}, `
@{N="Read IOPS";E={[math]::Round((Get-Stat -Entity $_ -Start $date -Stat "virtualDisk.numberReadAveraged.average" |Group-Object -Property Timestamp | %{$_.Group | Measure-Object -Property Value -Sum | Select -ExpandProperty Sum} | Measure-Object -Average | Select -ExpandProperty Average),2)}}, `
@{N="Write IOPS";E={[math]::Round((Get-Stat -Entity $_ -Start $date -Stat "virtualDisk.numberWriteAveraged.average" |Group-Object -Property Timestamp | %{$_.Group | Measure-Object -Property Value -Sum | Select -ExpandProperty Sum} | Measure-Object -Average | Select -ExpandProperty Average),2)}} |
Format-Table -AutoSize | Out-File $strTXTFile
