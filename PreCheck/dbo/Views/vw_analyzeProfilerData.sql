create view vw_analyzeProfilerData

as

select TextData, Applicationname, NTUserName, LoginName, CPU, Reads, Writes, Starttime, EndTime, HostName 
from [dbo].[ProductionProfilerTrace]
where cpu is not null and StartTime >= '2021-01-30 07:00:30.997' and StartTime <= '2021-01-30 11:30:01.173'