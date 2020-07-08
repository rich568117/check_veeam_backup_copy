#################################################################################
#################################################################################
#######################  Reworked by Rich King July 2020  #######################
#################################################################################
#################################################################################
###  This is a Nagios Plugin designed by Tytus Kurek to check the last status ###
#####  and last run of Veeam backup jobs, reworked for backup copy jobs.    #####
#################################################################################
#################################################################################

# Usage: check_veeam_backupcopy.ps1 <NAME OF JOB> <NUMBER OF DAYS TO CHECK>
# Example: check_veeam_backupcopy.ps1 'Test Job' 1

# Adding required SnapIn
Add-PSSnapin -Name VeeamPSSnapIn -ErrorAction SilentlyContinue

# Global variables
$Name = $args[0]
$Period = $args[1]
$CopyJob = $null
$Job = $null
$Last = $null

# Pull Job from VBR
$Job = Get-VBRJob -Name $Name
$Name = "'" + $Name + "'"

# Check if this is a valid job, timeframe, or if there was any missing arguments
if ($Job.IsContinuous -ne 'True' -or $null -eq $Period) {
	Write-Host "UNKNOWN! No backup copy job: $Name, or no job/period specified."
	exit 3
}

$CopyJob = (Get-VBRBackupSession | Where-Object {$_.jobId -eq $Job.Id.Guid} | Sort-Object EndTimeUTC -Descending | Select-Object -First $Period)
$status = ($CopyJob.Result | Select-Object -first 1)

if ($CopyJob.IsWorking -eq "True" -or $status -eq "None" -or $Job.IsContinuous -eq 'True') {
	Write-Host "OK! Backup copy job: $Name is currently in progress but has not completed."
	exit 0
}
if ($status -ne "Success") {
	Write-Host "CRITICAL! Something prevented the backup copy process of the job: $Name."
	exit 2
}

# Function to run a check on the last run to see if it has been within the period provided
function Get-LastRun {
	$now = ((Get-Date).AddDays(-$Period))
	$now = $now.ToString("yyyy-MM-dd")
	$Last = (($CopyJob.EndTime) | Select-Object -first 1)
	$Last = $Last.ToString("yyyy-MM-dd")

	if((Get-Date $now) -gt (Get-Date $Last))
	{
		Write-Host "CRITICAL! Last run of backup copy job: $Name more than $Period days ago."
		exit 2
	} 
	else
	{
		Write-Host "OK! Backup copy process of job $Name completed successfully."
		exit 0
	}
	Write-Host "WARNING! Backup copy job $Name hasn't fully succeed in the last $Period days."
	exit 1
}

Get-LastRun
