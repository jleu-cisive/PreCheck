-- =============================================  
-- Author:  Prasanna  
-- Create date: 10/17/2018  
-- Description:  Background checks with an Original Close date within the date parameters entered  
-- Execution:   
/*  
EXEC dbo.Business_Hours_TAT '11001:1441:2545:10852:1053:12487','08/01/2018','10/16/2018',0,1  
EXEC dbo.Business_Hours_TAT '0','10/01/2018','10/16/2018',0,0  
*/ 

/* Modified By: YSharma 
-- Modified Date: 07/01/2022
-- Description: Ticketno-#54480 
Modify existing q-reports that have affiliate ids in their search parameters
Details: 
Change search parameters for the Affiliate Id field
     * search by multiple affiliate ids (ex 4:297)
     * want to also be able to search all affiliates by putting zero - meaning 0 to search all affiliates
     * multiple affiliates to be separated by a colon  
Under Parameter Names - after Affiliate ID include this wording (separate by colon, default 0)
*/
---Testing
/*
EXEC Business_Hours_TAT '11001:1441:2545:10852:1053:12487','08/01/2018','10/16/2018','0',1
EXEC Business_Hours_TAT '0','08/01/2018','06/06/2018','4:8',1
*/
-- =============================================  
CREATE PROCEDURE [dbo].[Business_Hours_TAT]  
 -- Add the parameters for the stored procedure here  
 @ClientList varchar(MAX) = NULL,   
 @StartDate datetime,  
 @EndDate datetime,   
 @AffiliateID VArchar(Max),   -- Added on the behalf for HDT #54480
-- @AffiliateID int,  		 -- Comnt for HDT #54480						
 @IsOneHR BIT  
AS  
BEGIN  
 -- SET NOCOUNT ON added to prevent extra result sets from  
 -- interfering with SELECT statements.  
 SET NOCOUNT ON;  
  
 IF(@ClientList = '' OR LOWER(@ClientList) = 'null' OR @ClientList = '0')   
 Begin    
  SET @ClientList = NULL    
 END  
 IF(@AffiliateID = '' OR LOWER(@AffiliateID) = 'null' OR @AffiliateID = '0')   -- Added on the behalf for HDT #54480
 Begin    
  SET @AffiliateID = NULL    
 END  
    -- Insert statements for procedure here  
 SELECT  a.ApDate as [App Date], a.OrigCompDate AS [Original Close Date],   
   a.APNO, a.CLNO, C.NAME AS [Client Name], ra.Affiliate, a.Last AS [App First Name], a.First AS [App Last Name],  
   dbo.ElapsedBusinessDays_2(a.ApDate, a.OrigCompDate) * 12 AS NoOfHours,  
   [dbo].[GetWorkingHours](a.ApDate, a.OrigCompDate) AS [ActualHours],  
   [dbo].[GetWorkingHours](a.ApDate, CONVERT(VARCHAR,DATEADD(DAY, 1, a.ApDate),101) + ' 06:00:00.000') AS [FirstDayHours],  
   [dbo].[GetWorkingHours](a.OrigCompDate, CONVERT(VARCHAR,DATEADD(DAY, 1, a.OrigCompDate),101) + ' 06:00:00.000' ) AS [LastDayHours],  
   [dbo].[ElapsedBusinessDaysInDecimal](a.ApDate, a.OrigCompDate) AS [Business Days]  
   INTO #tmp  
 FROM dbo.Appl a(NOLOCK)   
 INNER JOIN dbo.Client AS c(NOLOCK) ON A.CLNO = c.CLNO  
 INNER JOIN dbo.refAffiliate AS ra(NOLOCK) ON C.AffiliateID = ra.AffiliateID  
 LEFT JOIN HEVN.dbo.Facility F (NOLOCK) ON ISNULL(A.DeptCode,0) = F.FacilityNum  
 WHERE A.ApStatus = 'F'  
   AND A.CLNO NOT IN (3468,2135)  
   AND (@ClientList IS NULL OR A.CLNO in (SELECT value FROM fn_Split(@ClientList,':')))  
   AND A.OrigCompDate BETWEEN @StartDate AND DATEADD(d,1,@EndDate)  
   AND (@AffiliateID IS NULL OR C.AffiliateID in (SELECT value FROM fn_Split(@AffiliateID,':'))) -- Added on the behalf for HDT #54480
   --AND C.AffiliateID = IIF(@AffiliateID=0,C.AffiliateID,@AffiliateID)							-- Comnt for HDT #54480						
   AND F.IsOneHR = @IsOneHR  
  
   --SELECT * FROM #tmp t  
  
   SELECT t.[App Date],t.[Original Close Date],   
    t.APNO, t.CLNO, t.[Client Name], t.Affiliate, t.[App First Name], t.[App Last Name],   
    CASE WHEN t.NoOfHours = t.ActualHours THEN t.ActualHours  
    ELSE t.ActualHours + 1  
    END AS [Business Hours TAT],     
    t.[Business Days]  
   FROM #tmp AS t ORDER BY t.[Original Close Date] asc  
  
   DROP TABLE #tmp  
END  