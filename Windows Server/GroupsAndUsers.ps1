# Add user to group
$de = [ADSI]"WinNT://st-tw716/iis_iusrs,group" # Switch iis_iusrs with wanted group
$de.psbase.Invoke("Add",([ADSI]"WinNT://DOMAIN/USER").path) # Switch DOMAIN/USER with wanted user, COMPUTER/USER for local user