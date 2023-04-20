using System;
using System.Diagnostics.CodeAnalysis;
using Microsoft.Azure.WebJobs;
using Microsoft.Azure.WebJobs.Host;
using Microsoft.Extensions.Logging;
using Microsoft.Graph;
using Microsoft.PowerPlatform.Dataverse.Client;
using Microsoft.Xrm.Sdk;
using Microsoft.Xrm.Sdk.Query;
using WNZL.Azure.Connectors;
using WNZL.Azure.Connectors.DataVerse;

namespace ManageDataverseRoles
{
    public static class RemoveUnmanagedRoles
    {
        [FunctionName("RemoveUnmanagedRoles")]
        [SuppressMessage("Style", "IDE0060:Remove unused parameter", Justification = "myTimer required by API")]
        public static void Run([TimerTrigger("0 0 3 * * *")]TimerInfo myTimer, ILogger log)
        {
            log.LogInformation($"Start remove D365 users' out-of-box roles at: {DateHelper.GetDateTimeAsString()}");

            RemoveUserOutOfBoxRoles(log);
        }

        private static void RemoveUserOutOfBoxRoles (ILogger log)
        {
            bool removeUsersFromSystemAdminRole = EnvironmentSettings.GetSettingAsBoolean("RemoveUsersFromSystemAdminRole");
            var crm = DataverseConnection.FromSetting("Dynamics365URL", log);

            EntityCollection UserRoles = GetUserUnmanagedRoles(crm.ServiceClient);
            
            if (UserRoles.Entities.Count > 0)
            {
                log.LogInformation($"Removing D365 out-of-box roles from users, total record count: {UserRoles.Entities.Count}");
                foreach(var UserRole in UserRoles.Entities)
                {
                    var rolename = UserRole.GetAttributeValue<AliasedValue>("role.name").Value;
                    var user = UserRole.GetAttributeValue<AliasedValue>("systemuser.fullname").Value;

                    if (!removeUsersFromSystemAdminRole && rolename.ToString().Equals("System Administrator", StringComparison.OrdinalIgnoreCase))
                    {
                        continue;
                    }
                    
                    crm.User.RemoveUserFromRole((Guid)UserRole.Attributes["systemuserid"], (Guid)UserRole.Attributes["roleid"]);
                    
                    log.LogInformation($"Removed the D365 out-of-box role, {rolename}, from {user}");
                }
            } 
            else
            {
                log.LogInformation($"No D365 out-of-box roles are assigned to users.");
            }
        }

                /**
         * D365 automatically assign out-of-box roles, that returned the users who have those roles except System Administrator
         */
        private static EntityCollection GetUserUnmanagedRoles(ServiceClient serviceClient)
        {
            var fetchxml = $@"<fetch>
                                <entity name='systemuserroles'>
                                    <attribute name='roleid' />
                                    <attribute name='systemuserid' />
                                    <link-entity name='role' from='roleid' to='roleid' alias='role'>
                                    <attribute name='name' />
                                    <filter>
                                        <condition attribute='ismanaged' operator='eq' value='1' />
                                        <condition attribute='name' operator='neq' value='Support User' />
                                    </filter>
                                    </link-entity>
                                    <link-entity name='systemuser' from='systemuserid' to='systemuserid' alias='systemuser'>
                                    <attribute name='fullname' />
                                    <filter>
                                        <condition attribute='applicationid' operator='null' />
                                        <condition attribute='internalemailaddress' operator='not-like' value='%srv%' />
                                        <condition attribute='internalemailaddress' operator='not-like' value='%@microsoft.com' />
                                    </filter>
                                    </link-entity>
                                </entity>
                                </fetch>";

            EntityCollection userRole = serviceClient.RetrieveMultiple(new FetchExpression(fetchxml));

            return userRole;
        } 
    }
}
