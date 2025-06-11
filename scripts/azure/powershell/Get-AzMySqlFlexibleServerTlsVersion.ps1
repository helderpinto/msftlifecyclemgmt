<#
.SYNOPSIS
    Retrieves the TLS versions used by Azure Database for MySQL flexible servers.

.DESCRIPTION
    This script connects to Azure, retrieves all Azure Database for MySQL flexible servers, and checks their TLS versions.
    It outputs the results to a CSV file named "azuredb-mysql-tls-versions.csv". 
    NOTE: this script works better when run in the Azure Cloud Shell.

.PARAMETER AzureEnvironment
    The Azure environment to connect to. Default is "AzureCloud".

.PARAMETER ResourceId
    The resource ID of a specific Azure Database for MySQL flexible server to check. If not provided, all servers will be checked.

.EXAMPLE
    ./Get-AzMySqlFlexibleServerTlsVersion
    Retrieves the TLS versions for all Azure Database for MySQL flexible servers in the Azure Cloud environment.

.EXAMPLE
    ./Get-AzMySqlFlexibleServerTlsVersion -AzureEnvironment "AzureUSGovernment"
    Retrieves the TLS versions for all Azure Database for MySQL flexible servers in the Azure US Government environment.

.EXAMPLE
    ./Get-AzMySqlFlexibleServerTlsVersion -ResourceId "/subscriptions/{subscription-id}/resourceGroups/{resource-group}/providers/Microsoft.DBforMySQL/flexibleServers/{server-name}"
    Retrieves the TLS version for a specific Azure Database for MySQL flexible server identified by the provided resource ID.
#>

param(
    [Parameter(Mandatory = $false)] 
    [String] $AzureEnvironment = "AzureCloud",

    [Parameter(Mandatory = $false)] 
    [String] $ResourceId
)

$ErrorActionPreference = "Stop"

$ctx = Get-AzContext
if (-not($ctx)) {
    Connect-AzAccount -Environment $AzureEnvironment
    $ctx = Get-AzContext
}
else {
    if ($ctx.Environment.Name -ne $AzureEnvironment) {
        Disconnect-AzAccount -ContextName $ctx.Name
        Connect-AzAccount -Environment $AzureEnvironment
        $ctx = Get-AzContext
    }
}

if ($ResourceId)
{
    $resourceFilter = " and id=~'$ResourceId'"
}

$ARGPageSize = 1000

$subscriptions = Get-AzSubscription | Where-Object { $_.State -eq "Enabled" } | ForEach-Object { "$($_.Id)"}

$argQuery = @"
resources 
| where type =~ 'microsoft.dbformysql/flexibleservers'$resourceFilter
| project id, name, resourceGroup, subscriptionId, location
| order by id asc
"@

$servers = (Search-AzGraph -Query $argQuery -First $ARGPageSize -Subscription $subscriptions).data

Write-Output "Found $($servers.Count) Azure Database for MySQL flexible servers."

$serversDetails = @()

foreach ($server in $servers) {

    if ($server.subscriptionId -ne $ctx.Subscription.Id)
    {
        $ctx = Set-AzContext -SubscriptionId $server.subscriptionId | Out-Null
    }

    $serverTlsConfiguration = Get-AzMySqlFlexibleServerConfiguration -Name "tls_version" `
        -ResourceGroupName $server.resourceGroup -ServerName $server.name -SubscriptionId $server.subscriptionId

    $foregroundColor = "Green"
    if ($serverTlsConfiguration.Value -like "*TLSv1,*" -or $serverTlsConfiguration.Value -like "*TLSv1.1*")
    {
        $foregroundColor = "Yellow"
    }
    Write-Host "Server: $($server.name) - TLS Version: $($serverTlsConfiguration.Value)" -ForegroundColor $foregroundColor

    $serverDetails = New-Object PSObject -Property @{
        ResourceId = $server.id
        ServerName = $server.name
        ResourceGroup = $server.resourceGroup
        SubscriptionId = $server.subscriptionId
        Region = $server.location
        TLSVersions = $serverTlsConfiguration.Value
    }
    $serversDetails += $serverDetails    
}

$serversDetails | Export-Csv -Path "azuredb-mysql-tls-versions.csv" -NoTypeInformation

Write-Output "Exported Azure Database for MySQL flexible servers TLS versions to azuredb-mysql-tls-versions.csv"