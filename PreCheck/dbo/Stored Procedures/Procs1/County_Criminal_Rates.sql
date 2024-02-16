-- Alter Procedure County_Criminal_Rates
-- =============================================
-- Author:		Radhika Dereddy	
-- Create date: 01/27/2017
-- Description:	County Criminla Rates from Client Manager
-- =============================================
CREATE PROCEDURE dbo.County_Criminal_Rates
	-- Add the parameters for the stored procedure here

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT C.CLNO, C.NAME, CR.COUNTY,  CO.CRIM_DEFAULTRATE, CR.RATE
	FROM CLIENTCRIMRATE CR
	INNER JOIN dbo.TblCounties CO ON CO.CNTY_NO = CR.CNTY_NO
	INNER JOIN CLIENT C ON C.CLNO = CR.CLNO
	WHERE C.ISINACTIVE = 0

END
