






Create PROCEDURE [dbo].[Iris_CriminalOneRecordSelect] 
@CrimID int

 AS

SELECT   dbo.Crim.CrimID,
         dbo.Crim.Clear 
From dbo.Crim 
WHERE  dbo.Crim.CrimID = @CrimID 
