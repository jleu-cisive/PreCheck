-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================

-- =============================================
-- Updated By:		Doug DeGenaro
-- Updated date: 08/29/2013
-- Description:	exclude apps that are inuse for AIMI
-- EXEC  [dbo].[NHDBControl_PendingApplications_Test] 'pkumari'
-- =============================================
CREATE PROCEDURE [dbo].[NHDBControl_PendingApplications_Test]
	@Username varchar(25) = null
AS
BEGIN
	
	--select apno,
	--max(case when seq = 1 then [First] end) Alias1_First,
	--max(case when seq = 1 then middle end) Alias1_middle,
	--max(case when seq = 1 then [Last] end) Alias1_last,
	--max(case when seq = 2 then [First] end) Alias2_First,
	--max(case when seq = 2 then middle end) Alias2_middle,
	--max(case when seq = 2 then [Last] end) Alias2_last,
	--max(case when seq = 3 then [First] end) Alias3_First,
	--max(case when seq = 3 then middle end) Alias3_middle,
	--max(case when seq = 3 then [Last] end) Alias3_last	
	--into #tempAA
	--from 
	--(
	--	select apno,first,middle,last,IsPublicRecordQualified,
	--	row_number() over(partition by apno order by applaliasid) seq
	--	from ApplAlias 
	--) aa where aa.APNO=5118582 and aa.IsPublicRecordQualified=1
	--group by apno
	
	--SELECT Appl.APNO,Client.Name as ClientName,Client.State, Appl.Last, Appl.First, Appl.Middle, 
	--aa.Alias1_Last, aa.Alias1_First, aa.Alias1_Middle, aa.Alias2_Last, aa.Alias2_First, aa.Alias2_Middle, 
 --   aa.Alias3_Last, aa.Alias3_First, aa.Alias3_Middle, Appl.ApStatus, Appl.SSN, Appl.DOB, Appl.ApDate, 
	--MedInteg.SectStat, refAffiliate.Affiliate
	--FROM ((Appl with (nolock) 
	--INNER JOIN
	-- #tempAA aa with (nolock) ON aa.APNO = Appl.APNO
	--LEFT JOIN
	-- Client  with (nolock) ON Appl.CLNO = Client.CLNO)
	-- LEFT JOIN
	-- MedInteg  with (nolock) ON Appl.APNO = MedInteg.APNO)
	-- LEFT JOIN 
	--refAffiliate  with (nolock) ON Client.AffiliateID = refAffiliate.AffiliateID
	--WHERE (((Appl.ApStatus)='p' Or (Appl.ApStatus)='w') AND ((MedInteg.SectStat)='9')) 
	--AND IsNull(Appl.InUse,'') = '' 
	--ORDER BY Appl.APNO, Appl.Last, Appl.First, Appl.Middle, Appl.ApDate;


		SELECT top 1000 Appl.APNO,Client.Name as ClientName,Client.State, Appl.Last, Appl.First, Appl.Middle, Appl.Alias1_Last, Appl.Alias1_First, Appl.Alias1_Middle,
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
	ORDER BY Appl.APNO, Appl.Last, Appl.First, Appl.Middle, Appl.ApDate desc;


END