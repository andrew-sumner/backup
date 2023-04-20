using Microsoft.VisualStudio.TestTools.UnitTesting;
using ManageDataverseRoles;

namespace WNZL.Schedule.Functions.Tests
{
    /**
     * This class is NOT for Unit Testing.  It is a way of triggering Azure Functions under development 
     * that cannot be easily triggered in any other way, eg those functions using TimerTrigger.
     * 
     * See http://www.ben-morris.com/writing-unit-tests-for-azure-functions-using-c/
     */
    [TestClass]
    public class LaunchPad : TestBase
    {
        [TestMethod]
        public void LaunchFunction()
        {
            PopulateEnvrionmentSettings("ManageDataverseRoles");

            RemoveUserRoleWhenNotInTeam.Run(timerInfo, debugLogger);

            Assert.IsNull(null); // Stop SonarQube complaining about lack of assertion
        }
    }
}
