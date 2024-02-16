



CREATE PROCEDURE [dbo].[SectionOpen] 
(@UserID varchar(8), @TableName varchar(25),  @TableID int, @AccessRequested varchar(12), @Role as varchar(50))
AS
SET NOCOUNT ON

DECLARE @AccessGranted varchar(4), @SectionUsageID int, @APNO int, @InUse varchar(8) -- check against UserID

SET @AccessGranted='Read'  -- assume -- should we check about “none”?
SET @APNO = dbo.GetAPNOFromTable(@TableName, @TableID)

if @AccessRequested='Edit'
begin
	EXEC InUseSectionSet @TableName, @TableID, @UserID
	SET @InUse = dbo.GetInUseFromTable(@TableName, @TableID)

	If @InUse = null or @InUse = @UserID
	BEGIN
		SET @AccessGranted='Edit'
		
		--temp fix to mark Appl  InUse until all pieces of code honor the section InUse field
		--exec InUseSectionSet 'Appl', @APNO, UserID   
		--SET @InUse = dbo.GetInUseFromTable('Appl', @APNO)
		If @InUse = null or @InUse = @UserID
			SET @AccessGranted='Edit'  -- only set to Edit if both Appl and section are available
		Else
			EXEC InUseSectionClear @TableName, @TableID, UserID -- if can't get rights to Appl, clear this one
	END

end

INSERT INTO SectionUsage (TableName,TableID,APNO, UserID,TimeOpen, Role) VALUES (@TableName, @TableID, @APNO, @UserID,GetDate(), @Role)
SET @SectionUsageID=@@identity

SELECT @AccessGranted as AccessGranted, @SectionUsageID as SectionUsageID
