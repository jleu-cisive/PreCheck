/****** Object:  StoredProcedure [dbo].[CAMPendingDetails]    Script Date: 9/20/2017 1:48:13 PM ******/  
-- =============================================  
-- Author:  Prasanna  
-- Create date: 1/1/2017  
-- Description: CAMPendingDetails  
-- Modified by: Humera Ahmed on 2/26/2020 for HDT#67958 - Please add a column to this report titled 'MCIC' which will show whether or not the report was submitted through an MCIC batch.  The column can simply display True/False.  
-- Exec [CAMPendingDetails] '',''  
-- Modified by : Sahithi Gangaraju on 10/06/2020 -HDT 77500- Adding columns IPR and TBF   
-- Modified by : Prasanna on 10/14/2020 - HDT#79714 FormLookupApp - In-Progress-All QReport not showing Compliance CAM  
-- Modified by : Sahithi on 10/28/2020-HDT:80320 added new column Admitted REcord  
-- Modified by : Humera Ahmed on 12/02/2020-HDT:81794 - USE TAT calculation logic for Elapsed column  
-- Modified by : AmyLiu on 09/03/2021-HDT17400 add a column to this Qreport in between the Reopen Date and the Elapsed columns which will show the Original Close date if there is one.  
-- Modified by : Mainak on 06/16/2022 - Ticket No.  38199
-- =============================================  
CREATE PROCEDURE [dbo].[CAMPendingDetails]  
  @CAM varchar(8),  
  @EnteredVia varchar(20)  
AS  
BEGIN   
  
	
	CREATE TABLE #tmpAppl ( Apno int)  
  
	INSERT INTO #tmpAppl  
	SELECT DISTINCT(A.Apno)
	 FROM dbo.Appl A WITH (NOLOCK)    
	INNER JOIN dbo.Client C ON A.Clno = C.Clno    
	left join dbo.Crim  WITH (NOLOCK) on crim.apno= a.apno And Crim.IsHidden =0 and ( crim.clear is null or crim.clear in ('R','M','O','V','I','W','Z','D'))    
	left join dbo.Civil WITH (NOLOCK) on civil.apno = a.apno AND ((Civil.Clear IS NULL) OR (Civil.Clear = 'O'))    
	left join dbo.Credit WITH (NOLOCK) on (Credit.Apno = A.Apno) AND (Credit.SectStat = '0' OR Credit.SectStat = '9')    
	left join  dbo.DL WITH (NOLOCK)  on (DL.Apno = A.Apno) AND (DL.SectStat = '0' OR DL.SectStat = '9')    
	left join dbo.Empl WITH (NOLOCK) on  (Empl.Apno = A.Apno) AND Empl.IsOnReport = 1 AND (Empl.SectStat = '0' OR Empl.SectStat = '9')    
	left join dbo.Educat WITH (NOLOCK) on  (Educat.Apno = A.Apno) AND Educat.IsOnReport = 1 AND (Educat.SectStat = '0' OR Educat.SectStat = '9')    
	left join dbo.ProfLic WITH (NOLOCK) on (ProfLic.Apno = A.Apno) AND ProfLic.IsOnReport = 1 AND (ProfLic.SectStat ='0' OR ProfLic.SectStat = '9')    
	left join dbo.PersRef WITH (NOLOCK) on  (PersRef.Apno = A.Apno) AND PersRef.IsOnReport = 1 AND (PersRef.SectStat = '0' OR PersRef.SectStat = '9')    
	left join dbo.Medinteg WITH (NOLOCK)  on  (Medinteg.Apno = A.Apno) AND (Medinteg.SectStat = '0' OR Medinteg.SectStat = '9')    
	WHERE (A.ApStatus IN ('P','W'))    
		AND A.Investigator <> '' --AND ISNULL(A.Investigator, '') <> ''    
		AND A.userid IS NOT null    
		AND C.ClientTypeID <> 15 --AND ISNULL(c.clienttypeid,-1) <> 15    
		and crim.CrimID is null    
		and civil.CivilID is null    
		and credit.apno is null    
		and DL.APNO is null    
		and empl.EmplID is null    
		and Educat.EducatID is null    
		and ProfLic.ProfLicID is null    
		and PersRef.PersRefID is null    
		and Medinteg.apno is null    
		
	  CREATE TABLE #tmpResults 
		(
				[Report Number]  int
				, [Create Date]  datetime
				, [Status] CHAR(1)
				, [Investigator]  VARCHAR(8)
				,[Reopen Date]   DATETIME
				,[Original Close date]  DATETIME
				, Elapsed  DATETIME
				,ElapsedHours  int
				, [Last Name] VARCHAR(50) 
				, [First Name]  VARCHAR(50)
				, [Client ID]   SMALLINT
				, Client  VARCHAR(100)
				, AffiliateID int
				, Affiliate NVARCHAR(50)
				, [Client's CAM] VARCHAR(8)
				, EnteredVia   VARCHAR(8)
				, [MCIC] bit
				, PackageDesc  VARCHAR(100)
				, [IPR] bit
				,[TBF] bit
		)


	  if @CAM=''
	  begin
			if @EnteredVia=''
			BEGIN
				INSERT INTO #tmpResults
				(
				    [Report Number],
				    [Create Date],
				    Status,
				    Investigator,
				    [Reopen Date],
				    [Original Close date],
				    Elapsed,
				    ElapsedHours,
				    [Last Name],
				    [First Name],
				    [Client ID],
				    Client,
				    AffiliateID,
				    Affiliate,
				    [Client's CAM],
				    EnteredVia,
				    MCIC,
				    PackageDesc,
				    IPR,
				    TBF
				)
				SELECT   
				A.APNO as [Report Number]  
				, A.ApDate as [Create Date]  
				, A.ApStatus as [Status]  
				, A.Investigator as [Investigator]  
				, A.ReopenDate as [Reopen Date]  
				--, DATEDIFF(day, A.ApDate, getdate()) AS Elapsed  
				,A.OrigCompDate AS [Original Close date]  
				,A.ApDate AS Elapsed --,[dbo].[ElapsedBusinessDays_2](A.ApDate, getdate()) AS Elapsed  
				,0 AS ElapsedHours --,[dbo].[ElapsedBusinessHours_2](A.ApDate, getdate()) AS ElapsedHours  
				, A.Last as [Last Name]  
				, A.First as[First Name]  
				, C.CLNO as [Client ID]   
				, C.Name AS Client  
				, c.AffiliateID, rf.Affiliate, ISNULL(A.UserID, C.CAM) AS [Client's CAM] --C.CAM AS [Client's CAM]  
				, A.EnteredVia   
				, CASE WHEN O.BatchOrderDetailId IS NULL THEN 'False' ELSE 'True' END [MCIC] --For HDT#67958  
				, pm.PackageDesc  
				, CASE WHEN a.inprogressreviewed IS NULL or a.inprogressreviewed =0 THEN 'False' ELSE 'True' END [IPR] --HDT:77500  
			   -- , CASE WHEN ISNULL(apd.Crim_SelfDisclosed,0) = 0 then 'False' else 'True' end as [Admitted Record]-- for HDT #80320  
				--,CASE WHEN EXISTS (SELECT TOP 1 1 FROM  #tmpAppl where  #tmpAppl.Apno=a.APNO)  THEN 'True' ELSE 'False' END as [TBF]--HDT 77500  --commented by Mainak 38199
				,case when isnull(t.apno,'')<>'' THEN 'True' ELSE 'False' END as [TBF] --Mainak 38199
			   FROM dbo.Appl A with (nolock)    
				INNER JOIN dbo.Client C with (nolock)  ON A.CLNO = C.CLNO  
				INNER JOIN dbo.refAffiliate rf with(nolock) On c.AffiliateID = rf.AffiliateID   
				LEFT JOIN dbo.PackageMain pm ON a.PackageID = pm.PackageID  
				LEFT JOIN Enterprise.dbo.[Order] O ON CAST(A.APNO AS VARCHAR(20)) = O.OrderNumber --For HDT#67958  
				--LEFT JOIn ApplAdditionalData apd (NOLOCK) on a.APno = apd.APNO --For HDT#80320 
				Left join  #tmpAppl t on t.apno=a.apno --Mainak 38199
			   WHERE   
				A.ApStatus in ('P','W')   
			   
		   end
		   else
		   begin 
				INSERT INTO #tmpResults
				(
				    [Report Number],
				    [Create Date],
				    Status,
				    Investigator,
				    [Reopen Date],
				    [Original Close date],
				    Elapsed,
				    ElapsedHours,
				    [Last Name],
				    [First Name],
				    [Client ID],
				    Client,
				    AffiliateID,
				    Affiliate,
				    [Client's CAM],
				    EnteredVia,
				    MCIC,
				    PackageDesc,
				    IPR,
				    TBF
				)
				SELECT   
				A.APNO as [Report Number]  
				, A.ApDate as [Create Date]  
				, A.ApStatus as [Status]  
				, A.Investigator as [Investigator]  
				, A.ReopenDate as [Reopen Date]  
				--, DATEDIFF(day, A.ApDate, getdate()) AS Elapsed  
				,A.OrigCompDate AS [Original Close date]  
				,A.ApDate AS Elapsed --,[dbo].[ElapsedBusinessDays_2](A.ApDate, getdate()) AS Elapsed  
				,0 AS ElapsedHours --,[dbo].[ElapsedBusinessHours_2](A.ApDate, getdate()) AS ElapsedHours  
				, A.Last as [Last Name]  
				, A.First as[First Name]  
				, C.CLNO as [Client ID]   
				, C.Name AS Client  
				, c.AffiliateID, rf.Affiliate, ISNULL(A.UserID, C.CAM) AS [Client's CAM] --C.CAM AS [Client's CAM]  
				, A.EnteredVia   
				, CASE WHEN O.BatchOrderDetailId IS NULL THEN 'False' ELSE 'True' END [MCIC] --For HDT#67958  
				, pm.PackageDesc  
				, CASE WHEN a.inprogressreviewed IS NULL or a.inprogressreviewed =0 THEN 'False' ELSE 'True' END [IPR] --HDT:77500  
			   -- , CASE WHEN ISNULL(apd.Crim_SelfDisclosed,0) = 0 then 'False' else 'True' end as [Admitted Record]-- for HDT #80320  
				--,CASE WHEN EXISTS (SELECT TOP 1 1 FROM  #tmpAppl where  #tmpAppl.Apno=a.APNO)  THEN 'True' ELSE 'False' END as [TBF]--HDT 77500  --commented by Mainak 38199
				,case when isnull(t.apno,'')<>'' THEN 'True' ELSE 'False' END as [TBF] --Mainak 38199
			   FROM dbo.Appl A with (nolock)    
				INNER JOIN dbo.Client C with (nolock)  ON A.CLNO = C.CLNO  
				INNER JOIN dbo.refAffiliate rf with(nolock) On c.AffiliateID = rf.AffiliateID   
				LEFT JOIN dbo.PackageMain pm ON a.PackageID = pm.PackageID  
				LEFT JOIN Enterprise.dbo.[Order] O ON A.APNO = O.OrderNumber --For HDT#67958  
				--LEFT JOIn ApplAdditionalData apd (NOLOCK) on a.APno = apd.APNO --For HDT#80320  
				Left join  #tmpAppl t on t.apno=a.apno --Mainak 38199

			   WHERE   
				A.ApStatus in ('P','W')   
				AND A.EnteredVia= @EnteredVia   
			    
		   end
	  end
	  else
	  begin
			if  @EnteredVia=''
			BEGIN
				INSERT INTO #tmpResults
				(
				    [Report Number],
				    [Create Date],
				    Status,
				    Investigator,
				    [Reopen Date],
				    [Original Close date],
				    Elapsed,
				    ElapsedHours,
				    [Last Name],
				    [First Name],
				    [Client ID],
				    Client,
				    AffiliateID,
				    Affiliate,
				    [Client's CAM],
				    EnteredVia,
				    MCIC,
				    PackageDesc,
				    IPR,
				    TBF
				)
				SELECT   
					A.APNO as [Report Number]  
					, A.ApDate as [Create Date]  
					, A.ApStatus as [Status]  
					, A.Investigator as [Investigator]  
					, A.ReopenDate as [Reopen Date]  
					--, DATEDIFF(day, A.ApDate, getdate()) AS Elapsed  
					,A.OrigCompDate AS [Original Close date]  
					,A.ApDate AS Elapsed --,[dbo].[ElapsedBusinessDays_2](A.ApDate, getdate()) AS Elapsed  
					,0 AS ElapsedHours --,[dbo].[ElapsedBusinessHours_2](A.ApDate, getdate()) AS ElapsedHours  
					, A.Last as [Last Name]  
					, A.First as[First Name]  
					, C.CLNO as [Client ID]   
					, C.Name AS Client  
					, c.AffiliateID, rf.Affiliate, ISNULL(A.UserID, C.CAM) AS [Client's CAM] --C.CAM AS [Client's CAM]  
					, A.EnteredVia   
					, CASE WHEN O.BatchOrderDetailId IS NULL THEN 'False' ELSE 'True' END [MCIC] --For HDT#67958  
					, pm.PackageDesc  
					, CASE WHEN a.inprogressreviewed IS NULL or a.inprogressreviewed =0 THEN 'False' ELSE 'True' END [IPR] --HDT:77500  
				   -- , CASE WHEN ISNULL(apd.Crim_SelfDisclosed,0) = 0 then 'False' else 'True' end as [Admitted Record]-- for HDT #80320  
					--,CASE WHEN EXISTS (SELECT TOP 1 1 FROM  #tmpAppl where  #tmpAppl.Apno=a.APNO)  THEN 'True' ELSE 'False' END as [TBF]--HDT 77500  --commented by Mainak 38199
					,case when isnull(t.apno,'')<>'' THEN 'True' ELSE 'False' END as [TBF] --Mainak 38199
				   FROM dbo.Appl A with (nolock)    
					INNER JOIN dbo.Client C with (nolock)  ON A.CLNO = C.CLNO  
					INNER JOIN dbo.refAffiliate rf with(nolock) On c.AffiliateID = rf.AffiliateID   
					LEFT JOIN dbo.PackageMain pm ON a.PackageID = pm.PackageID  
					LEFT JOIN Enterprise.dbo.[Order] O ON A.APNO = O.OrderNumber --For HDT#67958  
					--LEFT JOIn ApplAdditionalData apd (NOLOCK) on a.APno = apd.APNO --For HDT#80320 
					Left join  #tmpAppl t on t.apno=a.apno --Mainak 38199
				   WHERE   
					A.ApStatus in ('P','W')   
					AND C.CAM = @CAM  
				   
			   end
			   else
			   BEGIN
					INSERT INTO #tmpResults
					(
						[Report Number],
						[Create Date],
						Status,
						Investigator,
						[Reopen Date],
						[Original Close date],
						Elapsed,
						ElapsedHours,
						[Last Name],
						[First Name],
						[Client ID],
						Client,
						AffiliateID,
						Affiliate,
						[Client's CAM],
						EnteredVia,
						MCIC,
						PackageDesc,
						IPR,
						TBF
					)
					SELECT   
					A.APNO as [Report Number]  
					, A.ApDate as [Create Date]  
					, A.ApStatus as [Status]  
					, A.Investigator as [Investigator]  
					, A.ReopenDate as [Reopen Date]  
					--, DATEDIFF(day, A.ApDate, getdate()) AS Elapsed  
					,A.OrigCompDate AS [Original Close date]  
					,A.ApDate AS Elapsed --,[dbo].[ElapsedBusinessDays_2](A.ApDate, getdate()) AS Elapsed  
					,0 AS ElapsedHours --,[dbo].[ElapsedBusinessHours_2](A.ApDate, getdate()) AS ElapsedHours  
					, A.Last as [Last Name]  
					, A.First as[First Name]  
					, C.CLNO as [Client ID]   
					, C.Name AS Client  
					, c.AffiliateID, rf.Affiliate, ISNULL(A.UserID, C.CAM) AS [Client's CAM] --C.CAM AS [Client's CAM]  
					, A.EnteredVia   
					, CASE WHEN O.BatchOrderDetailId IS NULL THEN 'False' ELSE 'True' END [MCIC] --For HDT#67958  
					, pm.PackageDesc  
					, CASE WHEN a.inprogressreviewed IS NULL or a.inprogressreviewed =0 THEN 'False' ELSE 'True' END [IPR] --HDT:77500  
				   -- , CASE WHEN ISNULL(apd.Crim_SelfDisclosed,0) = 0 then 'False' else 'True' end as [Admitted Record]-- for HDT #80320  
					--,CASE WHEN EXISTS (SELECT TOP 1 1 FROM  #tmpAppl where  #tmpAppl.Apno=a.APNO)  THEN 'True' ELSE 'False' END as [TBF]--HDT 77500  --commented by Mainak 38199
					,case when isnull(t.apno,'')<>'' THEN 'True' ELSE 'False' END as [TBF] --Mainak 38199 
					--INTO	#tmpResults
				   FROM dbo.Appl A with (nolock)    
					INNER JOIN dbo.Client C with (nolock)  ON A.CLNO = C.CLNO  
					INNER JOIN dbo.refAffiliate rf with(nolock) On c.AffiliateID = rf.AffiliateID   
					LEFT JOIN dbo.PackageMain pm ON a.PackageID = pm.PackageID  
					LEFT JOIN Enterprise.dbo.[Order] O ON A.APNO = O.OrderNumber --For HDT#67958  
					--LEFT JOIn ApplAdditionalData apd (NOLOCK) on a.APno = apd.APNO --For HDT#80320 
					Left join  #tmpAppl t on t.apno=a.apno --Mainak 38199
				   WHERE   
					A.ApStatus in ('P','W')   
					AND C.CAM = @CAM  
					AND A.EnteredVia= @EnteredVia   
				    
			   end
	  END
      

	SELECT [Report Number]  
				, [Create Date]  
				, [Status]  
				, [Investigator]  
				,[Reopen Date]   
				,[Original Close date]  
				,[dbo].[ElapsedBusinessDays_2](Elapsed, getdate()) AS Elapsed  
				,[dbo].[ElapsedBusinessHours_2](Elapsed, getdate()) AS ElapsedHours  
				, [Last Name]  
				, [First Name]  
				, [Client ID]   
				, Client  
				, AffiliateID
				, Affiliate
				, [Client's CAM] 
				, EnteredVia   
				, [MCIC] 
				, PackageDesc  
				, [IPR] 
				,[TBF]
	FROM #tmpResults
	ORDER BY [Report Number] desc


	DROP TABLE #tmpResults;
	DROP TABLE IF EXISTS #tmpAppl;  
  
END  