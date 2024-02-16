CREATE PROCEDURE [dbo].[MethodistUploader_LicenseImageMainPull]
	
	@CLNO int, @StartDate datetime,@EndDate datetime

AS
BEGIN

--SET @StartDate = '05/02/2014'--DATEADD(m,-4,getdate());
--Set @EndDate = '07/02/2014';
insert into winservicelog (logdate,logmessage) values(getdate(),'MethodistParamsRelease: ' + cast(@CLNO as varchar(20)) + ' ' + convert(varchar,@StartDate,101) + ' ' + convert(varchar,@EndDate,101));


Select distinct LicenseImageID as FolderID,ER.EmployerID as clno,LicenseImageID as ReportID, 
ER.employeeNumber, F.ClientFacilityGroup
from HEVN.dbo.License L 
               inner join HEVN.dbo.EmployeeRecord ER on L.Employer_id = ER.Employerid and L.SSN = ER.SSN
               inner join CredentCheckDocuments.dbo.LicenseImage LI on L.Licenseid =LI.Licenseid
               inner join HEVN.dbo.Facility F on ER.facilityid = F.FacilityID
               inner join HEVN.dbo.ClientLicenseType CLT on L.ClientLicenseTypeID = CLT.ClientLicenseTypeID
Where (F.ParentEmployerID = @CLNO or F.EmployerID = @CLNO)
and ER.Facilityid is not null and ER.departmentid is not null and er.employeenumber is not null
and ISNULL(ER.LastStartDate, ER.OriginalStartDate) >= @StartDate 
and ISNULL(ER.LastStartDate, ER.OriginalStartDate) < @EndDate
AND ((SELECT Count(*) from reportuploadlog r WITH (NOLOCK) where r.ReportID = LicenseImageID 
and r.resend = 0 AND r.ReportType = 4) = 0	)
and L.licenseid in (select max(licenseid) from  HEVN.dbo.License L  Where Employer_ID =@CLNO
 group by ParentLicenseID)  
ORDER BY F.ClientFacilityGroup
		
END


