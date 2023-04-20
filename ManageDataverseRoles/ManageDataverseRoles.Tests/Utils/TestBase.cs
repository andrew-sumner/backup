using System;
using System.Diagnostics;
using Microsoft.Azure.WebJobs;
using Microsoft.Azure.WebJobs.Extensions.Timers;
using System.IO;
using System.Collections.Generic;
using Newtonsoft.Json;

namespace WNZL.Schedule.Functions.Tests
{
    public class TestBase
    {
        protected readonly DebugLogger debugLogger = new DebugLogger();
        protected readonly TimerInfo timerInfo = new TimerInfo(new ScheduleStub(), new ScheduleStatus());

        protected static void PopulateEnvrionmentSettings(String projectName)
        {
            var slnDirectory = GetSolutionDirectoryInfo();
            string projectSettings = Path.Combine(slnDirectory.FullName, projectName, "local.settings.json");
            string json = File.ReadAllText(projectSettings);
            
            var settings = JsonConvert.DeserializeObject<Dictionary<string, object>>(json);
            var values = JsonConvert.DeserializeObject<Dictionary<string, string>>(settings["Values"].ToString());

            foreach (var item in values)
            {
                Environment.SetEnvironmentVariable(item.Key, item.Value);
            } 
        }

        private static DirectoryInfo GetSolutionDirectoryInfo()
        {
            var directory = new DirectoryInfo(Directory.GetCurrentDirectory());

            while (directory != null && directory.GetFiles("*.sln").Length == 0)
            {
                directory = directory.Parent;
            }

            return directory;
        }
    }
}
