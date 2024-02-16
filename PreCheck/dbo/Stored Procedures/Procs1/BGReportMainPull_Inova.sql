-- =============================================
-- Author:		Deepak Vodethela
-- Create date: 03/22/2019
-- Description:	<Description,,>
-- Modified by Nirod Kumar : On select statement removed the casting of apno to varchar and added casting clno to int because its clno is smallint in appl table.
--                           and the output data type for all the procedure in BulkReportUploader has to be consistent.
-- Execution: [BGReportMainPull_Inova] 1937, '10/01/2020','03/05/2021',0
-- =============================================
CREATE PROCEDURE [dbo].[BGReportMainPull_Inova]
	@CLNO int, @StartDate datetime,@EndDate datetime,@UseHevnDb bit = 1
AS
BEGIN

--SET @CLNO = 1937;
SET @StartDate = '10/01/2020'
Set @EndDate = CURRENT_TIMESTAMP;

	SELECT  top 4000 cast(idtable.apno as varchar) as FolderID,idtable.clno,br.backgroundreportid as ReportID,idtable.employeeNumber, isnull(ClientFacilityGroup,'NonGrouped') as ClientFacilityGroup
	FROM (
	SELECT DISTINCT a.apno,a.clno,er.employeeNumber, 'NonGrouped' as ClientFacilityGroup
	FROM HEVN.dbo.EmployeeRecord er WITH (NOLOCK) 
	INNER JOIN  HEVN.dbo.Facility F WITH (NOLOCK) on er.facilityid = F.facilityid	
	INNER JOIN  dbo.appl a  WITH (NOLOCK) on a.ssn = er.ssn
	INNER JOIN BackgroundReports.dbo.BackgroundReport br WITH (NOLOCK) on br.apno = a.apno  
	WHERE (F.ParentEmployerID=@CLNO OR F.EmployerID=@CLNO)
	  AND er.facilityid is not null and er.departmentid is not null and er.employeenumber is not null		
	  AND ((IsNULL(a.compdate,'1/1/1900') > DATEADD(m,-6,@StartDate) AND IsNULL(a.compdate,'1/1/1900') <= @EndDate
	  AND IsNull(er.LastStartDate, er.OriginalStartDate) >= @StartDate and IsNull(er.LastStartDate, er.OriginalStartDate) < @EndDate)
	   OR (IsNULL(a.compdate,'1/1/1900') >= @StartDate AND IsNULL(a.compdate,'1/1/1900') <= @EndDate))
	  AND a.apstatus = 'F' 
	  AND (SELECT Count(*) from reportuploadlog r WITH (NOLOCK) where r.ReportID = br.backgroundreportid and r.resend = 0 AND r.ReportType = 1) = 0		
	  AND (a.clno = @CLNO OR a.clno in (select clno from clienthierarchybyservice WITH (NOLOCK) where parentclno = @CLNO and refhierarchyserviceid = 1 ))
	) as idTable 
	INNER JOIN BackgroundReports.dbo.BackgroundReport br WITH (NOLOCK) on br.apno = idTable.apno
	AND  br.CreateDate = (SELECT MAX(createdate) FROM BackgroundReports.dbo.BackgroundReport WITH (NOLOCK) WHERE apno = idTable.apno)
	AND (SELECT Count(*) FROM reportuploadlog r WITH (NOLOCK) WHERE r.ReportID = br.backgroundreportid and r.resend = 0 AND r.ReportType = 1) = 0		

END