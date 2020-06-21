
# This script puts Azure VM(s) in a Proximity Placement Group (PPG).

# Works on multiple Azure VMs in parallel.

# This script does not create the PPG, it has to be created in advance.

# VMs must be deallocated before running this script.

# Ensure Azure VM agent is installed on target VM(s), before you execute this script.

# This script runs on PowerShell AZ Module.

# The script is tested only for Windows VM.

# Test before you use this script in a critical environment.

# Use at your own risk.

# Ref: https://docs.microsoft.com/en-us/azure/virtual-machines/windows/proximity-placement-groups#move-an-existing-vm-out-of-a-proximity-placement-group


$VMList = Get-Content "c:\serverlist.txt"

$VMRGName = 'TestVMRG1'

$VMLocation = 'NorthEurope'

$PPGName = 'NorthEuropePPG'

$RRPRGName = 'PPGRG'

$Jobs = @()


$sblock = {
    
    Param (
        $VMName,
        $VMRGName,
        $VMLocation,
        $PPGName,
        $RRPRGName
    )

    $PublicSettings = @{"workspaceId" = $WorkspaceId}
    $ProtectedSettings = @{"workspaceKey" = $workspaceKey}

  $ppg = Get-AzProximityPlacementGroup -ResourceGroupName $RRPRGName -Name $PPGName

  $vm = Get-AzVM -ResourceGroupName $VMRGName -Name $VMName

  
  # Stop-AzVM -Name $VMName -ResourceGroupName $VMRGName

   Update-AzVM -VM $vm -ResourceGroupName $vm.ResourceGroupName -ProximityPlacementGroupId $ppg.Id

  # Start-AzVM -Name $vm.Name -ResourceGroupName $vm.ResourceGroupName
       
}

foreach($VMName in $VMList)

{


$Jobs += start-job -ScriptBlock $sblock -ArgumentList $VMName,$VMRGName,$VMLocation,$PPGName,$RRPRGName

Write-Host "  "

Write-host "Putting $($VMName) in $($PPGName) PPG ..."

Write-Host "  "


}


$jobs | Wait-Job | Receive-Job
