
# login-AzureRmAccount

$ErrorActionPreference = 'SilentlyContinue '


function Show-Menu

{


     param (
           [string]$Title = 'Welcome to CaptureAzureVMDetails V1.4!'
     )
     cls
     Write-Host "                   "
     Write-Host "                   "
     Write-Host "=========================$Title =========================" -ForegroundColor Yellow -BackgroundColor Black
     Write-Host "                   "
     
     Write-Host "Using this script , you can capture details of multiple Azure VMs."
     Write-Host "                   "
     Write-Host "You can run this script against an entire Azure Subscription, a Resource Group or a Single Azure VM."
     Write-Host "                   "
     Write-Host "This script assumes that an Azure VM and it's associated resources (like Disks) are within same resource group."
     Write-Host "                   "
     Write-Host "Please make sure you have read permission in all Resource Groups, if you are running it for the entire subscription."
     Write-Host "                   "
     Write-Warning "Test before you use, and run at your own risk."

     Write-Host "                   "

     Write-Host "-------------------------------MENU--------------------------------"
     Write-Host "                   "
     Write-Host "1: Press 1 to capture VM details for an entire Azure subscription (Current Subscription)."
     Write-Host "                   "
     Write-Host "2: Press 2 to capture VM details within an Azure Resource Group."
     Write-Host "                   "
     Write-Host "3: Press 3 to Capture details of a single VM."
     Write-Host "                   "
     Write-Host "Q: Press 'Q' to quit this Program."
     Write-Host "                   "
     Write-Host "--------------------------------------------------------------------"
     Write-Host "                   "

}




function CaptureVMDetails

{

foreach ($vm in $vmlist)

{

Write-Host ("  ")

Write-Host ("---------------------------------------- ")


Write-Host "Capturing Details of the VM $VM" -ForegroundColor Black -BackgroundColor White


Write-Host ("---------------------------------------- ")


$vmdetails= Get-AzureRmVM -ResourceGroupName $ResourceGroup -Name $vm

Write-Host (" ")

Write-Host ("Capturing VM Location for VM $VM")

$vmlocation= $vmdetails.Location

Write-Host (" ")

Write-Host ("Capturing Size of the VM $VM")

$VMSize = $vmdetails.HardwareProfile.VmSize

# Details about Availibility Set

Write-Host (" ")

Write-Host ("Capturing Availibility Set of the VM $VM")

$availibilityset= $vmdetails.AvailabilitySetReference.Id


if ($availibilityset -eq $null)

{

$availibilityset1= "None"

}

else

{

$arr = $availibilityset -split '/'

$availibilityset1= $arr[8]

}

Write-Host (" ")

Write-Host ("Capturing OS Type of the VM $VM")

$OS = $vmdetails.StorageProfile.OsDisk.OsType

# Managed Disk or Unmanaged Disk

$ManagedDisk = $vmdetails.StorageProfile.OsDisk.ManagedDisk


if ($ManagedDisk -eq $null)

{

$ManagedDisk1= "No"

}

else

{

$ManagedDisk1= "Yes"

}


# Details about OS Disk

Write-Host (" ")

Write-Host ("Capturing OS Disk Details of the VM $VM")

if ($ManagedDisk1 -eq "No")

{

$vhd= $vmdetails.StorageProfile.OsDisk.Vhd.Uri

$arr= $vhd -split '/'

$OSDiskName = $arr[4]

}

else

{

$vhd= $vmdetails.StorageProfile.OsDisk.Name


$OSDiskName = (get-azurermdisk -ResourceGroupName $ResourceGroup -Name $vhd).Name


}

if ($ManagedDisk1 -eq "No")

{

$OSDiskSize= $vmdetails.StorageProfile.OsDisk.DiskSizeGB

}

else

{

$OSDiskSize = (get-azurermdisk -ResourceGroupName $ResourceGroup -DiskName $vhd).DiskSizeGB

}

$OSDiskCaching = $vmdetails.StorageProfile.OsDisk.Caching

# End of OS Disk

Write-Host (" ")

Write-Host ("Capturing NIC details of the VM $VM")

$NICCount = $vmdetails.NetworkProfile.NetworkInterfaces.Count

$NicName = $vmdetails.NetworkProfile.NetworkInterfaces.id

$arr= $NicName -split '/'

$NicName1 = $arr[8]

$Nic = Get-AzureRmNetworkInterface -ResourceGroupName $ResourceGroup -Name $NicName1

Write-Host (" ")

Write-Host ("Capturing Private & Public IP details for $VM")

$PrivateIPAddress = $Nic.IpConfigurations[0].PrivateIpAddress

$PrivateIpAllocationMethod = $Nic.IpConfigurations[0].PrivateIpAllocationMethod

$PublicIP1= $Nic.IpConfigurations[0].PublicIpAddress.Id

$PublicIP2 = $PublicIP1 -split '/'

$PublicIP3= $PublicIP2[8]

$PublicIP = (Get-AzureRmPublicIpAddress -Name $PublicIP3 -ResourceGroupName $ResourceGroup).IpAddress

# Capturing Subnet Details

Write-Host (" ")

Write-Host ("Capturing Subnet details for the VM $VM")

$NICProperty = Get-AzureRmNetworkInterface -ResourceGroupName $ResourceGroup -Name $NicName1

$subnet2=$NICProperty.IpConfigurations[0].Subnet.Id

$subnet3 = $subnet2 -split '/'

$subnet= $subnet3[10]

Write-Host (" ")

Write-Host ("Capturing NSG, MAC Address and DNS Server for $VM")

$NSG1 = $NICProperty.NetworkSecurityGroup.Id

$NSG2 = $NSG1 -split '/'

$NSG = $NSG2[8]

$MacAddress = $NICProperty.MacAddress


Write-Host (" ")

Write-Host ("Capturing OS & Data Volume Encryption Status of $VM")

$OSVolumeEncrypted = (Get-AzureRmVMDiskEncryptionStatus -ResourceGroupName $resourcegroup -VMName $vm).OsVolumeEncrypted

$DataVolumeEncrypted = (Get-AzureRmVMDiskEncryptionStatus -ResourceGroupName $resourcegroup -VMName $vm).DataVolumesEncrypted

Write-Host (" ")

Write-Host ("Capturing Data Disk Count of the VM $VM")

$datadiskcount = $vmdetails.StorageProfile.DataDisks.Count

# Capture Storage Account Details for OS Disk

if ($ManagedDisk1 -eq "No")

{

$URI= $vmdetails.StorageProfile.OsDisk.Vhd.Uri

$URI1 = $URI -split '/'

$URI2= $URI1[2]

$URI3=$URI2 -split '\.'

$StorageAccountName= $URI3[0]

$StorageAccountType= (Get-AzureRmStorageAccount -ResourceGroupName $ResourceGroup -AccountName $StorageAccountName).Sku.Name

}

else

{

$StorageAccountName= "Managed by Azure"

$StorageAccountType = "Managed by Azure"



}



########Capture VM Details and Export to a Report##########

$MyHashTable = [ordered]@{


VMName= $vm

Location = $vmlocation

VMSize= $VMSize

AvailabilitySet=$availibilityset1

OsDiskName=$OSDiskName

OSDiskSizeinGiB = $OSDiskSize

OSVolumeEncrypted = $OSVolumeEncrypted

DataVolumeEncrypted = $DataVolumeEncrypted

OSDiskCaching = $OSDiskCaching

OS = $OS

ManagedDisk = $ManagedDisk1

StorageAccountName = $StorageAccountName

StorageAccountType = $StorageAccountType

DataDiskCount= $datadiskcount

NICCount = $NICCount

NICName = $NicName1

PrivateIPAddress= $PrivateIPAddress

PrivateIpAllocationMethod = $PrivateIpAllocationMethod

PublicIP = $PublicIP

Subnet = $subnet

NetworkSecurityGroup = $NSG

MacAddress = $MacAddress


}

$report = [pscustomobject]$MyHashTable

$report | export-csv -Path "$path\VMDetails.CSV" -NoTypeInformation -Append

############# End of VM Report Export ##################


##############Capture Data Disk Details and Export to a Report ###########

if ( $datadiskcount -ge 1 )

{

Write-Host (" ")

Write-Host "Found $datadiskcount Data Disk(s) attached with $VM, capturing details" -ForegroundColor Cyan

for ($i=0;$i -le ($datadiskcount-1); $i++)

{


$DataDiskSize = $vmdetails.StorageProfile.DataDisks[$i].DiskSizeGB

$DataDiskCaching = $vmdetails.StorageProfile.DataDisks[$i].Caching

$DataDiskName = $vmdetails.StorageProfile.DataDisks[$i].name

$DataDiskManaged1 = $vmdetails.StorageProfile.DataDisks[$i].ManagedDisk

if ($DataDiskManaged1 -eq $null)

{

$DataDiskManaged = "No"

}

else

{

$DataDiskManaged = "Yes"

}


if ($DataDiskManaged -eq "No")

{

$DataDiskURI= $vmdetails.StorageProfile.DataDisks[$i].Vhd.Uri

$DataDiskURI1 = $DataDiskURI -split '/'

$DataDiskURI2= $DataDiskURI1[2]

$DataDiskURI3= $DataDiskURI2 -split '\.'

$DataStorageAccountName= $DataDiskURI3[0]

$DataStorageAccountType= (Get-AzureRmStorageAccount -ResourceGroupName $ResourceGroup -AccountName $DataStorageAccountName).Sku.Name

}

else

{

$DataDiskURI= $vmdetails.StorageProfile.DataDisks[$i].ManagedDisk.Id

$DataStorageAccountName= "Managed by Azure"

$DataStorageAccountType= $vmdetails.StorageProfile.Datadisks[$i].ManagedDisk.StorageAccountType

}




$DataDiskLUN = $vmdetails.StorageProfile.DataDisks[$i].Lun


$MyHashTable1 = [ordered]@{

VMName= $vm

DataDiskName = $DataDiskName

DataDiskSizeInGiB = $DataDiskSize

DataDiskCaching = $DataDiskCaching

Managed = $DataDiskManaged

StorageAccountName = $DataStorageAccountName

StorageAccountType = $DataStorageAccountType


LUN = $DataDiskLUN

   }


$DataDiskReport= [pscustomobject]$MyHashTable1



$DataDiskReport | export-csv -Path "$path\ DataDiskDetails.csv" -NoTypeInformation -Append



}

##########End of Data Disk Counter Loop (i) ##########


}

######End of IF Statement###############

else 

{  

Write-Host (" ")

Write-Host "No Data Disk is attached with the VM $VM" -ForegroundColor Cyan

Write-Host (" ")
}


}

#########End of VM Loop#################

}

#########End of Function CaptureVmDetails#################





do
{
     Show-Menu

     $input = Read-Host "Please make a selection"

     switch ($input)

     {


                '1' {
                cls

                Write-Host ("     ")

                'You have selected option #1: Capture VM Details within an Azure Subscription.'
               
                Write-Host (" ")

                

Write-Host ("     ")

$path = Read-Host ("Enter output file path. Ex: c:\temp")

Write-Host ("     ")

Write-Host ("Two files will be created in the above mentioned path. 1) VMDetails.CSV 2) DataDiskDetails.csv. If no VM has data disk, the second file will not be created.")

Write-Host ("     ")

$ResourceGroupList = (Get-AzureRmResourceGroup).ResourceGroupName

foreach ($ResourceGroup in $ResourceGroupList)

{

Write-Host ("------------------------------------------------------------------------------------")

Write-Host (" ")

Write-Host "Preparing VM List in Resource Group $ResourceGroup" -ForegroundColor Yellow -BackgroundColor Black

Write-Host (" ")

Write-Host ("------------------------------------------------------------------------------------")

$vmlist= (Get-AzureRmVM -ResourceGroupName $ResourceGroup).Name


if (($vmlist -eq $null) -or ($vmlist -eq 0))

{

Write-Host ("  ")

write-host "No Azure VM found in the Resource Group $Resourcegroup" -ForegroundColor Yellow

Write-Host ("  ")

Write-Host ("  ")

}

else

{

CaptureVMDetails

}

}

Write-Host (" ")

Write-Host (" ")

Write-Host (" ")


Write-Host "It's Done, check output file(s) at $path!" -ForegroundColor Yellow


Write-Host (" ")

Write-Host (" ")              

                  } 




           '2' {
                cls

                Write-Host ("     ")

                'You have selected option #2: Capture VM details within an Azure Resource Group.'
               
                Write-Host (" ")

$ResourceGroup = Read-Host ("Enter Resource Group Name.")

Write-Host ("     ")

$path = Read-Host ("Enter output file path. Ex: c:\temp")

Write-Host ("     ")

Write-Host ("Two files will be created in the above mentioned path. 1) VMDetails.CSV 2) DataDiskDetails.csv. If no VM has data disk, the second file will not be created.")

Write-Host ("     ")

Write-Host ("---------------------------------------------------------------")

Write-Host "Preparing VM List in Resource Group $ResourceGroup" -ForegroundColor Yellow -BackgroundColor Black

Write-Host ("---------------------------------------------------------------")

Write-Host ("     ")

$vmlist= (Get-AzureRmVM -ResourceGroupName $ResourceGroup).Name

if (($vmlist -eq $null) -or ($vmlist -eq 0))

{

Write-Host ("  ")

write-host "No Azure VM found in the Resource Group $Resourcegroup" -ForegroundColor Yellow

Write-Host ("  ")

Write-Host ("  ")

}

else

{

CaptureVMDetails 

}

Write-Host (" ")

Write-Host (" ")

Write-Host (" ")


Write-Host "It's Done, check output file(s) at $path!" -ForegroundColor Yellow


Write-Host (" ")

Write-Host (" ")              

                  } 



           '3' {
                cls

                Write-Host ("     ")

                'You have selected option #3: Capture details of a single Azure VM.'
               
                Write-Host (" ")

$vmlist = Read-Host ("Enter Azure VM Name.")

Write-Host ("     ")

$ResourceGroup = Read-Host ("Enter Azure Resource Group Name.")

Write-Host ("     ")

$path = Read-Host ("Enter output file path. Ex: c:\temp")

Write-Host ("     ")

Write-Host ("Two files will be created in the above mentioned path. 1) VMDetails.CSV 2) DataDiskDetails.csv. If no VM has data disk, the second file will not be created.")

Write-Host ("     ")


CaptureVMDetails 

Write-Host (" ")

Write-Host (" ")

Write-Host (" ")


Write-Host "It's Done, check output file(s) at $path!" -ForegroundColor Yellow


Write-Host (" ")

Write-Host (" ")              

                  } 



 'q' {
                return
               }
     }
     pause
}
until ($input -eq 'q')


