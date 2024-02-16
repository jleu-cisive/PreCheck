-- =============================================
-- Author:		Johnny keller
-- Create date: 04/15/2022
-- Description:	Will pull the SectionKeyId of all SBMS that have not completed
-- in the month inputted. This Includes the last day of the previous month since 
-- we start SBMs on the last day of every months as of 04/15/2022
-- =============================================
CREATE PROCEDURE AIMS_SBM_Monthly_Report 
	-- Add the parameters for the stored procedure here
	@monthToCheck nvarchar(20),
	@yearToCheck nvarchar(4)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @monthChecking as nvarchar(20)
	DECLARE @yearChecking as nvarchar (4)
	DECLARE @completeDate as nvarchar(20)

	set @monthChecking  = case when @monthToCheck like 'Jan%' or @monthToCheck  in ('1', '01') then '01' 
							   when @monthToCheck like 'Feb%' or @monthToCheck in ('2', '02') then '02' 
							   when @monthToCheck like 'Mar%' or @monthToCheck in ('3', '03') then '03'
							   when @monthToCheck like 'Apr%' or @monthToCheck in ('4', '04') then '04'
							   when @monthToCheck like 'May%' or @monthToCheck in ('5', '05') then '05'
							   when @monthToCheck like 'Jun%' or @monthToCheck in ('6', '06') then '06'
							   when @monthToCheck like 'Jul%' or @monthToCheck in ('7', '07') then '07'
							   when @monthToCheck like 'Aug%' or @monthToCheck in ('8', '08') then '08'
							   when @monthToCheck like 'Sep%' or @monthToCheck in ('9', '09') then '09'
							   when @monthToCheck like 'Oct%' or @monthToCheck = '10' then '10'
							   when @monthToCheck like 'Nov%' or @monthToCheck = '11' then '11'
							   when @monthToCheck like 'Dec%' or @monthToCheck = '12' then '12'
							   else ''
							   end 

	set @yearChecking = case when @yearToCheck like '20%' and DATALENGTH(@yearToCheck) = 4 then @yearToCheck
						     else cast(YEAR(getDate()) as nvarchar(4))
						     end
	print @yearChecking

	set @completeDate = case when @monthChecking <> '' then @monthChecking + '/01/' + @yearChecking
							 else '' 
							 end
	print @completeDate

    Drop table if Exists #Enabled_Jobs

	select sectionkeyid as Section_Key into #Enabled_Jobs
	from DataXtract_RequestMapping m
	inner join DataXtract_AIMS_Schedule s on s.DataXtract_RequestMappingXMLID = m.DataXtract_RequestMappingXMLID
											 and s.refAIMS_SectionTypeCode = 'SBM' 
											 and s.IsActive = 1
											 and s.VendorAccountId in (4, 16)
											 and m.IsAutomationEnabled = 1
	
	
	drop table if exists #Completed_Jobs
	
	select sectionkeyID as Section_Key_Today into #Completed_Jobs
	from AIMS_Jobs
	where aims_jobstatus in ('C', 'Z')
		  and section = 'SBM'
		  and (datediff(Month, CreatedDate, case when @completeDate <> '' then @completeDate else getDate() end) = 0 
			   or datediff(day, createdDAte, (select EOMONTH(case when @completeDate <> '' then @completeDate else getDate() end, -1) Last_Month)) = 0)
	
	select E.Section_Key 
	from #Enabled_Jobs E
	where E.Section_Key not in (select Section_Key_Today from #Completed_Jobs)
END
