-- =============================================
-- Author:		Radhika Dereddy
-- Created Date: 09/27/2017
-- Description:	Add security privileges to the check status on Adverse Action of an Apno
-- EXEC [ClientAccess_AdverseAction] 3807183, '6151',12444,'cbingham'
-- =============================================
CREATE PROCEDURE [dbo].[ClientAccess_AdverseAction_test]
	@Apno int,
	@SSN Varchar(20),
	@CLNO int,
	@Username varchar(14)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

DECLARE @ClientUserID int
DECLARE @ConfigKey varchar(10)
DECLARE @Status varchar(1)
DECLARE @ApnoExistsWithPrivilege int
DECLARE @ApnoExistsWithCLNO int
DECLARE @ApnoInApplwithPrivilege int
DECLARE @ApnoInApplWithCLNO int

SET @Status = (SELECT ApStatus FROM Appl WHERE Apno = @Apno)	

SET @ClientUserID = (SELECT CONTACTID FROM [dbo].[ClientContacts] WHERE CLNO = @CLNO AND USERNAME = @Username)	

SET @ConfigKey = (Select ISNULL((SELECT LOWER(VALUE) FROM clientconfiguration WHERE clno = @clno and configurationkey ='ShowSecurityPrivileges'),'false') ) 

SET @ApnoExistsWithPrivilege = (select count(aa.apno) from adverseaction aa 
								left join appl a on aa.apno=a.apno 
								inner join (SELECT clno FROM dbo.Client WHERE Clno = @clno or WebOrderParentCLNO = @clno) c on a.CLNO = c.CLNO 
								where aa.apno=@apno
								and substring(a.ssn,len(rtrim(a.ssn))-3,4)=@ssn
								and a.clno in (SELECT ClientId AS CLNO  FROM [Security].[GetAuthorizedClients] (@ClientUserID))
								)
SET @ApnoExistsWithCLNO = (select count(aa.apno) from adverseaction aa left join appl a on aa.apno=a.apno 
						   where aa.apno=@apno
  						   and substring(a.ssn,len(rtrim(a.ssn))-3,4)=@ssn
						   and a.clno = @CLNO)

SET @ApnoInApplWithPrivilege= ( select count(apno) from appl a
								 inner join (SELECT clno FROM dbo.Client WHERE Clno = @clno or WebOrderParentCLNO = @clno) c on a.CLNO = c.CLNO  
								 where a.apno = @apno
  								 and substring(a.ssn,len(rtrim(a.ssn))-3,4)=@ssn
								 and a.clno in (SELECT ClientId AS CLNO  FROM [Security].[GetAuthorizedClients] (@ClientUserID))
							   )
SET @ApnoInApplWithCLNO = ( select count(apno) from appl 
							where apno=@apno
  							and substring(ssn,len(rtrim(ssn))-3,4)=@ssn
							and clno = @CLNO
						  )


	 IF @Status ='F'
		BEGIN
			IF (LOWER(@ConfigKey) ='true')
				BEGIN
					IF(@ApnoExistsWithPrivilege != 0)
						BEGIN
							SELECT aa.name, aa.StatusID, rs.Status
							FROM Adverseaction aa 
							left join Appl a on aa.apno=a.apno 
							inner join (SELECT clno FROM dbo.Client WHERE Clno = @clno or WebOrderParentCLNO = @clno) c on a.CLNO = c.CLNO 
							inner join refAdverseStatus rs on aa.StatusID = rs.refAdverseStatusID   
							WHERE a.apno = @Apno 
  							and substring(a.ssn,len(rtrim(a.ssn))-3,4)= @SSN
							and a.clno in (SELECT ClientId AS CLNO  FROM [Security].[GetAuthorizedClients] (@ClientUserID))
						END
					ElSE
						BEGIN
							   IF @ApnoInApplWithPrivilege != 0
									SELECT a.[First] + ' ' + isnull(a.Middle,'') + ' ' + isnull(a.[Last],'') as 'name', 0 as StatusID, 'NoStatus' as 'Status' from Appl a where Apno = @apno
							   ELSE
									SELECT '' as name, '' as StatusID, '' as Status
						END
				END
			ELSE
				BEGIN
					IF(@ApnoExistsWithCLNO != 0)
						BEGIN
							SELECT aa.name, aa.StatusID, rs.Status
							FROM Adverseaction aa left join Appl a on aa.apno=a.apno    
							inner join refAdverseStatus rs on aa.StatusID = rs.refAdverseStatusID   
							WHERE a.apno=@Apno 
  							and substring(a.ssn,len(rtrim(a.ssn))-3,4)=@SSN
							and a.clno = @CLNO
						END
					ELSE
						BEGIN
							  IF @ApnoInApplWithCLNO != 0
									SELECT a.[First] + ' ' + isnull(a.Middle,'') + ' ' + isnull(a.[Last],'') as 'name', 0 as StatusID, 'NoStatus' as 'Status' from Appl a where Apno=@apno
							   ELSE
									SELECT '' as name, '' as StatusID, '' as Status
						END
				END
		END
     ELSE
		BEGIN
			SELECT 'NotFinaled' as name, -1 as StatusID, 'NoStatus' as Status			
		END
END