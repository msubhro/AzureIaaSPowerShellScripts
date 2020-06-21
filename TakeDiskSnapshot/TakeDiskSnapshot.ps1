# This script takes snapshot of OS and Data Disks , which are attached with an Azure VM.

# You can take snapshots of multiple systems, based on an input file.

# Tested only on Windows VMs.

# Ensure Azure VM agent is installed on target VM(s), before you execute this script.

# This script runs on PowerShell AZ Module.

# The script is tested only for Windows VM.

# Test before you use this script in a critical environment.



Use at your own risk.


$VMList = Get-Content -Path 'c:\serverlist.txt'

$VMRGName = 'TestVMRG1'

$ErrorActionPreference = "Stop"


foreach ($VMName in $VMList) {


# Capturing existing VM Config

Write-Host " "

Write-Host "Capturing Existing VM Config of $($VMName) ..."

Write-Host " "

$SourceVmObject = get-azvm -Name $VMName -ResourceGroupName $VMRGName


# Taking OS Disk Snapshot


Write-Host " "
Write-Host "Copying OS Disk for $($VMName) ..."
Write-Host " "
$SourceOsDiskSku = (get-azdisk -ResourceGroupName $SourceVmObject.ResourceGroupName -DiskName $SourceVmObject.StorageProfile.OsDisk.name).Sku.Name

$SourceOsDiskSnapConfig =  New-AzSnapshotConfig  -SourceUri $SourceVmObject.StorageProfile.OsDisk.ManagedDisk.Id -Location $SourceVmObject.Location -CreateOption copy

$SourceOsDiskSnap = New-AzSnapshot -Snapshot $SourceOsDiskSnapConfig  -SnapshotName "$($SourceVmObject.Name)-OS-Snap"  -ResourceGroupName $VMRGName



# Taking Data Disk Snapshot

Write-Host " "
Write-Host "Copying Data Disk(s) of $($VMName) ..."
Write-Host " "
Foreach ($SourceDataDisk in $SourceVmObject.StorageProfile.DataDisks) { 

    $SourceDataDiskSku = (get-azdisk -ResourceGroupName $SourceVmObject.ResourceGroupName -DiskName $SourceDataDisk.name).Sku.Name

    $SourceDataDiskSnapConfig =  New-AzSnapshotConfig  -SourceUri $SourceDataDisk.ManagedDisk.Id -Location $SourceVmObject.Location -CreateOption copy

    $SourceDataDiskSnap = New-AzSnapshot -Snapshot $SourceDataDiskSnapConfig  -SnapshotName "$($SourceVmObject.Name)-$($SourceDataDisk.name)-Snap"  -ResourceGroupName $SourceVmObject.ResourceGroupName

    }

    }

