  
-- =============================================  
-- Author:  Lalit   
-- Create date: 11/11/2022>  
-- Description: Line Item Charges  
-- EXEC [QReport_LineItemCharges] 7519
-- EXEC [QReport_LineItemCharges] 'hca'
-- EXEC [QReport_LineItemCharges] null
-- =============================================  
CREATE PROCEDURE [dbo].[QReport_LineItemCharges]   
 @input Varchar(100)=Null

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

--SELECT 	@CLNO
--SELECT	@ClientName


DROP TABLE IF EXISTS #tmplinerate
DROP TABLE IF EXISTS #tmplinerate1
DROP TABLE IF EXISTS #tmplinerate2

IF (ISNULL(@CLNO, '') <> '')
BEGIN


SELECT
	cl1.CLNO
   ,"Client Name"
   ,"Accounting System Group"
   ,"Billing Grp"
   ,"CIV Client Rate"
   ,"CRED Client Rate"
   ,"CRIM Client Rate"
   ,"DL Client Rate"
   ,"EDUC Client Rate"
   ,"EMPL Client Rate"
   ,"PERS Client Rate"
   ,"PROF Client Rate"
   ,"SOC Client Rate"
   ,[One Price All Counties] INTO #tmplinerate
FROM (SELECT
		CLNO
	   ,"Name" AS "Client Name"
	   ,"Accounting System Grouping" AS "Accounting System Group"
	   ,BillCycle AS "Billing Grp"
	   ,OneCountyPrice AS "CRIM Client Rate"
	   ,(CASE
			WHEN OneCountyPricing = 1 THEN 'True'
			ELSE 'False'
		END) AS [One Price All Counties]
	FROM PRECHECK.dbo.Client c
	WHERE c.CLNO = @CLNO) cl1
INNER JOIN (SELECT
		CLNO
	   ,civ AS 'CIV Client Rate'
	   ,cred AS 'CRED Client Rate'
	   ,DL AS 'DL Client Rate'
	   ,EDUC AS 'EDUC Client Rate'
	   ,Empl AS 'EMPL Client Rate'
	   ,PERS AS 'PERS Client Rate'
	   ,PROF AS 'PROF Client Rate'
	   ,SOC AS 'SOC Client Rate'
	FROM (SELECT
			c.CLNO
		   ,RateType
		   ,Rate
		FROM PRECHECK.dbo.ClientRates cr
		INNER JOIN Client c
			ON c.CLNO = cr.CLNO
		WHERE c.CLNO = @CLNO) d
	PIVOT
	(
	MAX(Rate)
	FOR RateType IN (civ, cred, DL, EDUC, Empl, PERS, PROF, SOC)
	) piv) cl2
	ON cl1.CLNO = cl2.CLNO
ORDER BY cl1.CLNO

SELECT
	*
FROM #tmplinerate
ORDER BY CLNO
END

ELSE
BEGIN

IF (ISNULL(@ClientName, '') <> '')
BEGIN
SELECT
	cl1.CLNO
   ,"Client Name"
   ,"Accounting System Group"
   ,"Billing Grp"
   ,"CIV Client Rate"
   ,"CRED Client Rate"
   ,"CRIM Client Rate"
   ,"DL Client Rate"
   ,"EDUC Client Rate"
   ,"EMPL Client Rate"
   ,"PERS Client Rate"
   ,"PROF Client Rate"
   ,"SOC Client Rate"
   ,[One Price All Counties] INTO #tmplinerate1
FROM (SELECT
		CLNO
	   ,"Name" AS "Client Name"
	   ,"Accounting System Grouping" AS "Accounting System Group"
	   ,BillCycle AS "Billing Grp"
	   ,OneCountyPrice AS "CRIM Client Rate"
	   ,(CASE
			WHEN OneCountyPricing = 1 THEN 'True'
			ELSE 'False'
		END) AS [One Price All Counties]
	FROM PRECHECK.dbo.Client c
	WHERE c.Name LIKE '%' + @ClientName + '%') cl1
INNER JOIN (SELECT
		CLNO
	   ,civ AS 'CIV Client Rate'
	   ,cred AS 'CRED Client Rate'
	   ,DL AS 'DL Client Rate'
	   ,EDUC AS 'EDUC Client Rate'
	   ,Empl AS 'EMPL Client Rate'
	   ,PERS AS 'PERS Client Rate'
	   ,PROF AS 'PROF Client Rate'
	   ,SOC AS 'SOC Client Rate'
	FROM (SELECT
			c.CLNO
		   ,RateType
		   ,Rate
		FROM PRECHECK.dbo.ClientRates cr
		INNER JOIN Client c
			ON c.CLNO = cr.CLNO
		WHERE c.Name LIKE '%' + @ClientName + '%') d
	PIVOT
	(
	MAX(Rate)
	FOR RateType IN (civ, cred, DL, EDUC, Empl, PERS, PROF, SOC)
	) piv) cl2
	ON cl1.CLNO = cl2.CLNO
ORDER BY cl1.CLNO

SELECT
	*
FROM #tmplinerate1
ORDER BY CLNO
END
ELSE
BEGIN
SELECT
	cl1.CLNO
   ,"Client Name"
   ,"Accounting System Group"
   ,"Billing Grp"
   ,"CIV Client Rate"
   ,"CRED Client Rate"
   ,"CRIM Client Rate"
   ,"DL Client Rate"
   ,"EDUC Client Rate"
   ,"EMPL Client Rate"
   ,"PERS Client Rate"
   ,"PROF Client Rate"
   ,"SOC Client Rate"
   ,[One Price All Counties] INTO #tmplinerate2
FROM (SELECT
		CLNO
	   ,"Name" AS "Client Name"
	   ,"Accounting System Grouping" AS "Accounting System Group"
	   ,BillCycle AS "Billing Grp"
	   ,OneCountyPrice AS "CRIM Client Rate"
	   ,(CASE
			WHEN OneCountyPricing = 1 THEN 'True'
			ELSE 'False'
		END) AS [One Price All Counties]
	FROM PRECHECK.dbo.Client --Where clno in (7519,1169,1531) 
) cl1
INNER JOIN (SELECT
		CLNO
	   ,civ AS 'CIV Client Rate'
	   ,cred AS 'CRED Client Rate'
	   ,DL AS 'DL Client Rate'
	   ,EDUC AS 'EDUC Client Rate'
	   ,Empl AS 'EMPL Client Rate'
	   ,PERS AS 'PERS Client Rate'
	   ,PROF AS 'PROF Client Rate'
	   ,SOC AS 'SOC Client Rate'
	FROM (SELECT
			CLNO
		   ,RateType
		   ,Rate
		FROM PRECHECK.dbo.ClientRates
	--Where clno in (7519,1169,1531)
	) d
	PIVOT
	(
	MAX(Rate)
	FOR RateType IN (civ, cred, DL, EDUC, Empl, PERS, PROF, SOC)
	) piv) cl2
	ON cl1.CLNO = cl2.CLNO
ORDER BY cl1.CLNO

SELECT
	*
FROM #tmplinerate2
ORDER BY CLNO
END

END

DROP TABLE IF EXISTS #tmplinerate
DROP TABLE IF EXISTS #tmplinerate1
DROP TABLE IF EXISTS #tmplinerate2
SET NOCOUNT OFF;

End

-------------------------

