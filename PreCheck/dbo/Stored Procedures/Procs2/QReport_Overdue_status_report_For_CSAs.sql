
/* =============================================  
 Author  : Shashank Bhoi      
 Requester : Brian Silver      
 Create date: 10/4/2023(mm/dd/yyyy)      
 Description: It's a copy of dbo.[Overdue_status_report] procedure with additional column Pos_Sought,[Orientation Date] and ETADate  
 Execution : EXEC [Precheck].[dbo].[QReport_Overdue_status_report_For_CSAs]   
 -------------------------------------------------------------------------------------------
 Modify By : YSharma
 Create date: 10/12/2023      
 Description: Changing as per requested HDT 113285  
 Execution : EXEC [Precheck].[dbo].[QReport_Overdue_status_report_For_CSAs] '4:116'
 -------------------------------------------------------------------------------------------
 Modify By : Shashank Bhoi
 Create date: 11/02/2023      
 Description: HDT #114293 - Add Attn: To - the email address of the attention to person on the case and Display ETA date (MM/DD/YYYY) instead of the date with time 
 Execution : EXEC [Precheck].[dbo].[QReport_Overdue_status_report_For_CSAs] '4:116'
 -------------------------------------------------------------------------------------------
 Modify By : Cameron DeCook
 Create date: 1/29/2024     
 Description: HDT #124917 - Updating Order Joins
 Execution : EXEC [Precheck].[dbo].[QReport_Overdue_status_report_For_CSAs] '4:116'
 -------------------------------------------------------------------------------------------
 Modify By : Arindam Mitra
 Create date: 02/02/2024     
 Description: HDT #125049 - Re-ordering the orientation date column
 Execution : EXEC [Precheck].[dbo].[QReport_Overdue_status_report_For_CSAs] '4:116'
=============================================== */  

  
CREATE PROCEDURE  [dbo].[QReport_Overdue_status_report_For_CSAs]  

 @AffiliateIDs varchar(MAX) = '0'		-- Added as per HDT 113285 
AS
BEGIN
SET NOCOUNT ON    

 IF @AffiliateIDs = '0'   
 BEGIN    
  SET @AffiliateIDs = NULL    
 END									-- Added as per HDT 113285 

 IF OBJECT_ID('tempdb..#CSAtemp') IS NOT NULL
        DROP TABLE #CSAtemp;
 
SELECT A.Apno, A.ApStatus, A.UserID, A.Investigator,A.ApDate, A.Last, A.First, A.Middle, a.reopendate,  
  a.OrigCompDate As OriginalCloseDate  
  ,C.Name AS Client_Name, C.CLNO, RA.Affiliate,    
  'Elapsed'  = CONVERT(numeric(7,2), dbo.NewElapsedBusinessDays(a.Reopendate,a.ApDate,getdate())),     
  (case when A.InProgressReviewed = 0 then 'False' else 'True' end) as InProgressReviewed,    
  ( SELECT COUNT(1) FROM Crim with (nolock) WHERE (Crim.Apno = A.Apno And IsHidden=0)     
   AND     
     (    
    (Crim.Clear IS NULL) OR (Crim.Clear = 'O') OR (Crim.Clear = 'R') OR (Crim.Clear = 'V') OR (Crim.Clear = 'Z') OR (Crim.Clear = 'W')    
     OR (Crim.Clear = 'X') OR (Crim.Clear = 'E') OR (Crim.Clear = 'M') OR (Crim.Clear = 'N') OR (Crim.Clear = 'Q') OR (Crim.Clear = 'D') OR (Crim.Clear = 'G')    
     )    
  ) AS Crim_Count,    
  (SELECT 0) AS Civil_Count,    
  (SELECT COUNT(1) FROM Credit with (nolock) WHERE (Credit.Apno = A.Apno And IsHidden=0) AND (Credit.SectStat = '9' or credit.sectstat='0') ) AS Credit_Count,    
  (SELECT COUNT(1) FROM DL with (nolock) WHERE (DL.Apno = A.Apno And IsHidden=0) AND (DL.SectStat = '9' or DL.SectStat = '0')) AS DL_Count,    
  (SELECT COUNT(1) FROM Empl with (nolock) WHERE (Empl.Apno = A.Apno) AND Empl.IsOnReport = 1  AND (Empl.SectStat = '9' or empl.sectstat = '0')) AS Empl_Count,    
  (SELECT COUNT(1) FROM Educat with (nolock) WHERE (Educat.Apno = A.Apno) AND Educat.IsOnReport = 1 AND (Educat.SectStat = '9' or Educat.SectStat = '0')) AS Educat_Count,    
  (SELECT COUNT(1) FROM ProfLic with (nolock) WHERE (ProfLic.Apno = A.Apno) AND ProfLic.IsOnReport = 1 AND (ProfLic.SectStat = '9' or ProfLic.SectStat = '0')) AS ProfLic_Count,    
  (SELECT COUNT(1) FROM PersRef with (nolock) WHERE (PersRef.Apno = A.Apno) AND PersRef.IsOnReport = 1 AND (PersRef.SectStat = '9' or PersRef.SectStat = '0')) AS PersRef_Count,    
  (SELECT COUNT(1) FROM medinteg with (nolock) WHERE (medinteg.Apno = A.Apno and IsHidden = 0) AND (medinteg.SectStat = '9' or medinteg.SectStat = '0')) AS Medinteg_Count    
  ,A.Pos_Sought  
  --,OJ.JobStartDate AS [Orientation Date]  
  ,CONVERT(VARCHAR(10),TRY_CAST(VA.ETADate AS DATE),101) AS ETA
    , CASE WHEN CHARINDEX('@', A.Attn) > 1 THEN A.Attn 
		 ELSE CC1.Email END AS [Attn :]
INTO #CSAtemp
FROM dbo.Appl       AS A with (nolock)    
  JOIN dbo.Client      AS C  with (nolock) ON A.Clno = C.Clno    
  JOIN refAffiliate     AS RA on RA.AffiliateID = C.AffiliateID    
  LEFT JOIN dbo.vwApplETA    AS VA ON VA.APNO = A.APNO  
  --Left join Enterprise.[dbo].[Order] AS O  (Nolock) on A.Apno = ordernumber       
  --LEFT join Enterprise.[dbo].[OrderJobDetail] AS OJ  (Nolock) on o.[OrderId]=oj.orderid 
    OUTER APPLY (
      SELECT TOP 1 Email,FirstName, LastName 
	  FROM ClientContacts CC
	  WHERE CC.CLNO = A.CLNO AND CAST(A.Attn AS nvarchar) = (CC.LastName + ', ' + CC.FirstName) AND IsActive = 1
	  ORDER BY 1 DESC
	  ) AS CC1
WHERE (A.ApStatus IN ('P','W',''))        
  AND a.CLNO not in (2135,3468)    
  AND RA.AffiliateID IN (SELECT value FROM fn_Split(ISNULL(@AffiliateIDs,RA.AffiliateID),':')) -- Added as per HDT 113285 
--ORDER BY    
  --elapsed Desc   

  SELECT csa.Apno, csa.ApStatus, csa.UserID, csa.Investigator,csa.ApDate, csa.Last, csa.First, csa.Middle, csa.reopendate,
  csa.OriginalCloseDate, csa.Client_Name, csa.CLNO, csa.Affiliate, csa.Elapsed, csa.InProgressReviewed,
  csa.Crim_Count, csa.Civil_Count, csa.Credit_Count, csa.DL_Count, csa.Empl_Count, csa.Educat_Count, csa.ProfLic_Count, csa.PersRef_Count, csa.Medinteg_Count,    
  csa.Pos_Sought, OJ.JobStartDate AS [Orientation Date], csa.ETA, csa.[Attn :]
    FROM #CSAtemp csa
        LEFT OUTER JOIN Enterprise.[dbo].[Order] AS O (NOLOCK)
            ON csa.APNO = O.OrderNumber
        LEFT OUTER JOIN Enterprise.[dbo].[OrderJobDetail] AS OJ (NOLOCK)
            ON O.[OrderId] = OJ.OrderId
	ORDER BY csa.Elapsed DESC 

END

