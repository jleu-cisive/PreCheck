






Create PROCEDURE [dbo].[Iris_CriminalOneRecordUpdate] 
@Clear varchar(1), 
@Original_CrimID int,
@Original_Clear varchar(1), 
@CrimID int
 AS
SET NOCOUNT OFF;
UPDATE    dbo.Crim
SET              Clear = @Clear
WHERE     (CrimID = @Original_CrimID) AND (Clear = @Original_Clear OR
                      @Original_Clear IS NULL AND Clear IS NULL);
                          SELECT     CrimID, Clear
                           FROM         dbo.Crim
                           WHERE     (CrimID = @CrimID)