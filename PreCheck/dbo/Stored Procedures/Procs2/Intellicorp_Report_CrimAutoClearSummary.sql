
 -- Modified by Maiank for Ticket No. 3600, Oredered Count New column Added

-- Alter Procedure Intellicorp_Report_CrimAutoClearSummary  
  
CREATE   PROCEDURE [dbo].[Intellicorp_Report_CrimAutoClearSummary] @StartDate datetime, @EndDate datetime  
AS  
BEGIN  
  
SET @EndDate = DATEADD(DAY, +1, @EndDate)  
  
SELECT FORMAT(PLS.CreatedDate, 'd') AS Date  
,CN.A_County AS Jurisdiction  
,CN.State AS State  
,Count(PLS.SectionID) AS 'Submission Count'  
,SUM(case when PLS.CrimStatus = 'T' then 1 else 0 end) AS 'Auto Clear Count'  
,SUM(case when PLS.CrimStatus = 'R' then 1 else 0 end) AS 'Exception Count'  
,SUM(case when PLS.CrimStatus IS NULL then 1 else 0 end) AS 'Incomplete Count' 
,sum(case when c.clear = 'T'  then 1 else 0 end) as 'Ordered Count' -- Added by Maiank for Ticket No. 3600

FROM Partner_LogStatus PLS  
 ,Crim C  
 ,dbo.TblCounties CN  
WHERE PLS.PartnerID = 4  
 AND PLS.SectionId = C.CrimId  
 AND C.CNTY_NO = CN.CNTY_NO  
 AND PLS.CreatedDate >= @StartDate  
 AND PLS.CreatedDate < @EndDate  
GROUP BY FORMAT(PLS.CreatedDate, 'd')   
 ,CN.A_County  
 ,CN.State  
ORDER BY FORMAT(PLS.CreatedDate, 'd')  
 ,CN.State  
 ,CN.A_County  
  
END  