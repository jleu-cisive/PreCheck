
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- Execution: EXEC MethodistUploader_BGReleaseMainPull 2569, '08/01/2018','01/03/2019'
-- =============================================
CREATE PROCEDURE [dbo].[MethodistUploader_BGReleaseMainPull]
	
	@CLNO int, @StartDate datetime,@EndDate datetime

AS
BEGIN


SET @StartDate = '09/01/2018'
SET @EndDate = '02/01/2019'
--insert into winservicelog (logdate,logmessage) values(getdate(),'MethodistParamsRelease: ' + cast(@CLNO AS varchar(20)) + ' ' + convert(varchar,@StartDate,101) + ' ' + convert(varchar,@EndDate,101));
--SET @CLNO = 2569;
--SET @StartDate = '03/02/2014'--DATEADD(m,-4,getdate());
--Set @EndDate = '05/02/2014';

	--SELECT isnull(idtable.ClientFacilityGroup,'') + '-' + cast(idtable.releaseformid AS varchar) AS FolderID,idtable.clno,idtable.releaseformid AS ReportID,idtable.employeeNumber,idtable.ClientFacilityGroup 

	SELECT   idtable.releaseformid AS FolderID,idtable.clno,idtable.releaseformid AS ReportID,idtable.employeeNumber,idtable.ClientFacilityGroup 
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




		/*	
		-- Deepak - 10/03/2017 - UnComment the below statements to execute "ApplicantInfo_pdf"'s and Comment the above statements

		SELECT idtable.releaseformid AS FolderID,idtable.clno,idtable.releaseformid AS ReportID,idtable.employeeNumber,idtable.ClientFacilityGroup
		FROM (
				SELECT DISTINCT rf.releaseformid,rf.clno,er.employeeNumber,rf.ssn,F.ClientFacilityGroup
				FROM HEVN.dbo.EmployeeRecord er WITH (NOLOCK) 
				INNER JOIN  HEVN.dbo.Facility F WITH (NOLOCK) on er.facilityid = F.facilityid	
				INNER JOIN  
					(
						SELECT * FROM PreCheck_MainArchive.dbo.ReleaseForm_Archive WITH (NOLOCK) WHERE ApplicantInfo_pdf IS NOT NULL
						UNION ALL
						SELECT * FROM ReleaseForm WITH (NOLOCK) WHERE ApplicantInfo_pdf IS NOT NULL
					) rf on rf.ssn = er.ssn	
				WHERE (F.ParentEmployerID=@CLNO OR F.EmployerID=@CLNO)
				  AND er.facilityid IS NOT NULL
				  AND er.departmentid IS NOT NULL 
				  AND er.employeenumber IS NOT NULL
				  --AND (SELECT COUNT(*) FROM ReportUploadLog r WITH (NOLOCK) WHERE r.ReportID = rf.releaseformid AND r.resend = 0 AND r.ReportType = 2) = 0		
				  AND IsNull(er.LastStartDate, er.OriginalStartDate) >= @StartDate 
				  AND IsNull(er.LastStartDate, er.OriginalStartDate) < @EndDate--cutoff
				  AND (rf.clno = @CLNO OR rf.clno in (SELECT clno FROM clienthierarchybyservice WITH (NOLOCK) WHERE parentclno = @CLNO AND refhierarchyserviceid = 1 ))
			) AS idTable 
		INNER JOIN 
			(
				SELECT * FROM PreCheck_MainArchive.dbo.ReleaseForm_Archive WITH (NOLOCK) 
				UNION ALL
				SELECT * FROM ReleaseForm WITH (NOLOCK)
			) rf on rf.ssn = idtable.ssn AND rf.clno = idtable.clno 
			AND  rf.releaseformid = (SELECT Max(releaseformid) AS  releaseformid 
									FROM 
									(
										SELECT MAX(releaseformid) AS releaseformid,ssn,clno  FROM releaseform WITH (NOLOCK) WHERE ApplicantInfo_pdf IS NOT NULL GROUP BY ssn,clno
										UNION ALL
										SELECT MAX(releaseformid)  AS releaseformid,ssn,clno FROM PreCheck_MainArchive.dbo.ReleaseForm_Archive WITH (NOLOCK) WHERE ApplicantInfo_pdf IS NOT NULL GROUP BY ssn,clno
									) rfa   
									WHERE rfa.ssn = idTable.ssn 
									  AND rfa.clno = idtable.clno) 
			--AND (SELECT Count(*) FROM reportuploadlog r WITH (NOLOCK) WHERE r.ReportID = rf.releaseformid AND r.resend = 0 AND r.ReportType = 2) = 0		
			ORDER BY idtable.ClientFacilityGroup
	
		*/


END









