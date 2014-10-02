# The following commands will change c:\windows\system32\inetsrv\config\applicationhost.config to allow overrides on authentication settings in application web.config
Import-Module WebAdministration
Set-WebConfiguration //System.webserver/security/authentication/windowsAuthentication -metadata overrideMode -value Allow # Override Windows Authentication
Set-WebConfiguration //System.webserver/security/authentication/anonymousAuthentication -metadata overrideMode -value Allow # Override Anonymous Authentication
Set-WebConfiguration //System.webserver/security/authentication/digestAuthentication -metadata overrideMode -value Allow # Override Digest Authentication
Set-WebConfiguration //System.webserver/security/authentication/basicAuthentication -metadata overrideMode -value Allow # Override Basic Authentication
iisreset

# Enable impersonation
Import-Module WebAdministration
set-webconfiguration "/system.webServer/security/isapiCgiRestriction/add[@path='%windir%\Microsoft.NET\Framework\v4.0.30319\aspnet_isapi.dll']/@allowed" -value "True" -PSPath:IIS:\
set-webconfiguration "/system.webServer/security/isapiCgiRestriction/add[@path='%windir%\Microsoft.NET\Framework64\v4.0.30319\aspnet_isapi.dll']/@allowed" -value "True" -PSPath:IIS:\

# Allow impersonation asynchronously on WCF services
$aspnetpath = ${env:windir} + "\Microsoft.NET\Framework64\v4.0.30319\aspnet.config"
$doc = new-object System.Xml.XmlDocument
$doc.Load($aspnetpath)
$doc.SelectSingleNode("//runtime/legacyImpersonationPolicy").enabled = "false"
$doc.SelectSingleNode("//runtime/alwaysFlowImpersonationPolicy").enabled = "true"
$doc.Save($aspnetpath)
iisreset