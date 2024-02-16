/***********************************************************************
[M_edu_zlist] 'CCooper ','TimeZone'
	--Modified by Santosh on 050907 to fix a sorting issue
	-- Modified by Balaji on 09282013 to fix Timeout and Deadlock issue
--Modified by AmyLiu on 08/28/2020 add 'R' excluding 'Returned for Compliance Review' along with sectstat='9' (pending) for ComplianceReinvestigation
************************************************************************/
CREATE PROCEDURE [dbo].[M_edu_zlist]
(
	@investigator varchar(30)
	, @t_sortby varchar(20)
)
AS
BEGIN
	SET NOCOUNT ON
	--Modified by Santosh on 050907 to fix a sorting issue
	-- Modified by Balaji on 09282013 to fix Timeout and Deadlock issue

	--Added by Balaji Sankar on 09282013 
	SET TRANSACTION ISOLATION LEVEL  READ UNCOMMITTED

	--Added by Balaji Sankar on 09282013 

	CREATE TABLE #Educat_temp(
		[APNO] [int] NOT NULL,
		[EducatID] [int] NOT NULL,
		[School] [varchar](100) NOT NULL,
		[State] [varchar](2) NULL,
		[Phone] [varchar](20) NULL,
		[web_updated] [datetime] NULL,
		[time_in] [datetime] NULL,
		[CreatedDate] [datetime] NULL,
		[Investigator] [varchar](30) NULL,
		[SI] [varchar](3) NOT NULL,
		[ApStatus] [char](1) NOT NULL,
		[Web_Status] [int] NULL,
		[ApDate] [datetime] NULL,
		[First] [varchar](20) NOT NULL,
		[Middle] [varchar](20) NULL,
		[Last] [varchar](20) NOT NULL,
		[SectStat] [char](1) NOT NULL,
		[Name] [varchar](100) NULL,
		[Affiliate] [nvarchar](50) NULL, --Radhika Dereddy 02/20/2014
		[CLNO] [smallint] NOT NULL,
		[OkToContact] bit NULL,
		[City] varchar(50) NULL, --Radhika Dereddy 08/07/2014
		[zipcode] char(5) NULL, --Radhika Dereddy 08/07/2014
		[TimeZone] [varchar](20) NULL, -- Deepak Vodethela 09/25/2014 for Sorting by TimeZone
		[ETADate] [datetime] NULL,
		DateOrdered [datetime] NULL,
		OrderID VARCHAR(20) NULL
	) 

	INSERT INTO #Educat_temp
	Select a.* from
	 (SELECT E.APNO, E.EducatID, E.School, E.State, E.Phone, E.web_updated, E.time_in, E.CreatedDate, E.Investigator
			, CASE WHEN a.special_instructions IS NULL THEN 'No' ELSE 'Yes' END AS 'SI'
			, A.ApStatus, E.Web_Status, A.ApDate, A.First, A.Middle, A.Last
			, E.SectStat, C.Name, ref.Affiliate, A.CLNO, IsNull(C.OkToContact,0) as oktocontact, E.City, E.Zipcode
			, MainDB.dbo.fnGetTimeZone(E.zipcode,E.city,E.State) [TimeZone]
			, CASE WHEN X.UpdatedBy <> 'DeriveETAFromTATService' THEN CAST(X.ETADate AS DATE) END AS ETADate
			, E.DateOrdered, E.OrderID
		--INTO #Educat_temp
		FROM dbo.Educat AS E(NOLOCK)
			INNER JOIN dbo.Appl AS A(NOLOCK) ON E.APNO = A.APNO
			INNER JOIN dbo.Client AS C(NOLOCK) ON A.CLNO = C.CLNO
			INNER JOIN dbo.refAffiliate AS ref(NOLOCK) ON C.AffiliateID = ref.AffiliateID
			left join dbo.SectSubStatus sss (nolock) on e.SectStat = sss.SectStatusCode and e.SectSubStatusID = sss.SectSubStatusID and sss.ApplSectionID =2
			LEFT OUTER JOIN dbo.ApplSectionsETA AS X(NOLOCK) ON E.EducatID = X.SectionKeyID AND E.Apno = X.Apno AND X.ApplSectionID = 2
			--LEFT JOIN dbo.ApplSections_Followup af ON e.EducatID = af.ApplSectionID and e.APNO = af.Apno
		WHERE A.ApStatus IN ('P','W')
			AND E.IsOnReport = 1
			AND ( E.SectStat ='9'  or (E.SectStat ='R' and isnull(sss.SectSubStatus,'') <>'Returned for Compliance Review' ) )
			AND E.Investigator = @investigator
			--AND --((af.IsCompleted is null and af.Repeat_Followup is null) or 
			--(af.IsCompleted = 0 and af.Repeat_Followup = 0)
			UNION
		SELECT E.APNO, E.EducatID, E.School, E.State, E.Phone, E.web_updated, E.time_in, E.CreatedDate, E.Investigator
			, CASE WHEN a.special_instructions IS NULL THEN 'No' ELSE 'Yes' END AS 'SI'
			, A.ApStatus, E.Web_Status, A.ApDate, A.First, A.Middle, A.Last
			, E.SectStat, C.Name, ref.Affiliate, A.CLNO, IsNull(C.OkToContact,0) as oktocontact, E.City, E.Zipcode
			, MainDB.dbo.fnGetTimeZone(E.zipcode,E.city,E.State) [TimeZone], NULL ETADate
			, E.DateOrdered, E.OrderID
		--INTO #Educat_temp
		FROM dbo.Educat E
			INNER JOIN dbo.Appl A ON E.APNO = A.APNO
			INNER JOIN dbo.Client C ON A.CLNO = C.CLNO
			INNER JOIN dbo.refAffiliate ref ON C.AffiliateID = ref.AffiliateID
			INNER JOIN dbo.ApplSections_Followup af ON e.EducatID = af.ApplSectionID and e.APNO = af.Apno  and af.sectionid ='Educat'
		WHERE --A.ApStatus IN ('P','W')
			--AND 
			E.IsOnReport = 1
			--AND E.SectStat = '9'
			AND E.Investigator = @investigator
			AND --((af.IsCompleted is null and af.Repeat_Followup is null) or 
			(af.IsCompleted = 0 and af.Repeat_Followup = 0)
			and (FollowupOn < DATEADD(d,1,CURRENT_TIMESTAMP))
			) a


	IF @t_sortby = 'no'
		SET @t_sortby = ' ApDate ASC'
	ELSE
	BEGIN
	-- below if loop is done to use sorting in sql 2005 mode
	IF CHARINDEX('.',@t_sortby)>1
	SET @t_sortby = 'a.' + substring(@t_sortby,3,len(@t_sortby))
	END
	--select @t_sortby
	EXEC ('select * from #Educat_temp a order by ' + @t_sortby)

	DROP TABLE #Educat_temp;
END;

	-- online education module JS
	--DECLARE @SearchSQL varchar(5000)
	--IF (select @t_sortby) = 'no'
	--BEGIN
	--	SELECT E.APNO, E.EducatID, E.School, E.State, E.Phone, E.web_updated, E.time_in, E.CreatedDate, E.Investigator
	--		, CASE WHEN a.special_instructions IS NULL THEN 'No' ELSE 'Yes' END AS 'SI'
	--		, A.ApStatus, E.Web_Status, A.ApDate, A.First, A.Middle, A.Last
	--		, E.SectStat, C.Name
	--	FROM dbo.Educat E
	--		INNER JOIN dbo.Appl A ON E.APNO = A.APNO
	--		INNER JOIN dbo.Client C ON A.CLNO = C.CLNO
	--	WHERE A.ApStatus IN ('P','W')
	--		--AND E.IsOnReport = 1
	--		AND E.SectStat = '9'
	--		AND E.Investigator = @investigator
	--	ORDER BY A.ApDate ASC
	--END
	--
	--IF (select @t_sortby) <> 'no'
	--BEGIN
	--	SET @searchsql = '' +
	--		'SELECT E.APNO, E.EducatID, E.School, E.State, E.Phone, E.web_updated, E.time_in, E.CreatedDate, E.Investigator ' +
	--		'	, CASE WHEN a.special_instructions IS NULL THEN ''No'' ELSE ''Yes'' END AS ''SI'' ' +
	--		'	, A.ApStatus, E.Web_Status, A.ApDate, A.First, A.Middle, A.Last ' +
	--		'	, E.SectStat, C.Name ' +
	--		'FROM dbo.Educat E ' +
	--		'	INNER JOIN dbo.Appl A ON E.APNO = A.APNO ' +
	--		'	INNER JOIN dbo.Client C ON A.CLNO = C.CLNO ' + 
	--		'WHERE A.ApStatus IN (''P'',''W'') ' + 
	--		'	AND E.SectStat = ''9'' ' + 
	--		'	AND E.Investigator = ''' + @investigator + ''''+
	--		' ORDER BY ' + @t_sortby
	--
	--		--'	AND E.IsOnReport = 1 ' + 
	--print @searchsql
	--	EXEC(@SearchSQL)
	--END

	--GO


	--SET NOCOUNT ON

