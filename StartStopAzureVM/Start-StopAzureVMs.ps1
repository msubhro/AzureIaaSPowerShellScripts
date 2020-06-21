
# This script starts or stops multiple Azure VMs, based on input file.

# If the VM is stopped (deallocated) state, this script will start the VM. If the VM is in running state, this script will stop the VM.

# Can start / Stop multiple Azure VMs in parallel, based on input file.

# This script runs on PowerShell AZ Module.

# The script is tested only for Windows VM.

# Test before you use this script in a critical environment.

# Use at your own risk.



Use at your own risk.

$VMList = get-content 'c:\serverlist.txt'

$VMRGName = 'TestVMRG1'


$Jobs = @()


$sblock = {
    
    Param (
            
        $VMName,
        $VMRGName
    )



$SourceVmObject = get-azvm -Name $VMName -ResourceGroupName $VMRGName


$SourceVmPowerStatus = (get-azvm -Name $SourceVmObject.Name -ResourceGroupName $SourceVmObject.ResourceGroupName -Status).Statuses[1].DisplayStatus

if ($SourceVmPowerStatus -eq "VM running") 

   {

    stop-azVm -Name $SourceVmObject.Name -ResourceGroupName $SourceVmObject.ResourceGroupName -Force

    
    }


if ($SourceVmPowerStatus -eq "VM deallocated") 

  {

      start-azVm -Name $SourceVmObject.Name -ResourceGroupName $SourceVmObject.ResourceGroupName

    
   }

}


foreach($VMName in $VMList)

{


$Jobs += start-job -ScriptBlock $sblock -ArgumentList $VMName,$VMRGName

}

$jobs | Wait-Job | Receive-Job