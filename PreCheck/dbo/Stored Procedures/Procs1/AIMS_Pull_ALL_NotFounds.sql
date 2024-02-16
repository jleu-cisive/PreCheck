-- =============================================
-- Author:		Johnny Keller
-- Create date: 04/29/2022
-- Description:	This stored procedure will pull information
--				on jobs that sent out > 5 licenses had > 30% not founds
--				in the last seven days. Will pull SBM or CC dependant on
--				parameter input
-- =============================================
CREATE PROCEDURE [dbo].[AIMS_Pull_ALL_NotFounds] 

	@SectionType nvarchar(5)

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	Declare @ScenarioControl nvarchar(5) = case when @SectionType = 'CC' then @SectionType
												when @SectionType = 'SBM' then @SectionType
												else 'CC'
												end

	drop table if exists #NotFounds

	select sum(total_records) as Not_Founds, Parent_LoggingID into #NotFounds
	from precheck.dbo.dataxtract_logging
	where section like @SectionType+'_Not_Found%' and datediff(week, getDate(), datelogrequest) = 0
	group by Parent_LoggingId
	
	drop table if exists #BaseRequests
	
	select dataxtract_loggingid, sectionkeyid, total_records, DateLogRequest into #BaseRequests
	from precheck.dbo.DataXtract_Logging
	where Section like @SectionType+'_Base%' and datediff(week, getdate(), datelogrequest) = 0 and total_records > 0
	
	
	select B.SectionKeyId, B.Total_Records as Total_Sent, NF.Not_Founds as NotFounds_Received, B.DateLogRequest as Date_Processed 
	from #BaseRequests B
	inner join #NotFounds NF on NF.Parent_LoggingId = B.DataXtract_LoggingId
								and NF.Not_Founds/B.Total_Records >= 0.3
								and b.Total_Records > 5
	order by Date_Processed desc

END
