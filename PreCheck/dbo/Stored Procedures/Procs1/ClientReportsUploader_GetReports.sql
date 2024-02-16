-- =============================================  
  
-- Author:  <Najma Begum>  
  
-- Create date: <03/28/2011>  
  
-- Description: <Get reports from backgroundreports table based  
  
--     on clientid and apno range/date range>  
  
-- =============================================  
--[ClientReportsUploader_GetReports] 8019  ,'01/01/2010','12/31/2010',1,0,0,1
--[ClientReportsUploader_GetReports] 5752,'','',1,0  
CREATE PROCEDURE [dbo].[ClientReportsUploader_GetReports]  
  
 -- Add the parameters for the stored procedure here  
  
 @clientNo int, @start nvarchar(100), @end nvarchar(100), @searchbydate bit,@FetchOnlineReleaseImage bit =0,@indexFileOnly bit= 0  ,@last4SSNOnly bit=1
  
   
  
   
  
AS  
  
BEGIN  
  
  
  
 SET NOCOUNT ON       --stop the server from returning a message to the client, reduce network traffic  
  
 SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED  
  
   
  
--Get reports by ApNo.  
Create Table #tmpClientReports (APNO Int,CLNO Int,Last varchar(200),First varchar(200),SSN varchar(11),Middle varchar(100),FileName varchar(5000),Images Image)
  
 IF  @searchbydate = 0  
  
begin  
  
    
  
  IF(IsNumeric(@start) = 1 AND IsNumeric(@end) = 1)  
  
  begin  
   Insert into #tmpClientReports
   Select a.APNO,clno,ISNULL(last,'') Last,ISNULL(First,'') first,ISNULL(ssn,'') ssn,ISNULL(middle,'') middle , 
   (Case When isnull(ltrim(rtrim(SSN)),'') <> '' then (REPLACE(ISNULL(last,''),' ','_') + '_' + REPLACE(ISNULL(First,''),' ','_')) + '_' + (case when @last4SSNOnly=1 then right(ssn,4) else replace(ssn,'-','') end) else  (REPLACE(ISNULL(last,''),' ','_') + '_' + REPLACE(ISNULL(First,''),' ','_'))  end) + '_' + cast(a.APNO as varchar) + '_' + cast(a.CLNO as varchar) + '_' + REPLACE(CONVERT(VARCHAR(10), a.CompDate, 101), '/', '') + '_BackgroundReport.PDF' FileName,  
  
     (select backgroundreport from BackgroundReports.dbo.BackgroundReport where apno = b.apno and createdate = b.createddate) as images  
  
   from dbo.appl a inner join (Select apno, max(CreateDate)as createddate from BackgroundReports.dbo.BackgroundReport where backgroundreport is not null group by apno) as b  
  
   ON a.apno = b.apno where a.clno = @clientno and b.apno between @start and @end  
  
   IF @indexFileOnly = 1   
    SELECT DISTINCT TOP 100 PERCENT  ISNULL(Er.EmployeeNumber,'999999')+'|'+t.Last+'|'+t.First+'|'+t.Middle+'|'+CAST(RIGHT(t.SSN,4) AS VARCHAR) +'|'+CAST(CLNO AS VARCHAR) + '\BackgroundReports\'+t.[FileName] 
	FROM #tmpClientReports t LEFT JOIN HEVN..Employeerecord ER 
	ON t.SSN = ER.SSN   
    AND ER.EmployerID IN (SELECT CLNO FROM HEVN..VwEmployer WHERE CLNO = @clientno OR ParentCLNO = @clientno)   
   else  
    SELECT APNO,FileName,Images FROM #tmpClientReports ORDER BY Last  
  
     
  
  end  
  
end  
  
  
  
--Get reports by Date.  
  
ELSE IF @searchbydate = 1  
  
begin  
  
If(IsDate(@start) = 1  AND IsDate(@end) = 1)  
 BEGIN  
    
  SET @start = CAST(@start AS DATE)  
  SET @end = CAST(@end AS DATE)  
  
  IF @FetchOnlineReleaseImage = 0  
  
   BEGIN  
	Insert into #tmpClientReports
    Select a.APNO,clno,ISNULL(last,'') Last,ISNULL(First,'') first,ISNULL(ssn,'') ssn,ISNULL(middle,'') middle , 
	(Case When isnull(ltrim(rtrim(SSN)),'') <> '' then (REPLACE(ISNULL(last,''),' ','_') + '_' + REPLACE(ISNULL(First,''),' ','_')) + '_' + (case when @last4SSNOnly=1 THEN right(ssn,4) else replace(ssn,'-','') end) else  (REPLACE(ISNULL(last,''),' ','_') + '_' + REPLACE(ISNULL(First,''),' ','_'))  end)   + '_' + cast(a.APNO as varchar) + '_' + cast(a.CLNO as varchar)  + '_' + REPLACE(CONVERT(VARCHAR(10), a.CompDate, 101), '/', '')  +  '_BackgroundReport.PDF' FileName,   
    (select backgroundreport from BackgroundReports.dbo.BackgroundReport where apno = b.apno and createdate = b.createddate) as images  
  
    from dbo.appl a (nolock) inner join (Select apno, max(CreateDate)as createddate from BackgroundReports.dbo.BackgroundReport where backgroundreport is not null group by apno) as b  
  
    ON b.apno = a.apno where a.clno = @clientno and a.apdate between @start and Dateadd(d,1,@end) AND compdate IS NOT NULL  
  
    IF @indexFileOnly = 1   
     SELECT  DISTINCT TOP 100 PERCENT  ISNULL(Er.EmployeeNumber,'999999')+'|'+t.Last+'|'+t.First+'|'+t.Middle+'|'+CAST(RIGHT(t.SSN,4) AS VARCHAR) +'|'+'BackgroundReports'+'|'+t.[FileName]    
     FROM #tmpClientReports t LEFT JOIN HEVN..Employeerecord ER ON t.SSN = ER.SSN   
     AND ER.EmployerID IN (SELECT CLNO FROM HEVN..VwEmployer WHERE CLNO = @clientno OR ParentCLNO = @clientno)-- ORDER BY Last  
  
    --SELECT  DISTINCT TOP 100 PERCENT  '999999',t.Last,t.First,t.Middle,RIGHT(t.SSN,4) FROM #tmp2 t  ORDER BY Last --to proove that the same number of records are returned. The below could return more because of multiple applications  
    else  
     SELECT APNO,FileName,Images   
     FROM #tmpClientReports  ORDER BY Last  
  

   END  
   
  else  
   Begin  
      
	Insert into #tmpClientReports
    Select APNO,CLNO,[Last],[First],SSN,[Middle],[FileName],Images From
	(
    Select releaseformID APNO,CLNO,ISNULL(last,'') Last,ISNULL(First,'') first,ISNULL(ssn,'') ssn,'' middle ,
	 (Case When isnull(ltrim(rtrim(SSN)),'') <> '' then (ISNULL(last,'') + '_' + ISNULL(First,'')) + '_' + (case when @last4SSNOnly=1 THEN right(ssn,4) else replace(ssn,'-','') end) else  (ISNULL(last,'') + '_' + ISNULL(First,''))  end)   + '_' + cast(CLNO as varchar)  + '_' + REPLACE(CONVERT(VARCHAR(10), [Date], 101), '/', '') +  (case when [Date] < '2013-09-09 22:17:34.960' then '_Authorization_Disclosure.PDF' else '_Authorization.PDF' end) [FileName], pdf as images   
      from Precheck_MainArchive.dbo.ReleaseForm_Archive (nolock)  
  
    where clno = @clientno and [date]  between @start and Dateadd(d,1,@end)  
  
    UNION ALL  
  
    Select releaseformID APNO ,CLNO, ISNULL(last,'') Last,ISNULL(First,'') first,ISNULL(ssn,'') ssn,'' middle ,
	(Case When isnull(ltrim(rtrim(SSN)),'') <> '' then (ISNULL(last,'') + '_' + ISNULL(First,'')) + '_' + replace(ssn,'-','') else  (ISNULL(last,'') + '_' + ISNULL(First,''))  end)   + '_' + cast(CLNO as varchar)  + '_' + REPLACE(CONVERT(VARCHAR(10), [Date], 101), '/', '') +   '_Authorization.PDF'  [FileName], pdf as images   
  
    from dbo.Releaseform (nolock)  
  
    where clno = @clientno and dbo.Releaseform.[date] between @start and Dateadd(d,1,@end)  
  
    UNION ALL  
  
    Select releaseformID APNO ,CLNO, ISNULL(last,'') Last,ISNULL(First,'') first,ISNULL(ssn,'') ssn,'' middle ,
	(Case When isnull(ltrim(rtrim(SSN)),'') <> '' then (ISNULL(last,'') + '_' + ISNULL(First,'')) + '_' + (case when @last4SSNOnly=1 THEN right(ssn,4) else replace(ssn,'-','') end) else  (ISNULL(last,'') + '_' + ISNULL(First,''))  end)  + '_' + cast(CLNO as varchar)  + '_' + REPLACE(CONVERT(VARCHAR(10), [Date], 101), '/', '') +   '_Disclosure.PDF' [FileName],ApplicantInfo_pdf as images   
  
    from Precheck_MainArchive.dbo.ReleaseForm_Archive (nolock)  
  
    where clno = @clientno and [date]  between @start and Dateadd(d,1,@end)   
  
    and ApplicantInfo_pdf is not null  
  
    UNION ALL  
  
    Select releaseformID APNO ,CLNO, ISNULL(last,'') Last,ISNULL(First,'') first,ISNULL(ssn,'') ssn,'' middle ,
	(Case When isnull(ltrim(rtrim(SSN)),'') <> '' then (ISNULL(last,'') + '_' + ISNULL(First,'')) + '_' + (case when @last4SSNOnly=1 THEN right(ssn,4) else replace(ssn,'-','') end) else  (ISNULL(last,'') + '_' + ISNULL(First,''))  end)   + '_' + cast(CLNO as varchar)  + '_' + REPLACE(CONVERT(VARCHAR(10), [Date], 101), '/', '') +   '_Disclosure.PDF' [FileName], ApplicantInfo_pdf as images   
  
    from dbo.Releaseform (nolock)  
  
    where clno = @clientno and dbo.Releaseform.[date] between @start and Dateadd(d,1,@end)  
  
    and ApplicantInfo_pdf is not null
	)  Qry

    IF @indexFileOnly = 1   
     SELECT  DISTINCT TOP 100 PERCENT  ISNULL(Er.EmployeeNumber,'999999')+'|'+t.Last+'|'+t.First+'|'+t.Middle+'|'+CAST(RIGHT(t.SSN,4) AS VARCHAR) +'|'+'Release'+'|'+t.[FileName]    
     FROM #tmpClientReports t LEFT JOIN HEVN..Employeerecord ER ON t.SSN = ER.SSN   
     AND ER.EmployerID IN (SELECT CLNO FROM HEVN..VwEmployer WHERE CLNO = @clientno OR ParentCLNO = @clientno)-- ORDER BY Last  
  
    --SELECT  DISTINCT TOP 100 PERCENT  '999999',t.Last,t.First,t.Middle,RIGHT(t.SSN,4) FROM #tmp2 t  ORDER BY Last --to proove that the same number of records are returned. The below could return more because of multiple applications  
    else  
     SELECT APNO,FileName,Images    
     FROM #tmpClientReports  ORDER BY Last
   end  
 end  
  
 DROP TABLE #tmpClientReports 
  
end  
  
SET NOCOUNT OFF  
  
SET TRANSACTION ISOLATION LEVEL READ COMMITTED  
  
   
  
END  