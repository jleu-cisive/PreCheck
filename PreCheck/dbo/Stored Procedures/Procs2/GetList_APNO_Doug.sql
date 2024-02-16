
--[GetList_APNO] 1,'To Be Final','','','','ALL','All'

CREATE PROCEDURE [dbo].[GetList_APNO_Doug]
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
SET NOCOUNT ON

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
			FROM dbo.Appl A (NOLOCK) 
			LEFT OUTER JOIN dbo.ApplAdditionalData AAD with (Nolock) ON ( (A.CLNO = AAD.CLNO AND  A.SSN = AAD.SSN AND AAD.SSN IS NOT NULL ))
			LEFT OUTER JOIN dbo.ApplAdditionalData AAD2 with (Nolock) ON (A.APNO = AAD2.APNO AND  AAD2.APNO IS NOT NULL)
			INNER JOIN dbo.Client C (NOLOCK) ON A.CLNO = C.CLNO	
			WHERE isnull(A.first,'''') + '' '' + isnull(A.Last,'''') =  ''' + @SearchCriteria + ''''
	END
	ELSE
	BEGIN
	
	SET @SQL = @SQL + ' A.Investigator,A.ApStatus,A.APNO, A.ApDate, A.ReopenDate, DATEDIFF(day, A.ApDate, getdate()) AS ElapseDays, A.SSN, A.Last, A.First, C.Name AS ClientName, A.UserID AS ClientCAM,isnull(AAD2.Crim_SelfDisclosed,isnull(AAD.Crim_SelfDisclosed,0)) Crim_SelfDisclosed, isnull(A.InProgressReviewed,0) InProgressReviewed
			FROM dbo.Appl A (NOLOCK) 
			LEFT OUTER JOIN dbo.ApplAdditionalData AAD with (Nolock) ON ( (A.CLNO = AAD.CLNO AND  A.SSN = AAD.SSN AND AAD.SSN IS NOT NULL ))
			LEFT OUTER JOIN dbo.ApplAdditionalData AAD2 with (Nolock) ON (A.APNO = AAD2.APNO AND  AAD2.APNO IS NOT NULL)
			INNER JOIN dbo.Client C (NOLOCK) ON A.CLNO = C.CLNO	
			WHERE ' + @SearchField 
	

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
	print @sql
	Exec(@SQL)
END
Else IF @QueueType = 'Followup items'
BEGIN
	SELECT distinct A.Investigator,A.ApStatus,A.APNO, A.ApDate, A.ReopenDate, DATEDIFF(day, A.ApDate, getdate()) AS ElapseDays, A.SSN, A.Last, A.First, C.Name AS ClientName, A.UserID AS ClientCAM,isnull(AAD2.Crim_SelfDisclosed,isnull(AAD.Crim_SelfDisclosed,0)) Crim_SelfDisclosed,GetNextDate, isnull(A.InProgressReviewed,0) InProgressReviewed
	FROM dbo.Appl A (NOLOCK) 
		LEFT OUTER JOIN dbo.ApplAdditionalData AAD with (Nolock) ON ( (A.CLNO = AAD.CLNO AND  A.SSN = AAD.SSN AND AAD.SSN IS NOT NULL ))
		LEFT OUTER JOIN dbo.ApplAdditionalData AAD2 with (Nolock) ON (A.APNO = AAD2.APNO AND  AAD2.APNO IS NOT NULL)
		INNER JOIN dbo.Client C (NOLOCK) ON A.CLNO = C.CLNO
	WHERE GetNextDate is not null  
	ORDER BY GetNextDate
END
Else IF @IsCAM = 1
BEGIN
--schapyala created a temp table to prevent the repeated queries below - 07/15/14
		SELECT distinct A.Investigator,a.CLNO,A.ApStatus,A.APNO, A.ApDate, A.ReopenDate, DATEDIFF(day, A.ApDate, getdate()) AS ElapseDays, A.SSN, A.Last, A.First, C.Name AS ClientName, A.UserID AS ClientCAM, 
		(select max(activitydate) from applactivity where apno = a.apno and activitycode  = 2)  SentPending,isnull(AAD2.Crim_SelfDisclosed,isnull(AAD.Crim_SelfDisclosed,0)) Crim_SelfDisclosed,isnull(cc.value,'False') SmartStatusClient,
		isnull(empl.cnt,0) emplPendingCount,isnull(Educat.cnt,0)  EducatPendingCount,isnull(PersRef.cnt,0)  PersRefPendingCount,isnull(ProfLic.cnt,0)  ProfLicPendingCount,
		isnull(PID.cnt,0)  PIDPendingCount,isnull(MedInteg.cnt,0)  MedIntegPendingCount,isnull(Crim.cnt,0)  CrimPendingCount,
		isnull(CCredit.cnt,0)  CCreditPendingCount,isnull(DL.cnt,0)  DLPendingCount, isnull(A.InProgressReviewed,0) InProgressReviewed
		into #tmpAppl
		FROM dbo.Appl A with (nolock)  
			INNER JOIN dbo.Client C with (nolock)  ON A.CLNO = C.CLNO
		    LEFT JOIN (SELECT COUNT(1) cnt,APNO FROM dbo.Empl    with (nolock)   WHERE SectStat IN ('0','9') AND IsOnReport = 1 AND Ishidden = 0 Group by Apno) Empl on A.APNO = Empl.APNO
		    LEFT JOIN (SELECT COUNT(1) cnt,APNO FROM dbo.Educat  with (nolock)   WHERE SectStat IN ('0','9') AND IsOnReport = 1 AND Ishidden = 0 Group by Apno) Educat on A.APNO = Educat.APNO
		    LEFT JOIN (SELECT COUNT(1) cnt,APNO FROM dbo.PersRef with (nolock)   WHERE SectStat IN ('0','9') AND IsOnReport = 1 AND Ishidden = 0 Group by Apno) PersRef on A.APNO = PersRef.APNO
		    LEFT JOIN (SELECT COUNT(1) cnt,APNO FROM dbo.ProfLic  with (nolock)  WHERE SectStat IN ('0','9') AND IsOnReport = 1 AND Ishidden = 0 Group by Apno) ProfLic on A.APNO = ProfLic.APNO
		    LEFT JOIN (SELECT COUNT(1) cnt,APNO FROM dbo.Credit  with (nolock)   WHERE SectStat IN ('0','9') AND reptype ='S' AND Ishidden = 0 Group by Apno) PID on A.APNO = PID.APNO
		    LEFT JOIN (SELECT COUNT(1) cnt,APNO FROM dbo.Credit  with (nolock)   WHERE SectStat IN ('0','9') AND reptype ='C' AND Ishidden = 0 Group by Apno) CCredit on A.APNO = CCredit.APNO
		    LEFT JOIN (SELECT COUNT(1) cnt,APNO FROM dbo.MedInteg with (nolock)  WHERE SectStat IN ('0','9') AND Ishidden = 0 Group by Apno) MedInteg on A.APNO = MedInteg.APNO
		    LEFT JOIN (SELECT COUNT(1) cnt,APNO FROM dbo.DL      with (nolock)   WHERE SectStat IN ('0','9') AND Ishidden = 0 Group by Apno) DL on A.APNO = DL.APNO
		    LEFT JOIN (SELECT COUNT(1) cnt,APNO FROM dbo.Crim	 with (nolock)   WHERE ISNULL(Clear, '') IN ('','R','M','O', 'V','W','X','E','N','I','Q','Z') AND ishidden = 0 Group by Apno) Crim on A.APNO = Crim.APNO
			LEFT OUTER JOIN dbo.ApplAdditionalData AAD with (Nolock) ON ( (A.CLNO = AAD.CLNO AND  A.SSN = AAD.SSN AND AAD.SSN IS NOT NULL ))
			LEFT OUTER JOIN dbo.ApplAdditionalData AAD2 with (Nolock) ON (A.APNO = AAD2.APNO AND  AAD2.APNO IS NOT NULL)	
			left join clientconfiguration cc with (Nolock) on c.clno = cc.clno and cc.configurationkey = 'OASIS_InProgressStatus'	
		WHERE A.ApStatus in ('P','W')
		AND   Isnull(A.Investigator, '') <> ''
		AND A.userid IS NOT null
		--AND   Isnull(A.CAM, '') = '' -- Humera Ahmed on 8/16/2019 for HDT#56758
		AND IsNull(c.clienttypeid,-1) <> 15

		CREATE NONCLUSTERED INDEX IX_tmpAppl_ApStatus_SmartStatusClient
		ON [dbo].[#tmpAppl] ([ApStatus],[SmartStatusClient],[ProfLicPendingCount],[PIDPendingCount],[MedIntegPendingCount],[CrimPendingCount])
		INCLUDE ([Investigator],[APNO],[ApDate],[ReopenDate],[ElapseDays],[SSN],[Last],[First],[ClientName],[ClientCAM],[SentPending],[Crim_SelfDisclosed],[emplPendingCount],[EducatPendingCount],[PersRefPendingCount],[CCreditPendingCount],[DLPendingCount],[InProgressReviewed])

	IF @QueueType = 'In Progress'
	BEGIN
		SELECT distinct A.Investigator,A.ApStatus,A.APNO, A.ApDate, A.ReopenDate, DATEDIFF(day, A.ApDate, getdate()) AS ElapseDays, A.SSN, A.Last, A.First, C.Name AS ClientName, A.UserID AS ClientCAM,
		case when a.apstatus = 'W' then 2 else 0 end as Available, (select max(activitydate) from applactivity where apno = a.apno and activitycode  = 2) as SentPending,isnull(AAD2.Crim_SelfDisclosed,isnull(AAD.Crim_SelfDisclosed,0)) Crim_SelfDisclosed, isnull(A.InProgressReviewed,0) InProgressReviewed
		FROM dbo.Appl A with (nolock) 
			INNER JOIN dbo.Client C with (nolock) ON A.CLNO = C.CLNO
			LEFT OUTER JOIN dbo.ApplAdditionalData AAD with (Nolock) ON ( (A.CLNO = AAD.CLNO AND  A.SSN = AAD.SSN AND AAD.SSN IS NOT NULL ))
			LEFT OUTER JOIN dbo.ApplAdditionalData AAD2 with (Nolock) ON (A.APNO = AAD2.APNO AND  AAD2.APNO IS NOT NULL)
		     LEFT JOIN (SELECT COUNT(1) cnt,APNO FROM dbo.Empl    with (nolock)  WHERE SectStat IN ('0','9') AND IsOnReport = 1 Group by Apno) Empl on A.APNO = Empl.APNO
		     LEFT JOIN (SELECT COUNT(1) cnt,APNO FROM dbo.Educat  with (nolock)  WHERE SectStat IN ('0','9') AND IsOnReport = 1 Group by Apno) Educat on A.APNO = Educat.APNO
		     LEFT JOIN (SELECT COUNT(1) cnt,APNO FROM dbo.PersRef with (nolock)  WHERE SectStat IN ('0','9') AND IsOnReport = 1 Group by Apno) PersRef on A.APNO = PersRef.APNO
		     LEFT JOIN (SELECT COUNT(1) cnt,APNO FROM dbo.ProfLic with (nolock)  WHERE SectStat IN ('0','9') AND IsOnReport = 1 Group by Apno) ProfLic on A.APNO = ProfLic.APNO
		     LEFT JOIN (SELECT COUNT(1) cnt,APNO FROM dbo.Credit  with (nolock)  WHERE SectStat IN ('0','9') Group by Apno) Credit on A.APNO = Credit.APNO
		     LEFT JOIN (SELECT COUNT(1) cnt,APNO FROM dbo.MedInteg with (nolock) WHERE SectStat IN ('0','9')  Group by Apno) MedInteg on A.APNO = MedInteg.APNO
		     LEFT JOIN (SELECT COUNT(1) cnt,APNO FROM dbo.DL      with (nolock)  WHERE SectStat IN ('0','9')  Group by Apno) DL on A.APNO = DL.APNO
		     LEFT JOIN (SELECT COUNT(1) cnt,APNO FROM dbo.Crim	  with (nolock)  WHERE ISNULL(Clear, '') IN ('','R','M','O', 'V','W','X','E','N','I','Q') Group by Apno) Crim on A.APNO = Crim.APNO
--			 INNER JOIN dbo.SubStatus SS ON ISNULL(A.SubStatusID, 1) = SS.SubStatusID
--				AND SS.MainStatusID = 3	--completed
		WHERE A.ApStatus in ('P','W')
		--AND   A.ApDate IS NOT NULL
		AND   Isnull(A.Investigator, '') <> ''
		--AND	  Isnull(A.userid, '') <> ''
		AND A.userid IS NOT NULL
		AND   Isnull(A.CAM, '') = ''
		AND  (Isnull(Empl.Cnt,0) > 0
		OR    Isnull(Educat.Cnt,0) > 0
		OR    Isnull(PersRef.Cnt,0) > 0
		OR    Isnull(ProfLic.Cnt,0) > 0
		OR    Isnull(Credit.Cnt,0) > 0
		OR    Isnull(MedInteg.Cnt,0) > 0
		OR    Isnull(DL.Cnt,0) > 0
		OR    Isnull(Crim.Cnt,0) > 0)
		AND IsNull(c.clienttypeid,-1) <> 15

		--Select distinct A.Investigator,A.ApStatus,A.APNO, A.ApDate, A.ReopenDate, A.ElapseDays, A.SSN, A.Last, A.First, A.ClientName, A.ClientCAM,
		--		case when a.apstatus = 'W' then 2 else 0 end as Available, A.SentPending,A.Crim_SelfDisclosed
		--From #tmpAppl A
		--Where A.ApStatus in ('P','W')
		--AND   (emplPendingCount > 0
		--OR   EducatPendingCount > 0
		--OR   PersRefPendingCount > 0
		--OR   CCreditPendingCount > 0
		--OR   DLPendingCount > 0
		--OR   ProfLicPendingCount > 0
		--OR   PIDPendingCount > 0
		--OR   MedIntegPendingCount > 0
		--OR   CrimPendingCount > 0)	
		
		DROP table #tmpAppl	
	END
	ELSE IF @QueueType = 'To Be Final'
	BEGIN
		Select distinct A.Investigator,A.ApStatus,A.APNO, A.ApDate, A.ReopenDate, A.ElapseDays, A.SSN, A.Last, A.First, A.ClientName, A.ClientCAM,
				case when a.apstatus = 'W' then 2 else 0 end as Available, A.SentPending,A.Crim_SelfDisclosed, isnull(A.InProgressReviewed,0) InProgressReviewed
		From #tmpAppl A
		Where A.ApStatus in ('P','W')
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
		Select distinct A.Investigator,A.ApStatus,A.APNO, A.ApDate, A.ReopenDate, A.ElapseDays, A.SSN, A.Last, A.First, A.ClientName, A.ClientCAM,
				1 as Available, A.SentPending,A.Crim_SelfDisclosed, isnull(A.InProgressReviewed,0) InProgressReviewed
		From #tmpAppl A
		Where A.ApStatus = 'P'
		AND   SmartStatusClient = 'True'
		AND	  (emplPendingCount > 0
		   OR   EducatPendingCount > 0
		   OR   PersRefPendingCount>0
		   OR   CCreditPendingCount > 0
		   OR   DLPendingCount > 0)
		AND   ProfLicPendingCount = 0
		AND   PIDPendingCount = 0
		AND   MedIntegPendingCount = 0
		AND   CrimPendingCount = 0
		ORDER BY available desc,A.apno
	
		DROP table #tmpAppl
	--commented by schapyala and replaced by above query
--		SELECT distinct A.Investigator,A.ApStatus,A.APNO, A.ApDate, A.ReopenDate, DATEDIFF(day, A.ApDate, getdate()) AS ElapseDays, A.SSN, A.Last, A.First, C.Name AS ClientName, A.UserID AS ClientCAM,
--		case when a.apstatus = 'W' then 2 else 0 end as Available, (select max(activitydate) from applactivity where apno = a.apno and activitycode  = 2) as SentPending,isnull(AAD2.Crim_SelfDisclosed,isnull(AAD.Crim_SelfDisclosed,0)) Crim_SelfDisclosed
--		FROM dbo.Appl A with (nolock)  
--			INNER JOIN dbo.Client C with (nolock)  ON A.CLNO = C.CLNO
--			LEFT OUTER JOIN dbo.ApplAdditionalData AAD with (Nolock) ON ( (A.CLNO = AAD.CLNO AND  A.SSN = AAD.SSN AND AAD.SSN IS NOT NULL ))
--			LEFT OUTER JOIN dbo.ApplAdditionalData AAD2 with (Nolock) ON (A.APNO = AAD2.APNO AND  AAD2.APNO IS NOT NULL)
----			INNER JOIN dbo.SubStatus SS ON ISNULL(A.SubStatusID, 1) = SS.SubStatusID
----				AND SS.MainStatusID = 3	--investigator review
--		     LEFT JOIN (SELECT COUNT(1) cnt,APNO FROM dbo.Empl    with (nolock)   WHERE SectStat IN ('0','9') AND IsOnReport = 1 Group by Apno) Empl on A.APNO = Empl.APNO
--		     LEFT JOIN (SELECT COUNT(1) cnt,APNO FROM dbo.Educat  with (nolock)   WHERE SectStat IN ('0','9') AND IsOnReport = 1 Group by Apno) Educat on A.APNO = Educat.APNO
--		     LEFT JOIN (SELECT COUNT(1) cnt,APNO FROM dbo.PersRef with (nolock)   WHERE SectStat IN ('0','9') AND IsOnReport = 1 Group by Apno) PersRef on A.APNO = PersRef.APNO
--		     LEFT JOIN (SELECT COUNT(1) cnt,APNO FROM dbo.ProfLic  with (nolock)  WHERE SectStat IN ('0','9') AND IsOnReport = 1 Group by Apno) ProfLic on A.APNO = ProfLic.APNO
--		     LEFT JOIN (SELECT COUNT(1) cnt,APNO FROM dbo.Credit  with (nolock)   WHERE SectStat IN ('0','9') Group by Apno) Credit on A.APNO = Credit.APNO
--		     LEFT JOIN (SELECT COUNT(1) cnt,APNO FROM dbo.MedInteg with (nolock)  WHERE SectStat IN ('0','9')  Group by Apno) MedInteg on A.APNO = MedInteg.APNO
--		     LEFT JOIN (SELECT COUNT(1) cnt,APNO FROM dbo.DL      with (nolock)   WHERE SectStat IN ('0','9')  Group by Apno) DL on A.APNO = DL.APNO
--		     LEFT JOIN (SELECT COUNT(1) cnt,APNO FROM dbo.Crim	 with (nolock)    WHERE ISNULL(Clear, '') IN ('','R','M','O', 'V','W','X','E','N','I','Q','Z') and ishidden = 0 Group by Apno) Crim on A.APNO = Crim.APNO
--		WHERE A.ApStatus in ('P','W')
--		--AND   A.ApDate IS NOT NULL
--		AND   Isnull(A.Investigator, '') <> ''
--		--AND	  Isnull(A.userid, '') <> ''
--		AND A.userid IS NOT null
--		AND   Isnull(A.CAM, '') = ''
--		AND   Isnull(Empl.Cnt,0) = 0
--		AND   Isnull(Educat.Cnt,0) = 0
--		AND   Isnull(PersRef.Cnt,0) = 0
--		AND   Isnull(ProfLic.Cnt,0) = 0
--		AND   Isnull(Credit.Cnt,0) = 0
--		AND   Isnull(MedInteg.Cnt,0) = 0
--		AND   Isnull(DL.Cnt,0) = 0
--		AND   Isnull(Crim.Cnt,0) = 0
--		AND IsNull(c.clienttypeid,-1) <> 15
--		and a.apno not in (SELECT A.APNO
--		FROM dbo.Appl A with (nolock)  
--			INNER JOIN dbo.Client C with (nolock)  ON A.CLNO = C.CLNO
--			left join clientconfiguration cc on c.clno = cc.clno and cc.configurationkey = 'OASIS_InProgressStatus'
----			INNER JOIN dbo.SubStatus SS ON ISNULL(A.SubStatusID, 1) = SS.SubStatusID
----				AND SS.MainStatusID = 3	--investigator review
--		     LEFT JOIN (SELECT COUNT(1) cnt,APNO FROM dbo.Empl    with (nolock)   WHERE SectStat IN ('0','9') AND IsOnReport = 1 Group by Apno) Empl on A.APNO = Empl.APNO
--		     LEFT JOIN (SELECT COUNT(1) cnt,APNO FROM dbo.Educat  with (nolock)   WHERE SectStat IN ('0','9') AND IsOnReport = 1 Group by Apno) Educat on A.APNO = Educat.APNO
--		     LEFT JOIN (SELECT COUNT(1) cnt,APNO FROM dbo.PersRef with (nolock)   WHERE SectStat IN ('0','9') AND IsOnReport = 1 Group by Apno) PersRef on A.APNO = PersRef.APNO
--		     LEFT JOIN (SELECT COUNT(1) cnt,APNO FROM dbo.ProfLic  with (nolock)  WHERE SectStat IN ('0','9') AND IsOnReport = 1 Group by Apno) ProfLic on A.APNO = ProfLic.APNO
--		     LEFT JOIN (SELECT COUNT(1) cnt,APNO FROM dbo.Credit  with (nolock)   WHERE SectStat IN ('0','9') and reptype ='S' Group by Apno) SCredit on A.APNO = SCredit.APNO
--		     LEFT JOIN (SELECT COUNT(1) cnt,APNO FROM dbo.Credit  with (nolock)   WHERE SectStat IN ('0','9') and reptype ='C' Group by Apno) CCredit on A.APNO = CCredit.APNO
--		     LEFT JOIN (SELECT COUNT(1) cnt,APNO FROM dbo.MedInteg with (nolock)  WHERE SectStat IN ('0','9')  Group by Apno) MedInteg on A.APNO = MedInteg.APNO
--		     LEFT JOIN (SELECT COUNT(1) cnt,APNO FROM dbo.DL      with (nolock)   WHERE SectStat IN ('0','9')  Group by Apno) DL on A.APNO = DL.APNO
--		     LEFT JOIN (SELECT COUNT(1) cnt,APNO FROM dbo.Crim	 with (nolock)    WHERE ISNULL(Clear, '') IN ('','R','M','O', 'V','W','X','E','N','I','Q','Z') and ishidden = 0 Group by Apno) Crim on A.APNO = Crim.APNO
--		WHERE A.ApStatus = 'P'
--		--AND   A.ApDate IS NOT NULL
--		AND   Isnull(A.Investigator, '') <> ''
--		--AND	  Isnull(A.userid, '') <> ''
--		AND A.userid IS NOT null
--		AND   Isnull(A.CAM, '') = ''
--		AND   (Isnull(Empl.Cnt,0) > 0
--		or   Isnull(Educat.Cnt,0) > 0
--		or   Isnull(PersRef.Cnt,0) > 0
--		or   Isnull(CCredit.Cnt,0) > 0
--		or  Isnull(DL.Cnt,0) > 0)
--		AND   Isnull(ProfLic.Cnt,0) = 0
--		AND   Isnull(SCredit.Cnt,0) = 0
--		AND   Isnull(MedInteg.Cnt,0) = 0
--		AND   Isnull(Crim.Cnt,0) = 0
--		AND IsNull(c.clienttypeid,-1) <> 15
--		and cc.value = 'True')
--		UNION ALL
--		SELECT distinct A.Investigator,A.ApStatus,A.APNO, A.ApDate, A.ReopenDate, DATEDIFF(day, A.ApDate, getdate()) AS ElapseDays, A.SSN, A.Last, A.First, C.Name AS ClientName, A.UserID AS ClientCAM,
--		1 As Available, (select max(activitydate) from applactivity where apno = a.apno and activitycode  = 2) as SentPending,isnull(AAD2.Crim_SelfDisclosed,isnull(AAD.Crim_SelfDisclosed,0)) Crim_SelfDisclosed
--		FROM dbo.Appl A with (nolock)  
--			INNER JOIN dbo.Client C with (nolock)  ON A.CLNO = C.CLNO
--			LEFT OUTER JOIN dbo.ApplAdditionalData AAD with (Nolock) ON ( (A.CLNO = AAD.CLNO AND  A.SSN = AAD.SSN AND AAD.SSN IS NOT NULL ))
--			LEFT OUTER JOIN dbo.ApplAdditionalData AAD2 with (Nolock) ON (A.APNO = AAD2.APNO AND  AAD2.APNO IS NOT NULL)
--			left join clientconfiguration cc on c.clno = cc.clno and cc.configurationkey = 'OASIS_InProgressStatus'
----			INNER JOIN dbo.SubStatus SS ON ISNULL(A.SubStatusID, 1) = SS.SubStatusID
----				AND SS.MainStatusID = 3	--investigator review
--		     LEFT JOIN (SELECT COUNT(1) cnt,APNO FROM dbo.Empl    with (nolock)   WHERE SectStat IN ('0','9') AND IsOnReport = 1 Group by Apno) Empl on A.APNO = Empl.APNO
--		     LEFT JOIN (SELECT COUNT(1) cnt,APNO FROM dbo.Educat  with (nolock)   WHERE SectStat IN ('0','9') AND IsOnReport = 1 Group by Apno) Educat on A.APNO = Educat.APNO
--		     LEFT JOIN (SELECT COUNT(1) cnt,APNO FROM dbo.PersRef with (nolock)   WHERE SectStat IN ('0','9') AND IsOnReport = 1 Group by Apno) PersRef on A.APNO = PersRef.APNO
--		     LEFT JOIN (SELECT COUNT(1) cnt,APNO FROM dbo.ProfLic  with (nolock)  WHERE SectStat IN ('0','9') AND IsOnReport = 1 Group by Apno) ProfLic on A.APNO = ProfLic.APNO
--		     LEFT JOIN (SELECT COUNT(1) cnt,APNO FROM dbo.Credit  with (nolock)   WHERE SectStat IN ('0','9') and reptype ='S' Group by Apno) SCredit on A.APNO = SCredit.APNO
--		     LEFT JOIN (SELECT COUNT(1) cnt,APNO FROM dbo.Credit  with (nolock)   WHERE SectStat IN ('0','9') and reptype ='C' Group by Apno) CCredit on A.APNO = CCredit.APNO
--		     LEFT JOIN (SELECT COUNT(1) cnt,APNO FROM dbo.MedInteg with (nolock)  WHERE SectStat IN ('0','9')  Group by Apno) MedInteg on A.APNO = MedInteg.APNO
--		     LEFT JOIN (SELECT COUNT(1) cnt,APNO FROM dbo.DL      with (nolock)   WHERE SectStat IN ('0','9')  Group by Apno) DL on A.APNO = DL.APNO
--		     LEFT JOIN (SELECT COUNT(1) cnt,APNO FROM dbo.Crim	 with (nolock)    WHERE ISNULL(Clear, '') IN ('','R','M','O', 'V','W','X','E','N','I','Q') and ishidden = 0 Group by Apno) Crim on A.APNO = Crim.APNO
--		WHERE A.ApStatus = 'P'
--		--AND   A.ApDate IS NOT NULL
--		AND   Isnull(A.Investigator, '') <> ''
--		--AND	  Isnull(A.userid, '') <> ''
--		AND A.userid IS NOT null
--		AND   Isnull(A.CAM, '') = ''
--		AND   (Isnull(Empl.Cnt,0) > 0
--		or   Isnull(Educat.Cnt,0) > 0
--		or   Isnull(PersRef.Cnt,0) > 0
--		or   Isnull(CCredit.Cnt,0) > 0
--		or  Isnull(DL.Cnt,0) > 0)
--		AND   Isnull(ProfLic.Cnt,0) = 0
--		AND   Isnull(SCredit.Cnt,0) = 0
--		AND   Isnull(MedInteg.Cnt,0) = 0
--		AND   Isnull(Crim.Cnt,0) = 0
--		AND IsNull(c.clienttypeid,-1) <> 15
--		and cc.value = 'True'
--		ORDER BY available desc,A.apno
	END
    ELSE IF @QueueType = 'Both'
	BEGIN
        SELECT distinct A.Investigator,A.ApStatus,A.APNO, A.ApDate, A.ReopenDate, DATEDIFF(day, A.ApDate, getdate()) AS ElapseDays, A.SSN, A.Last, A.First, C.Name AS ClientName, A.UserID AS ClientCAM,isnull(AAD2.Crim_SelfDisclosed,isnull(AAD.Crim_SelfDisclosed,0)) Crim_SelfDisclosed, isnull(A.InProgressReviewed,0) InProgressReviewed
		FROM dbo.Appl A (NOLOCK) 
			INNER JOIN dbo.Client C (NOLOCK) ON A.CLNO = C.CLNO
			LEFT OUTER JOIN dbo.ApplAdditionalData AAD with (Nolock) ON ( (A.CLNO = AAD.CLNO AND  A.SSN = AAD.SSN AND AAD.SSN IS NOT NULL ))
			LEFT OUTER JOIN dbo.ApplAdditionalData AAD2 with (Nolock) ON (A.APNO = AAD2.APNO AND  AAD2.APNO IS NOT NULL)
			INNER JOIN dbo.SubStatus SS (NOLOCK) ON ISNULL(A.SubStatusID, 1) = SS.SubStatusID
				AND SS.MainStatusID = 3	--investigator review
		WHERE A.ApStatus = 'P'
		--AND   A.ApDate IS NOT NULL
		AND   ISNULL(A.Investigator, '') <> ''
		AND   ISNULL(A.CAM, '') = ''
			
		--WHERE (SELECT COUNT(*) FROM dbo.Empl		WHERE APNO = A.APNO AND SectStat IN ('0','9') AND IsOnReport = 1) = 0
			--AND (SELECT COUNT(*) FROM dbo.Educat	WHERE APNO = A.APNO AND SectStat IN ('0','9') AND IsOnReport = 1) = 0
			--AND (SELECT COUNT(*) FROM dbo.PersRef	WHERE APNO = A.APNO AND SectStat IN ('0','9') AND IsOnReport = 1) = 0
			--AND (SELECT COUNT(*) FROM dbo.ProfLic	WHERE APNO = A.APNO AND SectStat IN ('0','9') AND IsOnReport = 1) = 0
			--AND (SELECT COUNT(*) FROM dbo.Credit	WHERE APNO = A.APNO AND SectStat IN ('0','9')) = 0
			--AND (SELECT COUNT(*) FROM dbo.MedInteg	WHERE APNO = A.APNO AND SectStat IN ('0','9')) = 0
			--AND (SELECT COUNT(*) FROM dbo.DL		WHERE APNO = A.APNO AND SectStat IN ('0','9')) = 0
			--AND (SELECT COUNT(*) FROM dbo.Crim		WHERE APNO = A.APNO AND ISNULL(Clear, '') IN ('','R','M','O')) = 0
		--ORDER BY A.ApDate
		
	END
	Else IF @QueueType = 'UnAssigned'
	BEGIN
        SELECT distinct A.Investigator,A.ApStatus,A.APNO, A.ApDate, A.ReopenDate, DATEDIFF(day, A.ApDate, getdate()) AS ElapseDays, A.SSN, A.Last, A.First, C.Name AS ClientName, A.UserID AS ClientCAM,isnull(AAD2.Crim_SelfDisclosed,isnull(AAD.Crim_SelfDisclosed,0)) Crim_SelfDisclosed, isnull(A.InProgressReviewed,0) InProgressReviewed
		FROM dbo.Appl A (NOLOCK) 
			INNER JOIN dbo.Client C (NOLOCK) ON A.CLNO = C.CLNO	
			LEFT OUTER JOIN dbo.ApplAdditionalData AAD with (Nolock) ON ( (A.CLNO = AAD.CLNO AND  A.SSN = AAD.SSN AND AAD.SSN IS NOT NULL ))
			LEFT OUTER JOIN dbo.ApplAdditionalData AAD2 with (Nolock) ON (A.APNO = AAD2.APNO AND  AAD2.APNO IS NOT NULL)
		WHERE A.ApStatus = 'P'
		--AND   A.ApDate IS NOT NULL
		AND   ISNULL(C.CAM, '') = ''	
	END
END
ELSE 
BEGIN
	--IF @QueueType = 'UnAssigned'
		--BEGIN
			SELECT distinct A.Investigator,A.ApStatus,A.APNO, A.ApDate, A.ReopenDate, DATEDIFF(day, A.ApDate, getdate()) AS ElapseDays, A.SSN, A.Last, A.First, C.Name AS ClientName, A.UserID AS ClientCAM,isnull(AAD2.Crim_SelfDisclosed,isnull(AAD.Crim_SelfDisclosed,0)) Crim_SelfDisclosed, isnull(A.InProgressReviewed,0) InProgressReviewed
			FROM dbo.Appl A (NOLOCK) 
				INNER JOIN dbo.Client C (NOLOCK) ON A.CLNO = C.CLNO	
				LEFT OUTER JOIN dbo.ApplAdditionalData AAD with (Nolock) ON ( (A.CLNO = AAD.CLNO AND  A.SSN = AAD.SSN AND AAD.SSN IS NOT NULL ))
				LEFT OUTER JOIN dbo.ApplAdditionalData AAD2 with (Nolock) ON (A.APNO = AAD2.APNO AND  AAD2.APNO IS NOT NULL)
			WHERE A.ApStatus = 'P'
			--AND   A.ApDate IS NOT NULL
			AND   ISNULL(A.Investigator, '') = ''	
		--END
	--ELSE
		/*
		SELECT A.APNO, A.ApDate, A.ReopenDate, DATEDIFF(day, A.ApDate, getdate()) AS ElapseDays, A.SSN, A.Last, A.First, C.Name AS ClientName, C.CAM AS ClientCAM
		FROM dbo.Appl A
			INNER JOIN dbo.Client C ON A.CLNO = C.CLNO
			INNER JOIN dbo.SubStatus SS ON ISNULL(A.SubStatusID, 2) = SS.SubStatusID
				AND SS.MainStatusID = 1	--pending
		WHERE A.ApStatus = 'P'
		AND   A.ApDate IS NOT NULL
		AND   ISNULL(A.Investigator, '') <> ''
		--ORDER BY A.ApDate
	   */
END

SET NOCOUNT OFF

















