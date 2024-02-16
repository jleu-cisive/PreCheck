
/* =============================================  
-- Author:  Prasanna  
-- Create date: 04/04/2022  
-- Description: StudentCheck Order Details Report with Statuses(HDT#43004 Create a New Report for StudentCheck Client - Grand Canyon University)  
-- Execution: EXEC [StudentOrderDetailsWithStatuses]   
				
ModifiedBy		ModifiedDate(MM/DD/YYYY)	TicketNo	Description
Shashank Bhoi	03/02/2022					67397		#67397 Update Report for Grand Canyon University 
														1.Remove the time stamp from columns DateOfBirth,[Background Check Order Date] and [Drug Test Order Date]
														2.Remove the date(keep it blank) when the status is NOT ORDERED
Shashank Bhoi	04/28/2022					92802		#92802 Updates needed to report for Grand Canyon University - Replace comma separator with semicolon 
Anil Rai        05/23/2023                  95759       For HDT#95759 Add date condition To show report data from 01/01/2023
Arindam Mitra	01/24/2024					123882		#123882 Updates needed to report for Grand Canyon University - Replace comma separator with blank for firstname and last name column 

-- =============================================  */
CREATE PROCEDURE [dbo].[StudentOrderDetailsWithStatuses]  
 AS  
BEGIN  
  
 --   DROP TABLE IF EXISTS #tmpOrder  
 --DROP TABLE IF EXISTS #tmpSelectedAliases  
 --DROP TABLE IF EXISTS #tmpNameByAPNO  
  
 SELECT rs.ClientId,c.[Name] [Client Name],rs.ProgramName AS [Program Selected],rs.OrderNumber ,  
     --rs.Applicant_FirstName AS [First Name], --Code commented by Arindam for ticket# 123882 
	 replace(rs.Applicant_FirstName, ',', '') AS [First Name], --Code added by Arindam for ticket# 123882  
     --rs.Applicant_LastName AS [Last Name],  --Code commented by Arindam for ticket# 123882 
	 replace(rs.Applicant_LastName, ',', '') AS [Last Name],  --Code added by Arindam for ticket# 123882 
     SUBSTRING(RS.Applicant_UID, LEN(RS.Applicant_UID) - 3, 4) as SSN,  
     replace(VAO.Email, ',', ';') Email,  
     --VAO.DateOfBirth, --Code commenetd by Shashank for ticket id 67397
	 CAST(CAST(VAO.DateOfBirth AS DATE) as VARCHAR(10)) AS DateOfBirth,  --Code added by Shashank for ticket id 67397  
	 VAO.ApplicantID,  
   --  AI.studentId,  
     --Code commenetd by Shashank for ticket id 67397 Starts
     --IIF(rs.HasBackground = 1, IIF((ISNULL(c.ClientTypeID,0)<>6), BR.DisplayName, BS.DisplayName), 'Not Ordered') AS [Background Check Status],  
     --IIF(rs.HasBackground = 1, RS.OrderCreateDate , '') AS [Background Check Order Date],  
     --IIF(rs.HasDrugScreen = 1, IIF((ISNULL(c.ClientTypeID,0)<>6), DR.DisplayName, DS.DisplayName), 'Not Ordered') AS [Drug Test Status],  
     --IIF(rs.HasDrugScreen = 1, RS.OrderCreateDate, '') AS [Drug Test Order Date]
	 --Code commenetd by Shashank for ticket id 67397 Ends
	 
	 --Code added by Shashank for ticket id 67397 Starts
	 IIF(rs.HasBackground = 1, IIF((ISNULL(c.ClientTypeID,0)<>6), COALESCE(BR.DisplayName,BS.DisplayName), BS.DisplayName), 'Not Ordered') AS [Background Check Status],  
	 IIF(rs.HasBackground = 1, CAST(CAST(RS.OrderCreateDate AS DATE) AS VARCHAR(10)), '') AS [Background Check Order Date],  
	 IIF(rs.HasDrugScreen = 1, IIF((ISNULL(c.ClientTypeID,0)<>6), COALESCE(DR.DisplayName,DS.DisplayName), DS.DisplayName), 'Not Ordered') AS [Drug Test Status], 
	 IIF(rs.HasDrugScreen = 1, CAST(CAST(RS.OrderCreateDate AS DATE) AS VARCHAR(10)), '') AS [Drug Test Order Date]
	 --Code added by Shashank for ticket id 67397 Ends 
 INTO #tmpOrder  
 FROM REPORT.OrderSummary rs  
  INNER JOIN [PRECHECK].[dbo].Client C ON RS.ClientId=C.CLNO  
  INNER JOIN [Enterprise].[dbo].[vwApplicantOrder]  VAO ON vao.OrderNumber = rs.OrderNumber  
  --INNER JOIN [Enterprise].[dbo].[ApplicantImmunization] AI ON AI.ApplicantId = VAO.ApplicantId  
  LEFT OUTER JOIN [REPORT].refOrderSummaryStatus BS  
   ON rs.BG_OrderStatusId = BS.OrderSummaryStatusId  
  LEFT OUTER JOIN [REPORT].refOrderSummaryStatus DS  
   ON rs.DT_OrderStatusId = DS.OrderSummaryStatusId  
  LEFT OUTER JOIN [REPORT].refOrderSummaryResult BR  
   ON rs.BG_ResultId = BR.OrderSummaryResultId   
  LEFT OUTER JOIN [REPORT].refOrderSummaryResult DR  
   ON rs.DT_ResultId = DR.OrderSummaryResultId   
 WHERE rs.ClientId  in(15952,15945,16290,15946,16291,15726,15943,15950)  
 --AND DATEDIFF(DAY,ISNULL(rs.OrderCreateDate,'1/1/1900'),GETDATE()) <= 7  
 AND RS.OrderCreateDate >='2023-01-01'
 ORDER BY RS.OrderCreateDate  
  
 --select * from #tmpOrder 
  
 SELECT t.OrderNumber, t.ApplicantId,  
   --ISNULL(AA.FirstName,'') +' '+ ISNULL(AA.MiddleName,'') +' '+ ISNULL(AA.LastName,'') as [QualifiedNames]  --Code commented by Arindam for ticket# 123882 
   ISNULL(REPLACE(AA.FirstName,';', ''), '') +' '+ ISNULL(REPLACE(AA.MiddleName, ',', ''),'') +' '+ ISNULL(REPLACE(AA.LastName, ',', ''),'') as [QualifiedNames]  --Code added by Arindam for ticket# 123882 
  INTO #tmpNameByAPNO  
 FROM #tmpOrder t (NOLOCK)  
 LEFT OUTER JOIN [Enterprise].[dbo].[ApplicantAlias] AA ON t.ApplicantID = AA.ApplicantID  
  
    --select * from #tmpNameByAPNO   
  
   SELECT  t.OrderNumber,  
	--AliasNames = STUFF((SELECT ', ' + QualifiedNames  --Code commented by Shashank for ticket id 92802
	AliasNames = STUFF((SELECT '; ' + QualifiedNames	--Code added by Shashank for ticket id 92802
          FROM #tmpNameByAPNO b   
          WHERE b.ApplicantId = t.ApplicantId  
          FOR XML PATH('')), 1, 2, '')   
	INTO #tmpSelectedAliases  
	FROM #tmpNameByAPNO t (NOLOCK)  
	GROUP BY t.ApplicantId,  t.OrderNumber  
  
 --select * from #tmpSelectedAliases  
  
  
 SELECT  DISTINCT  
   t.ClientId as [Client ID],t.[Client Name],t.[Program Selected],t.OrderNumber as [Order Number],t.[First Name],t.[Last Name],t.SSN as [Last 4 SSN],t.DateOfBirth [DOB],  
   K.AliasNames as [Alias Names], t.Email, t.[Background Check Order Date], t.[Background Check Status],  t.[Drug Test Order Date], t.[Drug Test Status]  
 FROM #tmpOrder t (NOLOCK)  
 LEFT OUTER JOIN #tmpSelectedAliases AS K(NOLOCK) ON T.OrderNumber = k.OrderNumber  
END
