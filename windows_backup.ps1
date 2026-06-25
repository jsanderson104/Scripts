$date = Get-Date -Format "yyyy-MM-dd"
$src = "C:\Users"
$backupdir = "e:\backups"
$todays_backup_dir = "$backupdir\$date"
$log = "$backupdir\$date.log"



# If folder exists (ie the backup has already ran today, then delete it so we can start fresh
if (Test-Path -LiteralPath $todays_backup_dir) {
    	echo "========================================================"
	echo "Found an existing backup directory $todays_backup_dir.... deleting."
	echo "========================================================"
	Remove-Item -LiteralPath $todays_backup_dir -Recurse -Force
}
# Create the brand-new, empty folder
New-Item -Path $todays_backup_dir -ItemType Directory | Out-Null



echo "========================================================"
echo "Backing up to Destination directory $todays_backup_dir"
echo "========================================================"
xcopy $src $todays_backup_dir /E /D /C /Y > $log

try {
    # Attempt to create the zip file
    Compress-Archive -Path $todays_backup_dir -DestinationPath "$backupdir\$date.zip" -Force -ErrorAction Stop

    # If successful and file exists, delete the source folder
    if (Test-Path $backupdir\$date.zip) {
        Remove-Item -Path $todays_backup_dir -Recurse -Force
        Write-Output "Backup saved to $backupdir\$date.zip "
    }
}
catch {
    Write-Error "Zipping failed. Source folder will not be deleted. Error: $_"
}
