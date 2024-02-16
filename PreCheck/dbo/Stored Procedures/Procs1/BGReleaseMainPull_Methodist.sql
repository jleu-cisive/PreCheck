-- =============================================
-- Author:		Kiran Miryala
-- Create date: 05/25/2018
-- Description:	<Description,,>
-- Execution: --EXEC BGReleaseMainPull_Methodist 2569, '09/03/2019','07/03/2019',1
-- =============================================
CREATE PROCEDURE [dbo].[BGReleaseMainPull_Methodist]
	@CLNO int, 
	@StartDate datetime=null,
	@EndDate datetime=null, 
	@UseHevnDb bit = 1
AS
BEGIN
--SET @CLNO = 2569;
--SET @StartDate = '12/01/2018'
--Set @EndDate = '02/28/2019';

--SET @StartDate = '01/07/2019'	
--Set @EndDate = '01/08/2019';

	SELECT idtable.releaseformid AS FolderID,idtable.clno,idtable.releaseformid AS ReportID,idtable.employeeNumber,idtable.ClientFacilityGroup 
	FROM (
			SELECT DISTINCT rf.releaseformid,rf.clno,er.employeeNumber,rf.ssn,F.ClientFacilityGroup 
			FROM HEVN.dbo.EmployeeRecord er WITH (NOLOCK) 
			INNER JOIN  HEVN.dbo.Facility F WITH (NOLOCK) on er.facilityid = F.facilityid	
			--INNER JOIN  releaseform rf  WITH (NOLOCK) on rf.ssn = er.ssn	  
			INNER JOIN  
				(
					SELECT * FROM PreCheck_MainArchive.dbo.ReleaseForm_Archive WITH (NOLOCK)
					UNION ALL
					SELECT * FROM ReleaseForm WITH (NOLOCK)
				) rf on rf.ssn = er.ssn	
			WHERE (F.ParentEmployerID=@CLNO OR F.EmployerID=@CLNO)
			  AND ER.SSN NOT IN ('111-11-1111')
			  AND er.facilityid is not null AND er.departmentid is not null AND er.employeenumber is not null
			  --AND IsNULL(rf.date,@EndDate) > DATEADD(m,-3,@StartDate)		
			  AND (SELECT Count(*) FROM reportuploadlog r WITH (NOLOCK) WHERE r.ReportID = rf.releaseformid AND r.resend = 0 AND r.ReportType = 2) = 0		
			  AND IsNull(er.LastStartDate, er.OriginalStartDate) >= @StartDate 
			  AND IsNull(er.LastStartDate, er.OriginalStartDate) < @EndDate--cutoff
			  AND (rf.clno = @CLNO OR rf.clno in (SELECT clno FROM clienthierarchybyservice WITH (NOLOCK) WHERE parentclno = @CLNO AND refhierarchyserviceid = 1 ))
		) AS idTable 
	--INNER JOIN PreCheck_MainArchive.dbo.ReleaseForm_Archive rf WITH (NOLOCK) on rf.ssn = idtable.ssn AND rf.clno = idtable.clno 
	INNER JOIN 
		(
			SELECT * FROM PreCheck_MainArchive.dbo.ReleaseForm_Archive WITH (NOLOCK)   ----11-02-2016 Kiran added UNION ALL for using the archive table data 
			UNION ALL
			SELECT * FROM ReleaseForm WITH (NOLOCK)
		) rf on rf.ssn = idtable.ssn AND rf.clno = idtable.clno 
		--AND  rf.releaseformid = (SELECT MAX(releaseformid) FROM PreCheck_MainArchive.dbo.ReleaseForm_Archive WITH (NOLOCK) WHERE ssn = idTable.ssn AND clno = idtable.clno)
		AND  rf.releaseformid = (SELECT Max(releaseformid) AS  releaseformid 
								FROM 
								(
									SELECT MAX(releaseformid) AS releaseformid,ssn,clno  FROM releaseform WITH (NOLOCK) group by ssn,clno
									UNION ALL
									SELECT MAX(releaseformid)  AS releaseformid,ssn,clno FROM PreCheck_MainArchive.dbo.ReleaseForm_Archive WITH (NOLOCK) group by ssn,clno
								) rfa   
								WHERE rfa.ssn = idTable.ssn 
								  AND rfa.clno = idtable.clno) 
		AND (SELECT Count(*) FROM reportuploadlog r WITH (NOLOCK) WHERE r.ReportID = rf.releaseformid AND r.resend = 0 AND r.ReportType = 2) = 0
		ORDER BY idtable.ClientFacilityGroup

/* VD:12/14/2018 - Commened out old code.
 if(@UseHevnDb = 1)
   Begin
		SELECT idtable.releaseformid AS FolderID,idtable.clno,idtable.releaseformid AS ReportID,idtable.employeeNumber,idtable.ClientFacilityGroup 
		FROM (
				SELECT DISTINCT rf.releaseformid,rf.clno,er.employeeNumber,rf.ssn,F.ClientFacilityGroup
				FROM HEVN.dbo.EmployeeRecord er WITH (NOLOCK) 
				INNER JOIN  HEVN.dbo.Facility F WITH (NOLOCK) on er.facilityid = F.facilityid	
				INNER JOIN  ReleaseForm rf WITH (NOLOCK) on rf.ssn = er.ssn	

				WHERE (F.ParentEmployerID=@CLNO OR F.EmployerID=@CLNO)
				  AND er.facilityid is not null AND er.departmentid is not null AND er.employeenumber is not null
				 -- AND (SELECT Count(*) FROM reportuploadlog r WITH (NOLOCK) WHERE r.ReportID = rf.releaseformid AND r.resend = 0 AND r.ReportType = 2) = 0		
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
			--AND (SELECT Count(*) FROM reportuploadlog r WITH (NOLOCK) WHERE r.ReportID = rf.releaseformid AND r.resend = 0 AND r.ReportType = 2) = 0		
			ORDER BY idtable.ClientFacilityGroup
   End
 Else
   Begin
		SELECT idtable.releaseformid AS FolderID,idtable.clno,idtable.releaseformid AS ReportID,idtable.employeeNumber,idtable.ClientFacilityGroup 
		FROM (
				SELECT DISTINCT rf.releaseformid,rf.clno,'' as employeeNumber,rf.ssn,'' as ClientFacilityGroup
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
			--AND (SELECT Count(*) FROM reportuploadlog r WITH (NOLOCK) WHERE r.ReportID = rf.releaseformid AND r.resend = 0 AND r.ReportType = 2) = 0		
			ORDER BY idtable.ClientFacilityGroup
   End
   */
END
