-- =================================================================================================
-- Author:		Suchitra Yellapantula
-- Create date: 2/24/2017
-- Description:	For Q-Report to pull all APNOs created within a date range for SSNs already on file
-- Execution: exec APNOsWithAlreadyExistingSSNs '2/21/2017','2/21/2017'
-- ==================================================================================================
CREATE PROCEDURE APNOsWithAlreadyExistingSSNs
	-- Add the parameters for the stored procedure here
	@StartDate date,
	@EndDate date
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here

select A.APNO, A.ApStatus, A.Investigator, A.CLNO, A.Last, A.First, A.CreatedDate
from Appl A where Priv_Notes like '%SSN ALREADY EXISTS%'
and CreatedDate >@StartDate and CreatedDate<dateadd(d,1,@StartDate) 

END
