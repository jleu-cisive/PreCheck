

CREATE PROCEDURE [dbo].[BGReportMainPull_16107]
	@CLNO int, @StartDate datetime,@EndDate datetime,@UseHevnDb bit = 0
AS
BEGIN
	--SET @CLNO = 13126;
	SET @StartDate = '02/01/2020'--DATEADD(m,-2,@EndDate);
	Set @EndDate = Getdate();
		
		SELECT FolderID, clno, ReportID, employeeNumber, ClientFacilityGroup		
		FROM(
		--	SELECT * FROM #tmp
		--UNION ALL
		
			select  idtable.apno as FolderID,idtable.clno, br.backgroundreportid AS ReportID,idtable.employeeNumber, isnull(ClientFacilityGroup,'NonGrouped') as ClientFacilityGroup --schapyala returning emptystring for facilitygroup as this is not used for BG purposes - 05/04/2015
			from (
				SELECT DISTINCT  a.apno,cast(a.clno as int) as clno ,'000000000' employeeNumber, 'NonGrouped' as ClientFacilityGroup
				FROM   PRECHECK.DBO.appl a  WITH (NOLOCK)
					INNER JOIN BackgroundReports.dbo.BackgroundReport br WITH (NOLOCK) on a.apno = br.apno
					INNER JOIN dbo.Client c(NOLOCK) ON A.CLNO = c.CLNO
				WHERE
						----schapyala changed enddate to '1/1/1900' for the isnull default for compdate below. - 02/03/2015
							 ((IsNULL(a.compdate,'1/1/1900') > DATEADD(m,-6,@StartDate) AND IsNULL(a.compdate,'1/1/1900') <= @EndDate
							--AND IsNull(er.LastStartDate, er.OriginalStartDate) >= @StartDate and IsNull(er.LastStartDate, er.OriginalStartDate) < @EndDate)
							)OR (IsNULL(a.compdate,'1/1/1900') >= @StartDate AND IsNULL(a.compdate,'1/1/1900') <= @EndDate))
						----------- End Schayala --------
						AND a.apstatus = 'F'
				
						AND (SELECT Count(*) from reportuploadlog r WITH (NOLOCK) where r.ReportID = br.backgroundreportid and r.resend = 0 AND r.ReportType = 1) = 0		
						and a.clno in (16107,16109,16108,16111,17343)
						--AND (C.WebOrderParentCLNO = @CLNO OR a.clno in (select clno from clienthierarchybyservice WITH (NOLOCK) where parentclno = @CLNO and refhierarchyserviceid = 1 ))
						--AND A.APNO NOT IN (SELECT FolderID FROM #tmp)
				) as idTable
				INNER JOIN BackgroundReports.dbo.BackgroundReport br WITH (NOLOCK) on br.apno = idTable.apno
				and br.CreateDate = (Select MAX(createdate) from BackgroundReports.dbo.BackgroundReport WITH (NOLOCK) where apno = idTable.apno)
				AND (SELECT Count(*) from reportuploadlog r WITH (NOLOCK) where r.ReportID = br.backgroundreportid and r.resend = 0 AND r.ReportType = 1) = 0
			) AS Y
	 --End
	 --  DROP TABLE #tmp
END