-- =============================================
-- Author:		DEEPAK VODETHELA
-- Create date: 10/06/2018
-- Description:	Display the employment orders that are assigned to the user 'Overseas' for a given date parameter
-- Execution: Pending_Overseas_Employment_Orders '09/01/2018','10/16/2018'
-- =============================================
CREATE PROCEDURE Pending_Overseas_Employment_Orders 
	-- Add the parameters for the stored procedure here
	@StartDate DateTime,
	@EndDate DateTime
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Display the employment orders that are assigned to the user 'Overseas' 
	SELECT E.APNO, e.Employer
	FROM dbo.Empl e(NOLOCK) 
	WHERE e.IsOnReport = 1
	  AND e.SectStat = '9'
	  AND e.Investigator = 'Overseas'

END
