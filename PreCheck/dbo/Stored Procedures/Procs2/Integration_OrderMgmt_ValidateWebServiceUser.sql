
CREATE Procedure [dbo].[Integration_OrderMgmt_ValidateWebServiceUser]
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

set @foundStatus = 0

set @clnoCount = (select count(clno) from client where clno = @clno and not password is null)
if (@clnoCount = 0)
	set @foundStatus = 0
else
	Begin
		set @dbPassword = (Select top 1 IsNull(password,'') from client where Lower(clno) = @clno)
		if (@dbPassword <> '')
			set @foundPos =  Patindex(@inputPassword,@dbPassword)
			if (@foundPos <> 0)
				set @foundStatus = 1

	End
select @foundStatus			
END
