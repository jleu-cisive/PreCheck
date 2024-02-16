-- =============================================
-- Author:		<Vivek Chaturvedi>
-- Create date: <2022-07-26>
-- Description:	<#19422>

-- EXEC [CIC_Client_Experience] '01/07/2022', '08/07/2022', 0, 0   
-- =============================================
CREATE PROCEDURE [dbo].[CIC_Client_Experience]
	-- Add the parameters for the stored procedure here
	@StartDate DATE,
	@EndDate DATE, 
	@clno int,
	@Affiliate int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	  SELECT DISTINCT c.CLNO AS [Client Number]  
   ,c.Name AS [Client Name]  
   ,RA.Affiliate AS [Affiliate Name]  
   ,a.Attn as [Recruiter Name]  
   ,a.APNO AS [Report Number]  
   ,a.First as [Applicant First Name]  
   ,a.Last as [Applicant Last Name]  
   ,FORMAT(s.CreateDate,'MM/dd/yyyy hh:mm tt') AS [Invite Sent]  
   ,FORMAT(a.CreatedDate,'MM/dd/yyyy hh:mm tt') AS [Invite Completed] 
  
         ,FORMAT(cc.ClientCertUpdated,'MM/dd/yyyy hh:mm tt') AS [Certification Completed]  
   ,FORMAT(a.CreatedDate,'MM/dd/yyyy hh:mm tt')AS [Recived Date]  
   ,FORMAT(a.OrigCompDate,'MM/dd/yyyy hh:mm tt') AS [Original Close Date]  
   ,FORMAT(a.ReopenDate,'MM/dd/yyyy hh:mm tt') AS [ReOpen Date]  
   ,FORMAT(a.CompDate,'MM/dd/yyyy hh:mm tt') AS [Completed Date]  
   ,[dbo].[ElapsedBusinessDays_2](a.CreatedDate,a.OrigCompDate) AS [Report TAT] 
   ,(SELECT CONVERT(varchar(6), DATEDIFF(second, a.CreatedDate, cc.ClientCertUpdated)/3600) + ':' + RIGHT('0' + CONVERT(varchar(2), (DATEDIFF(second, a.CreatedDate, cc.ClientCertUpdated) % 3600) / 60), 2)
	+ ':' + RIGHT('0' + CONVERT(varchar(2), DATEDIFF(second,  a.CreatedDate, cc.ClientCertUpdated) % 60), 2) AS 'HH:MM:SS') as AvgTimeforClientUsertoCertified  --,ABS( DATEDIFF(day,  cc.ClientCertUpdated, a.CreatedDate)) as AvgTimeforClientUsertoCertified
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
END
