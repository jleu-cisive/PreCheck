-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE dbo.CredentCheckLicenseCounts_Auth
	-- Add the parameters for the stored procedure here
	@StartDate date,
	@EndDate date
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	SELECT         SectionKeyId as 'Board', 
                         ProcessDate, Total_Records, Total_Clears, Total_Exceptions, Total_Records -(Total_Clears +  Total_Exceptions) as NoUpdates
FROM            DataXtract_Logging
WHERE        Section = 'CredentCheck' and (Convert(date, ProcessDate) >= Convert(date, @StartDate) 
and Convert(date, ProcessDate) <= Convert(date, @EndDate))
order by                                  DataXtract_LoggingId 

  
END
