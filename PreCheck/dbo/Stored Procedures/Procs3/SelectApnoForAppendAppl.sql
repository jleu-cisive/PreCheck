

/*
Created: 02-16-06 by JC
Select apno for appending Appl.SpecialInstructions use. 
in where clause date > '02-27-06' is to handle the ones after starting the new feature. 
As for the ones before changes Frank had added manually 
*/

create procedure dbo.SelectApnoForAppendAppl

as

select a.apno,AppendedToAppl from adverseactionhistory h  
    inner join adverseaction a  on h.adverseactionid=a.adverseactionid
where h.AdverseActionHistoryID in (select min(AdverseActionHistoryID) from AdverseActionHistory h 
					inner join AdverseAction a on h.AdverseActionID=a.AdverseActionID
				    where h.StatusID=5 
				      and AppendedToAppl=0
				 group by h.AdverseActionID)
  --and date >= '02-27-06'
order by a.apno --h.adverseactionid

