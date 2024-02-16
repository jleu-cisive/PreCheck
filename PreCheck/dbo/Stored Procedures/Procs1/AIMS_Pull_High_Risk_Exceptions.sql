-- =============================================
-- Author:		Johnny Keller
-- Create date: 06/01/2022
-- Description:	This SP will pull any entries 
-- =============================================
CREATE PROCEDURE [dbo].[AIMS_Pull_High_Risk_Exceptions]
	-- Add the parameters for the stored procedure here
	--@interval nvarchar(10)

AS
BEGIN
	
	--DECLARE @controlScenario int = case when @interval like 'Da%' then 1
	--									when @interval like 'We%' then 2
	--									when @interval like 'Mo%' then 3
	--									else 1
	--									end
	
	SET NOCOUNT ON;

		drop table if exists #Exceptions
	
		select sum(isNull(Total_Exceptions, 0)) as Exceptions, Parent_LoggingID into #Exceptions
		from precheck.dbo.dataxtract_logging (nolock)
		where (section in ('CC', 'SBM') or section like '%worked%' or section like '%scraped%' or section like '%not_found%') and datediff(DAY, getdate(), datelogrequest) in (0)
		group by Parent_LoggingId
		
		
		drop table if exists #BaseRequests
		
		select dataxtract_loggingid, sectionkeyid, total_records, DateLogRequest, replace(Section, '_Base', '') as Section into #BaseRequests
		from precheck.dbo.DataXtract_Logging (nolock)
		where Section in ('CC_Base', 'SBM_Base') and datediff(DAY, getdate(), datelogrequest) in (0) and total_records > 0
		
		
		select B.SectionKeyId, B.Total_Records as Total_Sent, isNull(ex.Exceptions, '') as Exceptions_Received,  B.Section, B.DateLogRequest as Date_Processed
		from #BaseRequests B
		inner join #Exceptions ex on ex.Parent_LoggingId = B.DataXtract_LoggingId
		                                                and ((cast(ex.Exceptions as float)/cast(B.Total_Records as float) >= 0.2 and b.Total_Records >= 10)
														or (cast(ex.Exceptions as float)/cast(B.Total_Records as float) >= 0.6 and b.Total_Records >= 5 and b.Total_Records < 10))
		order by Date_Processed desc

END
