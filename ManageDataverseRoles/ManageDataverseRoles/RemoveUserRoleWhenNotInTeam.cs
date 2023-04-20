using System;
using System.Diagnostics.CodeAnalysis;
using Microsoft.Azure.WebJobs;
using Microsoft.Azure.WebJobs.Host;
using Microsoft.Extensions.Logging;
using Microsoft.Graph;
using Microsoft.Xrm.Sdk;
using Microsoft.Xrm.Sdk.Query;
using WNZL.Azure.Connectors;
using WNZL.Azure.Connectors.DataVerse;

namespace ManageDataverseRoles
{
    public static class RemoveUserRoleWhenNotInTeam
    {
        [FunctionName("RemoveUserRoleWhenNotInTeam")]
        [SuppressMessage("Style", "IDE0060:Remove unused parameter", Justification = "myTimer required by API")]
        public static void Run([TimerTrigger("0 15 20 * * *")]TimerInfo myTimer, ILogger log)
        {
            log.LogInformation($"Function started at: {DateHelper.GetDateTimeAsString()}");

            RemoveUserRoles(log);
        }

        private static void RemoveUserRoles(ILogger log)
        {
            bool removeUsersFromTeamRole = EnvironmentSettings.GetSettingAsBoolean("RemoveUsersFromTeamRole");
            var crm = DataverseConnection.FromSetting("Dynamics365URL", log);

            if (!removeUsersFromTeamRole)
            {
                log.LogInformation($"*** Running in test mode, users will not be removed from roles ****");
            }

            // Not bothing with paging over multiple result sets - will get those next time function triggered
            EntityCollection user = FetchManuallyAssignedUsers(crm);
                        
            if (user.Entities.Count > 0)
            {
                foreach(var item in user.Entities)
                {
                    var rolename = item.GetAttributeValue<AliasedValue>("role.name").Value;
                    var username = item.GetAttributeValue<AliasedValue>("systemuser.fullname").Value;
                    var salaryId = item.GetAttributeValue<AliasedValue>("systemuser.ice_salaryid")?.Value;
                    
                    log.LogInformation($"Removing '{salaryId} - {username}' from role '{rolename}'");

                    if (removeUsersFromTeamRole)
                    {
                        crm.User.RemoveUserFromRole((Guid)item.GetAttributeValue<AliasedValue>("systemuser.systemuserid").Value, (Guid)item.GetAttributeValue<AliasedValue>("role.roleid").Value);
                    }
                }

                log.LogInformation($"Removed {user.Entities.Count} user roles assignments.");
            } else
            {
                log.LogInformation($"No team roles are directly assigned to users.");
            }
        }

        private static EntityCollection FetchManuallyAssignedUsers(DataverseConnection crm)
        {
            // Team: is linked to active directoy group and not system managed
            // Role: isinherited is set to "Direct User(Basic) access level and Team privileges"
            // SystemUser: is real user (i.e. not Application User)
            string fetchxml = @"<fetch>
                      <entity name='team'>
                        <attribute name='name' />
                        <attribute name='azureactivedirectoryobjectid' />
                        <filter>
                          <condition attribute='azureactivedirectoryobjectid' operator='not-null' />
                          <condition attribute='systemmanaged' operator='eq' value='0' />
                        </filter>
                        <link-entity name='teamroles' from='teamid' to='teamid' intersect='true'>
                          <link-entity name='role' alias='role' from='roleid' to='roleid' intersect='true'>
                            <attribute name='roleid' />
                            <attribute name='name' />
                            <attribute name='isinherited' />
                             <filter>
                              <condition attribute='isinherited' operator='eq' value='1' />
                            </filter>
                            <link-entity name='systemuserroles' from='roleid' to='roleid' intersect='true'>
                              <link-entity name='systemuser' alias='systemuser' from='systemuserid' to='systemuserid' intersect='true'>
                                <attribute name='systemuserid' />
                                <attribute name='fullname' />
                                <attribute name='ice_salaryid' />
                                <attribute name='internalemailaddress' />
                                <attribute name='applicationid' />
                                <filter>
                                  <condition attribute='applicationid' operator='null' />
                                </filter>
                                <order attribute='fullname' />
                              </link-entity>
                            </link-entity>
                          </link-entity>
                        </link-entity>
                      </entity>
                    </fetch>";

            EntityCollection users = crm.ServiceClient.RetrieveMultiple(new FetchExpression(fetchxml));

            return users;
        }
    }
}
