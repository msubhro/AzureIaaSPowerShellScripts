# This script encrypts Azure Windows VM volumes with the help of Azure Disk Encryption.

# The Encryption Keys and Secrets are stored in Azure Key Vault.

# Your account should have appropriate access policy in Azure Key Vault, to read / get secrets and keys.

# Key Encryption Key must be present in Azure Key Vault.

# Disk Encryption must be enabled in Azure Key Vault.

# This script is applicable only for Azure Windows VMs.

# This script will run on multiple VMs in parallel.


$KeyVaultName = ''

$KeyVaultRGName = ''

# Key Encryption Key Name

$KeyName = ''

$VMList = Get-Content "C:\serverlist.txt"

$VMRGName = ''


$Jobs = @()

$sblock = {
    
    Param (
        $KeyVaultName,
        $KeyVaultRGName,
        $KeyName,
        $VMName,
        $VMRGName
    )

    $KeyVault = Get-AzKeyVault -VaultName $KeyVaultName -ResourceGroupName $KeyVaultRGName

    $DiskEncryptionKeyVaultURI = $KeyVault.VaultUri

    $KeyVaultResourceID = $KeyVault.ResourceId

    $KeyEncryptionKeyUrl = (Get-AzKeyVaultKey -VaultName $KeyVaultName -Name $KeyName).key.Kid

   
     Set-AzVMDiskEncryptionExtension -ResourceGroupName $VMRGName -VMName $VMName -DiskEncryptionKeyVaultUrl $DiskEncryptionKeyVaultURI -DiskEncryptionKeyVaultId $KeyVaultResourceID -KeyEncryptionKeyUrl $KeyEncryptionKeyUrl -KeyEncryptionKeyVaultId $KeyVaultResourceID -Force
    
       
}


foreach($VMName in $VMList)

{


$Jobs += start-job -ScriptBlock $sblock -ArgumentList $KeyVaultName,$KeyVaultRGName,$KeyName,$VMName,$VMRGName

Write-Host "  "

Write-host "Enabling Disk Encryption for $($VMName) ..."

Write-Host "  "


}

$jobs | Wait-Job | Receive-Job