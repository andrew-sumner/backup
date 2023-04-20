using Microsoft.Azure.WebJobs.Extensions.Timers;
using Microsoft.Azure.WebJobs;
using System;

namespace WNZL.Schedule.Functions.Tests
{
    public class ScheduleStub : TimerSchedule
    {
        public override bool AdjustForDST => throw new NotImplementedException();

        public override DateTime GetNextOccurrence(DateTime now)
        {
            throw new NotImplementedException();
        }
    }
}
