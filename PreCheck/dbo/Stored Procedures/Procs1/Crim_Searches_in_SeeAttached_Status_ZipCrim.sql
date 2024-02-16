-- =============================================
-- Author:		Deepak Vodethela
-- Create date: 05/12/2020
-- Description:	Leads closed in a See Attached status due to COVID-19 as of [present date]
-- Execution: EXEC Crim_Searches_in_SeeAttached_Status_ZipCrim
-- =============================================
CREATE PROCEDURE [dbo].[Crim_Searches_in_SeeAttached_Status_ZipCrim]
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT  a.APNO, s.PartnerReference AS [CaseNumber], W.WorkOrderID, a.CLNO, cl.[Name] as ClientName, 
			ra.Affiliate, a.UserID, a.ApDate,a.Apstatus, a.[Last], a.[First], FORMAT(a.DOB,'yyyy-MM-dd') AS DOB,
			c.County
    FROM Crim c 
	INNER JOIN Appl a ON c.APNO = a.APNO
	INNER JOIN Client cl on a.clno = cl.clno
	INNER JOIN refAffiliate ra on cl.affiliateID = ra.AffiliateID
	LEFT OUTER JOIN dbo.PreCheckZipCrimComponentMap p ON C.CrimID = P.SectionUniqueID AND P.IsActive = 0
	LEFT OUTER JOIN dbo.ZipCrimWorkOrders W ON C.APNO = W.APNO
	LEFT OUTER JOIN dbo.ZipCrimWorkOrdersStaging s ON W.WorkOrderID = s.WorkOrderID
	WHERE Apstatus in ('P', 'W', 'F')
	  AND c.[Clear] = 'S'
	  AND cl.AffiliateID = 249 -- eVerifile
	ORDER BY a.ApDate DESC	
END
