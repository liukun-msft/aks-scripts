param (
  # Subscription id or name
  [Parameter(Mandatory = $true)]
  [string]$Subscription
)


# Get the current Azure subscription list
$subscriptions = Get-AzContext | Select-Object -ExpandProperty Name

# Check if the input parameter is in the list
if ($subscriptions.Name -contains $Subscription -or $subscriptions.Id -contains $Subscription) {
  # If in the list, use the Set-AzContext command to switch subscription
  Set-AzContext -Subscription $Subscription
  Write-Host "Switch Subscritpion to $Subscription"
}
else {
  # If not in the list, prompt the user to enter a valid subscription
  Write-Host "Invalid subscription, please enter a valid subscription name or id"
}