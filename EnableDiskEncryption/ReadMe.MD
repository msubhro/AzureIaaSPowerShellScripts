- This script encrypts Azure Windows VM volumes with the help of Azure Disk Encryption.

- The Encryption Keys and Secrets are stored in Azure Key Vault.

- Your account should have appropriate access in Azure Key Vault, to read / get secrets and keys. Use Key Vault access policy.

- Key Encryption Key must be present in Azure Key Vault, which will be used to wrap the bitlocker secret.

- Disk Encryption must be enabled in Azure Key Vault.

- This script is applicable only for Azure Windows VMs.

- This script will run on multiple VMs in parallel.

- This script runs on PowerShell AZ Module.

- The script is tested only for Windows VM.

- Test before you use this script in a critical environment.

- Use at your own risk.

- For more details on how to enable Azure Disk Encryption, please read my article: https://social.technet.microsoft.com/wiki/contents/articles/53496.azure-disk-encryption-configure-for-azure-windows-vms.aspx?Sort=MostUseful&PageIndex=1
