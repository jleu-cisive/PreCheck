



--	exec BGReportMainPull 14576, '1/1/2017','09/02/2018',0

--select  * from client where clno in (9058,9028)
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>

-- =============================================
CREATE PROCEDURE [dbo].[BGReportMainPull]
	@CLNO int, @StartDate datetime,@EndDate datetime,@UseHevnDb bit = 0
AS
BEGIN

------------------Please use this section for manual reruns-------------------------------------
--SET @CLNO = 9058;
SET @StartDate = '1/1/2018'--DATEADD(m,-4,getdate());
Set @EndDate = '8/10/2018';




If(@UseHevnDb = 1)
 Begin
		
select top 20 idtable.apno as FolderID,idtable.clno, br.backgroundreportid AS ReportID,idtable.employeeNumber, isnull(ClientFacilityGroup,'NonGrouped') as ClientFacilityGroup --schapyala returning emptystring for facilitygroup as this is not used for BG purposes - 05/04/2015
		from (
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
		) as idTable 
		INNER JOIN BackgroundReports.dbo.BackgroundReport br WITH (NOLOCK) on br.apno = idTable.apno
		and  
		br.CreateDate = (Select MAX(createdate) from BackgroundReports.dbo.BackgroundReport WITH (NOLOCK) where apno = idTable.apno)
		--AND (SELECT Count(*) from reportuploadlog r WITH (NOLOCK) where r.ReportID = br.backgroundreportid and r.resend = 0 AND r.ReportType = 1) = 0		
 End
Else
 Begin
		
select idtable.apno as FolderID,idtable.clno, br.backgroundreportid AS ReportID,idtable.employeeNumber, isnull(ClientFacilityGroup,'NonGrouped') as ClientFacilityGroup --schapyala returning emptystring for facilitygroup as this is not used for BG purposes - 05/04/2015
		from (
		SELECT DISTINCT  a.apno,cast(a.clno as int) as clno ,'' employeeNumber, 'NonGrouped' as ClientFacilityGroup
		FROM   PRECHECK.DBO.appl a  WITH (NOLOCK) 
			INNER JOIN BackgroundReports.dbo.BackgroundReport br WITH (NOLOCK) on a.apno = br.apno  

		WHERE 
	
		
				----schapyala changed enddate to '1/1/1900' for the isnull default for compdate below. - 02/03/2015
					 ((IsNULL(a.compdate,'1/1/1900') > DATEADD(m,-6,@StartDate) AND IsNULL(a.compdate,'1/1/1900') < @EndDate
					--AND IsNull(er.LastStartDate, er.OriginalStartDate) >= @StartDate and IsNull(er.LastStartDate, er.OriginalStartDate) < @EndDate)
					)OR (IsNULL(a.compdate,'1/1/1900') >= @StartDate AND IsNULL(a.compdate,'1/1/1900') < @EndDate))
				----------- End Schayala --------
	
				AND a.apstatus = 'F' 
				
				AND (SELECT Count(*) from reportuploadlog r WITH (NOLOCK) where r.ReportID = br.backgroundreportid and r.resend = 0 AND r.ReportType = 1) = 0		
				AND (a.clno = @CLNO OR a.clno in (select clno from clienthierarchybyservice WITH (NOLOCK) where parentclno = @CLNO and refhierarchyserviceid = 1 ))
		) as idTable 
		INNER JOIN BackgroundReports.dbo.BackgroundReport br WITH (NOLOCK) on br.apno = idTable.apno
		and  
		br.CreateDate = (Select MAX(createdate) from BackgroundReports.dbo.BackgroundReport WITH (NOLOCK) where apno = idTable.apno)
		AND (SELECT Count(*) from reportuploadlog r WITH (NOLOCK) where r.ReportID = br.backgroundreportid and r.resend = 0 AND r.ReportType = 1) = 0	
		
 End


	
END