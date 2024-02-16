/*  
select distinct top 10  c.CLNO,AffiliateId,IsNull(cc.FirstName + ' ' + cc.LastName,'No Primary Contact') as [Contact Name] from dbo.Client c inner join dbo.Appl a on c.CLNO = a.CLNO  
inner join dbo.ClientContacts cc on c.CLNO = cc.CLNO    
where AffiliateID is not null and (a.ApDate between '03/01/2019' and '03/31/2019') and cc.PrimaryContact = 1  
order by clno desc  
 
--select AffiliateId from dbo.Client where CLNO = 11625  
--dbo.GetPrivateNotesByClientAffiliate @clientid='15951' ,@StartDate='04/08/2019',@Cam='KDeLeon'  
-- Modified by Radhika dereddy on 10/16/2020 this because while exporting the columns to excel the length of Priv_notes field is 214766 for APNO =5179533)   
-- and many of more so adding the max length of the excel to accommodate the export.  
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
EXEC GetPrivateNotesByClientAffiliate '15951','04/08/2022',NULL,'2:4',NULL
EXEC GetPrivateNotesByClientAffiliate '0','04/08/2022','06/08/2022,'2',NULL
EXEC GetPrivateNotesByClientAffiliate @StartDate='04/08/2019',@Cam='KDeLeon' 
*/
  
CREATE procedure [dbo].[GetPrivateNotesByClientAffiliate]  
(  
@clientid varchar(100) = NULL,  
@startdate datetime = null,  
@enddate datetime = null,  
@affilliateid Varchar(Max)=NULL,   -- Added on the behalf for HDT #54480
-- @affilliateid int=NULL,  		 -- Comnt for HDT #54480 
@cam varchar(8) = null  
)  
as  
IF(@affilliateid = '' OR LOWER(@affilliateid) = 'null' OR @affilliateid = '0')   -- Added on the behalf for HDT #54480
 Begin    
  SET @affilliateid = NULL    
 END  
if (@clientid = '0')															-- Just made 0 to varchar to avoid conversion issue by Ysharma on 07/01/2022
 set @clientid = null  
DECLARE @clients table  
(  
 Idx smallint,  
 ClientID varchar(40)  
)  
  
if (Len(@clientid) > 0 or IsNull(@clientid,'0') <> '0')  
BEGIN  
  
insert into @clients  
select * from fn_Split(@clientid,':')  
  
  
  
select   
   FORMAT(a.ApDate,'MMMM') as [Report Month]  
   ,c.Clno as [Client ID]  
  ,af.Affiliate as Affiliate  
  ,c.Name as [Client Name]  
  ,c.State as [Client State]  
  ,a.Attn as [Contact Name]  
  ,a.APNO as [Report Number]  
  ,convert(varchar(10),a.ApDate,101) + right(convert(varchar(32),a.ApDate,100),8) as [Report Create Date]  
  ,convert(varchar(10),a.OrigCompDate,101) + right(convert(varchar(32),a.OrigCompDate,100),8) as [Original Closed Date]  
  --,a.OrigCompDate as [Original Closed Date]  
  ,case when a.ApStatus = 'P' then 'In Progress' when a.ApStatus='F' then 'Completed' else 'On Hold' end as [Report Status]  
  ,a.EnteredVia as [Submitted Via]  
  ,C.CAM as [Cam]  
  ,a.Priv_Notes as [Oasis Private Notes]  
from   
 dbo.Client c (nolock) inner join dbo.Appl a (nolock) on c.CLNO = a.CLNO   
 inner join dbo.refAffiliate af (nolock) on c.AffiliateID = af.AffiliateID  
 inner join @clients totcl on totcl.ClientID = c.CLNO  
where   
 (a.ApDate between COALESCE(@startdate,a.ApDate)  and COALESCE(@enddate,a.ApDate))   
 AND (@affilliateid IS NULL OR C.AffiliateID in (SELECT value FROM fn_Split(@affilliateid,':'))) -- Added on the behalf for HDT #54480
   --AND C.AffiliateID = COALESCE(@affilliateid,c.AffiliateId,0)							-- Comnt for HDT #54480	   
 and c.CAM = COALESCE(@cam,c.CAM)   
END  
ELSE  
select   
   FORMAT(a.ApDate,'MMMM') as [Report Month]  
   ,c.Clno as [Client ID]  
  ,af.Affiliate as Affiliate  
  ,c.Name as [Client Name]  
  ,c.State as [Client State]  
  ,a.Attn as [Contact Name]  
  ,a.APNO as [Report Number]  
  --,a.ApDate as [Report Create Date]  
  --,a.OrigCompDate as [Original Closed Date]  
   ,convert(varchar(10),a.ApDate,101) + right(convert(varchar(32),a.ApDate,100),8) as [Report Create Date]  
  ,convert(varchar(10),a.OrigCompDate,101) + right(convert(varchar(32),a.OrigCompDate,100),8) as [Original Closed Date]  
  ,case when a.ApStatus = 'P' then 'In Progress' when a.ApStatus='F' then 'Completed' else 'On Hold' end as [Report Status]  
  ,a.EnteredVia as [Submitted Via]  
  ,C.CAM as [Cam]  
  ,Replace(REPLACE(a.Priv_Notes , char(10),';'),char(13),';') as [Oasis Private Notes]  
from   
 dbo.Client c (nolock) inner join dbo.Appl a (nolock) on c.CLNO = a.CLNO   
 inner join dbo.refAffiliate af (nolock) on c.AffiliateID = af.AffiliateID   
where   
 (a.ApDate between COALESCE(@startdate,a.ApDate)  and COALESCE(@enddate,a.ApDate))   
 AND (@affilliateid IS NULL OR C.AffiliateID in (SELECT value FROM fn_Split(@affilliateid,':'))) -- Added on the behalf for HDT #54480
   --AND C.AffiliateID = COALESCE(@affilliateid,c.AffiliateId,0)							-- Comnt for HDT #54480	  
 and c.CAM = COALESCE(@cam,c.CAM)  
 and C.CLNO not in (3468)  
 and LEN(Replace(REPLACE(Priv_Notes , char(10),';'),char(13),';')) < 32767 --Added by Radhika dereddy on 10/16/2020 this because while exporting the columns to excel the length of Priv_notes field is 214766 for APNO =5179533) and many of more so adding the max length of the excel to accommodate the export.  
 