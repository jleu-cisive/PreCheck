-- ========================================================================================================
-- Author:           Suchitra Yellapantula
-- Create date: 04/26/2017
-- Description:      For Q-Report which shows the number of crims sent through Order Management in IRIS by queue
-- Execution: exec OrderManagementInIris '2017-04-06','2017-04-20',''
-- =========================================================================================================
CREATE PROCEDURE [dbo].[OrderManagementInIris] 
 @StartDate date,
 @EndDate date,
@Investigator varchar(8)
AS
BEGIN
       -- SET NOCOUNT ON added to prevent extra result sets from
       -- interfering with SELECT statements.
       SET NOCOUNT ON;

declare @WebServiceCount int

set @WebServiceCount = (select count(*) from Crim where ordered is not null and deliverymethod='WEB SERVICE' and  crimenteredtime>=@StartDate and crimenteredtime<dateadd(day,1,@EndDate)) 

                                         
                                         
    -- Insert statements for procedure here
select S.SectionKeyID, cast(S.LastUpdateDate as date) [LastUpdateDate], S.LastUpdatedBy
  into #temp_ApplAliasSections
  from ApplAlias_Sections S where LastUpdateDate>@StartDate and LastUpdateDate<dateadd(day,1,@EndDate)
  and IsActive=1 and (isnull(@Investigator,'')='' or S.LastUpdatedBy = @Investigator)
  group by S.SectionKeyId, cast(S.LastUpdateDate as date),S.LastUpdatedBy 


  select S.SectionKeyID, S.LastUpdateDate, S.LastUpdatedBy, C.deliverymethod, C.vendorid
  into #temp_Crims1
  from #temp_ApplAliasSections S inner join Crim C on S.SectionKeyID = C.CrimID
  

  
  select distinct C.LastUpdatedBy [Investigator], 
  (select count(*) from #temp_Crims1 C1 where LastUpdatedBy = C.LastUpdatedBy and C1.deliverymethod like 'Online%')  [Online],
  (select count(*) from #temp_Crims1 C1 where LastUpdatedBy = C.LastUpdatedBy and C1.deliverymethod='Call_In')  [Call In],
  (select count(*) from #temp_Crims1 C1 where LastUpdatedBy = C.LastUpdatedBy and C1.deliverymethod='Fax')  [Fax],
  (select count(*) from #temp_Crims1 C1 where LastUpdatedBy = C.LastUpdatedBy and C1.deliverymethod='Fax-CopyofCheck')  [FaxCheck],
  (select count(*) from #temp_Crims1 C1 where LastUpdatedBy = C.LastUpdatedBy and C1.deliverymethod='Mail')  [Mail],
  (select count(*) from #temp_Crims1 C1 where LastUpdatedBy = C.LastUpdatedBy and C1.deliverymethod='Mail-CopyofCheck')  [MailCheck],
  (select count(*) from #temp_Crims1 C1 where LastUpdatedBy = C.LastUpdatedBy and C1.deliverymethod='E-Mail')  [Email],
  (select count(*) from #temp_Crims1 C1 where LastUpdatedBy = C.LastUpdatedBy and C1.deliverymethod='InHouse' and C1.vendorid<>262)  [InHouse],  
  (select count(*) from #temp_Crims1 C1 where LastUpdatedBy = C.LastUpdatedBy and C1.vendorid=262)  [DPS_InHouse],
  (select count(*) from #temp_Crims1 C1 where LastUpdatedBy = C.LastUpdatedBy and C1.deliverymethod='Integration')  [Integration],
  (select count(*) from #temp_Crims1 C1 where LastUpdatedBy = C.LastUpdatedBy and C1.deliverymethod='WEB SERVICE')  [WebServiceVendors],
  --(select count(*) from #temp_Crims1 C1 where LastUpdatedBy = C.LastUpdatedBy and C1.deliverymethod not in ('OnlineDB','Call_In','Fax','Fax-CopyofCheck','Mail','Mail-CopyofCheck','E-Mail','InHouse','WEB SERVICE') and C.vendorid<>262) [Misc]
  (select count(*) from #temp_Crims1 C1 where LastUpdatedBy = C.LastUpdatedBy) [Total]
  into #temp_Counts
  from #temp_Crims1 C



select * from 
 (select C.Investigator, C.Online, C.[Call In], C.Fax, C.FaxCheck, C.Mail, C.MailCheck, C.Email, C.InHouse, C.DPS_InHouse, C.Integration,
(C.Total - (C.Online+C.[Call In] + C.Fax + C.FaxCheck + C.Mail + C.MailCheck + C.Email + C.InHouse + C.DPS_InHouse + C.Integration + C.WebServiceVendors)) [Misc],
C.Total
from #temp_Counts C
union
(select 'Web Service' [Investigator],0,0,0,0,0,0,0,0,0,0,0,@WebServiceCount)) C1
order by 
 case C1.Investigator 
 when 'Web Service' then 1
else 0 
 end asc


  drop table #temp_ApplAliasSections
  drop table #temp_Crims1
  drop table #temp_Counts

END


