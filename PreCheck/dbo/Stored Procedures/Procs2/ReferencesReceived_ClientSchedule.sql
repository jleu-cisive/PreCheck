-- =============================================
-- Author: Radhika Dereddy
-- Create date: 02/28/2021
-- Description: Number of references received per day. 
-- Execution: EXEC [ReferencesReceived_ClientSchedule]
-- =============================================
CREATE PROCEDURE [dbo].[ReferencesReceived_ClientSchedule] 

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	
DECLARE @StartDate DATE = DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE())-1, 0) --First day of previous month
DECLARE @EndDate DATE = DATEADD(MONTH, DATEDIFF(MONTH, -1, GETDATE())-1, -1) --Last Day of previous month

DROP TABLE IF EXISTS #VerificationTempTable 

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

 
SELECT COUNT(distinct Apno) AS [Number Of References]
From persref WITH(NOLOCK) 
WHERE Apno IN (SELECT Apno From #VerificationTempTable) 

END
