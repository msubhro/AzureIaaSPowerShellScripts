
# This script install the Azure VM Extension for Microsoft Monitoring Agent (MMA).

# The script also connects Azure VM to a Log Analytics Workspace.

# Works on multiple Azure VMs in parallel, based on an input file.

# This script runs on PowerShell AZ Module.

# The script is tested only for Windows VM.

# Test before you use this script in a critical environment.

# Use at your own risk.


# Log Analytics Workspace ID

$WorkspaceId = ' '

# Log Analytics Workspace Key

$workspaceKey =' '

$VMList = Get-Content "c:\serverlist.txt"

$VMRGName = 'TestVMRG1'

$VMLocation = 'NorthEurope'

$Jobs = @()


$sblock = {
    
    Param (
        $WorkspaceId,
        $workspaceKey,
        $VMName,
        $VMRGName,
        $VMLocation
    )

    $PublicSettings = @{"workspaceId" = $WorkspaceId}
    $ProtectedSettings = @{"workspaceKey" = $workspaceKey}

    Set-AzVMExtension -ExtensionName "MicrosoftMonitoringAgent" `
    -ResourceGroupName $VMRGName `
    -VMName $VMName `
    -Publisher "Microsoft.EnterpriseCloud.Monitoring" `
    -ExtensionType "MicrosoftMonitoringAgent" `
    -TypeHandlerVersion 1.0 `
    -Settings $PublicSettings `
    -ProtectedSettings $ProtectedSettings `
    -Location $VMLocation
    
       
}



foreach($VMName in $VMList)

{


$Jobs += start-job -ScriptBlock $sblock -ArgumentList $WorkspaceId,$workspaceKey,$VMName,$VMRGName,$VMLocation

Write-Host "  "

Write-host "Installing MMA Agent on $($VMName) ..."

Write-Host "  "


}

$jobs | Wait-Job | Receive-Job