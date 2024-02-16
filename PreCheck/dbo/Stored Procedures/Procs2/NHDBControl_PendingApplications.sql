-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================

-- =============================================
-- Updated By:		Doug DeGenaro
-- Updated date: 08/29/2013
-- Description:	exclude apps that are inuse for AIMI
-- =============================================
CREATE PROCEDURE [dbo].[NHDBControl_PendingApplications]
	@Username varchar(25) = null
AS
BEGIN
	
	
SELECT Appl.APNO,Client.Name as ClientName,Client.State, Appl.Last, Appl.First, Appl.Middle, Appl.Alias1_Last, Appl.Alias1_First, Appl.Alias1_Middle,
Appl.Alias2_Last, Appl.Alias2_First, Appl.Alias2_Middle, Appl.Alias3_Last, Appl.Alias3_First, Appl.Alias3_Middle, 
Appl.Alias4_Last, Appl.Alias4_First, Appl.Alias4_Middle, Appl.ApStatus, Appl.SSN, Appl.DOB, Appl.ApDate, 
MedInteg.SectStat, refAffiliate.Affiliate
FROM ((Appl with (nolock) 
LEFT JOIN
 Client  with (nolock) ON Appl.CLNO = Client.CLNO)
 LEFT JOIN
 MedInteg  with (nolock) ON Appl.APNO = MedInteg.APNO)
 LEFT JOIN 
refAffiliate  with (nolock) ON Client.AffiliateID = refAffiliate.AffiliateID
WHERE (((Appl.ApStatus)='p' Or (Appl.ApStatus)='w') AND ((MedInteg.SectStat)='9')) 
AND IsNull(Appl.InUse,'') = ''
--and (select count(*) from medintegapplreview with (nolock) where apno = appl.apno and username = @username) = 0
ORDER BY Appl.APNO, Appl.Last, Appl.First, Appl.Middle, Appl.ApDate;


END