-- =============================================
-- Author:		DEEPAK VODETHELA
-- Create date: 09/26/2018
-- Description:	Jurisdiction Ordered by Client
-- Execution: EXEC Jurisdiction_Ordered_by_Client '09/01/2018','09/25/2018',0,0,0
-- Modified by Humera Ahmed on 6/26/2020 - Added 2 new columns Case #, [Lead Closing Status] for HDT - #74378
-- =============================================
CREATE PROCEDURE [dbo].[Jurisdiction_Ordered_by_Client] 
@StartDate date,
@EndDate Date,	
@clno int,
@Affiliate int = 0,
@CountyID int = 0
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	   SELECT RA.Affiliate, a.CLNO,T.[NAME] AS [Client Name], 
	   a.APNO, zcwos.PartnerReference [Case #], a.ApDate,
	   c.IrisOrdered as 'Ordered Date', c.CNTY_NO, c.County,
	   c2.crimdescription [Lead Closing Status], a.ApStatus, 
	   a.Last AS [Last Name], a.First AS [First Name]
       FROM dbo.Appl a(NOLOCK)
       INNER JOIN dbo.Crim c(NOLOCK) ON a.Apno = c.APNO
       INNER JOIN dbo.CLient T (NOLOCK) ON A.CLNO = T.CLNO
       INNER JOIN dbo.refAffiliate AS RA (NOLOCK) ON T.AffiliateID = RA.AffiliateID
       INNER JOIN dbo.Crimsectstat c2 ON c.Clear = c2.crimsect
       INNER JOIN dbo.PreCheckZipCrimComponentMap pczccm ON c.APNO = pczccm.APNO
       INNER JOIN dbo.ZipCrimWorkOrders zcwo ON pczccm.APNO = zcwo.APNO
       INNER JOIN dbo.ZipCrimWorkOrdersStaging zcwos ON zcwo.WorkOrderID = zcwos.WorkOrderID
       WHERE C.IsHidden = 0
         AND ((Convert(date, c.IrisOrdered)>= CONVERT(date, @StartDate)) 
         AND (Convert(date, c.IrisOrdered) <= CONVERT(date, @EndDate)))
         AND T.CLNO = IIF(@CLNO=0, T.CLNO, @CLNO) 
         AND T.AffiliateID = IIF(@Affiliate=0, T.AffiliateID, @Affiliate) 
         AND C.CNTY_NO = IIF(@CountyID=0, C.CNTY_NO, @CountyID)

END
