#Variables - This should be changed to match your configuration
    $vcenter = "sv4-cdp-vcenter70-01.eng.cohesity.com"
    $TempCSVlocation = "C:\diskinformation.csv"
    $ExcelFileLocation = "C:\Diskinformation_$(Get-Date -Format 'yyyy_MM_dd').xlsx" 

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
$Virtualmachines = Get-VM

#Generate report
$date = Get-Date -Format 'dd/MM/yyyy'
$report = @()
foreach ($vm in $Virtualmachines){

$row = '' | select Name, Provisioned, Used, Date
    $row.Name = $vm.Name
    $row.Provisioned = [math]::round($vm.ProvisionedSpaceGB , 2)
    $row.Used = [math]::round($vm.UsedSpaceGB , 2)
    $row.date = $date
$report += $row
}
$report | Sort Name | Export-Csv $TempCSVLocation -NoTypeInformation
$delimiter = ","
$excel = New-Object -ComObject excel.application 
    $workbook = $excel.Workbooks.Add(1)
    $worksheet = $workbook.worksheets.Item(1)
    $TxtConnector = ("TEXT;" + $TempCSVLocation)
    $Connector = $worksheet.QueryTables.add($TxtConnector,$worksheet.Range("A1"))
    $query = $worksheet.QueryTables.item($Connector.name)
    $query.TextFileOtherDelimiter = $delimiter
    $query.TextFileParseType  = 1
    $query.TextFileColumnDataTypes = ,1 * $worksheet.Cells.Columns.Count
    $query.AdjustColumnWidth = 1
    $query.Refresh()
    $query.Delete()
        Add-Type -AssemblyName "Microsoft.Office.Interop.Excel"
        $WorkSheet.Columns.AutoFit()
        $ListObject = $excel.ActiveSheet.ListObjects.Add([Microsoft.Office.Interop.Excel.XlListObjectSourceType]::xlSrcRange, $excel.ActiveCell.CurrentRegion, $null ,[Microsoft.Office.Interop.Excel.XlYesNoGuess]::xlYes)
        $ListObject.Name = "TableData"
        $ListObject.TableStyle = "TableStyleMedium20"
$Workbook.SaveAs($ExcelFileLocation,51)
$excel.Quit()

#Remove the Temp CSV file.
Remove-Item -Path $TempCSVlocation -Force
#Disconnect from Vcenter.
Disconnect-VIServer * -Confirm:$False

Write-Host "Vcenter diskreport is now done" -ForegroundColor Green -ErrorAction Stop
Start-Sleep -s 2