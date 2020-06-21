# By default, Azure VM Private IPs are assigned as Dynamic IP.

# This script will change the private IP assignment type to Static.

# Works on multiple Azure VMs in parallel.

# VMs must be deallocated before running this script.

# Ensure Azure VM agent is installed on target VM(s), before you execute this script.

# This script runs on PowerShell AZ Module.

# The script is tested only for Windows VM.

# Test before you use this script in a critical environment.


$VMName = get-content 'c:\serverlist.txt'

$VMRGName = 'TestVMRG1'


$Jobs = @()



$sblock = {
    
    Param (
        $VMName,
        $VMRGName
        
    )


$vmdetails= Get-AzVM -ResourceGroupName $VMRGName -Name $VMName

$NicName = $vmdetails.NetworkProfile.NetworkInterfaces[0].Id

$arr= $NicName -split '/'

$NicName1 = $arr[8]

$Nic = Get-AzNetworkInterface -ResourceGroupName $VMRgName -Name $NicName1

$nic.IpConfigurations[0].PrivateIpAllocationMethod = "Static"

$nic | Set-AzNetworkInterface


       
}


foreach($VMName in $VMList)

{


$Jobs += start-job -ScriptBlock $sblock -ArgumentList $VMName,$VMRGName

Write-Host "  "

Write-host "Enabling Private Static IP on $($VMName) ..."

Write-Host "  "


}

$jobs | Wait-Job | Receive-Job