Set-StrictMode -Version latest

$RAM = Get-WmiObject -Class win32_operatingsystem | Select-Object -ExpandProperty TotalVisibleMemorysize
$Free_Memory = Get-WmiObject -class win32_operatingsystem | Select-Object -ExpandProperty freephysicalmemory
$RAM_usage = (($RAM -$Free_Memory)/$RAM) * 100 
$RAM_usage_int = [int]$RAM_usage
#Write-Host "The RAM usage for server is: $RAM_usage_int%"
  
  if($RAM_usage_int -gt 80){
    Write-Warning "RAM usage is over 80% at $RAM_usage_int"
  }else{
    Write-Host "RAM usage is normal at $RAM_usage_int"
  }