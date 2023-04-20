<#
.SYNOPSIS
    Add Graph API Permissions to a User Managed Identity

.DESCRIPTION
    https://docs.microsoft.com/en-us/azure/app-service/scenario-secure-app-access-microsoft-graph-as-app?tabs=azure-powershell%2Ccommand-line
    https://docs.microsoft.com/en-us/azure/active-directory/managed-identities-azure-resources/how-to-manage-ua-identity-portal#assign-a-role-to-a-user-assigned-managed-identity
    https://laurakokkarinen.com/authenticating-to-azure-ad-protected-apis-with-managed-identity-no-key-vault-required/

#>

# Install the module (You need admin on the machine)
#Install-Module AzureAD 

# Your tenant id (in Azure Portal, under Azure Active Directory -> Overview )
#$TenantID=""

# Microsoft Graph App ID (DON'T CHANGE)
$GraphAppId = '00000003-0000-0000-c000-000000000000'
$GraphPermissions = @( 'Group.Read.All', 'User.Read.All' )

# Principal Id of the managed identity
$MsiObjectIdTest = '055654de-7c8c-4eed-9d8c-eca6a76bb949' # ice-graph-api-ui
#$MsiObjectIdProd = ?

Connect-AzureAD #-TenantId $TenantID 

$msi = Get-AzureADServicePrincipal -ObjectId $MsiObjectIdTest

$graph = Get-AzureADServicePrincipal -Filter "appId eq '$GraphAppId'"

#Note: Need 
foreach ( $permission in $GraphPermissions )
{
    $AppRole = $graph.AppRoles `
        | Where-Object { $_.Value -eq $permission -and $_.AllowedMemberTypes -contains 'Application' }

        #| where Value -eq $permission -and AllowedMemberTypes -contains "Application" `
        #| Select-Object -First 1

    New-AzureAdServiceAppRoleAssignment `
        -ObjectId $msi.ObjectId `
        -PrincipalId $msi.ObjectId `
        -ResourceId $graph.ObjectId `
        -Id $appRole.Id

    New-AzureADApplication -
}