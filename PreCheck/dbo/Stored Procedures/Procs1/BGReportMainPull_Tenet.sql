
-- =============================================
-- Author:		DEEPAK VODETHELA
-- Create date: 11/02/2018
-- Description:	To generate back ground reports for Tenet
-- Modified by Nirod Kumar : On select statement removed the casting of apno to varchar and added casting clno to int because its clno is smallint in appl table.
--                           and the output data type for all the procedure in BulkReportUploader has to be consistent.
-- Execution: EXEC [BGReportMainPull_Tenet] 12444, '01/15/2020','02/01/2020',1
-- 12/26/2019 - 8034 Reports
-- Modified By Lalit to send facility number in returned index file for #96021 on 17 July 2023
-- =============================================

CREATE PROCEDURE [dbo].[BGReportMainPull_Tenet]
	@CLNO int, @StartDate datetime,@EndDate datetime,@UseHevnDb bit = 1
AS
BEGIN

	--SET @CLNO = 12444;
	--SET @StartDate = '07/01/1997'--DATEADD(m,-4,getdate());
	--Set @EndDate = '01/31/2020';

	If(@UseHevnDb = 1)
	 BEGIN

		--DECLARE temp tables (helps to maintain the same plan regardless of stats change)
		drop table if exists #tmp
		CREATE TABLE #tmp(
			[FolderID] [int] NOT NULL,
			[CLNO] [smallint] NOT NULL,
			[ReportID] [int] NOT NULL,
			[EmployeeNumber] [varchar](50) NOT NULL,
			[ClientFacilityGroup] [varchar](50) NULL,
			[FacilityNumber][varchar](10)null)

		CREATE CLUSTERED INDEX IX_tmp2_01 ON #tmp([FolderID])


			INSERT INTO #tmp
			SELECT  idtable.apno as FolderID, idtable.clno, br.backgroundreportid AS ReportID,idtable.employeeNumber, isnull(ClientFacilityGroup,'NonGrouped') as ClientFacilityGroup,FacilityNumber --schapyala returning emptystring for facilitygroup as this is not used for BG purposes - 05/04/2015
			FROM (
				SELECT DISTINCT  a.apno,cast(a.clno as int) as clno ,er.employeeNumber, 'NonGrouped' as ClientFacilityGroup,f.facilitynum as FacilityNumber
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
				
						AND (SELECT Count(*) from reportuploadlog r WITH (NOLOCK) where r.ReportID = br.backgroundreportid and r.resend = 0 AND r.ReportType = 1) = 0		
						AND (C.WebOrderParentCLNO = @CLNO OR a.clno in (select clno from clienthierarchybyservice WITH (NOLOCK) where parentclno = @CLNO and refhierarchyserviceid = 1 ))
				) as idTable 
				INNER JOIN BackgroundReports.dbo.BackgroundReport br WITH (NOLOCK) on br.apno = idTable.apno
				and  br.CreateDate = (Select MAX(createdate) from BackgroundReports.dbo.BackgroundReport WITH (NOLOCK) where apno = idTable.apno)
				AND (SELECT Count(*) from reportuploadlog r WITH (NOLOCK) where r.ReportID = br.backgroundreportid and r.resend = 0 AND r.ReportType = 1) = 0
		
		--SELECT * FROM #tmp

		SELECT FolderID, clno, ReportID, employeeNumber, ClientFacilityGroup,FacilityNumber		
		FROM(
			SELECT * FROM #tmp
		UNION ALL
		
			select  idtable.apno as FolderID,idtable.clno, br.backgroundreportid AS ReportID,idtable.employeeNumber, isnull(ClientFacilityGroup,'NonGrouped') as ClientFacilityGroup,FacilityNumber --schapyala returning emptystring for facilitygroup as this is not used for BG purposes - 05/04/2015
			from (
				SELECT DISTINCT  a.apno,cast(a.clno as int) as clno ,'000000000' employeeNumber, 'NonGrouped' as ClientFacilityGroup,t1.facilitynum as FacilityNumber
				FROM   PRECHECK.DBO.appl a  WITH (NOLOCK) 
					INNER JOIN BackgroundReports.dbo.BackgroundReport br WITH (NOLOCK) on a.apno = br.apno  
					INNER JOIN dbo.Client c(NOLOCK) ON A.CLNO = c.CLNO
					left join (
							select f0.* from hevn.dbo.Facility f0 
							inner join (
							select f.ParentEmployerID,f.FacilityCLNO,count(*)_count
							from hevn.dbo.facility f where f.IsActive=1 and f.ParentEmployerID=@CLNO
							group by f.ParentEmployerID,f.FacilityCLNO 
							having count(*)<2  ) t on f0.FacilityCLNO=t.FacilityCLNO and f0.ParentEmployerID=t.ParentEmployerID
							)t1 on t1.FacilityCLNO=a.CLNO  --<<<<<< added by Lalit to return facility number only in case a facilityClno has only one facility mapped otherwise return null
				WHERE 
						----schapyala changed enddate to '1/1/1900' for the isnull default for compdate below. - 02/03/2015
							 ((IsNULL(a.compdate,'1/1/1900') > DATEADD(m,-6,@StartDate) AND IsNULL(a.compdate,'1/1/1900') <= @EndDate
							--AND IsNull(er.LastStartDate, er.OriginalStartDate) >= @StartDate and IsNull(er.LastStartDate, er.OriginalStartDate) < @EndDate)
							)OR (IsNULL(a.compdate,'1/1/1900') >= @StartDate AND IsNULL(a.compdate,'1/1/1900') <= @EndDate))
						----------- End Schayala --------
						AND a.apstatus = 'F' 
				
						AND (SELECT Count(*) from reportuploadlog r WITH (NOLOCK) where r.ReportID = br.backgroundreportid and r.resend = 0 AND r.ReportType = 1) = 0		
						AND (C.WebOrderParentCLNO = @CLNO OR a.clno in (select clno from clienthierarchybyservice WITH (NOLOCK) where parentclno = @CLNO and refhierarchyserviceid = 1 ))
						AND A.APNO NOT IN (SELECT FolderID FROM #tmp)
				) as idTable 
				INNER JOIN BackgroundReports.dbo.BackgroundReport br WITH (NOLOCK) on br.apno = idTable.apno
				and br.CreateDate = (Select MAX(createdate) from BackgroundReports.dbo.BackgroundReport WITH (NOLOCK) where apno = idTable.apno)
				AND (SELECT Count(*) from reportuploadlog r WITH (NOLOCK) where r.ReportID = br.backgroundreportid and r.resend = 0 AND r.ReportType = 1) = 0
			) AS Y
	 End

	   DROP TABLE #tmp

END