

CREATE PROCEDURE [dbo].[sp_login_verify]
	@username	varchar(50),
	@password	varchar(50),
	@clientid	int
AS
/* Modified Date:  06/18/2008
   Modifications: To return client configurations and 
				  to add a join between client and client configurations
   Modified by: SRai
*/
/* Modified Date:  12/08/2008
   Modifications: To return MergeAppReleaseKeyValue,WO_Merge_ApplClientData,AdjudicationProcess for US Oncology
   Modified by: Kiran Miryala


*/



if ((SELECT count(*)  FROM Precheck.dbo.clientcontacts a INNER JOIN  Precheck.dbo.client b ON a.clno = b.clno
WHERE ( ( ltrim(rtrim(a.username)) = @username) AND ( ltrim(rtrim(a.UserPassword)) = @password) 
	AND (a.CLNO = @clientid)  	and isnull(a.IsActive,0) = 1 	and b.billingstatusid = 1	and WOLockout <=3) )>0)
Begin
INSERT INTO [Precheck].[dbo].[ClientAccess_Login_Audit]
           ([username]
           --,[password]
           ,[clientid]
           ,[LogDate]
           ,[LogInSuccess]
			,[ClientType])

    SELECT @username
           --@password
           ,@clientid
           ,GETDATE()
           ,1
			,ClientTypeID FROM Precheck.dbo.Client where clno = @clientid 
End
else
Begin
INSERT INTO [Precheck].[dbo].[ClientAccess_Login_Audit]
           ([username]
           ,[password]
           ,[clientid]
           ,[LogDate]
           ,[LogInSuccess]
           ,[ClientType])
     SELECT  @username,
           @password
           ,@clientid
           ,GETDATE()
           ,0
,ClientTypeID FROM Precheck.dbo.Client where clno = @clientid 
End


SELECT a.*,b.ClientTypeID,
(SELECT LOWER(VALUE) FROM Precheck..clientconfiguration WHERE clno = @clientid 
and configurationkey='WO_Merge_ClientRequiresMergedReports') as 'MergeConfigurationKeyValue',
 (SELECT LOWER(VALUE) FROM Precheck..clientconfiguration WHERE clno = @clientid 
and configurationkey='WO_Merge_DrugScreeningRequired') as 'IsDrugScreeningRequired',
ISNULL((SELECT LOWER(VALUE) FROM Precheck..clientconfiguration WHERE clno = @clientid and configurationkey='WO_DisplayFindings'),'false') as DisplayFindings,
ISNULL((SELECT LOWER(VALUE) FROM Precheck..clientconfiguration WHERE clno = @clientid and configurationkey='ShowStatusIcons'),'display') as ShowStatusIcons,
ISNULL((SELECT LOWER(VALUE) FROM Precheck..clientconfiguration WHERE clno = @clientid and configurationkey='UseOldClientAccess'),'false') as UseOldClientAccess,
ISNULL((Select DisplayPendingOrderMgmt from Precheck..ClientConfig where CLNO=@clientid),0) AS DisplayPendingOrderMgmt,
ISNULL((Select DisplayAdverseAction from Precheck..ClientConfig where CLNO=@clientid),0) AS DisplayAdverseAction,
(SELECT LOWER(VALUE) FROM Precheck..clientconfiguration WHERE clno = @clientid 
and configurationkey='WO_Merge_APP+Release') as 'MergeAppReleaseKeyValue',
(SELECT LOWER(VALUE) FROM Precheck..clientconfiguration WHERE clno = @clientid 
and configurationkey='WO_Merge_ApplClientData') as 'Merge_ApplClientData',
(SELECT LOWER(VALUE) FROM Precheck..clientconfiguration WHERE clno = @clientid 
and configurationkey='AdjudicationProcess') as 'AdjudicationProcess',
(SELECT VALUE FROM Precheck..clientconfiguration WHERE clno = @clientid 
and configurationkey='Adjudication_SectionReq') as 'Adjudication_SectionReq',
(SELECT VALUE FROM Precheck..clientconfiguration WHERE clno = @clientid 
and configurationkey='Redirect_Nevada') as 'Redirect_Nevada',
(SELECT LOWER(VALUE) FROM Precheck..clientconfiguration WHERE clno = @clientid 
and configurationkey='WO_Merge_CredentialCertificate') as 'Merge_CredentialCertificate',
(SELECT LOWER(VALUE) FROM Precheck..clientconfiguration WHERE clno = @clientid 
and configurationkey='ExportSSNDOB') as 'ExportSSNDOB'

FROM Precheck.dbo.clientcontacts a 
INNER JOIN  Precheck.dbo.client b ON a.clno = b.clno

WHERE ( ( ltrim(rtrim(a.username)) = @username) AND ( ltrim(rtrim(a.UserPassword)) = @password) 
	AND (a.CLNO = @clientid)  --and b.clno = @clientid	
	and isnull(a.IsActive,0) = 1  --added by Schapyala on 05/24/11 -- please cross check
	and b.billingstatusid = 1
	and WOLockout <=3)














