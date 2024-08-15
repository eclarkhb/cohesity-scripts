# listBMRProtectedHosts

Powershell script to look for physical hosts on Cohesity that are protected with CoBMR.
CoBMR requires a pre-script that is run in the protection group.
This Powershell script searches active Physical protection jobs for a specific prescript filename.
This script requires cohesity-api.ps1 , the Cohesity REST API helper module [README](https://github.com/bseltz-cohesity/scripts/tree/master/powershell/cohesity-api)

Place both files in a folder together, then we can run the script like so:

```powershell
./listBMRProtectedHosts.ps1 -vip mycluster `
                 -username myuser `
                 -domain mydomain.net `
                 -scriptname cobmrcfg.bat
```

## Parameters

* -vip: Cohesity Cluster to connect to
* -username: Cohesity username
* -domain: (optional) Active Directory domain of user (defaults to local)
* -scriptname: (optional) Name of CoMBR script to look for (defaults to cobmrcfg)

Script will automatically check for both cobmrcfg & cobmrcfg.bat
