# Enable NTLM authentication for WMSvc through registry key
Set-ItemProperty -Path hklm:Software\Microsoft\WebManagement\Server -Name "WindowsAuthenticationEnabled" -value 1
net stop wmsvc
net start wmsvc

# Grant user permission to deploy to websites
# Run once per user with permission
$inetsrvPath = ${env:windir} + "\system32\inetsrv\"
[System.Reflection.Assembly]::LoadFrom( $inetsrvPath + "Microsoft.Web.Administration.dll" ) > $null
[System.Reflection.Assembly]::LoadFrom( $inetsrvPath + "Microsoft.Web.Management.dll" )   > $null
$username = "DOMAIN\USER" # COMPUTER\USER for local user
$appHostConfig = ${env:windir} + "\system32\inetsrv\config\applicationHost.config"
$Acl = (Get-Item $appHostConfig).GetAccessControl("Access")
$Ar = New-Object System.Security.AccessControl.FileSystemAccessRule -ArgumentList @($username,"ReadAndExecute,Write","Allow")
$Acl.AddAccessRule($Ar)
set-acl -aclobject $Acl $appHostConfig 
# Add new statement per site to grant permission to
$site = "NewApplication"
[Microsoft.Web.Management.Server.ManagementAuthorization]::Grant($username, $site, $FALSE) | out-null

# Delegation rules #
# Delegation rule: Deploy Applications with Content 
[System.Reflection.Assembly]::LoadFrom( ${env:windir} + "\system32\inetsrv\Microsoft.Web.Administration.dll" ) > $null
Import-Module WebAdministration
$serverManager = (New-Object Microsoft.Web.Administration.ServerManager)
$delegationRulesCollection = $serverManager.GetAdministrationConfiguration().GetSection("system.webServer/management/delegation").GetCollection()
$newRule = $delegationRulesCollection.CreateElement("rule")
$newRule.Attributes["providers"].Value = "contentPath, iisApp"
$newRule.Attributes["actions"].Value = "*"
$newRule.Attributes["path"].Value = "{userScope}"
$newRule.Attributes["pathType"].Value = "PathPrefix"
$newRule.Attributes["enabled"].Value = "true"
$runAs = $newRule.GetChildElement("runAs")
$runAs.Attributes["identityType"].Value = "CurrentUser"
$permissions = $newRule.GetCollection("permissions")
$user = $permissions.CreateElement("user")
$user.Attributes["name"].Value = "DOMAIN\USER" # User configured to deploy sites
$user.Attributes["accessType"].Value = "Allow"
$user.Attributes["isRole"].Value = "False"
$permissions.Add($user) | out-null
$delegationRulesCollection.Add($newRule) | out-null
$serverManager.CommitChanges()

# Delegation rule: Mark Folders as Applications
# Set username and password for locally executing user
$username = "DOMAIN\USER"
$password = "********"
[System.Reflection.Assembly]::LoadFrom( ${env:windir} + "\system32\inetsrv\Microsoft.Web.Administration.dll" ) > $null
Import-Module WebAdministration
$serverManager = (New-Object Microsoft.Web.Administration.ServerManager)
$delegationRulesCollection = $serverManager.GetAdministrationConfiguration().GetSection("system.webServer/management/delegation").GetCollection()
$newRule = $delegationRulesCollection.CreateElement("rule")
$newRule.Attributes["providers"].Value = "createApp"
$newRule.Attributes["actions"].Value = "*"
$newRule.Attributes["path"].Value = "{userScope}"
$newRule.Attributes["pathType"].Value = "PathPrefix"
$newRule.Attributes["enabled"].Value = "true"
$runAs = $newRule.GetChildElement("runAs")
$runAs.Attributes["identityType"].Value = "SpecificUser"
$runAs.Attributes["userName"].Value = $username # Executing user
$runAs.Attributes["password"].Value = $password
$permissions = $newRule.GetCollection("permissions")
$user = $permissions.CreateElement("user")
$user.Attributes["name"].Value = "DOMAIN\USER" # User configured to deploy sites
$user.Attributes["accessType"].Value = "Allow"
$user.Attributes["isRole"].Value = "False"
$permissions.Add($user) | out-null
$delegationRulesCollection.Add($newRule) | out-null
$serverManager.CommitChanges()

# Delegation rule: Set Permissions for Applications
[System.Reflection.Assembly]::LoadFrom( ${env:windir} + "\system32\inetsrv\Microsoft.Web.Administration.dll" ) > $null
Import-Module WebAdministration
$serverManager = (New-Object Microsoft.Web.Administration.ServerManager)
$delegationRulesCollection = $serverManager.GetAdministrationConfiguration().GetSection("system.webServer/management/delegation").GetCollection()
$newRule = $delegationRulesCollection.CreateElement("rule")
$newRule.Attributes["providers"].Value = "setAcl"
$newRule.Attributes["actions"].Value = "*"
$newRule.Attributes["path"].Value = "{userScope}"
$newRule.Attributes["pathType"].Value = "PathPrefix"
$newRule.Attributes["enabled"].Value = "true"
$runAs = $newRule.GetChildElement("runAs")
$runAs.Attributes["identityType"].Value = "CurrentUser"
$permissions = $newRule.GetCollection("permissions")
$user = $permissions.CreateElement("user")
$user.Attributes["name"].Value = "DOMAIN\USER" # User configured to deploy sites
$user.Attributes["accessType"].Value = "Allow"
$user.Attributes["isRole"].Value = "False"
$permissions.Add($user) | out-null
$delegationRulesCollection.Add($newRule) | out-null
$serverManager.CommitChanges()