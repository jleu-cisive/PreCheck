-- =============================================
-- Author: Humera Ahmed
-- Create date: 03/22/2021
-- Description: HDT# 86105 Create a new Qreport for Name counts on application.
-- EXEC [dbo].[AliasNameCountOnReport_Qreport] '03/22/2021','03/22/2021'
-- =============================================
CREATE PROCEDURE [dbo].[AliasNameCountOnReport_Qreport] 
       -- Add the parameters for the stored procedure here
       @StartDate datetime,
       @EndDate datetime
AS
BEGIN
       -- SET NOCOUNT ON added to prevent extra result sets from
       -- interfering with SELECT statements.
       SET NOCOUNT ON;

    -- Insert statements for procedure here
       SELECT 
              a.APNO
              , ra.Affiliate [Affiliate Name]
              ,count(a.APNO) [Names Count]
       FROM dbo.appl a (NOLOCK)
              INNER JOIN dbo.ApplAlias aa (NOLOCK) ON a.APNO = aa.APNO
              INNER JOIN dbo.Client c (NOLOCK) ON a.CLNO = c.CLNO
              INNER JOIN dbo.refAffiliate ra (NOLOCK) ON c.AffiliateID = ra.AffiliateID
       WHERE 
              cast(a.ApDate AS date) BETWEEN @StartDate AND @EndDate
              AND aa.IsPublicRecordQualified = 1
       GROUP BY a.APNO, ra.Affiliate
       ORDER BY a.APNO
END

