-- =============================================
-- Author:		DEEPAK VODETHELA
-- Create date: 04/18/2018
-- Description:	<Description,,>
-- Execution: EXEC [dbo].[BGReleaseMainPull_Presbyterian_deepak] 7898, '2016-02-22','01/02/2018',1
-- =============================================
CREATE PROCEDURE [dbo].[BGReleaseMainPull_Presbyterian_deepak]
	
	@CLNO int, @StartDate datetime=null,@EndDate datetime=null, @UseHevnDb bit = 1

AS
BEGIN

SET @CLNO = 7898;
SET @StartDate = '01/01/2010'--DATEADD(m,-4,getdate());
Set @EndDate = '08/01/2018';

 if(@UseHevnDb = 1)
   BEGIN

	--DECLARE temp tables (helps to maintain the same plan regardless of stats change)
		CREATE TABLE #tmp(
			[FolderID] [int] NOT NULL,
			[APNO] [int] NOT NULL,
			[ImageFileName] varchar(150) NULL,
			[CLNO] [smallint] NOT NULL,
			[ReportID] [int] NOT NULL,
			[EmployeeNumber] varchar(50) NULL,
			[ClientFacilityGroup] varchar(50) NULL)

		CREATE CLUSTERED INDEX IX_tmp2200_01 ON #tmp([FolderID])

		INSERT INTO #tmp
 			select idTable.releaseformid as FolderID,idtable.apno,idtable.imagefilename,idtable.clno,idtable.releaseformid as ReportID,idtable.employeeNumber,idtable.ClientFacilityGroup 
			from (
				SELECT DISTINCT aa.applfileid as releaseformid,a.apno,aa.imagefilename,a.clno,er.employeeNumber,a.ssn,F.ClientFacilityGroup
				FROM HEVN.dbo.EmployeeRecord er WITH (NOLOCK) 
				INNER JOIN  HEVN.dbo.Facility F WITH (NOLOCK) on er.facilityid = F.facilityid	
				INNER JOIN  appl a  WITH (NOLOCK) on a.ssn = er.ssn	  
				inner join applfile aa with(nolock) on aa.apno = a.apno
				WHERE aa.refapplfiletype = 2 and isnull(aa.deleted,0) = 0
				and (F.ParentEmployerID=@CLNO OR F.EmployerID=@CLNO)
				AND er.facilityid is not null and er.departmentid is not null and er.employeenumber is not null
				AND (SELECT Count(*) from reportuploadlog r WITH (NOLOCK) where r.ReportID = aa.applfileid and r.resend = 0 AND r.ReportType = 2) = 0		
				AND IsNull(er.LastStartDate, er.OriginalStartDate) >= @StartDate and IsNull(er.LastStartDate, er.OriginalStartDate) < @EndDate--cutoff
				--AND (a.clno = @CLNO OR a.clno in (select clno from clienthierarchybyservice WITH (NOLOCK) where parentclno = @CLNO and refhierarchyserviceid = 1 ))
				and a.clno = @CLNO	
				--and applfileid in (2123846,2137241,2151429,2165380,2183050,2205122,2253963,2279506)
				) as idTable 
				where (SELECT Count(*) from reportuploadlog r WITH (NOLOCK) where r.ReportID = idTable.releaseformid and r.resend = 0 AND r.ReportType = 2) = 0		
				

				select  FolderID, apno,imagefilename,clno,ReportID,employeeNumber,ClientFacilityGroup INTO #tmp2
				from (
					SELECT * FROM #tmp
				UNION ALL
				select idtable.releaseformid as FolderID,idtable.apno,idtable.imagefilename,idtable.clno,idtable.releaseformid as ReportID,idtable.employeeNumber,idtable.ClientFacilityGroup 
				from (
					SELECT DISTINCT aa.applfileid as releaseformid,a.apno,aa.imagefilename,a.clno,'' as employeeNumber,a.ssn,'' as ClientFacilityGroup
					FROM --HEVN.dbo.EmployeeRecord er WITH (NOLOCK) 
					--INNER JOIN  HEVN.dbo.Facility F WITH (NOLOCK) on er.facilityid = F.facilityid	
					appl a  WITH (NOLOCK) --on a.ssn = er.ssn	  
					inner join applfile aa with(nolock) on aa.apno = a.apno
					WHERE aa.refapplfiletype = 2 and isnull(aa.deleted,0) = 0
					and a.CLNO=@CLNO --(F.ParentEmployerID=@CLNO OR F.EmployerID=@CLNO)
					--AND er.facilityid is not null and er.departmentid is not null and er.employeenumber is not null
					AND (SELECT Count(*) from reportuploadlog r WITH (NOLOCK) where r.ReportID = aa.applfileid and r.resend = 0 AND r.ReportType = 2) = 0		
					--AND IsNull(er.LastStartDate, er.OriginalStartDate) >= @StartDate and IsNull(er.LastStartDate, er.OriginalStartDate) < @EndDate--cutoff
					--AND (a.clno = @CLNO OR a.clno in (select clno from clienthierarchybyservice WITH (NOLOCK) where parentclno = @CLNO and refhierarchyserviceid = 1 ))	
					and a.clno = @CLNO
				  ) as idTable 
				where (SELECT Count(*) from reportuploadlog r WITH (NOLOCK) where r.ReportID = idTable.releaseformid and r.resend = 0 AND r.ReportType = 2) = 0	
				) AS Y
				ORDER BY ClientFacilityGroup

				--select * from #tmp 

			---- Temp
			SELECT DISTINCT TOP 100 x.* FROM dbo.ApplFile af(NOLOCK)
			INNER JOIN	#tmp2 AS X ON af.APNO = x.FolderID	
			WHERE AF.refApplFileType = 2
			--and af.applfileid in (2123846,2137241,2151429,2165380,2183050,2205122,2253963,2279506)
			ORDER BY 1 desc

		DROP TABLE #tmp
		DROP TABLE #tmp2
	END



/*
 if(@UseHevnDb = 1)
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
		SELECT  idtable.releaseformid AS FolderID,idtable.clno,idtable.releaseformid AS ReportID,idtable.employeeNumber,idtable.ClientFacilityGroup 
		FROM (
				SELECT DISTINCT rf.releaseformid,rf.clno,er.employeeNumber,rf.ssn,F.ClientFacilityGroup
				FROM HEVN.dbo.EmployeeRecord er WITH (NOLOCK) 
				INNER JOIN  HEVN.dbo.Facility F WITH (NOLOCK) on er.facilityid = F.facilityid	
				INNER JOIN  ReleaseForm rf WITH (NOLOCK) on rf.ssn = er.ssn	

				WHERE (F.ParentEmployerID=@CLNO OR F.EmployerID=@CLNO)
				  AND er.facilityid is not null AND er.departmentid is not null AND er.employeenumber is not null
				  AND (SELECT Count(*) FROM reportuploadlog r WITH (NOLOCK) WHERE r.ReportID = rf.releaseformid AND r.resend = 0 AND r.ReportType = 2) = 0		
				  AND (( @StartDate is not null and  IsNull(er.LastStartDate, er.OriginalStartDate) >= @StartDate) or(@StartDate is null))
				  AND (( @EndDate is not null and  IsNull(er.LastStartDate, er.OriginalStartDate) < @EndDate) or(@EndDate is null))
				  AND (rf.clno = @CLNO OR rf.clno in (SELECT clno FROM clienthierarchybyservice WITH (NOLOCK) WHERE parentclno = @CLNO AND refhierarchyserviceid = 1 ))
			) AS idTable 
			INNER JOIN ReleaseForm rf WITH (NOLOCK) on rf.ssn = idtable.ssn AND rf.clno = idtable.clno 
			AND  rf.releaseformid = (SELECT Max(releaseformid) AS  releaseformid 
									FROM 
									(
									    SELECT MAX(releaseformid) AS releaseformid,ssn,clno  FROM releaseform WITH (NOLOCK) group by ssn,clno
									
									) rfa   
									WHERE rfa.ssn = idTable.ssn 
									  AND rfa.clno = idtable.clno) 
			AND (SELECT Count(*) FROM reportuploadlog r WITH (NOLOCK) WHERE r.ReportID = rf.releaseformid AND r.resend = 0 AND r.ReportType = 2) = 0		

	SELECT FolderID, clno,ReportID, employeeNumber,ClientFacilityGroup 
	FROM 
		(
			SELECT * FROM #tmp
	UNION ALL

		SELECT  idtable.releaseformid AS FolderID,idtable.clno,idtable.releaseformid AS ReportID,idtable.employeeNumber,idtable.ClientFacilityGroup 
		FROM (
				SELECT DISTINCT rf.releaseformid,rf.clno,'000000000' as employeeNumber,rf.ssn,'' as ClientFacilityGroup
				FROM --HEVN.dbo.EmployeeRecord er WITH (NOLOCK) 
				--INNER JOIN  HEVN.dbo.Facility F WITH (NOLOCK) on er.facilityid = F.facilityid	
				ReleaseForm rf WITH (NOLOCK)  --on rf.ssn = er.ssn	

				WHERE --rf.CLNO = @CLNO --(F.ParentEmployerID=@CLNO OR F.EmployerID=@CLNO)
				  --AND er.facilityid is not null AND er.departmentid is not null AND er.employeenumber is not null
				 -- AND (SELECT Count(*) FROM reportuploadlog r WITH (NOLOCK) WHERE r.ReportID = rf.releaseformid AND r.resend = 0 AND r.ReportType = 2) = 0		
				--  AND 
				  (( @StartDate is not null and rf.date >= @StartDate) or(@StartDate is null))
				  AND (( @EndDate is not null and rf.date < @EndDate) or(@EndDate is null))
				  AND (rf.clno = @CLNO OR rf.clno in (SELECT clno FROM clienthierarchybyservice WITH (NOLOCK) WHERE parentclno = @CLNO AND refhierarchyserviceid = 1 ))
			) AS idTable 
		   INNER JOIN ReleaseForm rf WITH (NOLOCK) on rf.ssn = idtable.ssn AND rf.clno = idtable.clno 
			AND  rf.releaseformid = (SELECT Max(releaseformid) AS  releaseformid 
									FROM 
									(
									    SELECT MAX(releaseformid) AS releaseformid,ssn,clno  FROM releaseform WITH (NOLOCK) group by ssn,clno				
									) rfa   
									WHERE rfa.ssn = idTable.ssn AND rfa.clno = idtable.clno) 
			AND rf.releaseformid NOT IN (SELECT FolderID FROM #tmp)
			AND (SELECT Count(*) FROM reportuploadlog r WITH (NOLOCK) WHERE r.ReportID = rf.releaseformid AND r.resend = 0 AND r.ReportType = 2) = 0
			) AS Y
			ORDER BY ClientFacilityGroup
   End

   DROP TABLE #tmp
   */
END
