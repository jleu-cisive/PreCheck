


CREATE PROCEDURE [dbo].[Trong_DisplayRecords]
AS
SET NOCOUNT ON

DECLARE MyCursor CURSOR FOR
SELECT pm.PackageDesc
     , c.Name
     , cp.CLNO
     , pm.DefaultPrice
     , cp.Rate as Price 
     , cr.RateType as ServiceType
     , cr.Rate
     , dr.DefaultRate
     , ps.Includedcount
     , ps.MaxCount
     , dr.DefaultRate as PackageDefaultRate
FROM dbo.Packagemain pm 
	INNER JOIN dbo.clientpackages cp on pm.packageid=cp.packageid 
	INNER JOIN dbo.client c on c.clno=cp.clno
	INNER JOIN dbo.clientrates cr on cr.clno=c.clno
	INNER JOIN dbo.defaultrates dr on dr.ServiceID = cr.ServiceID
	INNER JOIN dbo.PackageService ps on ps.packageid = cp.packageid and ps.ServiceID = dr.ServiceID 
ORDER BY pm.packageid, c.Name, cr.RateType

DECLARE @PackageDesc varchar(100)
	, @Name varchar(100)
	, @Prev_CLNO int
	, @CLNO int
	, @DefaultPrice float
	, @Price float
	, @Prev_ServiceType varchar(10)
	, @ServiceType varchar(10)
	, @Rate float
	, @DefaultRate float
	, @Includedcount int
	, @MaxCount int
	, @PackageDefaultRate float
	, @Prev_ClientCrimRateID int
	, @ClientCrimRateID int
	, @County varchar(100)
    , @DCRRate float
	, @CCRRate float
	, @ExcludeFromRules varchar(3)
	, @ShowServiceType bit

SET @Prev_CLNO = 0
SET @Prev_ServiceType = NULL
SET @Prev_ClientCrimRateID = 0
SET @ClientCrimRateID = 0

CREATE TABLE #TempTable
(
	PackageDesc varchar(100)
	, Name varchar(100)
	, CLNO int
	, DefaultPrice float
	, Price float
	, ServiceType varchar(10)
	, Rate float
	, DefaultRate float
	, Includedcount int
	, MaxCount int
	, PackageDefaultRate float
	, County varchar(100)
    , DCRRate float
	, CCRRate float
	, ExcludeFromRules varchar(3)
)

DECLARE @CrimIncludedCount int
	, @CrimMaxCount int
	, @CrimDefaultRate float

SELECT TOP 1 @CrimDefaultRate = DefaultRate FROM dbo.DefaultRates WHERE ServiceID = 9

OPEN MyCursor
FETCH NEXT FROM MyCursor INTO @PackageDesc, @Name, @CLNO, @DefaultPrice, @Price, @ServiceType, @Rate, @DefaultRate, @Includedcount, @MaxCount, @PackageDefaultRate--, @County, @CCRRate, @ExcludeFromRules
WHILE @@FETCH_STATUS = 0
BEGIN
	IF @CLNO <> @Prev_CLNO	--reset
	BEGIN
		SET @Prev_ClientCrimRateID = 0
		SET @ClientCrimRateID = 0

		IF @Prev_CLNO <> 0 --create crim record
		BEGIN
			SELECT TOP 1 
				@CrimIncludedCount = IncludedCount
				, @CrimMaxCount = MaxCount 
			FROM dbo.PackageService PS
				INNER JOIN dbo.ClientPackages CP ON PS.PackageID = CP.PackageID
				INNER JOIN dbo.Client C ON CP.CLNO = C.CLNO
			WHERE PS.ServiceID = 9 AND C.CLNO = @CLNO

			INSERT INTO #TempTable
			SELECT NULL	--PackageDesc
				, NULL	--Name
				, NULL	--CLNO
				, NULL	--DefaultPrice
				, NULL	--Price
				, 'CRIM'	--ServiceType
				, 0		--Rate
				, @CrimDefaultRate
				, @CrimIncludedCount
				, @CrimMaxCount
				, @CrimDefaultRate
				, NULL
				, NULL
				, NULL
		END
	END

	IF @CLNO = @Prev_CLNO AND @ServiceType = @Prev_ServiceType 
		SET @ShowServiceType = 0
	ELSE
		SET @ShowServiceType = 1

	SELECT TOP 1 @ClientCrimRateID = ClientCrimRateID
		, @County = dbo.ClientCrimRate.County
        , @DCRRate = dbo.Counties.Crim_DefaultRate
		, @CCRRate = Rate
		, @ExcludeFromRules = CASE WHEN ExcludeFromRules = 1 THEN 'Yes' ELSE 'No' END
	FROM dbo.ClientCrimRate join Counties on dbo.Counties.CNTY_NO = dbo.ClientCrimRate.CNTY_NO
	--WHERE 
        AND CLNO = @CLNO
		AND ClientCrimRateID > @ClientCrimRateID

	IF @Prev_ClientCrimRateID = @ClientCrimRateID
	BEGIN
		SET @ClientCrimRateID = NULL
		SET @County = NULL
        SET @DCRRate = NULL
     	SET @CCRRate = NULL
		SET @ExcludeFromRules = NULL
	END

	INSERT INTO #TempTable
	SELECT CASE WHEN @CLNO = @Prev_CLNO THEN NULL ELSE @PackageDesc END AS PackageDesc
		, CASE WHEN @CLNO = @Prev_CLNO THEN NULL ELSE @Name END AS Name
        , CASE WHEN @CLNO = @Prev_CLNO THEN NULL ELSE @CLNO END AS CLNO
        , CASE WHEN @CLNO = @Prev_CLNO THEN NULL ELSE @DefaultPrice END AS DefaultPrice
        , CASE WHEN @CLNO = @Prev_CLNO THEN NULL ELSE @Price END AS Price
		--, @CLNO AS CLNO
		--, @DefaultPrice AS DefaultPrice
		--, @Price AS Price
		, CASE WHEN @ShowServiceType = 1 THEN @ServiceType ELSE NULL END AS ServiceType
		, CASE WHEN @ShowServiceType = 1 THEN @Rate ELSE NULL END AS Rate
		, CASE WHEN @ShowServiceType = 1 THEN @DefaultRate ELSE NULL END AS DefaultRate
		, CASE WHEN @ShowServiceType = 1 THEN @Includedcount ELSE NULL END AS Includedcount
		, CASE WHEN @ShowServiceType = 1 THEN @MaxCount ELSE NULL END AS MaxCount
		, CASE WHEN @ShowServiceType = 1 THEN @PackageDefaultRate ELSE NULL END AS PackageDefaultRate
		, @County AS County
        , @DCRRate as Crim_DefaultRate
		, @CCRRate AS Rate
		, @ExcludeFromRules AS ExcludeFromRules
		--, (SELECT TOP 1 County FROM dbo.ClientCrimRate WHERE CLNO = @CLNO AND ClientCrimRateID NOT IN (SELECT ClientCrimRateID FROM #TempTable WHERE CLNO = @CLNO)) AS County
		--, (SELECT TOP 1 Rate FROM dbo.ClientCrimRate WHERE CLNO = @CLNO AND ClientCrimRateID NOT IN (SELECT ClientCrimRateID FROM #TempTable WHERE CLNO = @CLNO)) AS Rate
		--, (SELECT TOP 1 CASE WHEN ExcludeFromRules = 1 THEN 'Yes' ELSE 'No' END FROM dbo.ClientCrimRate WHERE CLNO = @CLNO AND ClientCrimRateID NOT IN (SELECT ClientCrimRateID FROM #TempTable WHERE CLNO = @CLNO)) AS ExcludeFromRules
		--, (SELECT TOP 1 ClientCrimRateID FROM dbo.ClientCrimRate WHERE CLNO = @CLNO AND ClientCrimRateID NOT IN (SELECT ClientCrimRateID FROM #TempTable WHERE CLNO = @CLNO)) AS ExcludeFromRules
	
	SET @Prev_CLNO = @CLNO
	SET @Prev_ClientCrimRateID = @ClientCrimRateID
	SET @Prev_ServiceType = @ServiceType

	FETCH NEXT FROM MyCursor INTO @PackageDesc, @Name, @CLNO, @DefaultPrice, @Price, @ServiceType, @Rate, @DefaultRate, @Includedcount, @MaxCount, @PackageDefaultRate--, @County, @DCRRate, @CCRRate, @ExcludeFromRules
END

CLOSE MyCursor
DEALLOCATE MyCursor

SELECT * FROM #TempTable
DROP TABLE #TempTable
SET NOCOUNT OFF


