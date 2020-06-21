# This script deletes and recreates a VM with new name, using existing VM disks and NIC.

# The system name within the Operaing System must be changed manually.

# The original VM will be deleted, but original disks will be retained to follow a safer approach.

# If you want to put the new VM in Availability Zone, you can set the zone option.Otherwise you can leave it blank.

# If you want to use Availability Zone option, please check that your Azure region supports Availability Zone.

# We will use the original NIC in the new VM, to avoid any connectivity issue. So do not delete the original NIC.


$vmOldName = 'TestVM6'

$vmNewName = 'NewTestVM6'

$rgName = 'TestVMRG1'

$VMLocation = 'NorthEurope'

$AvailablityZone = '2'


$ErrorActionPreference = "Stop"

Write-Host " "

Write-Host "Capturing Existing VM Config ..."

Write-Host " "

$SourceVmObject = get-azvm -Name $vmOldName -ResourceGroupName $rgName


$SourceVmPowerStatus = (get-azvm -Name $SourceVmObject.Name -ResourceGroupName $SourceVmObject.ResourceGroupName -Status).Statuses[1].DisplayStatus

if ($SourceVmPowerStatus -eq "VM running") 

   {

    stop-azVm -Name $SourceVmObject.Name -ResourceGroupName $SourceVmObject.ResourceGroupName -Force

    
   }

Write-Host " "

Write-Host "Creating new VM object..."

Write-Host " "   

$NewVmObject = New-AzVMConfig -VMName $vmNewName -VMSize $SourceVmObject.HardwareProfile.VmSize 

$NicID = $SourceVmObject.NetworkProfile.NetworkInterfaces[0].id


$subnetID = (Get-AzNetworkInterface -ResourceId $NicID).IpConfigurations.Subnet.id

# Deleting existing VM, keeping disks and NIC

Write-Host " "

Write-Host "Deleting existing VM, keeping disk and NIC ..."

Write-Host " "


Remove-AzVM -Name $vmOldName -ResourceGroupName $rgName -Force

# Attaching existing NIC to the new VM

Write-Host " "

Write-Host "Attaching existing NIC to the new VM ..."

Write-Host " "

Add-AzVMNetworkInterface -VM $NewVmObject -Id $NicID


if ([string]::IsNullOrEmpty($AvailablityZone)) {

Write-Host " "
Write-Host "You have decided to provision the new VM without any Availability Zone..."
Write-Host " "


Write-Host " "
Write-Host "Copying OS Disk ..."
Write-Host " "
$SourceOsDiskSku = (get-azdisk -ResourceGroupName $SourceVmObject.ResourceGroupName -DiskName $SourceVmObject.StorageProfile.OsDisk.name).Sku.Name

$SourceOsDiskSnapConfig =  New-AzSnapshotConfig  -SourceUri $SourceVmObject.StorageProfile.OsDisk.ManagedDisk.Id -Location $SourceVmObject.Location -CreateOption copy

$SourceOsDiskSnap = New-AzSnapshot -Snapshot $SourceOsDiskSnapConfig  -SnapshotName "$($SourceVmObject.Name)-os-snap"  -ResourceGroupName $rgName

$TargetOsDiskConfig = New-AzDiskConfig -AccountType $SourceOsDiskSku -Location $VMLocation -CreateOption Copy -SourceResourceId $SourceOsDiskSnap.Id

$TargetOsDisk = New-AzDisk -Disk $TargetOsDiskConfig -ResourceGroupName $rgName -DiskName "$($vmNewName.ToLower())-os-vhd"

Set-AzVMOSDisk -VM $NewVmObject -ManagedDiskId $TargetOsDisk.Id -CreateOption Attach -Windows

Write-Host " "
Write-Host "Copying Data Disk(s) ..."
Write-Host " "
Foreach ($SourceDataDisk in $SourceVmObject.StorageProfile.DataDisks) { 

    $SourceDataDiskSku = (get-azdisk -ResourceGroupName $SourceVmObject.ResourceGroupName -DiskName $SourceDataDisk.name).Sku.Name

    $SourceDataDiskSnapConfig =  New-AzSnapshotConfig  -SourceUri $SourceDataDisk.ManagedDisk.Id -Location $SourceVmObject.Location -CreateOption copy

    $SourceDataDiskSnap = New-AzSnapshot -Snapshot $SourceDataDiskSnapConfig  -SnapshotName "$($SourceVmObject.Name)-$($SourceDataDisk.name)-snap"  -ResourceGroupName $SourceVmObject.ResourceGroupName

    $TargetDataDiskConfig = New-AzDiskConfig -AccountType $SourceDataDiskSku -Location $VMLocation -CreateOption Copy -SourceResourceId $SourceDataDiskSnap.Id

    $TargetDataDisk = New-AzDisk -Disk $TargetDataDiskConfig -ResourceGroupName $rgName -DiskName "$($vmNewName.ToLower())-$($SourceDataDisk.lun)-vhd"


    Add-AzVMDataDisk -VM $NewVmObject -Name "$($vmNewName.ToLower())-$($SourceDataDisk.lun)-vhd" -ManagedDiskId $TargetDataDisk.Id -Lun $SourceDataDisk.lun -CreateOption "Attach"
}

Write-Host " "
Write-Host "Creating the new Azure VM ..."
Write-Host " "
New-AzVM -VM $NewVmObject -ResourceGroupName $rgName -Location $VMLocation
Write-Host " "
Write-Host "New VM created without any Availibility Zone."
Write-Host " "

}

else {

Write-Host " "
Write-Host "You have decided to provision the new VM in Availability Zone $($AvailablityZone)..."
Write-Host " "

Write-Host " "
Write-Host "Copying OS Disk ..."
Write-Host " "
$SourceOsDiskSku = (get-azdisk -ResourceGroupName $SourceVmObject.ResourceGroupName -DiskName $SourceVmObject.StorageProfile.OsDisk.name).Sku.Name

$SourceOsDiskSnapConfig =  New-AzSnapshotConfig  -SourceUri $SourceVmObject.StorageProfile.OsDisk.ManagedDisk.Id -Location $SourceVmObject.Location -CreateOption copy

$SourceOsDiskSnap = New-AzSnapshot -Snapshot $SourceOsDiskSnapConfig  -SnapshotName "$($SourceVmObject.Name)-os-snap"  -ResourceGroupName $rgName

$TargetOsDiskConfig = New-AzDiskConfig -AccountType $SourceOsDiskSku -Location $VMLocation -CreateOption Copy -SourceResourceId $SourceOsDiskSnap.Id -Zone $AvailablityZone

$TargetOsDisk = New-AzDisk -Disk $TargetOsDiskConfig -ResourceGroupName $rgName -DiskName "$($vmNewName.ToLower())-os-vhd"

Set-AzVMOSDisk -VM $NewVmObject -ManagedDiskId $TargetOsDisk.Id -CreateOption Attach -Windows

Write-Host " "
Write-Host "Copying Data Disk(s) ..."
Write-Host " "
Foreach ($SourceDataDisk in $SourceVmObject.StorageProfile.DataDisks) { 

    $SourceDataDiskSku = (get-azdisk -ResourceGroupName $SourceVmObject.ResourceGroupName -DiskName $SourceDataDisk.name).Sku.Name

    $SourceDataDiskSnapConfig =  New-AzSnapshotConfig  -SourceUri $SourceDataDisk.ManagedDisk.Id -Location $SourceVmObject.Location -CreateOption copy

    $SourceDataDiskSnap = New-AzSnapshot -Snapshot $SourceDataDiskSnapConfig  -SnapshotName "$($SourceVmObject.Name)-$($SourceDataDisk.name)-snap"  -ResourceGroupName $SourceVmObject.ResourceGroupName

    $TargetDataDiskConfig = New-AzDiskConfig -AccountType $SourceDataDiskSku -Location $VMLocation -CreateOption Copy -SourceResourceId $SourceDataDiskSnap.Id -Zone $AvailablityZone

    $TargetDataDisk = New-AzDisk -Disk $TargetDataDiskConfig -ResourceGroupName $rgName -DiskName "$($vmNewName.ToLower())-$($SourceDataDisk.lun)-vhd"


    Add-AzVMDataDisk -VM $NewVmObject -Name "$($vmNewName.ToLower())-$($SourceDataDisk.lun)-vhd" -ManagedDiskId $TargetDataDisk.Id -Lun $SourceDataDisk.lun -CreateOption "Attach"
}

Write-Host " "
Write-Host "Creating the new Azure VM ..."
Write-Host " "
New-AzVM -VM $NewVmObject -ResourceGroupName $rgName -Location $VMLocation -Zone $AvailablityZone
Write-Host " "
Write-Host "New VM created with Availibility Zone $($AvailablityZone)"
Write-Host " "

}