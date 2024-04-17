$auth = 16 ## [System.DirectoryServices.AuthenticationTypes]::Anonymous
$ldap = New-Object System.DirectoryServices.DirectoryEntry("LDAP://<server>:<port>", $null, $null, 16)
Write-Host (&{If($ldap.name) {$ldap.name} Else {"FAILED"}})

###

$ADsPath = "LDAP://<server>:<port>/dc=com/dc=.../ou=.../.../..."
$auth = [System.DirectoryServices.AuthenticationTypes]::FastBind
$ldap = New-Object System.DirectoryServices.DirectoryEntry($ADsPath, $null, $null, $auth)
$s = New-Object System.DirectoryServices.DirectorySearcher($ldap)
Write-Host $s.FindOne().Path

###

$path = "LDAP://<server>:<port>/dc=com/dc=.../ou=.../..."
$user = ""
$pswd = ""
$auth = [System.DirectoryServices.AuthenticationTypes]::FastBind
$ldap = New-Object System.DirectoryServices.DirectoryEntry($path, $user, $pswd, $auth)
$s = New-Object System.DirectoryServices.DirectorySearcher($ldap)
$s.Filter = "(...)"
$s.SearchScope = "subtree"
$s.PropertiesToLoad.Add("...")
$r = $s.FindOne()
Write-Host $r.Count
Write-Host $r.Path
Write-Host $r.Properties["..."]

### 

$ldap = [ADSI](<ADsPath>)
$ldap.psbase.Username = ""
$ldap.psbase.Password = ""
$ldap.psbase.AuthenticationType = 16
$ldap | select *
Write-Host $ldap.Path
Write-Host $ldap.Properties['ou']
$ldap.psbase.InvokeGet("adspath")
