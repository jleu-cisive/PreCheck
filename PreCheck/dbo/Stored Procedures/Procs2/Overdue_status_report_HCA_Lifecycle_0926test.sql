
/******************************************************************    
--[Overdue_status_report_HCA_Lifecycle]     
-- Modified by AmyLiu on  08/13/2021: for HDT:13503 remove reopend report in order to remove duplicates.    
-- Modified By Humera Ahmed on 9/22/2021 for HDT#19093 to Add 2 columns - Report TAT and Admitted Crim    
--    
-- Modified by:  Jeff Simenc    
-- Modified Date: 10/19/2021    
-- Modification: replaced exec [ApplToBeFinaled] with query from the SP and changed #tmpAppl table to contain only     
--     the AplNo field.  This is the only field needed for this SP.    
    
-- Modified by:  Humera Ahmed    
-- Modified Date: 01/19/2022    
-- Modification: replaced DateDiff with DateAdd in line #135 and #172   

-- Modified by:  Andy   
-- Modified Date: 09/26/2022    
-- Modification: restricted report to 90 days of data  

-- Test:  exec [dbo].[Overdue_status_report_HCA_Lifecycle_0926test] 

*******************************************************************/    
CREATE PROCEDURE [dbo].[Overdue_status_report_HCA_Lifecycle_0926test]      
(@For_HCA_Inspire Bit = 0 )    
AS    
    
BEGIN    
 SET NOCOUNT ON    
 SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED   

				--declare @For_HCA_Inspire Bit 
				--set @For_HCA_Inspire = 0

 DECLARE @HCA_InModel bit    
 DECLARE @includeCompletedReports Bit     
 DECLARE @MergeCompletedReports Bit     
    
 SET @HCA_InModel =1    
 SET @includeCompletedReports =1    
 SET @MergeCompletedReports =1    
    
 DROP TABLE IF EXISTS  #tempPendingPercentages

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
 EXEC [PendingReportsWithPercentages_ByCAM] null    
    
 DROP TABLE IF EXISTS #tmpHCAOverDue
 Create Table #tmpHCAOverDue (    
        [Report Number] int ,    
        [Report Created Date] DateTime,    
        [Report Status] varchar(10),    
        [Applicant Last Name] varchar(100),    
        [Applicant First Name] varchar(100),    
        [Applicant Middle Name] varchar(50),    
        [SSN] varchar(11),    
        [Report Reopened Date] Datetime,    
        [Report Completion Date] DateTime,    
         ProcessLevel varchar(50),    
         Requisition varchar(50),    
         StartDate varchar(12),    
         [Account Name] varchar(250),    
         [Elapsed Days] int,     
         [Report TAT] int, --Added By Humera Ahmed on 9/22/2021 for HDT#19093 to Add 2 columns - Report TAT and Admitted Crim    
         [Admitted Crim] varchar(10),    
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

    
    CREATE NONCLUSTERED INDEX [ix_tmpHCAOverDue]
ON [dbo].[#tmpHCAOverDue] ([Report Status])
INCLUDE ([Report Number],[Report Created Date],[Applicant Last Name],[Applicant First Name],[Applicant Middle Name],[SSN],[Report Reopened Date],[Report Completion Date],[ProcessLevel],[Requisition],[StartDate],[Account Name],[Elapsed Days],[Report TAT],[Admitted Crim],[Criminal Searches Ordered],[Criminal Searches Pending],[MVR Ordered],[MVR Pending],[Employment Verifications Ordered],[Employment Verifications Pending],[Education Verifications Ordered],[Education Verifications Pending],[License Verifications Ordered],[License Verifications Pending],[Personal References Ordered],[Personal References Pending],[SanctionCheck Ordered],[SanctionCheck Pending],[Percentage Completed])


 Insert into #tmpHCAOverDue    
 SELECT A.Apno , A.ApDate ,case when A.ApStatus = 'P' then 'InProgress' else 'Available' end,    
     replace(A.Last,',','') , replace(A.First,',','') , replace(A.Middle,',','') ,  
  case when @For_HCA_Inspire = 1 then SSN else Right(SSN,4) END,   
  A.reopendate ,A.compDate, replace(isnull(deptcode,0),',', ' ') ,     
     replace(IsNull(TransformedRequest.value('(/Application/NewApplicant/RequisitionNumber)[1]', 'varchar(50)'),''),',',''),   cast(JobStartDate as varchar(12)) ,    
     replace(C.Name,',','')  , CONVERT(numeric(7,2), dbo.NewElapsedBusinessDays(a.Reopendate,a.ApDate,getdate())),    
     tp.[Report TAT], --Added By Humera Ahmed on 9/22/2021 for HDT#19093 to Add 2 columns - Report TAT and Admitted Crim    
     case when tp.Admitted=0 THEN 'No' ELSE 'Yes' END AS [Admitted Crim],    
     (SELECT COUNT(1) FROM dbo.Crim with (nolock) WHERE (Crim.Apno = A.Apno And IsHidden=0) ),   --[Criminal Searches Ordered]    
     (SELECT COUNT(1) FROM dbo.Crim with (nolock) WHERE (Crim.Apno = A.Apno And IsHidden=0) AND (ISNULL(Crim.Clear,'') NOT IN ('T','F')) ), --[Criminal Searches Pending]        
     (SELECT COUNT(1) FROM dbo.DL with (nolock) WHERE (DL.Apno = A.Apno And IsHidden=0) ), --[MVR Ordered]    
     (SELECT COUNT(1) FROM dbo.DL with (nolock) WHERE (DL.Apno = A.Apno And IsHidden=0)   AND (DL.SectStat = '9' or DL.SectStat = '0')) , --[MVR Pending]    
     (SELECT COUNT(1) FROM dbo.Empl with (nolock) WHERE (Empl.Apno = A.Apno) AND Empl.IsOnReport = 1) , --[Employment Verifications Ordered]    
     (SELECT COUNT(1) FROM dbo.Empl with (nolock) WHERE (Empl.Apno = A.Apno) AND Empl.IsOnReport = 1  AND (Empl.SectStat = '9' or empl.sectstat = '0')) , --[Employment Verifications Pending]    
     (SELECT COUNT(1) FROM dbo.Educat with (nolock) WHERE (Educat.Apno = A.Apno) AND Educat.IsOnReport = 1) , --AS [Education Verifications Ordered]    
     (SELECT COUNT(1) FROM dbo.Educat with (nolock) WHERE (Educat.Apno = A.Apno) AND Educat.IsOnReport = 1 AND (Educat.SectStat = '9' or Educat.SectStat = '0')) , --AS [Education Verifications Pending]    
     (SELECT COUNT(1) FROM dbo.ProfLic with (nolock)  WHERE (ProfLic.Apno = A.Apno) AND ProfLic.IsOnReport = 1), -- AS [License Verifications Ordered],    
     (SELECT COUNT(1) FROM dbo.ProfLic with (nolock) WHERE (ProfLic.Apno = A.Apno) AND ProfLic.IsOnReport = 1 AND (ProfLic.SectStat = '9' or ProfLic.SectStat = '0')), -- AS [License Verifications Pending],    
     (SELECT COUNT(1) FROM dbo.PersRef with (nolock) WHERE (PersRef.Apno = A.Apno) AND PersRef.IsOnReport = 1), -- AS [Personal References Ordered],    
     (SELECT COUNT(1) FROM dbo.PersRef with (nolock)  WHERE (PersRef.Apno = A.Apno) AND PersRef.IsOnReport = 1 AND (PersRef.SectStat = '9' or PersRef.SectStat = '0')) , --AS  [Personal References Pending],    
     (SELECT COUNT(1) FROM dbo.medinteg with (nolock) WHERE (medinteg.Apno = A.Apno and IsHidden = 0) ), -- AS [SanctionCheck Ordered],    
     (SELECT COUNT(1) FROM dbo.medinteg with (nolock) WHERE (medinteg.Apno = A.Apno and IsHidden = 0) AND (medinteg.SectStat = '9' or medinteg.SectStat = '0')), --AS [SanctionCheck Pending]    
     (CASE WHEN tp.[Percentage Completed] = 100 THEN 99 ELSE tp.[Percentage Completed] END) as [Percentage Completed]    
 FROM dbo.Appl A with (nolock)    
 Inner JOIN dbo.Client C  with (nolock) ON A.Clno = C.Clno    
 left join dbo.Integration_ordermgmt_request R (Nolock) on a.apno = R.apno     
 Left join Enterprise.[dbo].[Order] O  (Nolock) on A.Apno = ordernumber     
 inner join Enterprise.[dbo].[OrderJobDetail] OJ  (Nolock) on o.[OrderId]=oj.orderid    
 LEFT JOIN HEVN.dbo.Facility F (nolock) ON IsNull(TransformedRequest.value('(/Application/NewApplicant/DeptCode)[1]', 'varchar(50)'),'') = facilitynum and parentemployerid = 7519 and Isnull(IsOneHR,0) =  @HCA_InModel    
 Inner JOIN #tempPendingPercentages tp ON A.APNO = tp.[Report Number]    
 WHERE a.Apdate	> getdate() -90
 and (C.affiliateid in (4))     
 and (A.ApStatus IN ('P','W'))     
 And (A.ApStatus = 'P' and OrigCompDate is null)    ---added by AmyLiu on  08/13/2021: for HDT:13503 remove reopend report in order to remove duplicates.    
    
 --Added By Humera Ahmed on 9/22/2021 for HDT#19093 to Add 2 columns - Report TAT and Admitted Crim  
 
 DROP TABLE IF EXISTS #AdmittedCrim_CompletedReports    

 SELECT     
  aad.APNO    
  , case when sum(isnull(cast(aad.Crim_SelfDisclosed as int),0) )=0 then 'No' else 'Yes' end AS [Admitted Crim]    
 INTO #AdmittedCrim_CompletedReports    
 FROM Appl a(NOLOCK)    
 INNER JOIN dbo.Client c ON a.CLNO = c.CLNO    
 INNER JOIN dbo.ApplAdditionalData aad (NOLOCK) ON a.APNO = aad.APNO    
 WHERE  a.Apdate	> getdate() -90
 and   c.AffiliateID = 4     
  and ((A.ApStatus = 'F') or (A.ApStatus = 'P' and OrigCompDate is not null))     
  and isnull(a.compdate,'1/1/1900') > case when @For_HCA_Inspire = 0 then '7/1/2021' else DateAdd(m,-1,current_timestamp) end    
 GROUP BY aad.APNO    
    
 If @includeCompletedReports = 1     
  Insert into #tmpHCAOverDue    
  SELECT A.Apno , A.ApDate , Case when A.ApStatus = 'F' then 'Completed' else 'ReOpened' end,    
   replace(A.Last,',','') , replace(A.First,',','') , replace(A.Middle,',','') ,  
   case when @For_HCA_Inspire = 1 then SSN else Right(SSN,4) END,   
   a.reopendate , a.compdate, replace(isnull(deptcode,0),',', ' ') ,     
     replace(IsNull(TransformedRequest.value('(/Application/NewApplicant/RequisitionNumber)[1]', 'varchar(50)'),''),',',''),   cast(JobStartDate as varchar(12)),    
    replace(C.Name,',','') , CONVERT(numeric(7,2), dbo.NewElapsedBusinessDays(a.Reopendate,a.ApDate,getdate())) ,    
    dbo.ElapsedBusinessDays_2(A.ApDate, A.OrigCompDate) AS [Report TAT], --Added By Humera Ahmed on 9/22/2021 for HDT#19093 to Add 2 columns - Report TAT and Admitted Crim    
    accr.[Admitted Crim] AS [Admitted Crim],    
     (SELECT COUNT(1) FROM dbo.Crim with (nolock) WHERE (Crim.Apno = A.Apno And IsHidden=0) ),   --[Criminal Searches Ordered]    
     0, --[Criminal Searches Pending]    
     (SELECT COUNT(1) FROM dbo.DL with (nolock) WHERE (DL.Apno = A.Apno And IsHidden=0) ), --[MVR Ordered]    
     0 , --[MVR Pending]    
     (SELECT COUNT(1) FROM dbo.Empl with (nolock) WHERE (Empl.Apno = A.Apno) AND Empl.IsOnReport = 1) , --[Employment Verifications Ordered]    
     0 , --[Employment Verifications Pending]    
     (SELECT COUNT(1) FROM dbo.Educat with (nolock) WHERE (Educat.Apno = A.Apno) AND Educat.IsOnReport = 1) , --AS [Education Verifications Ordered]    
     0, --AS [Education Verifications Pending]    
     (SELECT COUNT(1) FROM dbo.ProfLic with (nolock)  WHERE (ProfLic.Apno = A.Apno) AND ProfLic.IsOnReport = 1), -- AS [License Verifications Ordered],    
     0, -- AS [License Verifications Pending],    
     (SELECT COUNT(1) FROM dbo.PersRef with (nolock) WHERE (PersRef.Apno = A.Apno) AND PersRef.IsOnReport = 1), -- AS [Personal References Ordered],    
     0 , --AS  [Personal References Pending],    
   (SELECT COUNT(1) FROM dbo.medinteg with (nolock) WHERE (medinteg.Apno = A.Apno and IsHidden = 0) ), -- AS [SanctionCheck Ordered],    
   0, --AS [SanctionCheck Pending],    
   (CASE WHEN ISNULL(tp.[Percentage Completed],100) = 100 and A.Apstatus <> 'F' THEN 99 ELSE ISNULL(tp.[Percentage Completed],100) END) as [Percentage Completed]    
 FROM dbo.Appl A with (nolock)    
 Inner JOIN dbo.Client C  with (nolock) ON A.Clno = C.Clno    
 left join dbo.Integration_ordermgmt_request R (Nolock) on a.apno = R.apno     
 Left join Enterprise.[dbo].[Order] O  (Nolock) on A.Apno = ordernumber     
 inner join Enterprise.[dbo].[OrderJobDetail] OJ  (Nolock) on o.[OrderId]=oj.orderid    
 LEFT JOIN HEVN.dbo.Facility F (nolock) ON IsNull(TransformedRequest.value('(/Application/NewApplicant/DeptCode)[1]', 'varchar(50)'),'') = facilitynum and parentemployerid = 7519 and Isnull(IsOneHR,0) =  @HCA_InModel    
 LEFT JOIN #tempPendingPercentages tp ON A.APNO = tp.[Report Number]    
 Inner JOIN #AdmittedCrim_CompletedReports accr ON A.APNO = accr.APNO    
 WHERE a.Apdate	> getdate() -90
 and (C.affiliateid in (4))     
 and ((A.ApStatus = 'F') or (A.ApStatus = 'P' and OrigCompDate is not null)) --and A.ApDate >= DateAdd(d,-90,current_TimeStamp)    
  --and DateDiff(dd,cast(a.compdate  as Date),cast(Current_timeStamp as Date))<=3    
  and isnull(a.compdate,'1/1/1900') > case when @For_HCA_Inspire = 0 then '7/1/2021' else DateAdd(m,-1,current_timestamp) end 

  --TBF Logic   
   DROP TABLE IF EXISTS #tmpAppl
  CREATE TABLE #tmpAppl ( Apno INT)    

 INSERT INTO #tmpAppl    
 SELECT A.Apno    
  FROM dbo.Appl A WITH (NOLOCK)    
 INNER JOIN dbo.Client C ON A.Clno = C.Clno    
 left join dbo.Crim  WITH (NOLOCK) on crim.apno= a.apno And Crim.IsHidden =0 and ( crim.clear is null or crim.clear in ('R','M','O','V','I','W','Z','D'))    
 left join dbo.Civil WITH (NOLOCK) on civil.apno = a.apno AND ((Civil.Clear IS NULL) OR (Civil.Clear = 'O'))    
 left join dbo.Credit WITH (NOLOCK) on (Credit.Apno = A.Apno) AND (Credit.SectStat = '0' OR Credit.SectStat = '9')    
 left join  dbo.DL WITH (NOLOCK)  on (DL.Apno = A.Apno) AND (DL.SectStat = '0' OR DL.SectStat = '9')    
 left join dbo.Empl WITH (NOLOCK) on  (Empl.Apno = A.Apno) AND Empl.IsOnReport = 1 AND (Empl.SectStat = '0' OR Empl.SectStat = '9')    
 left join dbo.Educat WITH (NOLOCK) on  (Educat.Apno = A.Apno) AND Educat.IsOnReport = 1 AND (Educat.SectStat = '0' OR Educat.SectStat = '9')    
 left join dbo.ProfLic WITH (NOLOCK) on (ProfLic.Apno = A.Apno) AND ProfLic.IsOnReport = 1 AND (ProfLic.SectStat ='0' OR ProfLic.SectStat = '9')    
 left join dbo.PersRef WITH (NOLOCK) on  (PersRef.Apno = A.Apno) AND PersRef.IsOnReport = 1 AND (PersRef.SectStat = '0' OR PersRef.SectStat = '9')    
 left join dbo.Medinteg WITH (NOLOCK)  on  (Medinteg.Apno = A.Apno) AND (Medinteg.SectStat = '0' OR Medinteg.SectStat = '9')    
 WHERE a.Apdate	> getdate() -90
 and (A.ApStatus IN ('P','W'))    
    AND ISNULL(A.Investigator, '') <> ''    
    AND A.userid IS NOT null    
    AND ISNULL(c.clienttypeid,-1) <> 15    
 and crim.CrimID is null    
 and civil.CivilID is null    
 and credit.apno is null    
 and DL.APNO is null    
 and empl.EmplID is null    
 and Educat.EducatID is null    
 and ProfLic.ProfLicID is null    
 and PersRef.PersRefID is null    
 and Medinteg.apno is null    
 --and a.APNO= 5558112    
 ORDER BY A.ApDate    
    
 --End TBF Temp    
    
 if @MergeCompletedReports = 1    
  Select distinct *,    
  [Contingent Decision Status] = case when [Criminal Searches Pending] = 0 and [License Verifications Pending] = 0 and [SanctionCheck Pending] = 0 then 'Review' Else 'Pending' End,    
  [Pending Closure <24hrs] = CASE WHEN EXISTS (Select Top 1 1 FROM  #tmpAppl t where  t.Apno = Qry.[Report Number])  THEN 'True' ELSE 'False' END,    
  [Report Conclusion ETA] = (select CASE WHEN Cast(CURRENT_TIMESTAMP as Date) <= max(etadate) then max(etadate) Else Null End from dbo.ApplSectionsETA ETA  Group by ETA.APNO having ETA.APNO =  Qry.[Report Number])  ,    
  ResultsURL = 'https://weborder.precheck.net/ClientAccess/webclient.aspx?Apno=' + CAST([Report Number] AS VARCHAR) + '&Clno=7519'    
  From( select   * from #tmpHCAOverDue ) QRY      
  ORDER BY  [Elapsed Days] Desc    
    
 else    
  Begin    
     --Client wants to include all in progress regardless of the non pending components    
    
     select  distinct 'OverDue' FileType, * from #tmpHCAOverDue 
	 where    [Report Status] in ('InProgress','Available')  ORDER BY  [Elapsed Days] Desc    
    
     If @includeCompletedReports = 1    
    
     select  distinct 'Completed' FileType, * 
	 from #tmpHCAOverDue Where [Report Status] in ('Completed','ReOpened')  
	 ORDER BY  [Report Created Date] Desc    
    
  end    
  
END
