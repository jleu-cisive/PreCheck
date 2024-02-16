
-- =============================================
-- Author:		Radhika Dereddy
-- Create date: 01/14/2019
-- Description:	Process Level Facilities to display for the Drug Test Order placed under a specific Process Level.
-- EXEC ClientAccess_GetProcessLevelFacilities 7519, '254'
-- =============================================
CREATE PROCEDURE [dbo].[ClientAccess_GetProcessLevelFacilities]
	-- Add the parameters for the stored procedure here
@CLNO int,
@ProcessLevel varchar(10)

AS
BEGIN

DECLARE @StaticFacilities VARCHAR(1000), @FacilityListCount Int
SELECT @StaticFacilities = Value FROM ClientConfiguration WHERE ConfigurationKey = 'DrugTestOrder_ListFacilityCLNO' AND CLNO=@CLNO

DECLARE @ListFacilities table
(
	CLNO INT,
	ClientName VARCHAR(100),
	DisplayFlag BIT NULL
)

INSERT INTO @ListFacilities
SELECT DISTINCT CLNO = f.FacilityCLNO, ClientName = CONCAT(C.CLNO, ' - ', C.Name), DisplayFlag = 0
FROM HEVN.dbo.Facility F
INNER JOIN ClientConfiguration_DrugScreening dc (NOLOCK) ON f.FacilityCLNO=dc.CLNO
INNER JOIN CLIENT C(NOLOCK) ON F.FacilityCLNO=C.CLNO
WHERE F.FacilityNum = @ProcessLevel 
AND F.FacilityCLNO IS NOT NULL
AND F.ParentEmployerID = @CLNO


SELECT @FacilityListCount = COUNT(1) FROM @ListFacilities


SELECT DISTINCT * FROM 
(
	SELECT  CLNO, CLIENTNAME,DisplayFlag = CASE WHEN @FacilityListCount = 1 THEN 1 ELSE 0 END   
	FROM @ListFacilities

	UNION ALL

	SELECT  C.CLNO, CONCAT(C.CLNO, ' - ', C.Name),DisplayFlag = CASE WHEN @FacilityListCount = 0 and c.CLNO =@CLNO THEN 1 ELSE 0 End  
	FROM SPLIT(',', @StaticFacilities) S
	INNER JOIN CLIENT C 
	ON S.Item=C.CLNO

) Qry1


END
