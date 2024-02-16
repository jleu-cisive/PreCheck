

/****** Object:  StoredProcedure [dbo].[EZVerify_LogInfo]    Script Date: 06/22/2011 11:06:38 ******/

-- =============================================
-- Author:		Najma Begum	
-- Create date: 06/21/2011
-- Description:	Log EZVerify EmplInfo status whether it has been verified/not verified or for errors
-- =============================================
CREATE PROCEDURE [dbo].[EZVerify_LogInfo]
	-- Add the parameters for the stored procedure here
	@UserID int, @VID nvarchar(50), @Success bit = 0, @Message text, @Invalidated bit = 0
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
    --declare @EID int
    --SET @EID = Left(@VID,Len(@VID)-4)
	INSERT INTO [EZVerifyLog]
           ([EZVUserID]
           ,[VerificationID]
           ,[Success]
           ,[ErrorLog]
           ,[VIDInvalidated]
         --  ,[EmplID]
           )
     VALUES(
           @UserID
           ,@VID
           ,@Success
           ,@Message
           ,@Invalidated
          -- ,@EID
           )
           
END
