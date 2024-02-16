-- =============================================
-- Author:		Deepak Vodethela
-- Create date: 10/01/2018
-- Description:	One time generation of files 
--Execution: EXEC [dbo].[BGReportMainPull_Presbyterian_PaperRelease_CatchUp_And_BG_Reports] 7898, '05/1/2018','09/1/2018',1
-- =============================================
CREATE PROCEDURE [dbo].[BGReportMainPull_Presbyterian_PaperRelease_CatchUp_And_BG_Reports]
	@CLNO int, @StartDate datetime,@EndDate datetime,@UseHevnDb bit = 1
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @PaperReleaseStartDate datetime,@PaperReleaseEndDate datetime
	SET @PaperReleaseStartDate = '01/01/2006'--DATEADD(m,-4,getdate());
	SET @PaperReleaseEndDate = '10/01/2018';
	SET @StartDate = '07/01/2018'
	SET @EndDate = '10/01/2018'

	If(@UseHevnDb = 1)
	BEGIN
		CREATE TABLE #tmp(
			[FolderID] [int] NOT NULL,
			[CLNO] [smallint] NOT NULL,
			[ReportID] [int] NOT NULL,
			[EmployeeNumber] [varchar](50) NOT NULL,
			[ClientFacilityGroup] [varchar](50) NULL)

		CREATE CLUSTERED INDEX IX_tmp2_01 ON #tmp([FolderID])

		CREATE TABLE #tmp1(
			[FolderID] [int] NOT NULL,
			[CLNO] [smallint] NOT NULL,
			[ReportID] [int] NOT NULL,
			[EmployeeNumber] [varchar](50) NOT NULL,
			[ClientFacilityGroup] [varchar](50) NULL)

		CREATE CLUSTERED INDEX IX_tmp1_01 ON #tmp1([FolderID])

		CREATE TABLE #tmp7898(
			[FolderID] [int] NOT NULL,
			[CLNO] [smallint] NOT NULL,
			[ReportID] [int] NOT NULL,
			[EmployeeNumber] [varchar](50) NOT NULL,
			[ClientFacilityGroup] [varchar](50) NULL)

		CREATE CLUSTERED INDEX IX_tmp7898_01 ON #tmp7898([FolderID])

		CREATE TABLE #tmpPaperReleases(
			[FolderID] [int] NOT NULL,
			[CLNO] [smallint] NOT NULL,
			[ReportID] [int] NOT NULL,
			[EmployeeNumber] [varchar](50) NOT NULL,
			[ClientFacilityGroup] [varchar](50) NULL)

		CREATE CLUSTERED INDEX IX_tmpPaperReleases_01 ON #tmpPaperReleases([FolderID])

		INSERT INTO #tmp
		SELECT  idtable.apno as FolderID, idtable.clno, br.backgroundreportid AS ReportID,idtable.employeeNumber, isnull(ClientFacilityGroup,'NonGrouped') as ClientFacilityGroup --schapyala returning emptystring for facilitygroup as this is not used for BG purposes - 05/04/2015
		FROM (
				SELECT DISTINCT  a.apno,cast(a.clno as int) as clno ,er.employeeNumber, 'NonGrouped' as ClientFacilityGroup
				FROM HEVN.dbo.EmployeeRecord er WITH (NOLOCK) 
				INNER JOIN  HEVN.dbo.Facility F WITH (NOLOCK) on er.facilityid = F.facilityid         
				INNER JOIN  PRECHECK.DBO.appl a  WITH (NOLOCK) on ER.ssn = a.ssn 
				INNER JOIN BackgroundReports.dbo.BackgroundReport br WITH (NOLOCK) on a.apno = br.apno 
				WHERE (F.ParentEmployerID=@CLNO OR F.EmployerID=@CLNO)
				AND er.facilityid is not null and er.departmentid is not null and er.employeenumber is not null                              
				AND ((IsNULL(a.compdate,'1/1/1900') > DATEADD(m,-6,@PaperReleaseStartDate) AND IsNULL(a.compdate,'1/1/1900') <= @PaperReleaseEndDate
				AND IsNull(er.LastStartDate, er.OriginalStartDate) >= @PaperReleaseStartDate and IsNull(er.LastStartDate, er.OriginalStartDate) < @PaperReleaseEndDate)
				OR (IsNULL(a.compdate,'1/1/1900') >= @PaperReleaseStartDate AND IsNULL(a.compdate,'1/1/1900') <= @PaperReleaseEndDate)) 
				AND a.apstatus = 'F' 
				--AND (SELECT Count(*) from reportuploadlog r WITH (NOLOCK) where r.ReportID = br.backgroundreportid and r.resend = 0 AND r.ReportType = 1) = 0                
				AND (a.clno in (select clno from clienthierarchybyservice WITH (NOLOCK) where parentclno = @CLNO and refhierarchyserviceid = 1 ))
				--AND a.APNO = 2793940
				--AND A.APNO IN (SELECT DISTINCT a.APNO
				--               FROM dbo.Appl a(NOLOCK) 
				--               INNER JOIN dbo.ApplFile af(nolock) ON a.APNO = af.APNO AND af.refApplFileType = 2
				--               WHERE A.CLNO IN (select clno from clienthierarchybyservice WITH (NOLOCK) where parentclno = @CLNO and refhierarchyserviceid = 1 ) ) 
				AND A.CLNO != 7898
			) as idTable 
			INNER JOIN BackgroundReports.dbo.BackgroundReport br WITH (NOLOCK) on br.apno = idTable.apno
			and  br.CreateDate = (Select MAX(createdate) from BackgroundReports.dbo.BackgroundReport WITH (NOLOCK) where apno = idTable.apno)
			--AND (SELECT Count(*) from reportuploadlog r WITH (NOLOCK) where r.ReportID = br.backgroundreportid and r.resend = 0 AND r.ReportType = 1) = 0
                   
		--SELECT * FROM #tmp

		INSERT INTO #tmpPaperReleases
		SELECT FolderID, clno, ReportID, employeeNumber, ClientFacilityGroup 
		FROM(
			SELECT * FROM #tmp
		UNION ALL
			select  idtable.apno as FolderID,idtable.clno, idTable.apno AS ReportID,idtable.employeeNumber, isnull(ClientFacilityGroup,'NonGrouped') as ClientFacilityGroup --schapyala returning emptystring for facilitygroup as this is not used for BG purposes - 05/04/2015
			from (
					SELECT DISTINCT  a.apno,cast(a.clno as int) as clno ,'000000000' employeeNumber, 'NonGrouped' as ClientFacilityGroup
					FROM   PRECHECK.DBO.appl a  WITH (NOLOCK) 
					INNER JOIN BackgroundReports.dbo.BackgroundReport br WITH (NOLOCK) on a.apno = br.apno  
					WHERE ((IsNULL(a.compdate,'1/1/1900') > DATEADD(m,-6,@PaperReleaseStartDate) AND IsNULL(a.compdate,'1/1/1900') <= @PaperReleaseEndDate
						--AND IsNull(er.LastStartDate, er.OriginalStartDate) >= @PaperReleaseStartDate and IsNull(er.LastStartDate, er.OriginalStartDate) < @PaperReleaseEndDate)
						)OR (IsNULL(a.compdate,'1/1/1900') >= @PaperReleaseStartDate AND IsNULL(a.compdate,'1/1/1900') <= @PaperReleaseEndDate))
					AND a.apstatus = 'F' 
					--AND (SELECT Count(*) from reportuploadlog r WITH (NOLOCK) where r.ReportID = br.backgroundreportid and r.resend = 0 AND r.ReportType = 1) = 0                
					AND ( a.clno in (select clno from clienthierarchybyservice WITH (NOLOCK) where parentclno = @CLNO and refhierarchyserviceid = 1 ))
					--AND a.APNO = 2793940
					--AND A.APNO IN (SELECT DISTINCT a.APNO
					--               FROM dbo.Appl a(NOLOCK) 
					--               INNER JOIN dbo.ApplFile af(nolock) ON a.APNO = af.APNO AND af.refApplFileType = 2
					--                WHERE A.CLNO IN (select clno from clienthierarchybyservice WITH (NOLOCK) where parentclno = @CLNO and refhierarchyserviceid = 1 ) 
					--              )
					AND A.CLNO != 7898
					AND A.APNO NOT IN (SELECT FolderID FROM #tmp)
				) as idTable 
				INNER JOIN BackgroundReports.dbo.BackgroundReport br WITH (NOLOCK) on br.apno = idTable.apno
				and br.CreateDate = (Select MAX(createdate) from BackgroundReports.dbo.BackgroundReport WITH (NOLOCK) where apno = idTable.apno)
			) AS Y

		------------------------------------- END OF Paper Releases for all the Sub -------------------------------------------     

		--SELECT * FROM #tmpPaperReleases

		INSERT INTO #tmp1
		SELECT  idtable.apno as FolderID, idtable.clno, br.backgroundreportid AS ReportID,idtable.employeeNumber, isnull(ClientFacilityGroup,'NonGrouped') as ClientFacilityGroup --schapyala returning emptystring for facilitygroup as this is not used for BG purposes - 05/04/2015
		FROM (
				SELECT DISTINCT  a.apno,cast(a.clno as int) as clno ,er.employeeNumber, 'NonGrouped' as ClientFacilityGroup
				FROM HEVN.dbo.EmployeeRecord er WITH (NOLOCK) 
				INNER JOIN  HEVN.dbo.Facility F WITH (NOLOCK) on er.facilityid = F.facilityid         
				INNER JOIN  PRECHECK.DBO.appl a  WITH (NOLOCK) on ER.ssn = a.ssn 
				INNER JOIN BackgroundReports.dbo.BackgroundReport br WITH (NOLOCK) on a.apno = br.apno 
				WHERE (F.ParentEmployerID=@CLNO OR F.EmployerID=@CLNO)
				AND er.facilityid is not null and er.departmentid is not null and er.employeenumber is not null                              
				AND ((IsNULL(a.compdate,'1/1/1900') > DATEADD(m,-6,@StartDate) AND IsNULL(a.compdate,'1/1/1900') <= @EndDate
				AND IsNull(er.LastStartDate, er.OriginalStartDate) >= @StartDate and IsNull(er.LastStartDate, er.OriginalStartDate) < @EndDate)
				OR (IsNULL(a.compdate,'1/1/1900') >= @StartDate AND IsNULL(a.compdate,'1/1/1900') <= @EndDate))
				AND a.apstatus = 'F' 
				--AND a.APNO = 2793940
				AND (SELECT Count(*) from reportuploadlog r WITH (NOLOCK) where r.ReportID = br.backgroundreportid and r.resend = 0 AND r.ReportType = 1) = 0                
				AND (a.clno = @CLNO --OR a.clno in (select clno from clienthierarchybyservice WITH (NOLOCK) where parentclno = @CLNO and refhierarchyserviceid = 1 )
				)
				--AND a.clno = @CLNO
				) as idTable 
				INNER JOIN BackgroundReports.dbo.BackgroundReport br WITH (NOLOCK) on br.apno = idTable.apno
				and  br.CreateDate = (Select MAX(createdate) from BackgroundReports.dbo.BackgroundReport WITH (NOLOCK) where apno = idTable.apno)
				AND (SELECT Count(*) from reportuploadlog r WITH (NOLOCK) where r.ReportID = br.backgroundreportid and r.resend = 0 AND r.ReportType = 1) = 0
                             
		--SELECT * FROM #tmp
		INSERT INTO #tmp7898
		SELECT FolderID, clno, ReportID, employeeNumber, ClientFacilityGroup                             
		FROM(
			SELECT * FROM #tmp1
		UNION ALL
			select  idtable.apno as FolderID,idtable.clno, idTable.apno AS ReportID,idtable.employeeNumber, isnull(ClientFacilityGroup,'NonGrouped') as ClientFacilityGroup --schapyala returning emptystring for facilitygroup as this is not used for BG purposes - 05/04/2015
			from (
					SELECT DISTINCT  a.apno,cast(a.clno as int) as clno ,'000000000' employeeNumber, 'NonGrouped' as ClientFacilityGroup
					FROM   PRECHECK.DBO.appl a  WITH (NOLOCK) 
					INNER JOIN BackgroundReports.dbo.BackgroundReport br WITH (NOLOCK) on a.apno = br.apno  
					WHERE  ((IsNULL(a.compdate,'1/1/1900') > DATEADD(m,-6,@StartDate) AND IsNULL(a.compdate,'1/1/1900') <= @EndDate
					--AND IsNull(er.LastStartDate, er.OriginalStartDate) >= @StartDate and IsNull(er.LastStartDate, er.OriginalStartDate) < @EndDate)
					)OR (IsNULL(a.compdate,'1/1/1900') >= @StartDate AND IsNULL(a.compdate,'1/1/1900') <= @EndDate))
					AND a.apstatus = 'F' 
					AND (SELECT Count(*) from reportuploadlog r WITH (NOLOCK) where r.ReportID = br.backgroundreportid and r.resend = 0 AND r.ReportType = 1) = 0                
					AND (a.clno = @CLNO --OR a.clno in (select clno from clienthierarchybyservice WITH (NOLOCK) where parentclno = @CLNO and refhierarchyserviceid = 1 )
					)
					--AND a.clno = @CLNO
					--AND a.APNO = 2793940
					AND A.APNO NOT IN (SELECT FolderID FROM #tmp1)
				) as idTable 
				INNER JOIN BackgroundReports.dbo.BackgroundReport br WITH (NOLOCK) on br.apno = idTable.apno
				and br.CreateDate = (Select MAX(createdate) from BackgroundReports.dbo.BackgroundReport WITH (NOLOCK) where apno = idTable.apno)
				AND (SELECT Count(*) from reportuploadlog r WITH (NOLOCK) where r.ReportID = br.backgroundreportid and r.resend = 0 AND r.ReportType = 1) = 0
			) AS Y

			--SELECT * FROM #tmp7898

			-- COMBINE Paper Releases and all the others
			SELECT * FROM #tmpPaperReleases r(nolock) WHERE r.FolderID NOT IN (2213122,2248654,2249154,2399323,3237008,3529992,3778242,4287964,4288429,4295835,4295869)
			UNION ALL
			SELECT * FROM #tmp7898 t(nolock) WHERE t.FolderID NOT IN (2213122,2248654,2249154,2399323,3237008,3529992,3778242,4287964,4288429,4295835,4295869)

	END

   DROP TABLE #tmp
   DROP TABLE #tmp1
   DROP TABLE #tmpPaperReleases
   DROP TABLE #tmp7898

END
