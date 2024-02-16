






CREATE PROCEDURE [dbo].[ReportApplClientAverageTurnaroundReportDetail_Module]
(
 @CLNO INT,
 @from_date datetime,
 @to_date datetime,
@Module varchar(50)=''
)
 AS
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
if (@Module='Education') Begin

	SELECT a.apno AS 'Application Number',
	(select ( (CASE  
	WHEN isnull(educat.last_updated,'1/1/1900') >= isnull(educat.last_worked,'1/1/1900') AND isnull(educat.last_updated,'1/1/1900') >= isnull(educat.Web_Updated,'1/1/1900') THEN dbo.elapsedbusinessdays_2( educat.CreatedDate,educat.last_updated)  
	WHEN isnull(educat.last_worked,'1/1/1900') >= isnull(educat.last_updated,'1/1/1900') AND isnull(educat.last_worked,'1/1/1900') >= isnull(educat.Web_Updated,'1/1/1900') THEN dbo.elapsedbusinessdays_2( educat.CreatedDate,educat.last_worked) 
	WHEN isnull(educat.Web_Updated,'1/1/1900') >= isnull(educat.last_worked,'1/1/1900') AND isnull(educat.Web_Updated,'1/1/1900') >= isnull(educat.last_updated,'1/1/1900') THEN dbo.elapsedbusinessdays_2( educat.CreatedDate,educat.Web_Updated)
end) )
	from appl with (NOLOCK) where 
(CASE  
	WHEN isnull(educat.last_updated,'1/1/1900') >= isnull(educat.last_worked,'1/1/1900') AND isnull(educat.last_updated,'1/1/1900') >= isnull(educat.Web_Updated,'1/1/1900') THEN educat.last_updated  
	WHEN isnull(educat.last_worked,'1/1/1900') >= isnull(educat.last_updated,'1/1/1900') AND isnull(educat.last_worked,'1/1/1900') >= isnull(educat.Web_Updated,'1/1/1900') THEN educat.last_worked 
	WHEN isnull(educat.Web_Updated,'1/1/1900') >= isnull(educat.last_worked,'1/1/1900') AND isnull(educat.Web_Updated,'1/1/1900') >= isnull(educat.last_updated,'1/1/1900') THEN educat.Web_Updated 
END)   >= @from_date AND 
(CASE  
	WHEN isnull(educat.last_updated,'1/1/1900') >= isnull(educat.last_worked,'1/1/1900') AND isnull(educat.last_updated,'1/1/1900') >= isnull(educat.Web_Updated,'1/1/1900') THEN educat.last_updated  
	WHEN isnull(educat.last_worked,'1/1/1900') >= isnull(educat.last_updated,'1/1/1900') AND isnull(educat.last_worked,'1/1/1900') >= isnull(educat.Web_Updated,'1/1/1900') THEN educat.last_worked 
	WHEN isnull(educat.Web_Updated,'1/1/1900') >= isnull(educat.last_worked,'1/1/1900') AND isnull(educat.Web_Updated,'1/1/1900') >= isnull(educat.last_updated,'1/1/1900') THEN educat.Web_Updated 
END)   < @to_date AND 
CLNO = @CLNO  AND APNO = A.APNO 
group by educat.CreatedDate, educat.Last_Updated,educat.last_worked,educat.Web_Updated) as 'Turnaround Time' , School, (case when (educat.state ='') then '-'else educat.state end) as State
from appl  a with (NOLOCK)
join educat with (NOLOCK) on a.apno = educat.apno
where  
(CASE  
	WHEN isnull(educat.last_updated,'1/1/1900') >= isnull(educat.last_worked,'1/1/1900') AND isnull(educat.last_updated,'1/1/1900') >= isnull(educat.Web_Updated,'1/1/1900') THEN educat.last_updated  
	WHEN isnull(educat.last_worked,'1/1/1900') >= isnull(educat.last_updated,'1/1/1900') AND isnull(educat.last_worked,'1/1/1900') >= isnull(educat.Web_Updated,'1/1/1900') THEN educat.last_worked 
	WHEN isnull(educat.Web_Updated,'1/1/1900') >= isnull(educat.last_worked,'1/1/1900') AND isnull(educat.Web_Updated,'1/1/1900') >= isnull(educat.last_updated,'1/1/1900') THEN educat.Web_Updated 
END)   >= @from_date and  
(CASE  
	WHEN isnull(educat.last_updated,'1/1/1900') >= isnull(educat.last_worked,'1/1/1900') AND isnull(educat.last_updated,'1/1/1900') >= isnull(educat.Web_Updated,'1/1/1900') THEN educat.last_updated  
	WHEN isnull(educat.last_worked,'1/1/1900') >= isnull(educat.last_updated,'1/1/1900') AND isnull(educat.last_worked,'1/1/1900') >= isnull(educat.Web_Updated,'1/1/1900') THEN educat.last_worked 
	WHEN isnull(educat.Web_Updated,'1/1/1900') >= isnull(educat.last_worked,'1/1/1900') AND isnull(educat.Web_Updated,'1/1/1900') >= isnull(educat.last_updated,'1/1/1900') THEN educat.Web_Updated 
END)  < @to_date AND apstatus in ('W','F')
AND CLNO = @CLNO 
AND isonreport = 1 and ishidden = 0
group by a.apno ,educat.state,educat.School,educat.createddate, educat.Last_Updated ,educat.last_worked,educat.Web_Updated
ORDER BY a.apno
end 

if (@Module='Education_new') Begin

SELECT a.apno AS 'Application Number',
(select  dbo.elapsedbusinessdays_2( educat.CreatedDate,educat.Web_Updated)
from appl with (NOLOCK) where 
educat.Web_Updated >= @from_date AND educat.Web_Updated < @to_date  AND 
CLNO = @CLNO  AND APNO = A.APNO 
group by educat.CreatedDate, educat.Last_Updated,educat.last_worked,educat.Web_Updated) as 'Turnaround Time' , School, (case when (educat.state ='') then '-'else educat.state end) as State
from appl  a with (NOLOCK)
join educat with (NOLOCK) on a.apno = educat.apno
where  
educat.Web_Updated >= @from_date AND educat.Web_Updated < @to_date AND apstatus in ('W','F')
AND CLNO = @CLNO 
AND isonreport = 1 and ishidden = 0
group by a.apno ,educat.state,educat.School,educat.createddate, educat.Last_Updated ,educat.last_worked,educat.Web_Updated
ORDER BY a.apno
END
 
	if(@Module='Employment') begin

		SELECT a.apno AS 'Application Number',
		(select ( dbo.elapsedbusinessdays_2( empl.CreatedDate, empl.Last_worked ) )
		from appl with (NOLOCK) where empl.Last_worked >= @from_date AND empl.Last_worked < @to_date AND 
		CLNO = @CLNO  AND APNO = A.APNO 
		group by empl.CreatedDate, empl.Last_worked) as 'Turnaround Time',empl.employer, (case when (empl.state='') then '-'else empl.state end) as State
		from appl  a with (NOLOCK)
		join empl with (NOLOCK) on a.apno = empl.apno
		where  empl.Last_worked >= @from_date and  empl.Last_worked < @to_date AND apstatus in ('W','F') AND CLNO = @CLNO 
		AND isonreport = 1 and ishidden = 0
		group by a.apno ,empl.state,empl.employer,empl.createddate, empl.Last_worked 
		ORDER BY a.apno
end 
 
if (@Module='Licenses')  begin

		SELECT a.apno AS 'Application Number',
		(select ( dbo.elapsedbusinessdays_2( proflic.CreatedDate, proflic.Last_updated) )
		from appl with (NOLOCK) where proflic.Last_updated >= @from_date AND proflic.Last_updated < @to_date AND 
		CLNO = @CLNO  AND APNO = A.APNO 
		group by proflic.CreatedDate, proflic.Last_updated) as 'Turnaround Time' ,proflic.lic_type as 'Name',(case when (proflic.state='') then '-' else proflic.state end) as State  
		from appl a with (NOLOCK) 
		join proflic with (NOLOCK) on a.apno = proflic.apno
		where  proflic.Last_updated >= @from_date and  proflic.Last_updated < @to_date AND apstatus in ('W','F') AND CLNO = @CLNO 
		AND isonreport = 1 and ishidden = 0
		group by a.apno,proflic.state,proflic.lic_type ,proflic.createddate, proflic.Last_updated
		ORDER BY a.apno

end 

	if(@Module='Criminal')  begin

		SELECT a.apno AS 'Application Number',
		(select ( dbo.elapsedbusinessdays_2( Crim.Crimenteredtime, Crim.Last_Updated ) )
		from appl with (NOLOCK) where crim.Last_Updated >= @from_date AND crim.Last_Updated < @to_date AND 
		CLNO = @CLNO  AND APNO = A.APNO 
		group by Crim.Crimenteredtime, crim.Last_Updated) as 'Turnaround Time',County
		from appl a with (NOLOCK) 
		join crim on a.apno = crim.apno
		where  crim.Last_Updated >= @from_date and  crim.Last_Updated < @to_date AND apstatus in ('W','F') AND CLNO = @CLNO 
		group by a.apno ,Crim.Crimenteredtime, crim.Last_Updated,crim.county 
		ORDER BY a.apno

end 

--From here veena 07/07/2008
if(@Module='PersonalReference')  begin


	SELECT a.apno AS 'Application Number',
	(select ( (CASE  
	WHEN isnull(PersRef.last_updated,'1/1/1900') >= isnull(PersRef.last_worked,'1/1/1900') AND isnull(PersRef.last_updated,'1/1/1900') >= isnull(PersRef.Web_Updated,'1/1/1900') THEN dbo.elapsedbusinessdays_2( PersRef.CreatedDate,PersRef.last_updated)  
	WHEN isnull(PersRef.last_worked,'1/1/1900') >= isnull(PersRef.last_updated,'1/1/1900') AND isnull(PersRef.last_worked,'1/1/1900') >= isnull(PersRef.Web_Updated,'1/1/1900') THEN dbo.elapsedbusinessdays_2( PersRef.CreatedDate,PersRef.last_worked) 
	WHEN isnull(PersRef.Web_Updated,'1/1/1900') >= isnull(PersRef.last_worked,'1/1/1900') AND isnull(PersRef.Web_Updated,'1/1/1900') >= isnull(PersRef.last_updated,'1/1/1900') THEN dbo.elapsedbusinessdays_2( PersRef.CreatedDate,PersRef.Web_Updated)
end) )
	from appl with (NOLOCK) where 
(CASE  
	WHEN isnull(PersRef.last_updated,'1/1/1900') >= isnull(PersRef.last_worked,'1/1/1900') AND isnull(PersRef.last_updated,'1/1/1900') >= isnull(PersRef.Web_Updated,'1/1/1900') THEN PersRef.last_updated  
	WHEN isnull(PersRef.last_worked,'1/1/1900') >= isnull(PersRef.last_updated,'1/1/1900') AND isnull(PersRef.last_worked,'1/1/1900') >= isnull(PersRef.Web_Updated,'1/1/1900') THEN PersRef.last_worked 
	WHEN isnull(PersRef.Web_Updated,'1/1/1900') >= isnull(PersRef.last_worked,'1/1/1900') AND isnull(PersRef.Web_Updated,'1/1/1900') >= isnull(PersRef.last_updated,'1/1/1900') THEN PersRef.Web_Updated 
END)   >= @from_date AND 
(CASE  
	WHEN isnull(PersRef.last_updated,'1/1/1900') >= isnull(PersRef.last_worked,'1/1/1900') AND isnull(PersRef.last_updated,'1/1/1900') >= isnull(PersRef.Web_Updated,'1/1/1900') THEN PersRef.last_updated  
	WHEN isnull(PersRef.last_worked,'1/1/1900') >= isnull(PersRef.last_updated,'1/1/1900') AND isnull(PersRef.last_worked,'1/1/1900') >= isnull(PersRef.Web_Updated,'1/1/1900') THEN PersRef.last_worked 
	WHEN isnull(PersRef.Web_Updated,'1/1/1900') >= isnull(PersRef.last_worked,'1/1/1900') AND isnull(PersRef.Web_Updated,'1/1/1900') >= isnull(PersRef.last_updated,'1/1/1900') THEN PersRef.Web_Updated 
END)   < @to_date AND 
CLNO = @CLNO  AND APNO = A.APNO 
group by PersRef.CreatedDate, PersRef.Last_Updated,PersRef.last_worked,PersRef.Web_Updated) as 'Turnaround Time' ,persref.[name] as 'Reference Name' 
from appl  a with (NOLOCK)
join PersRef with (NOLOCK) on a.apno = PersRef.apno
where  
(CASE  
	WHEN isnull(PersRef.last_updated,'1/1/1900') >= isnull(PersRef.last_worked,'1/1/1900') AND isnull(PersRef.last_updated,'1/1/1900') >= isnull(PersRef.Web_Updated,'1/1/1900') THEN PersRef.last_updated  
	WHEN isnull(PersRef.last_worked,'1/1/1900') >= isnull(PersRef.last_updated,'1/1/1900') AND isnull(PersRef.last_worked,'1/1/1900') >= isnull(PersRef.Web_Updated,'1/1/1900') THEN PersRef.last_worked 
	WHEN isnull(PersRef.Web_Updated,'1/1/1900') >= isnull(PersRef.last_worked,'1/1/1900') AND isnull(PersRef.Web_Updated,'1/1/1900') >= isnull(PersRef.last_updated,'1/1/1900') THEN PersRef.Web_Updated 
END)   >= @from_date and  
(CASE  
	WHEN isnull(PersRef.last_updated,'1/1/1900') >= isnull(PersRef.last_worked,'1/1/1900') AND isnull(PersRef.last_updated,'1/1/1900') >= isnull(PersRef.Web_Updated,'1/1/1900') THEN PersRef.last_updated  
	WHEN isnull(PersRef.last_worked,'1/1/1900') >= isnull(PersRef.last_updated,'1/1/1900') AND isnull(PersRef.last_worked,'1/1/1900') >= isnull(PersRef.Web_Updated,'1/1/1900') THEN PersRef.last_worked 
	WHEN isnull(PersRef.Web_Updated,'1/1/1900') >= isnull(PersRef.last_worked,'1/1/1900') AND isnull(PersRef.Web_Updated,'1/1/1900') >= isnull(PersRef.last_updated,'1/1/1900') THEN PersRef.Web_Updated 
END)  < @to_date AND apstatus in ('W','F')
AND CLNO = @CLNO 
AND isonreport = 1 and ishidden = 0
group by a.apno,Persref.Name, PersRef.createddate, PersRef.Last_Updated ,PersRef.last_worked,PersRef.Web_Updated
ORDER BY a.apno

end 
--Till here veena 07/07/2008


SET TRANSACTION ISOLATION LEVEL READ COMMITTED














