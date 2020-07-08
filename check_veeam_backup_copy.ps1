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
$name = $args[0]
$period = $args[1]
$copyjob = $null
$job = $null
$last = $null

# Pull Job from VBR
$job = Get-VBRJob -Name $name
$name = "'" + $name + "'"

# Check if this is a valid job, timeframe, or if there was any missing arguments
if($job.IsContinuous -ne 'True' -or $period -eq $null)
{
	Write-Host "UNKNOWN! No backup copy job: $name, or no job/period specified."
	exit 3
}

$copyjob=(Get-VBRBackupSession | Where {$_.jobId -eq $job.Id.Guid} | Sort EndTimeUTC -Descending | Select -First $period)
$status = ($copyjob.Result | select-object -first 1)

if($copyjob.IsWorking -eq "True" -or $status -eq "None" -or $job.IsContinuous -eq 'True'){
	Write-Host "OK! Backup copy job: $name is currently in progress but has not completed."
	exit 0
}
if ($status -ne "Success")
{
	Write-Host "CRITICAL! Something prevented the backup copy process of the job: $name."
	exit 2
}

# Function to run a check on the last run to see if it has been within the period provided
function Last-Run {
	$now = ((Get-Date).AddDays(-$period))
	$now = $now.ToString("yyyy-MM-dd")
	$last = (($copyjob.EndTime) | select-object -first 1)
	$last=$last.ToString("yyyy-MM-dd")

	if((Get-Date $now) -gt (Get-Date $last))
	{
		Write-Host "CRITICAL! Last run of backup copy job: $name more than $period days ago."
		exit 2
	} 
	else
	{
		Write-Host "OK! Backup copy process of job $name completed successfully."
		exit 0
	}
	Write-Host "WARNING! Backup copy job $name hasn't fully succeed in the last $period days."
	exit 1
}
Last-Run
