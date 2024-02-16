


CREATE PROCEDURE [dbo].[ReportClientByCAM] 
@StartDate datetime=null,
@EndDate datetime=null
AS


if @StartDate != '' and @EndDate != ''
 begin

/*
     SELECT a.CLNO, c.Name, c.State, c.CAM as Team, 'Active' as ActiveStatus,Count(*) Count
	     ,convert (varchar(6),round(cast (count(*)as float(2))/(SELECT Count(*) FROM APPL WHERE APdate >= @StartDate and apdate < @EndDate),3)) '  %'
       FROM APPL a 
	    JOIN Client c ON c.clno=a.clno
            
      WHERE APdate >= @StartDate and apdate < @EndDate
        and IsInactive = 0
      GROUP BY a.clno,Name,c.State,c.CAM
      union
     SELECT a.CLNO, c.Name,c.State,c.CAM as Team, 'InActive' as ActiveStatus,Count(*) Count
	   ,convert (varchar(6),round(cast (count(*)as float(2))/(SELECT Count(*) FROM APPL WHERE APdate >= @StartDate and apdate < @EndDate),3)) '  %'
       FROM APPL a 
	    JOIN Client c ON c.clno=a.clno
           
      WHERE APdate >= @StartDate and apdate < @EndDate
        and IsInactive = 1
   GROUP BY a.clno, Name,c.State,c.CAM

   --=====hz added on 7/12/06
	union
	SELECT  CLNO, Name, State, CAM as Team, 'Active' as ActiveStatus, 0 as Count, 0.000 as '  %'   
	FROM  Client      
	WHERE clno not in (select a.clno from appl a join client c on a.clno=c.clno where APdate >= @StartDate and apdate < @EndDate) 
		and IsInactive = 0 
	
  --=====end here.

   ORDER BY count(*) DESC

*/
--==========hz changed on 7/14/06
Select CLNO,max(Name) as Name,max(State) as State,max(Team) as Team,sum(cnt) as Count,sum(Perc) '   %',max(LastApplRcv) ActiveStatus ,max(ActiveStatus) LastApplRcv  from
(
Select C.CLNO,'' NAME,'' State,'' as Team ,Count(1) cnt
,convert (varchar(6),round(cast (count(1)as float(2))/(SELECT Count(1) FROM APPL  with (nolock) WHERE APdate >= @StartDate and apdate < @EndDate),3)) Perc,
'' ActiveStatus,null LastApplRcv
 FROM CLIENT C with (nolock) LEFT JOIN APPL A  with (nolock) ON C.CLNO= a.CLNO 
Where   ApDate Between @StartDate and @EndDate
Group By C.clno
union
SELECT C.CLNO,C.NAME,MAX(c.State) State,MAX(c.CAM) as Team ,
0 Cnt,0.000 as Perc,
max(a.APdate) as LastApplRcv,
(CASE WHEN max(cast(IsInActive as int)) = 0 Then 'Active' else 'InActive' End) ActiveStatus
FROM CLIENT C  with (nolock) LEFT JOIN APPL A  with (nolock) ON C.CLNO= a.CLNO 
GROUP BY C.CLNO,C.NAME
) SubQuery
group by clno
order by count desc


  end


--for passed parameters without dates
