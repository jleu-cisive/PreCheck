
-- =================================================================================
-- Author:		Prasanna
-- Create date: 06/04/2021
-- Description:	Modified existing procedure BGReportMainPull_Tenet_GBC
-- Execution: EXEC [BGReportMainPull_MedSpot] 15794, '10/01/2019','06/07/2021',1
-- =================================================================================

CREATE PROCEDURE [dbo].[BGReportMainPull_MedSpot]
	@CLNO int, @StartDate datetime,@EndDate datetime,@UseHevnDb bit = 1
AS
BEGIN

	SET @StartDate = '10/01/2019'
	Set @EndDate = '06/07/2021';

	If(@UseHevnDb = 1)
	 BEGIN		

		SELECT FolderID, clno, ReportID, lastname, firstname,employeeNumber, ClientFacilityGroup		
		FROM(
		
			select  idtable.apno as FolderID,idtable.clno, br.backgroundreportid AS ReportID,lastname, firstname,idtable.employeeNumber, isnull(ClientFacilityGroup,'NonGrouped') as ClientFacilityGroup --schapyala returning emptystring for facilitygroup as this is not used for BG purposes - 05/04/2015
			from (
				SELECT DISTINCT  a.apno,cast(a.clno as int) as clno ,a.Last as [LastName], a.First as [FirstName],'000000000' employeeNumber, 'NonGrouped' as ClientFacilityGroup
				FROM   PRECHECK.DBO.appl a  WITH (NOLOCK) 
					INNER JOIN BackgroundReports.dbo.BackgroundReport br WITH (NOLOCK) on a.apno = br.apno  
					INNER JOIN dbo.Client c(NOLOCK) ON A.CLNO = c.CLNO
				WHERE 
				   	 ((IsNULL(a.compdate,'1/1/1900') > DATEADD(m,-6,@StartDate) AND IsNULL(a.compdate,'1/1/1900') <= @EndDate
				  		)OR (IsNULL(a.compdate,'1/1/1900') >= @StartDate AND IsNULL(a.compdate,'1/1/1900') <= @EndDate))
						AND a.apstatus = 'F' 				
						AND (C.CLNO = @CLNO OR a.clno in (15794,15795,15824,15814,15796,15815,15797,15828,15831,15816,15825,15829,15826,15798,15799,15830,15844,15832,15833,15834,15811,15827,15787,15817,
                        15790,15800,15802,15803,15804,15788,15789,15818,15805,15806,15837,15838,15839,15801,15835,15812,15823,15807,15808,15791,15809,15819,15840,15841,
                        15842,15820,15843,15743,15792,15744,15821,15822,15845,15836,15793,15741,15813,15742,15810,16200))
				) as idTable 
				INNER JOIN BackgroundReports.dbo.BackgroundReport br WITH (NOLOCK) on br.apno = idTable.apno
				and br.CreateDate = (Select MAX(createdate) from BackgroundReports.dbo.BackgroundReport WITH (NOLOCK) where apno = idTable.apno)

			) AS Y
	 End


END