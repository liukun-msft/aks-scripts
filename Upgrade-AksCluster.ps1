# Upgrade AKS clusterVersion
param (
  # Resource group name
  [Parameter(Mandatory = $true)]
  [string]$ResourceGroup,

  # AKS cluster name
  [Parameter(Mandatory = $true)]
  [string]$ClusterName,

  # Version to upgrade to
  [Parameter(Mandatory = $true)]
  [string]$Version,

  # Subscription
  [Parameter(Mandatory = $false)]
  [string]$Subscription
)

# Call the function, pass in a subscription name or id
if ($Subscription) {
  .\Switch-AzSubscription.ps1 -Subscription $Subscription

}
else {
  $subscriptionName = Get-AzContext | Select-Object -ExpandProperty Name
  Write-Host "No subscription provided, use current subscritpion: $subscriptionName"
}


# Check for available AKS cluster upgrade versions and store them in a variable
$availableVersions = Get-AzAksUpgradeProfile -ResourceGroupName $ResourceGroup -Name $ClusterName | Select-Object -ExpandProperty ControlPlaneProfileUpgrade | Select-Object -ExpandProperty KubernetesVersion

# Check if the target version is in the available versions
if ($availableVersions -contains $version) {
  # Write a message that the target version is valid
  Write-Host "Target version $Version is valid for upgrade."
}
else {
  # Write an error message that the target version is invalid and exit the script
  Write-Error "Target version $Version is invalid for upgrade. Please choose one of the following versions: $($availableVersions -join ', ')"
  exit
}




$controlPlaneVersion = Get-AzAksUpgradeProfile -ResourceGroupName $ResourceGroup -Name $ClusterName  | Select-Object -ExpandProperty ControlPlaneProfileKubernetesVersion
Write-Host "The control plane version of the AKS cluster is $controlPlaneVersion"
if ($controlPlaneVersion -eq $Version) {
  Write-Host "Skip control plane upgrade as it is same as the target version."
}
else {
  # Try to upgrade the control plane and handle any exception
  try {
    Write-Host "Starting to upgrade control plane to version $Version..."
    $result = Set-AzAksCluster -Confirm -ControlPlaneOnly -ResourceGroupName $ResourceGroup -Name $ClusterName -KubernetesVersion $Version
    if ($result.Confirm -eq "N") {
      Write-Host "Exit the upgrading process."
      exit
    }
    Write-Host "Control plane upgraded successfully to version $Version."
  }
  catch {
    Write-Error "Control plane failed to upgrade to version $version. Error: $_"
    exit
  }
}




# # Define the order of node pool names
# $nodePoolOrder = @("system", "infra", "watchdog", "linux", "win")

# # Get all node pool names and sort them by the order
# $nodePools = Get-AzAksNodePool -ResourceGroupName $ResourceGroup -ClusterName $ClusterName | Select-Object Name, KubernetesVersion, ProvisioningState | Sort-Object { $nodePoolOrder.IndexOf($_.Name) }

# Check if any node pool is upgrading
# if ($nodePools.ProvisioningState -contains "Upgrading") {
#   Write-Host "Another node pool is upgrading. Waiting."
#   exit //TODO: wait upgrade finished
# }

# # Loop through each node pool and upgrade
# foreach ($nodePool in $nodePools) {
#   # Check if the node pool version is the same as the target version
#   if ($nodePool.KubernetesVersion -eq $Version) {
#     # Skip the upgrade for this node pool and write a message
#     Write-Host "Node pool $($nodePool.Name) is already on version $Version. Skipping upgrade."
#     continue
#   }
  
#   # Try to upgrade the node pool and handle any exception
#   try {
#     Write-Host "Starting to upgrade node pool $($nodePool.Name) to version $Version..."
#     Update-AzAksNodePool -ResourceGroupName $ResourceGroup -ClusterName $ClusterName -Name $nodePool.Name -KubernetesVersion $Version
#     Write-Host "Node pool $($nodePool.Name) upgraded successfully to version $Version."
#   }
#   catch {
#     Write-Error "Node pool $($nodePool.Name) failed to upgrade to version $Version. Error: $_"
#     break
#   }
# }


