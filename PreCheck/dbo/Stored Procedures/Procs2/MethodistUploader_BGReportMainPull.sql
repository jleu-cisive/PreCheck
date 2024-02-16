
---[MethodistUploader_BGReportMainPull] 1937, '6/1/2015','09/1/2015'

--	[MethodistUploader_BGReportMainPull] 2569, '9/1/2018','1/1/2019'

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[MethodistUploader_BGReportMainPull]
	-- Add the parameters for the stored procedure here
	@CLNO int, @StartDate datetime,@EndDate datetime
AS
BEGIN


----SET @CLNO = 7898;
--SET @StartDate = '9/1/2018'--DATEADD(m,-4,getdate());
--Set @EndDate = '2/1/2019';
------------------Please use this section for manual reruns-------------------------------------
--SET @CLNO = 2569;
--SET @StartDate = '07/01/2015'--DATEADD(m,-4,getdate());
--Set @EndDate = '08/1/2015';
--insert into winservicelog (logdate,logmessage) values(getdate(),'MethodistParams: ' + cast(@CLNO as varchar(20)) + ' ' + convert(varchar,@StartDate,101) + ' ' + convert(varchar,@EndDate,101));
------------------manual reruns-------------------------------------
--SET @StartDate = '11/01/2014'--DATEADD(m,-4,getdate());
--Set @EndDate = '01/01/2015';
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
select (cast(idtable.apno as varchar)-- + '-' + cast(idtable.employeeNumber as varchar)
) as FolderID,idtable.clno,br.backgroundreportid as ReportID,idtable.employeeNumber, isnull(ClientFacilityGroup,'NonGrouped') as ClientFacilityGroup --schapyala returning emptystring for facilitygroup as this is not used for BG purposes - 05/04/2015
from (
SELECT DISTINCT a.apno,a.clno,er.employeeNumber, 'NonGrouped' as ClientFacilityGroup
FROM HEVN.dbo.EmployeeRecord er WITH (NOLOCK) 
	INNER JOIN  HEVN.dbo.Facility F WITH (NOLOCK) on er.facilityid = F.facilityid	
	INNER JOIN  dbo.appl a  WITH (NOLOCK) on a.ssn = er.ssn
	INNER JOIN BackgroundReports.dbo.BackgroundReport br WITH (NOLOCK) on br.apno = a.apno  

WHERE (F.ParentEmployerID=@CLNO OR F.EmployerID=@CLNO)
		AND er.facilityid is not null and er.departmentid is not null and er.employeenumber is not null		
		--AND IsNULL(a.compdate,@EndDate) > DATEADD(m,-6,@StartDate) AND IsNULL(a.compdate,@EndDate) <= @EndDate
		--AND IsNull(er.LastStartDate, er.OriginalStartDate) >= @StartDate and IsNull(er.LastStartDate, er.OriginalStartDate) < @EndDate--cutoff
		----------
		
		----schapyala changed enddate to '1/1/1900' for the isnull default for compdate below. - 02/03/2015
			AND ((IsNULL(a.compdate,'1/1/1900') > DATEADD(m,-6,@StartDate) AND IsNULL(a.compdate,'1/1/1900') <= @EndDate
			AND IsNull(er.LastStartDate, er.OriginalStartDate) >= @StartDate and IsNull(er.LastStartDate, er.OriginalStartDate) < @EndDate)
			OR (IsNULL(a.compdate,'1/1/1900') >= @StartDate AND IsNULL(a.compdate,'1/1/1900') <= @EndDate))
		----------- End Schayala --------

		----------        Sreddy commented the above 3 lines and added the uncommented code for the Methodist Report and will work for Inova too.  --------------------
		--AND (
		--		(er.originalstartdate >= @StartDate and er.originalstartdate <= @EndDate)  
		--			or (er.jobstartdate >= @StartDate and er.jobstartdate<= @EndDate) 
		--			or (er.laststartdate >=@StartDate and er.laststartdate<= @EndDate)
		--	)

		----------        Sreddy commented the above first 3 lines and added the uncommented code for the Methodist Report and will work for Inova too.  --------------------
		
		--AND (er.EndDate is null OR (month(enddate) = month(er.laststartdate) and year(enddate) = year(er.laststartdate)))
		
		AND a.apstatus = 'F' 
		AND (SELECT Count(*) from reportuploadlog r WITH (NOLOCK) where r.ReportID = br.backgroundreportid and r.resend = 0 AND r.ReportType = 1) = 0		
		AND (a.clno = @CLNO OR a.clno in (select clno from clienthierarchybyservice WITH (NOLOCK) where parentclno = @CLNO and refhierarchyserviceid = 1 ))
) as idTable 
INNER JOIN BackgroundReports.dbo.BackgroundReport br WITH (NOLOCK) on br.apno = idTable.apno
and  br.CreateDate = (Select MAX(createdate) from BackgroundReports.dbo.BackgroundReport WITH (NOLOCK) where apno = idTable.apno)
AND (SELECT Count(*) from reportuploadlog r WITH (NOLOCK) where r.ReportID = br.backgroundreportid and r.resend = 0 AND r.ReportType = 1) = 0		
	
END































