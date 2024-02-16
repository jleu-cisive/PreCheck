-- Alter Procedure AliasNames_Sent_by_DateRange
-- =============================================
-- Author:		Radhika Dereddy
-- Create date: 04/26/2018
-- Description:	Alias Names Sent by Date Range
-- =============================================
CREATE PROCEDURE dbo.AliasNames_Sent_by_DateRange
	-- Add the parameters for the stored procedure here
	@StartDate datetime,
	@EndDate datetime
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
SELECT APNO, CNTY_NO, County, SUM(AliasCount) AS AliasCount 
FROM  
(  
	SELECT A.APNO, C.CNTY_NO, C.County, 
		CAST(ISNULL(C.txtlast, 0) as int)  + CAST(ISNULL(C.txtalias, 0) as int)  + 
		CAST(ISNULL(C.txtalias2, 0) as int)  + CAST(ISNULL(C.txtalias3, 0) as int)  + 
		CAST(ISNULL(C.txtalias4, 0) as int) AS AliasCount  
	FROM dbo.Appl A  
	INNER JOIN dbo.Crim C ON A.APNO = C.APNO AND A.ApDate >=@StartDate AND A.ApDate < DATEADD(day, 1, @EndDate)            
			AND (C.txtlast = '1' OR C.txtalias = '1' OR C.txtalias2 = '1' OR C.txtalias3 = '1' OR C.txtalias4 = '1')               
	INNER JOIN dbo.TblCounties CN on C.CNTY_NO = CN.CNTY_NO 
) T1  
 group by CNTY_NO, County, APNO


END
