

CREATE PROCEDURE [dbo].[Integration_OrderMgmt_login_verify]
	@username	varchar(50),
	@password	varchar(50) = null,
	@clientid	int,
	@Request  varchar(max),
	@IsAutoLogin bit = 0,
	@RequestID int = null,
	@IsTransformed bit = null
AS
--DECLARE @RequestID int

/* Modified Date:  06/18/2008
   Modifications: To return client configurations and 
				  to add a join between client and client configurations
   Modified by: SRai
*/
/* Modified Date:  12/08/2008
   Modifications: To return MergeAppReleaseKeyValue,WO_Merge_ApplClientData,AdjudicationProcess for US Oncology
   Modified by: Kiran Miryala
*/
IF @IsAutoLogin = 0
BEGIN	
		if (SELECT count(1)
			FROM dbo.clientcontacts a 
			INNER JOIN  dbo.client b ON a.clno = b.clno
			WHERE ( ( ltrim(rtrim(a.username)) = @username) AND ( ltrim(rtrim(a.UserPassword)) = @password) 
				AND (a.CLNO = @clientid)  --and b.clno = @clientid	
				and b.billingstatusid = 1
				and WOLockout <=3) )= 0 
				BEGIN
					Insert into Integration_OrderMgmt_Login_FailureActivityLog
					Select @username,@clientid,IsNull(@password,''),getDate()

					raiserror('Error logging in. Please cross check your logon credentials and try again',16,1)
					Return 0		
				END
		
END

if (@RequestID is null)
BEGIN
Insert into dbo.Integration_OrderMgmt_Request (CLNO,UserName,Request)
Select @clientid,@username,@Request

Select @RequestID = SCOPE_IDENTITY() 
END

if (@IsTransformed is null)
	Select @RequestID RequestID,  XSLTFileData,XSLTNameSpace,URL_CallBack_Acknowledge,CallBackMethod,IsNull(Config.OperationName,'') as OperationName
	From  dbo.XLATECLNO Client left join dbo.XSLFileCache XSLFile on isnull(Client.CLNO_XSLT,0) =  XSLFile.CLNO
	left join dbo.ClientConfig_Integration Config on isnull(Client.CLNOin,0) = Config.CLNO and IntegrationMethod = 'OrderMgmt'
	Where Client.CLNOin = @clientid
ELSE
	Select @RequestID RequestID,  null as XSLTFileData,null as XSLTNameSpace,URL_CallBack_Acknowledge,CallBackMethod,IsNull(Config.OperationName,'') as OperationName
	From  dbo.ClientConfig_Integration Config 
	Where CLNO = @clientid and IntegrationMethod = 'OrderMgmt'




