#################################################################################
#################################################################################
####################  Made by Tytus Kurek on September 2012  ####################
#################################################################################
#################################################################################
###  This is a Nagios Plugin destined to check the last status and last run   ###
###        of Veeam Backup & Replication job passed as an argument.           ###
#################################################################################
#################################################################################
# Edits by Rich King July 2020

# Adding required SnapIn
Add-PSSnapin -Name VeeamPSSnapIn -ErrorAction SilentlyContinue

# Global variables
$name = $args[0]
$period = $args[1]

# Veeam Backup & Replication job status check
$job = Get-VBRJob -Name $name
$name = "'" + $name + "'"

# Check to see if a backup job with the provided name exists
if ($job -eq $null -or $period -eq $null)
{
	Write-Host "UNKNOWN! No such job: $name."
	exit 3
}

# Get the result of the last job and exit if failed or anything other than success.
$status = $job.GetLastResult()

if($($job.findlastsession()).State -eq "Working"){
	Write-Host "OK! Backup or Replication Job: $name is currently in progress."
	exit 0
}
if ($status -eq "Failed")
{
	Write-Host "CRITICAL! Errors were encountered during the backup process of the following job: $name."
	exit 2
}
if ($status -ne "Success")
{
	Write-Host "WARNING! Job $name didn't fully succeed."
	exit 1
}
	
# Check the last run of this backup copy job.
$now = (Get-Date).AddDays(-$period)
$now = $now.ToString("yyyy-MM-dd")
$last = $job.GetScheduleOptions()
$last = $last -replace '.*Latest run time: \[', ''
$last = $last -replace '\], Next run time: .*', ''
$last = $last.split(' ')[0]

#changed by DY on 11/04/2014 based on comment from cmot-weasel at http://exchange.nagios.org/directory/Plugins/Backup-and-Recovery/Others/check_veeam_backups/details
#if ($now -gt $last)
if((Get-Date $now) -gt (Get-Date $last))
{
	Write-Host "CRITICAL! Last run of job: $name more than $period days ago."
	exit 2
} 
else
{
	Write-Host "OK! Backup job $name completed successfully."
	exit 0
}
