# Remove all sites and applications from IIS
Import-Module WebAdministration
Get-Website | Remove-Website

# App pools #
# Create app pool
Import-Module WebAdministration
New-Item iis:\AppPools\NewAppPool

# Set .NET runtime for app pool
Set-ItemProperty IIS:\AppPools\NewAppPool managedRuntimeVersion v4.0 # .NET 4 - 4.5.2
Set-ItemProperty IIS:\AppPools\NewAppPool managedRuntimeVersion v2.0 # .NET 2 - 3.5

# Set classic mode for app pool
$appPool = Get-Item IIS:\AppPools\NewAppPool
$appPool .managedPipelineMode = "Classic"
$appPool | Set-Item

# Change user for app pool
Import-Module WebAdministration
$pool = Get-Item "iis:\AppPools\NewAppPool"
$pool.processModel.username = "DOMAIN\DOMAINUSER" # "COMPUTER\USER"
$pool.processModel.password = "********"
$pool.processModel.identityType = 3 # 0 = LocalSystem, 1 = LocalService, 2 = NetworkService, 3 = SpecificUser, 4 = ApplicationPoolIdentity
$pool | set-item
# More on app pool processmodel properties: http://www.iis.net/configreference/system.applicationhost/applicationpools/add/processmodel
# Remember to add user to iis_iusrs group, see scripts under ./../Windows Server/GroupsAndUsers.ps1

# Sites #
# Create site on port localhost:80
$webroot="c:\inetpub\sites\NewApplication"
mkdir $webroot
New-Item iis:\Sites\NewApplication -physicalpath $webroot -bindings @{protocol=”http”;bindingInformation=”:80:”}
# Remember to grant iis_iusrs full control to the folder, see scripts under ./../Windows Server/FileSystemPermissions.ps1

# Set app pool
Set-ItemProperty iis:\Sites\NewApplication -Name applicationpool -Value NewAppPool

# Bindings #
# Set host headers
Import-Module WebAdministration
Set-ItemProperty IIS:\Sites\NewApplication -name Bindings -value @{protocol="http";bindingInformation=":80:sub.domain.com"} # http://sub.domain.com
# With specific port
Set-ItemProperty IIS:\Sites\NewApplication -name Bindings -value @{protocol="http";bindingInformation=":8181:sub.domain.com"} # http://sub.domain.com:8181