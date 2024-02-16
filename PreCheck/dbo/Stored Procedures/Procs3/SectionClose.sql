CREATE PROCEDURE SectionClose @SectionUsageID int, @TableName varchar(50), @TableID int AS
	--Log out	
	UPDATE SectionUsage SET TimeClose=GetDate() WHERE SectionUsageID=@SectionUsageID;

	--Mark as not used
	exec InUseSectionClear @TableName, @TableID

-- until all programs honor the section InUse flag, SectionOpen sets the Appl.InUse flag, so we need to clear it here
--DECLARE @APNO int
--SET @APNO = dbo.GetAPNOFromTable(@TableName, @TableID)
	--exec InUseSectionClear 'Appl', @APNO