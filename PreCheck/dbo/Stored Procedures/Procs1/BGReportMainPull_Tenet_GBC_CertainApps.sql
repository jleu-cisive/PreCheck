
-- =============================================
-- Author:		Prasanna
-- Create date: 04/01/2021
-- Description:	Modified existing procedure BGReportMainPull_Methodist
-- Execution: EXEC [BGReportMainPull_Tenet_GBC_CertainApps] 15660, '01/01/2019','05/07/2021',1
-- =============================================

CREATE PROCEDURE [dbo].[BGReportMainPull_Tenet_GBC_CertainApps]
	@CLNO int, @StartDate datetime,@EndDate datetime,@UseHevnDb bit = 1
AS
BEGIN

	--SET @CLNO = 12444;
	SET @StartDate = '01/01/2019'--DATEADD(m,-4,getdate());
	Set @EndDate = '05/07/2021';

	If(@UseHevnDb = 1)
	 BEGIN

		--DECLARE temp tables (helps to maintain the same plan regardless of stats change)
		CREATE TABLE #tmp(
			[FolderID] [int] NOT NULL,
			[CLNO] [smallint] NOT NULL,
			[ReportID] [int] NOT NULL,
			[LastName] [varchar](100) NOT NULL,
			[FirstName] [varchar](100) NOT NULL,
			[EmployeeNumber] [varchar](50) NOT NULL,
			[ClientFacilityGroup] [varchar](50) NULL)

		CREATE CLUSTERED INDEX IX_tmp2_01 ON #tmp([FolderID])


			INSERT INTO #tmp
			SELECT  idtable.apno as FolderID, idtable.clno, br.backgroundreportid AS ReportID,LastName, FirstName,idtable.employeeNumber, isnull(ClientFacilityGroup,'NonGrouped') as ClientFacilityGroup --schapyala returning emptystring for facilitygroup as this is not used for BG purposes - 05/04/2015
			FROM (
				SELECT DISTINCT  a.apno,cast(a.clno as int) as clno ,a.Last as [LastName], a.First as [FirstName],er.employeeNumber, 'NonGrouped' as ClientFacilityGroup
				FROM HEVN.dbo.EmployeeRecord er WITH (NOLOCK) 
					INNER JOIN  HEVN.dbo.Facility F WITH (NOLOCK) on er.facilityid = F.facilityid	
					INNER JOIN  PRECHECK.DBO.appl a  WITH (NOLOCK) on ER.ssn = a.ssn 
					INNER JOIN dbo.Client c(NOLOCK) ON A.CLNO = c.CLNO
					INNER JOIN BackgroundReports.dbo.BackgroundReport br WITH (NOLOCK) on a.apno = br.apno 
				WHERE (F.ParentEmployerID=@CLNO OR F.EmployerID=@CLNO)
						AND er.facilityid is not null and er.departmentid is not null and er.employeenumber is not null			
		
						----schapyala changed enddate to '1/1/1900' for the isnull default for compdate below. - 02/03/2015
							AND ((IsNULL(a.compdate,'1/1/1900') > DATEADD(m,-6,@StartDate) AND IsNULL(a.compdate,'1/1/1900') <= @EndDate
							AND IsNull(er.LastStartDate, er.OriginalStartDate) >= @StartDate and IsNull(er.LastStartDate, er.OriginalStartDate) < @EndDate)
							OR (IsNULL(a.compdate,'1/1/1900') >= @StartDate AND IsNULL(a.compdate,'1/1/1900') <= @EndDate))
						----------- End Schayala --------
	
						AND a.apstatus = 'F' 
						AND a.Apno in (5434221, 5431115, 5433582, 5434369, 5431424, 5433958, 5436300, 5431112, 5431168, 5433915, 5432528, 5434381, 5481477, 
						5485167, 5479285, 5479193, 5478997, 5478991, 5480384, 5481479, 5480238, 5478998, 5481472, 5484608, 5483896, 5479007, 5479427, 5479023, 
						5479177, 5483552, 5479066, 5483493, 5484074, 5481626, 5483860, 5479264, 5483880, 5481526, 5479008, 5483778, 5481477, 5483649, 5481475, 
						5483942, 5488700, 5488635, 5491054, 5505720, 5502930, 5500769, 5510875, 5510208, 5526713, 5508595, 5513652, 5530157, 5531587, 5532003, 
						5532610, 5581263, 5578428, 5591376, 5598927, 5591326, 5593629, 5593120, 5593880, 5596807, 5606172, 5604396, 5606029, 5606170, 5615738, 
						5618189, 5615309, 5616084, 5615253, 5615409, 5622588, 5615255, 5620173, 5628227, 5631842, 5641651, 5643995, 5655098, 5664793, 5654562, 
						5656957, 5654563, 5669208, 5670432, 5684849, 5687167, 5684786, 5682319, 5682762, 5694881, 5712586, 5708464, 5710328, 5710574, 5708478, 
						5727227, 5722368, 5724500, 5725300, 5736854, 5736645, 5551658, 5550761, 5555011, 5556546, 5682367, 5742684, 5738409, 5742928, 5742687)
	
						--AND (SELECT Count(*) from reportuploadlog r WITH (NOLOCK) where r.ReportID = br.backgroundreportid and r.resend = 0 AND r.ReportType = 1) = 0		
						AND (C.CLNO = @CLNO OR a.clno in (select clno from clienthierarchybyservice WITH (NOLOCK) where parentclno = @CLNO and refhierarchyserviceid = 1 ))
				) as idTable 
				INNER JOIN BackgroundReports.dbo.BackgroundReport br WITH (NOLOCK) on br.apno = idTable.apno
				and  br.CreateDate = (Select MAX(createdate) from BackgroundReports.dbo.BackgroundReport WITH (NOLOCK) where apno = idTable.apno)
				--AND (SELECT Count(*) from reportuploadlog r WITH (NOLOCK) where r.ReportID = br.backgroundreportid and r.resend = 0 AND r.ReportType = 1) = 0
				
		--SELECT * FROM #tmp

		SELECT FolderID, clno, ReportID, lastname, firstname,employeeNumber, ClientFacilityGroup		
		FROM(
			SELECT * FROM #tmp
		UNION ALL
		
			select  idtable.apno as FolderID,idtable.clno, br.backgroundreportid AS ReportID,lastname, firstname,idtable.employeeNumber, isnull(ClientFacilityGroup,'NonGrouped') as ClientFacilityGroup --schapyala returning emptystring for facilitygroup as this is not used for BG purposes - 05/04/2015
			from (
				SELECT DISTINCT  a.apno,cast(a.clno as int) as clno ,a.Last as [LastName], a.First as [FirstName],'000000000' employeeNumber, 'NonGrouped' as ClientFacilityGroup
				FROM   PRECHECK.DBO.appl a  WITH (NOLOCK) 
					INNER JOIN BackgroundReports.dbo.BackgroundReport br WITH (NOLOCK) on a.apno = br.apno  
					INNER JOIN dbo.Client c(NOLOCK) ON A.CLNO = c.CLNO
				WHERE 
						----schapyala changed enddate to '1/1/1900' for the isnull default for compdate below. - 02/03/2015
							 ((IsNULL(a.compdate,'1/1/1900') > DATEADD(m,-6,@StartDate) AND IsNULL(a.compdate,'1/1/1900') <= @EndDate
							--AND IsNull(er.LastStartDate, er.OriginalStartDate) >= @StartDate and IsNull(er.LastStartDate, er.OriginalStartDate) < @EndDate)
							)OR (IsNULL(a.compdate,'1/1/1900') >= @StartDate AND IsNULL(a.compdate,'1/1/1900') <= @EndDate))
						----------- End Schayala --------
						AND a.apstatus = 'F' 
				
						AND (SELECT Count(*) from reportuploadlog r WITH (NOLOCK) where r.ReportID = br.backgroundreportid and r.resend = 0 AND r.ReportType = 1) = 0		
						AND (C.CLNO = @CLNO OR a.clno in (select clno from clienthierarchybyservice WITH (NOLOCK) where parentclno = @CLNO and refhierarchyserviceid = 1 ))
						AND A.APNO NOT IN (SELECT FolderID FROM #tmp)
				) as idTable 
				INNER JOIN BackgroundReports.dbo.BackgroundReport br WITH (NOLOCK) on br.apno = idTable.apno
				and br.CreateDate = (Select MAX(createdate) from BackgroundReports.dbo.BackgroundReport WITH (NOLOCK) where apno = idTable.apno)
				AND (SELECT Count(*) from reportuploadlog r WITH (NOLOCK) where r.ReportID = br.backgroundreportid and r.resend = 0 AND r.ReportType = 1) = 0
			) AS Y
	 End

	   DROP TABLE #tmp

END

