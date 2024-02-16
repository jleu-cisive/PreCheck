-- Alter Procedure Criminal_PassThru_Charges_By_AllClients
-- =============================================
-- Author:		Radhika Dereddy
-- Create date: 07/20/2017
-- Description:	Criminal Pass Thru Charges By All Clients
-- =============================================
CREATE PROCEDURE dbo.Criminal_PassThru_Charges_By_AllClients
	-- Add the parameters for the stored procedure here
	@StartDate datetime,
	@EndDate datetime
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
		SELECT I.APNO
				, CC.Name
				, C.A_County + ', ' + C.State + ', ' + C.Country AS County
				, I.Amount AS InvoiceAmount
				, ISNULL(C.PassThroughCharge, 0.00) AS PassThroughCharge
	FROM  dbo.Appl A
				INNER JOIN dbo.InvDetail I ON A.APNO = I.APNO 
					  AND A.ApDate BETWEEN @StartDate AND @EndDate
					  AND I.Description LIKE 'Criminal Search:%'
				INNER JOIN dbo.TblCounties C ON REPLACE(I.Description, 'Criminal Search: ', '') = C.A_County + ', ' + C.State + ', ' + C.Country
				INNER JOIN dbo.Client CC ON A.CLNO = CC.CLNO
	ORDER BY CC.Name, A.APNO
END
