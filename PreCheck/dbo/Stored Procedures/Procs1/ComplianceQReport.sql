-- =============================================
-- Author:		Radhika Dereddy
-- Create date: 07/16/2020
-- Description:	Compliance Qreport for Max
-- =============================================
CREATE PROCEDURE [dbo].[ComplianceQReport]
	-- Add the parameters for the stored procedure here
	@StartDate datetime,
	@EndDate datetime,
	@UserId varchar(8)

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here


	SELECT a.APNO FROM APPL a
	INNER JOIN AdverseAction aa ON a.apno = aa.apno
	INNER JOIN AdverseActionHistory aah ON aa.AdverseActionID = aah.AdverseActionid
	WHERE aah.UserID =@UserId and a.apdate between @StartDate and DateAdd(day,1,@EndDate)



END
