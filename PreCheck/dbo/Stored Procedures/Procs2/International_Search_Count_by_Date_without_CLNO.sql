-- Alter Procedure International_Search_Count_by_Date_without_CLNO
-- =============================================
-- Author:		Radhika Dereddy
-- Create date: 07/20/2017
-- Description:	International Search Count by Date - w/o CLNO
-- =============================================
CREATE PROCEDURE dbo.International_Search_Count_by_Date_without_CLNO
	-- Add the parameters for the stored procedure here
	 @StartDate datetime,
	 @EndDate datetime
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;  

		SELECT C.COUNTY,CC.COUNTRY,COUNT(*) AS ORDERCOUNT FROM APPL A  WITH (NOLOCK)
		INNER JOIN CRIM C WITH (NOLOCK) ON A.APNO = C.APNO
		INNER JOIN dbo.TblCounties CC WITH (NOLOCK) ON C.CNTY_NO = CC.CNTY_NO
		WHERE A.APDATE >= @STARTDATE AND A.APDATE < @ENDDATE
		AND C.CNTY_NO IN (SELECT CNTY_NO FROM dbo.TblCounties WHERE ISNULL(COUNTRY,'') NOT IN ('USA','STATEWIDE'))
		GROUP BY C.COUNTY,CC.COUNTRY

END
