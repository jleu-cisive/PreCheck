-- =============================================
-- Author:           Humera Ahmed
-- Create date: 08/27/2020
-- Description:      UTSW Applicant Monitoring Report - The report should show the information below for UTSW accounts for any report with a first close during the month prior plus any currently pending report.
-- Modified by Humera Ahmed on 09/29/2020 - Replace comma with a space in Requestor column.
-- Modified by Humera Ahmed on 10/01/2020 - replace the where condition and added 4 new columns.
-- EXEC ApplicantMonitoringReport_ScheduledReport 16192
-- =============================================
CREATE PROCEDURE [dbo].[ApplicantMonitoringReport_ScheduledReport] 
       -- Add the parameters for the stored procedure here
       @Clno int 
       
AS
BEGIN
       -- SET NOCOUNT ON added to prevent extra result sets from
       -- interfering with SELECT statements.
       SET NOCOUNT ON;

    -- Insert statements for procedure here
       DECLARE @StartDate datetime= DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE())-1, 0) --First day of previous month.
       Declare @EndDate datetime = DATEADD(MONTH, DATEDIFF(MONTH, -1, GETDATE())-1, -1) --Last day of previous month.
       SELECT 
              c.CLNO [Client ID]
              , c.Name [Client Name]
              , replace(a.Attn,',','') [Requestor]
              , a.APNO [Report ID]
              , asd.AppStatusValue [Report Status]
              , a.First + ' ' + a.Last [Applicant Name]
              , [as].CreateDate [CIC Invitation Date]
              , CASE WHEN os.IsReviewRequired = 1 THEN rr.CreateDate else [as].ModifyDate End [CIC Invitation Completion Date]
              , CASE WHEN os.IsReviewRequired = 1 THEN datediff(day,[as].CreateDate, rr.CreateDate) ELSE datediff(day,[as].CreateDate, [as].ModifyDate) END [Candidate Completion]
              , case when os.IsReviewRequired = 1 THEN 'Yes' ELSE 'No' END [HR Review Required]
              , rra.ModifyDate [HR Review Completion Date]
              , CASE WHEN os.IsReviewRequired = 1 THEN datediff(day,rr.CreateDate, rra.ModifyDate) ELSE datediff(day,[as].ModifyDate, rra.ModifyDate) END [TAC Time to Submit]
              , a.OrigCompDate [Report Completed Date]
              , [dbo].[ElapsedBusinessDays_2](a.ApDate,a.OrigCompDate) [PreCheck Turn Around Tme]
              , datediff(day,[as].CreateDate, a.OrigCompDate) [Total Time For Background]
       FROM dbo.Appl a
       INNER JOIN client c ON a.CLNO = c.CLNO
       INNER JOIN dbo.AppStatusDetail asd ON a.ApStatus = asd.AppStatusItem
       inner JOIN Enterprise.Staging.ApplicantStage [as] ON a.apno = [as].ApplicantNumber
       INNER JOIN Enterprise.Staging.OrderStage os ON [as].StagingOrderId = os.StagingOrderId
       left JOIN Enterprise.Staging.ReviewRequest rr ON [as].StagingApplicantId = rr.StagingApplicantId AND rr.ClosingReviewStatusId IN (3,4)
       LEFT JOIN Enterprise.Staging.ReviewResponseAction rra ON rr.ReviewRequestId = rra.ReviewRequestId AND rra.ReviewStatusId = 3
       WHERE 
       c.WebOrderParentCLNO = @Clno
       AND 
       (      a.ApStatus = 'P'
              OR 
              --(a.ApStatus='F' and (a.OrigCompDate>= @StartDate and a.OrigCompDate<= @EndDate))
              [as].CreateDate BETWEEN @StartDate AND @Enddate
       )
       ORDER BY [as].CreateDate
END
