-- =============================================    
-- Author:  Lalit Kumar    
-- Create date: 01/17/2024    
-- Description: To generate back ground reports for AdventHealth   
-- Execution: EXEC [BGReportMainPull_csh] 13966, '01/15/2020','09/01/2023',1    
-- =============================================    
    
CREATE PROCEDURE [dbo].[BGReportMainPull_AdventHealthOffBoarding]    
 @CLNO int, @StartDate datetime,@EndDate datetime,@UseHevnDb bit = 1    
AS    
BEGIN    
    
 --SET @CLNO = 13966;    
 --SET @StartDate = '07/01/1997'--DATEADD(m,-4,getdate());    
 --Set @EndDate = '01/31/2020';    
  set @UseHevnDb=1  
 If(@UseHevnDb = 1)    
  BEGIN    
  --set @StartDate=DATEADD(DAY,1,EOMONTH(DATEADD(month,-12,@EndDate))) ---- disable it later once all the reports have been completed    
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
   SELECT  idtable.apno as FolderID, idtable.clno, br.backgroundreportid AS ReportID,idtable.employeeNumber, isnull(ClientFacilityGroup,'NonGrouped') as ClientFacilityGroup,FacilityNumber     
   FROM (    
    SELECT DISTINCT  a.apno,cast(a.clno as int) as clno ,er.employeeNumber, 'NonGrouped' as ClientFacilityGroup,f.facilitynum as FacilityNumber    
    FROM HEVN.dbo.EmployeeRecord er WITH (NOLOCK)     
     INNER JOIN  HEVN.dbo.Facility F WITH (NOLOCK) on er.facilityid = F.facilityid     
     INNER JOIN  [Precheck].DBO.appl a  WITH (NOLOCK) on ER.ssn = a.ssn     
     INNER JOIN dbo.Client c(NOLOCK) ON A.CLNO = c.CLNO    
     INNER JOIN BackgroundReports.dbo.BackgroundReport br WITH (NOLOCK) on a.apno = br.apno     
    WHERE (F.ParentEmployerID=@CLNO OR F.EmployerID=@CLNO)    
      AND er.facilityid is not null and er.departmentid is not null and er.employeenumber is not null AND      
      (IsNULL(a.compdate,'1/1/1900') >= @StartDate AND IsNULL(a.compdate,'1/1/1900') <= @EndDate)    
       --AND ((IsNULL(a.compdate,'1/1/1900') > DATEADD(m,-6,@StartDate) AND IsNULL(a.compdate,'1/1/1900') <= @EndDate    
       --AND IsNull(er.LastStartDate, er.OriginalStartDate) >= @StartDate and IsNull(er.LastStartDate, er.OriginalStartDate) < @EndDate)    
       --OR (IsNULL(a.compdate,'1/1/1900') >= @StartDate AND IsNULL(a.compdate,'1/1/1900') <= @EndDate))    
     
      AND a.apstatus = 'F'     
        
      AND (SELECT Count(*) from reportuploadlog r WITH (NOLOCK) where r.ReportID = br.backgroundreportid and r.resend = 0 AND r.ReportType = 1 AND r.CreatedDate>'2024-01-17') = 0      
      AND (C.WebOrderParentCLNO = @CLNO OR a.clno in (select clno from clienthierarchybyservice WITH (NOLOCK) where parentclno = @CLNO and refhierarchyserviceid = 1 ))    
    ) as idTable     
    INNER JOIN BackgroundReports.dbo.BackgroundReport br WITH (NOLOCK) on br.apno = idTable.apno    
    and  br.CreateDate = (Select MAX(createdate) from BackgroundReports.dbo.BackgroundReport WITH (NOLOCK) where apno = idTable.apno)    
    AND (SELECT Count(*) from reportuploadlog r WITH (NOLOCK) where r.ReportID = br.backgroundreportid and r.resend = 0 AND r.ReportType = 1  AND r.CreatedDate>'2024-01-17') = 0    
        --WHERE  idTable.APNO IN (0) -- disable this later, Lalit  
  
  --SELECT * FROM #tmp    
    
  SELECT TOP 5000 FolderID, clno, ReportID, employeeNumber, ClientFacilityGroup,FacilityNumber      
  FROM(    
   SELECT * FROM #tmp    
  UNION ALL    
      
   select  idtable.apno as FolderID,idtable.clno, br.backgroundreportid AS ReportID,idtable.employeeNumber, isnull(ClientFacilityGroup,'NonGrouped') as ClientFacilityGroup,FacilityNumber     
   from (    
    SELECT DISTINCT  a.apno,cast(a.clno as int) as clno ,'000000000' employeeNumber, 'NonGrouped' as ClientFacilityGroup,t1.facilitynum as FacilityNumber    
    FROM   [Precheck].DBO.appl a  WITH (NOLOCK)     
     INNER JOIN BackgroundReports.dbo.BackgroundReport br WITH (NOLOCK) on a.apno = br.apno      
     INNER JOIN dbo.Client c(NOLOCK) ON A.CLNO = c.CLNO    
     left join (    
       select f0.* from hevn.dbo.Facility f0     
       inner join (    
       select f.ParentEmployerID,f.FacilityCLNO,count(*)_count    
       from hevn.dbo.facility f where f.IsActive=1 and f.ParentEmployerID=@CLNO    
       group by f.ParentEmployerID,f.FacilityCLNO     
       having count(*)<2  ) t on f0.FacilityCLNO=t.FacilityCLNO and f0.ParentEmployerID=t.ParentEmployerID    
       )t1 on t1.FacilityCLNO=a.CLNO      
    WHERE     
    (IsNULL(a.compdate,'1/1/1900') >= @StartDate AND IsNULL(a.compdate,'1/1/1900') <= @EndDate)    
       -- ((IsNULL(a.compdate,'1/1/1900') > DATEADD(m,-6,@StartDate) AND IsNULL(a.compdate,'1/1/1900') <= @EndDate    
       --)OR (IsNULL(a.compdate,'1/1/1900') >= @StartDate AND IsNULL(a.compdate,'1/1/1900') <= @EndDate))    
      AND a.apstatus = 'F'     
        
      AND (SELECT Count(*) from reportuploadlog r WITH (NOLOCK) where r.ReportID = br.backgroundreportid and r.resend = 0 AND r.ReportType = 1 AND r.CreatedDate>'2024-01-17') = 0      
      AND (C.WebOrderParentCLNO = @CLNO OR a.clno in (select clno from clienthierarchybyservice WITH (NOLOCK) where parentclno = @CLNO and refhierarchyserviceid = 1 ))    
      AND A.APNO NOT IN (SELECT FolderID FROM #tmp)    
    ) as idTable     
    INNER JOIN BackgroundReports.dbo.BackgroundReport br WITH (NOLOCK) on br.apno = idTable.apno    
    and br.CreateDate = (Select MAX(createdate) from BackgroundReports.dbo.BackgroundReport WITH (NOLOCK) where apno = idTable.apno)    
    AND (SELECT Count(*) from reportuploadlog r WITH (NOLOCK) where r.ReportID = br.backgroundreportid and r.resend = 0 AND r.ReportType = 1  AND r.CreatedDate>'2024-01-17') = 0    
     --WHERE  idTable.APNO IN (6115677,6718342) -- disable this later, Lalit  
   ) AS Y    
  End    
    
    DROP TABLE IF EXISTS #tmp    
    
END