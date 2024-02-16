
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>

--User login setup – 
-- contact should be in client manager  and
-- contact type as “SanctionCheck online only” if the should not be allowed to the clientaccess area.
--Add a record in the Precheck.dbo.ContactRole table for that contactID, with @PC_ApplicationID set to 1 and @RoleID set to one of the following:
--•	1 = access to single search and batch uploading
--•	2 = (admin) – full access, can see all user searches
--•	3 = access to batch uploading only





-- =============================================
CREATE PROCEDURE  [dbo].[NHDBWeb_CreateLogin]
	@Username varchar(50),
@Password varchar(50), 
@CLNO int , 
@PC_ApplicationID int,
@RoleID int

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

   Declare @ContactID as int


SELECT   @ContactID = ContactID--*--, CLNO AS Expr1, username AS Expr2, UserPassword AS Expr3
FROM         dbo.ClientContacts
WHERE     username = @Username and UserPassword = @Password and CLNO = @CLNO

if(@ContactID is not null)
Begin
	SELECT   *--@ContactID = ContactID--*--, CLNO AS Expr1, username AS Expr2, UserPassword AS Expr3
FROM         dbo.ClientContacts
where ContactID = @ContactID

	if(select count(*) from dbo.ContactRole	  where ContactID =@ContactID)>0
		begin
			select *
			FROM         dbo.ContactRole where ContactID =@ContactID
		end
		else
			begin	
					insert into ContactRole
					(ContactID ,
					PC_ApplicationID,
					RoleID,
					CreatedDate )
					values
					(@ContactID,
					@PC_ApplicationID,
					@RoleID,
					getdate())
			end
		

End

END

