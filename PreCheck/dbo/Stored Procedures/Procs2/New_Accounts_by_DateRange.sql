-- =============================================
-- Author:		Radhika Dereddy
-- Create date: 07/20/2017
-- Description:	New Accounts by Date Range
-- =============================================
CREATE PROCEDURE New_Accounts_by_DateRange
		 @StartDate DATETIME,
		 @EndDate DATETIME
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
		
		SELECT Clno,Name AS [Client Name], CreatedDate, CAM, SalesPersonUserID AS [Sales Rep]
		FROM dbo.Client(nolock) 
		WHERE IsInactive = 0 
		AND (CreatedDate BETWEEN @StartDate AND DATEADD(d,1,@EndDate))
		Order by CreatedDate
END
