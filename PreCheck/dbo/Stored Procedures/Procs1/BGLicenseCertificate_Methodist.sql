-- =============================================
-- Author:		Kiran Miryala
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- Execution: [BGLicenseCertificate_Methodist] 2569,'1/01/2017','01/04/2018',1
-- =============================================
CREATE PROCEDURE [dbo].[BGLicenseCertificate_Methodist]
	@CLNO int, @StartDate datetime,@EndDate datetime,@UseHevnDb bit = 1

AS
BEGIN

SET @CLNO = 2569;
SET @StartDate = '04/01/2018'
SET @EndDate = '05/01/2018'

if(@UseHevnDb = 1)
 Begin
		select idtable.releaseformid as FolderID,idtable.apno,idtable.imagefilename,idtable.clno,idtable.releaseformid as ReportID,idtable.employeeNumber,idtable.ClientFacilityGroup from (
		SELECT DISTINCT aa.applfileid as releaseformid,a.apno,aa.imagefilename,a.clno,er.employeeNumber,a.ssn,F.ClientFacilityGroup
		FROM HEVN.dbo.EmployeeRecord er WITH (NOLOCK) 
		INNER JOIN  HEVN.dbo.Facility F WITH (NOLOCK) on er.facilityid = F.facilityid	
		INNER JOIN  appl a  WITH (NOLOCK) on a.ssn = er.ssn	  
		inner join applfile aa with(nolock) on aa.apno = a.apno
		WHERE aa.refapplfiletype = 2 and isnull(aa.deleted,0) = 0
		and (F.ParentEmployerID=@CLNO OR F.EmployerID=@CLNO)
		AND er.facilityid is not null and er.departmentid is not null and er.employeenumber is not null
		AND (SELECT Count(*) from reportuploadlog r WITH (NOLOCK) where r.ReportID = aa.applfileid and r.resend = 0 AND r.ReportType = 5) = 0		
		AND IsNull(er.LastStartDate, er.OriginalStartDate) >= @StartDate and IsNull(er.LastStartDate, er.OriginalStartDate) < @EndDate--cutoff
		AND (a.clno = @CLNO OR a.clno in (select clno from clienthierarchybyservice WITH (NOLOCK) where parentclno = @CLNO and refhierarchyserviceid = 1 ))	
		) as idTable 
		where (SELECT Count(*) from reportuploadlog r WITH (NOLOCK) where r.ReportID = idTable.releaseformid and r.resend = 0 AND r.ReportType = 5) = 0		
		ORDER BY idtable.ClientFacilityGroup
 End
else
 Begin
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
			AND (SELECT Count(*) from reportuploadlog r WITH (NOLOCK) where r.ReportID = aa.applfileid and r.resend = 0 AND r.ReportType = 5) = 0		
			--AND IsNull(er.LastStartDate, er.OriginalStartDate) >= @StartDate and IsNull(er.LastStartDate, er.OriginalStartDate) < @EndDate--cutoff
			AND (a.clno = @CLNO OR a.clno in (select clno from clienthierarchybyservice WITH (NOLOCK) where parentclno = @CLNO and refhierarchyserviceid = 1 ))	
		  ) as idTable 
		where (SELECT Count(*) from reportuploadlog r WITH (NOLOCK) where r.ReportID = idTable.releaseformid and r.resend = 0 AND r.ReportType = 5) = 0		
		ORDER BY idtable.ClientFacilityGroup
 End
		
END
