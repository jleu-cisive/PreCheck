
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- Modified by Nirod Kumar : On select statement removed the casting of apno to varchar and added casting clno to int because its clno is smallint in appl table.
--                           and the output data type for all the procedure in BulkReportUploader has to be consistent.
-- Execution: EXEC [BGReportMainPull_Presbyterian_PaperReleases] 7898, '2016-02-22','01/02/2018',1
-- =============================================

CREATE PROCEDURE [dbo].[BGReportMainPull_Presbyterian_PaperReleases]
	@CLNO int, @StartDate datetime,@EndDate datetime,@UseHevnDb bit = 1
AS
BEGIN

------------------Please use this section for manual reruns-------------------------------------
SET @CLNO = 7898;
SET @StartDate = '01/01/2010'--DATEADD(m,-4,getdate());
Set @EndDate = '08/01/2018';

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
				
					--AND (SELECT Count(*) from reportuploadlog r WITH (NOLOCK) where r.ReportID = br.backgroundreportid and r.resend = 0 AND r.ReportType = 1) = 0		
					AND (a.clno = @CLNO OR a.clno in (select clno from clienthierarchybyservice WITH (NOLOCK) where parentclno = @CLNO and refhierarchyserviceid = 1 ))
					AND A.APNO IN (SELECT DISTINCT a.APNO
									FROM dbo.Appl a(NOLOCK) 
									INNER JOIN dbo.ApplFile af(nolock) ON a.APNO = af.APNO AND af.refApplFileType = 2
									WHERE A.CLNO = @CLNO 
									AND a.APNO IN (3296453,3441716)
									 -- AND A.APNO IN (
										--------1650467,
										--------1675986,
										--------2169389,
										------1915479,
										------1918461,
										------3585538,
										------3587376
									 -- )
--									  AND A.APNO IN (
--1585342,
--1615693,
--1613933)
--									AND a.APNO NOT IN (1511432,
--1544960,
--1550927,
--1552510,
--1730369,
--1736844,
--1740230,
--1748685,
--1748838,
--1749639,
--1750635,
--1754130,
--1755497,
--1773169,
--1786579,
--1793360,
--1800587,
--1801036,
--1807463,
--1808729,
--1813983,
--1814677,
--1816012,
--1818332,
--1819286,
--1819535,
--1819746,
--1838256,
--1839600,
--1842200,
--1845793,
--1846076,
--1869897,
--1935036,
--1974375,
--2314056,
--2377500,
--2538487,
--2565531,
--2593688,
--2706784,
--2719375,
--2750545,
--2814166,
--2850490,
--2861377,
--2871023,
--2940068,
--2970483,
--3293113,
--3347606,
--3471665,
--3807122,
--4087948,
--4094235,
--4115576,
--1723799,
--1727286,
--1766667,
--1820866,
--1821681,
--1822069,
--1822623,
--1828898,
--1829015
--)
)
			) as idTable 
			INNER JOIN BackgroundReports.dbo.BackgroundReport br WITH (NOLOCK) on br.apno = idTable.apno
			and  br.CreateDate = (Select MAX(createdate) from BackgroundReports.dbo.BackgroundReport WITH (NOLOCK) where apno = idTable.apno)
			--AND (SELECT Count(*) from reportuploadlog r WITH (NOLOCK) where r.ReportID = br.backgroundreportid and r.resend = 0 AND r.ReportType = 1) = 0
		
	--SELECT * FROM #tmp

	SELECT FolderID, clno, ReportID, employeeNumber, ClientFacilityGroup		
	FROM(
		SELECT * FROM #tmp
	UNION ALL
		
		select  idtable.apno as FolderID,idtable.clno, idTable.apno AS ReportID,idtable.employeeNumber, isnull(ClientFacilityGroup,'NonGrouped') as ClientFacilityGroup --schapyala returning emptystring for facilitygroup as this is not used for BG purposes - 05/04/2015
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
							AND A.APNO IN (SELECT DISTINCT a.APNO
											FROM dbo.Appl a(NOLOCK) 
											INNER JOIN dbo.ApplFile af(nolock) ON a.APNO = af.APNO AND af.refApplFileType = 2
											WHERE A.CLNO = @CLNO 
											  AND a.APNO IN (3296453,3441716)
											  --AND A.APNO IN (
													--	--1650467,
													--	--1675986,
													--	--2169389,
													--	1915479,
													--	1918461,
													--	3585538,
													--	3587376
											  --)
--											  AND A.APNO IN (
--1585342,
--1615693,
--1613933)
--											AND a.APNO NOT IN (1511432,
--1544960,
--1550927,
--1552510,
--1730369,
--1736844,
--1740230,
--1748685,
--1748838,
--1749639,
--1750635,
--1754130,
--1755497,
--1773169,
--1786579,
--1793360,
--1800587,
--1801036,
--1807463,
--1808729,
--1813983,
--1814677,
--1816012,
--1818332,
--1819286,
--1819535,
--1819746,
--1838256,
--1839600,
--1842200,
--1845793,
--1846076,
--1869897,
--1935036,
--1974375,
--2314056,
--2377500,
--2538487,
--2565531,
--2593688,
--2706784,
--2719375,
--2750545,
--2814166,
--2850490,
--2861377,
--2871023,
--2940068,
--2970483,
--3293113,
--3347606,
--3471665,
--3807122,
--4087948,
--4094235,
--4115576,
--1723799,
--1727286,
--1766667,
--1820866,
--1821681,
--1822069,
--1822623,
--1828898,
--1829015)
											)
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

END