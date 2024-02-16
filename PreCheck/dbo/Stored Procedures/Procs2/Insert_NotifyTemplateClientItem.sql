-- =============================================
-- Author:		Prasanna Kumari
-- Create date: 01/26/2017
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE Insert_NotifyTemplateClientItem
	-- Add the parameters for the stored procedure here
	@CLNO int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here



---1 PreAdverse template for Tenet
INSERT INTO [dbo].[NotifyTemplateClientItem]
VALUES
(@CLNO,5,
'Pursuant to your authorization, we have obtained a consumer background report for employment purposes.<br/><br/>The link below provides you with secure access to a copy of your background check report, along with a document entitled “A Summary of Your Rights under the Fair Credit Reporting Act.”<br/><br/>If you are resident of or are applying for a position in any of the following locations, please select and review any of the applicable notices:<br/><br/><a href="https://weborder.precheck.net/ClientAccess/Resources/Article_23-A_of_the_NY_Correction_Law.pdf">New York - Article 23-A of the New York Correction Law</a> <br/><a href="https://weborder.precheck.net/ClientAccess/Resources/27542165_1_State_of_NewJersey_FCRA_Summary_of_Consumer_Rights.pdf"> New Jersey - A Summary of Your Rights Under New Jersey Law</a> <br/><a href="https://weborder.precheck.net/ClientAccess/Resources/27493073_1_New_Washington_State_FCRA_Disclosure.pdf"> Washington - A Summary of Your Rights Under Washington Law</a> <br/><a href="https://weborder.precheck.net/ClientAccess/Resources/cori-process-correcting-criminal-record.pdf"> Massachusetts - Information Concerning the Process for Correcting a Criminal Record in Massachusetts</a> <br/><br/><br/>Based in whole or in part upon information contained in the background report, we are considering taking adverse action.  Depending on the circumstances, adverse action could involve not offering you the position (including withdrawal of any conditional offer of employment), termination of your employment, or some other action.  If adverse action is taken based in whole or in part on information contained in the background report, you will receive additional information in a separate letter.<br/><br/>To dispute the accuracy of the background report, you may contact the consumer reporting agency that supplied us with the background report:<br/><br/> <div align = "center">PreCheck, Inc.<br/>3453 Las Palomas Road <br/>Alamogordo, NM 88310<br/>800-203-1654</div><br/><br/>You may also contact us at (469)893-2668 or by email at TenetHRServices@tenethealth.com  if you would like to provide additional information or alert us of your dispute to the accuracy of the background report.'
,'sa',GETDATE(),'sa',GETDATE())

---2 
INSERT INTO [dbo].[NotifyTemplateClientItem]       
VALUES
(@CLNO
,16
,'HR Services<br/>TenetHealthCare'
,'sa'
,GETDATE()
,'sa'
,GETDATE()
)

---3 
INSERT INTO [dbo].[NotifyTemplateClientItem]         
VALUES
(@CLNO
,18
,''
,'sa'
,GETDATE()
,'sa'
,GETDATE()
)

---4 
INSERT INTO [dbo].[NotifyTemplateClientItem]         
VALUES
(@CLNO
,25
,'As you know, Tenet HealthCare conducts routine background checks for employment purposes.  As part of that process and with your authorization, we obtained a consumer report on you.  Based in whole or in part on information contained in that consumer report, we have denied your application for employment, are not promoting you, are terminating your employment, or are withdrawing your conditional offer of employment.<br/><br/>The agency that furnished us with the consumer report is:'
,'sa'
,GETDATE()
,'sa'
,GETDATE()
)

---5
INSERT INTO [dbo].[NotifyTemplateClientItem]          
VALUES
(@CLNO
,27
,'PreCheck, Inc.<br/>3453 Las Palomas Road<br/>Alamogordo, NM 88310<br/>800-203-1654'
,'sa'
,GETDATE()
,'sa'
,GETDATE()
)

---6		  
INSERT INTO [dbo].[NotifyTemplateClientItem]
VALUES
(@CLNO
,29
,'PreCheck, Inc., did not make the decision to take the adverse action and is unable to provide you with the specific reasons as to why the adverse action was taken. You have the right to dispute the accuracy of any information PreCheck has furnished, and you have the opportunity to correct any problems with PreCheck.  You also have the right to an additional free consumer report from PreCheck if requested within 60 days.'
,'sa'
,GETDATE()
,'sa'
,GETDATE()
)


---777 
 INSERT INTO [dbo].[NotifyTemplateClientItem]
VALUES
(@CLNO
,36
,'Sincerely,<br/><br/>HR Services<br/>TenetHealthCare'
,'sa'
,GETDATE()
,'sa'
,GETDATE()
)

---8
 INSERT INTO [dbo].[NotifyTemplateClientItem]        
VALUES
(@CLNO
,38
,''
,'sa'
,GETDATE()
,'sa'
,GETDATE()
)

END

