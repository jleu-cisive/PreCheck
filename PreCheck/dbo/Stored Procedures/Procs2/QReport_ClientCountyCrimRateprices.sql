-- =============================================  
-- Author:  Lalit   
-- Create date: 11/11/2022>  
-- Description: Client County Crim Rate prices  
-- EXEC QReport_ClientCountyCrimRateprices 7519
-- EXEC QReport_ClientCountyCrimRateprices 'hca'
-- EXEC QReport_ClientCountyCrimRateprices null
-- =============================================  
CREATE PROCEDURE [dbo].[QReport_ClientCountyCrimRateprices]   
   @input Varchar(100)=null

AS  
BEGIN

SET NOCOUNT ON;
Declare @CLNO int=null
Declare @ClientName Varchar(100)=null
if(isnumeric(isnull(@input,''))=1)
 begin
SET @CLNO = TRY_CAST(@input AS INT)
SET @ClientName = NULL
 end

 else

 begin
   if((isnull(@input,''))='')
	   begin
SET @CLNO = NULL
SET @ClientName = NULL
	   end
   else
   begin
SET @CLNO = NULL
SET @ClientName = TRY_CAST(@input AS VARCHAR)
   end
 end

--SELECT	@CLNO
--SELECT	@ClientName


DROP TABLE IF EXISTS #tmpcountyrate
DROP TABLE IF EXISTS #tmpcountyrate1
DROP TABLE IF EXISTS #tmpcountyrate2

IF (ISNULL(@CLNO, '') <> '')
BEGIN
SELECT
	c.CLNO
   ,[Name] AS "Client Name"
   ,[Accounting System Grouping]
   ,BillCycle AS [Billing Group]
   ,co.County AS County
   ,co.Crim_DefaultRate AS [Default Rate]
   ,(CASE
		WHEN ExcludeFromRules = 1 THEN 'True'
		ELSE 'False'
	END) AS "Exc (True/False)"
   ,Rate AS [Client Rate] INTO #tmpcountyrate
FROM ClientCrimRate ccr
INNER JOIN Client c
	ON ccr.CLNO = c.CLNO
INNER JOIN counties co
	ON ccr.CNTY_NO = co.CNTY_NO
WHERE c.CLNO = @CLNO

SELECT
	*
FROM #tmpcountyrate
ORDER BY CLNO, County
END

ELSE
BEGIN

IF (ISNULL(@ClientName, '') <> '')
BEGIN
SELECT
	c.CLNO
   ,[Name] AS "Client Name"
   ,[Accounting System Grouping]
   ,BillCycle AS [Billing Group]
   ,co.County AS County
   ,co.Crim_DefaultRate AS [Default Rate]
   ,(CASE
		WHEN ExcludeFromRules = 1 THEN 'True'
		ELSE 'False'
	END) AS "Exc (True/False)"
   ,Rate AS [Client Rate] INTO #tmpcountyrate1
FROM ClientCrimRate ccr
INNER JOIN Client c
	ON ccr.CLNO = c.CLNO
INNER JOIN counties co
	ON ccr.CNTY_NO = co.CNTY_NO
WHERE c.Name LIKE '%' + @ClientName + '%'

SELECT
	*
FROM #tmpcountyrate1
ORDER BY CLNO, County
END
ELSE
BEGIN
SELECT
	c.CLNO
   ,[Name] AS "Client Name"
   ,[Accounting System Grouping]
   ,BillCycle AS [Billing Group]
   ,co.County AS County
   ,co.Crim_DefaultRate AS [Default Rate]
   ,(CASE
		WHEN ExcludeFromRules = 1 THEN 'True'
		ELSE 'False'
	END) AS "Exc (True/False)"
   ,Rate AS [Client Rate] INTO #tmpcountyrate2
FROM ClientCrimRate ccr
INNER JOIN Client c
	ON ccr.CLNO = c.CLNO
INNER JOIN counties co
	ON ccr.CNTY_NO = co.CNTY_NO

SELECT
	*
FROM #tmpcountyrate2
ORDER BY CLNO, County
END

END

DROP TABLE IF EXISTS #tmpcountyrate
DROP TABLE IF EXISTS #tmpcountyrate1
DROP TABLE IF EXISTS #tmpcountyrate2
SET NOCOUNT OFF;

End

