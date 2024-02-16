-- =============================================  
-- Author:      Humera Ahmed  
-- Create date: 12/21/2020  
-- Description: Weekly Pending Report by Client(s), Affiliate(s)  
-- EXEC [dbo].[QReport_WeeklyPendingReports] '3115',0 


/* Modified By: YSharma 
-- Modified Date: 07/12/2022
-- Description: Ticketno-#55504 
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
EXEC [dbo].[QReport_WeeklyPendingReports] '3115','0' 
EXEC [dbo].[QReport_WeeklyPendingReports] '3115','4:177' 
*/
-- =============================================  
CREATE PROCEDURE [dbo].[QReport_WeeklyPendingReports]   
 -- Add the parameters for the stored procedure here  
  @CLNO varchar(max) = '0',   
 @AffiliateID Varchar(Max)='0'									-- Added on the behalf for HDT #55504
 --@AffiliateID int = 0											-- Comnt for HDT #55504	
AS  
BEGIN  
 -- SET NOCOUNT ON added to prevent extra result sets from  
 -- interfering with SELECT statements.  
 SET NOCOUNT ON;  
  
    -- Insert statements for procedure here  
 IF(@CLNO = 0 OR @CLNO IS NULL OR LOWER(@CLNO) = 'null' OR @CLNO='')  
 BEGIN  
  SET @CLNO = 0  
 END  
 IF(@AffiliateID = '' OR LOWER(@AffiliateID) = 'null' OR @AffiliateID = '0')   -- Added on the behalf for HDT #55504
 Begin    
  SET @AffiliateID = NULL    
 END 
 
 select   
   a.apno as [Report Number]  
   ,a.clno as [ClientID]  
   ,c.Name AS [Client Name]  
   ,format(a.StartDate, 'MM/dd/yyyy') as [Start Date]  
   ,'Pending' As ReportStatus  
   ,a.attn as Recruiter  
   ,format(a.ApDate,'MM/dd/yyyy') as DateSubmitted  
   ,a.last as [Last Name]  
   ,a.first as [First Name]  
   ,'XXX-XX-'+Right((a.ssn),4) as SSN  
   ,'Employment' as Section  
   ,e.pub_notes as PublicNotes   
 from appl a with (nolock)   
   inner join  empl e with (nolock) on a.apno = e.apno  
   INNER JOIN dbo.Client c ON a.CLNO = c.CLNO  
   INNER JOIN dbo.refAffiliate ra ON c.AffiliateID = ra.AffiliateID  
  where   
   e.isonreport = 1    
   and e.ishidden = 0   
   and a.apstatus = 'P'   
   AND (@CLNO = 0 OR C.CLNO IN (SELECT VALUE FROM fn_Split(@CLNO,':')))  
   and isnull(e.sectstat,'') in ('0','9','8')  
   AND (@AffiliateID IS NULL OR ra.AffiliateID in (SELECT value FROM fn_Split(@AffiliateID,':'))) -- Added on the behalf for HDT #55504
   --AND ra.AffiliateID = IIF(@AffiliateID =0, ra.AffiliateID, @AffiliateID) 						-- Comnt for HDT #55504	 
    
   AND a.CLNO not in (2135,3468)  
   AND c.CLNO = IIF(@CLNO =0, c.CLNO, @CLNO)  
   
  UNION ALL   
  select   
   a.apno  
   ,a.clno as [ClientID]  
   ,c.Name AS [Client Name]  
   ,format(a.StartDate, 'MM/dd/yyyy') as [Start Date]  
   ,'Pending' As ReportStatus  
   ,a.attn  
   ,format(a.ApDate,'MM/dd/yyyy') as DateSubmitted  
   ,a.last,a.first  
   ,'XXX-XX-'+Right((a.ssn),4)  
   ,'Education' as Section  
   ,e.pub_notes as PublicNotes   
  from   
  appl a with (nolock)   
  inner join  educat e with (nolock) on a.apno = e.apno  
  INNER JOIN dbo.Client c ON a.CLNO = c.CLNO  
  INNER JOIN dbo.refAffiliate ra ON c.AffiliateID = ra.AffiliateID  
  where   
   e.isonreport = 1   
   and e.ishidden = 0    
   and a.apstatus = 'P'   
   AND (@CLNO = 0 OR C.CLNO IN (SELECT VALUE FROM fn_Split(@CLNO,':')))  
   and isnull(e.sectstat,'') in ('0','9','8')  
   AND (@AffiliateID IS NULL OR ra.AffiliateID in (SELECT value FROM fn_Split(@AffiliateID,':'))) -- Added on the behalf for HDT #55504
   --AND ra.AffiliateID = IIF(@AffiliateID =0, ra.AffiliateID, @AffiliateID) 						-- Comnt for HDT #55504	 
    
   AND a.CLNO not in (2135,3468)  
   AND c.CLNO = IIF(@CLNO =0, c.CLNO, @CLNO)  
   
  UNION ALL   
  select   
   a.apno  
   ,a.clno as [ClientID]  
   ,c.Name AS [Client Name]  
   ,format(a.StartDate, 'MM/dd/yyyy') as [Start Date]  
   ,'Pending' As ReportStatus  
   ,a.attn  
   ,format(a.ApDate,'MM/dd/yyyy') as DateSubmitted  
   ,a.last  
   ,a.first  
   ,'XXX-XX-'+Right((a.ssn),4)  
   ,'License' as Section  
   ,e.pub_notes as PublicNotes   
  from   
  appl a with (nolock)   
  inner join  proflic e with (nolock) on a.apno = e.apno  
  INNER JOIN dbo.Client c ON a.CLNO = c.CLNO  
  INNER JOIN dbo.refAffiliate ra ON c.AffiliateID = ra.AffiliateID   
  where   
  e.isonreport = 1   
  and e.ishidden = 0   
  and a.apstatus = 'P'   
  AND (@CLNO = 0 OR C.CLNO IN (SELECT VALUE FROM fn_Split(@CLNO,':')))   
  and isnull(e.sectstat,'') in ('0','9','8') 
  AND (@AffiliateID IS NULL OR ra.AffiliateID in (SELECT value FROM fn_Split(@AffiliateID,':'))) -- Added on the behalf for HDT #55504
   --AND ra.AffiliateID = IIF(@AffiliateID =0, ra.AffiliateID, @AffiliateID) 						-- Comnt for HDT #55504	 
   
  AND a.CLNO not in (2135,3468)  
  AND c.CLNO = IIF(@CLNO =0, c.CLNO, @CLNO)  
   
  UNION ALL   
  select   
   a.apno  
   ,a.clno as [ClientID]  
   ,c.Name AS [Client Name]  
   ,format(a.StartDate, 'MM/dd/yyyy') as [Start Date]  
   ,'Pending' As ReportStatus  
   ,a.attn  
   ,format(a.ApDate,'MM/dd/yyyy') as DateSubmitted  
   ,a.last  
   ,a.first  
   ,'XXX-XX-'+Right((a.ssn),4)  
   ,'Criminal' as Section  
   ,e.pub_notes as PublicNotes  
  from   
  appl a with (nolock)   
  inner join  crim e with (nolock) on a.apno = e.apno  
  INNER JOIN dbo.Client c ON a.CLNO = c.CLNO  
  INNER JOIN dbo.refAffiliate ra ON c.AffiliateID = ra.AffiliateID  
  where   
  e.ishidden = 0   
  and a.apstatus = 'P'   
  AND (@CLNO = 0 OR C.CLNO IN (SELECT VALUE FROM fn_Split(@CLNO,':')))  
  and isnull(e.clear,'') not in ('T','F')  
  AND (@AffiliateID IS NULL OR ra.AffiliateID in (SELECT value FROM fn_Split(@AffiliateID,':'))) -- Added on the behalf for HDT #55504
   --AND ra.AffiliateID = IIF(@AffiliateID =0, ra.AffiliateID, @AffiliateID) 						-- Comnt for HDT #55504	   
  AND a.CLNO not in (2135,3468)  
  AND c.CLNO = IIF(@CLNO =0, c.CLNO, @CLNO)  
   
  UNION ALL   
  select   
  a.apno  
  ,a.clno as [ClientID]  
  ,c.Name AS [Client Name]  
  ,format(a.StartDate, 'MM/dd/yyyy') as [Start Date]  
  ,'Pending' As ReportStatus  
  ,a.attn  
  ,format(a.ApDate,'MM/dd/yyyy') as DateSubmitted  
  ,a.last  
  ,a.first  
  ,'XXX-XX-'+Right((a.ssn),4)  
  ,'Personal Reference' as Section  
  ,e.pub_notes as PublicNotes   
  from   
  appl a with (nolock)   
  inner join  persref e with (nolock) on a.apno = e.apno  
  INNER JOIN dbo.Client c ON a.CLNO = c.CLNO  
  INNER JOIN dbo.refAffiliate ra ON c.AffiliateID = ra.AffiliateID  
  where   
  e.isonreport = 1   
  and e.ishidden = 0   
  and a.apstatus = 'P'   
  AND (@CLNO = 0 OR C.CLNO IN (SELECT VALUE FROM fn_Split(@CLNO,':')))  
  and isnull(e.sectstat,'') in ('0','9','8')  
  AND (@AffiliateID IS NULL OR ra.AffiliateID in (SELECT value FROM fn_Split(@AffiliateID,':'))) -- Added on the behalf for HDT #55504
   --AND ra.AffiliateID = IIF(@AffiliateID =0, ra.AffiliateID, @AffiliateID) 						-- Comnt for HDT #55504	   
  AND a.CLNO not in (2135,3468)  
  AND c.CLNO = IIF(@CLNO =0, c.CLNO, @CLNO)  
 order by [Start Date] asc,a.apno ASC  
  
END  