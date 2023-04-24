# AKS-scripts
Automation scripts for AKS

## Install Powershell AZ

https://learn.microsoft.com/zh-cn/powershell/azure/install-azure-powershell?view=azps-9.6.0

```
Install-Module -Name Az -Scope CurrentUser -Repository PSGallery -Force
```

## Login Az account

```
Connect-AzAccount
```

## Upgrade AKS version

```
$Subscription = ""
$ResourceGroup = ""
$ClusterName = ""
$Version =""
.\Upgrade-AksCluster.ps1 -ResourceGroup $ResourceGroup -ClusterName $ClusterName -Version $Version -Subscription $Subscription
```
