-- Alter Procedure ZipCrim_Billing_Report

-- =============================================
-- Author:		/*Yves Fernandes*/
-- Create date: /*2019-10-14*/
-- Description:	/*Zipcrim Billing Summary*/
-- Modified by Radhika on 06/17/2020 per deepak to change the date from -7 to -9
-- Modified by Radhika on 06/18/2020 per deepak to change the date from -9 to -5
-- =============================================
CREATE PROCEDURE [dbo].[ZipCrim_Billing_Report]
AS
BEGIN
	DROP TABLE IF EXISTS #apps
	DECLARE @currentDate date = dateadd( dd,-9,getdate())


	SELECT a.apno, a.clno, a.apstatus, a.origcompdate, a.PackageID, a.ApDate INTO #apps  FROM appl a WITH (NOLOCK)
	WHERE a.apstatus = 'F' AND cast(a.OrigCompDate AS date) > @currentDate AND a.EnteredVia = 'ZipCrim'

	select	zw.APNO,a.clno, cl.Name as ClientName, zw.WorkOrderID, zws.PartnerReference as CaseNumber, 
			isnull(z.ExternalID, '00') as LeadNum, a.PackageID, a.apdate, a.OrigCompDate,
			a.apstatus, z.componentType componentType, z.SectionUniqueID,
			z.IsSent, z.SendDate,z.ExternalType LeadType, 
			case z.Clear WHEN 'T' THEN 'CLEAR'WHEN 'F' THEN 'RECORD FOUND' ELSE z.Clear END as CrimStatus,
			idp.ServiceType, idp.SubKey, idp.SubKeyChar, 
			replace(idp.FeeDescription,',','') AS FeeDescription, idp.Amount
	from ZipCrimWorkOrdersStaging zws
	inner join ZipCrimWorkOrders zw on zw.WorkOrderID = zws.WorkOrderID
	inner join #apps a with (nolock) on a.APNO = zw.APNO
	inner join client cl on cl.clno = a.clno
	inner join InvDetailsParallel idp on a.apno = idp.apno
	LEFT JOIN (
		SELECT pczccm.apno, cc.CNTY_NO, pczccm.IsSent, pczccm.ExternalID, pczccm.ExternalType, pczccm.SectionUniqueID,
			pczccm.ApplSectionID,pczccm.SendDate, c.Clear, asec.Description AS componentType
		 FROM dbo.PreCheckZipCrimComponentMap pczccm
		INNER JOIN #apps a2 ON a2.apno = pczccm.APNO
		INNER join crim c on c.apno = pczccm.apno  and c.crimId = pczccm.sectionuniqueId
		INNER JOIN dbo.TblCounties cc ON cc.cnty_no = c.CNTY_NO
		INNER JOIN dbo.ApplSections asec ON pczccm.ApplSectionID = asec.ApplSectionID
		WHERE pczccm.ApplSectionID = 5
	) as z ON  z.apno = a.apno AND z.CNTY_NO = idp.SubKey	
	where ((idp.ServiceType = 2 AND idp.FeeDescription LIKE '%court access fee%') OR idp.ServiceType = 1)
	ORDER BY a.apdate DESC
END
