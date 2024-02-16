/*

Create By:		Joshua Ates
Create Date:	1/26/2021
Description:	Calculates each agent average public record searches


EXAMPLE: EXECUTE dbo.AIMS_Public_Record_Search_Averages '1/1/2020','12/31/2020',3
*/


CREATE PROCEDURE AIMS_Public_Record_Search_Averages
(
	@Startdate  datetime	
   ,@Enddate	datetime	
   ,@AvgType	INT	--1 Day, 2 Week, 3 Month,4 quarter, 5 Year
)
AS
BEGIN
--DECLARE
--	@Startdate  datetime		=	'1/1/2020'	
--   ,@Enddate	datetime		=	'12/31/2020'
--   ,@AvgType	INT				=	3 --1 Day, 2 Week, 3 Month,4 quarter, 5 Year

	BEGIN --DateDifference Start 
		DECLARE
			 @DateDiff INT

		IF @AvgType = 1
		BEGIN
			SET @DateDiff = DATEDIFF(DAY,@Startdate,@Enddate)	
		END

		IF @AvgType = 2
		BEGIN
			SET @DateDiff = DATEDIFF(WEEK,@Startdate,@Enddate)	
		END

		IF @AvgType = 3
		BEGIN
			SET @DateDiff = DATEDIFF(MONTH,@Startdate,@Enddate)	
		END

		IF @AvgType = 4
		BEGIN
			SET @DateDiff = DATEDIFF(QUARTER,@Startdate,@Enddate)	
		END

		IF @AvgType = 5
		BEGIN
			SET @DateDiff = DATEDIFF(YEAR,@Startdate,@Enddate)	
		END

	END -- Date Difference End

	SELECT 
		 l.SectionKeyId
		,c.County
		,CAST(ROUND(CAST(SUM(l.Total_Records) AS decimal(18,0))/@DateDiff,0) AS INT)		AS AVG_Records
		,CAST(ROUND(CAST(SUM(l.Total_Exceptions) AS decimal(18,0))/@DateDiff,0) AS INT)		AS AVG_Exceptions
		,CAST(ROUND(CAST(SUM(l.Total_Clears) AS decimal(18,0))/@DateDiff,0) AS INT)			AS AVG_Clears	
		,CASE
			WHEN @AvgType = 1 THEN 'Day'
			WHEN @AvgType = 2 THEN 'Week'
			WHEN @AvgType = 3 THEN 'Month'
			WHEN @AvgType = 4 THEN 'Quarter'
			WHEN @AvgType = 5 THEN 'Year'
		 END AS AVGType
	FROM
		dbo.DataXtract_Logging l (NOLOCK)
	INNER JOIN 
		dbo.TblCounties c ON l.SectionKeyId = c.CNTY_NO
	WHERE SectionKeyID in (SELECT SectionKeyId FROM Dataxtract_RequestMapping WHERE Section ='Crim') 
		AND DateLogRequest BETWEEN @StartDate and DateAdd(d,1, @EndDate)
		AND Total_Records > 0
		AND Response IS NOT NULL
	GROUP BY 
		l.SectionKeyId, c.County
END