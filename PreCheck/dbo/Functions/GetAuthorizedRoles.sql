-- =============================================
-- Author:		Radhika Dereddy
-- Create date: 08/10/2020
-- Description:	Function returns concatenating all the RoleId's for a client user
-- SELECT [dbo].[GetAuthorizedRoles](73882)
-- SELECT [dbo].[GetAuthorizedRoles](74105)
-- =============================================
CREATE FUNCTION [dbo].[GetAuthorizedRoles]
(
	-- Add the parameters for the function here
	@contactId int
)
RETURNS varchar(max)
AS
BEGIN


DECLARE @RoleAccess varchar(max)

Select @RoleAccess = COALESCE(@RoleAccess + ',' + cast(RoleID as VARCHAR(max)), cast(RoleID as VARCHAR(max)))
FROM [dbo].[vwClientContact] 
WHERE UserId = @contactId 

	-- Return the result of the function
RETURN @RoleAccess

END
