-- =============================================
-- Author:		Radhika Dereddy
-- Create date: 06/06/2017
-- Description:	Dana: Reports both received and closed during the date parameters for either the CLNO 
-- or affiliate group, and a T/F as to whether they had any components added after the initial review date.  
-- =============================================
CREATE PROCEDURE Reports_with_Items_Added_After_Review
	-- Add the parameters for the stored procedure here
	@CLNO int,
	@Affiliate varchar(max) = NULL,
	@StartDate datetime,
	@EndDate datetime
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT A.APDATE 'RECEIVED DATE', A.CLNO,C.NAME, A.APNO 'REPORT NUMBER',A.LAST 'APPLICANT LAST', A.FIRST 'APPLICANT FIRST', DBO.ELAPSEDBUSINESSDAYS_2(A.APDATE, A.ORIGCOMPDATE) AS 'TURNAROUND TIME OF REPORT'
	FROM APPL A WITH(NOLOCK)
	INNER JOIN CLIENT C WITH(NOLOCK) ON A.CLNO = C.CLNO
	INNER JOIN REFAFFILIATE RA WITH(NOLOCK) ON C.AFFILIATEID = RA.AFFILIATEID
	WHERE (A.APDATE BETWEEN @STARTDATE AND DATEADD(D,1,@ENDDATE)) AND C.CLNO = IIF(@CLNO=0,C.CLNO,@CLNO)
	AND (@AFFILIATE IS NULL OR RA.AFFILIATE = @AFFILIATE)

END
