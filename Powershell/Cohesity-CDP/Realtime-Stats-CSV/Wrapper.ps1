for(;;) {
 try {
  # invoke the Realtimestats script by providing by providing exact location as shown in below example
  C:\Users\wkhan\Desktop\PCLI_Sscripts\Comment_Incorporation.ps1
 }
 catch {
  # do something with $_, log it, more likely
 }

 # Start Stats collection after sleeping for seconds defined below
 Start-Sleep 1200
}