
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- Modified by Nirod Kumar : On select statement removed the casting of apno to varchar and added casting clno to int because its clno is smallint in appl table.
--                           and the output data type for all the procedure in BulkReportUploader has to be consistent.
-- Execution: EXEC [BGReportMainPull_Presbyterian] 7898, '09/03/2019','07/03/2019',1
-- =============================================

CREATE PROCEDURE [dbo].[BGReportMainPull_Presbyterian]
	@CLNO int, @StartDate datetime,@EndDate datetime,@UseHevnDb bit = 1
AS
BEGIN

------------------Please use this section for manual reruns-------------------------------------
--SET @CLNO = 7898;
--SET @StartDate = '12/01/2018'--DATEADD(m,-4,getdate());
--Set @EndDate = '02/26/2019';

--insert into winservicelog (logdate,logmessage) values(getdate(),'MethodistParams: ' + cast(@CLNO as varchar(20)) + ' ' + convert(varchar,@StartDate,101) + ' ' + convert(varchar,@EndDate,101));
------------------manual reruns-------------------------------------
--SET @StartDate = '11/01/2014'--DATEADD(m,-4,getdate());
--Set @EndDate = '01/01/2015';
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.

If(@UseHevnDb = 1)
 BEGIN

	--DECLARE temp tables (helps to maintain the same plan regardless of stats change)
	CREATE TABLE #tmp(
		[FolderID] [int] NOT NULL,
		[CLNO] [smallint] NOT NULL,
		[ReportID] [int] NOT NULL,
		[EmployeeNumber] [varchar](50) NOT NULL,
		[ClientFacilityGroup] [varchar](50) NULL)

	CREATE CLUSTERED INDEX IX_tmp2_01 ON #tmp([FolderID])


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
		
					----schapyala changed enddate to '1/1/1900' for the isnull default for compdate below. - 02/03/2015
						AND ((IsNULL(a.compdate,'1/1/1900') > DATEADD(m,-6,@StartDate) AND IsNULL(a.compdate,'1/1/1900') <= @EndDate
						AND IsNull(er.LastStartDate, er.OriginalStartDate) >= @StartDate and IsNull(er.LastStartDate, er.OriginalStartDate) < @EndDate)
						OR (IsNULL(a.compdate,'1/1/1900') >= @StartDate AND IsNULL(a.compdate,'1/1/1900') <= @EndDate))
					----------- End Schayala --------
	
					AND a.apstatus = 'F' 
				
					AND (SELECT Count(*) from reportuploadlog r WITH (NOLOCK) where r.ReportID = br.backgroundreportid and r.resend = 0 AND r.ReportType = 1) = 0		
					AND (a.clno = @CLNO OR a.clno in (select clno from clienthierarchybyservice WITH (NOLOCK) where parentclno = @CLNO and refhierarchyserviceid = 1 ))
			) as idTable 
			INNER JOIN BackgroundReports.dbo.BackgroundReport br WITH (NOLOCK) on br.apno = idTable.apno
			and  br.CreateDate = (Select MAX(createdate) from BackgroundReports.dbo.BackgroundReport WITH (NOLOCK) where apno = idTable.apno)
			AND (SELECT Count(*) from reportuploadlog r WITH (NOLOCK) where r.ReportID = br.backgroundreportid and r.resend = 0 AND r.ReportType = 1) = 0
		
	--SELECT * FROM #tmp

	SELECT FolderID, clno, ReportID, employeeNumber, ClientFacilityGroup		
	FROM(
		SELECT  FolderID, clno,  ReportID,employeeNumber,  ClientFacilityGroup FROM #tmp
	UNION ALL
		
		select  idtable.apno as FolderID,idtable.clno, br.backgroundreportid AS ReportID,idtable.employeeNumber, isnull(ClientFacilityGroup,'NonGrouped') as ClientFacilityGroup --schapyala returning emptystring for facilitygroup as this is not used for BG purposes - 05/04/2015
		from (
			SELECT DISTINCT  a.apno,cast(a.clno as int) as clno ,'000000000' employeeNumber, 'NonGrouped' as ClientFacilityGroup
			FROM   PRECHECK.DBO.appl a  WITH (NOLOCK) 
				INNER JOIN BackgroundReports.dbo.BackgroundReport br WITH (NOLOCK) on a.apno = br.apno  

			WHERE 
					----schapyala changed enddate to '1/1/1900' for the isnull default for compdate below. - 02/03/2015
						 ((IsNULL(a.compdate,'1/1/1900') > DATEADD(m,-6,@StartDate) AND IsNULL(a.compdate,'1/1/1900') <= @EndDate
						--AND IsNull(er.LastStartDate, er.OriginalStartDate) >= @StartDate and IsNull(er.LastStartDate, er.OriginalStartDate) < @EndDate)
						)OR (IsNULL(a.compdate,'1/1/1900') >= @StartDate AND IsNULL(a.compdate,'1/1/1900') <= @EndDate))
					----------- End Schayala --------
					AND a.apstatus = 'F' 
				
					AND (SELECT Count(*) from reportuploadlog r WITH (NOLOCK) where r.ReportID = br.backgroundreportid and r.resend = 0 AND r.ReportType = 1) = 0		
					AND (a.clno = @CLNO OR a.clno in (select clno from clienthierarchybyservice WITH (NOLOCK) where parentclno = @CLNO and refhierarchyserviceid = 1 ))
					AND A.APNO NOT IN (SELECT FolderID FROM #tmp)
			) as idTable 
			INNER JOIN BackgroundReports.dbo.BackgroundReport br WITH (NOLOCK) on br.apno = idTable.apno
			and br.CreateDate = (Select MAX(createdate) from BackgroundReports.dbo.BackgroundReport WITH (NOLOCK) where apno = idTable.apno)
			AND (SELECT Count(*) from reportuploadlog r WITH (NOLOCK) where r.ReportID = br.backgroundreportid and r.resend = 0 AND r.ReportType = 1) = 0
		) AS Y
 End

   DROP TABLE #tmp

END

/*
-- VD: 12/14/2018 -- Removed all the commented code.

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
		
					----schapyala changed enddate to '1/1/1900' for the isnull default for compdate below. - 02/03/2015
						AND ((IsNULL(a.compdate,'1/1/1900') > DATEADD(m,-6,@StartDate) AND IsNULL(a.compdate,'1/1/1900') <= @EndDate
						AND IsNull(er.LastStartDate, er.OriginalStartDate) >= @StartDate and IsNull(er.LastStartDate, er.OriginalStartDate) < @EndDate)
						OR (IsNULL(a.compdate,'1/1/1900') >= @StartDate AND IsNULL(a.compdate,'1/1/1900') <= @EndDate))
					----------- End Schayala --------
	
					AND a.apstatus = 'F' 
				
					--AND (SELECT Count(*) from reportuploadlog r WITH (NOLOCK) where r.ReportID = br.backgroundreportid and r.resend = 0 AND r.ReportType = 1) = 0		
					AND (a.clno = @CLNO OR a.clno in (select clno from clienthierarchybyservice WITH (NOLOCK) where parentclno = @CLNO and refhierarchyserviceid = 1 ))
					--AND a.clno = @CLNO
					--AND A.APNO IN (SELECT DISTINCT a.APNO
					--				FROM dbo.Appl a(NOLOCK) 
					--				INNER JOIN dbo.ApplFile af(nolock) ON a.APNO = af.APNO AND af.refApplFileType = 2
					--				WHERE A.CLNO = @CLNO 
					--			 )
			) as idTable 
			INNER JOIN BackgroundReports.dbo.BackgroundReport br WITH (NOLOCK) on br.apno = idTable.apno
			and  br.CreateDate = (Select MAX(createdate) from BackgroundReports.dbo.BackgroundReport WITH (NOLOCK) where apno = idTable.apno)
			--AND (SELECT Count(*) from reportuploadlog r WITH (NOLOCK) where r.ReportID = br.backgroundreportid and r.resend = 0 AND r.ReportType = 1) = 0
		
	--SELECT * FROM #tmp

	SELECT FolderID, clno, ReportID, employeeNumber, ClientFacilityGroup		
	FROM(
		SELECT * FROM #tmp
	UNION ALL
		
		select  idtable.apno as FolderID,idtable.clno, br.backgroundreportid AS ReportID,idtable.employeeNumber, isnull(ClientFacilityGroup,'NonGrouped') as ClientFacilityGroup --schapyala returning emptystring for facilitygroup as this is not used for BG purposes - 05/04/2015
		from (
			SELECT DISTINCT  a.apno,cast(a.clno as int) as clno ,'000000000' employeeNumber, 'NonGrouped' as ClientFacilityGroup
			FROM   PRECHECK.DBO.appl a  WITH (NOLOCK) 
				INNER JOIN BackgroundReports.dbo.BackgroundReport br WITH (NOLOCK) on a.apno = br.apno  

			WHERE 
					----schapyala changed enddate to '1/1/1900' for the isnull default for compdate below. - 02/03/2015
						 ((IsNULL(a.compdate,'1/1/1900') > DATEADD(m,-6,@StartDate) AND IsNULL(a.compdate,'1/1/1900') <= @EndDate
						--AND IsNull(er.LastStartDate, er.OriginalStartDate) >= @StartDate and IsNull(er.LastStartDate, er.OriginalStartDate) < @EndDate)
						)OR (IsNULL(a.compdate,'1/1/1900') >= @StartDate AND IsNULL(a.compdate,'1/1/1900') <= @EndDate))
					----------- End Schayala --------
					AND a.apstatus = 'F' 
				
					--AND (SELECT Count(*) from reportuploadlog r WITH (NOLOCK) where r.ReportID = br.backgroundreportid and r.resend = 0 AND r.ReportType = 1) = 0		
					AND (a.clno = @CLNO OR a.clno in (select clno from clienthierarchybyservice WITH (NOLOCK) where parentclno = @CLNO and refhierarchyserviceid = 1 ))
					--AND a.clno = @CLNO
							--AND A.APNO IN (SELECT DISTINCT a.APNO
							--				FROM dbo.Appl a(NOLOCK) 
							--				INNER JOIN dbo.ApplFile af(nolock) ON a.APNO = af.APNO AND af.refApplFileType = 2
							--				WHERE A.CLNO = @CLNO 
  					--					  )
					AND A.APNO NOT IN (SELECT FolderID FROM #tmp)
			) as idTable 
			INNER JOIN BackgroundReports.dbo.BackgroundReport br WITH (NOLOCK) on br.apno = idTable.apno
			and br.CreateDate = (Select MAX(createdate) from BackgroundReports.dbo.BackgroundReport WITH (NOLOCK) where apno = idTable.apno)
			--AND (SELECT Count(*) from reportuploadlog r WITH (NOLOCK) where r.ReportID = br.backgroundreportid and r.resend = 0 AND r.ReportType = 1) = 0
			--AND idTable.APNO IN (SELECT DISTINCT a.APNO
			--	FROM dbo.Appl a(NOLOCK) 
			--	INNER JOIN dbo.ApplFile af(nolock) ON a.APNO = af.APNO AND af.refApplFileType = 2
			--	WHERE A.CLNO = 7898 )
		) AS Y
 End

   DROP TABLE #tmp

*/