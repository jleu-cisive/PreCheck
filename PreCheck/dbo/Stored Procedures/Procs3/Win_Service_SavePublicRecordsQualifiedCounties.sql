-- Alter Procedure Win_Service_SavePublicRecordsQualifiedCounties

CREATE PROCEDURE [dbo].[Win_Service_SavePublicRecordsQualifiedCounties]
	@apno int
AS
BEGIN
	DECLARE @source varchar(3) = 'PID', @sourceID int = 6
	
	UPDATE  dbo.ApplCounties 
	SET dbo.ApplCounties.IsActive = 0  
	WHERE dbo.ApplCounties.Apno = @apno AND dbo.ApplCounties.SourceID = @sourceID
	
	;WITH cte AS
	(
		SELECT aa.APNO, max(aa.ApplAddressID) AS ApplAddressID, aa.[State], aa.County, aa.Source, count(*) AS CountyCount
		FROM dbo.ApplAddress aa 
		WHERE aa.APNO = @apno AND aa.Source = @source
		GROUP BY aa.APNO,aa.[State], aa.County, aa.Source
	),
	cte1 AS 
	(
		SELECT c.APNO, c.County, c.[State], 
		c1.CNTY_NO, 
		Isnull(c1.isStatewide, 0) IsStatewide, 
		CASE c1.isStatewide 
			WHEN 1 THEN (SELECT TOP 1 co.CNTY_NO FROM dbo.Counties co WHERE co.[State] = c.[State] AND isnull(co.refCountyTypeID,0) = 2)
			ELSE c1.CNTY_NO
		END CntyToOrder,
		c.ApplAddressID AS SourceIdntyColValue,
		c.CountyCount
		FROM cte c
		LEFT JOIN dbo.Counties c1 ON c1.[State] = c.[State] AND c1.A_County = c.County
	)
	INSERT INTO dbo.ApplCounties
	(
	    Apno,
	    SourceID,
	    County,
	    [State],
	    IsStatewide,
	    CNTY_NUM,
	    CNTY_NUMToOrder,
	    CountyCount,
	    AddedOn,
	    SourceIdntyColValue,
	    IsActive
	    --ApplCountiesID - column value is auto-generated
	)
	SELECT 
	    c.APNO, -- Apno - int
	    @sourceID, -- SourceID - int
	    c.County, -- County - varchar
	    c.[State], -- State - varchar
	    c.IsStatewide, -- IsStatewide - bit
	    c.CNTY_NO, -- CNTY_NUM - int
	    c.CntyToOrder, -- CNTY_NUMToOrder - int
	    c.CountyCount, -- CountyCount - int
	    getdate(), -- AddedOn - datetime
	    c.SourceIdntyColValue, -- SourceIdntyColValue - int
	    1 -- IsActive - bit
	from cte1 c
END
