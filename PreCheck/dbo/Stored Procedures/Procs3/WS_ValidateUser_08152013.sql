

-- =============================================
-- Name:		Ddegenaro
-- Create date: 1/3/2011
-- Description:	Returns 0 or 1 based on if a user is correctly authenticated by clno and pass 
-- =============================================
CREATE Procedure [dbo].[WS_ValidateUser_08152013]
(
	@clno varchar(10),
	@inputPassword varchar(50)	
)
as
BEGIN
declare @clnoCount int
declare @dbPassword varchar(50)
declare @foundPos int
declare @foundStatus bit

SET NOCOUNT ON;

set @foundStatus = 0

set @clnoCount = (select count(clno) from client with (nolock) where clno = @clno and not password is null)
if (@clnoCount = 0)
	set @foundStatus = 0
else
	Begin
		set @dbPassword = (Select top 1 IsNull(password,'') from client with (nolock) where Lower(clno) = @clno)
		if (@dbPassword <> '')
			set @foundPos =  Patindex(@inputPassword,@dbPassword)
			if (@foundPos <> 0)
				set @foundStatus = 1

	End
select @foundStatus			
END