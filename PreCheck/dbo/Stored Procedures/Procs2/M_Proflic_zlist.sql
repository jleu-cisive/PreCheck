
/***************************************************************
	EXEC [dbo].[M_Proflic_zlist] 'HRocha','P.APNO'

	EXEC [dbo].[M_Proflic_zlist] 'aliu','P.APNO'
--Modified by AmyLiu on 08/28/2020 add 'R' excluding 'Returned for Compliance Review' along with sectstat='9' (pending) for ComplianceReinvestigation
****************************************************************/
CREATE PROCEDURE [dbo].[M_Proflic_zlist] 
(
	@investigator varchar(12)
	, @t_sortby varchar(13)
)
AS
--modified by schapyala on 051007 - fixed a syntax issue in the dynamic sql below

DECLARE @SearchSQL varchar(5000)

If (SELECT @t_sortby) = 'no'
BEGIN
	SELECT P.APNO, P.ProfLicID, P.Lic_Type, P.State,  A.ApStatus, P.web_status
		, CASE WHEN A.special_instructions IS NULL THEN 'No' ELSE 'Yes' END AS 'SI'
		, A.ApDate, A.First, A.Middle, A.Last, ref.Affiliate, P.web_updated
		, P.SectStat, substring(C.Name,0,20) as name, A.CLNO, P.time_in, P.CreatedDate, IsNull(C.OkToContact,0) as oktocontact
		, CASE WHEN X.UpdatedBy <> 'DeriveETAFromTATService' THEN CAST(X.ETADate AS DATE) END AS ETADate
	FROM dbo.ProfLic AS P(NOLOCK)
		INNER JOIN dbo.Appl AS A(NOLOCK) ON P.APNO = A.APNO
		INNER JOIN dbo.Client AS C(NOLOCK) ON A.CLNO = C.CLNO
		INNER JOIN dbo.refAffiliate AS ref(NOLOCK) ON C.AffiliateID = ref.AffiliateID
		left join dbo.SectSubStatus sss (nolock) on P.SectStat = sss.SectStatusCode and P.SectSubStatusID = sss.SectSubStatusID and sss.ApplSectionID = 4
		LEFT OUTER JOIN dbo.ApplSectionsETA AS X(NOLOCK) ON P.ProfLicID = X.SectionKeyID AND P.Apno = X.Apno AND X.ApplSectionID = 4
	WHERE A.ApStatus IN ('P','W')
		AND A.InUse IS NULL
	    AND ( P.SectStat ='9'  or (P.SectStat ='R' and isnull(sss.SectSubStatus,'') <>'Returned for Compliance Review' ) )
		--AND P.IsOnReport = 1
		AND P.Investigator = @investigator
		And P.Is_Investigator_Qualified=1
	ORDER BY A.ApDate ASC
END
If (SELECT @t_sortby) <> 'no'
BEGIN
	SET @SearchSQL = '' +
		'SELECT P.APNO, P.ProfLicID, P.Lic_Type, P.State,  A.ApStatus, P.web_status ' +
		'	, CASE WHEN A.special_instructions IS NULL THEN ''No'' ELSE ''Yes'' END AS ''SI'' ' +
		'	, A.ApDate, A.First, A.Middle, A.Last, ref.Affiliate, P.web_updated ' +
		'	, P.SectStat,  substring(C.Name,0,20) as name, A.CLNO, P.time_in, P.CreatedDate, IsNull(C.OkToContact,0) as oktocontact ' +
		'	, CASE WHEN X.UpdatedBy <> ''DeriveETAFromTATService'' THEN CAST(X.ETADate AS DATE) END AS ETADate  ' +
		'FROM dbo.ProfLic P(NOLOCK) ' +
		'	INNER JOIN dbo.Appl A(NOLOCK) ON P.APNO = A.APNO ' +
		'	INNER JOIN dbo.Client C(NOLOCK) ON A.CLNO = C.CLNO ' +
		'   INNER JOIN dbo.refAffiliate ref(NOLOCK) ON C.AffiliateID = ref.AffiliateID ' +
		'	LEFT OUTER JOIN dbo.ApplSectionsETA AS X(NOLOCK) ON P.ProfLicID = X.SectionKeyID AND P.Apno = X.Apno AND X.ApplSectionID = 4 ' +
		'	left join dbo.SectSubStatus sss (nolock) on P.SectStat = sss.SectStatusCode and P.SectSubStatusID = sss.SectSubStatusID and sss.ApplSectionID = 4 ' +
		'WHERE A.ApStatus IN (''P'',''W'') ' +
		'	AND A.InUse IS NULL ' +
		'	AND ( P.SectStat =''9''  or (P.SectStat =''R'' and isnull(sss.SectSubStatus,'''') <>''Returned for Compliance Review'' ) ) ' +
		'	And P.Is_Investigator_Qualified=1 '+
		'	AND P.Investigator = ''' + @investigator +
		''' ORDER BY ' + @t_sortby
		--'	AND P.IsOnReport = 1 ' +
	--PRINT @SearchSQL
	EXEC(@SearchSQL)
END
