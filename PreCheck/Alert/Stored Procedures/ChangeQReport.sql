-- =============================================
-- Author:		Gaurav Bangia
-- Create date: 05/24/2017
-- Description:	<Description,,>
-- Updated By:  Suchitra Yellapantula
-- Update:      Updated the CCEMail field with the list of email addresses of all the users mapped to the updated reports 
-- =============================================
CREATE PROCEDURE [Alert].[ChangeQReport]
	-- Add the parameters for the stored procedure here
	
AS
BEGIN
	
	SET NOCOUNT ON;
	DECLARE @lastRunTime DATETIME 
	--SET @lastRunTime = DATEADD(MINUTE,-2,ISNULL(NotificationHub.dbo.GetSourceLastExecutionTime(53), DATEADD(DAY,-1,GETDATE())))
	SET @lastRunTime = '6/6/2017'

 SELECT 
		ReportName=QueryDesc,
		[Description] = ReportDescription,
		ModifiedDate = ModifyDate,
		Requestor=LastChangeRequestor,
		ITExecutor=ModifyBy,
		Reason=LastChangeReason,
		Email = ISNULL(dbo.ListCSVQReportUserEmail(Q.qreportid),'ApplicationMonitoring_IT@precheck.com'),
		CCEmail= 'ApplicationMonitoring_IT@precheck.com'		
	FROM dbo.QReport Q
	WHERE DATEDIFF(MINUTE, ISNULL(Q.MODIFYDATE,'1/1/2016'), GETDATE()) BETWEEN 0 AND 60
	
END
