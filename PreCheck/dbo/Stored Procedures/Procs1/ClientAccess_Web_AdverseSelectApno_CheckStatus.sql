-- =============================================
-- Moified By:		Radhika Dereddy
-- Modified Date: 12/07/2016
-- Description:	Add security privileges to the check status on Adverse Action of an Apno
-- =============================================
CREATE PROCEDURE [dbo].[ClientAccess_Web_AdverseSelectApno_CheckStatus]
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
DECLARE @countPrivilege  int
DECLARE @countPrivilege1 int
DECLARE @count  int
DECLARE @count1 int


SET @ClientUserID = (SELECT CONTACTID FROM [dbo].[ClientContacts] WHERE CLNO = @CLNO AND USERNAME = @Username)	

SET @ConfigKey = (Select ISNULL((SELECT LOWER(VALUE) FROM clientconfiguration WHERE clno = @clno and configurationkey ='ShowSecurityPrivileges'),'false') ) -- Commented Commented by Radhika Dereddy for ConfigKey 'ShowTenet'


SET @countPrivilege = ( select count(aa.apno) from adverseaction aa 
						left join appl a on aa.apno=a.apno 
						inner join (SELECT clno FROM dbo.Client WHERE Clno = @clno or WebOrderParentCLNO = @clno) c on a.CLNO = c.CLNO 
						where aa.apno=@apno
						and substring(a.ssn,len(rtrim(a.ssn))-3,4)=@ssn
						and a.clno in (SELECT ClientId AS CLNO  FROM [Security].[GetAuthorizedClients] (@ClientUserID))
					  )

SET @countPrivilege1 = ( select count(apno) from appl a
						 inner join (SELECT clno FROM dbo.Client WHERE Clno = @clno or WebOrderParentCLNO = @clno) c on a.CLNO = c.CLNO  
						 where a.apno = @apno
  						 and substring(a.ssn,len(rtrim(a.ssn))-3,4)=@ssn
						 and a.clno in (SELECT ClientId AS CLNO  FROM [Security].[GetAuthorizedClients] (@ClientUserID))
					   )

SET @count = ( select count(aa.apno) from adverseaction aa left join appl a on aa.apno=a.apno 
			   where aa.apno=@apno
  			   and substring(a.ssn,len(rtrim(a.ssn))-3,4)=@ssn
			   and a.clno = @CLNO
			 )

SET @count1 = ( select count(apno) from appl 
			    where apno=@apno
  			    and substring(ssn,len(rtrim(ssn))-3,4)=@ssn
			    and clno = @CLNO
			  )


IF(LOWER(@ConfigKey) = 'true')
		BEGIN			  
				IF @countPrivilege != 0
						BEGIN
							SELECT aa.name 
							FROM Adverseaction aa 
							left join Appl a on aa.apno=a.apno 
							inner join (SELECT clno FROM dbo.Client WHERE Clno = @clno or WebOrderParentCLNO = @clno) c on a.CLNO = c.CLNO    
							WHERE a.apno = @Apno 
  							and substring(a.ssn,len(rtrim(a.ssn))-3,4)= @SSN
							and a.clno in (SELECT ClientId AS CLNO  FROM [Security].[GetAuthorizedClients] (@ClientUserID))
						END
				ELSE
						BEGIN
							   IF @countPrivilege1 != 0
									SELECT 'NoRecords' as name
							   ELSE
									SELECT '' as name
						END

				
		END
ELSE
		BEGIN
				IF @count != 0
					BEGIN
						SELECT aa.name 
						FROM Adverseaction aa left join Appl a on aa.apno=a.apno    
						WHERE a.apno=@Apno 
  						and substring(a.ssn,len(rtrim(a.ssn))-3,4)=@SSN
						and a.clno = @CLNO
					END
				ELSE
					BEGIN
						   IF @count1 != 0
								select 'NoRecords' as name
						   ELSE
								select '' as name
					END

		END
END

