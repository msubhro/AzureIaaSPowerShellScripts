# This script Enable Azure Backup on multiple Azure VMs.

# Works on multiple Azure VMs in parallel, based on an input file.

# Recovery Services Vault and Azure Backup Policies must be created in advance.

# For Azure Backup solution to work, Azure VM and Recovery Services Vault must be in the same region.

# This script runs on PowerShell AZ Module.

# The script is tested only for Windows VM.

# Test before you use this script in a critical environment.

# Use at your own risk.

# Test Backup restoration.


$VMList = Get-Content "c:\serverlist.txt"

$VMLocation = 'NorthEurope'

$VMRGName = 'TestVMRG1'

# Make sure you have the ESV and Backup Policy created. RSV must be in the same region of the VM.


$BackupRSVName = 'TestBackupPolicy'

$BackupPolicyName = 'TestPolicy'


$Jobs = @()


$sblock = {
    
    Param (
     
        $VMName,
        $VMLocation,
        $VMRGName,
        $BackupRSVName,
        $BackupPolicyName
    )

  Get-AZRecoveryServicesVault -Name $BackupRSVName | Set-AzRecoveryServicesVaultContext

  $Policy = Get-AzRecoveryServicesBackupProtectionPolicy -Name $BackupPolicyName

  Enable-AzRecoveryServicesBackupProtection -ResourceGroupName $VMRGName -Name $VMName -Policy $Policy
    
       
}




foreach($VMName in $VMList)

{


$Jobs += start-job -ScriptBlock $sblock -ArgumentList $VMName,$VMLocation,$VMRGName,$BackupRSVName,$BackupPolicyName

Write-Host "  "

Write-host "Enabling Backup for $($VMName) ..."

Write-Host "  "


}

$jobs | Wait-Job | Receive-Job
