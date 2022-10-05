#set strict mode best practice to detect variable not declare
Set-StrictMode -version latest

#set variable to create shortcut. Replace "file-path" with the location of file. Example: "C:\temp\Server.csv"
$filePath= "file-path"

#import csv to get data inside excel in the path.
$serverlist = import-csv -Path $filePath -Delimiter ','

#create foreach to run each of server and create condition

#creating ArrayList to store output to the excel
$export = [System.Collections.ArrayList]@()

foreach($server in $serverlist){
    #declare server name for ease to call later
    $serverName = $server.ServerName

    #variable $connection created to pass resuly to condition
    $connection=Test-Connection $server.ServerName -Count 1

    if($connection.StatusCode -eq 0){
        Write-Output "$($serverName) is online"
    }
    else{
        Write-Output "$($serverName) is offline"
    }
    #adding server into array export
    [void]$export.Add($server)
}

#pipeline to tranfer output to the csv file
$export | Export-Csv -Path $filePath -Delimiter ',' -NoTypeInformation