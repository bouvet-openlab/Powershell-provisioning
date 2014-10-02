# Tested on Windows Server 2012
Import-Module ServerManager

# Add .Net framework
Add-WindowsFeature As-Net-Framework

# Install web server feature with management tools and sub features
Install-WindowsFeature Web-Server -IncludeManagementTools -IncludeAllSubFeature -restart

# Enable impersonation
Import-Module WebAdministration
set-webconfiguration "/system.webServer/security/isapiCgiRestriction/add[@path='%windir%\Microsoft.NET\Framework\v4.0.30319\aspnet_isapi.dll']/@allowed" -value "True" -PSPath:IIS:\
set-webconfiguration "/system.webServer/security/isapiCgiRestriction/add[@path='%windir%\Microsoft.NET\Framework64\v4.0.30319\aspnet_isapi.dll']/@allowed" -value "True" -PSPath:IIS:\
$appPool = Get-Item IIS:\AppPools\NewAppPool
$appPool .managedPipelineMode = "Classic"
$appPool | Set-Item
Iisreset

# Enable WCF activation
Install-WindowsFeature -Name NET-WCF-Services45 -IncludeAllSubFeature # Windows server 2012