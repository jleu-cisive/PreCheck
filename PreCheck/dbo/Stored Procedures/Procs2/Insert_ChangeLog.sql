-- =============================================
-- Author:		kiran miryala
-- Create date: 1/18/2013
-- Description:	insert into changelog if there is any change in apstatus
-- =============================================
CREATE PROCEDURE  [dbo].[Insert_ChangeLog]
	@APNO int
	, @Investigator varchar(20)
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

Declare @Oldapstatus as varchar(1)


	select @Oldapstatus = apstatus from Appl where APNO = @Apno


   INSERT INTO [dbo].[ChangeLog]
           ([TableName]
           ,[ID]
           ,[OldValue]
           ,[NewValue]
           ,[ChangeDate]
           ,[UserID])
     VALUES
           ('Appl.apstatus'
           ,@APNO
           ,@Oldapstatus
           ,'P'
           ,GETDATE()
           ,@Investigator)
END
