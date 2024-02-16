
-- =================================================================================
-- Author:		Prasanna
-- Create date: 06/04/2021
-- Description:	Modified existing procedure BGReportMainPull_Tenet_GBC
-- Execution: EXEC [BGReportMainPull_CareSpot] 15655, '10/01/2019','06/07/2021',1
-- =================================================================================

CREATE PROCEDURE [dbo].[BGReportMainPull_CareSpot]
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
						AND (C.CLNO = @CLNO OR a.clno in (15655,15725,15747,15751,15755,15756,15757,15767,15748,16159,16306,15749,15750,15782,16118,15771,15752,15758,16161,15764,15765,16121,15772,15759,
                            15773,15754,15766,15753,16191,15760,15768,15769,15775,15776,15778,15779,15761,15774,15762,15781,15783,15784,15780,15777,15763,15785,15786,16622 ))
				) as idTable 
				INNER JOIN BackgroundReports.dbo.BackgroundReport br WITH (NOLOCK) on br.apno = idTable.apno
				and br.CreateDate = (Select MAX(createdate) from BackgroundReports.dbo.BackgroundReport WITH (NOLOCK) where apno = idTable.apno)

			) AS Y
	 End


END