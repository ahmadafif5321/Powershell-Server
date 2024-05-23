Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# Create the form
$form = New-Object System.Windows.Forms.Form
$form.Text = "Software Installation Automation"
$form.Size = New-Object System.Drawing.Size(400, 300)
$form.StartPosition = "CenterScreen"

# Create a label and textbox for the installer local path
$labelInstallerLocalPath = New-Object System.Windows.Forms.Label
$labelInstallerLocalPath.Text = "Installer Local Path:"
$labelInstallerLocalPath.Location = New-Object System.Drawing.Point(10, 20)
$form.Controls.Add($labelInstallerLocalPath)

$textboxInstallerLocalPath = New-Object System.Windows.Forms.TextBox
$textboxInstallerLocalPath.Location = New-Object System.Drawing.Point(150, 20)
$textboxInstallerLocalPath.Size = New-Object System.Drawing.Size(200, 20)
$form.Controls.Add($textboxInstallerLocalPath)

# Create a button to browse for the installer local path
$buttonBrowseInstaller = New-Object System.Windows.Forms.Button
$buttonBrowseInstaller.Text = "Browse"
$buttonBrowseInstaller.Location = New-Object System.Drawing.Point(360, 20)
$buttonBrowseInstaller.Add_Click({
    $openFileDialog = New-Object System.Windows.Forms.OpenFileDialog
    $openFileDialog.Filter = "Executable Files (*.exe)|*.exe|All Files (*.*)|*.*"
    if ($openFileDialog.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) {
        $textboxInstallerLocalPath.Text = $openFileDialog.FileName
    }
})
$form.Controls.Add($buttonBrowseInstaller)

# Create a label and textbox for the server list path
$labelServerListPath = New-Object System.Windows.Forms.Label
$labelServerListPath.Text = "Server List Path:"
$labelServerListPath.Location = New-Object System.Drawing.Point(10, 60)
$form.Controls.Add($labelServerListPath)

$textboxServerListPath = New-Object System.Windows.Forms.TextBox
$textboxServerListPath.Location = New-Object System.Drawing.Point(150, 60)
$textboxServerListPath.Size = New-Object System.Drawing.Size(200, 20)
$form.Controls.Add($textboxServerListPath)

# Create a button to browse for the server list path
$buttonBrowseServerList = New-Object System.Windows.Forms.Button
$buttonBrowseServerList.Text = "Browse"
$buttonBrowseServerList.Location = New-Object System.Drawing.Point(360, 60)
$buttonBrowseServerList.Add_Click({
    $openFileDialog = New-Object System.Windows.Forms.OpenFileDialog
    $openFileDialog.Filter = "Text Files (*.txt)|*.txt|All Files (*.*)|*.*"
    if ($openFileDialog.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) {
        $textboxServerListPath.Text = $openFileDialog.FileName
    }
})
$form.Controls.Add($buttonBrowseServerList)

# Create a label and textbox for the installer remote path
$labelInstallerRemotePath = New-Object System.Windows.Forms.Label
$labelInstallerRemotePath.Text = "Installer Remote Path:"
$labelInstallerRemotePath.Location = New-Object System.Drawing.Point(10, 100)
$form.Controls.Add($labelInstallerRemotePath)

$textboxInstallerRemotePath = New-Object System.Windows.Forms.TextBox
$textboxInstallerRemotePath.Location = New-Object System.Drawing.Point(150, 100)
$textboxInstallerRemotePath.Size = New-Object System.Drawing.Size(200, 20)
$form.Controls.Add($textboxInstallerRemotePath)

# Create a button to start the installation process
$buttonStart = New-Object System.Windows.Forms.Button
$buttonStart.Text = "Start Installation"
$buttonStart.Location = New-Object System.Drawing.Point(150, 140)
$buttonStart.Add_Click({
    $installerLocalPath = $textboxInstallerLocalPath.Text
    $serverList = $textboxServerListPath.Text
    $installerRemotePath = $textboxInstallerRemotePath.Text
    $installerArguments = "/S"  # Silent install argument for Notepad++
    $servers = Get-Content -Path $serverList
    $logFilePath = "C:\CopyFiles\install_log.txt"

    Start-Transcript -Path $logFilePath -Append

    foreach ($server in $servers) {
        try {
            $session = New-PSSession -ComputerName $server

            # Copy the installer to the remote server
            Copy-Item -Path $installerLocalPath -Destination $installerRemotePath -ToSession $session -Force
            Write-Host "Installer copy to $server successful"

            # Command to install the software
            $installCommand = {
                param($installerPath, $installerArguments)
                Start-Process -FilePath $installerPath -ArgumentList $installerArguments -Wait
            }

            Invoke-Command -Session $session -ScriptBlock $installCommand -ArgumentList $installerRemotePath, $installerArguments
            Write-Host "Software installation on $server successful"
        }
        catch {
            Write-Host "Error during operation on {$server}: $_"
        }
        finally {
            Remove-PSSession -Session $session
            Write-Host "Session ended for $server"
        }
    }

    Stop-Transcript
    [System.Windows.Forms.MessageBox]::Show("Installation completed. Check the log file for details.", "Installation Status", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Information)
})
$form.Controls.Add($buttonStart)

# Show the form
[void]$form.ShowDialog()
