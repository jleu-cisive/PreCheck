-- =============================================  
-- Author:  Suchitra Yellapantula  
-- Create date: 2/21/2017  
-- Description: Clients with Oasis Client Form Criminal Requirement of All Counties Within 7 Years  
-- Execution exec dbo.[ClientsCrimRequirementsofAllCounties] '2016-06-01','2016-06-03',0  
-- =============================================  
CREATE PROCEDURE [dbo].[ClientsCrimRequirementsofAllCounties]  
 -- Add the parameters for the stored procedure here  
@StartDate datetime,   
@EndDate datetime,   
@CLNO int  
AS  
BEGIN  
   
--set @StartDate='2016-06-01'  
--set @EndDate = '2016-07-01'  
  
if @CLNO = '' or LOWER(@CLNO)='null'  
begin  
 set @CLNO = 0  
end  
  
--First get all the Apnos within the input date range  
Select APNO, CLNO, PackageID   
into #temp1   
from Appl   
where apdate between @StartDate and DateAdd(d,1,@EndDate)  
and isnull(@CLNO,0)=0 or CLNO = @CLNO  
  
  
Select distinct T1.APNO, T1.CLNO, T1.PackageID,count(C.CrimID) as 'CrimCount'  
into #temp2   
from Crim C (NOLOCK) inner join #temp1 T1 on T1.APNO = C.APNO  
where ishidden = 0 and CNTY_NO not in (2480,2738,2737,3519,229)  
 --and C.Apno in (select Apno from #temp1)  
group by T1.APNO,T1.CLNO,T1.PackageID  
  
  
  
select C.CLNO, C.Name as 'ClientName',RA.Affiliate,   
(CASE WHEN isnull(R.NumOfRecord,0)=-1 THEN 'All' ELSE CAST(isnull(R.NumOfRecord,0) as varchar) END) as 'OasisCriminalRequirement-NumberOfCounty', isnull(R.TimeSpan,0) as 'Number of Year', PM.PackageID,  
PM.PackageDesc as 'Package Name',CP.Rate as 'Package Price', PS.IncludedCount as 'Included Crim Searches', RS.Description [Special Registries]  
into #temp4  
from client C  
left join refRequirement R on R.CLNO = C.CLNO and R.RecordType='crim'  
inner join ClientPackages CP on CP.CLNO = C.CLNO  
inner join PackageMain PM on PM.PackageID = CP.PackageID  
inner join PackageService PS on PS.PackageID = CP.PackageID  
inner join refAffiliate RA on RA.AffiliateID = C.AffiliateID  
inner join refRequirementText RT on RT.CLNO = C.CLNO  
inner join refStatewide RS on RS.StateWideID = RT.StatewideID  
--left join (select count(1) crimcount from #temp2 )  
where isnull(R.TimeSpan,0)<=7  
and PS.ServiceType=0  
and isnull(@CLNO,0)=0 or C.CLNO = @CLNO  
  
  
select T4.CLNO, T4.ClientName, T4.Affiliate,T4.[OasisCriminalRequirement-NumberOfCounty],T4.[Number of Year],T4.[Special Registries], T4.[Package Name], T4.[Package Price],  
T4.[Included Crim Searches], ISNULL(AVG(CASE WHEN T2.CrimCount <> 0 THEN CONVERT(DECIMAL(16,2),T2.CrimCount) else null end),0) as [Avg Criminal Searches]  
from #temp4 T4  
left join #temp2 T2 on T4.CLNO = T2.CLNO and T4.PackageID = T2.PackageID  
group by T4.CLNO, T4.PackageID,T4.ClientName,T4.Affiliate, T4.[OasisCriminalRequirement-NumberOfCounty],T4.[Number of Year],T4.[Special Registries],T4.[Package Name], T4.[Package Price],  
T4.[Included Crim Searches]  
  
  
drop table #temp1  
drop table #temp2  
drop table #temp4  
END  