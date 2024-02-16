-- =============================================
-- Author:		Radhika Dereddy	
-- Create date: 12/07/2016
-- Description:	Add security privileges to the Adverse Action Status History
-- Modified by Radhika Dereddy on 12/28/2017
-- =============================================
CREATE PROCEDURE [dbo].[ClientAccess_Web_AdverseStatusHistory_SecurityPrivilege]
	-- Add the parameters for the stored procedure here
	@apno int,
	@ssn  varchar(11)=null,
	@CLNO int,
	@Username varchar(14)
AS
BEGIN

DECLARE @ErrorCode int
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

DECLARE @ClientUserID int
DECLARE @ConfigKey varchar(10)

SET @ClientUserID = (SELECT CONTACTID FROM [dbo].[ClientContacts] WHERE CLNO = @CLNO AND USERNAME = @Username)	

SET @ConfigKey = (Select ISNULL((SELECT LOWER(VALUE) FROM clientconfiguration WHERE clno = @clno and configurationkey ='ShowSecurityPrivileges'),'false') ) -- Commented by Radhika Dereddy for ConfigKey 'ShowTenet'
   
   
IF(LOWER(@ConfigKey) = 'true')
		BEGIN    
				SELECT Top(1) refas.Status, aah.[Date] 
				FROM Appl a
				INNER JOIN AdverseAction aa  ON a.apno=aa.apno
				INNER JOIN AdverseActionHistory aah ON aa.adverseactionid=aah.AdverseActionID
				INNER JOIN refAdverseStatus refas ON  aah.StatusID=refas.refAdverseStatusID AND refas.statusGroup = 'AdverseAction'
				WHERE aa.apno = @apno 
				OR substring(a.ssn,len(rtrim(a.ssn))-3,4) = @ssn
				and a.clno in (SELECT ClientId AS CLNO  FROM [Security].[GetAuthorizedClients] (@ClientUserID))
				ORDER BY aah.[date] DESC
		END
ELSE
		BEGIN
				SELECT TOP (1) refas.Status, aah.[Date] 
				FROM Appl a
				INNER JOIN AdverseAction aa  ON a.apno=aa.apno
				INNER JOIN AdverseActionHistory aah ON aa.adverseactionid=aah.AdverseActionID
				INNER JOIN refAdverseStatus refas ON  aah.StatusID=refas.refAdverseStatusID AND refas.statusGroup = 'AdverseAction'
				WHERE a.apno = @apno 
				OR substring(a.ssn,len(rtrim(a.ssn))-3,4)= @ssn 
				and a.CLNO in (SELECT clno FROM dbo.Client WHERE Clno = @clno or WebOrderParentCLNO = @clno)
				ORDER BY aah.[date] DESC
		END

END
