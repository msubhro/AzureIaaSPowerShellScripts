1. This script deletes and recreates a VM with new name.

2. It takes snapshots of original disks, and creates new disks with the new name and attaches with the new VM.

3. The existing NIC is retained (and not recreated) to avoid any connectivity issue. Name of the NIC would not be changed.

4. The Computer name within Operaing System must be changed manually.

5. The original VM will be deleted, but original disks will be retained to follow a safer approach.

6. If you want to put the new VM in Availability Zone, you can set the zone option.Otherwise you can leave it blank.

7. If you want to use Availability Zone option, please check that your Azure region supports Availability Zone.

8. We will use the original NIC in the new VM, to avoid any connectivity issue. So do not delete the original NIC.

9. This script runs on PowerShell AZ Module.

10. The script is tested only for Windows VM.

11. Test before you use this script in a critical environment.

12. Use at your own risk.
