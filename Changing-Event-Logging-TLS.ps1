#Change path based on the location of file. Alternative is using import-csv for excel file
#Replace "file-path" with the location of file. Example: "C:\temp\Server.txt"

$Server_List = Get-Content "file-path"
$Path = "HKLM:\System\CurrentControlSet\Control\SecurityProviders\SCHANNEL"
$valueName = "EventLogging"
$Type = "DWORD"
$Value = "4"
$Credential = Get-Credential

foreach ($server in $Server_List)
{Invoke-Command -ComputerName $server -ScriptBlock{
set-Itemproperty -Path $using:Path -Name $using:ValueName -Value $using:Value -Type $using:Type
} -Credential $Credential}

#If got error path not exist, check the 32bits or 64 as the path will be different. 
# X86: "HKLM:\System\CurrentControlSet\Control\SecurityProviders\SCHANNEL"
# X64: "HKEY_LOCAL_MACHINE\System\CurrentControlSet\Control\SecurityProviders\SCHANNEL"
# Run the script in AM Machine (SV02060) cause other server have firewall restriction
# Set-ItemProperty -Path "HKLM: \System\CurrentControlSet\Control\SecurityProviders\SCHANNEL" -Value "4" -Name "EventLogging" -Type DWord
