# Add new rule to configure a port for passing through firewall
Import-Module NetSecurity
$port = "8080"
$ruleName = "NewApplication_Inbound"
New-NetFirewallRule -name $ruleName -DisplayName "World Wide Web Services (HTTP Traffic-In)" -Description "An inbound rule to allow HTTP traffic for Internet Information Services (IIS) [TCP 8181]" -Enabled True -Profile Any -Action Allow -Program System -Group "@%windir%\system32\inetsrv\iisres.dll,-30501" -Protocol TCP -LocalPort $port