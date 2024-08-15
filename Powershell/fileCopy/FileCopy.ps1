#==== global variables ===================================================================================

#Set path to source directory - This directory should house files to seed dataset
$FileSourcePath = "C:\ransomware_simulation\sample_data"

#Set path to target directory - Directory where dataset will be created and also the target for later encryption
$FileTargetPath = "C:\core-app"

#Target file types - File types to be randomly selected from source path - example '*.txt*','*.xml*','*.png*'
$TargetFiles = '*'

$sleeptime = 600

#END ==== global variables ===============================================================================

#Do not edit below here



[System.Net.ServicePointManager]::ServerCertificateValidationCallback = { $true }
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12


#Check for target directory, create as needed  
    if ( -not (Test-Path $FileTargetPath -PathType Any)) {
        New-Item -ItemType Directory -Path $FileTargetPath
    }


#Populate data in target directory to create change

    foreach ($i in 1..16) {
        
        Write-Host "Creating Data."
        if ( -not (Test-Path $FileTargetPath\$i -PathType Any)) {
        New-Item -ItemType Directory -Path $FileTargetPath\$i
        }

#Create a series of text files in target directory

        foreach ($d in 1..300) {    
            $filename=$($FileTargetPath) + '\' + $i + '\' + $(Get-Random 100000).tostring() + '.txt'
            Write-Host $filename
            Add-Content -Value ("Cohesity ransomware demo file" * (4096*16)) -Path $filename
        }

#Select files from source directory and copy in to target directory

    $FileList = get-childitem -path $FileSourcePath\* -Include $TargetFiles -Recurse -force | where { ! $_.PSIsContainer }
    $FileCount = '300'
    $FilestoCopy = Get-Random -InputObject $FileList -Count $FileCount
    
    
    foreach ($file in $FilestoCopy)
    {
        Write-Host "Populating $file"
        copy $file $FileTargetPath\$i\
    }
    Write-VolumeCache C
    Start-Sleep -Seconds $sleeptime


    }
