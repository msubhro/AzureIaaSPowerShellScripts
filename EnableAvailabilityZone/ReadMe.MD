Using this script, you can put an Azure VM to an Availability Zone.

You cal also change the Availability Zone of an existing Azure VM using this script.

This script copies the disks of existing VM, and creates a new VM with the same name.

This script will delete existing VM, but original disks will be retained to follow a safer approach.

Before you run this script, please check that your Azure region supports Availability Zone.

Assign VM private IP address statically.

If your VM has Public IP address, then convert it to Standard and Static Public IP. Availability Zone does not work with Basic Public IP address.

We will use the original NIC in the new VM, to avoid any connectivity issue. So do not delete the original NIC.
