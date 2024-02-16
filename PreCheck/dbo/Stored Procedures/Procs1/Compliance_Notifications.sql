-- =============================================  
-- Author:  DEEPAK VODETHELA  
-- Create date: 06/26/2017  
-- Description: how many PreAdverse, Adverse, and Free Reports have been conducted  
-- Requested By: Maximiliana Senkbeil  
-- Execution: EXEC Compliance_Notifications 8507,'01/01/2017','06/26/2017'  
-- =============================================  
CREATE PROCEDURE Compliance_Notifications  
 -- Add the parameters for the stored procedure here  
 @Clno INT,  
 @StartDate DateTime,  
 @EndDate DateTime  
AS  
BEGIN  
 -- SET NOCOUNT ON added to prevent extra result sets from  
 -- interfering with SELECT statements.  
 SET NOCOUNT ON;  
  
    -- Insert statements for procedure here  
 SELECT APNO, [First Name], [Last Name],[Middle Name],[Status Description], [Date], CLNO  
 FROM (  
  SELECT DISTINCT F.APNO, A.[First] AS [First Name], A.[Last] AS [Last Name], A.Middle AS [Middle Name], R.[Status] AS [Status Description], [Date], F.CLNO  
  FROM dbo.AdverseActionHistory AS H(NOLOCK)  
  INNER JOIN dbo.FreeReport AS F(NOLOCK) ON H.AdverseActionID = F.FreeReportID  
  INNER JOIN dbo.Appl AS A(NOLOCK) ON F.APNO = A.APNO  
  INNER JOIN refAdverseStatus AS R(NOLOCK) ON H.StatusID = R.refAdverseStatusID  
  WHERE H.StatusID = 24   
    AND ([Date] BETWEEN @StartDate AND DATEADD(d,1,@EndDate))  
    AND F.CLNO = @Clno  
  UNION ALL  
  SELECT DISTINCT AA.APNO,  A.[First] AS [First Name], A.[Last] AS [Last Name], A.Middle AS [Middle Name], R.[Status] AS [Status Description], [Date], A.CLNO  
  FROM dbo.AdverseAction AS AA(NOLOCK)  
  INNER JOIN dbo.Appl AS A(NOLOCK) ON AA.APNO = A.APNO  
  INNER JOIN dbo.AdverseActionHistory AS H(NOLOCK) ON AA.AdverseActionID = H.AdverseActionID  
  INNER JOIN refAdverseStatus AS R(NOLOCK) ON H.StatusID = R.refAdverseStatusID  
  WHERE H.StatusID IN (1,16)  
    AND ([Date] BETWEEN @StartDate AND DATEADD(d,1,@EndDate))  
    AND A.CLNO = @Clno  
   ) Y   
   ORDER BY [DATE]  
END  