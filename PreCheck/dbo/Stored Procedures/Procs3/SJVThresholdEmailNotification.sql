-- =============================================
-- Author:		Deepak Vodethela
-- Create date: 01/24/2018
-- Description:	SJV Threshold Notification
-- Execution: SJVThresholdEmailNotification '04/18/2019'
-- =============================================
CREATE PROCEDURE [dbo].[SJVThresholdEmailNotification]
	-- Add the parameters for the stored procedure here
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	DECLARE @Date date
	SET @Date = CAST(CURRENT_TIMESTAMP AS DATE)

	DECLARE @IsUnAvailable BIT, 
			@Investigator VARCHAR(10) ='SJV',
			@NotifyEmail VARCHAR(100) = 'EmploymentLeads@precheck.com',
			@NotifyCutoff int
		
	SELECT @IsUnAvailable = CASE WHEN s.IsActive=1 THEN CONVERT(BIT,1) ELSE CONVERT(BIT,0) END 
	FROM dbo.Users as u(NOLOCK)
	LEFT JOIN dbo.UserRolesBySection as s(NOLOCK) on u.UserID = s.UserID 
	WHERE u.empl = 1
	  AND u.UserID = @Investigator  
  
    SELECT @NotifyCutoff = cc.[Value]
	FROM PreCheck.dbo.ClientConfiguration cc(NOLOCK)
	WHERE CC.ConfigurationKey = 'SJV_Threshold'

	SELECT  ApplicantId=Count(1), CandidateName = '', Email=@NotifyEmail, ClientName='', CreateDate=CURRENT_TIMESTAMP, RecruiterEmail='ApplicationMonitoring_IT@precheck.com', 
			HourSinceInitialNotification = 0,MaxDate=CONVERT(VARCHAR(12),CONVERT(DATE,DATEADD(DAY,10,CURRENT_TIMESTAMP)),101),HasBackground=0, HasDrugTest=0, HasImmunization=0  
	FROM PreCheck.dbo.GetNextAudit (NOLOCK)   
	WHERE CAST(updatedate AS DATE) = @date  
	  AND NewValue = @Investigator 
	  AND ISNULL(@IsUnAvailable,0) = 0   
	HAVING COUNT(1) >= @NotifyCutoff

END
