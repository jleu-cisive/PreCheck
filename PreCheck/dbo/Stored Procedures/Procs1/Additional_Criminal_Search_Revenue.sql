-- =============================================
-- Author:		DEEPAK VODETHELA
-- Create Date: 01/10/2017
-- Description: Average additional criminal charges for all CLNOs.  
-- Execution :	EXEC [dbo].[Additional_Criminal_Search_Revenue]  '12/01/2016','12/31/2016',''
--				EXEC [dbo].[Additional_Criminal_Search_Revenue]  '12/01/2016','12/31/2016', 0
--				EXEC [dbo].[Additional_Criminal_Search_Revenue]  '12/01/2016','12/31/2016', 12794
-- =============================================
CREATE PROCEDURE [dbo].[Additional_Criminal_Search_Revenue] 
	-- Add the parameters for the stored procedure here
	@StartDate DateTime,
	@EndDate DateTime,
	@CLNO INT 
AS
BEGIN

	-- SET NOCOUNT ON added to prevent extra result sets FROM
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	SELECT a.apno, Sum(i.amount) AS Amount, c.CLNO, c.Name as [Client Name], Count(I.Billed) as Billed
	INTO #temp1
	FROM Invdetail AS I (NOLOCK)
	INNER JOIN Appl AS A(NOLOCK) ON I.APNO =  A.APNO
	INNER JOIN Client AS C(NOLOCK) ON C.CLNo = A.CLNO
	WHERE I.Description LIKE '%Criminal Search%' 
	AND I.Amount <> 0.00 
	AND I.Billed = 1
	 -- AND c.clno = 1041
	AND C.CLNO = IIF(@CLNO=0,C.CLNO,@CLNO)
	AND I.CreateDate BETWEEN @StartDate AND DATEADD(S,-1,DATEADD(D,1,@EndDate))
	GROUP BY a.apno,i.amount, c.CLNO, c.Name
	ORDER BY a.apno

	SELECT CLNO, [Client Name], AVG(Amount) AS [Average Additional Criminal Search Revenue], Sum(Billed) AS [# of Additional Criminal Searches Billed (>$0)] 
	FROM #temp1 
	GROUP BY CLNO, [Client Name]
	ORDER BY CLNO

	DROP TABLE #temp1

	END