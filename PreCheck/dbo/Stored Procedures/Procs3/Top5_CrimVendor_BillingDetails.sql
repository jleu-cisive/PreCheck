-- =============================================
-- Author:		Prasanna 
-- Create date: 04/22/2022
-- Description:	Top5_CrimVendor_BillingDetails
-- EXEC Top5_CrimVendor_BillingDetails   ----SEX OFFENDER SEARCH, INNOVATIVE NATIONAL,WHOLESALE SCREENING
-- =============================================
CREATE PROCEDURE [dbo].[Top5_CrimVendor_BillingDetails] 
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    DROP TABLE IF EXISTS #tmpCrimOrdered
	SELECT DISTINCT	a.Apno, a.ApDate, a.CompDate, a.Investigator, a.DOB, a.CLNO, c.CAM, c.[Name], ra.Affiliate, rbc.BillingCycle,cr.Ordered,
			R_Name, cr.CRIM_SpecialInstr,cr.Priv_Notes, cr.CrimId, cr.IsHidden, cr.County, tc.[State], cr.[Clear],rc.Researcher_Aliases_count[Alias Allowed Count], 
			rc.Researcher_combo, rc.Researcher_other,rc.Researcher_CourtFees, cr.deliverymethod --ISNULL(cl.ChangeDate, '') as [Vendor Reviewed Date] 
			,MAX(CASE WHEN cr.deliverymethod = 'OnlineDB' THEN cv.EnteredDate ELSE cl.ChangeDate END) as 'Vendor Reviewed Date', MAX(cr.Crimenteredtime) as Crimenteredtime
	INTO #tmpCrimOrdered
	FROM dbo.Appl a WITH(NOLOCK)
	INNER JOIN dbo.Crim cr WITH(NOLOCK) ON a.APNO = cr.APNO
	LEFT OUTER JOIN CriminalVendor_Log cv on cr.apno = cv.apno and cr.cnty_no = cv.CNTY_NO
	INNER JOIN dbo.Client c WITH(NOLOCK) ON A.CLNO = C.CLNO
	INNER JOIN dbo.refBillingCycle rbc WITH(NOLOCK) ON rbc.BillingCycleID = c.BillingCycleID
	INNER JOIN dbo.refAffiliate ra WITH(NOLOCK) ON C.AffiliateID = ra.AffiliateID
	INNER JOIN dbo.TblCounties tc WITH(NOLOCK) ON cr.CNTY_NO = tc.CNTY_NO
	INNER JOIN dbo.Iris_Researchers r WITH(NOLOCK) ON cr.vendorid = r.R_id
	INNER JOIN dbo.Iris_Researcher_charges rc WITH(NOLOCK) ON rc.Researcher_id = r.R_id and rc.cnty_no = cr.CNTY_NO
	LEFT OUTER JOIN dbo.changeLog cl WITH(NOLOCK) ON cl.ID = cr.CrimID AND (cl.TableName = 'Crim.Status' OR cl.TableName = 'Crim.Clear') AND (((ISNULL(cl.oldvalue,'') in('V','F','O','B')) and NewValue='T') OR (oldvalue IS NULL and NewValue='T') OR (NewValue='V'))
	WHERE cr.ordered is not null 
	  AND a.ApStatus ='F' 
	  AND a.clno not in(2135,3468) 
	  AND cr.Clear NOT IN('I')
	--  AND cr.IsHidden = 0
	AND cr.ordered is not null and cr.ordered <>'' 
	AND  isdate(cr.ordered) =1  
	AND TRY_CAST(cr.ordered as date) is not null
	AND CAST(cr.ordered as DATE) >= DATEADD(day, -3, getdate())
	--AND (r.R_Name like '%SJV%' OR  r.R_Name like'%Securitec%' OR r.R_Name like'%Lexis Nexis%'
	          --  OR r.R_Name like'%Omni%' OR r.R_Name like'%Wholesale%' OR r.R_Name like'%Innovative%')
	--AND a.apno= 6168841   
	AND (r.R_Name like '%SJV%' OR r.R_Name like '%Securitec%'  OR r.R_Name like '%Lexis%' OR r.R_Name like '%Omni%' OR r.R_Name like '%Wholesale%' OR r.R_Name like '%Innovative%') --SJV, Securitec, Lexis Nexis, Omni, Wholesale, Innovative
	group by a.Apno, a.ApDate, a.CompDate, a.Investigator, a.DOB, a.CLNO, c.CAM, c.[Name], ra.Affiliate, rbc.BillingCycle,
			R_Name, cr.CRIM_SpecialInstr,cr.Priv_Notes, cr.CrimId, cr.IsHidden, cr.County, tc.[State], cr.[Clear],rc.Researcher_Aliases_count, 
			rc.Researcher_combo, rc.Researcher_other,rc.Researcher_CourtFees, cr.deliverymethod, cr.Ordered


	--SELECT * from #tmpCrimOrdered 

	DROP TABLE IF EXISTS #tmpNameByAPNO
	SELECT	t.Apno, t.CrimId,  S.ApplSectionId,S.IsActive,
			ISNULL(AA.First,'') +' '+ ISNULL(AA.Middle,'') +' '+ ISNULL(AA.Last,'') as [QualifiedNames], 
			s.CreatedBy as [PRInvestigator]
		INTO #tmpNameByAPNO
	FROM #tmpCrimOrdered t (NOLOCK)
	INNER JOIN ApplAlias AA(NOLOCK) ON t.APNO = AA.APNO 
	LEFT OUTER JOIN dbo.ApplAlias_Sections S(NOLOCK) ON  AA.ApplAliasID = S.ApplAliasID AND t.CrimID = s.SectionKeyID
	WHERE AA.IsActive = 1 
	  AND AA.IsPublicRecordQualified = 1
	  AND (S.ApplSectionId = 5 OR S.ApplSectionId IS NULL)
	  AND (S.IsActive = 1 OR S.IsActive IS NULL)

	--SELECT * FROM #tmpNameByAPNO --WHERE CrimId = 38839818

	DROP TABLE IF EXISTS #tmpSelectedAliases
  	SELECT  t.CrimID, t.APNO,
			t.PRInvestigator,QualifiedNames
			--AliasesSentToVendor = STUFF((SELECT ', ' + QualifiedNames
			--							FROM #tmpNameByAPNO b 
			--							WHERE b.CrimID = t.CrimID 
			--							FOR XML PATH('')), 1, 2, '') 
		INTO #tmpSelectedAliases
	FROM #tmpNameByAPNO t (NOLOCK)
	GROUP BY t.CrimID, t.APNO, t.PRInvestigator, QualifiedNames 

	--SELECT * FROM #tmpSelectedAliases

	SELECT  DISTINCT
			t.Apno as APNO, t.apdate [App Created date],t.CompDate [App Completed Date],
			t.investigator [Applicant Investigator],t.CAM, t.CLNO, t.[Name] as [Client Name], t.Affiliate as [Client Affiliate], t.BillingCycle,
			t.DOB, t.R_Name as [Vendor Name], t.[County],t.[State], t.CrimID, t.IsHidden as [UnUsed], t.CRIM_SpecialInstr as [Crim Special Instructions], t.Priv_Notes as [Private Notes], 
			K.QualifiedNames as [Names Selected], k.PRInvestigator,t.[Alias Allowed Count], t.Researcher_combo, t.Researcher_other,t.Researcher_CourtFees, t.[Vendor Reviewed Date], t.Crimenteredtime
	FROM #tmpCrimOrdered t (NOLOCK)
	LEFT OUTER JOIN #tmpSelectedAliases AS K(NOLOCK) ON T.CrimID = k.CrimID

END
