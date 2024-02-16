-- =============================================
-- Author:		Johnny Keller
-- Create date: 04/15/2021
-- Description:	This will pull the total amount of BG licenses
-- that have been ran for a given time frame. It will be either 
-- all the BG licenses in that time frame or for a specific
-- state-type. Depending on user input
-- =============================================
CREATE PROCEDURE [dbo].[AIMS_Pull_BG_License_Total] 
	-- Add the parameters for the stored procedure here
	@sectionKey nvarchar(30),
	@startDate nvarchar(20),
	@endDate nvarchar(20)

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	declare @scenarioControl int = case when @sectionKey = 'All' and @startDate = @endDate then 4
										when @sectionKey != 'All' and @startDate =  @endDate then 5
										when @sectionKey = 'All' and @startDate != 'Not Required' and @endDate != 'Not Required' then 1
										when @sectionKey != 'All' and @startDate != 'Not Required' and @endDate != 'Not Required' and @startDate != @endDate then 2
										when @sectionKey != 'All' and @startDate = 'Not Required' and @endDate = 'Not Required' then 3
										else 6
										end

	print @sectionKey
	print @startDate
	print @endDate
	print @scenarioControl

    -- All BGLicenses in a given time interval
	IF (@scenarioControl = 1)
	begin	
		select sum(isnull(total_records, 0)) as Interval_Totals from dataxtract_logging
		where section in ('BGlicense_base', 'BGNursys') 
		and (@startDate <= datelogrequest and @endDate >= datelogrequest);
	end

	--BGlicenses of a specific state-type in a given time interval
	IF (@scenarioControl = 2)
	begin	
		select sum(isnull(total_records, 0)) as Specific_Interval_Totals from dataxtract_logging
		where section in ('BGlicense_base', 'BGNursys') 
		and (@startDate <= datelogrequest and @endDate >= datelogrequest)
		and sectionkeyid = @sectionKey;
	end

	--BG licenses of a specific state-type in current month
	IF (@scenarioControl = 3)
	begin	
		select sum(isnull(total_records, 0)) as Specific_Monthly_Totals from dataxtract_logging
		where section in ('BGlicense_base', 'BGNursys') 
		and datediff(month, GetDate(), datelogrequest) = 0 
		and sectionkeyid = @sectionKey;
	end
	
	--BGlicenses of a specific state-type in a given time interval
	IF (@scenarioControl = 4)
	begin	
		select sum(isnull(total_records, 0)) as Daily_Totals from dataxtract_logging
		where section in ('BGlicense_base', 'BGNursys') 
		and datediff(day, @startDate, datelogrequest) = 0 
	end

	--BG licenses of a specific state-type in current day
	IF (@scenarioControl = 5)
	begin	
		select sum(isnull(total_records, 0)) as Specific_Daily_Totals from dataxtract_logging
		where section in ('BGlicense_base', 'BGNursys') 
		and datediff(day, @startDate, datelogrequest) = 0 
		and sectionkeyid = @sectionKey;
	end
	--Default case: all Bglicenses in current month 
	IF (@scenarioControl = 6) 
	begin	
		--@sectionKey in ('', 'All', null) and @startDate in ('', 'Not Required', null) and @endDate in ('', 'Not Required', null)
		select sum(isnull(total_records, 0)) as Monthly_Totals from dataxtract_logging
		where section in ('BGlicense_base', 'BGNursys') 
		and datediff(month, '04/01/2022', datelogrequest) = 0; 
	end
END
