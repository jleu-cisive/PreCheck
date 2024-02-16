-- =============================================
-- Author:		Dongmei He
-- Create date: 03/11/2022
-- Description:	Inserts new entry to 
--              StudentCheck.DWHLog
-- =============================================
CREATE PROCEDURE [StudentCheck].[InsDWHLog]
AS
BEGIN 
--TRY
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
   
   INSERT INTO StudentCheck.DWHLog
   (
        [StartTime]
       ,[EndTime]
       ,[HasError]
       ,[ErrorMessage]
       ,[IsComplete]
       ,[CreateDate]
       ,[CountInsert]
       ,[ModifyDate]
       ,[CountUpdate]
   )
   VALUES
   (   
       GETDATE(),
	   GETDATE(),
	   0,
	   null,
	   0,
       GETDATE(), 
       0,         
       GETDATE(), 
       0         
       )
 	SELECT SCOPE_IDENTITY()
END 



