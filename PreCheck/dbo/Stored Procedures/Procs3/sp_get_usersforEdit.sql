


-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[sp_get_usersforEdit]
 @CLNO	int,
 @Phone nvarchar(30),
 @First	nvarchar(50),
 @Last nvarchar(50),
 @isActive int	
AS

IF (@isActive <> 0) 
BEGIN
 Select ContactID,FirstName,LastName,Phone,Email,ContactType,IsActive
From ClientContacts
where 
CLNO = @CLNO 
AND 
( FirstName = @First OR @First = '' )
AND 
(LastName =@Last OR	@Last = '')
AND
( Phone = @Phone	OR	@Phone = '')
AND 
(
IsActive=
CASE @isActive
	WHEN 1 Then
		1
	WHEN 2 Then 
		0
END
)
END
ELSE

 Select ContactID,FirstName,LastName,Phone,Email,ContactType,IsActive
From ClientContacts
where 
CLNO = @CLNO 
AND 
( FirstName = @First OR @First = '' )
AND 
(LastName =@Last OR	@Last = '')
AND
( Phone = @Phone	OR	@Phone = '')


SET ANSI_NULLS ON
