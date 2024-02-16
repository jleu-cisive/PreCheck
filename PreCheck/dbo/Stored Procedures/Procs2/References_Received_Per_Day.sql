
-- =============================================
-- Author:		DEEPAK VODETHELA
-- Create date: 04/23/2019
-- Description: Number of references received per day. 
-- Execution: EXEC References_Received_Per_Day '04/22/2019','04/22/2019'
-- =============================================
-- Modify by : Arindam Mitra  
-- Modify Date : 12/05/2023  
-- Desc : References received report was not pulling data correctly. HDT# 119332  
-- EXEC References_Received_Per_Day '11/01/2023','11/30/2023'
-- ============================================= 
CREATE PROCEDURE [dbo].[References_Received_Per_Day] 
	-- Add the parameters for the stored procedure here
	@StartDate Date,
	@EndDate Date
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	-- code commented starts against HDT# 119332
	/*  
	CREATE TABLE #VerificationTempTable  
	(  
		Apno int
	)  
	
	INSERT INTO #VerificationTempTable
	SELECT Apno
	FROM precheckservicelog WITH (NOLOCK) 
	WHERE request.value(
				'declare namespace a="http://schemas.datacontract.org/2004/07/PreCheckBPMServiceHelper"; 
				 declare namespace i="http://www.w3.org/2001/XMLSchema-instance"; 
				 declare namespace m="http://schemas.datacontract.org/2004/07/PreCheck.Services.WCF.DataContracts"; 
				 (/m:UpsertRequest/m:Application/a:NewApplicants/a:NewApplicant/a:PersonalReferences/a:PersonalReference/a:SectStat)[1]', 'nvarchar') like '%9%'
	AND ServiceDate > @StartDate AND ServiceDate < DATEADD(DAY, 1, @EndDate)

	---SELECT * From #VerificationTempTable

	SELECT COUNT(distinct Apno) AS [Number Of References]
	From persref (NOLOCK) 
	WHERE Apno IN (SELECT Apno From #VerificationTempTable) 

	Drop Table #VerificationTempTable 

	*/
	--code commented ends against HDT# 119332 

	SELECT SUM(Referencecount) AS [Number Of References]  FROM
 (
	 SELECT persref.apno,  count(1) Referencecount   
	 From persref PersRef (NOLOCK) 
	 LEFT JOIN Appl A (NOLOCK)  On PersRef.APNO=A.APNO  
	 INNER JOIN Client C (NOLOCK)  On A.ClNO=C.CLNO 
	 INNER JOIN dbo.refAffiliate ra (NOLOCK) ON c.AffiliateID = ra.AffiliateID  
	 where PersRef.IsOnReport = 1  
	   AND persref.ishidden = 0 
	   AND PersRef.createddate BETWEEN @StartDate AND DateAdd(d, 1, @EndDate) 
	   GROUP BY persref.apno
   ) ref


	/*
    -- Insert statements for procedure here
	SELECT COUNT(DISTINCT pf.APNO) [Number Of References]
	FROM dbo.PersRef pf(NOLOCK) 
	WHERE pf.Last_Updated > @StartDate 
	  AND pf.Last_Updated < DATEADD(DAY, 1, @EndDate)
	*/
END
