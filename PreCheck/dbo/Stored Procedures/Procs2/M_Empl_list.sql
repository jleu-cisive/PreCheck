
/**********************************************************
	EXEC [M_Empl_list] 'CCLARK','TimeZone'
--Modified by AmyLiu on 08/28/2020 add 'R' excluding 'Returned for Compliance Review' along with sectstat='9' (pending) for ComplianceReinvestigation
**********************************************************/
CREATE PROCEDURE [dbo].[M_Empl_list]
(
	@investigator varchar(30)
	, @t_sortby varchar(20)
)
AS
SET NOCOUNT ON

	SELECT a.* INTO #Empl_temp FROM
		(SELECT A.APNO, A.ApDate, E.Employer, E.State, E.City, A.ApStatus, E.web_status, E.web_updated, E.Investigator, C.Name 
				, A.PrecheckChallenge, A.Rush, C.HighProfile, E.EmplID, A.First, A.Last,  A.CLNO, ref.Affiliate,  IsNull(C.OkToContact,0) as oktocontact 
				, CASE  WHEN A.special_instructions IS NULL THEN 'No' ELSE 'Yes' END AS 'SI',E.DateOrdered,E.OrderId, E.Zipcode,
				MainDB.dbo.fnGetTimeZone(E.zipcode,E.city,E.State) TimeZone, CASE WHEN X.UpdatedBy <> 'DeriveETAFromTATService' THEN X.ETADate END AS ETADate
		FROM dbo.Appl AS A(NOLOCK) 
			INNER JOIN dbo.Empl AS E(NOLOCK) ON A.APNO = E.APNO 
			INNER JOIN dbo.Client AS C(NOLOCK) ON A.CLNO = C.CLNO 
			INNER JOIN dbo.refAffiliate AS ref(NOLOCK) ON C.AffiliateID = ref.AffiliateID
			left join dbo.SectSubStatus sss (nolock) on e.SectStat = sss.SectStatusCode and e.SectSubStatusID = sss.SectSubStatusID and sss.ApplSectionID =1
			LEFT OUTER JOIN dbo.ApplSectionsETA AS X(NOLOCK) ON E.EmplID = X.SectionKeyID AND E.Apno = X.Apno AND X.ApplSectionID = 1
		WHERE A.ApStatus IN ('P','W') 
			AND E.DNC = 0 
			AND ( E.SectStat ='9'  or (E.SectStat ='R' and isnull(sss.SectSubStatus,'') <>'Returned for Compliance Review' ) )
			AND E.IsOnReport = 1 
			AND E.Investigator = @investigator
		UNION ALL
		SELECT A.APNO, A.ApDate, E.Employer, E.State, E.City, A.ApStatus, E.web_status, E.web_updated, E.Investigator, C.Name 
			, A.PrecheckChallenge, A.Rush, C.HighProfile, E.EmplID, A.First, A.Last ,A.CLNO, ref.Affiliate,  IsNull(C.OkToContact,0) as oktocontact
			, CASE  WHEN A.special_instructions IS NULL THEN 'No' ELSE 'Yes' END AS 'SI',E.DateOrdered,E.OrderId, E.Zipcode ,
			MainDB.dbo.fnGetTimeZone(E.zipcode,E.city,E.State) TimeZone, '' ETADate
		FROM dbo.Appl AS A(NOLOCK)
			INNER JOIN dbo.Empl AS E(NOLOCK) ON A.APNO = E.APNO 
			INNER JOIN dbo.Client AS C(NOLOCK) ON A.CLNO = C.CLNO 
			INNER JOIN dbo.ApplSections_Followup AS af(NOLOCK) ON e.EmplID = af.ApplSectionID and e.APNO = af.Apno and af.sectionid ='Empl'
			INNER JOIN dbo.refAffiliate AS ref(NOLOCK) ON C.AffiliateID = ref.AffiliateID
		WHERE E.IsOnReport = 1
		  AND E.Investigator = @investigator
		  AND --((af.IsCompleted is null and af.Repeat_Followup is null) or 
				(af.IsCompleted = 0 and af.Repeat_Followup = 0)
		  AND (FollowupOn <= current_timestamp)) a
	

	IF @t_sortby = 'no'
	BEGIN
		Set @t_sortby = ' ApDate ASC'
	END
	ELSE
	BEGIN
		-- below if loop is done to use sorting in sql 2005 mode
		IF CHARINDEX('.',@t_sortby)>1

		IF (@t_sortby = 'ref.Affiliate')
			SET @t_sortby = 'a.' + substring(@t_sortby,5,len(@t_sortby))
		ELSE	
			SET @t_sortby = 'a.' + substring(@t_sortby,3,len(@t_sortby))
	END
	--select @t_sortby

	EXEC ('select * from #Empl_temp a order by ' + @t_sortby)

	DROP TABLE #Empl_temp

	SET NOCOUNT OFF




