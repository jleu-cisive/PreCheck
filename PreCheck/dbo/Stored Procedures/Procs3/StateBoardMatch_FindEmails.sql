



CREATE PROCEDURE [dbo].[StateBoardMatch_FindEmails]
(
	@InputID uniqueidentifier 
)
AS

SELECT SBEA.*, CL.NAME AS ClientName, FA.FacilityName FROM dbo.[StateBoardEmailActivities] SBEA
INNER JOIN dbo.[StateBoardEmailBatch] SBEB ON [SBEA].[EmailBatchID]=SBEB.StateBoardEmailBatchID
INNER JOIN dbo.[StateBoardMatchIntermediateTable] SBMIT ON SBMIT.EmailReferenceID=SBEA.EmailReferenceID
INNER JOIN Rabbit.HEVN.dbo.[Client] CL ON CL.CLNO=SBEA.[ClientID]
LEFT JOIN  Rabbit.HEVN.dbo.[Facility] FA ON FA.[FacilityID]=SBEA.[FacilityID]
WHERE SBMIT.InputID=@InputID












