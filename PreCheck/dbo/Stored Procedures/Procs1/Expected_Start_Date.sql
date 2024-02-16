-- =============================================
-- Author: Abhijti Awari
-- Create date: 07/13/2022
-- Description:	Report to get Expected Start Date for #48602 
------The client has requested for PreCheck to capture and relay to the background the start date assigned to an applicant during the on-boarding.
------The initiative is to measure the success rate of NEO and the Applicant experience as a result of the BG report.
-- Execution: EXEC [Expected_Start_Date] '08/01/2021', '11/01/2021', 0, 0, 
-- =============================================
CREATE PROCEDURE [dbo].[Expected_Start_Date]
	@StartDate DATE,
	@EndDate DATE,
	@clno int,
	@Affiliate int
	--,@IsOneHR bit 
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

   declare @DateDiff int= 0;
   select @DateDiff = ABS(DATEDIFF(month, @StartDate, @EndDate));
  
  --Three months limit
   if  @DateDiff > 3 and @StartDate<@EndDate
   begin
   set @EndDate =  DATEADD(m,3,@StartDate)
   end

	SELECT  c.CLNO AS [Client Number]
			,c.Name AS [Client Name]
			,RA.Affiliate AS [Affiliate Name]
			,a.APNO AS [Report Number]
			,a.First as [Applicant First Name]
			,a.Last as [Applicant Last Name]
		
			,FORMAT(s.CreateDate,'MM/dd/yyyy hh:mm') AS [Invite Sent]
			,FORMAT(a.CreatedDate,'MM/dd/yyyy hh:mm') AS [Invite Completed]
			,a.Attn as [Recruiter Name]
	        	,FORMAT(cc.ClientCertUpdated,'MM/dd/yyyy hh:mm') AS [Certification Completed]
			,FORMAT(a.CreatedDate,'MM/dd/yyyy hh:mm')AS [Received Date]
			,Format(CONVERT(datetime,JSON_VALUE(JsonContent,'$.JobDetail.JobStartDate')),'MM/dd/yyyy hh:mm')  as [Expected Start Date]
			,FORMAT(a.OrigCompDate,'MM/dd/yyyy hh:mm') AS [Original Close Date]
			,FORMAT(a.ReopenDate,'MM/dd/yyyy hh:mm') AS [ReOpen Date]
			,FORMAT(a.CompDate,'MM/dd/yyyy hh:mm') AS [Completed Date]
			,[dbo].[ElapsedBusinessDays_2](a.CreatedDate,a.OrigCompDate) AS [Report TAT]
			,ISNULL(F.IsOneHR,0) AS [IsOneHR],
			[dbo].[ElapsedBusinessDays_2](s.CreateDate,a.OrigCompDate) AS [Invite to Original Close TAT – Without Reopen],
			[dbo].[ElapsedBusinessDays_2](s.CreateDate,a.CompDate) AS [Total Client TAT (Invite to Last Close Date)],
			CASE WHEN (X.RuleGroup IS NOT NULL OR LEN(X.RuleGroup) > 0) THEN 'True' ELSE 'False' END AS [Adverse/Dispute],
			CASE WHEN CONVERT(BIT,CASE WHEN o.BatchOrderDetailId IS NULL THEN 0 ELSE 1 END) = 0 THEN 'False' ELSE 'True' END as MCIC
       FROM  PreCheck.dbo.Appl AS A(NOLOCK) 
	
       INNER JOIN PreCheck.dbo.Client AS c(NOLOCK) ON a.CLNO = c.CLNO		
       INNER JOIN Precheck.dbo.refAffiliate AS RA WITH (NOLOCK) ON c.AffiliateId = RA.AffiliateID
       LEFT JOIN Enterprise.dbo.[Order] AS O(NOLOCK) ON a.APNO = o.OrderNumber
       LEFT JOIN Enterprise.Staging.OrderStage S(nolock) on O.OrderId = S.OrderId and O.DASourceId=2
       LEFT OUTER JOIN PreCheck.dbo.ClientCertification AS cc(NOLOCK) ON a.APNO = cc.APNO AND CC.ClientCertReceived = 'Yes'
       LEFT OUTER JOIN HEVN.dbo.Facility F (NOLOCK) ON (ISNULL(A.DeptCode,0) = F.FacilityNum  OR A.CLNO = F.FacilityCLNO)
       LEFT OUTER JOIN Enterprise.[dbo].[vwAdverseActionReason] AS X ON A.APNO = X.APNO
       WHERE a.OrigCompDate BETWEEN @StartDate AND DATEADD(d,1,@EndDate)
              AND c.CLNO = IIF(@CLNO=0, C.CLNO, @CLNO) 
              AND c.AffiliateId = IIF(@Affiliate=0, c.AffiliateId, @Affiliate) 
              --AND ISNULL(F.IsOneHR,0) = ISNULL(@IsOneHR, 0)

END
