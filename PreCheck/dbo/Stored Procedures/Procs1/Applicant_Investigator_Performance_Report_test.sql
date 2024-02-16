  
-- exec [Applicant_Investigator_Performance_Report] '5/16/2012', '5/16/2012'  
  
CREATE Procedure [dbo].[Applicant_Investigator_Performance_Report_test]  
(  
@StartDate DateTime = '5/16/2012',   
@EndDate DateTime = '5/7/2012'  
  
)   
 as   
  
SELECT    Apno,  username  into #tempChangeLog  
FROM         dbo.ApplGetNextLog  
WHERE     (CreatedDate> CONVERT(DATETIME, @StartDate, 102)) and CreatedDate< = dateadd(s,-1,dateadd(d,1,@EndDate))  
		  and Apno>0 --added by Mainak for ticket no.13307
group by  Apno,  username --added by Mainak for ticket no.13307
  
  
  
SELECT   Userid  into #tempChangeLog2  
FROM         dbo.ChangeLog (Nolock)  
WHERE     
(ChangeDate > CONVERT(DATETIME, @StartDate, 102)) and ChangeDate< = dateadd(s,-1,dateadd(d,1,@EndDate))  
and  NewValue = 'F' and OldValue = 'P'  --ID >0   
and TableName like 'Appl.ApStatus'  
order by ID,UserID  
  
insert Into  #tempChangeLog2  
Select Investigator as UserID  
from APPL (Nolock)  
where Investigator = 'DSOnly'   
AND (last_updated > CONVERT(DATETIME, @StartDate, 102))   
and last_updated< = dateadd(s,-1,dateadd(d,1,@EndDate))  
  
  
  
SELECT   Newvalue  into #tempChangeLog3  
FROM         dbo.ChangeLog (Nolock)  
WHERE     
(ChangeDate > CONVERT(DATETIME, @StartDate, 102)) and ChangeDate< = dateadd(s,-1,dateadd(d,1,@EndDate))  
  
and TableName like 'Appl.Investigator' and OldValue = ''   
order by ID,UserID  
  
  
  
Select distinct Investigator as USerID  
into #tmp1  
from APPL (Nolock)  
where isnull(Investigator,'') <> '' and   
 (Last_Updated>= @StartDate and Last_Updated< = dateadd(s,-1,dateadd(d,1,@EndDate)))  
order by Investigator asc  
  
  
insert Into  #tmp1  
Select distinct EnteredBy as UserID  
from APPL (Nolock)  
where isnull(EnteredBy,'') <> '' and   
  
 (ApDate>= @StartDate and ApDate< = dateadd(s,-1,dateadd(d,1,@EndDate)))  
and (isnull(EnteredVia,'') = '' or ISNULL(Enteredvia,'') = 'DEMI')  
order by EnteredBy asc  
  
insert Into  #tmp1  
Select distinct USerID  
from #tempChangeLog2  
  
--insert Into  #tmp1  
--Select distinct USerID  
--from #tempChangeLog3  
  
  
Select  distinct T.UserID,   
(SELECT Count(Appl.EnteredBy) FROM Appl with (NOLOCK)  
WHERE ApDate >= @StartDate AND ApDate < DateAdd(d,1,@EndDate) AND Enteredby = T.UserID AND (ISNULL(Enteredvia,'') = '' or ISNULL(Enteredvia,'') = 'DEMI') ) As EnteredBy,  
(SELECT Count(Appl.EnteredBy) FROM Appl with (NOLOCK)  
WHERE ApDate >= @StartDate AND ApDate < DateAdd(d,1,@EndDate) AND Enteredby = T.UserID AND ( ISNULL(Enteredvia,'') = 'DEMI') ) As DEMI,  
(Select count(1) From #tempChangeLog B where  T.UserID = B.username) as  'Reviewed(Get Next)',  
(Select count(1) From #tempChangeLog3 A where  T.UserID = A.Newvalue) as  'Reviewed (Not Get Next)',  
((Select count(1) From #tempChangeLog c where  T.UserID = C.username) + (Select count(1) From #tempChangeLog3 E where  T.UserID = E.Newvalue) ) as 'Total Reviewed',   
(Select count(1) From #tempChangeLog2 D where  T.UserID = D.UserID) as  Finaled  
from #tmp1 T  
  
Group By T.UserID  
order by T.UserID  
  
  
Drop Table #tempChangeLog  
Drop Table #tempChangeLog2  
Drop Table #tmp1  
Drop Table #tempChangeLog3  

  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  