  
-- =============================================  
-- Author:  DEEPAK VODETHELA  
-- Create date: 01/06/2020  
-- Description: To generate back ground reports for HCA  
-- Execution: EXEC [BGReportMainPull_HCA_EduReverifyResults] 15989, '11/01/2019','03/10/2020',1  
-- =============================================  
  
CREATE PROCEDURE [dbo].[BGReportMainPull_HCA_EduReverifyResults_Kiran]  
 @CLNO int, @StartDate datetime,@EndDate datetime,@UseHevnDb bit = 1  
AS  
BEGIN  
  
------------------Please use this section for manual reruns-------------------------------------  
 --SET @CLNO = 7519;  
 --SET @StartDate = '12/01/2019'  
 --Set @EndDate = '02/31/2020';  
  
 -- SET NOCOUNT ON added to prevent extra result sets from  
 -- interfering with SELECT statements.  
-- SELECT APNO   
--  INTO #tmpHCA_EduReverifyResults  
-- FROM BackgroundReports.dbo.BackgroundReport br  
-- WHERE br.APNO IN   
  
-- (select APNO from appl where   
---- Apno not in (  
----Select apno from BackgroundReports.dbo.BackgroundReport where backgroundreportid in (  
----select Reportid from ReportUploadLog where ReportUploadVolumeid in (  
----select ReportUploadVolumeid from ReportUploadVolume where ForClient = @CLNO)))  
----and  
-- Clno = @CLNO )  
-- ORDER BY br.APNO DESC  
  
 --CREATE CLUSTERED INDEX IX_HCAReverify_01 ON #tmpHCA_EduReverifyResults(APNO)  
  
-- SELECT '#tmpHCA_EduReverifyResults' AS TableName, * FROM #tmpHCA_EduReverifyResults  
  
  
 --If(@UseHevnDb = 1)  
  BEGIN  
  
  CREATE TABLE #tmp(  
   [FolderID] [int] NOT NULL,  
   [CLNO] [smallint] NOT NULL,  
   [ReportID] [int] NOT NULL,  
   [EmployeeNumber] [varchar](50) NOT NULL,  
   [ClientFacilityGroup] [varchar](50) NULL)  
  
  CREATE CLUSTERED INDEX IX_tmp2_01 ON #tmp([FolderID])  
  
  INSERT INTO #tmp  
  SELECT DISTINCT idtable.apno as FolderID,idtable.clno AS Clno, br.backgroundreportid AS ReportID,idtable.employeeNumber, isnull(ClientFacilityGroup,'NonGrouped') as ClientFacilityGroup --schapyala returning emptystring for facilitygroup as this is not used for BG purposes - 05/04/2015  
  FROM (  
   SELECT DISTINCT  a.apno,cast(a.clno as int) as clno , employeeNumber, 'HCA_EDU' as ClientFacilityGroup  
   FROM PRECHECK.DBO.appl a  WITH (NOLOCK)   
   --INNER JOIN #tmpHCA_EduReverifyResults br WITH (NOLOCK) ON a.apno = br.apno    
   INNER JOIN (SELECT EmployerID,SSN,employeeNumber,Facilityid,departmentid   
    FROM HEVN.dbo.EmployeeRecord(NOLOCK)  
    WHERE --enddate IS NULL And   
    hrCompany is not null  
      AND Facilityid IS NOT NULL   
      AND departmentid IS NOT NULL   
      AND employeenumber IS NOT NULL   
      AND EmployerID = 7519) AS ER ON ISNULL(a.clno,0) = 15989 AND a.SSN = ER.SSN  
 INNER JOIN (SELECT facilityid,ClientFacilityGroup   
    FROM HEVN.dbo.Facility (NOLOCK)  
    WHERE ParentEmployerID = 7519 or EmployerID = 7519) AS F ON ER.facilityid = F.FacilityID  
  
   INNER JOIN dbo.Client c(NOLOCK) ON A.CLNO = c.CLNO  
   WHERE a.apstatus = 'F' and a.clno = @CLNO  
   --AND (C.WebOrderParentCLNO = @CLNO OR a.clno in (select clno from clienthierarchybyservice WITH (NOLOCK) where parentclno = @CLNO ))  
   ) as idTable   
   INNER JOIN BackgroundReports.dbo.BackgroundReport br WITH (NOLOCK) on br.apno = idTable.apno  
   AND br.CreateDate = (Select MAX(createdate) from BackgroundReports.dbo.BackgroundReport WITH (NOLOCK) where apno = idTable.apno)  
  
  SELECT top 5 * FROM #tmp t ORDER BY t.FolderID ASC  
 END  
  
 --SELECT * FROM #tmpHCA_EduReverifyResults  
   DROP TABLE #tmp  
  -- DROP TABLE #tmpHCA_EduReverifyResults  
  
END  