-- =============================================
-- Author:		Deepak Vodethela
-- Create date: 02/14/2018
-- Description:	Report showing how many background reports were created in DEMI with each of the Salary Range options listed 
-- Execution: EXEC DEMI_Salary_Range '01/01/2017','12/31/2017'
-- =============================================
CREATE PROCEDURE DEMI_Salary_Range
	-- Add the parameters for the stored procedure here
	@StartDate DATETIME, 
	@EndDate DATETIME
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT Replace(REPLACE(D.SalaryRange, char(10),';'),char(13),';') as SalaryRange, COUNT(A.APNO) NoOfReports
	FROM ApplAdditionalData AS D(NOLOCK)
	INNER JOIN Appl AS A(NOLOCK) ON D.APNO = A.APNO
	WHERE ApDate BETWEEN @StartDate AND DATEADD(S,-1,DATEADD(D,1,@EndDate))  
	  AND D.DataSource = 'DEMI'
	GROUP BY Replace(REPLACE(D.SalaryRange, char(10),';'),char(13),';')
END
