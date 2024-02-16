-- =============================================
-- Author:		Radhika Dereddy
-- Create date: 04/11/2017
-- Description:	Dana:query of any education verification for report where Tenet is contained in the affiliate, 
-- where public notes text contains "This institution is not accredited by any nationally recognized accrediting organization..." 
-- That is not the complete statement we use but is enough that we should be able to pull what we're looking for
-- =============================================
--EXEC Tenet_Education_Verification '01/01/2016','04/11/2017', 0
CREATE PROCEDURE Tenet_Education_Verification
	-- Add the parameters for the stored procedure here
    @STARTDATE datetime,
	@ENDDATE datetime,
	@CLNO int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

     	SELECT  A.APNO, A.APDATE, A.CLNO, C.NAME, A.FIRST, A.LAST, E.PUB_NOTES, RF.AFFILIATE, SS.DESCRIPTION AS [STATUS] FROM APPL A
		INNER JOIN CLIENT C ON C.CLNO = A.CLNO
		INNER JOIN EDUCAT E ON E.APNO = A.APNO
		INNER JOIN SECTSTAT SS ON SS.CODE = E.SECTSTAT
		INNER JOIN REFAFFILIATE RF ON RF.AFFILIATEID = C.AFFILIATEID
		WHERE  C.AFFILIATEID IN (10, 164, 166)
		AND (A.APDATE >= @STARTDATE AND A.APDATE <= @ENDDATE)
		AND  C.CLNO = IIF(@CLNO=0,C.CLNO,@CLNO)
		AND E.PUB_NOTES LIKE '%THIS INSTITUTION IS NOT ACCREDITED BY ANY NATIONALLY RECOGNIZED ACCREDITING ORGANIZATION%'
		ORDER BY APDATE DESC


END
