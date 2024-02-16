﻿-- =============================================
-- Author:		DEEPAK VODETHELA
-- Create date: 11/02/2018
-- Description:	<Description,,>
-- Execution: EXEC [BGReleaseMainPull_Tenet] 12444, '01/15/2020','08/01/2022',1
-- 12/26/2019 - 51,112 Releases
-- =============================================
CREATE PROCEDURE [dbo].[BGReleaseMainPull_Tenet]
	
	@CLNO int, @StartDate datetime=null,@EndDate datetime=null, @UseHevnDb bit = 1

AS
BEGIN

--SET @CLNO = 12444;
--SET @StartDate = '07/01/2016'--DATEADD(m,-4,getdate());
--Set @EndDate = '01/31/2020';

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
				  AND (rf.clno = @CLNO OR rf.clno in (SELECT clno FROM clienthierarchybyservice WITH (NOLOCK) WHERE parentclno = @CLNO AND refhierarchyserviceid = 2 ))
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

	SELECT top 5000 FolderID, clno,ReportID, employeeNumber,ClientFacilityGroup 
	FROM 
		(
			SELECT * FROM #tmp
	UNION ALL

		SELECT  idtable.releaseformid AS FolderID,idtable.clno,idtable.releaseformid AS ReportID,idtable.employeeNumber,idtable.ClientFacilityGroup 
		FROM (
				SELECT DISTINCT rf.releaseformid,rf.clno,'000000000' as employeeNumber,rf.ssn,'' as ClientFacilityGroup
				FROM ReleaseForm rf WITH (NOLOCK)
				WHERE (( @StartDate is not null and rf.date >= @StartDate) or(@StartDate is null))
				  AND (( @EndDate is not null and rf.date < @EndDate) or(@EndDate is null))
				  AND (rf.clno = @CLNO OR rf.clno in (SELECT clno FROM clienthierarchybyservice WITH (NOLOCK) WHERE parentclno = @CLNO AND refhierarchyserviceid = 2 ))
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
  
END
