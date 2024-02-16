-- =============================================
/* Created By: Vairavan A
-- Created Date : 10/28/2022
--Commented the below existing code and changed as new sp 
--DECLARE @StartDate datetime  DECLARE @EndDate datetime  DECLARE @ClientList varchar(8000)  SET @ClientList = --'2167:2569'--;  SET @StartDate =-- '05/01/2015'--;  SET @EndDate = --'05/31/2015'--;    SELECT Apno as 'Report Number', DeptCode FROM Appl WHERE  Apdate >= @StartDate and Apdate < @EndDate and CLNO in (select value from fn_Split(@ClientList,':'))
-- Description: Main Ticketno-67221 - Update Affiliate ID Parameter Parent HDT#56320

-- Execution:  exec dbo.[DeptCode_Info_ReviewReport] '2167:2569','05/01/2015','05/31/2015','158:117'
exec dbo.[DeptCode_Info_ReviewReport] '2167:2569','05/01/2015','05/31/2015','158:117'
*/
-- =============================================
CREATE PROCEDURE [dbo].DeptCode_Info_ReviewReport
	-- Add the parameters for the stored procedure here
	@ClientList varchar(8000) ='0',
	@StartDate Date,
	@EndDate Date,
	@AffiliateIDs varchar(MAX) = '0'--code added by vairavan for ticket id -67221

AS
BEGIN


--code added by vairavan for ticket id -67221 starts
IF @AffiliateIDs = '0' 
BEGIN  
	SET @AffiliateIDs = NULL  
END

IF @ClientList ='0'
BEGIN  
	SET @ClientList = NULL  
END
--code added by vairavan for ticket id -67221 ends

--SET @ClientList = --'2167:2569'--;
--SET @StartDate =-- '05/01/2015'--;  
--SET @EndDate = --'05/31/2015'--; 

SELECT a.Apno as 'Report Number', a.DeptCode
FROM Appl a  with(NOLOCK)
Left JOIN dbo.Client C with(nolock) ON a.CLNO = C.CLNO--code added by vairavan for ticket id - 67221
WHERE  a.Apdate >= @StartDate and a.Apdate < @EndDate
and (@ClientList IS NULL  or a.CLNO in (select value from fn_Split(@ClientList,':')))
and (@AffiliateIDs IS NULL OR C.AffiliateID IN (SELECT value FROM fn_Split(@AffiliateIDs,':')))--code added by vairavan for ticket id -67221

END