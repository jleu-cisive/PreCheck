-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[pc_update_ClientContact]
	@ContactID		int,
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
Update ClientContacts
Set FirstName = @FirstName,
LastName = @LastName,
MiddleName = @MiddleName,
Phone = @Phone,
Ext = @Ext,
Email = @Email,
username = @username,
UserPassword = @UserPassword,
IsActive = @IsActive,
ClientRoleID = @ClientRoleID
WHERE ContactID = @ContactID AND CLNO = @clientid

return (0)


SET ANSI_NULLS ON
