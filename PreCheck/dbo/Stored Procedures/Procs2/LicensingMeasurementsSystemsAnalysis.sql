-- =============================================
-- Author:		Suchitra Yellapantula
-- Create date: 10/27/2016
-- Description:	Stored procedure for the Licensing Measurements Systems Analysis Q-Report
--              Requested by Valerie Salazar 
-- Execution: exec [dbo].LicensingMeasurementsSystemsAnalysis '2005-10-01 12:00:00.000','10/25/2006 12:00:00','RN','FL:TX'
-- =============================================
CREATE PROCEDURE [dbo].[LicensingMeasurementsSystemsAnalysis] 
	-- Add the parameters for the stored procedure here
	@StartDate DateTime,
	@EndDate DateTime,
	@LicenseType nvarchar(MAX),
	@State nvarchar(MAX)

AS 

IF(@LicenseType = '' OR LOWER(@LicenseType) = 'null') BEGIN SET @LicenseType = NULL END
IF (@State = '' OR LOWER(@State) = 'null') BEGIN SET @State = NULL END

BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT Apno as 'Report Number',Lic_Type as 'License Type', [State] as 'License State', P.CreatedDate as 'License Received Date',P.time_in as 'Start Time',P.Last_Updated as 'Stop Time',
	'License Complete Date' = (Case when SectStat='5' or SectStat = '6' then Last_Updated  else NULL end) 
	INTO #Temp
	FROM ProfLic P
	WHERE ((@LicenseType IS NULL) OR (P.Lic_Type in (SELECT * FROM [dbo].[Split](':',@LicenseType))))
	AND (@State IS NULL OR P.State in (SELECT * FROM [dbo].[Split](':',@State)))
	AND P.CreatedDate between @StartDate and @EndDate
		

	select T.[Report Number], T.[License Type], T.[License State], T.[License Received Date], T.[Start Time], T.[Stop Time], T.[License Complete Date],
	'TAT per License' = 
	CASE 
		WHEN (T.[License Received Date] is not null and T.[License Complete Date] is not null)
		THEN
			CASE 
			WHEN dbo.ElapsedBusinessDays_2(T.[License Received Date],T.[License Complete Date])>0			
			--THEN CAST(dbo.ElapsedBusinessDays_2(T.[License Received Date],T.[License Complete Date]) as nvarchar(max)) + ' day(s)'
			THEN CAST(dbo.ElapsedBusinessHours(T.[License Received Date],T.[License Complete Date]) as nvarchar(max))
			
			WHEN dbo.ElapsedBusinessDays_2(T.[License Received Date],T.[License Complete Date])=0	
			THEN CAST(dbo.ElapsedBusinessHours(T.[License Received Date],T.[License Complete Date]) as nvarchar(max))
			ELSE 		       
			     CASE WHEN dbo.ElapsedBusinessHours(T.[License Received Date],T.[License Complete Date])>0
				 THEN CAST(dbo.ElapsedBusinessHours(T.[License Received Date],T.[License Complete Date]) AS nVARCHAR(MAX))
				 ELSE CAST((DATEDIFF(s,T.[License Received Date], T.[License Complete Date])/60)  AS nvarchar(max)) + ' mm : ' + CAST(DATEDIFF(s,T.[License Received Date], T.[License Complete Date])%60  AS NVARCHAR(MAX)) + ' ss'
				 END
			END
--		THEN	CAST((DATEDIFF(s,T.[License Received Date], T.[License Complete Date])/60)  AS nvarchar(max)) + ' : ' + CAST(DATEDIFF(s,T.[License Received Date], T.[License Complete Date])%60  AS NVARCHAR(MAX))
		ELSE ''
	END
	FROM #Temp T

END
