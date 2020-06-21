# This script deletes and recreates a VM with new name.

# It takes snapshots of original disks, and creates new disks with the new name and attaches with the new VM.

# The existing NIC is retained (and not recreated) to avoid any connectivity issue. Name of the NIC would not be changed.

# The Computer name within Operaing System must be changed manually.

# The original VM will be deleted, but original disks will be retained to follow a safer approach.

# If you want to put the new VM in Availability Zone, you can set the zone option.Otherwise you can leave it blank.

# If you want to use Availability Zone option, please check that your Azure region supports Availability Zone.

# We will use the original NIC in the new VM, to avoid any connectivity issue. So do not delete the original NIC.

# This script runs on PowerShell AZ Module.

# The script is tested only for Windows VM.

# Test before you use this script in a critical environment.

# Use at your own risk.
