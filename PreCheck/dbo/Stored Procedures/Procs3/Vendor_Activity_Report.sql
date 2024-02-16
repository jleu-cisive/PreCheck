-- =============================================
-- Author:		Radhika Dereddy
-- Create date: 04/20/2017
-- Description:	Searched done by Vendor between the date range

--EXEC Vendor_Activity_Report '01/01/2017','04/20/2017'
-- =============================================
CREATE PROCEDURE [dbo].[Vendor_Activity_Report]
	-- Add the parameters for the stored procedure here
	@StartDate datetime,
	@EndDate datetime 
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;


	-- Step 1 - Get the Vendors List who have record count between a date range
	CREATE TABLE #TEMPVENDOR
	( NAME VARCHAR(100),
	  ID INT,
	  RECORDCOUNT INT,
	)

	-- Insert into temp table with count
	INSERT INTO #TEMPVENDOR
	SELECT IR.R_NAME AS VENDORNAME, IR.R_ID AS VENDORID, COUNT(RESULTLOGID) AS RECORDCOUNT
	FROM DBO.IRIS_RESULTLOG RL WITH(NOLOCK) 
	INNER JOIN CRIM C (NOLOCK) ON RL.CRIMID = C.CRIMID  
	INNER JOIN IRIS_RESEARCHERS IR (NOLOCK) ON C.VENDORID = IR.R_ID 
	WHERE RL.LOGDATE >= @STARTDATE AND LOGDATE < DATEADD(DAY, 1, @ENDDATE)
	GROUP BY R_ID, R_NAME ORDER BY R_NAME ASC



	-- Step 2 - Get the Vendors List who did not have a record count and still be displayed as ZERO
	CREATE TABLE #TEMPVENDORNOCOUNT
	( NAME VARCHAR(100),
	  ID INT,
	  RECORDCOUNT INT,
	)

	-- Insert into temp table with no count (0 as count)
	INSERT INTO #TEMPVENDORNOCOUNT
	SELECT IR.R_NAME AS VENDORNAME, IR.R_ID AS VENDORID, 0 AS RECORDCOUNT	
	FROM IRIS_RESEARCHERS IR 
	WHERE R_ID NOT IN (Select Distinct ID FROM #TEMPVENDOR) AND R_NAME IS NOT NULL


	-- Step 3 - Display all the Vendors List combining both tables
	(Select * from #TEMPVENDOR

	UNION ALL

	SELECT * FROM #TEMPVENDORNOCOUNT ) ORDER BY NAME ASC


	-- Step 4 - Drop temp Tables
	DROP TABLE #TEMPVENDOR 

	DROP TABLE #TEMPVENDORNOCOUNT

	

END
