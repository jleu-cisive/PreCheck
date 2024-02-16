-- =============================================
-- Author:		Johnny Keller
-- Create date: 04/15/2021
-- Description:	Will report which CCs have not ran on either the provided date
--				or the current date
-- =============================================
CREATE PROCEDURE AIMS_CC_Daily_Report
	
	@dateToCheck nvarchar(20)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	Drop table if Exists #Enabled_Jobs
	
	--select all CC jobs that would have qualified for pick up
	--for both the Nursys and Scrapy vendors
	select sectionkeyid as Section_Key into #Enabled_Jobs
	from DataXtract_RequestMapping m
	inner join DataXtract_AIMS_Schedule s on 
				s.DataXtract_RequestMappingXMLID = m.DataXtract_RequestMappingXMLID
				and s.refAIMS_SectionTypeCode = 'CC' 
				and s.IsActive = 1
				and s.VendorAccountId in (4, 16)
				and m.IsAutomationEnabled = 1
	
	
	drop table if exists #Completed_Jobs
	
	--select all CC jobs that have ran for the day
	select sectionkeyID as Section_Key_Today into #Completed_Jobs
	from AIMS_Jobs
	where aims_jobstatus in ('C', 'Z')
				and section = 'CC'
				and datediff(day, CreatedDate, case when @dateToCheck = '' then getDate() 
													when @dateToCheck is null then getDate()
													else @dateToCheck end) = 0
	
	--select all jobs that would be qualified but did not run for the day
	select E.Section_Key 
	from #Enabled_Jobs E
	where E.Section_Key not in (select Section_Key_Today from #Completed_Jobs)
END
