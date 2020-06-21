# Using this script, you can put an Azure VM to an Availability Zone.

# You cal also change the Availability Zone of an existing Azure VM using this script.

# This script copies the disks of existing VM, and creates a new VM with the same name.

# This script will delete existing VM, but original disks will be retained to follow a safer approach.

# Before you run this script, please check that your Azure region supports Availability Zone.

# Assign VM private IP address statically.

# If your VM has Public IP address, then convert it to Standard and Static Public IP. Availability Zone does not work with Basic Public IP address.

# We will use the original NIC in the new VM, to avoid any connectivity issue. So do not delete the original NIC.



$VMName = 'TestVM2'

$VMRGName = 'TestVMRG1'

$VMLocation = 'NorthEurope'

$AvailablityZone = '3'

$ErrorActionPreference = "Stop"

# Capturing existing VM Config

Write-Host " "

Write-Host "Capturing Existing VM Config ..."

Write-Host " "

$SourceVmObject = get-azvm -Name $VMName -ResourceGroupName $VMRGName

# Capturing original VM NIC details

$NicName = $SourceVmObject.NetworkProfile.NetworkInterfaces.id

$arr= $NicName -split '/'

$NicName1 = $arr[8]

$SourceNICID = (Get-AzNetworkInterface -ResourceGroupName $VMRGName -Name $NicName1).Id


# Deleting existing VM, keeping only the disks

Remove-AzVM -Name $VMName -ResourceGroupName $VMRgName -Force


# Creating object for new VM


$NewVmObject = New-AzVMConfig -VMName $VMName -VMSize $SourceVmObject.HardwareProfile.VmSize

# Creating NIC for new VM

Write-Host " "
Write-Host "Creating new Network Objects ..."
Write-Host " "
$subnetID = (Get-AzNetworkInterface -ResourceId $SourceVmObject.NetworkProfile.NetworkInterfaces[0].id).IpConfigurations.Subnet.id

# $nic = New-AzNetworkInterface -Name "$($VMName.ToLower())-new-nic" -ResourceGroupName $VMRGName -Location $VMLocation -SubnetId $SubnetId

Add-AzVMNetworkInterface -VM $NewVmObject -Id $SourceNICID


# Copying OS Disk


Write-Host " "
Write-Host "Copying OS Disk ..."
Write-Host " "
$SourceOsDiskSku = (get-azdisk -ResourceGroupName $SourceVmObject.ResourceGroupName -DiskName $SourceVmObject.StorageProfile.OsDisk.name).Sku.Name

$SourceOsDiskSnapConfig =  New-AzSnapshotConfig  -SourceUri $SourceVmObject.StorageProfile.OsDisk.ManagedDisk.Id -Location $SourceVmObject.Location -CreateOption copy

$SourceOsDiskSnap = New-AzSnapshot -Snapshot $SourceOsDiskSnapConfig  -SnapshotName "$($SourceVmObject.Name)-os-snap"  -ResourceGroupName $VMRGName

$TargetOsDiskConfig = New-AzDiskConfig -AccountType $SourceOsDiskSku -Location $VMLocation -CreateOption Copy -SourceResourceId $SourceOsDiskSnap.Id  -Zone $AvailablityZone

$TargetOsDisk = New-AzDisk -Disk $TargetOsDiskConfig -ResourceGroupName $VMRGName -DiskName "$($VMName.ToLower())-OS-Disk"

Set-AzVMOSDisk -VM $NewVmObject -ManagedDiskId $TargetOsDisk.Id -CreateOption Attach -Windows


# Copying Data Disk

Write-Host " "
Write-Host "Copying Data Disk(s) ..."
Write-Host " "
Foreach ($SourceDataDisk in $SourceVmObject.StorageProfile.DataDisks) { 

    $SourceDataDiskSku = (get-azdisk -ResourceGroupName $SourceVmObject.ResourceGroupName -DiskName $SourceDataDisk.name).Sku.Name

    $SourceDataDiskSnapConfig =  New-AzSnapshotConfig  -SourceUri $SourceDataDisk.ManagedDisk.Id -Location $SourceVmObject.Location -CreateOption copy

    $SourceDataDiskSnap = New-AzSnapshot -Snapshot $SourceDataDiskSnapConfig  -SnapshotName "$($SourceVmObject.Name)-$($SourceDataDisk.name)-snap"  -ResourceGroupName $SourceVmObject.ResourceGroupName

    $TargetDataDiskConfig = New-AzDiskConfig -AccountType $SourceDataDiskSku -Location $VMLocation -CreateOption Copy -SourceResourceId $SourceDataDiskSnap.Id  -Zone $AvailablityZone

    $TargetDataDisk = New-AzDisk -Disk $TargetDataDiskConfig -ResourceGroupName $VMRGName -DiskName "$($VMName.ToLower())-$($SourceDataDisk.lun)-Disk"


    Add-AzVMDataDisk -VM $NewVmObject -Name "$($VMName.ToLower())-$($SourceDataDisk.lun)-Disk" -ManagedDiskId $TargetDataDisk.Id -Lun $SourceDataDisk.lun -CreateOption "Attach"
}


Write-Host " "
Write-Host "Creating the new Azure VM with Availability zone enabled ..."
Write-Host " "
New-AzVM -VM $NewVmObject -ResourceGroupName $VMRGName -Location $VMLocation -Zone $AvailablityZone
Write-Host " "
Write-Host "New VM created with Availability Zone $($AvailablityZone).Your original VM disks are also retained, you can manually delete those disks."
Write-Host " "
Write-Host " "
Write-Warning "If your ogiginal VM had a basic Public IP, that would not work here because now the VM is now part of Availablity Zone. So you need to cretae a Standard Public IP address manually and attach with the new VM."

