  
-- =============================================    
-- Author: Deepak Vodethela    
-- Requester: Valerie K. Salazar    
-- Create date: 03/31/2016    
-- Description: To find out the overseas education by date range    
-- Execution: EXEC [dbo].[Overseas_Education_by_Clients_by_Date_Range] '1/1/2015','1/1/2016','1619:2135:5751',''    
--     EXEC [dbo].[Overseas_Education_by_Clients_by_Date_Range] '03/01/2016','03/31/2016','3115',''    
-- Updated: 4/11/2017: Suchitra Yellapantula - Added Affiliate Parameter per HDT 13333, requested by Valerie K. Salazar    
-- Updated: 4/12/2017: Gaurav Bangia - Ticket requestId# 13427    
-- Updated 3/5/2019: Humera Ahmed - HDT - 47688 - Please add the unique Component TAT in a column to the Overseas Education by Clients by Date Range report.  Should reflect the TAT for the specific component displayed in the row.       
    
/* Change Request Date: 4/12/2017    
1) Please add two columns before public notes:    
     IsHiddenReport-stating items that have moved to unused folder    
     IsOnReport-stating items that have been moved to unused folder    
2) Add column header name- Client Name after clno and re-name clno to Client Id.    
3) Re-name APNO to Report Number    
4) Re-name First and Last to First Name and Last Name    
*/    
    
--Modified by Radhika Dereddy on 03/22/2019 to Add OriginalClose date    
--[dbo].[Overseas_Education_by_Clients_by_Date_Range_CA_test] '03/01/2021', '03/31/2021', '0', 230    
    
-- Modified by : Deepak Vodethela    
-- Modified Date:05/28/2019  for Req#52728.    
-- Modified By Radhika Dereddy for HDT #52735    
-- Modified bY Radhika Dereddy for HDT to add Education transferred record    
-- Modified by Doug DeGenaro to change from Affiliate to Affiliate id  
-- Modified on 10/18/2019 by Humera Ahmed to add SSN column requested in HDT#60343  
-- Modified by Humera Ahmed on 3/2/2020 for HDT#67981  
-- Modified by Prasanna on 4/8/2020 for HDT#70997  
-- Modified by Amy Liu on 09/04/2020 for phase3 of project: IntranetModule: Status-substatus  
-- Modified by Radhika Dereddy on 11/10/2020 while exporting the columns to excel the length of Priv_notes & Pub_notes field is 214766 for APNO =5179533)   
--    and many of more so adding the max length of the excel to accommodate the export.  
-- Modified BY Radhika Dereddy on 04/05/2021 to use Substring on Private Notes and Public Notes instead of limiting the APNO's not to display  
-- Modified BY James Norton on 04/07/2022  Created new _CA version to select by create data rather than original close. 
-- Modified By Mainak Bhadra for Ticket No.55501,modifiing Old parameter @AffiliateId int to Varchar(max) for using multiple Affiliate IDs separated with : 
-- =============================================    
CREATE PROCEDURE [dbo].[Overseas_Education_by_Clients_by_Date_Range_CA]    
 -- Add the parameters for the stored procedure here    
 @StartDate DateTime,    
 @EndDate DateTime,    
 @CLNO VARCHAR(500) = null,    
 --@AffiliateId int = 0 --code commented by Mainak for ticket id -55501
 @AffiliateId varchar(MAX) = '0'--code added by Mainak for ticket id -55501 
  
AS    
SET NOCOUNT ON    
    
--if(@Affiliate is null or @Affiliate='null')    
--begin    
--set @Affiliate=''    
--end    
--declare  @StartDate DateTime ='08/24/2020',    
--   @EndDate DateTime = '08/28/2020',    
--   @CLNO VARCHAR(500) = 0,    
--   @AffiliateId int = 4  
    
if(@CLNO='0' or @CLNO is null or @CLNO='null')    
begin    
set @CLNO=''    
end    

--code added by Mainak for ticket id -55501 starts
	IF @AffiliateId = '0' 
	BEGIN  
		SET @AffiliateId = NULL  
	END
--code added by Mainak for ticket id -55501 ends
    
SELECT      
  [Client ID] = A.CLNO,     
  [Client Name]= C.Name,  
  RA.Affiliate,  
  CASE WHEN F.IsOneHR = 1 THEN 'True' WHEN F.IsOneHR = 0 THEN 'False' WHEN F.IsOneHR IS NULL THEN 'N/A' END AS [IsOneHR],    
  A.Investigator,     
  [Report Number] = A.APNO,     
  E.School AS Education,     
  E.Studies_V AS Studies,     
  E.Degree_V AS [Degree Type],     
  E.To_V AS [Degree Date],    
  E.city AS [Edu City],    
  E.State AS [Edu State],    
  [First Name] = A.First,     
  [Last Name]=A.Last,   
  [SSN] = A.SSN,  --By Humera Ahmed on 10/18/2019 to add SSN column requested in HDT#60343  
  CASE WHEN E.IsIntl IS NULL THEN 'NO' WHEN E.IsIntl = 0 THEN 'NO' ELSE 'YES' END AS [International/Overseas],     
  --dbo.elapsedbusinessdays_2(A.CreatedDate, A.OrigCompDate) AS Turnaround,    
  dbo.elapsedbusinessdays_2(A.CreatedDate, A.CompDate) AS Turnaround,      
  dbo.elapsedbusinessdays_2(A.ReopenDate, A.CompDate) AS [ReOpen Turnaround],     
  dbo.elapsedbusinessdays_2(E.CreatedDate, E.Last_Updated) AS [Component TAT], --Added by Humera Ahmed on 3/5/2019 for HDT#47688    
  S.[Description] AS Status,    
  isnull(sss.SectSubStatus,'') as SecSubStatus,  
  format(A.CreatedDate,'MM/dd/yyyy hh:mm tt') AS [Created Date],     
  format(A.OrigCompDate,'MM/dd/yyyy hh:mm tt')  AS [OriginalClose],    
  format(A.CompDate,'MM/dd/yyyy hh:mm tt') AS [Close Date],     
  --Case WHEN E.IsHistoryRecord =0 THEN 'NO' ELSE 'YES' END as [Education Transferred],    
  A.UserID AS CAM,    
  e.Investigator, W.description as [Web Status],    
  --[Is Hidden Report] = CASE WHEN E.IsHidden = 0 THEN 'On Report' ELSE 'UnUsed' end,    
  --[Is On Report] = CASE WHEN e.IsOnReport = 1 THEN '' ELSE 'UnUsed' END,    
  [Is Hidden Report] = E.IsHidden,    
  [Is On Report] =  e.IsOnReport,    
  SUBSTRING(Replace(REPLACE(e.Pub_Notes, char(10),';'),char(13),';'),1,32767)  [Public Notes],  
  SUBSTRING(Replace(REPLACE(e.Priv_Notes , char(10),';'),char(13),';'), 1, 32767) as  [Private Notes]  
FROM dbo.Appl AS A(NOLOCK)    
INNER JOIN dbo.Educat AS E(NOLOCK) ON E.APNO = A.APNO    
INNER JOIN dbo.SectStat AS S(NOLOCK) ON S.CODE = E.SectStat    
INNER JOIN dbo.Client C(NOLOCK) on C.CLNO = A.CLNO    
INNER JOIN refAffiliate RA(NOLOCK) on RA.AffiliateID = C.AffiliateID    
INNER JOIN dbo.Websectstat AS W(NOLOCK) ON W.code = E.web_status   
LEFT JOIN HEVN.dbo.Facility F (NOLOCK) ON isnull(A.DeptCode,0) = F.FacilityNum  --Humera Ahmed on 3/2/2020 for HDT#67981  
Left join dbo.SectSubStatus sss (nolock) on E.SectStat = sss.SectStatusCode and E.SectSubStatusID = sss.SectSubStatusID  
WHERE   
A.CreatedDate >= @StartDate  --Humera Ahmed on 3/2/2020 for HDT#67981  
AND A.CreatedDate < DATEADD(DAY, 1, @EndDate)  
AND (isnull(@CLNO,'')='' OR A.CLNO IN (SELECT splitdata FROM dbo.fnSplitString(@CLNO,':')))    
--AND (RA.AffiliateId = @AffiliateId or @AffiliateId = 0)  --code commented by Mainak for ticket id -55501
AND (@AffiliateId IS NULL OR RA.AffiliateId IN (SELECT value FROM fn_Split(@AffiliateId,':')))--code added by Mainak for ticket id -55501

--and LEN(Replace(REPLACE(e.Pub_Notes , char(10),';'),char(13),';')) < 32767   
--and LEN(Replace(REPLACE(e.Priv_Notes , char(10),';'),char(13),';')) < 32767   
ORDER BY A.CLNO    
    
SET NOCOUNT OFF  