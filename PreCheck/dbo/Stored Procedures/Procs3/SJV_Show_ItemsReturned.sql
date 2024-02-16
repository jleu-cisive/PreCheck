--Show Final notes and status for date range
--dbo.SJV_Show_ItemsReturned '12/01/2019','12/03/2019'
CREATE PROCEDURE dbo.SJV_Show_ItemsReturned
(@date1 datetime,@date2 datetime)
as
 --set @date1='08/12/2019'
 --SET @date2 ='08/12/2019'
 BEGIN

select @date2 = Convert(datetime, Convert(date, @date2))+1

drop table if exists #tmpChangeLog



SELECT DISTINCT
	ROW_NUMBER() OVER (Partition BY e.EmplId Order By ClStat.ChangeDate asc, clFinal.ChangeDate asc) as RowNumber,
	clStat.NewValue, 
	e.APNO as ReportNumber,
	e.EmplId as EmplId,
	e.Employer as Employer,
	c.AffiliateID,		
	--e.web_status,
	clStat.NewValue web_status,
	e.SectStat,
	case when clStat.NewValue in ('54','74') then clFinal.NewValue else null end as FinalNotes,
	e.web_updated as DateReturned
	--FORMAT(clFinal.ChangeDate,'MM/dd/yyyy hh:mm tt') as DateReturned
INTO 
	#tmpChangeLog		
FROM  
	dbo.Empl e 	
	inner join dbo.ChangeLog clStat on e.EmplId = clStat.ID and clStat.userid='sjv' and clStat.NewValue in ('74','54','57','5','78','87') and clStat.TableName='Empl.web_status'
	inner join dbo.ChangeLog clFinal on  e.EmplId = clFinal.ID  and convert(date,clFinal.ChangeDate)=convert(date,clStat.ChangeDate) and clFinal.TableName in ('Empl.Priv_Notes','Empl.pub_notes')
	inner join dbo.Appl a on a.APNO = e.APNO
	inner join dbo.Client c on c.CLNO = a.CLNO
	
	--inner join dbo.GetNextAudit gna on e.EmplID = gna.EmplId and e.APNO = gna.APNO
	--inner join dbo.ClientConfiguration cc on c.CLNO = cc.CLNO	
 WHERE 
	e.web_updated > @date1 and e.web_updated < @date2  
	and  e.Investigator = 'SJV'
	and clStat.userid='SJV'  
	/*
	and e.IsOnReport=1 
	and e.SectStat='9'
	--
		
	and clStat.NewValue in ('74','54','57','5','78','87')) 
	and clStat.TableName='Empl.web_status'
	and clFinal.UserID = 'sjv'	
 --gna.NewValue = 'SJV'
 */

 option (recompile)
--select * FRom 	#tmpChangeLog-- where EmplId = 6329914

--select * from dbo.Empl  where OrderId = '77322691'	   
	--(cl.NewValue in ('74','54','57','5','78','87') and cl.TableName='Empl.web_status') and 
	--e.OrderId is not null-- and 
	--a.CLNO not in (select clno from ClientOutOfBusiness)  
	
	--ChangeDate between @date1 and @date2
 /*
 select * from #tmpChangeLog 
 --where EmplId = 6303057 
 where rownumber=1
 order by  rownumber, EmplId
 */
 
 SELECT 
	ReportNumber,
	Employer,
	ra.Affiliate,
	--ClientNumber,
	--ClientName,	
	ws.[description] as [Status at time of final note],
	--sc.Description as [Section status],
	FinalNotes,
	DateReturned
from 
	#tmpChangeLog cl inner join dbo.Websectstat ws on ws.code = cl.web_status
	inner join dbo.SectStat sc on sc.Code = cl.SectStat
	inner join dbo.refAffiliate ra on ra.AffiliateID = cl.AffiliateID
where 
	RowNumber = 1 	
	ORDER BY ReportNumber,Employer

 drop table #tmpChangeLog
/*
 --select * from dbo.Empl where apno = 4749941
 --select * from GetNextAudit where Emplid in (select Emplid from dbo.empl where orderid = '77322691')
 --and NewValue='SJV'

 --select * from dbo.ChangeLog where ID= 6328805 and TableName = 'Empl.Web_status' and NewValue='5' and UserID = 'SJV'
 --select top 100 * from dbo.GetNextAudit where Emplid = 6328805
 --select * from dbo.ChangeLog where ID = 6328805 order by changedate desc
 
  --select top 100 * from dbo.GetNextAudit where NewValue = 'sjv' and CreatedBy = 'AssignInvestigatorsToUnAssignedPendingData' order by 1 desc
 --select 
	--web_status,* from dbo.Empl e where Apno = 4728164 and e.Employer = 'Advent Health Tampa'
 --select * from dbo.ChangeLog where ID = 6328805 order by changedate desc
 --select * from WebSectStat where code in (74,54,57,5,78,87)

 --select * from dbo.ClientConfiguration where ConfigurationKey = 'AUTOCLOSE' and CLNO = 10056
 
 --select * from dbo.Empl where Investigator='sjv' and IsOnReport=1 and SectStat='9'
 --and web_updated > '08/19/2019 00:00:00.000' and web_updated < '08/20/2019 13:02:00.000'
 */
 END