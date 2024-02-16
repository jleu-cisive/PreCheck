-- =============================================
-- Author:		Douglas DeGenaro
-- Create date: 07/24/2013
-- Description:	Get file locations for Images
-- =============================================
CREATE PROCEDURE dbo.PrecheckFramework_GetFileLocations 
	-- Add the parameters for the stored procedure here	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT 
		[ApplFileLocationID] ,[APNOStart] ,[APNOEnd] ,[FilePath] ,[GroupSize] ,[SubFolder] ,afl.[refApplTypeID] ,rf.Description,[SearchRoot] 
	FROM 
		[dbo].[ApplFileLocation] afl join [dbo].RefApplFileType rf 
	ON 
		afl.[refApplTypeID] = rf.[refApplFileTypeID]
END
