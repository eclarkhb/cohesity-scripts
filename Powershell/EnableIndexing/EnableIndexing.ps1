#
# Sample script to enable indexing on NetApp & NAS Protection Jobs
#
# Recommend updating to latst Cohesity Powershell Module first:
# Update-Module -Name “Cohesity.PowerShell”
#

# Setup Local System Variables 
$username = "admin"
$password = "admin"
$clusterip = "172.16.3.101"

# Connect to cluster
$secstr = New-Object -TypeName System.Security.SecureString
$password.ToCharArray() | ForEach-Object {$secstr.AppendChar($_)}
$cred = new-object -typename System.Management.Automation.PSCredential -argumentlist $username, $secstr
Connect-CohesityCluster -Server $clusterip -Credential ($cred)

# Create an Indexing Object for NAS
$indexing = [cohesity.model.indexingpolicy]::new()
$indexing.DisableIndexing = $false
$indexing.allowPrefixes = "/"

# Enable Indexing on all NAS Jobs
Foreach ($i in get-CohesityProtectionJob -Environments kNetapp,kGenericNAS) {
    $i.IndexingPolicy = $indexing
    $i | set-CohesityProtectionJob
}
