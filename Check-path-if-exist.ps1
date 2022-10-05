#Strictmode to get return of error instead of null if you not declare something
Set-StrictMode -Version latest

#Replace "file-path" with the location of file. Example: "C:\temp\Server.txt"
$filepath = "file-path"

if (test-path -Path $filepath){
    Write-Output "the path exist correctly"}
else {
    Write-Output "The $filepath not exist"}


