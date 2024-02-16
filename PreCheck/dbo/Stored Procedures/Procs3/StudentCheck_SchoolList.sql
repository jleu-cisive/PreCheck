
		  CREATE Procedure [dbo].[StudentCheck_SchoolList]
		  (@CLNO int =0)
		  AS

DECLARE @StudentCheckTypeIdCSV VARCHAR(1000) 
SET @StudentCheckTypeIdCSV = (SELECT KeyValue FROM Enterprise.Config.Configuration WHERE KeyName='StudentCheck.ClientType.CSV')

DECLARE @StudentCheckType TABLE(ClientTypeId int)
INSERT INTO @StudentCheckType
SELECT Value FROM Enterprise.[dbo].[Split](@StudentCheckTypeIdCSV,',')

SELECT
       ClientNumber=c.CLNO,
       ClientName=c.Name,descriptivename [DisplayName - Inactive when blank],
       ClientTypeId=c.ClientTypeId,
       TypeName = CT.ClientType,
       Active = ~C.IsInactive
FROM 
       PreCheck.dbo.Client c
       INNER JOIN PreCheck..refClientType CT
              ON C.ClientTypeID=CT.ClientTypeID
       INNER JOIN @StudentCheckType T
              ON c.ClientTypeId=t.ClientTypeId
		Where (@CLNO =0 or CLNO = @CLNO) 
       ORDER BY C.Name