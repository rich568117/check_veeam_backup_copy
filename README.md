# check_veeam_backupcopy.ps1
```
Powershell scripts to check the status of Veeam Backups, Replications, and Backup Copies for use with Nagios Core v4.
``` 
Fork of the original script by Tytus Kurek at https://exchange.nagios.org/directory/Plugins/Backup-and-Recovery/Others/check_veeam_backups/details
Must have NRPE running on the Windows Server running Veeam Backup and Replication.

# Usage:
```
check_veeam_backup_copy.ps1 <NAME OF JOB> <NUMBER OF DAYS TO CHECK>
or
check_veeam_backup.ps1 <NAME OF JOB> <NUMBER OF DAYS TO CHECK>
```
# Nagios Command syntax:
```
$USER1$/check_nrpe -H $HOSTADDRESS$ -2 -n -c  $ARG1$ -t 60 
```
Note that timeout has been changed to 60 seconds with -t60 to accomodate the backup copy job checks. Those checks exceed the default 10 seconds. The 60 seconds is not necessary for regular backup jobs or replications.
# Nagios Usage in Host/Service:
```
define host {
	host_name                      	<YOUR HOSTNAME>
	alias                          	Check status of Veeam Backup
	address                        	<IP address or hostname>   #not actually used, but I enter the hostname/IP for uniformity
	check_command                  	check_veeam_backup_copy!<NAME OF JOB>!<NUMBER OF DAYS TO CHECK>!-t 60
	use                            	generic-host
	register                       	1
}	


define service {
	host_name                      	<YOUR HOSTNAME>
	service_description            	Check status of Veeam Backup
	active_checks_enabled          	1              #update as needed for your install, or omit if set at a parent level
	check_period                   	24x7           #update as needed for your install, or omit if set at a parent level
	notification_interval          	0              #update as needed for your install, or omit if set at a parent level
	notification_period            	24x7           #update as needed for your install, or omit if set at a parent level
	notifications_enabled          	1              #update as needed for your install, or omit if set at a parent level
	contact_groups                 	admins         #update as needed for your install, or omit if set at a parent level
	check_command                  	check_veeam_backup_copy!<NAME OF JOB>!<NUMBER OF DAYS TO CHECK>!-t 60
	use                            	generic-service
	register                       	1
}	
```
