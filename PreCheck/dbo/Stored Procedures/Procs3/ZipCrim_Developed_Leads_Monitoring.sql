-- =============================================
-- Author:		Deepak Vodethela
-- Create date: 08/24/2020
-- Description:	Monitoring developed leads
-- Execution : EXEC ZipCrim_Developed_Leads_Monitoring
-- =============================================
CREATE PROCEDURE ZipCrim_Developed_Leads_Monitoring
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

	SELECT c.APNO, c.CrimID, c.County, c.CNTY_NO, c.IsHidden, c.Crimenteredtime, a.ApDate
		INTO #tmpPreCheckActiveLeads
	FROM dbo.Appl a
	INNER JOIN dbo.Crim c ON A.APNO = c.APNO
	INNER JOIN dbo.Client c2 ON A.CLNO = c2.CLNO
	WHERE c2.AffiliateID = 249

  --SELECT '#tmpPreCheckActiveLeads' AS TableName, * FROM #tmpPreCheckActiveLeads p

  SELECT t.APNO, t.CrimID, t.County, t.CNTY_NO, p.SectionUniqueID, p.ExternalID, p.IsSent, p.SendDate, p.SendAttempts, p.IsActive
	INTO #tmpZipCrimLeads
  FROM #tmpPreCheckActiveLeads t
  INNER JOIN dbo.PreCheckZipCrimComponentMap p ON T.CrimID = P.SectionUniqueID

  --SELECT * FROM #tmpZipCrimLeads WHERE APNO = 5268740

  SELECT t.*
	INTO #tmpMissingDeevelopedLeads
  FROM #tmpPreCheckActiveLeads t
  LEFT OUTER JOIN #tmpZipCrimLeads p ON T.APNO = p.APNO AND t.CNTY_NO = p.CNTY_NO
  WHERE P.ExternalID IS NULL

  --SELECT * FROM #tmpMissingDeevelopedLeads t --WHERE T.IsHidden = 0 ORDER BY 1 

  SELECT t.APNO, t.County, S.PartnerReference AS CaseNumber, S.WorkOrderID, t.CrimID
  FROM #tmpMissingDeevelopedLeads t 
  INNER JOIN dbo.ZipCrimWorkOrders z ON T.APNO = Z.APNO
  INNER JOIN dbo.ZipCrimWorkOrdersStaging S ON Z.WorkOrderID = S.WorkOrderID
  WHERE T.IsHidden = 0 
  ORDER BY 1 DESC

  DROP TABLE #tmpPreCheckActiveLeads
  DROP TABLE #tmpZipCrimLeads
  DROP TABLE #tmpMissingDeevelopedLeads

	SET TRANSACTION ISOLATION LEVEL READ COMMITTED
	SET NOCOUNT OFF

END
