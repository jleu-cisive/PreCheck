-- =============================================
-- Author: Radhika Dereddy
-- Create date: 02/28/2021
-- Description: PersRef Verified Rate with Affiliate Details
-- Mirrored the procedure from [GetPersRefVerifiedRateWithAffiliate] Qreport to schedule it
-- EXEC [dbo].[GetPersRefVerifiedRateWithAffiliate_ClientSchedule]
-- =============================================
CREATE PROCEDURE [dbo].[GetPersRefVerifiedRateWithAffiliate_ClientSchedule]

AS
BEGIN

DECLARE @StartDate DATE = DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE())-1, 0) --First day of previous month
DECLARE @EndDate DATE = DATEADD(MONTH, DATEDIFF(MONTH, -1, GETDATE())-1, -1) --Last Day of previous month
DECLARE @CLNO int =0
DECLARE @AffiliateID INT =0 


SET NOCOUNT ON;
       
    -- Insert statements for procedure here
       SELECT DISTINCT a.APNO AS [Report Number],                     
                     FORMAT(a.ApDate,'MM/dd/yyyy hh:mm:s tt') AS [Report Date],
                     RA.Affiliate, a.CLNO AS [Client Number], c.[Name] AS [ClientName], 
                     a.ApStatus AS [Report Status], 
                     ISNULL(FORMAT(a.ReopenDate,'MM/dd/yyyy hh:mm:s tt'),'N/A') as 'Re-Open Date',
                     a.[Last] AS [Last Name], a.[First] AS [First Name], pr.[Name] AS [PersRef Name],
					 pr.Phone AS [PersRef Phone#],
                     [Y].[Description] AS [Status],
                     isnull(sss.SectSubStatus, '') as [SubStatus],
                     I.Amount, [X].[Description] AS ClientAdjudicationStatus
       FROM [Appl] AS a(NOLOCK)
       INNER JOIN [PersRef] AS pr(NOLOCK) ON a.APNO = pr.APNO
       INNER JOIN Client AS C(NOLOCK) on a.CLNO = C.clno
       INNER JOIN refAffiliate AS RA (NOLOCK) on C.AffiliateID= RA.AffiliateID 
       LEFT OUTER JOIN ClientAdjudicationStatus AS X(NOLOCK) ON pr.ClientAdjudicationStatus = X.ClientAdjudicationStatusID
       INNER JOIN SectStat AS Y(NOLOCK) ON pr.SectStat = Y.Code
       LEFT OUTER JOIN InvDetail AS I(NOLOCK) ON pr.APNO = I.APNO AND I.[Description] LIKE '%Personal Reference%'
       Left join dbo.SectSubStatus sss (NOLOCK) on pr.SectStat = sss.SectStatusCode and pr.SectSubStatusID = sss.SectSubStatusID
       WHERE (pr.IsOnReport = 1)
         AND (pr.[IsHidden] = 0)
		 AND (a.ApStatus = 'F')
         AND (CONVERT(DATE,a.[OrigCompDate]) >= @Startdate) AND (CONVERT(DATE,a.[OrigCompDate]) <= @Enddate) 
         AND a.CLNO = IIF(@CLNO = 0, C.CLNO, @CLNO)
         AND RA.AffiliateID = IIF(@AffiliateID = 0, RA.AffiliateID, @AffiliateID)
       ORDER BY a.APNO,[Report Date] 
END
