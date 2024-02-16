-- =============================================
-- Author:		Prasanna 
-- Create date: 04/22/2022>
-- Description:	Crim Vendor Billing Details
-- EXEC QReport_CrimVendorBillingDetails '02/01/2022','02/02/2022','INNOVATIVE NATIONAL'   ----SEX OFFENDER SEARCH, INNOVATIVE NATIONAL,WHOLESALE SCREENING
-- =============================================
CREATE PROCEDURE [dbo].[QReport_CrimVendorBillingDetails] 
	-- Add the parameters for the stored procedure here
	@StartDate DateTime,
	@EndDate DateTime,
	@VendorName varchar(100)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    DROP TABLE IF EXISTS #tmpchangelog
	select
		 cr.APNO,cr.CrimId, cr.County ,cr.CRIM_SpecialInstr,cr.Priv_Notes, cr.IsHidden, cr.deliverymethod, cr.Ordered, cr.[Clear], cr.[CNTY_NO],cr.[vendorid], MAX(cr.Crimenteredtime) as Crimenteredtime
		,MAX(cv.EnteredDate) AS 'Vendor Reviewed Date'
	INTO #tmpchangelog
	FROM
		Crim cr WITH(NOLOCK)
	INNER JOIN
		dbo.Iris_Researchers r WITH(NOLOCK)
		ON cr.vendorid = r.R_id
	LEFT OUTER JOIN
		CriminalVendor_Log cv WITH(NOLOCK)
		on cr.apno = cv.apno and cr.cnty_no = cv.CNTY_NO
	WHERE
		cv.EnteredDate BETWEEN @StartDate AND @EndDate
	AND cr.deliverymethod = 'OnlineDB'
	AND r.R_Name like '%' + CASE WHEN @VendorName IS NULL THEN r.R_Name ELSE @VendorName END  +  '%'
	GROUP BY
		cr.APNO,cr.CrimId,  cr.County ,cr.CRIM_SpecialInstr,cr.Priv_Notes, cr.IsHidden, cr.deliverymethod, cv.EnteredDate, cr.Ordered, cr.[Clear], cr.[CNTY_NO],cr.[vendorid]


    INSERT INTO #tmpchangelog
	select
		 cr.APNO,cr.CrimId, cr.County ,cr.CRIM_SpecialInstr,cr.Priv_Notes, cr.IsHidden, cr.deliverymethod, cr.Ordered, cr.[Clear], cr.[CNTY_NO],cr.[vendorid]
		, MAX(cr.Crimenteredtime) as Crimenteredtime, MAX(cl.ChangeDate) AS 'Vendor Reviewed Date'
	FROM
		Crim cr WITH(NOLOCK)
	INNER JOIN
		dbo.Iris_Researchers r WITH(NOLOCK)
		ON cr.vendorid = r.R_id
	LEFT OUTER JOIN
		Changelog cl WITH(NOLOCK)
		on cl.ID = cr.CrimID
	WHERE
		(cl.TableName = 'Crim.Status' OR cl.TableName = 'Crim.Clear')
	AND (((ISNULL(cl.oldvalue,'') in('V','F','O','B')) and NewValue='T') OR (oldvalue IS NULL and NewValue='T') OR (NewValue='V'))
	AND cl.ChangeDate BETWEEN @StartDate AND @EndDate
	AND r.R_Name like '%' + CASE WHEN @VendorName IS NULL THEN r.R_Name ELSE @VendorName END  +  '%'
	AND  cr.deliverymethod <> 'OnlineDB'
	GROUP BY
		cr.APNO,cr.CrimId,  cr.County ,cr.CRIM_SpecialInstr,cr.Priv_Notes, cr.IsHidden, cr.deliverymethod, cl.ChangeDate, cr.ordered, cr.[Clear], cr.[CNTY_NO],cr.[vendorid]
   
  -- select * from #tmpchangelog

   DROP TABLE IF EXISTS #tmpCrimOrdered

   SELECT a.Apno, a.ApDate, a.CompDate, a.Investigator, a.DOB, a.CLNO, c.CAM, c.[Name], ra.Affiliate, rbc.BillingCycle,
			r.R_Name, t.CRIM_SpecialInstr,t.Priv_Notes, t.CrimId, css.crimdescription, t.IsHidden, t.County, tc.[State],rc.Researcher_Aliases_count[Alias Allowed Count],
			rc.Researcher_combo, rc.Researcher_other,rc.Researcher_CourtFees, t.deliverymethod, t.[Vendor Reviewed Date], t.Crimenteredtime 			
	INTO #tmpCrimOrdered
	FROM dbo.Appl a WITH(NOLOCK)
	INNER JOIN #tmpchangelog t ON t.APNO = A.APNO
	--INNER JOIN dbo.Crim cr WITH(NOLOCK) ON a.APNO = cr.APNO
	--LEFT OUTER JOIN CriminalVendor_Log cv on cr.apno = cv.apno and cr.cnty_no = cv.CNTY_NO
	INNER JOIN dbo.Client c WITH(NOLOCK) ON A.CLNO = C.CLNO
	INNER JOIN dbo.refBillingCycle rbc WITH(NOLOCK) ON rbc.BillingCycleID = c.BillingCycleID
	INNER JOIN dbo.refAffiliate ra WITH(NOLOCK) ON C.AffiliateID = ra.AffiliateID
	INNER JOIN dbo.Crimsectstat css WITH(NOLOCK) ON css.crimsect = t.[clear]
	INNER JOIN dbo.TblCounties tc WITH(NOLOCK) ON t.CNTY_NO = tc.CNTY_NO
	INNER JOIN dbo.Iris_Researchers r WITH(NOLOCK) ON t.vendorid = r.R_id
	INNER JOIN dbo.Iris_Researcher_charges rc WITH(NOLOCK) ON rc.Researcher_id = r.R_id and rc.cnty_no = t.CNTY_NO
	         --LEFT OUTER JOIN dbo.changeLog cl WITH(NOLOCK) ON cl.ID = t.CrimID AND (cl.TableName = 'Crim.Status' OR cl.TableName = 'Crim.Clear') AND (((ISNULL(cl.oldvalue,'') in('V','F','O','B')) and cl.NewValue='T') OR (cl.oldvalue IS NULL and cl.NewValue='T') OR (cl.NewValue='V'))
	WHERE
	--a.ApStatus ='F' AND 
	a.clno not in(2135,3468)
	AND t.[Clear] NOT IN('I')
	----AND t.ordered is not null and t.ordered <>''
	----AND  isdate(t.ordered) =1
	AND TRY_CAST(t.ordered as date) is not null
	
	--SELECT * FROM #tmpCrimOrdered

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
			t.DOB, t.R_Name as [Vendor Name], t.[County],t.[State], t.CrimID, t.IsHidden as [UnUsed], t.CRIM_SpecialInstr as [Crim Special Instructions], --t.Priv_Notes as [Private Notes], 
			K.QualifiedNames as [Names Selected], k.PRInvestigator,t.[Alias Allowed Count], t.Researcher_combo, t.Researcher_other,t.Researcher_CourtFees, t.[Vendor Reviewed Date], t.Crimenteredtime
	FROM #tmpCrimOrdered t (NOLOCK)
	LEFT OUTER JOIN #tmpSelectedAliases AS K(NOLOCK) ON T.CrimID = k.CrimID

END
