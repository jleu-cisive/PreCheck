CREATE PROCEDURE [StudentCheck].[UpdDWHLog]
    @DWHLogId INT,
	@HasError BIT,
	@ErrorMessage VARCHAR(MAX) = NULL,
	--@IsComplete BIT,
	@CountInsert INT,
	@CountUpdate INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
    Update StudentCheck.DWHLog
        SET
        [EndTime] = GETDATE()
       ,[HasError] = @HasError
       ,[ErrorMessage] = CASE WHEN ISNULL(@ErrorMessage,'')='' THEN NULL ELSE @ErrorMessage end
       ,[IsComplete] = 1
       ,[CountInsert] = @CountInsert
       ,[ModifyDate] = CURRENT_TIMESTAMP 
       ,[CountUpdate] = @CountUpdate
	    WHERE DWHLogId = @DWHLogId

   
END

