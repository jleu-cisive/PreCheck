  
-- =============================================  
-- Author: Mainak Bhadra  
-- Create date: 06/22/2022  
-- Description: New Q-Report Name: TAT by client affiliate
-- EXEC [TAT_by_client_affiliate] '01/01/2021','01/31/2021',0, 249  
-- =============================================  
CREATE PROCEDURE [dbo].[TAT_by_client_affiliate]  
(  
@startdate datetime,  
@enddate datetime,  
@clno int,  
@affiliateId int  
)  
  
as   
  
BEGIN    
  
 
  
drop table IF exists #crimsbydaterange  
  
  
SELECT c.CrimID,  
       c.IrisOrdered,    
    a.apno as 'Report Number',  
       cl.name as 'Client Name',  
       a.clno as 'Client ID',  
       cl.State as 'Client State',  
       ra.Affiliate as 'Affiliate',        
       a.First as 'Applicant First Name',   
       a.Last as 'Applicant Last Name',  
       FORMAT(a.DOB,'MM/dd/yyyy hh:mm tt') as 'DOB',   
       FORMAT(a.Apdate, 'MM/dd/yyyy hh:mm tt') as 'Created Date',  
       c.county as 'County',    
       d.a_county as 'Applicant County',  
       d.state as 'State',  
       d.country as 'Country' ,  
    (SELECT Max(cl.ChangeDate) from  ChangeLog cl (NOLOCK) where cl.ID = c.CrimID ) as ChangeDate,  
       FORMAT(c.IrisOrdered, 'MM/dd/yyyy hh:mm tt') as 'Component Order Date',  
       css.CrimDescription as 'Record Status',  
       a.ApStatus as 'ReportStatus',  
       case when d.refCountyTypeID = 5 then 'Yes' else 'No' end  as 'Is International',  
    a.OrigCompDate as [Original Closing Date],  
       ir.R_Name as 'Search Vendor',  
       CASE WHEN c.IsHidden = 1 THEN 'UnUsed'   
           WHEN C.IsHidden = 0 THEN 'On Report' End AS [Unused Crim],  
       C.Name as 'Name On Record',  
       c.CaseNo as 'CaseNo',   
       c.Date_Filed as 'Date_Filed',  
    c.Offense as 'Offense',   
  
       case when c.Degree = '1' then 'Petty Misdemeanor'  
              WHEN c.Degree = '2' THEN 'Traffic Misdemeanor'  
              WHEN c.Degree = '3' THEN 'Criminal Traffic'  
              WHEN c.Degree = '4' THEN 'Traffic'  
              WHEN c.Degree = '5' THEN 'Ordinance Violation'  
              WHEN c.Degree = '6' THEN 'Infraction'  
              WHEN c.Degree = '7' THEN 'Disorderly Persons'  
              WHEN c.Degree = '8' THEN 'Summary Offense'  
              WHEN c.Degree = '9' THEN 'Indictable Crime'  
              WHEN c.Degree = 'F' THEN 'Felony'  
              WHEN c.Degree = 'M' THEN 'Misdemeanor'  
              WHEN c.Degree = 'O' THEN 'Other'  
              WHEN c.Degree = 'U' THEN 'Unknown'  
       END AS  'Degree',  
       c.Sentence as 'Sentence',  
       c.Fine as 'Fine',   
       c.Disp_Date as 'Disp_Date',  
       c.Disposition as 'Disposition'  
  
  
into #crimsbydaterange  
   
FROM crim c(NOLOCK)  
inner join appl a(NOLOCK)  on c.apno = a.apno   
inner join dbo.TblCounties d(NOLOCK) on c.CNTY_NO = d.CNTY_NO    
inner join client cl(NOLOCK) on a.clno = cl.clno   
inner join refAffiliate ra(NOLOCK) on cl.AffiliateId = ra.AffiliateID   
INNER JOIN Crimsectstat AS css  ON c.Clear = css.crimsect  
INNER JOIN IRIS_Researcher_Charges irc WITH (NOLOCK) ON C.vendorid = irc.Researcher_id AND C.CNTY_NO = irc.cnty_no AND irc.Researcher_Default = 'Yes'  
INNER JOIN dbo.Iris_Researchers ir WITH (nolock) ON irc.Researcher_id = ir.R_id  
  
  
  
where (convert(date,a.OrigCompDate) between @StartDate and @EndDate)  
       and a.CLNO in (16022, 16023, 16024, 16469) 
       and ra.AffiliateID = IIF(@affiliateId=0,ra.affiliateId, @affiliateId)   
        --and c.Clear IN ('F','T','P')  
  
  
SELECT   
       c.[Report Number],  
       c.[Client Name],  
       c.[Client ID],  
       c.[Client State],  
       c.Affiliate,        
       c.[Applicant First Name],   
       c.[Applicant Last Name],  
       c.DOB,   
       c.[Created Date],  
       c.County,    
       c.[Applicant County],  
       c.[State],  
       c.[Country] ,  
       CAST(DATEDIFF(d,c.IrisOrdered,c.ChangeDate) as varchar)  as 'Criminal Turnaround Days',  
       CAST(DATEDIFF(HOUR,c.IrisOrdered,c.ChangeDate) as varchar) as 'Criminal Turnaround Hours',  
       c.[Component Order Date],  
       FORMAT(c.ChangeDate,'MM/dd/yyyy hh:mm tt') as 'Component Complete Date',  
       c.[Record Status],  
       c.ReportStatus,  
       c.[Is International],  
    c.[Original Closing Date],  
       c.[Search Vendor],  
       c.[Unused Crim],  
       c.[Name On Record],  
       c.CaseNo,   
       c.Date_Filed,  
    c.Offense,   
    c.[Degree],  
       c.Sentence ,  
       c.Fine ,   
       c.Disp_Date ,  
       c.Disposition   
   
FROM #crimsbydaterange c(NOLOCK)  
ORDER BY c.[Report Number]  
  
  
drop table IF exists #crimsbydaterange  
--drop table IF exists #changelogfoundclosed  
  
  
  
END  