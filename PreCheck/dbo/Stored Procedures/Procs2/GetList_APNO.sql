--/******************************************************************************************************
-- DOug - 04/13/2020 , 'D' status was missing in Crim status search, added to make this match up with the numbers of the Cam Activity Report ticket #70980
-- EXEC [GetList_APNO] 1,'To Be Final','','','','ALL','All'
-- Modified by AmyLiu: for task 496:ZipCrim related changes in OASIS on 09/17/2020
-- Modified By:		Joshua Ates
-- Modified Date:	03/02/2021
-- Description:		Moved subqueries in select statments to left joins.  Changed all IN () to X = Y.  Formatted query to be more readable.  Removed index creation as that was adding unneeded insert time.
--WARNING:  The dynamic SQL poses a security risk for SQL injection should this ever be run manually or if users can type in information for column name. 
--Also dynamic queries are marked as adhoc and plans not stored so long runtimes of dynamic queries can be hard to troubleshoot. 
--I have a query that replaces the dynamic content and keeps all functionality; however, it increases the run time by about 50 seconds.
--******************************************************************************************************/

CREATE PROCEDURE [dbo].[GetList_APNO]
(
	  @IsCAM bit = 0
	, @QueueType varchar(20) = 'In Progress'
	, @SearchField varchar(20) = ''
	, @SearchOperator Varchar(20) = ''
	, @SearchCriteria Varchar(100) = ''
	, @RecordLimit varchar(20) = ''
	, @EnteredBy varchar(20) = ''
)
AS

/* Test Variables

DECLARE
	 @IsCAM bit = 1
	,@QueueType varchar(20) = 'To Be Final'
	,@SearchField varchar(20) = ''
	,@SearchOperator Varchar(20) = ''
	,@SearchCriteria Varchar(100) = ''
	,@RecordLimit varchar(20) = 'ALL'
	,@EnteredBy varchar(20) = 'All'

*/
DROP TABLE IF EXISTS #tmpAppl

IF @QueueType = 'All'
BEGIN 
	Declare @SQL nVarchar(max)

	IF @RecordLimit <> '' AND @RecordLimit <> 'All'
		SET @SQl = 'SELECT distinct TOP ' + @RecordLimit
	ELSE
		SET @SQL = 'SELECT distinct '
	IF @SearchField = 'Name'
	BEGIN

	SET @SQL = @SQL + ' A.Investigator,A.ApStatus,A.APNO, A.ApDate, A.ReopenDate, DATEDIFF(day, A.ApDate, getdate()) AS ElapseDays, A.SSN, A.Last, A.First, C.Name AS ClientName, A.UserID AS ClientCAM,isnull(AAD2.Crim_SelfDisclosed,isnull(AAD.Crim_SelfDisclosed,0)) Crim_SelfDisclosed, isnull(A.InProgressReviewed,0) InProgressReviewed
						,isnull(z.PartnerReference,'''') AS [CaseNumber], w.WorkOrderID
			FROM dbo.Appl A (NOLOCK) 
			LEFT OUTER JOIN dbo.ApplAdditionalData AAD with (Nolock) ON ( (A.CLNO = AAD.CLNO AND  A.SSN = AAD.SSN AND AAD.SSN IS NOT NULL ))
			LEFT OUTER JOIN dbo.ApplAdditionalData AAD2 with (Nolock) ON (A.APNO = AAD2.APNO AND  AAD2.APNO IS NOT NULL)
			INNER JOIN dbo.Client C (NOLOCK) ON A.CLNO = C.CLNO	
			LEFT JOIN dbo.ZipCrimWorkOrders w on a.apno = w.apno
			LEFT JOIN dbo.ZipCrimWorkOrdersStaging z on z.WorkOrderID = w.WorkOrderID 
			WHERE isnull(A.first,'''') + '' '' + isnull(A.Last,'''') =  ''' + @SearchCriteria + ''''
	END
	ELSE
	BEGIN
		SET @SQL = @SQL + ' A.Investigator,A.ApStatus,A.APNO, A.ApDate, A.ReopenDate, DATEDIFF(day, A.ApDate, getdate()) AS ElapseDays, A.SSN, A.Last, A.First, C.Name AS ClientName, A.UserID AS ClientCAM,isnull(AAD2.Crim_SelfDisclosed,isnull(AAD.Crim_SelfDisclosed,0)) Crim_SelfDisclosed, isnull(A.InProgressReviewed,0) InProgressReviewed
						,isnull(z.PartnerReference,'''') AS [CaseNumber], w.WorkOrderID
			FROM dbo.Appl A (NOLOCK) 
			LEFT OUTER JOIN dbo.ApplAdditionalData AAD with (Nolock) ON ( (A.CLNO = AAD.CLNO AND  A.SSN = AAD.SSN AND AAD.SSN IS NOT NULL ))
			LEFT OUTER JOIN dbo.ApplAdditionalData AAD2 with (Nolock) ON (A.APNO = AAD2.APNO AND  AAD2.APNO IS NOT NULL)
			INNER JOIN dbo.Client C (NOLOCK) ON A.CLNO = C.CLNO	
			LEFT JOIN dbo.ZipCrimWorkOrders w on a.apno = w.apno
			LEFT JOIN dbo.ZipCrimWorkOrdersStaging z on z.WorkOrderID = w.WorkOrderID '
			--AmyLiu modified to avoid syntax error on 09/16/2020 
		if isnull(@SearchField,'')<>''
			SET @SQL = @SQL + ' WHERE ' + @SearchField 
	

		IF @SearchField = 'A.DOB'
			SET @SQL = @SQL + '= ''' + @SearchCriteria + ''''   
		ELSE IF  @SearchOperator = 'Begins With'
			SET @SQL = @SQL + ' Like ''' + @SearchCriteria + '%'''
		ELSE IF  @SearchOperator = 'Contains'
			SET @SQL = @SQL + ' Like ''%' + @SearchCriteria + '%'''
		ELSE IF  @SearchOperator = 'Ends With'
			SET @SQL = @SQL + ' Like ''%' + @SearchCriteria + ''''
		ELSE IF  @SearchOperator = 'Is Equal To'
			SET @SQL = @SQL + '= ''' + @SearchCriteria + ''''	
		ELSE IF  @SearchOperator = 'Is Greater Than'
			SET @SQL = @SQL + '> ''' + @SearchCriteria + ''''	
		ELSE IF  @SearchOperator = 'Is Less Than'
			SET @SQL = @SQL + '< ''' + @SearchCriteria + ''''
	END

	IF @EnteredBy <> '' AND @EnteredBy <> 'All'
		SET @SQL = @SQL + ' AND EnteredVia = ''' + @EnteredBy + ''''

    SET @SQL = @SQL + ' order by A.apno DESC'
	Exec(@SQL)
END

ELSE IF @QueueType = 'Followup items'
BEGIN
	SELECT distinct 
		 A.Investigator
		,A.ApStatus
		,A.APNO
		,A.ApDate
		,A.ReopenDate
		,DATEDIFF(day, A.ApDate, getdate()) AS ElapseDays
		,A.SSN
		,A.Last
		,A.First
		,C.Name AS ClientName
		,A.UserID AS ClientCAM
		,isnull(AAD2.Crim_SelfDisclosed,isnull(AAD.Crim_SelfDisclosed,0)) Crim_SelfDisclosed
		,GetNextDate
		,isnull(A.InProgressReviewed,0) InProgressReviewed
		,isnull(z.PartnerReference,'') AS [CaseNumber], w.WorkOrderID
	FROM dbo.Appl A (NOLOCK) 
		LEFT OUTER JOIN dbo.ApplAdditionalData AAD with (Nolock) ON ( (A.CLNO = AAD.CLNO AND  A.SSN = AAD.SSN AND AAD.SSN IS NOT NULL ))
		LEFT OUTER JOIN dbo.ApplAdditionalData AAD2 with (Nolock) ON (A.APNO = AAD2.APNO AND  AAD2.APNO IS NOT NULL)
		INNER JOIN dbo.Client C (NOLOCK) ON A.CLNO = C.CLNO
		LEFT JOIN dbo.ZipCrimWorkOrders w on w.APNO = a.APNO
		LEFT JOIN dbo.ZipCrimWorkOrdersStaging z ON z.WorkOrderID = w.WorkOrderID
	WHERE GetNextDate is not null  
	ORDER BY GetNextDate
END

ELSE IF @IsCAM = 1
BEGIN
	
--schapyala created a temp table to prevent the repeated queries below - 07/15/14
	SELECT 
		 A.Investigator
		,a.CLNO
		,A.ApStatus
		,A.APNO
		,A.ApDate
		,A.ReopenDate
		,DATEDIFF(day, A.ApDate, getdate()) AS ElapseDays
		,A.SSN
		,A.Last
		,A.First
		,C.Name AS ClientName
		,A.UserID AS ClientCAM
		,SentPending
		,isnull(AAD2.Crim_SelfDisclosed,isnull(AAD.Crim_SelfDisclosed,0)) Crim_SelfDisclosed
		,isnull(cc.value,'False') SmartStatusClient
		,isnull(empl.cnt,0) emplPendingCount
		,isnull(Educat.cnt,0)  EducatPendingCount
		,isnull(PersRef.cnt,0)  PersRefPendingCount
		,isnull(ProfLic.cnt,0)  ProfLicPendingCount
		,isnull(PID.cnt,0)  PIDPendingCount
		,isnull(MedInteg.cnt,0)  MedIntegPendingCount
		,isnull(Crim.cnt,0)  CrimPendingCount
		,isnull(CCredit.cnt,0)  CCreditPendingCount
		,isnull(DL.cnt,0)  DLPendingCount
		,isnull(A.InProgressReviewed,0) InProgressReviewed
		,isnull(z.PartnerReference,'') AS [CaseNumber]
		,w.WorkOrderID
	INTO #tmpAppl
	FROM 
		dbo.Appl A with (nolock)  
	INNER JOIN 
		dbo.Client C with (nolock)  
		ON A.CLNO = C.CLNO
	   LEFT JOIN 
		(
			SELECT COUNT(1) cnt,APNO 
			FROM dbo.Empl with (nolock)   
			WHERE 
				(SectStat = '0' OR  SectStat = '9' ) --Removing in statments to this reduced run time by over half
			AND IsOnReport = 1 
			AND Ishidden = 0 
			Group by Apno
		) Empl 
		on A.APNO = Empl.APNO
	   LEFT JOIN 
		(
			SELECT COUNT(1) cnt,APNO 
			FROM dbo.Educat  with (nolock)   
			WHERE 
				(SectStat = '0' OR  SectStat = '9' ) --Removing in statments to this reduced run time by over half
			AND IsOnReport = 1 
			AND Ishidden = 0 
			Group by Apno
		) Educat 
		on A.APNO = Educat.APNO
	   LEFT JOIN 
		(
			SELECT COUNT(1) cnt,APNO 
			FROM dbo.PersRef with (nolock)   
			WHERE
				(SectStat = '0' OR  SectStat = '9' ) --Removing in statments to this reduced run time by over half
			AND IsOnReport = 1 
			AND Ishidden = 0 
			Group by Apno
		) PersRef 
		on A.APNO = PersRef.APNO
	   LEFT JOIN 
		(
			SELECT COUNT(1) cnt,APNO 
			FROM dbo.ProfLic  with (nolock)  
			WHERE  
				(SectStat = '0' OR  SectStat = '9' ) --Removing in statments to this reduced run time by over half
			AND IsOnReport = 1 
			AND Ishidden = 0 
			Group by Apno
		) ProfLic 
		on A.APNO = ProfLic.APNO
	   LEFT JOIN 
		(
			SELECT COUNT(1) cnt,APNO 
			FROM dbo.Credit  with (nolock)  
			WHERE 
				(SectStat = '0' OR  SectStat = '9' ) --Removing in statments to this reduced run time by over half
			AND reptype ='S' 
			AND Ishidden = 0 
			Group by Apno
		) PID on A.APNO = PID.APNO
	   LEFT JOIN 
		(
			SELECT COUNT(1) cnt,APNO 
			FROM dbo.Credit  with (nolock)   
			WHERE
				(SectStat = '0' OR  SectStat = '9' ) --Removing in statments to this reduced run time by over half
			AND reptype ='C' 
			AND Ishidden = 0 
			Group by Apno
		) CCredit 
		on A.APNO = CCredit.APNO
	   LEFT JOIN 
		(
			SELECT COUNT(1) cnt,APNO 
			FROM dbo.MedInteg with (nolock)  
			WHERE 
				(SectStat = '0' OR  SectStat = '9' ) --Removing in statments to this reduced run time by over half
			AND Ishidden = 0 
			Group by Apno
		) MedInteg 
		on A.APNO = MedInteg.APNO
	   LEFT JOIN 
		(
			SELECT COUNT(1) cnt,APNO 
			FROM dbo.DL      with (nolock)   
			WHERE
				(SectStat = '0' OR  SectStat = '9' ) --Removing in statments to this reduced run time by over half
			AND Ishidden = 0 
			Group by Apno
		) DL 
		on A.APNO = DL.APNO
	   LEFT JOIN 
		(
			SELECT COUNT(1) cnt,APNO 
			FROM dbo.Crim	 with (nolock)   
			WHERE 
				(Clear IS NULL 
			OR	Clear = 'R'
			OR	Clear = 'M'
			OR	Clear = 'O'
			OR	Clear = 'V'
			OR	Clear = 'W'
			OR	Clear = 'X'
			OR	Clear = 'E'
			OR	Clear = 'N'
			OR	Clear = 'I'
			OR	Clear = 'Q'
			OR	Clear = 'Z') --Removing in statments to this reduced run time by over half
			AND ishidden = 0 
			Group by Apno
		) Crim 
		on A.APNO = Crim.APNO
	LEFT OUTER JOIN 
		dbo.ApplAdditionalData AAD with (Nolock) 
		ON	A.CLNO = AAD.CLNO 
		AND A.SSN = AAD.SSN 
		AND AAD.SSN IS NOT NULL 
	LEFT OUTER JOIN 
		dbo.ApplAdditionalData AAD2 with (Nolock) 
		ON	A.APNO = AAD2.APNO 
		AND AAD2.APNO IS NOT NULL	
	LEFT JOIN 
		clientconfiguration cc with (Nolock) 
		ON	c.clno = cc.clno 
		AND cc.configurationkey = 'OASIS_InProgressStatus'	
	LEFT JOIN 
		dbo.ZipCrimWorkOrders w 
		on w.APNO = a.APNO
	LEFT JOIN 
		dbo.ZipCrimWorkOrdersStaging z 
		ON z.WorkOrderID = w.WorkOrderID
	LEFT JOIN
		(
			SELECT apno, max(activitydate) AS SentPending 
			FROM applactivity WITH(NOLOCK)
			WHERE activitycode  = 2
			GROUP BY apno
		 ) MaxSentPending
		 ON  MaxSentPending.apno = a.apno
	WHERE 
		(A.ApStatus = 'P' OR A.ApStatus = 'W')
	AND Isnull(A.Investigator, '') <> ''
	AND A.userid IS NOT null
	--AND   Isnull(A.CAM, '') = '' -- Humera Ahmed on 8/16/2019 for HDT#56758
	AND IsNull(c.clienttypeid,-1) <> 15

	/* Incase it is needed in the future

		CREATE NONCLUSTERED INDEX IX_tmpAppl_ApStatus_SmartStatusClient
		ON [dbo].[#tmpAppl] ([ApStatus],[SmartStatusClient],[ProfLicPendingCount],[PIDPendingCount],[MedIntegPendingCount],[CrimPendingCount])
		INCLUDE ([Investigator],[APNO],[ApDate],[ReopenDate],[ElapseDays],[SSN],[Last],[First],[ClientName],[ClientCAM],[SentPending],[Crim_SelfDisclosed],[emplPendingCount],[EducatPendingCount],[PersRefPendingCount],[CCreditPendingCount],[DLPendingCount],[InProgressReviewed], [CaseNumber], [WorkOrderID])

	*/




	IF @QueueType = 'In Progress'
	BEGIN
		SELECT DISTINCT 
			 A.Investigator
			,A.ApStatus
			,A.APNO
			,A.ApDate
			,A.ReopenDate
			,DATEDIFF(day, A.ApDate, getdate()) AS ElapseDays
			,A.SSN
			,A.Last
			,A.First
			,C.Name AS ClientName
			,A.UserID AS ClientCAM
			,case 
				when a.apstatus = 'W' then 2 
				else 0 
			 end as Available
			,MAXSentPending AS SentPending
			,isnull(AAD2.Crim_SelfDisclosed
			,isnull(AAD.Crim_SelfDisclosed,0)) Crim_SelfDisclosed
			,isnull(A.InProgressReviewed,0) InProgressReviewed
			,isnull(z.PartnerReference,'') AS [CaseNumber]
			,w.WorkOrderID
		FROM dbo.Appl A with (nolock) 
		INNER JOIN 
			dbo.Client C with (nolock) ON A.CLNO = C.CLNO
		LEFT OUTER JOIN 
			dbo.ApplAdditionalData AAD with (Nolock) ON ( (A.CLNO = AAD.CLNO AND  A.SSN = AAD.SSN AND AAD.SSN IS NOT NULL ))
		LEFT OUTER JOIN
			dbo.ApplAdditionalData AAD2 with (Nolock) ON (A.APNO = AAD2.APNO AND  AAD2.APNO IS NOT NULL)
		LEFT JOIN 
			(
				SELECT COUNT(1) cnt,APNO 
				FROM dbo.Empl    with (nolock)  
				WHERE (SectStat = '0' OR  SectStat = '9' )
				AND IsOnReport = 1 
				Group by Apno) Empl on A.APNO = Empl.APNO
		LEFT JOIN 
			(
				SELECT COUNT(1) cnt,APNO 
				FROM dbo.Educat  with (nolock) 
				WHERE (SectStat = '0' OR  SectStat = '9' )
				AND IsOnReport = 1 
				Group by Apno) Educat on A.APNO = Educat.APNO
		LEFT JOIN 
			(
				SELECT COUNT(1) cnt,APNO 
				FROM dbo.PersRef with (nolock)  
				WHERE (SectStat = '0' OR  SectStat = '9' )
				AND IsOnReport = 1 
				Group by Apno) PersRef on A.APNO = PersRef.APNO
		LEFT JOIN 
			(
				SELECT COUNT(1) cnt,APNO 
				FROM dbo.ProfLic with (nolock) 
				WHERE (SectStat = '0' OR  SectStat = '9' )
				AND IsOnReport = 1 
				Group by Apno) ProfLic on A.APNO = ProfLic.APNO
		LEFT JOIN 
			(
				SELECT COUNT(1) cnt,APNO 
				FROM dbo.Credit  with (nolock) 
				WHERE (SectStat = '0' OR  SectStat = '9' )
				Group by Apno) Credit on A.APNO = Credit.APNO
		LEFT JOIN 
			(
				SELECT COUNT(1) cnt,APNO 
				FROM dbo.MedInteg with (nolock) 
				WHERE (SectStat = '0' OR  SectStat = '9' )
				Group by Apno) MedInteg on A.APNO = MedInteg.APNO
		LEFT JOIN 
			(	
				SELECT COUNT(1) cnt,APNO 
				FROM dbo.DL      with (nolock) 
				WHERE (SectStat = '0' OR  SectStat = '9' )
				Group by Apno
			) DL 
			on A.APNO = DL.APNO
		LEFT JOIN 
			(
				SELECT COUNT(1) cnt,APNO 
				FROM dbo.Crim	with (nolock)  
				WHERE (
						Clear IS NULL 
						OR	Clear	=	'R' 
						OR	Clear	=	'M'
						OR	Clear	=	'O'
						OR	Clear	=	'V'
						OR	Clear	=	'W'
						OR	Clear	=	'X'
						OR	Clear	=	'E'
						OR	Clear	=	'N'
						OR	Clear	=	'I'
						OR	Clear	=	'Q'
						OR	Clear	=	'D' --Added 'D' to statuses
					 )
				Group by Apno
			) Crim 
			ON A.APNO = Crim.APNO
		LEFT JOIN 
			dbo.ZipCrimWorkOrders w 
			on w.APNO = a.APNO
		LEFT JOIN 
			dbo.ZipCrimWorkOrdersStaging z 
			ON z.WorkOrderID = w.WorkOrderID
		LEFT JOIN
				(
					SELECT APNO, max(activitydate) AS MAXSentPending
					FROM applactivity 
					WHERE activitycode  = 2 
					GROUP BY APNO
				) AS SentPending
				ON SentPending.APNO = a.APNO
		WHERE (A.ApStatus = 'P' OR A.ApStatus = 'P')
		AND   Isnull(A.Investigator, '') <> ''
		AND A.userid IS NOT NULL
		AND   Isnull(A.CAM, '') = ''
		AND  (Isnull(Empl.Cnt,0) > 0
		OR    Isnull(Educat.Cnt,0) > 0
		OR    Isnull(PersRef.Cnt,0) > 0
		OR    Isnull(ProfLic.Cnt,0) > 0
		OR    Isnull(Credit.Cnt,0) > 0
		OR    Isnull(MedInteg.Cnt,0) > 0
		OR    Isnull(DL.Cnt,0) > 0
		OR    Isnull(Crim.Cnt,0) > 0
		OR  ISNULL(a.EnteredVia,'')='ZipCrim' or c.AffiliateID =249
		)
		AND IsNull(c.clienttypeid,-1) <> 15

		

	END
	ELSE IF @QueueType = 'To Be Final'
	BEGIN
		Select distinct 
			 A.Investigator
			,A.ApStatus
			,A.APNO
			,A.ApDate
			,A.ReopenDate
			,A.ElapseDays
			,A.SSN
			,A.Last
			,A.First
			,A.ClientName
			,A.ClientCAM
			,case 
				when a.apstatus = 'W' then 2 
				else 0 
			 end as Available
			,A.SentPending
			,A.Crim_SelfDisclosed
			,isnull(A.InProgressReviewed,0) InProgressReviewed
			,CaseNumber
			,WorkOrderID	
		From #tmpAppl A
		Where (A.ApStatus = 'P' OR A.ApStatus = 'W')
		AND   emplPendingCount = 0
		AND   EducatPendingCount = 0
		AND   PersRefPendingCount=0
		AND   CCreditPendingCount = 0
		AND   DLPendingCount = 0
		AND   ProfLicPendingCount = 0
		AND   PIDPendingCount = 0
		AND   MedIntegPendingCount = 0
		AND   CrimPendingCount = 0
		UNION ALL
		Select distinct 
			 A.Investigator
			,A.ApStatus
			,A.APNO
			,A.ApDate
			,A.ReopenDate
			,A.ElapseDays
			,A.SSN
			,A.Last
			,A.First
			,A.ClientName
			,A.ClientCAM
			,1 as Available
			, A.SentPending
			,A.Crim_SelfDisclosed
			,isnull(A.InProgressReviewed,0) InProgressReviewed
			,CaseNumber
			,WorkOrderID	
		FROM #tmpAppl A
		WHERE A.ApStatus = 'P'
		AND   SmartStatusClient = 'True'
		AND	(
				emplPendingCount > 0
				OR   EducatPendingCount > 0
				OR   PersRefPendingCount>0
				OR   CCreditPendingCount > 0
				OR   DLPendingCount > 0
			)
		AND   ProfLicPendingCount = 0
		AND   PIDPendingCount = 0
		AND   MedIntegPendingCount = 0
		AND   CrimPendingCount = 0
		ORDER BY available desc,A.apno
	
	
	END
    ELSE IF @QueueType = 'Both'
	BEGIN
        SELECT distinct 
			A.Investigator
			,A.ApStatus
			,A.APNO
			,A.ApDate
			,A.ReopenDate
			,DATEDIFF(day, A.ApDate, getdate()) AS ElapseDays
			,A.SSN
			,A.Last
			,A.First
			,C.Name AS ClientName
			,A.UserID AS ClientCAM
			,isnull(AAD2.Crim_SelfDisclosed
			,isnull(AAD.Crim_SelfDisclosed,0)) Crim_SelfDisclosed
			,isnull(A.InProgressReviewed,0) InProgressReviewed
			,isnull(z.PartnerReference,'') AS [CaseNumber], w.WorkOrderID	
		FROM dbo.Appl A (NOLOCK) 
		INNER JOIN 
			dbo.Client C (NOLOCK) 
			ON A.CLNO = C.CLNO
		LEFT OUTER JOIN 
			dbo.ApplAdditionalData AAD with (Nolock) 
			ON  A.CLNO = AAD.CLNO 
			AND A.SSN = AAD.SSN 
			AND AAD.SSN IS NOT NULL
		LEFT OUTER JOIN 
			dbo.ApplAdditionalData AAD2 with (Nolock) 
			ON (A.APNO = AAD2.APNO AND  AAD2.APNO IS NOT NULL)
		INNER JOIN dbo.SubStatus SS (NOLOCK) 
			ON ISNULL(A.SubStatusID, 1) = SS.SubStatusID
			AND SS.MainStatusID = 3	--investigator review
		LEFT JOIN 
			dbo.ZipCrimWorkOrders w 
			on a.apno = w.apno
		LEFT JOIN 
			dbo.ZipCrimWorkOrdersStaging z 
			on z.WorkOrderID = w.WorkOrderID
		WHERE A.ApStatus = 'P'
		AND   ISNULL(A.Investigator, '') <> ''
		AND   ISNULL(A.CAM, '') = ''
		
	END
	Else IF @QueueType = 'UnAssigned'
	BEGIN
        SELECT DISTINCT 
			 A.Investigator
			,A.ApStatus
			,A.APNO
			,A.ApDate
			,A.ReopenDate
			,DATEDIFF(day, A.ApDate, getdate()) AS ElapseDays
			,A.SSN
			,A.Last
			,A.First
			,C.Name AS ClientName
			,A.UserID AS ClientCAM
			,isnull(AAD2.Crim_SelfDisclosed,isnull(AAD.Crim_SelfDisclosed,0)) Crim_SelfDisclosed
			,isnull(A.InProgressReviewed,0) InProgressReviewed
			,isnull(z.PartnerReference,'') AS [CaseNumber]
			,w.WorkOrderID		
		FROM dbo.Appl A (NOLOCK) 
			INNER JOIN 
				dbo.Client C (NOLOCK) 
				ON A.CLNO = C.CLNO	
			LEFT OUTER JOIN 
				dbo.ApplAdditionalData AAD with (Nolock) 
				ON A.CLNO = AAD.CLNO 
				AND  A.SSN = AAD.SSN 
				AND AAD.SSN IS NOT NULL
			LEFT OUTER JOIN 
				dbo.ApplAdditionalData AAD2 with (Nolock) 
				ON A.APNO = AAD2.APNO 
				AND  AAD2.APNO IS NOT NULL
			LEFT JOIN
				dbo.ZipCrimWorkOrders w 
				ON a.apno = w.apno
			LEFT JOIN 
				dbo.ZipCrimWorkOrdersStaging z 
				ON z.WorkOrderID = w.WorkOrderID
		WHERE A.ApStatus = 'P'
		AND   ISNULL(C.CAM, '') = ''	
	END
END

ELSE 
BEGIN
	SELECT DISTINCT 
		 A.Investigator
		,A.ApStatus
		,A.APNO
		,A.ApDate
		,A.ReopenDate
		,DATEDIFF(day, A.ApDate, getdate()) AS ElapseDays
		,A.SSN
		,A.Last
		,A.First
		,C.Name AS ClientName
		,A.UserID AS ClientCAM
		,isnull(AAD2.Crim_SelfDisclosed,isnull(AAD.Crim_SelfDisclosed,0)) AS Crim_SelfDisclosed
		,isnull(A.InProgressReviewed,0) AS InProgressReviewed
		,isnull(z.PartnerReference,'') AS [CaseNumber], w.WorkOrderID
	FROM dbo.Appl A (NOLOCK) 
	INNER JOIN 
		dbo.Client C (NOLOCK) 
		ON A.CLNO = C.CLNO	
	LEFT OUTER JOIN 
		dbo.ApplAdditionalData AAD with (Nolock) 
		ON A.CLNO = AAD.CLNO 
		AND  A.SSN = AAD.SSN 
		AND AAD.SSN IS NOT NULL 
	LEFT OUTER JOIN 
		dbo.ApplAdditionalData AAD2 with (Nolock) 
		ON A.APNO = AAD2.APNO 
		AND  AAD2.APNO IS NOT NULL
	LEFT JOIN 
		dbo.ZipCrimWorkOrders w 
		on a.apno = w.apno
	LEFT JOIN 
		dbo.ZipCrimWorkOrdersStaging z 
		on z.WorkOrderID = w.WorkOrderID
	WHERE A.ApStatus = 'P'
	AND   ISNULL(A.Investigator, '') = ''	
END

SET NOCOUNT OFF


