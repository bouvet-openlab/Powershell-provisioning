# Give group full control of a folder with subfolders
$group = "IIS_IUSRS"
$Acl = Get-Acl "C:\inetpub\sites"
$Ar = New-Object System.Security.AccessControl.FileSystemAccessRule -ArgumentList @($group,"FullControl","ObjectInherit, ContainerInherit","None","Allow")
$Acl.SetAccessRule($Ar)
Set-Acl "C:\inetpub\sites" $Acl