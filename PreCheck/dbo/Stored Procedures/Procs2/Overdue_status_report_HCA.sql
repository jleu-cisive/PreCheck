--[Overdue_status_report_HCA] 1,1,1
--exec [Overdue_status_report_HCA_06182022] 1,1,1
--Modified by Joshua Ates 02/10/2021 Removed Subqueries in the Select Statment and maed them their own temp tables and joined to that in order to reduce server load  
  
CREATE PROCEDURE [dbo].[Overdue_status_report_HCA]    
(  
 @HCA_InModel bit = 1,  
 @includeCompletedReports Bit  = 0,  
 @MergeCompletedReports Bit = 0   
)   
AS  
  
SET NOCOUNT ON  
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED  
BEGIN /* Drop Temp Tables if they exist */  
 DROP TABLE IF EXISTS #tmpHCAOverDue  
 DROP TABLE IF EXISTS #tempPendingPercentages  
 DROP TABLE IF EXISTS #CriminalSearchesOrderedCount  
 DROP TABLE IF EXISTS #CriminalSearchesPendingCount  
 DROP TABLE IF EXISTS #MVROrderedCount  
 DROP TABLE IF EXISTS #MVRPendingCount  
 DROP TABLE IF EXISTS #EmploymentVerificationsOrderedCount  
 DROP TABLE IF EXISTS #EmploymentVerificationsPendingCount  
 DROP TABLE IF EXISTS #EducationVerificationsOrderedCount  
 DROP TABLE IF EXISTS #EducationVerificationsPendingCount  
 DROP TABLE IF EXISTS #LicenseVerificationsOrderedCount  
 DROP TABLE IF EXISTS #LicenseVerificationsPendingCount  
 DROP TABLE IF EXISTS #PersonalReferencesOrderedCount  
 DROP TABLE IF EXISTS #PersonalReferencesPendingCount  
 DROP TABLE IF EXISTS #SanctionCheckOrderedCount  
 DROP TABLE IF EXISTS #SanctionCheckPendingCount  
 DROP TABLE IF EXISTS #APNO  
END  
  
  
Create Table #tmpHCAOverDue (  
       [Report Number] int ,  
       [Report Created Date] DateTime,  
       [Report Status] varchar(10),  
       [Applicant Last Name] varchar(100),  
       [Applicant First Name] varchar(100),  
       [Applicant Middle Name] varchar(50),  
       SSN varchar(11),  
       [Report Reopened Date] Datetime,  
       [Report Completion Date] DateTime,  
        ProcessLevel varchar(50),  
        Requisition varchar(50),  
        [Account Name] varchar(250),  
        [Elapsed Days] int,  
        [Criminal Searches Ordered] int,  
        [Criminal Searches Pending] int,  
        [MVR Ordered] int,  
        [MVR Pending] int,  
        [Employment Verifications Ordered] int,  
        [Employment Verifications Pending] int,  
        [Education Verifications Ordered] int,   
        [Education Verifications Pending] int,  
        [License Verifications Ordered] int,  
        [License Verifications Pending] int,  
        [Personal References Ordered] int,  
        [Personal References Pending] int,  
        [SanctionCheck Ordered] int,  
        [SanctionCheck Pending] int,  
        [Percentage Completed] int  
        )  
CREATE TABLE #tempPendingPercentages  
       (  
       [CAM] varchar(8),  
       [Report Number] int,   
       [Client ID] int,         
       [Client Name] varchar(100),   
       [Recruiter Name] varchar(100),  
       [Reopened] varchar(20),   
       [Admitted] varchar(10),  
       [InProgressReviewed] varchar(20),   
       [Percentage Completed] int,  
       [BusinessDaysInThisPercentage] varchar(10),   
       [Report TAT] int  
       )  
  
  
INSERT INTO #tempPendingPercentages  
EXEC [PendingReportsWithPercentages_ByCAM] null,4  --affiliateID = 4 for HCA
  
/* Create and Fill Counting Temp Tables */  
BEGIN  
  
 CREATE TABLE #APNO  
 (  
  APNO INT Primary Key  
 )  

 INSERT INTO  #APNO  
 SELECT  Distinct Top 100 Percent  
  A.APNO  
 FROM   
  DBO.Appl A with (nolock)  
 INNER JOIN   
  DBO.Client C  with (nolock)   
  ON A.Clno = C.Clno  
 LEFT JOIN   
  #tempPendingPercentages tp   
  ON A.APNO = tp.[Report Number]  
 WHERE  
  C.affiliateid = 4  
  AND A.ApDate >= DateAdd(d,-180,current_TimeStamp) 
  
  
 BEGIN /* Criminal Searches Ordered  */  
  CREATE TABLE #CriminalSearchesOrderedCount  
  (  
    APNO INT   
   ,[Criminal Searches Ordered] INT  
  )  
   
	INSERT INTO #CriminalSearchesOrderedCount(APNO,[Criminal Searches Ordered])  
	SELECT   
	#APNO.APNO  
	,COUNT(*)  AS [Criminal Searches Ordered]  
	FROM   
	DBO.CRIM  WITH (NOLOCK)  --corrected to crim instead of DL - schapyala 06172022
	INNER JOIN  
	#APNO with(nolock)   
	ON #APNO.APNO = CRIM.APNO  
	WHERE  
	IsHidden=0  
	GROUP BY  
	#APNO.APNO  
	END  
  
 BEGIN /* Criminal Searches Pending  */  
  CREATE TABLE #CriminalSearchesPendingCount  
  (  
    APNO INT   
   ,[Criminal Searches Pending] INT  
  )  
   
  INSERT INTO #CriminalSearchesPendingCount(APNO,[Criminal Searches Pending])  
  SELECT    
    Appl.APNO   
   ,COUNT(*) AS [Criminal Searches Pending]      
  FROM   
   DBO.Crim WITH (NOLOCK)   
  INNER JOIN  
   #APNO AS Appl with(nolock)   
   ON Appl.APNO = Crim.APNO  
  WHERE   
   IsHidden=0   
   AND (ISNULL(Crim.Clear,'') NOT IN ('T','F'))  
  GROUP BY  
   Appl.APNO  
      
 END  
  
 BEGIN /* MVR Ordered */  
  CREATE TABLE #MVROrderedCount  
  (  
    APNO INT   
   ,[MVR Ordered] INT  
  )  
   
  INSERT INTO #MVROrderedCount(APNO,[MVR Ordered])  
  SELECT   
    Appl.APNO  
   ,COUNT(*) [MVR Ordered]  
  FROM   
   DBO.DL WITH (NOLOCK)   
  INNER JOIN  
   #APNO AS Appl with(nolock)   
   ON Appl.APNO =  DL.APNO  
  WHERE   
   IsHidden=0   
  GROUP BY  
   Appl.APNO  
 END  
  
 BEGIN /* MVR Pending */  
  CREATE TABLE #MVRPendingCount  
  (  
    APNO INT   
   ,[MVR Pending] INT  
  )  
   
  INSERT INTO #MVRPendingCount(APNO,[MVR Pending])  
  SELECT   
   Appl.APNO  
   ,COUNT(*) AS [MVR Pending]   
  FROM   
   DL WITH (NOLOCK)  
  INNER JOIN  
   #APNO AS Appl with(nolock)   
   ON Appl.APNO =  DL.APNO  
  WHERE   
    IsHidden=0     
  AND (DL.SectStat = '9' or DL.SectStat = '0')  
  GROUP BY  
   Appl.APNO  
 END  
  
 BEGIN /* Employment Verifications Ordered */  
  CREATE TABLE #EmploymentVerificationsOrderedCount  
  (  
    APNO INT   
   ,[Employment Verifications Ordered] INT  
  )  
   
  INSERT INTO #EmploymentVerificationsOrderedCount(APNO,[Employment Verifications Ordered])  
  SELECT   
    Appl.APNO  
   ,COUNT(*) AS [Employment Verifications Ordered]   
  FROM   
   DBO.Empl WITH (NOLOCK)   
  INNER JOIN  
   #APNO AS Appl with(nolock)   
   ON Appl.APNO =  Empl.APNO  
  WHERE   
   Empl.IsOnReport = 1  
  GROUP BY  
   Appl.APNO  
 END  
  
 BEGIN /* Employment Verifications Pending */  
  CREATE TABLE #EmploymentVerificationsPendingCount  
  (  
    APNO INT   
   ,[Employment Verifications Pending] INT  
  )  
   
  INSERT INTO #EmploymentVerificationsPendingCount(APNO,[Employment Verifications Pending] )  
  SELECT   
    Appl.APNO  
   ,COUNT(*) AS [Employment Verifications Pending]  
  FROM   
   DBO.Empl WITH (NOLOCK)   
  INNER JOIN  
   #APNO AS Appl with(nolock)   
   ON Appl.APNO = Empl.APNO  
  WHERE   
   Empl.IsOnReport = 1    
  AND (Empl.SectStat = '9' or empl.sectstat = '0')  
  GROUP BY  
   Appl.APNO  
 END  
  
 BEGIN /* Education Verifications Ordered */  
  CREATE TABLE #EducationVerificationsOrderedCount  
  (  
    APNO INT   
   ,[Education Verifications Ordered] INT  
  )  
   
  INSERT INTO #EducationVerificationsOrderedCount(APNO,[Education Verifications Ordered])  
  SELECT   
    Appl.APNO  
   ,COUNT(*) AS [Education Verifications Ordered]  
  FROM   
   DBO.Educat WITH (NOLOCK)  
  INNER JOIN  
   #APNO AS Appl with(nolock)   
   ON Appl.APNO =  Educat.APNO  
  WHERE   
   Educat.IsOnReport = 1  
  GROUP BY  
   Appl.APNO  
 END  
  
 BEGIN /* Education Verifications Pending */  
  CREATE TABLE #EducationVerificationsPendingCount  
  (  
    APNO INT   
   ,[Education Verifications Pending] INT  
  )  
   
  INSERT INTO #EducationVerificationsPendingCount(APNO,[Education Verifications Pending])  
  SELECT   
    Appl.APNO  
   ,COUNT(*) AS [Education Verifications Pending]  
  FROM   
   DBO.Educat WITH (NOLOCK)  
  INNER JOIN  
   #APNO AS Appl with(nolock)   
   ON Appl.APNO =  Educat.APNO  
  WHERE   
   Educat.IsOnReport = 1   
  AND (Educat.SectStat = '9' or Educat.SectStat = '0')  
  GROUP BY  
   Appl.APNO  
 END  
  
 BEGIN /* License Verifications Ordered */  
  CREATE TABLE #LicenseVerificationsOrderedCount  
  (  
    APNO INT   
   ,[License Verifications Ordered] INT  
  )  
   
  INSERT INTO #LicenseVerificationsOrderedCount(APNO,[License Verifications Ordered])  
  SELECT   
    Appl.APNO  
   ,COUNT(*) AS [License Verifications Ordered]  
  FROM   
   DBO.ProfLic with (nolock)   
  INNER JOIN  
   #APNO AS Appl with(nolock)   
   ON Appl.APNO =  ProfLic.APNO  
  WHERE   
   ProfLic.IsOnReport = 1  
  GROUP BY  
   Appl.APNO  
 END  
  
 BEGIN /* License Verifications Pending */  
  CREATE TABLE #LicenseVerificationsPendingCount    (  
    APNO INT   
   ,[License Verifications Pending] INT  
  )  
   
  INSERT INTO #LicenseVerificationsPendingCount(APNO,[License Verifications Pending])  
  SELECT   
    Appl.APNO  
   ,COUNT(*) AS [License Verifications Pending]  
  FROM   
   DBO.ProfLic WITH (NOLOCK)   
  INNER JOIN  
   #APNO AS Appl with(nolock)   
   ON Appl.APNO =  ProfLic.APNO  
  WHERE   
   ProfLic.IsOnReport = 1   
  AND (ProfLic.SectStat = '9' or ProfLic.SectStat = '0')  
  GROUP BY  
   Appl.APNO  
 END  
  
 BEGIN /* Personal References Ordered */  
  CREATE TABLE #PersonalReferencesOrderedCount  
  (  
    APNO INT   
   ,[Personal References Ordered] INT  
  )  
   
  INSERT INTO #PersonalReferencesOrderedCount(APNO,[Personal References Ordered])  
  SELECT   
    Appl.APNO  
   ,COUNT(*)  AS [Personal References Ordered]  
  FROM   
   DBO.PersRef WITH (NOLOCK)   
  INNER JOIN  
   #APNO AS Appl with(nolock)   
   ON Appl.APNO =  PersRef.APNO  
  WHERE   
   PersRef.IsOnReport = 1  
  GROUP BY  
   Appl.APNO  
 END  
  
 BEGIN /* Personal References Pending */  
  CREATE TABLE #PersonalReferencesPendingCount  
  (  
    APNO INT   
   ,[Personal References Pending] INT  
  )  
   
  INSERT INTO #PersonalReferencesPendingCount(APNO,[Personal References Pending])  
  SELECT   
    Appl.APNO  
   ,COUNT(*) AS  [Personal References Pending]  
  FROM   
   DBO.PersRef WITH (NOLOCK)   
  INNER JOIN  
   #APNO AS Appl with(nolock)   
   ON Appl.APNO =  PersRef.APNO  
  WHERE   
   PersRef.IsOnReport = 1   
  AND (PersRef.SectStat = '9' or PersRef.SectStat = '0')  
  GROUP BY  
   Appl.APNO  
 END  
  
 BEGIN /* SanctionCheck Ordered */  
  CREATE TABLE #SanctionCheckOrderedCount  
  (  
    APNO INT   
   ,[SanctionCheck Ordered] INT  
  )  
   
  INSERT INTO #SanctionCheckOrderedCount(APNO,[SanctionCheck Ordered])  
  SELECT   
    Appl.APNO  
   ,COUNT(*) AS [SanctionCheck Ordered]  
  FROM   
   DBO.medinteg WITH (NOLOCK)  
  INNER JOIN  
   #APNO AS Appl with(nolock)   
   ON Appl.APNO =  medinteg.APNO  
  WHERE   
   IsHidden = 0  
  GROUP BY  
   Appl.APNO  
  -- AS [SanctionCheck Ordered],  
 END  
  
 BEGIN /* SanctionCheck Ordered */  
  CREATE TABLE #SanctionCheckPendingCount  
  (  
    APNO INT   
   ,[SanctionCheck Pending] INT  
  )  
   
  INSERT INTO #SanctionCheckPendingCount(APNO,[SanctionCheck Pending])  
  SELECT   
    Appl.APNO  
   ,COUNT(*) AS [SanctionCheck Pending]  
  FROM   
   DBO.medinteg WITH (NOLOCK)   
  INNER JOIN  
   #APNO AS Appl with(nolock)   
   ON Appl.APNO =  medinteg.APNO  
  WHERE   
   IsHidden = 0  
  AND (medinteg.SectStat = '9' or medinteg.SectStat = '0')  
  GROUP BY  
   Appl.APNO  
 END  
END  
  
Insert into #tmpHCAOverDue  
SELECT A.Apno , A.ApDate ,case when A.ApStatus = 'P' then 'InProgress' else 'Available' end,  
    replace(A.Last,',','') , replace(A.First,',','') , replace(A.Middle,',','') ,SSN, A.reopendate ,A.compDate, replace(isnull(deptcode,0),',', ' ') ,   
    replace(IsNull(Request.value('(/Application/NewApplicant/RequisitionNumber)[1]', 'varchar(50)'),''),',',''),    
       replace(C.Name,',','')  , CONVERT(numeric(7,2), dbo.NewElapsedBusinessDays(a.Reopendate,a.ApDate,getdate())),--'2017-03-26 06:55:00.880')),  
       ISNULL([Criminal Searches Ordered],0),  
       ISNULL([Criminal Searches Pending],0),      
    ISNULL([MVR Ordered],0),  
       ISNULL([MVR Pending],0),  
       ISNULL([Employment Verifications Ordered],0),  
       ISNULL([Employment Verifications Pending],0),  
       ISNULL([Education Verifications Ordered],0),  
       ISNULL([Education Verifications Pending],0),  
       ISNULL([License Verifications Ordered],0),  
       ISNULL([License Verifications Pending],0),  
       ISNULL([Personal References Ordered],0),  
       ISNULL([Personal References Pending],0),  
       ISNULL([SanctionCheck Ordered],0),  
       ISNULL([SanctionCheck Pending],0),  
    (CASE WHEN tp.[Percentage Completed] = 100 THEN 99 ELSE tp.[Percentage Completed] END) as [Percentage Completed]  
FROM   
 DBO.Appl A with (nolock)  
INNER JOIN  
 #APNO  
 ON A.APNO = #APNO.APNO  
INNER JOIN   
 DBO.Client C  with (nolock)   
 ON A.Clno = C.Clno  
LEFT JOIN   
 dbo.PrecheckServiceLog R with(nolock)   
 on a.apno = R.apno and ServiceName = 'PrecheckWebService'  
LEFT JOIN   
 HEVN.dbo.Facility F with(nolock)   
 ON IsNull(Request.value('(/Application/NewApplicant/DeptCode)[1]', 'varchar(50)'),'') = facilitynum   
 AND parentemployerid = 7519   
 AND Isnull(IsOneHR,0) =  @HCA_InModel  
INNER JOIN   
 #tempPendingPercentages tp   
 ON A.APNO = tp.[Report Number]  
LEFT JOIN  
 #CriminalSearchesOrderedCount  
 ON A.APNO = #CriminalSearchesOrderedCount.APNO  
LEFT JOIN  
 #CriminalSearchesPendingCount  
 ON A.APNO = #CriminalSearchesPendingCount.APNO  
LEFT JOIN  
 #MVROrderedCount  
 ON A.APNO = #MVROrderedCount.APNO  
LEFT JOIN  
 #MVRPendingCount  
 ON A.APNO = #MVRPendingCount.APNO  
LEFT JOIN  
 #EmploymentVerificationsOrderedCount  
 ON A.APNO = #EmploymentVerificationsOrderedCount.APNO  
LEFT JOIN  
 #EmploymentVerificationsPendingCount  
 ON A.APNO = #EmploymentVerificationsPendingCount.APNO  
LEFT JOIN  
 #EducationVerificationsOrderedCount  
 ON A.APNO = #EducationVerificationsOrderedCount.APNO  
LEFT JOIN  
 #EducationVerificationsPendingCount  
 ON A.APNO = #EducationVerificationsPendingCount.APNO  
LEFT JOIN  
 #LicenseVerificationsOrderedCount  
 ON A.APNO = #LicenseVerificationsOrderedCount.APNO  
LEFT JOIN  
 #LicenseVerificationsPendingCount  
 ON A.APNO = #LicenseVerificationsPendingCount.APNO  
LEFT JOIN  
 #PersonalReferencesOrderedCount  
 ON A.APNO = #PersonalReferencesOrderedCount.APNO  
LEFT JOIN  
 #PersonalReferencesPendingCount  
 ON A.APNO = #PersonalReferencesPendingCount.APNO  
LEFT JOIN  
 #SanctionCheckOrderedCount  
 ON A.APNO = #SanctionCheckOrderedCount.APNO  
LEFT JOIN  
 #SanctionCheckPendingCount  
 ON A.APNO = #SanctionCheckPendingCount.APNO  
WHERE   
 (C.affiliateid in (4))   
AND (A.ApStatus IN ('P','W'))   
--and A.apno = 4594793  
  
  
--Client did not want the below records to be eliminated - 03/22/2016  
--Eliminate records with no pending items  
--select distinct [Report Number]  into #temp2 from #tmpHCAOverDue where [Criminal Searches Pending] = 0 and [MVR Pending] = 0 and [Employment Verifications Pending] = 0 and [Education Verifications Pending] = 0 and [License Verifications Pending] = 0 and
   
--[Personal References Pending] = 0 and [SanctionCheck Pending] = 0  
  
  
If @includeCompletedReports = 1   
  
 Insert into #tmpHCAOverDue  
 SELECT A.Apno , A.ApDate , Case when A.ApStatus = 'F' then 'Completed' else 'ReOpened' end,  
  replace(A.Last,',','') , replace(A.First,',','') , replace(A.Middle,',','') ,SSN, a.reopendate , a.compdate, replace(isnull(deptcode,0),',', ' ') ,   
  replace(IsNull(Request.value('(/Application/NewApplicant/RequisitionNumber)[1]', 'varchar(50)'),''),',',''),    
  replace(C.Name,',','') , CONVERT(numeric(7,2), dbo.NewElapsedBusinessDays(a.Reopendate,a.ApDate,getdate())),--'2017-03-26 06:55:00.880')),  
  ISNULL([Criminal Searches Ordered],0),  
  0, --[Criminal Searches Pending]  
  ISNULL([MVR Ordered],0),  
  0, --[MVR Pending]  
  ISNULL([Employment Verifications Ordered],0),  
  0, --[Employment Verifications Pending]  
        ISNULL([Education Verifications Ordered],0),  
  0, --AS [Education Verifications Pending]  
  ISNULL([License Verifications Ordered],0),  
  0, -- AS [License Verifications Pending],0),  
  ISNULL([Personal References Ordered],0),  
  0 , --AS  [Personal References Pending],  
  ISNULL([SanctionCheck Ordered],0),  
        0, --AS [SanctionCheck Pending]  
    (CASE WHEN  A.Apstatus <> 'F' THEN 99 ELSE 100 END) as [Percentage Completed]  
FROM   
 DBO.Appl A with (nolock)  
INNER JOIN  
 #APNO  
 ON A.APNO = #APNO.APNO  
INNER JOIN   
 DBO.Client C  with (nolock)   
 ON A.Clno = C.Clno  
LEFT JOIN   
 dbo.PrecheckServiceLog R with(Nolock)   
 on a.apno = R.apno and ServiceName = 'PrecheckWebService'  
LEFT JOIN   
 HEVN.dbo.Facility F with(nolock)   
 ON IsNull(Request.value('(/Application/NewApplicant/DeptCode)[1]', 'varchar(50)'),'') = facilitynum   
 and parentemployerid = 7519   
 and Isnull(IsOneHR,0) =  @HCA_InModel    
LEFT JOIN  
 #CriminalSearchesOrderedCount  
 ON A.APNO = #CriminalSearchesOrderedCount.APNO  
LEFT JOIN  
 #MVROrderedCount  
 ON A.APNO = #MVROrderedCount.APNO  
LEFT JOIN  
 #EmploymentVerificationsOrderedCount  
 ON A.APNO = #EmploymentVerificationsOrderedCount.APNO  
LEFT JOIN  
 #EducationVerificationsOrderedCount  
 ON A.APNO = #EducationVerificationsOrderedCount.APNO  
LEFT JOIN  
 #LicenseVerificationsOrderedCount  
 ON A.APNO = #LicenseVerificationsOrderedCount.APNO  
LEFT JOIN  
 #PersonalReferencesOrderedCount  
 ON A.APNO = #PersonalReferencesOrderedCount.APNO  
LEFT JOIN  
 #SanctionCheckOrderedCount  
 ON A.APNO = #SanctionCheckOrderedCount.APNO  
WHERE   
 (C.affiliateid in (4))   
AND ((A.ApStatus = 'F') or (A.ApStatus = 'P' and OrigCompDate is not null))   
--AND A.ApDate >= DateAdd(d,-180,current_TimeStamp)  
  
  
if @MergeCompletedReports = 1  
    Select distinct *,ResultsURL = 'https://weborder.precheck.net/ClientAccess/webclient.aspx?Apno=' + CAST([Report Number] AS VARCHAR) + '&Clno=7519'   
 From  
 (  
  select * from #tmpHCAOverDue where [Report Status] in ('InProgress','Available')    
   UNION ALL  
  select  * from #tmpHCAOverDue where [Report Status] in ('Completed','ReOpened')   
   and DateDiff(dd,cast([Report Completion Date]  as Date),cast(Current_timeStamp as Date))<=7  
    ) QRY  ORDER BY  [Elapsed Days] Desc  
else  
    Begin  
    --Client wants to include all in progress regardless of the non pending components  
  
    select  distinct 'OverDue' FileType, * from #tmpHCAOverDue where --[Report Number] not in (Select [Report Number] from #temp2) and   
    [Report Status] in ('InProgress','Available')  ORDER BY  [Elapsed Days] Desc  
  
    If @includeCompletedReports = 1  
    select  distinct 'Completed' FileType, * from #tmpHCAOverDue Where [Report Status] in ('Completed','ReOpened') 
	 and DateDiff(dd,cast([Report Completion Date]  as Date),cast(Current_timeStamp as Date))<=7  
      ORDER BY  [Report Created Date] Desc  
  
    end  
  
  
  
  
SET TRANSACTION ISOLATION LEVEL READ COMMITTED  
SET NOCOUNT OFF  
  
set ANSI_NULLS OFF  
  
--set QUOTED_IDENTIFIER OFF  
  