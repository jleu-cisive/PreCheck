-- =============================================
-- Author:		Gaurav Bangia
-- Create date: 6/16/2016
-- Description:	Function returns all authorized client/sub accounts that ClientContactId has permissions for
	-- super user/User at parent account level 
	-- select * from [Security].[GetAuthorizedClients](5570)
	-- sub account 
	-- select * from [Security].[GetAuthorizedClients](53)
	-- select * from [Security].[GetAuthorizedClients](1566)
	--- modified by lalit on 16 November 2022 for #72092
	-- updated by Lalit on 22 November for #73178
-- =============================================
CREATE FUNCTION [Security].[GetAuthorizedClients] 
(
	-- Add the parameters for the function here
	@ClientContactId int 
	
)
RETURNS 
 @ClientPrivilege table
(
	UserId	int,
	UserName varchar(14),
	ClientId int,
	UserEmail VARCHAR(150),
	Client varchar(100),
	[ParentClientId] INT NULL
)
AS
BEGIN

Declare @ClientPrivilegetemp table
(
	UserId	int,
	UserName varchar(14),
	ClientId int,
	UserEmail VARCHAR(150),
	Client varchar(100),
	[ParentClientId] INT NULL
)

DECLARE @PARENTCLIENTID INT
DECLARE @USERNAME VARCHAR(14)
DECLARE @USEREMAIL VARCHAR(150)

SELECT @PARENTCLIENTID=[ClientId],
	   @USERNAME=[UserName],
	   @USEREMAIL=UserEmail
FROM [dbo].[vwClientPrivilege]( NOLOCK )
WHERE UserId=@ClientContactId
	  AND ([ParentClientId] IS NULL or ClientId=ParentClientId)

INSERT INTO @ClientPrivilegetemp
	   SELECT [UserId],
			  [UserName],
			  [ClientId],
			  [UserEmail],
			  [Client],
			  [ParentClientId]
	   FROM [dbo].[vwClientPrivilege]( NOLOCK )
	   WHERE UserId=@ClientContactId

IF (@PARENTCLIENTID IS NOT NULL)
BEGIN
INSERT INTO @ClientPrivilegetemp
(UserId,
 UserName,
 ClientId,
 UserEmail,
 Client,
 [ParentClientId])
	   SELECT @ClientContactId,
			  @USERNAME,
			  C.CLNO,
			  @USEREMAIL,
			  C.Name,
			  C.WebOrderParentCLNO
	   FROM Client C (NOLOCK)
	   WHERE C.WebOrderParentCLNO=@PARENTCLIENTID
END

INSERT INTO @ClientPrivilege
	   SELECT DISTINCT*
	   FROM @ClientPrivilegetemp
RETURN
END

