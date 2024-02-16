-- =============================================
-- Author:		Radhika Dereddy
-- Create date: 04/10/2017
-- Description:	Dana: Please provide details for any reports where Tenet is contained in the affiliate,
-- and there's a license with a status of Alert/Board Action or Alert/See Attached
-- =============================================
CREATE PROCEDURE Tenet_License_With_Status
	-- Add the parameters for the stored procedure here
	@STARTDATE datetime,
	@ENDDATE datetime,
	@CLNO int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
		SELECT  A.APNO, A.APDATE, A.CLNO, A.FIRST, A.LAST, SS.DESCRIPTION, RF.AFFILIATE FROM APPL A
		INNER JOIN CLIENT C ON C.CLNO = A.CLNO
		INNER JOIN PROFLIC P ON P.APNO = A.APNO
		INNER JOIN SECTSTAT SS ON SS.CODE = P.SECTSTAT
		INNER JOIN REFAFFILIATE RF ON RF.AFFILIATEID = C.AFFILIATEID
		WHERE  C.AFFILIATEID IN (10, 164, 166)
		AND P.SECTSTAT IN ('7', 'B')
		AND (A.APDATE >= @STARTDATE and A.APDATE <= @ENDDATE)
		AND  C.CLNO = IIF(@CLNO=0,C.CLNO,@CLNO)
		ORDER BY APDATE DESC
END
