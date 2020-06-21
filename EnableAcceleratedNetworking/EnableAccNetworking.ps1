# This script Enable Accelered Networking for Azure VM(s).

# VM must be deallocated before running this script.

# VM Size must support Accelerated Networking. Not all Azure VM supports Accelerated Networking.

$VMList = get-content 'c:\serverlist.txt'

$VMRGName = 'VMResourceGroupName'


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

$nic.EnableAcceleratedNetworking = $true

$nic | Set-AzNetworkInterface


       
}


foreach($VMName in $VMList)

{


$Jobs += start-job -ScriptBlock $sblock -ArgumentList $VMName,$VMRGName

Write-Host "  "

Write-host "Enabling Accelerated Networking on $($VMName) ..."

Write-Host "  "


}

$jobs | Wait-Job | Receive-Job