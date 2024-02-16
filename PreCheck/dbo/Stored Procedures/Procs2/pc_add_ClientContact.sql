



-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[pc_add_ClientContact]
	
@clientid		int,
 @FirstName nvarchar(50),
@LastName nvarchar(50),
@MiddleName nvarchar(50),
@Phone nvarchar(30),
@Ext nvarchar(30),
@Email nvarchar(50),
@username nvarchar(14),
@UserPassword nvarchar(14),
@IsActive bit,
@ClientRoleID  int

As

INSERT INTO ClientContacts
           ([CLNO]
           ,[PrimaryContact]
           ,[ReportFlag]
           ,[FirstName]
           ,[MiddleName]
           ,[LastName]
           ,[Phone]
           ,[Ext]
           ,[Email]
           ,[username]
           ,[UserPassword]
           ,[WOLockout]
           ,[GetsReport]
           ,[IsActive]
           ,[ClientRoleID])
     VALUES 
		(@clientid,	0,0,
			 @FirstName, @MiddleName, @LastName, @Phone, @Ext, @Email, @username, @UserPassword, 
          
           0,0, @IsActive, @ClientRoleID)

		IF @clientid = 12444 
		BEGIN

			DECLARE @msg NVARCHAR(500),@NeedPrivileges INT,@clientCAM VARCHAR(8)

			SET @msg = 'This is to inform you that a new client contact: ' + @FirstName + ' ' + @LastName + ' has been created for CLNO: ' +  cast(@clientid as nvarchar)+  ', who needs User Privileges to be setup before they can start using Client Access. ' 

			set @msg = @msg + ' Please collect the information for the user privilege and create a help desk ticket to set up the privileges. ' 

			EXEC msdb.dbo.sp_send_dbmail   @from_address = 'New Client Contact needs User Privileges <DoNotReply@PreCheck.com>',@subject=N'US Oncology Data Error Notification', @recipients=N'santoshchapyala@Precheck.com;CarlaBingham@PRECHECK.com;JenniferPrather@precheck.com',    @body=@msg ;
		END

return (0)




SET ANSI_NULLS ON
