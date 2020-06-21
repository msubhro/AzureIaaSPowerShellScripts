- This script puts Azure VM(s) in a Proximity Placement Group (PPG).

- Works on multiple Azure VMs in parallel.

- This script does not create the PPG, it has to be created in advance.

- VMs must be deallocated before running this script.

- Ensure Azure VM agent is installed on target VM(s), before you execute this script.

- This script runs on PowerShell AZ Module.

- The script is tested only for Windows VM.

- Test before you use this script in a critical environment.

- Use at your own risk.

- Ref: https://docs.microsoft.com/en-us/azure/virtual-machines/windows/proximity-placement-groups#move-an-existing-vm-out-of-a-proximity-placement-group
