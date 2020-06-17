Welcome to the CaptureAzureVMDetails V1.4 !


Using this script, you can capture below details of multiple Azure VMs:



• VM Name

• Location

• Size

• Availability Sets

• OS Disk Name, Disk Size

• Disk Encryption Status

• OS Name (Windows / Linux)

• Managed Disk (Yes / No)

• Storage Account Details (Name, Type)

• NIC Count, NIC Name

• Private IP, Public IP, Subnet Name. MAC address

• NSG Name

• Data Disk Count, Name, Size, Caching, Storage Account, LUN

 

The script will give you three different options to extract VM details:


1. Capture VM details for an entire Azure subscription (Current Subscription)

2. Capture VM details within an Azure Resource Group.

3. Capture details of a single VM.

 

The script will export all details to CSV to a location which you specify, and will generate two CSV files:


1. VMDetails.CSV

2. DataDiskDetails.CSV (If there is any Data Disk attached with any VM)

 

Please Note:

 
1. Before you run the script, you have to login to the Azure subscription so the script will get proper access. Inside the script, I have put “login-AzureRmAccount” as comment statement to avoid repeated Login Prompts.

2. This script assumes that the Azure VM and its associated resources (like Disks) are within same resource group. For example, if a VM is in Resource Group A, and a disk attached to it is in Resource Group B, the script will not be able to find the disk as it will search the disk in Resource Group A where the VM is located.

3. I have suppressed error messages by adding the statement ErrorActionPreference = 'SilentlyContinue'. If you want to see error messages, you can remove this.

4. This script has been programmed and tested in PowerShell 5.1 within Windows 2016 server.

5. During execution, the script will display user friendly messages in console to indicate what it is doing in the background.

6. The script is tested, but please test it from your end before running it in a production. I suggest to start with a single VM (option 3) and then gradually test option 2 and finally option 1.

7. Use at your own risk.

 
