
-- =============================================
-- Author:		schapyala
-- Create date: 05/09/2014
-- Description:	Return the list of jobs that qualify based on the schedule
-- =============================================
---UPDATED date: 05/04/2015
-- Description:	Added another join condition on VendorAccountId for the SBM/CC running at the same time to account for a per vendor run
-- =============================================
CREATE PROCEDURE [dbo].[Aims_GetJobsBySchedule_033120017]
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	CREATE TABLE #tmpSchedule
	(
	   ScheduleID int ,
	   Section varchar(20),
	   SectionKeyID varchar(50),
	   SectionTypeCode varchar(10),
	    VendorAccountId int DEFAULT 5   --default to Mozenda
	)

	CREATE TABLE #tmpDualSchedule
	(
	   Section varchar(20),
	   SectionKeyID varchar(50),
	   VendorAccountId Int
	)

	Insert into #tmpSchedule
	Select DataXtract_AIMS_ScheduleID,Section,SectionKeyID, refAIMS_SectionTypeCode,VendorAccountId 
	From DBO.DataXtract_AIMS_Schedule sched
		inner join DataXtract_RequestMapping M ON sched.DataXtract_RequestMappingXMLID= M.DataXtract_RequestMappingXMLID
	Where M.Section <> 'Crim' and IsAutomationEnabled = 1 and sched.IsActive=1
	AND   NextRunTime <= Current_TimeStamp



	--DUAL SCHEDULE LOGIC: When CC and SBM schedules clash, update the CC schedule but do not create a job for CC, since SBM pretty much handles the CC job too
	Insert into #tmpDualSchedule
	Select Section,SectionKeyID,VendorAccountId from #tmpSchedule
	Group By Section,SectionKeyID,VendorAccountId
	Having count(SectionKeyID)>1



	DELETE t
	From #tmpSchedule t inner join #tmpDualSchedule tds on t.Section = tds.Section and t.SectionKeyID= tds.SectionKeyID 
	Where SectionTypeCode = 'CC' and t.VendorAccountId <> 4
	--END DUAL SCHEDULE LOGIC
		
	DELETE t
	From #tmpSchedule t inner join AIMS_Jobs job on  t.SectionKeyID= job.SectionKeyID and t.VendorAccountId=job.VendorAccountId 
	--and t.SectionTypeCode = job.Section -- Removed per Kiran 07/1/2016
	Where 
	--SectionTypeCode = 'CC' AND 
	job.AIMS_JobStatus in ('A','E')

	UPDATE Job SET section ='SBM'
	FROM #tmpSchedule t inner join AIMS_Jobs job on  t.SectionKeyID= job.SectionKeyID and t.VendorAccountId=job.VendorAccountId 
	WHERE job.AIMS_JobStatus = 'Q' AND t.SectionTypeCode <> job.section AND t.SectionTypeCode = 'SBM'


	Update Sched Set NextRunTime = (Case When Interval = 'minute' then DateAdd(MINUTE,TimeValue,NextRunTime)
										 When Interval = 'hour' then DateAdd(HOUR,TimeValue,NextRunTime)
										 When Interval = 'day' then DateAdd(DAY,TimeValue,NextRunTime)
										 When Interval = 'month' then DateAdd(MONTH,TimeValue,NextRunTime)
										 When Interval = 'year' then DateAdd(YEAR,TimeValue,NextRunTime)
									ELSE
									NextRunTime
									END)
    FROM DBO.DataXtract_AIMS_Schedule Sched 
	inner Join #tmpSchedule t on Sched.DataXtract_AIMS_ScheduleID = t.ScheduleID

	Select isnull(SectionTypeCode,Section) Section,SectionKeyID, VendorAccountId
	From #tmpSchedule
	
	DROP TABLE #tmpDualSchedule 
	DROP TABLE #tmpSchedule 
END

