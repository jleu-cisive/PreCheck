

CREATE PROCEDURE [dbo].[ClientAccess_AppDetail_StatusSummary] @apno int,
@AdjudicationProcess bit = 0,
@clno int = 0 
AS

--SET @clno = 0

SET NOCOUNT ON

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

--[ClientAccess_AppDetail_StatusSummary] 2284157 ,1,8987

--Insert into ClientAccess_TMPLog
--Select @AdjudicationProcess,@clno,@apno

--IF (select count(1) from clientconfiguration where configurationkey ='AdjudicationProcess' and value = 'True' and CLNO = @clno) = 0 
--	SET @AdjudicationProcess = 0
--else
--	SET @AdjudicationProcess = 1

IF @AdjudicationProcess = 0
	Select onlinedescription [Status],sum(cnt) StatusCount FROM
	(
	SELECT --'Empl' Section,	
	sectstat.onlinedescription, count(1) cnt
	FROM DBO.Empl INNER JOIN DBO.SECTSTAT ON empl.sectstat = sectstat.code 				 
	WHERE isonreport = 1 and ishidden = 0 and Empl.apno = @apno
	Group by onlinedescription

	UNION ALL

	SELECT --'educat' Section, 
	sectstat.onlinedescription , count(1) cnt
	FROM DBO.educat INNER JOIN DBO.sectstat on educat.sectstat = sectstat.code 					
	WHERE isonreport = 1 and ishidden = 0 and educat.apno =  @apno
	Group by onlinedescription

	UNION ALL

	SELECT --'MVR' Section, 
		sectstat.onlinedescription , count(1) cnt
	FROM DBO.DL INNER JOIN DBO.sectstat on DL.sectstat = sectstat.code 
	where ishidden = 0 and DL.apno = @apno
	Group by onlinedescription

	UNION ALL


	SELECT --'persref' Section, 
	sectstat.onlinedescription , count(1) cnt
	FROM DBO.persref INNER JOIN DBO.SECTSTAT ON persref.sectstat = sectstat.code 
	where isonreport = 1 and ishidden = 0 and persref.apno = @apno
	Group by onlinedescription

	UNION ALL
	SELECT --'proflic' Section, 
	sectstat.onlinedescription , count(1) cnt
	FROM DBO.proflic INNER JOIN DBO.sectstat on proflic.sectstat = sectstat.code 
	where isonreport = 1  and ishidden = 0 and proflic.apno = @apno
	Group by onlinedescription

	UNION ALL

	SELECT --'SanctionCheck' Section, 
	sectstat.onlinedescription , count(1) cnt
	FROM DBO.medinteg INNER JOIN DBO.sectstat on medinteg.sectstat = sectstat.code
	where ishidden = 0 and medinteg.apno =  @apno
	Group by onlinedescription

	UNION ALL

	SELECT --'credit' Section, 
	sectstat.onlinedescription , count(1) cnt
	FROM  DBO.credit INNER JOIN DBO.sectstat on sectstat.code = credit.sectstat
	where credit.apno = @apno
	Group by onlinedescription

	UNION ALL

	SELECT --'Civil' Section, 
			crimsectstat.crimdescription as onlinedescription, count(1) cnt
	FROM DBO.Civil LEFT JOIN DBO.crimsectstat on civil.clear = crimsectstat.crimsect 
	where apno = @apno
	Group by crimdescription
	) QRY
	Group by onlinedescription
ELSE
	Select onlinedescription [Status],sum(cnt) StatusCount FROM
	(
	SELECT --'Empl' Section, 
	IsNull(isnull(custom.DisplayName,AdjStatus.DisplayName),'In Progress') as onlinedescription, count(1) cnt
	FROM DBO.Empl LEFT OUTER JOIN DBO.SECTSTAT ON empl.sectstat = sectstat.code 
				  LEFT JOIN dbo.ClientAdjudicationStatus AdjStatus ON empl.ClientAdjudicationStatus = AdjStatus.ClientAdjudicationStatusID  
				  LEFT JOIN dbo.ClientAdjudicationStatusCustom Custom ON AdjStatus.ClientAdjudicationStatusID = Custom.ClientAdjudicationStatusID and custom.CLNO = @clno
	WHERE isonreport = 1 and ishidden = 0 and Empl.apno = @apno
	Group by (IsNull(isnull(custom.DisplayName,AdjStatus.DisplayName),'In Progress'))

	UNION ALL

	SELECT --'educat' Section, 
	(IsNull(isnull(custom.DisplayName,AdjStatus.DisplayName),'In Progress')) as onlinedescription, count(1) cnt
	FROM DBO.educat LEFT JOIN DBO.sectstat on educat.sectstat = sectstat.code 
					LEFT JOIN dbo.ClientAdjudicationStatus AdjStatus ON educat.ClientAdjudicationStatus = AdjStatus.ClientAdjudicationStatusID 
					LEFT JOIN dbo.ClientAdjudicationStatusCustom Custom ON AdjStatus.ClientAdjudicationStatusID = Custom.ClientAdjudicationStatusID and custom.CLNO = @clno
	WHERE isonreport = 1 and ishidden = 0 and educat.apno =  @apno
	Group by (IsNull(isnull(custom.DisplayName,AdjStatus.DisplayName),'In Progress'))

	UNION ALL

	SELECT --'MVR' Section, 
	(IsNull(isnull(custom.DisplayName,AdjStatus.DisplayName),'In Progress')) as onlinedescription , count(1) cnt
	FROM DBO.DL LEFT JOIN DBO.sectstat on DL.sectstat = sectstat.code 
				LEFT JOIN dbo.ClientAdjudicationStatus AdjStatus ON DL.ClientAdjudicationStatus = AdjStatus.ClientAdjudicationStatusID  
				  LEFT JOIN dbo.ClientAdjudicationStatusCustom Custom ON AdjStatus.ClientAdjudicationStatusID = Custom.ClientAdjudicationStatusID and custom.CLNO = @clno
	where ishidden = 0 and DL.apno = @apno
	Group by (IsNull(isnull(custom.DisplayName,AdjStatus.DisplayName),'In Progress'))

	UNION ALL


	SELECT --'persref' Section, 
	(IsNull(isnull(custom.DisplayName,AdjStatus.DisplayName),'In Progress')) as onlinedescription, count(1) cnt
	FROM DBO.persref LEFT JOIN DBO.SECTSTAT ON persref.sectstat = sectstat.code 
					 LEFT JOIN dbo.ClientAdjudicationStatus AdjStatus ON persref.ClientAdjudicationStatus = AdjStatus.ClientAdjudicationStatusID  
				  LEFT JOIN dbo.ClientAdjudicationStatusCustom Custom ON AdjStatus.ClientAdjudicationStatusID = Custom.ClientAdjudicationStatusID and custom.CLNO = @clno
	where isonreport = 1 and ishidden = 0 and persref.apno = @apno
	Group by (IsNull(isnull(custom.DisplayName,AdjStatus.DisplayName),'In Progress'))

	UNION ALL
	SELECT --'proflic' Section, 
	(IsNull(isnull(custom.DisplayName,AdjStatus.DisplayName),'In Progress')) as onlinedescription , count(1) cnt
	FROM DBO.proflic LEFT JOIN DBO.sectstat on proflic.sectstat = sectstat.code 
					 LEFT JOIN dbo.ClientAdjudicationStatus AdjStatus ON proflic.ClientAdjudicationStatus = AdjStatus.ClientAdjudicationStatusID  
				  LEFT JOIN dbo.ClientAdjudicationStatusCustom Custom ON AdjStatus.ClientAdjudicationStatusID = Custom.ClientAdjudicationStatusID and custom.CLNO = @clno
	where isonreport = 1  and ishidden = 0 and proflic.apno = @apno
	Group by (IsNull(isnull(custom.DisplayName,AdjStatus.DisplayName),'In Progress'))

	UNION ALL

	SELECT --'SanctionCheck' Section, 
	(IsNull(isnull(custom.DisplayName,AdjStatus.DisplayName),'In Progress')) as onlinedescription , count(1) cnt
	FROM DBO.medinteg LEFT JOIN DBO.sectstat on medinteg.sectstat = sectstat.code
					  LEFT JOIN dbo.ClientAdjudicationStatus AdjStatus ON medinteg.ClientAdjudicationStatus = AdjStatus.ClientAdjudicationStatusID 
				  LEFT JOIN dbo.ClientAdjudicationStatusCustom Custom ON AdjStatus.ClientAdjudicationStatusID = Custom.ClientAdjudicationStatusID and custom.CLNO = @clno
	where ishidden = 0 and medinteg.apno =  @apno
	Group by (IsNull(isnull(custom.DisplayName,AdjStatus.DisplayName),'In Progress'))

	UNION ALL

	SELECT --'credit' Section, 
	(IsNull(isnull(custom.DisplayName,AdjStatus.DisplayName),'In Progress')) as onlinedescription , count(1) cnt
	FROM  DBO.credit LEFT JOIN DBO.sectstat on sectstat.code = credit.sectstat
					 LEFT JOIN dbo.ClientAdjudicationStatus AdjStatus ON credit.ClientAdjudicationStatus = AdjStatus.ClientAdjudicationStatusID   
				  LEFT JOIN dbo.ClientAdjudicationStatusCustom Custom ON AdjStatus.ClientAdjudicationStatusID = Custom.ClientAdjudicationStatusID and custom.CLNO = @clno
	where credit.apno = @apno
	Group by (IsNull(isnull(custom.DisplayName,AdjStatus.DisplayName),'In Progress'))

	UNION ALL

	SELECT --'Civil' Section, 
			crimsectstat.crimdescription as onlinedescription, count(1) cnt
	FROM DBO.Civil LEFT JOIN DBO.crimsectstat on civil.clear = crimsectstat.crimsect 
	where apno = @apno
	Group by crimdescription
	) QRY
	Group by onlinedescription
