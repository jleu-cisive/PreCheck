  
-- =============================================  
-- Author:  DEEPAK VODETHELA  
-- Create date: 01/06/2020  
-- Description: To generate back ground reports for HCA  
-- Execution: EXEC [BGReportMainPull_HCA_EduReverifyResults] 15989, '01/01/2020','01/10/2020',1  
-- =============================================  
--select * from Client where CLNO = 14565  
CREATE PROCEDURE [dbo].[BGReportMainPull_ThePillClub]  
--DECLARE  
 @CLNO int = null, @StartDate datetime = null,@EndDate datetime = null,@UseHevnDb bit = 0  
AS  
BEGIN  
  
------------------Please use this section for manual reruns-------------------------------------  
 SET @CLNO = 14565;  
 --SET @StartDate = '01/01/2020'  
 --Set @EndDate = '01/31/2020';  
 DROP TABLE IF EXISTS #tmpBGReports  
 DROP TABLE IF EXISTS #tmp  
 -- SET NOCOUNT ON added to prevent extra result sets from  
 -- interfering with SELECT statements.  
 SELECT *   
  INTO #tmpBGReports  
 FROM BackgroundReports.dbo.BackgroundReport br  
 WHERE br.APNO IN   
 (  
 select APNO from dbo.Appl where CLNO  in (@clno) and apstatus in ('F') 
 )  
 ORDER BY br.APNO DESC  
  
 CREATE CLUSTERED INDEX IX_HCAReverify_01 ON #tmpBGReports(APNO)  
  
 --SELECT '#tmpHCA_EduReverifyResults' AS TableName, * FROM #tmpHCA_EduReverifyResults  
   CREATE TABLE #tmp(  
   [FolderID] [int] NOT NULL,  
   [CLNO] [smallint] NOT NULL,  
   [ReportID] [int] NOT NULL,  
   [EmployeeNumber] [varchar](50) NOT NULL,  
   [ClientFacilityGroup] [varchar](50) NULL)  
  
  CREATE CLUSTERED INDEX IX_tmp2_01 ON #tmp([FolderID])  
  
 If(@UseHevnDb = 1)  
  BEGIN     
  INSERT INTO #tmp  
  SELECT DISTINCT idtable.apno as FolderID,idtable.clno AS Clno, br.backgroundreportid AS ReportID,idtable.employeeNumber, isnull(ClientFacilityGroup,'NonGrouped') as ClientFacilityGroup --schapyala returning emptystring for facilitygroup as this is not used for BG purposes - 05/04/2015  
  FROM (  
   SELECT DISTINCT  a.apno,cast(a.clno as int) as clno ,'000000000' employeeNumber, 'NonGrouped' as ClientFacilityGroup  
   FROM PRECHECK.DBO.appl a  WITH (NOLOCK)   
   --INNER JOIN #tmpHCA_EduReverifyResults br WITH (NOLOCK) ON a.apno = br.apno    
   INNER JOIN dbo.Client c(NOLOCK) ON A.CLNO = c.CLNO  
   WHERE a.apstatus = 'F'   
   AND (C.WebOrderParentCLNO = @CLNO OR a.clno in (select clno from clienthierarchybyservice WITH (NOLOCK) where parentclno = @CLNO ))  
   ) as idTable   
   INNER JOIN BackgroundReports.dbo.BackgroundReport br WITH (NOLOCK) on br.apno = idTable.apno  
   --AND br.CreateDate = (Select MAX(createdate) from BackgroundReports.dbo.BackgroundReport WITH (NOLOCK) where apno = idTable.apno)  
  
  --SELECT * FROM #tmp t ORDER BY t.FolderID ASC  
 END  
 ELSE
 BEGIN
  INSERT INTO #tmp  
  select FolderId,Clno,ReportId,EmployeeNumber,ClientFacilityGroup from   
  (SELECT   
   Apno as FolderId,
   @clno as clno, 
   BackgroundReportID as ReportID,    
   '000000000' as EmployeeNumber,
   'PillClub' as ClientFacilityGroup,
   ROW_Number() OVER(Partition By Apno Order By CreateDate desc) as RowNumber  -- because we may have multiple reports in the table we only want the latest  
  FROM   
   #tmpBGReports) t  
  where t.RowNumber = 1  
END
   
SELECT * FROM #tmp t ORDER BY t.FolderID ASC  
END  