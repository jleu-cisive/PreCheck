  
-- =============================================  
-- Author:  kiran miryala
-- Create date: 9/21/2020  
-- Description: To generate back ground reports for Advent Health  
-- Execution: EXEC [BGReportMainPull_AdventHealth] 15355, '11/01/2019','03/10/2020',1  
-- =============================================  
  
CREATE PROCEDURE [dbo].[BGReportMainPull_AdventHealth]  
 @CLNO int, @StartDate datetime,@EndDate datetime,@UseHevnDb bit = 1  
AS  
BEGIN  
  
  
 SET @StartDate = '12/01/2001'  
 Set @EndDate = CURRENT_TIMESTAMP  
  
 -- SET NOCOUNT ON added to prevent extra result sets from  
  
  BEGIN  

   CREATE TABLE #tmpBackground(  
   [Apno] [int] NOT NULL,  
   [BackgroundReportid] [int] NOT NULL)
   INSERT INTO #tmpBackground  
Select apno ,max(BackgroundReportid) as   BackgroundReportid from BackgroundReports.dbo.BackgroundReport where apno in (  Select [Report Number] from [PRECHECK].[dbo].[BRU_Advent] )
group by apno
  
  CREATE TABLE #tmp(  
   [FolderID] [int] NOT NULL,  
   [CLNO] [smallint] NOT NULL,  
   [ReportID] [int] NOT NULL,  
   [EmployeeNumber] [varchar](50) NOT NULL,  
   [ClientFacilityGroup] [varchar](50) NULL)  
  
  CREATE CLUSTERED INDEX IX_tmp2_01 ON #tmp([FolderID])  
  
  INSERT INTO #tmp  
  SELECT DISTINCT idtable.apno as FolderID, Clno, br.backgroundreportid AS ReportID,idtable.employeeNumber, isnull(ClientFacilityGroup,'NonGrouped') as ClientFacilityGroup --schapyala returning emptystring for facilitygroup as this is not used for BG purposes - 05/04/2015  
  FROM (  
   SELECT DISTINCT  a.apno,cast(a.clno as int) as clno , [PS Emplid] employeeNumber, 'Background_Report' as ClientFacilityGroup  
   FROM PRECHECK.DBO.appl a  WITH (NOLOCK)   
   INNER JOIN [PRECHECK].[dbo].[BRU_Advent]  ba WITH (NOLOCK) ON a.apno = ba.[Report Number] 
   WHERE a.apstatus = 'F'   
    ) as idTable   
   INNER JOIN BackgroundReports.dbo.BackgroundReport br WITH (NOLOCK) on br.apno = idTable.apno  
  
   and   
 idtable.Apno not in (  
Select apno from BackgroundReports.dbo.BackgroundReport where backgroundreportid in (  
select Reportid from ReportUploadLog where ReportUploadVolumeid in (  
select ReportUploadVolumeid from ReportUploadVolume where ForClient = @CLNO and reporttype = 1)
AND resend = 0))
and br.backgroundreportID in (select backgroundreportID from #tmpBackground)
--and  
-- Clno = @CLNO  
--and idtable.APNO not in (4910635,4910640,4910643,4910643,4910643
--)
  
  SELECT top 3000 * FROM #tmp t ORDER BY t.FolderID ASC  
 END  
  
 --SELECT * FROM #tmpHCA_EduReverifyResults  
   DROP TABLE #tmp  
	drop table #tmpBackground
  -- DROP TABLE #tmpHCA_EduReverifyResults  
  
END  