-- =============================================
-- Author:		Gaurav Bangia
-- Create date: 06/02/2017
-- Description:	Insert Facility Privilege 
-- =============================================
CREATE PROCEDURE Tool.InsFacilityPrivilege
	-- Add the parameters for the stored procedure here
	@Email VARCHAR(500), -- Email address of the user how it should be in the client contacts-- it is a requirement to start with
	@parentClno INT, -- This is the parent account and would be used to find the client contact with the email address provided above and the clno
	@FACILITIES  VARCHAR(MAX)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	

/* VARIABLE DECLARATION */

DECLARE @principalId INT
DECLARE @FACILIYTABLE TABLE(FACILITYCLNO INT)
DECLARE @principalTypeid INT
DECLARE @resourceTypeId INT



/*
SET @email='est.marshallmoultrie@tenethealth.com' -- Email address of the user how it should be in the client contacts-- it is a requirement to start with
SET @parentClno=12444 -- This is the parent account and would be used to find the client contact with the email address provided above and the clno
SET @FACILITIES='12738,12741' -- Facilities that the user needs access to-- if super user then only ParentId is required, like '12444' for all Tenet facilities.
*/

DECLARE @SuperUser BIT
SET @SuperUser=0

IF(CONVERT(VARCHAR(MAX),@parentClno)=@FACILITIES)
	SET @SuperUser=1

PRINT @SuperUser
-- Automated Script Area -- 
/***********************Nothing needs to be changed/set here unless neeeded*********************************************/
--SELECT * FROM dbo.ClientContacts WHERE  Email=@email

INSERT INTO @FACILIYTABLE( FACILITYCLNO )
SELECT Item FROM [PreCheck].dbo.Split(',', @FACILITIES)

SET @principalId=(SELECT contactid FROM [PreCheck].dbo.ClientContacts WHERE clno=@parentClno AND Email=@email)
SET @principalTypeid=1
SET @resourceTypeId=2

PRINT @principalId
/*Access setup*/
IF(@principalId IS NOT NULL)
BEGIN

	DECLARE @NEWPRIVILEGES TABLE(PrincipalTypeId int, PrincipalId int, ResourceTypeId int, ResourceId int, IsActive bit)
									INSERT INTO @NEWPRIVILEGES
SELECT 
	@principalTypeid, @principalId,@resourceTypeId,	FacilityId = Convert(INT, FACILITYCLNO) ,1 
	FROM @FACILIYTABLE T INNER JOIN [PreCheck].dbo.Client C
		ON T.FACILITYCLNO=C.CLNO
	WHERE 
	ISNULL(C.WebOrderParentCLNO,0) = CASE  WHEN (@SuperUser=0) THEN  @parentClno ELSE 0 end	 
	AND 
	t.FACILITYCLNO NOT IN (SELECT resourceid FROM [PreCheck].[Security].Privilege WHERE PrincipalId=@principalId)

	--SELECT * FROM @NEWPRIVILEGES
	IF((SELECT COUNT(*) FROM @NEWPRIVILEGES)>0)
	BEGIN
		INSERT INTO [PreCheck].Security.Privilege( PrincipalTypeId , PrincipalId ,ResourceTypeId ,ResourceId ,IsActive )
		SELECT PrincipalTypeId , PrincipalId ,ResourceTypeId ,ResourceId ,IsActive FROM @NEWPRIVILEGES

		SELECT * FROM [PreCheck].dbo.vwClientPrivilege WHERE UserId=@principalId
	end
	ELSE
	BEGIN
		PRINT 'No privilege inserted. Either privilege already exists, or invalid facility number'
	END
END
ELSE
BEGIN
	PRINT 'USER DOES NOT EXIST'
END



END
