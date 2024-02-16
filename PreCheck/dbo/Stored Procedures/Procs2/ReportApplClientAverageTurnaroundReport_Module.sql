



CREATE PROCEDURE [dbo].[ReportApplClientAverageTurnaroundReport_Module]
(
		 @CLNO INT=0,
		 @from_date datetime='',
		 @to_date datetime='',
		 @section varchar(50)=''
) 
AS

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

if ( @section = 'Employment')
BEGIN
 
SELECT '0 Day' AS 'Turnaround Time',( SELECT count(*) FROM empl with (NOLOCK)
JOIN appl with (NOLOCK) on appl.apno = empl.apno
WHERE empl.last_worked >= @from_date AND empl.last_worked < @to_date AND CLNO = @CLNO AND apstatus in ('W','F')
AND  dbo.elapsedbusinessdays_2( empl.CreatedDate, empl.last_worked ) = 0
--group by clno
) as 'Count',
CAST( 100. * (SELECT count(*) FROM empl with (NOLOCK)
	JOIN appl with (NOLOCK) on appl.apno = empl.apno
	WHERE empl.last_worked >= @from_date AND empl.last_worked < @to_date AND CLNO = @CLNO AND apstatus in ('W','F')
	AND  dbo.elapsedbusinessdays_2( empl.CreatedDate, empl.last_worked ) = 0 
--group by clno
	)  /
  (select count(emplid) from empl with (NOLOCK) JOIN appl with (NOLOCK) on appl.apno = empl.apno 
   where empl.last_worked >= @from_date AND empl.last_worked < @to_date AND CLNO = @CLNO AND apstatus in ('W','F')
  )AS NUMERIC( 5, 2 ) ) AS 'Percentage',
CAST( 100. * (SELECT count(*) FROM empl with (NOLOCK)
	JOIN appl with (NOLOCK) on appl.apno = empl.apno
	WHERE empl.last_worked >= @from_date AND empl.last_worked < @to_date AND CLNO = @CLNO AND apstatus in ('W','F')
	AND  dbo.elapsedbusinessdays_2( empl.CreatedDate, empl.last_worked   ) = 0
 --group by clno
	) / 
  (select count(emplid) from empl with (NOLOCK) JOIN appl with (NOLOCK) on appl.apno = empl.apno 
   where empl.last_worked >= @from_date AND empl.last_worked < @to_date AND CLNO = @CLNO AND apstatus in ('W','F')
  )AS NUMERIC( 5, 2 ) ) as 'Cumulative %'

FROM empl with (NOLOCK) JOIN appl with (NOLOCK) on appl.apno = empl.apno
WHERE  empl.last_worked >= @from_date AND empl.last_worked < @to_date AND  CLNO = @CLNO AND apstatus in ('W','F') 
--AND  dbo.elapsedbusinessdays_2( empl.CreatedDate, empl.last_worked   ) = 0
--group by clno

UNION

SELECT '1 Day' AS 'Turnaround Time',( SELECT count(*) FROM empl with (NOLOCK)
JOIN appl with (NOLOCK) on appl.apno = empl.apno
WHERE empl.last_worked >= @from_date AND empl.last_worked < @to_date AND CLNO = @CLNO AND apstatus in ('W','F')
AND  dbo.elapsedbusinessdays_2( empl.CreatedDate, empl.last_worked ) = 1
--group by clno
) as 'Count',

CAST( 100. * (SELECT count(*) FROM empl with (NOLOCK)
	JOIN appl with (NOLOCK) on appl.apno = empl.apno
	WHERE empl.last_worked >= @from_date AND empl.last_worked < @to_date AND CLNO = @CLNO AND apstatus in ('W','F')
	AND  dbo.elapsedbusinessdays_2( empl.CreatedDate, empl.last_worked ) = 1
-- group by clno
	)  /
  (select count(emplid) from empl with (NOLOCK) JOIN appl with (NOLOCK) on appl.apno = empl.apno 
   where empl.last_worked >= @from_date AND empl.last_worked < @to_date AND CLNO = @CLNO AND apstatus in ('W','F')
  )AS NUMERIC( 5, 2 ) ) AS 'Percentage',

CAST( 100. * (SELECT count(*) FROM empl with (NOLOCK)
	JOIN appl with (NOLOCK) on appl.apno = empl.apno
	WHERE empl.last_worked >= @from_date AND empl.last_worked < @to_date AND CLNO = @CLNO AND apstatus in ('W','F')
	AND  dbo.elapsedbusinessdays_2( empl.CreatedDate, empl.last_worked   ) <=1 
--group by clno
	) / 
  (select count(emplid) from empl with (NOLOCK) JOIN appl with (NOLOCK) on appl.apno = empl.apno 
   where empl.last_worked >= @from_date AND empl.last_worked < @to_date AND CLNO = @CLNO AND apstatus in ('W','F')
  )AS NUMERIC( 5, 2 ) ) as 'Cumulative %'

FROM empl with (NOLOCK) JOIN appl with (NOLOCK) on appl.apno = empl.apno
WHERE  empl.last_worked >= @from_date AND empl.last_worked < @to_date AND  CLNO = @CLNO AND apstatus in ('W','F') 
--group by clno

UNION

SELECT '2 Day' AS 'Turnaround Time',( SELECT count(*) FROM empl with (NOLOCK)
JOIN appl with (NOLOCK) on appl.apno = empl.apno
WHERE empl.last_worked >= @from_date AND empl.last_worked < @to_date AND CLNO = @CLNO AND apstatus in ('W','F')
AND  dbo.elapsedbusinessdays_2( empl.CreatedDate, empl.last_worked ) = 2
--group by clno
) as 'Count',

CAST( 100. * (SELECT count(*) FROM empl with (NOLOCK)
	JOIN appl with (NOLOCK) on appl.apno = empl.apno
	WHERE empl.last_worked >= @from_date AND empl.last_worked < @to_date AND CLNO = @CLNO AND apstatus in ('W','F')
	AND  dbo.elapsedbusinessdays_2( empl.CreatedDate, empl.last_worked ) = 2 
--group by clno
	)  /
  (select count(emplid) from empl with (NOLOCK) JOIN appl with (NOLOCK) on appl.apno = empl.apno 
   where empl.last_worked >= @from_date AND empl.last_worked < @to_date AND CLNO = @CLNO AND apstatus in ('W','F')
  )AS NUMERIC( 5, 2 ) ) AS 'Percentage',

CAST( 100. * (SELECT count(*) FROM empl with (NOLOCK)
	JOIN appl with (NOLOCK) on appl.apno = empl.apno
	WHERE empl.last_worked >= @from_date AND empl.last_worked < @to_date AND CLNO = @CLNO AND apstatus in ('W','F')
	AND  dbo.elapsedbusinessdays_2( empl.CreatedDate, empl.last_worked   ) <=2
-- group by clno
	) / 
  (select count(emplid) from empl with (NOLOCK) JOIN appl  with (NOLOCK) on appl.apno = empl.apno 
   where empl.last_worked >= @from_date AND empl.last_worked < @to_date AND CLNO = @CLNO AND apstatus in ('W','F')
  )AS NUMERIC( 5, 2 ) ) as 'Cumulative %'

FROM empl with (NOLOCK) JOIN appl  with (NOLOCK) on appl.apno = empl.apno
WHERE  empl.last_worked >= @from_date AND empl.last_worked < @to_date AND  CLNO = @CLNO AND apstatus in ('W','F') 
--group by clno

UNION

SELECT '3 Day' AS 'Turnaround Time',( SELECT count(*) FROM empl with (NOLOCK)
JOIN appl with (NOLOCK) on appl.apno = empl.apno
WHERE empl.last_worked >= @from_date AND empl.last_worked < @to_date AND CLNO = @CLNO AND apstatus in ('W','F')
AND  dbo.elapsedbusinessdays_2( empl.CreatedDate, empl.last_worked ) = 3
--group by clno
) as 'Count',

CAST( 100. * (SELECT count(*) FROM empl with (NOLOCK)
	JOIN appl with (NOLOCK) on appl.apno = empl.apno
	WHERE empl.last_worked >= @from_date AND empl.last_worked < @to_date AND CLNO = @CLNO AND apstatus in ('W','F')
	AND  dbo.elapsedbusinessdays_2( empl.CreatedDate, empl.last_worked ) = 3 
--group by clno
	)  /
  (select count(emplid) from empl with (NOLOCK) JOIN appl with (NOLOCK) on appl.apno = empl.apno 
   where empl.last_worked >= @from_date AND empl.last_worked < @to_date AND CLNO = @CLNO AND apstatus in ('W','F')
  )AS NUMERIC( 5, 2 ) ) AS 'Percentage',

CAST( 100. * (SELECT count(*) FROM empl with (NOLOCK)
	JOIN appl with (NOLOCK) on appl.apno = empl.apno
	WHERE empl.last_worked >= @from_date AND empl.last_worked < @to_date AND CLNO = @CLNO AND apstatus in ('W','F')
	AND  dbo.elapsedbusinessdays_2( empl.CreatedDate, empl.last_worked   ) <=3 
--group by clno
	) / 
  (select count(emplid) from empl with (NOLOCK) JOIN appl with (NOLOCK) on appl.apno = empl.apno 
   where empl.last_worked >= @from_date AND empl.last_worked < @to_date AND CLNO = @CLNO AND apstatus in ('W','F')
  )AS NUMERIC( 5, 2 ) ) as 'Cumulative %'

FROM empl with (NOLOCK) JOIN appl  with (NOLOCK) on appl.apno = empl.apno
WHERE  empl.last_worked >= @from_date AND empl.last_worked < @to_date AND  CLNO = @CLNO AND apstatus in ('W','F') 
--group by clno


UNION

SELECT '4 Day' AS 'Turnaround Time',( SELECT count(*) FROM empl with (NOLOCK)
JOIN appl with (NOLOCK) on appl.apno = empl.apno
WHERE empl.last_worked >= @from_date AND empl.last_worked < @to_date AND CLNO = @CLNO AND apstatus in ('W','F')
AND  dbo.elapsedbusinessdays_2( empl.CreatedDate, empl.last_worked ) = 4
--group by clno
) as 'Count',

CAST( 100. * (SELECT count(*) FROM empl with (NOLOCK)
	JOIN appl with (NOLOCK) on appl.apno = empl.apno
	WHERE empl.last_worked >= @from_date AND empl.last_worked < @to_date AND CLNO = @CLNO AND apstatus in ('W','F')
	AND  dbo.elapsedbusinessdays_2( empl.CreatedDate, empl.last_worked ) = 4
-- group by clno
	)  /
  (select count(emplid) from empl with (NOLOCK) JOIN appl with (NOLOCK) on appl.apno = empl.apno 
   where empl.last_worked >= @from_date AND empl.last_worked < @to_date AND CLNO = @CLNO AND apstatus in ('W','F')
  )AS NUMERIC( 5, 2 ) ) AS 'Percentage',

CAST( 100. * (SELECT count(*) FROM empl with (NOLOCK)
	JOIN appl with (NOLOCK) on appl.apno = empl.apno
	WHERE empl.last_worked >= @from_date AND empl.last_worked < @to_date AND CLNO = @CLNO AND apstatus in ('W','F')
	AND  dbo.elapsedbusinessdays_2( empl.CreatedDate, empl.last_worked   ) <=4
-- group by clno
	) / 
  (select count(emplid) from empl with (NOLOCK) JOIN appl with (NOLOCK) on appl.apno = empl.apno 
   where empl.last_worked >= @from_date AND empl.last_worked < @to_date AND CLNO = @CLNO AND apstatus in ('W','F')
  )AS NUMERIC( 5, 2 ) ) as 'Cumulative %'

FROM empl with (NOLOCK) JOIN appl with (NOLOCK) on appl.apno = empl.apno
WHERE  empl.last_worked >= @from_date AND empl.last_worked < @to_date AND  CLNO = @CLNO AND apstatus in ('W','F') 
--group by clno

UNION

SELECT '5 Day' AS 'Turnaround Time',( SELECT count(*) FROM empl with (NOLOCK)
JOIN appl with (NOLOCK) on appl.apno = empl.apno
WHERE empl.last_worked >= @from_date AND empl.last_worked < @to_date AND CLNO = @CLNO AND apstatus in ('W','F')
AND  dbo.elapsedbusinessdays_2( empl.CreatedDate, empl.last_worked ) = 5
--group by clno
) as 'Count',

CAST( 100. * (SELECT count(*) FROM empl with (NOLOCK)
	JOIN appl with (NOLOCK) on appl.apno = empl.apno
	WHERE empl.last_worked >= @from_date AND empl.last_worked < @to_date AND CLNO = @CLNO AND apstatus in ('W','F')
	AND  dbo.elapsedbusinessdays_2( empl.CreatedDate, empl.last_worked ) = 5
-- group by clno
	)  /
  (select count(emplid) from empl with (NOLOCK) JOIN appl with (NOLOCK) on appl.apno = empl.apno 
   where empl.last_worked >= @from_date AND empl.last_worked < @to_date AND CLNO = @CLNO AND apstatus in ('W','F')
  )AS NUMERIC( 5, 2 ) ) AS 'Percentage',

CAST( 100. * (SELECT count(*) FROM empl with (NOLOCK)
	JOIN appl with (NOLOCK) on appl.apno = empl.apno
	WHERE empl.last_worked >= @from_date AND empl.last_worked < @to_date AND CLNO = @CLNO AND apstatus in ('W','F')
	AND  dbo.elapsedbusinessdays_2( empl.CreatedDate, empl.last_worked   ) <=5
-- group by clno
	) / 
  (select count(emplid) from empl with (NOLOCK) JOIN appl with (NOLOCK) on appl.apno = empl.apno 
   where empl.last_worked >= @from_date AND empl.last_worked < @to_date AND CLNO = @CLNO AND apstatus in ('W','F')
  )AS NUMERIC( 5, 2 ) ) as 'Cumulative %'

FROM empl with (NOLOCK) JOIN appl with (NOLOCK) on appl.apno = empl.apno
WHERE  empl.last_worked >= @from_date AND empl.last_worked < @to_date AND  CLNO = @CLNO AND apstatus in ('W','F') 
--group by clno

UNION

SELECT '6+ Day' AS 'Turnaround Time',( SELECT count(*) FROM empl with (NOLOCK)
JOIN appl with (NOLOCK) on appl.apno = empl.apno
WHERE empl.last_worked >= @from_date AND empl.last_worked < @to_date AND CLNO = @CLNO AND apstatus in ('W','F')
AND  dbo.elapsedbusinessdays_2( empl.CreatedDate, empl.last_worked ) >= 6
--group by clno
) as 'Count',

CAST( 100. * (SELECT count(*) FROM empl with (NOLOCK)
	JOIN appl with (NOLOCK) on appl.apno = empl.apno
	WHERE empl.last_worked >= @from_date AND empl.last_worked < @to_date AND CLNO = @CLNO AND apstatus in ('W','F')
	AND  dbo.elapsedbusinessdays_2( empl.CreatedDate, empl.last_worked ) >= 6
-- group by clno
	)  /
  (select count(emplid) from empl with (NOLOCK) JOIN appl with (NOLOCK) on appl.apno = empl.apno 
   where empl.last_worked >= @from_date AND empl.last_worked < @to_date AND CLNO = @CLNO AND apstatus in ('W','F')
  )AS NUMERIC( 5, 2 ) ) AS 'Percentage',

CAST( 100. * (SELECT count(*) FROM empl with (NOLOCK)
	JOIN appl with (NOLOCK) on appl.apno = empl.apno
	WHERE empl.last_worked >= @from_date AND empl.last_worked < @to_date AND CLNO = @CLNO AND apstatus in ('W','F')
	AND  dbo.elapsedbusinessdays_2( empl.CreatedDate, empl.last_worked   )  >=0
-- group by clno
	) / 
  (select count(emplid) from empl with (NOLOCK) JOIN appl with (NOLOCK) on appl.apno = empl.apno 
   where empl.last_worked >= @from_date AND empl.last_worked < @to_date AND CLNO = @CLNO AND apstatus in ('W','F')
  )AS NUMERIC( 5, 2 ) ) as 'Cumulative %'

FROM empl with (NOLOCK) JOIN appl with (NOLOCK) on appl.apno = empl.apno
WHERE  empl.last_worked >= @from_date AND empl.last_worked < @to_date AND  CLNO = @CLNO AND apstatus in ('W','F') 
--group by clno

UNION

SELECT 'Total',
(select COUNT( emplid ) from empl with (NOLOCK) join appl with (NOLOCK) on empl.apno = appl.apno
where empl.last_worked  >= @from_date and empl.last_worked  < @to_date and CLNO = @CLNO  AND apstatus in ('W','F')
--group by CLNO
), 100, 100
FROM empl with (NOLOCK)  JOIN appl with (NOLOCK)  on appl.apno = empl.apno
WHERE  empl.last_worked >= @from_date AND empl.last_worked < @to_date AND  CLNO = @CLNO AND apstatus in ('W','F') 
--group by clno

END -- end of empl section

IF @section = 'Education_new'
BEGIN
SELECT '0 days' AS 'Turnaround Time',( SELECT count(*) FROM educat with (NOLOCK)
JOIN appl with (NOLOCK)  on appl.apno = educat.apno
WHERE
educat.Web_Updated >= @from_date AND educat.Web_Updated < @to_date 
AND CLNO = @CLNO
AND apstatus in ('W','F')
AND dbo.elapsedbusinessdays_2( educat.CreatedDate,educat.Web_Updated) = 0
--group by clno
) as 'Count'
, CAST( 100. * (SELECT count(*) FROM educat with (NOLOCK)
	JOIN appl with (NOLOCK) on appl.apno = educat.apno
	WHERE 
educat.Web_Updated >= @from_date AND educat.Web_Updated < @to_date  AND CLNO = @CLNO AND apstatus in ('W','F')
	AND dbo.elapsedbusinessdays_2( educat.CreatedDate,educat.Web_Updated) = 0 
--group by clno
	)  /
  (select count(educatid) from educat with (NOLOCK) JOIN appl with (NOLOCK) on appl.apno = educat.apno 
   where 
educat.Web_Updated >= @from_date AND educat.Web_Updated < @to_date  AND CLNO = @CLNO AND apstatus in ('W','F')
  )AS NUMERIC( 5, 2 ) ) AS 'Percentage',

CAST( 100. * (SELECT count(*) FROM educat with (NOLOCK)
	JOIN appl with (NOLOCK) on appl.apno = educat.apno
	WHERE 
educat.Web_Updated >= @from_date AND educat.Web_Updated < @to_date  AND CLNO = @CLNO AND apstatus in ('W','F')
	AND  dbo.elapsedbusinessdays_2( educat.CreatedDate,educat.Web_Updated)  = 0
-- group by clno
	) / 
  (select count(educatid) from educat with (NOLOCK) JOIN appl with (NOLOCK) on appl.apno = educat.apno 
   where 
educat.Web_Updated >= @from_date AND educat.Web_Updated < @to_date  AND CLNO = @CLNO AND apstatus in ('W','F')
  )AS NUMERIC( 5, 2 ) ) as 'Cumulative %'
FROM educat with (NOLOCK) JOIN appl with (NOLOCK) on appl.apno = educat.apno
WHERE  
educat.Web_Updated >= @from_date AND educat.Web_Updated < @to_date  AND  CLNO = @CLNO AND apstatus in ('W','F') 
--group by clno 

UNION

SELECT '1 day' AS 'Turnaround Time',( SELECT count(*) FROM educat with (NOLOCK)
JOIN appl with (NOLOCK) on appl.apno = educat.apno
WHERE
educat.Web_Updated >= @from_date AND educat.Web_Updated < @to_date 
AND CLNO = @CLNO
AND apstatus in ('W','F')
AND dbo.elapsedbusinessdays_2( educat.CreatedDate,educat.Web_Updated) = 1
--group by clno
) as 'Count'
, CAST( 100. * (SELECT count(*) FROM educat with (NOLOCK)
	JOIN appl with (NOLOCK) on appl.apno = educat.apno
	WHERE 
educat.Web_Updated >= @from_date AND educat.Web_Updated < @to_date  AND CLNO = @CLNO AND apstatus in ('W','F')
	AND dbo.elapsedbusinessdays_2( educat.CreatedDate,educat.Web_Updated)  = 1
--group by clno 
	)  /
  (select count(educatid) from educat with (NOLOCK) JOIN appl with (NOLOCK) on appl.apno = educat.apno 
   where 
educat.Web_Updated >= @from_date AND educat.Web_Updated < @to_date  AND CLNO = @CLNO AND apstatus in ('W','F')
  )AS NUMERIC( 5, 2 ) ) AS 'Percentage',

CAST( 100. * (SELECT count(*) FROM educat with (NOLOCK)
	JOIN appl with (NOLOCK) on appl.apno = educat.apno
	WHERE 
educat.Web_Updated >= @from_date AND educat.Web_Updated < @to_date  AND CLNO = @CLNO AND apstatus in ('W','F')
	AND  dbo.elapsedbusinessdays_2( educat.CreatedDate,educat.Web_Updated)  <= 1
-- group by clno
	) / 
  (select count(educatid) from educat with (NOLOCK) JOIN appl with (NOLOCK) on appl.apno = educat.apno 
   where 
educat.Web_Updated >= @from_date AND educat.Web_Updated < @to_date  AND CLNO = @CLNO AND apstatus in ('W','F')
  )AS NUMERIC( 5, 2 ) ) as 'Cumulative %'
FROM educat with (NOLOCK) JOIN appl with (NOLOCK) on appl.apno = educat.apno
WHERE  
educat.Web_Updated >= @from_date AND educat.Web_Updated < @to_date  AND  CLNO = @CLNO AND apstatus in ('W','F') 
--group by clno 

UNION

SELECT '2 days' AS 'Turnaround Time',( SELECT count(*) FROM educat with (NOLOCK)
JOIN appl with (NOLOCK) on appl.apno = educat.apno
WHERE
educat.Web_Updated >= @from_date AND educat.Web_Updated < @to_date 
AND CLNO = @CLNO AND apstatus in ('W','F')
AND apstatus in ('W','F')
AND dbo.elapsedbusinessdays_2( educat.CreatedDate,educat.Web_Updated)  = 2
--group by clno
) as 'Count'
, CAST( 100. * (SELECT count(*) FROM educat with (NOLOCK)
	JOIN appl with (NOLOCK) on appl.apno = educat.apno
	WHERE 
educat.Web_Updated >= @from_date AND educat.Web_Updated < @to_date  AND CLNO = @CLNO AND apstatus in ('W','F')
	AND dbo.elapsedbusinessdays_2( educat.CreatedDate,educat.Web_Updated) = 2 
--group by clno
	)  /
  (select count(educatid) from educat with (NOLOCK) JOIN appl with (NOLOCK) on appl.apno = educat.apno 
   where 
educat.Web_Updated >= @from_date AND educat.Web_Updated < @to_date  AND CLNO = @CLNO AND apstatus in ('W','F')
  )AS NUMERIC( 5, 2 ) ) AS 'Percentage', 

CAST( 100. * (SELECT count(*) FROM educat with (NOLOCK)
	JOIN appl with (NOLOCK) on appl.apno = educat.apno
	WHERE 
educat.Web_Updated >= @from_date AND educat.Web_Updated < @to_date  AND CLNO = @CLNO AND apstatus in ('W','F')
	AND  dbo.elapsedbusinessdays_2( educat.CreatedDate,educat.Web_Updated)  <= 2
-- group by clno
	) / 
  (select count(educatid) from educat with (NOLOCK) JOIN appl with (NOLOCK) on appl.apno = educat.apno 
   where 
educat.Web_Updated >= @from_date AND educat.Web_Updated < @to_date  AND CLNO = @CLNO AND apstatus in ('W','F')
  )AS NUMERIC( 5, 2 ) ) as 'Cumulative %'
FROM educat with (NOLOCK) JOIN appl with (NOLOCK) on appl.apno = educat.apno
WHERE  
educat.Web_Updated >= @from_date AND educat.Web_Updated < @to_date AND  CLNO = @CLNO AND apstatus in ('W','F') 
--group by clno 

UNION
--SELECT '1 day' AS 'Turnaround Time',( SELECT count(*) FROM educat with (NOLOCK)
--JOIN appl with (NOLOCK) on appl.apno = educat.apno
--WHERE
--(CASE  
--	WHEN isnull(educat.last_updated,'1/1/1900') > isnull(educat.last_worked,'1/1/1900') AND isnull(educat.last_updated,'1/1/1900') > isnull(educat.Web_Updated,'1/1/1900') THEN educat.last_updated   
--	WHEN isnull(educat.last_worked,'1/1/1900') > isnull(educat.last_updated,'1/1/1900') AND isnull(educat.last_worked,'1/1/1900') > isnull(educat.Web_Updated,'1/1/1900') THEN educat.last_worked  
--	WHEN isnull(educat.Web_Updated,'1/1/1900') > isnull(educat.last_worked,'1/1/1900') AND isnull(educat.Web_Updated,'1/1/1900') > isnull(educat.last_updated,'1/1/1900') THEN educat.Web_Updated  
--END) >= @from_date
--AND
--(CASE  
--	WHEN isnull(educat.last_updated,'1/1/1900') > isnull(educat.last_worked,'1/1/1900') AND isnull(educat.last_updated,'1/1/1900') > isnull(educat.Web_Updated,'1/1/1900') THEN educat.last_updated  
--	WHEN isnull(educat.last_worked,'1/1/1900') > isnull(educat.last_updated,'1/1/1900') AND isnull(educat.last_worked,'1/1/1900') > isnull(educat.Web_Updated,'1/1/1900') THEN educat.last_worked 
--	WHEN isnull(educat.Web_Updated,'1/1/1900') > isnull(educat.last_worked,'1/1/1900') AND isnull(educat.Web_Updated,'1/1/1900') > isnull(educat.last_updated,'1/1/1900') THEN educat.Web_Updated 
--END)  < @to_date
--AND CLNO = @CLNO
--AND apstatus in ('W','F')
--AND dbo.elapsedbusinessdays_2( educat.CreatedDate,educat.Web_Updated)  = 1
----group by clno
--) as 'Count'
--, CAST( 100. * (SELECT count(*) FROM educat with (NOLOCK)
--	JOIN appl with (NOLOCK) on appl.apno = educat.apno
--	WHERE 
--(CASE  
--	WHEN isnull(educat.last_updated,'1/1/1900') > isnull(educat.last_worked,'1/1/1900') AND isnull(educat.last_updated,'1/1/1900') > isnull(educat.Web_Updated,'1/1/1900') THEN educat.last_updated  
--	WHEN isnull(educat.last_worked,'1/1/1900') > isnull(educat.last_updated,'1/1/1900') AND isnull(educat.last_worked,'1/1/1900') > isnull(educat.Web_Updated,'1/1/1900') THEN educat.last_worked 
--	WHEN isnull(educat.Web_Updated,'1/1/1900') > isnull(educat.last_worked,'1/1/1900') AND isnull(educat.Web_Updated,'1/1/1900') > isnull(educat.last_updated,'1/1/1900') THEN educat.Web_Updated 
--END)  >= @from_date AND
--(CASE  
--	WHEN isnull(educat.last_updated,'1/1/1900') > isnull(educat.last_worked,'1/1/1900') AND isnull(educat.last_updated,'1/1/1900') > isnull(educat.Web_Updated,'1/1/1900') THEN educat.last_updated  
--	WHEN isnull(educat.last_worked,'1/1/1900') > isnull(educat.last_updated,'1/1/1900') AND isnull(educat.last_worked,'1/1/1900') > isnull(educat.Web_Updated,'1/1/1900') THEN educat.last_worked 
--	WHEN isnull(educat.Web_Updated,'1/1/1900') > isnull(educat.last_worked,'1/1/1900') AND isnull(educat.Web_Updated,'1/1/1900') > isnull(educat.last_updated,'1/1/1900') THEN educat.Web_Updated 
--END) < @to_date AND CLNO = @CLNO AND apstatus in ('W','F')
--	AND  dbo.elapsedbusinessdays_2( educat.CreatedDate,educat.Web_Updated) = 1
---- group by clno 
--	)  /
--  (select count(educatid) from educat with (NOLOCK) JOIN appl with (NOLOCK) on appl.apno = educat.apno 
--   where 
--(CASE  
--	WHEN isnull(educat.last_updated,'1/1/1900') > isnull(educat.last_worked,'1/1/1900') AND isnull(educat.last_updated,'1/1/1900') > isnull(educat.Web_Updated,'1/1/1900') THEN educat.last_updated  
--	WHEN isnull(educat.last_worked,'1/1/1900') > isnull(educat.last_updated,'1/1/1900') AND isnull(educat.last_worked,'1/1/1900') > isnull(educat.Web_Updated,'1/1/1900') THEN educat.last_worked 
--	WHEN isnull(educat.Web_Updated,'1/1/1900') > isnull(educat.last_worked,'1/1/1900') AND isnull(educat.Web_Updated,'1/1/1900') > isnull(educat.last_updated,'1/1/1900') THEN educat.Web_Updated 
--END)  >= @from_date AND 
--(CASE  
--	WHEN isnull(educat.last_updated,'1/1/1900') > isnull(educat.last_worked,'1/1/1900') AND isnull(educat.last_updated,'1/1/1900') > isnull(educat.Web_Updated,'1/1/1900') THEN educat.last_updated  
--	WHEN isnull(educat.last_worked,'1/1/1900') > isnull(educat.last_updated,'1/1/1900') AND isnull(educat.last_worked,'1/1/1900') > isnull(educat.Web_Updated,'1/1/1900') THEN educat.last_worked 
--	WHEN isnull(educat.Web_Updated,'1/1/1900') > isnull(educat.last_worked,'1/1/1900') AND isnull(educat.Web_Updated,'1/1/1900') > isnull(educat.last_updated,'1/1/1900') THEN educat.Web_Updated 
--END)  < @to_date AND CLNO = @CLNO AND apstatus in ('W','F')
--  )AS NUMERIC( 5, 2 ) ) AS 'Percentage',
--
--CAST( 100. * (SELECT count(*) FROM educat with (NOLOCK)
--	JOIN appl with (NOLOCK) on appl.apno = educat.apno
--	WHERE 
--(CASE  
--	WHEN isnull(educat.last_updated,'1/1/1900') > isnull(educat.last_worked,'1/1/1900') AND isnull(educat.last_updated,'1/1/1900') > isnull(educat.Web_Updated,'1/1/1900') THEN educat.last_updated  
--	WHEN isnull(educat.last_worked,'1/1/1900') > isnull(educat.last_updated,'1/1/1900') AND isnull(educat.last_worked,'1/1/1900') > isnull(educat.Web_Updated,'1/1/1900') THEN educat.last_worked 
--	WHEN isnull(educat.Web_Updated,'1/1/1900') > isnull(educat.last_worked,'1/1/1900') AND isnull(educat.Web_Updated,'1/1/1900') > isnull(educat.last_updated,'1/1/1900') THEN educat.Web_Updated 
--END)  >= @from_date AND 
--(CASE  
--	WHEN isnull(educat.last_updated,'1/1/1900') > isnull(educat.last_worked,'1/1/1900') AND isnull(educat.last_updated,'1/1/1900') > isnull(educat.Web_Updated,'1/1/1900') THEN educat.last_updated  
--	WHEN isnull(educat.last_worked,'1/1/1900') > isnull(educat.last_updated,'1/1/1900') AND isnull(educat.last_worked,'1/1/1900') > isnull(educat.Web_Updated,'1/1/1900') THEN educat.last_worked 
--	WHEN isnull(educat.Web_Updated,'1/1/1900') > isnull(educat.last_worked,'1/1/1900') AND isnull(educat.Web_Updated,'1/1/1900') > isnull(educat.last_updated,'1/1/1900') THEN educat.Web_Updated 
--END)  < @to_date AND CLNO = @CLNO AND apstatus in ('W','F')
--	AND dbo.elapsedbusinessdays_2( educat.CreatedDate,educat.Web_Updated)<= 1 
----group by clno
--	) / 
--  (select count(educatid) from educat with (NOLOCK) JOIN appl with (NOLOCK) on appl.apno = educat.apno 
--   where 
--(CASE  
--	WHEN isnull(educat.last_updated,'1/1/1900') > isnull(educat.last_worked,'1/1/1900') AND isnull(educat.last_updated,'1/1/1900') > isnull(educat.Web_Updated,'1/1/1900') THEN educat.last_updated  
--	WHEN isnull(educat.last_worked,'1/1/1900') > isnull(educat.last_updated,'1/1/1900') AND isnull(educat.last_worked,'1/1/1900') > isnull(educat.Web_Updated,'1/1/1900') THEN educat.last_worked 
--	WHEN isnull(educat.Web_Updated,'1/1/1900') > isnull(educat.last_worked,'1/1/1900') AND isnull(educat.Web_Updated,'1/1/1900') > isnull(educat.last_updated,'1/1/1900') THEN educat.Web_Updated 
--END)  >= @from_date AND 
--(CASE  
--	WHEN isnull(educat.last_updated,'1/1/1900') > isnull(educat.last_worked,'1/1/1900') AND isnull(educat.last_updated,'1/1/1900') > isnull(educat.Web_Updated,'1/1/1900') THEN educat.last_updated  
--	WHEN isnull(educat.last_worked,'1/1/1900') > isnull(educat.last_updated,'1/1/1900') AND isnull(educat.last_worked,'1/1/1900') > isnull(educat.Web_Updated,'1/1/1900') THEN educat.last_worked 
--	WHEN isnull(educat.Web_Updated,'1/1/1900') > isnull(educat.last_worked,'1/1/1900') AND isnull(educat.Web_Updated,'1/1/1900') > isnull(educat.last_updated,'1/1/1900') THEN educat.Web_Updated 
--END)  < @to_date AND CLNO = @CLNO AND apstatus in ('W','F')
--  )AS NUMERIC( 5, 2 ) ) as 'Cumulative %'
--FROM educat with (NOLOCK) JOIN appl with (NOLOCK) on appl.apno = educat.apno
--WHERE  
--(CASE  
--	WHEN isnull(educat.last_updated,'1/1/1900') > isnull(educat.last_worked,'1/1/1900') AND isnull(educat.last_updated,'1/1/1900') > isnull(educat.Web_Updated,'1/1/1900') THEN educat.last_updated  
--	WHEN isnull(educat.last_worked,'1/1/1900') > isnull(educat.last_updated,'1/1/1900') AND isnull(educat.last_worked,'1/1/1900') > isnull(educat.Web_Updated,'1/1/1900') THEN educat.last_worked 
--	WHEN isnull(educat.Web_Updated,'1/1/1900') > isnull(educat.last_worked,'1/1/1900') AND isnull(educat.Web_Updated,'1/1/1900') > isnull(educat.last_updated,'1/1/1900') THEN educat.Web_Updated 
--END)  >= @from_date AND 
--(CASE  
--	WHEN isnull(educat.last_updated,'1/1/1900') > isnull(educat.last_worked,'1/1/1900') AND isnull(educat.last_updated,'1/1/1900') > isnull(educat.Web_Updated,'1/1/1900') THEN educat.last_updated  
--	WHEN isnull(educat.last_worked,'1/1/1900') > isnull(educat.last_updated,'1/1/1900') AND isnull(educat.last_worked,'1/1/1900') > isnull(educat.Web_Updated,'1/1/1900') THEN educat.last_worked 
--	WHEN isnull(educat.Web_Updated,'1/1/1900') > isnull(educat.last_worked,'1/1/1900') AND isnull(educat.Web_Updated,'1/1/1900') > isnull(educat.last_updated,'1/1/1900') THEN educat.Web_Updated 
--END) < @to_date AND  CLNO = @CLNO AND apstatus in ('W','F') 
----group by clno 
--
--UNION

SELECT '3 days' AS 'Turnaround Time',( SELECT count(*) FROM educat with (NOLOCK)
JOIN appl with (NOLOCK) on appl.apno = educat.apno
WHERE
educat.Web_Updated >= @from_date AND educat.Web_Updated < @to_date 
AND CLNO = @CLNO AND apstatus in ('W','F')
AND apstatus in ('W','F')
AND dbo.elapsedbusinessdays_2( educat.CreatedDate,educat.Web_Updated) = 3
--group by clno
) as 'Count'
, CAST( 100. * (SELECT count(*) FROM educat with (NOLOCK)
	JOIN appl with (NOLOCK) on appl.apno = educat.apno
	WHERE 
educat.Web_Updated >= @from_date AND educat.Web_Updated < @to_date  AND CLNO = @CLNO AND apstatus in ('W','F')
	 AND dbo.elapsedbusinessdays_2( educat.CreatedDate,educat.Web_Updated)  = 3 
--group by clno
	)  /
  (select count(educatid) from educat with (NOLOCK) JOIN appl with (NOLOCK) on appl.apno = educat.apno 
   where 
educat.Web_Updated >= @from_date AND educat.Web_Updated < @to_date  AND CLNO = @CLNO AND apstatus in ('W','F')
  )AS NUMERIC( 5, 2 ) ) AS 'Percentage', 

CAST( 100. * (SELECT count(*) FROM educat with (NOLOCK)
	JOIN appl with (NOLOCK) on appl.apno = educat.apno
	WHERE 
educat.Web_Updated >= @from_date AND educat.Web_Updated < @to_date  AND CLNO = @CLNO AND apstatus in ('W','F')
	 AND dbo.elapsedbusinessdays_2( educat.CreatedDate,educat.Web_Updated) <=3
--group by clno
	) / 
  (select count(educatid) from educat with (NOLOCK) JOIN appl with (NOLOCK) on appl.apno = educat.apno 
   where 
educat.Web_Updated >= @from_date AND educat.Web_Updated < @to_date  AND CLNO = @CLNO AND apstatus in ('W','F')
  )AS NUMERIC( 5, 2 ) ) as 'Cumulative %'
FROM educat with (NOLOCK) JOIN appl with (NOLOCK) on appl.apno = educat.apno
WHERE  
educat.Web_Updated >= @from_date AND educat.Web_Updated < @to_date  AND  CLNO = @CLNO AND apstatus in ('W','F') 
--group by clno 


UNION

SELECT '4 days' AS 'Turnaround Time',( SELECT count(*) FROM educat with (NOLOCK)
JOIN appl with (NOLOCK) on appl.apno = educat.apno
WHERE
educat.Web_Updated >= @from_date AND educat.Web_Updated < @to_date
AND CLNO = @CLNO AND apstatus in ('W','F')
 AND dbo.elapsedbusinessdays_2( educat.CreatedDate,educat.Web_Updated) = 4
--group by clno
) as 'Count'
, CAST( 100. * (SELECT count(*) FROM educat with (NOLOCK)
	JOIN appl with (NOLOCK) on appl.apno = educat.apno
	WHERE 
educat.Web_Updated >= @from_date AND educat.Web_Updated < @to_date  AND CLNO = @CLNO AND apstatus in ('W','F')
 AND dbo.elapsedbusinessdays_2( educat.CreatedDate,educat.Web_Updated) = 4 
--group by clno
	)  /
  (select count(educatid) from educat with (NOLOCK) JOIN appl with (NOLOCK) on appl.apno = educat.apno 
   where 
educat.Web_Updated >= @from_date AND educat.Web_Updated < @to_date  AND CLNO = @CLNO AND apstatus in ('W','F')
  )AS NUMERIC( 5, 2 ) ) AS 'Percentage',

CAST( 100. * (SELECT count(*) FROM educat with (NOLOCK)
	JOIN appl with (NOLOCK) on appl.apno = educat.apno
	WHERE 
educat.Web_Updated >= @from_date AND educat.Web_Updated < @to_date AND CLNO = @CLNO AND apstatus in ('W','F') AND
	 dbo.elapsedbusinessdays_2( educat.CreatedDate,educat.Web_Updated) <= 4
-- group by clno
	) / 
  (select count(educatid) from educat with (NOLOCK) JOIN appl with (NOLOCK) on appl.apno = educat.apno 
   where 
educat.Web_Updated >= @from_date AND educat.Web_Updated < @to_date  AND CLNO = @CLNO AND apstatus in ('W','F')
  )AS NUMERIC( 5, 2 ) ) as 'Cumulative %'
FROM educat with (NOLOCK) JOIN appl with (NOLOCK) on appl.apno = educat.apno
WHERE  
educat.Web_Updated >= @from_date AND educat.Web_Updated < @to_date AND  CLNO = @CLNO AND apstatus in ('W','F') 
--group by clno 

UNION

SELECT '5 days' AS 'Turnaround Time',( SELECT count(*) FROM educat with (NOLOCK)
JOIN appl with (NOLOCK) on appl.apno = educat.apno
WHERE
educat.Web_Updated >= @from_date AND educat.Web_Updated < @to_date
AND CLNO = @CLNO AND apstatus in ('W','F')
 AND dbo.elapsedbusinessdays_2( educat.CreatedDate,educat.Web_Updated) = 5
--group by clno
) as 'Count'
, CAST( 100. * (SELECT count(*) FROM educat with (NOLOCK)
	JOIN appl with (NOLOCK) on appl.apno = educat.apno
	WHERE 
educat.Web_Updated >= @from_date AND educat.Web_Updated < @to_date  AND CLNO = @CLNO AND apstatus in ('W','F')
 AND dbo.elapsedbusinessdays_2( educat.CreatedDate,educat.Web_Updated) = 5 
--group by clno
	)  /
  (select count(educatid) from educat with (NOLOCK) JOIN appl with (NOLOCK) on appl.apno = educat.apno 
   where 
educat.Web_Updated >= @from_date AND educat.Web_Updated < @to_date  AND CLNO = @CLNO AND apstatus in ('W','F')
  )AS NUMERIC( 5, 2 ) ) AS 'Percentage',

CAST( 100. * (SELECT count(*) FROM educat with (NOLOCK)
	JOIN appl with (NOLOCK) on appl.apno = educat.apno
	WHERE 
educat.Web_Updated >= @from_date AND educat.Web_Updated < @to_date AND CLNO = @CLNO AND apstatus in ('W','F') AND
	 dbo.elapsedbusinessdays_2( educat.CreatedDate,educat.Web_Updated) <= 5
-- group by clno
	) / 
  (select count(educatid) from educat with (NOLOCK) JOIN appl with (NOLOCK) on appl.apno = educat.apno 
   where 
educat.Web_Updated >= @from_date AND educat.Web_Updated < @to_date  AND CLNO = @CLNO AND apstatus in ('W','F')
  )AS NUMERIC( 5, 2 ) ) as 'Cumulative %'
FROM educat with (NOLOCK) JOIN appl with (NOLOCK) on appl.apno = educat.apno
WHERE  
educat.Web_Updated >= @from_date AND educat.Web_Updated < @to_date AND  CLNO = @CLNO AND apstatus in ('W','F') 
--group by clno 

UNION

SELECT '6+ days' AS 'Turnaround Time',( SELECT count(*) FROM educat with (NOLOCK)
JOIN appl with (NOLOCK) on appl.apno = educat.apno
WHERE
educat.Web_Updated >= @from_date AND educat.Web_Updated < @to_date 
AND CLNO = @CLNO
AND apstatus in ('W','F')
AND dbo.elapsedbusinessdays_2( educat.CreatedDate,educat.Web_Updated) >=6
--group by clno
) as 'Count'
, CAST( 100. * (SELECT count(*) FROM educat with (NOLOCK)
	JOIN appl with (NOLOCK) on appl.apno = educat.apno
	WHERE 
educat.Web_Updated >= @from_date AND educat.Web_Updated < @to_date AND CLNO = @CLNO AND apstatus in ('W','F')
	AND dbo.elapsedbusinessdays_2( educat.CreatedDate,educat.Web_Updated) >=6 
--group by clno
	)  /
  (select count(educatid) from educat with (NOLOCK) JOIN appl with (NOLOCK) on appl.apno = educat.apno 
   where 
educat.Web_Updated >= @from_date AND educat.Web_Updated < @to_date AND CLNO = @CLNO AND apstatus in ('W','F')
  )AS NUMERIC( 5, 2 ) ) AS 'Percentage',

CAST( 100. * (SELECT count(*) FROM educat with (NOLOCK)
	JOIN appl with (NOLOCK) on appl.apno = educat.apno
	WHERE 
educat.Web_Updated >= @from_date AND educat.Web_Updated < @to_date

AND CLNO = @CLNO AND apstatus in ('W','F')
	AND dbo.elapsedbusinessdays_2( educat.CreatedDate,educat.Web_Updated)  >=0 
--group by clno
	) / 
  (select count(educatid) from educat with (NOLOCK) JOIN appl with (NOLOCK) on appl.apno = educat.apno 
   where 
educat.Web_Updated >= @from_date AND educat.Web_Updated < @to_date
AND CLNO = @CLNO AND apstatus in ('W','F')
  )AS NUMERIC( 5, 2 ) ) as 'Cumulative %'
FROM educat with (NOLOCK) JOIN appl with (NOLOCK) on appl.apno = educat.apno
WHERE  
educat.Web_Updated >= @from_date AND educat.Web_Updated < @to_date AND  CLNO = @CLNO AND apstatus in ('W','F') 
--group by clno 

UNION

SELECT 'Total',
(select COUNT( educatid ) from educat with (NOLOCK) JOIN appl with (NOLOCK) on educat.apno = appl.apno
where 
educat.Web_Updated >= @from_date AND educat.Web_Updated < @to_date AND CLNO = @CLNO  AND apstatus in ('W','F') 
--group by CLNO
), 100, 100
FROM educat with (NOLOCK) JOIN appl with (NOLOCK) on appl.apno = educat.apno
WHERE  
educat.Web_Updated >= @from_date AND educat.Web_Updated < @to_date AND  CLNO = @CLNO AND apstatus in ('W','F') 
--group by clno
END --end of educat section

IF @section = 'Education'
BEGIN
SELECT '0 days' AS 'Turnaround Time',( SELECT count(*) FROM educat with (NOLOCK)
JOIN appl with (NOLOCK)  on appl.apno = educat.apno
WHERE
(CASE  
	WHEN isnull(educat.last_updated,'1/1/1900') >= isnull(educat.last_worked,'1/1/1900') AND isnull(educat.last_updated,'1/1/1900') >= isnull(educat.Web_Updated,'1/1/1900') THEN educat.last_updated   
	WHEN isnull(educat.last_worked,'1/1/1900') >= isnull(educat.last_updated,'1/1/1900') AND isnull(educat.last_worked,'1/1/1900') >= isnull(educat.Web_Updated,'1/1/1900') THEN educat.last_worked  
	WHEN isnull(educat.Web_Updated,'1/1/1900') >= isnull(educat.last_worked,'1/1/1900') AND isnull(educat.Web_Updated,'1/1/1900') > isnull(educat.last_updated,'1/1/1900') THEN educat.Web_Updated  
END) >= @from_date
AND
(CASE  
	WHEN isnull(educat.last_updated,'1/1/1900') >= isnull(educat.last_worked,'1/1/1900') AND isnull(educat.last_updated,'1/1/1900') >= isnull(educat.Web_Updated,'1/1/1900') THEN educat.last_updated  
	WHEN isnull(educat.last_worked,'1/1/1900') >= isnull(educat.last_updated,'1/1/1900') AND isnull(educat.last_worked,'1/1/1900') >= isnull(educat.Web_Updated,'1/1/1900') THEN educat.last_worked 
	WHEN isnull(educat.Web_Updated,'1/1/1900') >= isnull(educat.last_worked,'1/1/1900') AND isnull(educat.Web_Updated,'1/1/1900') > isnull(educat.last_updated,'1/1/1900') THEN educat.Web_Updated 
END)  < @to_date
AND CLNO = @CLNO
AND apstatus in ('W','F')
AND (CASE  
	WHEN isnull(educat.last_updated,'1/1/1900') >= isnull(educat.last_worked,'1/1/1900') AND isnull(educat.last_updated,'1/1/1900') >= isnull(educat.Web_Updated,'1/1/1900') THEN dbo.elapsedbusinessdays_2( educat.CreatedDate,educat.last_updated)  
	WHEN isnull(educat.last_worked,'1/1/1900') >= isnull(educat.last_updated,'1/1/1900') AND isnull(educat.last_worked,'1/1/1900') >= isnull(educat.Web_Updated,'1/1/1900') THEN dbo.elapsedbusinessdays_2( educat.CreatedDate,educat.last_worked) 
	WHEN isnull(educat.Web_Updated,'1/1/1900') >= isnull(educat.last_worked,'1/1/1900') AND isnull(educat.Web_Updated,'1/1/1900') >= isnull(educat.last_updated,'1/1/1900') THEN dbo.elapsedbusinessdays_2( educat.CreatedDate,educat.Web_Updated)
END) = 0
--group by clno
) as 'Count'
, CAST( 100. * (SELECT count(*) FROM educat with (NOLOCK)
	JOIN appl with (NOLOCK) on appl.apno = educat.apno
	WHERE 
(CASE  
	WHEN isnull(educat.last_updated,'1/1/1900') >= isnull(educat.last_worked,'1/1/1900') AND isnull(educat.last_updated,'1/1/1900') >= isnull(educat.Web_Updated,'1/1/1900') THEN educat.last_updated  
	WHEN isnull(educat.last_worked,'1/1/1900') >= isnull(educat.last_updated,'1/1/1900') AND isnull(educat.last_worked,'1/1/1900') >= isnull(educat.Web_Updated,'1/1/1900') THEN educat.last_worked 
	WHEN isnull(educat.Web_Updated,'1/1/1900') >= isnull(educat.last_worked,'1/1/1900') AND isnull(educat.Web_Updated,'1/1/1900') >= isnull(educat.last_updated,'1/1/1900') THEN educat.Web_Updated 
END)  >= @from_date AND
(CASE  
	WHEN isnull(educat.last_updated,'1/1/1900') >= isnull(educat.last_worked,'1/1/1900') AND isnull(educat.last_updated,'1/1/1900') >= isnull(educat.Web_Updated,'1/1/1900') THEN educat.last_updated  
	WHEN isnull(educat.last_worked,'1/1/1900') >= isnull(educat.last_updated,'1/1/1900') AND isnull(educat.last_worked,'1/1/1900') >= isnull(educat.Web_Updated,'1/1/1900') THEN educat.last_worked 
	WHEN isnull(educat.Web_Updated,'1/1/1900') >= isnull(educat.last_worked,'1/1/1900') AND isnull(educat.Web_Updated,'1/1/1900') >= isnull(educat.last_updated,'1/1/1900') THEN educat.Web_Updated 
END) < @to_date AND CLNO = @CLNO AND apstatus in ('W','F')
	AND  (CASE  
	WHEN isnull(educat.last_updated,'1/1/1900') >= isnull(educat.last_worked,'1/1/1900') AND isnull(educat.last_updated,'1/1/1900') >= isnull(educat.Web_Updated,'1/1/1900') THEN dbo.elapsedbusinessdays_2( educat.CreatedDate,educat.last_updated)  
	WHEN isnull(educat.last_worked,'1/1/1900') >= isnull(educat.last_updated,'1/1/1900') AND isnull(educat.last_worked,'1/1/1900') >= isnull(educat.Web_Updated,'1/1/1900') THEN dbo.elapsedbusinessdays_2( educat.CreatedDate,educat.last_worked) 
	WHEN isnull(educat.Web_Updated,'1/1/1900') >= isnull(educat.last_worked,'1/1/1900') AND isnull(educat.Web_Updated,'1/1/1900') >= isnull(educat.last_updated,'1/1/1900') THEN dbo.elapsedbusinessdays_2( educat.CreatedDate,educat.Web_Updated)
end) = 0 
--group by clno
	)  /
  (select count(educatid) from educat with (NOLOCK) JOIN appl with (NOLOCK) on appl.apno = educat.apno 
   where 
(CASE  
	WHEN isnull(educat.last_updated,'1/1/1900') >= isnull(educat.last_worked,'1/1/1900') AND isnull(educat.last_updated,'1/1/1900') >= isnull(educat.Web_Updated,'1/1/1900') THEN educat.last_updated  
	WHEN isnull(educat.last_worked,'1/1/1900') >= isnull(educat.last_updated,'1/1/1900') AND isnull(educat.last_worked,'1/1/1900') >= isnull(educat.Web_Updated,'1/1/1900') THEN educat.last_worked 
	WHEN isnull(educat.Web_Updated,'1/1/1900') >= isnull(educat.last_worked,'1/1/1900') AND isnull(educat.Web_Updated,'1/1/1900') >= isnull(educat.last_updated,'1/1/1900') THEN educat.Web_Updated 
END)  >= @from_date AND 
(CASE  
	WHEN isnull(educat.last_updated,'1/1/1900') >= isnull(educat.last_worked,'1/1/1900') AND isnull(educat.last_updated,'1/1/1900') >= isnull(educat.Web_Updated,'1/1/1900') THEN educat.last_updated  
	WHEN isnull(educat.last_worked,'1/1/1900') >= isnull(educat.last_updated,'1/1/1900') AND isnull(educat.last_worked,'1/1/1900') >= isnull(educat.Web_Updated,'1/1/1900') THEN educat.last_worked 
	WHEN isnull(educat.Web_Updated,'1/1/1900') >= isnull(educat.last_worked,'1/1/1900') AND isnull(educat.Web_Updated,'1/1/1900') >= isnull(educat.last_updated,'1/1/1900') THEN educat.Web_Updated 
END)  < @to_date AND CLNO = @CLNO AND apstatus in ('W','F')
  )AS NUMERIC( 5, 2 ) ) AS 'Percentage',

CAST( 100. * (SELECT count(*) FROM educat with (NOLOCK)
	JOIN appl with (NOLOCK) on appl.apno = educat.apno
	WHERE 
(CASE  
	WHEN isnull(educat.last_updated,'1/1/1900') >= isnull(educat.last_worked,'1/1/1900') AND isnull(educat.last_updated,'1/1/1900') >= isnull(educat.Web_Updated,'1/1/1900') THEN educat.last_updated  
	WHEN isnull(educat.last_worked,'1/1/1900') >= isnull(educat.last_updated,'1/1/1900') AND isnull(educat.last_worked,'1/1/1900') >= isnull(educat.Web_Updated,'1/1/1900') THEN educat.last_worked 
	WHEN isnull(educat.Web_Updated,'1/1/1900') >= isnull(educat.last_worked,'1/1/1900') AND isnull(educat.Web_Updated,'1/1/1900') >= isnull(educat.last_updated,'1/1/1900') THEN educat.Web_Updated 
END)  >= @from_date AND 
(CASE  
	WHEN isnull(educat.last_updated,'1/1/1900') >= isnull(educat.last_worked,'1/1/1900') AND isnull(educat.last_updated,'1/1/1900') >= isnull(educat.Web_Updated,'1/1/1900') THEN educat.last_updated  
	WHEN isnull(educat.last_worked,'1/1/1900') >= isnull(educat.last_updated,'1/1/1900') AND isnull(educat.last_worked,'1/1/1900') >= isnull(educat.Web_Updated,'1/1/1900') THEN educat.last_worked 
	WHEN isnull(educat.Web_Updated,'1/1/1900') >= isnull(educat.last_worked,'1/1/1900') AND isnull(educat.Web_Updated,'1/1/1900') >= isnull(educat.last_updated,'1/1/1900') THEN educat.Web_Updated 
END)  < @to_date AND CLNO = @CLNO AND apstatus in ('W','F')
	AND  (CASE  
	WHEN isnull(educat.last_updated,'1/1/1900') >= isnull(educat.last_worked,'1/1/1900') AND isnull(educat.last_updated,'1/1/1900') >= isnull(educat.Web_Updated,'1/1/1900') THEN dbo.elapsedbusinessdays_2( educat.CreatedDate,educat.last_updated)  
	WHEN isnull(educat.last_worked,'1/1/1900') >= isnull(educat.last_updated,'1/1/1900') AND isnull(educat.last_worked,'1/1/1900') >= isnull(educat.Web_Updated,'1/1/1900') THEN dbo.elapsedbusinessdays_2( educat.CreatedDate,educat.last_worked) 
	WHEN isnull(educat.Web_Updated,'1/1/1900') >= isnull(educat.last_worked,'1/1/1900') AND isnull(educat.Web_Updated,'1/1/1900') >= isnull(educat.last_updated,'1/1/1900') THEN dbo.elapsedbusinessdays_2( educat.CreatedDate,educat.Web_Updated)
	END) = 0
-- group by clno
	) / 
  (select count(educatid) from educat with (NOLOCK) JOIN appl with (NOLOCK) on appl.apno = educat.apno 
   where 
(CASE  
	WHEN isnull(educat.last_updated,'1/1/1900') >= isnull(educat.last_worked,'1/1/1900') AND isnull(educat.last_updated,'1/1/1900') >= isnull(educat.Web_Updated,'1/1/1900') THEN educat.last_updated  
	WHEN isnull(educat.last_worked,'1/1/1900') >= isnull(educat.last_updated,'1/1/1900') AND isnull(educat.last_worked,'1/1/1900') >= isnull(educat.Web_Updated,'1/1/1900') THEN educat.last_worked 
	WHEN isnull(educat.Web_Updated,'1/1/1900') >= isnull(educat.last_worked,'1/1/1900') AND isnull(educat.Web_Updated,'1/1/1900') >= isnull(educat.last_updated,'1/1/1900') THEN educat.Web_Updated 
END)  >= @from_date AND 
(CASE  
	WHEN isnull(educat.last_updated,'1/1/1900') >= isnull(educat.last_worked,'1/1/1900') AND isnull(educat.last_updated,'1/1/1900') >= isnull(educat.Web_Updated,'1/1/1900') THEN educat.last_updated  
	WHEN isnull(educat.last_worked,'1/1/1900') >= isnull(educat.last_updated,'1/1/1900') AND isnull(educat.last_worked,'1/1/1900') >= isnull(educat.Web_Updated,'1/1/1900') THEN educat.last_worked 
	WHEN isnull(educat.Web_Updated,'1/1/1900') >= isnull(educat.last_worked,'1/1/1900') AND isnull(educat.Web_Updated,'1/1/1900') >= isnull(educat.last_updated,'1/1/1900') THEN educat.Web_Updated 
END)  < @to_date AND CLNO = @CLNO AND apstatus in ('W','F')
  )AS NUMERIC( 5, 2 ) ) as 'Cumulative %'
FROM educat with (NOLOCK) JOIN appl with (NOLOCK) on appl.apno = educat.apno
WHERE  
(CASE  
	WHEN isnull(educat.last_updated,'1/1/1900') >= isnull(educat.last_worked,'1/1/1900') AND isnull(educat.last_updated,'1/1/1900') >= isnull(educat.Web_Updated,'1/1/1900') THEN educat.last_updated  
	WHEN isnull(educat.last_worked,'1/1/1900') >= isnull(educat.last_updated,'1/1/1900') AND isnull(educat.last_worked,'1/1/1900') >= isnull(educat.Web_Updated,'1/1/1900') THEN educat.last_worked 
	WHEN isnull(educat.Web_Updated,'1/1/1900') >= isnull(educat.last_worked,'1/1/1900') AND isnull(educat.Web_Updated,'1/1/1900') >= isnull(educat.last_updated,'1/1/1900') THEN educat.Web_Updated 
END)  >= @from_date AND 
(CASE  
	WHEN isnull(educat.last_updated,'1/1/1900') >= isnull(educat.last_worked,'1/1/1900') AND isnull(educat.last_updated,'1/1/1900') >= isnull(educat.Web_Updated,'1/1/1900') THEN educat.last_updated  
	WHEN isnull(educat.last_worked,'1/1/1900') >= isnull(educat.last_updated,'1/1/1900') AND isnull(educat.last_worked,'1/1/1900') >= isnull(educat.Web_Updated,'1/1/1900') THEN educat.last_worked 
	WHEN isnull(educat.Web_Updated,'1/1/1900') >= isnull(educat.last_worked,'1/1/1900') AND isnull(educat.Web_Updated,'1/1/1900') >= isnull(educat.last_updated,'1/1/1900') THEN educat.Web_Updated 
END) < @to_date AND  CLNO = @CLNO AND apstatus in ('W','F') 
--group by clno 

UNION

SELECT '1 day' AS 'Turnaround Time',( SELECT count(*) FROM educat with (NOLOCK)
JOIN appl with (NOLOCK) on appl.apno = educat.apno
WHERE
(CASE  
	WHEN isnull(educat.last_updated,'1/1/1900') >= isnull(educat.last_worked,'1/1/1900') AND isnull(educat.last_updated,'1/1/1900') >= isnull(educat.Web_Updated,'1/1/1900') THEN educat.last_updated   
	WHEN isnull(educat.last_worked,'1/1/1900') >= isnull(educat.last_updated,'1/1/1900') AND isnull(educat.last_worked,'1/1/1900') >= isnull(educat.Web_Updated,'1/1/1900') THEN educat.last_worked  
	WHEN isnull(educat.Web_Updated,'1/1/1900') >= isnull(educat.last_worked,'1/1/1900') AND isnull(educat.Web_Updated,'1/1/1900') >= isnull(educat.last_updated,'1/1/1900') THEN educat.Web_Updated  
END) >= @from_date
AND
(CASE  
	WHEN isnull(educat.last_updated,'1/1/1900') >= isnull(educat.last_worked,'1/1/1900') AND isnull(educat.last_updated,'1/1/1900') >= isnull(educat.Web_Updated,'1/1/1900') THEN educat.last_updated  
	WHEN isnull(educat.last_worked,'1/1/1900') >= isnull(educat.last_updated,'1/1/1900') AND isnull(educat.last_worked,'1/1/1900') >= isnull(educat.Web_Updated,'1/1/1900') THEN educat.last_worked 
	WHEN isnull(educat.Web_Updated,'1/1/1900') >= isnull(educat.last_worked,'1/1/1900') AND isnull(educat.Web_Updated,'1/1/1900') >= isnull(educat.last_updated,'1/1/1900') THEN educat.Web_Updated 
END)  < @to_date
AND CLNO = @CLNO
AND apstatus in ('W','F')
AND (CASE  
	WHEN isnull(educat.last_updated,'1/1/1900') >= isnull(educat.last_worked,'1/1/1900') AND isnull(educat.last_updated,'1/1/1900') >= isnull(educat.Web_Updated,'1/1/1900') THEN dbo.elapsedbusinessdays_2( educat.CreatedDate,educat.last_updated)  
	WHEN isnull(educat.last_worked,'1/1/1900') >= isnull(educat.last_updated,'1/1/1900') AND isnull(educat.last_worked,'1/1/1900') >= isnull(educat.Web_Updated,'1/1/1900') THEN dbo.elapsedbusinessdays_2( educat.CreatedDate,educat.last_worked) 
	WHEN isnull(educat.Web_Updated,'1/1/1900') >= isnull(educat.last_worked,'1/1/1900') AND isnull(educat.Web_Updated,'1/1/1900') >= isnull(educat.last_updated,'1/1/1900') THEN dbo.elapsedbusinessdays_2( educat.CreatedDate,educat.Web_Updated)
END) = 1
--group by clno
) as 'Count'
, CAST( 100. * (SELECT count(*) FROM educat with (NOLOCK)
	JOIN appl with (NOLOCK) on appl.apno = educat.apno
	WHERE 
(CASE  
	WHEN isnull(educat.last_updated,'1/1/1900') >= isnull(educat.last_worked,'1/1/1900') AND isnull(educat.last_updated,'1/1/1900') >= isnull(educat.Web_Updated,'1/1/1900') THEN educat.last_updated  
	WHEN isnull(educat.last_worked,'1/1/1900') >= isnull(educat.last_updated,'1/1/1900') AND isnull(educat.last_worked,'1/1/1900') >= isnull(educat.Web_Updated,'1/1/1900') THEN educat.last_worked 
	WHEN isnull(educat.Web_Updated,'1/1/1900') >= isnull(educat.last_worked,'1/1/1900') AND isnull(educat.Web_Updated,'1/1/1900') >= isnull(educat.last_updated,'1/1/1900') THEN educat.Web_Updated 
END)  >= @from_date AND
(CASE  
	WHEN isnull(educat.last_updated,'1/1/1900') >= isnull(educat.last_worked,'1/1/1900') AND isnull(educat.last_updated,'1/1/1900') >= isnull(educat.Web_Updated,'1/1/1900') THEN educat.last_updated  
	WHEN isnull(educat.last_worked,'1/1/1900') >= isnull(educat.last_updated,'1/1/1900') AND isnull(educat.last_worked,'1/1/1900') >= isnull(educat.Web_Updated,'1/1/1900') THEN educat.last_worked 
	WHEN isnull(educat.Web_Updated,'1/1/1900') >= isnull(educat.last_worked,'1/1/1900') AND isnull(educat.Web_Updated,'1/1/1900') >= isnull(educat.last_updated,'1/1/1900') THEN educat.Web_Updated 
END) < @to_date AND CLNO = @CLNO AND apstatus in ('W','F')
	AND  (CASE  
	WHEN isnull(educat.last_updated,'1/1/1900') >= isnull(educat.last_worked,'1/1/1900') AND isnull(educat.last_updated,'1/1/1900') >= isnull(educat.Web_Updated,'1/1/1900') THEN dbo.elapsedbusinessdays_2( educat.CreatedDate,educat.last_updated)  
	WHEN isnull(educat.last_worked,'1/1/1900') >= isnull(educat.last_updated,'1/1/1900') AND isnull(educat.last_worked,'1/1/1900') >= isnull(educat.Web_Updated,'1/1/1900') THEN dbo.elapsedbusinessdays_2( educat.CreatedDate,educat.last_worked) 
	WHEN isnull(educat.Web_Updated,'1/1/1900') >= isnull(educat.last_worked,'1/1/1900') AND isnull(educat.Web_Updated,'1/1/1900') >= isnull(educat.last_updated,'1/1/1900') THEN dbo.elapsedbusinessdays_2( educat.CreatedDate,educat.Web_Updated)
end) = 1
--group by clno 
	)  /
  (select count(educatid) from educat with (NOLOCK) JOIN appl with (NOLOCK) on appl.apno = educat.apno 
   where 
(CASE  
	WHEN isnull(educat.last_updated,'1/1/1900') >= isnull(educat.last_worked,'1/1/1900') AND isnull(educat.last_updated,'1/1/1900') >= isnull(educat.Web_Updated,'1/1/1900') THEN educat.last_updated  
	WHEN isnull(educat.last_worked,'1/1/1900') >= isnull(educat.last_updated,'1/1/1900') AND isnull(educat.last_worked,'1/1/1900') >= isnull(educat.Web_Updated,'1/1/1900') THEN educat.last_worked 
	WHEN isnull(educat.Web_Updated,'1/1/1900') >= isnull(educat.last_worked,'1/1/1900') AND isnull(educat.Web_Updated,'1/1/1900') >= isnull(educat.last_updated,'1/1/1900') THEN educat.Web_Updated 
END)  >= @from_date AND 
(CASE  
	WHEN isnull(educat.last_updated,'1/1/1900') >= isnull(educat.last_worked,'1/1/1900') AND isnull(educat.last_updated,'1/1/1900') >= isnull(educat.Web_Updated,'1/1/1900') THEN educat.last_updated  
	WHEN isnull(educat.last_worked,'1/1/1900') >= isnull(educat.last_updated,'1/1/1900') AND isnull(educat.last_worked,'1/1/1900') >= isnull(educat.Web_Updated,'1/1/1900') THEN educat.last_worked 
	WHEN isnull(educat.Web_Updated,'1/1/1900') >= isnull(educat.last_worked,'1/1/1900') AND isnull(educat.Web_Updated,'1/1/1900') >= isnull(educat.last_updated,'1/1/1900') THEN educat.Web_Updated 
END)  < @to_date AND CLNO = @CLNO AND apstatus in ('W','F')
  )AS NUMERIC( 5, 2 ) ) AS 'Percentage',

CAST( 100. * (SELECT count(*) FROM educat with (NOLOCK)
	JOIN appl with (NOLOCK) on appl.apno = educat.apno
	WHERE 
(CASE  
	WHEN isnull(educat.last_updated,'1/1/1900') >= isnull(educat.last_worked,'1/1/1900') AND isnull(educat.last_updated,'1/1/1900') >= isnull(educat.Web_Updated,'1/1/1900') THEN educat.last_updated  
	WHEN isnull(educat.last_worked,'1/1/1900') >= isnull(educat.last_updated,'1/1/1900') AND isnull(educat.last_worked,'1/1/1900') >= isnull(educat.Web_Updated,'1/1/1900') THEN educat.last_worked 
	WHEN isnull(educat.Web_Updated,'1/1/1900') >= isnull(educat.last_worked,'1/1/1900') AND isnull(educat.Web_Updated,'1/1/1900') >= isnull(educat.last_updated,'1/1/1900') THEN educat.Web_Updated 
END)  >= @from_date AND 
(CASE  
	WHEN isnull(educat.last_updated,'1/1/1900') >= isnull(educat.last_worked,'1/1/1900') AND isnull(educat.last_updated,'1/1/1900') >= isnull(educat.Web_Updated,'1/1/1900') THEN educat.last_updated  
	WHEN isnull(educat.last_worked,'1/1/1900') >= isnull(educat.last_updated,'1/1/1900') AND isnull(educat.last_worked,'1/1/1900') >= isnull(educat.Web_Updated,'1/1/1900') THEN educat.last_worked 
	WHEN isnull(educat.Web_Updated,'1/1/1900') >= isnull(educat.last_worked,'1/1/1900') AND isnull(educat.Web_Updated,'1/1/1900') >= isnull(educat.last_updated,'1/1/1900') THEN educat.Web_Updated 
END)  < @to_date AND CLNO = @CLNO AND apstatus in ('W','F')
	AND  (CASE  
	WHEN isnull(educat.last_updated,'1/1/1900') >= isnull(educat.last_worked,'1/1/1900') AND isnull(educat.last_updated,'1/1/1900') >= isnull(educat.Web_Updated,'1/1/1900') THEN dbo.elapsedbusinessdays_2( educat.CreatedDate,educat.last_updated)  
	WHEN isnull(educat.last_worked,'1/1/1900') >= isnull(educat.last_updated,'1/1/1900') AND isnull(educat.last_worked,'1/1/1900') >= isnull(educat.Web_Updated,'1/1/1900') THEN dbo.elapsedbusinessdays_2( educat.CreatedDate,educat.last_worked) 
	WHEN isnull(educat.Web_Updated,'1/1/1900') >= isnull(educat.last_worked,'1/1/1900') AND isnull(educat.Web_Updated,'1/1/1900') >= isnull(educat.last_updated,'1/1/1900') THEN dbo.elapsedbusinessdays_2( educat.CreatedDate,educat.Web_Updated)
	END) <= 1
-- group by clno
	) / 
  (select count(educatid) from educat with (NOLOCK) JOIN appl with (NOLOCK) on appl.apno = educat.apno 
   where 
(CASE  
	WHEN isnull(educat.last_updated,'1/1/1900') >= isnull(educat.last_worked,'1/1/1900') AND isnull(educat.last_updated,'1/1/1900') >= isnull(educat.Web_Updated,'1/1/1900') THEN educat.last_updated  
	WHEN isnull(educat.last_worked,'1/1/1900') >= isnull(educat.last_updated,'1/1/1900') AND isnull(educat.last_worked,'1/1/1900') >= isnull(educat.Web_Updated,'1/1/1900') THEN educat.last_worked 
	WHEN isnull(educat.Web_Updated,'1/1/1900') >= isnull(educat.last_worked,'1/1/1900') AND isnull(educat.Web_Updated,'1/1/1900') >= isnull(educat.last_updated,'1/1/1900') THEN educat.Web_Updated 
END)  >= @from_date AND 
(CASE  
	WHEN isnull(educat.last_updated,'1/1/1900') >= isnull(educat.last_worked,'1/1/1900') AND isnull(educat.last_updated,'1/1/1900') >= isnull(educat.Web_Updated,'1/1/1900') THEN educat.last_updated  
	WHEN isnull(educat.last_worked,'1/1/1900') >= isnull(educat.last_updated,'1/1/1900') AND isnull(educat.last_worked,'1/1/1900') >= isnull(educat.Web_Updated,'1/1/1900') THEN educat.last_worked 
	WHEN isnull(educat.Web_Updated,'1/1/1900') >= isnull(educat.last_worked,'1/1/1900') AND isnull(educat.Web_Updated,'1/1/1900') >= isnull(educat.last_updated,'1/1/1900') THEN educat.Web_Updated 
END)  < @to_date AND CLNO = @CLNO AND apstatus in ('W','F')
  )AS NUMERIC( 5, 2 ) ) as 'Cumulative %'
FROM educat with (NOLOCK) JOIN appl with (NOLOCK) on appl.apno = educat.apno
WHERE  
(CASE  
	WHEN isnull(educat.last_updated,'1/1/1900') >= isnull(educat.last_worked,'1/1/1900') AND isnull(educat.last_updated,'1/1/1900') >= isnull(educat.Web_Updated,'1/1/1900') THEN educat.last_updated  
	WHEN isnull(educat.last_worked,'1/1/1900') >= isnull(educat.last_updated,'1/1/1900') AND isnull(educat.last_worked,'1/1/1900') >= isnull(educat.Web_Updated,'1/1/1900') THEN educat.last_worked 
	WHEN isnull(educat.Web_Updated,'1/1/1900') >= isnull(educat.last_worked,'1/1/1900') AND isnull(educat.Web_Updated,'1/1/1900') >= isnull(educat.last_updated,'1/1/1900') THEN educat.Web_Updated 
END)  >= @from_date AND 
(CASE  
	WHEN isnull(educat.last_updated,'1/1/1900') >= isnull(educat.last_worked,'1/1/1900') AND isnull(educat.last_updated,'1/1/1900') >= isnull(educat.Web_Updated,'1/1/1900') THEN educat.last_updated  
	WHEN isnull(educat.last_worked,'1/1/1900') >= isnull(educat.last_updated,'1/1/1900') AND isnull(educat.last_worked,'1/1/1900') >= isnull(educat.Web_Updated,'1/1/1900') THEN educat.last_worked 
	WHEN isnull(educat.Web_Updated,'1/1/1900') >= isnull(educat.last_worked,'1/1/1900') AND isnull(educat.Web_Updated,'1/1/1900') >= isnull(educat.last_updated,'1/1/1900') THEN educat.Web_Updated 
END) < @to_date AND  CLNO = @CLNO AND apstatus in ('W','F') 
--group by clno 

UNION

SELECT '2 days' AS 'Turnaround Time',( SELECT count(*) FROM educat with (NOLOCK)
JOIN appl with (NOLOCK) on appl.apno = educat.apno
WHERE
(CASE  
	WHEN isnull(educat.last_updated,'1/1/1900') >= isnull(educat.last_worked,'1/1/1900') AND isnull(educat.last_updated,'1/1/1900') >= isnull(educat.Web_Updated,'1/1/1900') THEN educat.last_updated   
	WHEN isnull(educat.last_worked,'1/1/1900') >= isnull(educat.last_updated,'1/1/1900') AND isnull(educat.last_worked,'1/1/1900') >= isnull(educat.Web_Updated,'1/1/1900') THEN educat.last_worked  
	WHEN isnull(educat.Web_Updated,'1/1/1900') >= isnull(educat.last_worked,'1/1/1900') AND isnull(educat.Web_Updated,'1/1/1900') >= isnull(educat.last_updated,'1/1/1900') THEN educat.Web_Updated  
END) >= @from_date
AND
(CASE  
	WHEN isnull(educat.last_updated,'1/1/1900') >= isnull(educat.last_worked,'1/1/1900') AND isnull(educat.last_updated,'1/1/1900') >= isnull(educat.Web_Updated,'1/1/1900') THEN educat.last_updated  
	WHEN isnull(educat.last_worked,'1/1/1900') >= isnull(educat.last_updated,'1/1/1900') AND isnull(educat.last_worked,'1/1/1900') >= isnull(educat.Web_Updated,'1/1/1900') THEN educat.last_worked 
	WHEN isnull(educat.Web_Updated,'1/1/1900') >= isnull(educat.last_worked,'1/1/1900') AND isnull(educat.Web_Updated,'1/1/1900') >= isnull(educat.last_updated,'1/1/1900') THEN educat.Web_Updated 
END)  < @to_date
AND CLNO = @CLNO AND apstatus in ('W','F')
AND apstatus in ('W','F')
AND (CASE  
	WHEN isnull(educat.last_updated,'1/1/1900') >= isnull(educat.last_worked,'1/1/1900') AND isnull(educat.last_updated,'1/1/1900') >= isnull(educat.Web_Updated,'1/1/1900') THEN dbo.elapsedbusinessdays_2( educat.CreatedDate,educat.last_updated)  
	WHEN isnull(educat.last_worked,'1/1/1900') >= isnull(educat.last_updated,'1/1/1900') AND isnull(educat.last_worked,'1/1/1900') >= isnull(educat.Web_Updated,'1/1/1900') THEN dbo.elapsedbusinessdays_2( educat.CreatedDate,educat.last_worked) 
	WHEN isnull(educat.Web_Updated,'1/1/1900') >= isnull(educat.last_worked,'1/1/1900') AND isnull(educat.Web_Updated,'1/1/1900') >= isnull(educat.last_updated,'1/1/1900') THEN dbo.elapsedbusinessdays_2( educat.CreatedDate,educat.Web_Updated)
END) = 2
--group by clno
) as 'Count'
, CAST( 100. * (SELECT count(*) FROM educat with (NOLOCK)
	JOIN appl with (NOLOCK) on appl.apno = educat.apno
	WHERE 
(CASE  
	WHEN isnull(educat.last_updated,'1/1/1900') >= isnull(educat.last_worked,'1/1/1900') AND isnull(educat.last_updated,'1/1/1900') >= isnull(educat.Web_Updated,'1/1/1900') THEN educat.last_updated  
	WHEN isnull(educat.last_worked,'1/1/1900') >= isnull(educat.last_updated,'1/1/1900') AND isnull(educat.last_worked,'1/1/1900') >= isnull(educat.Web_Updated,'1/1/1900') THEN educat.last_worked 
	WHEN isnull(educat.Web_Updated,'1/1/1900') >= isnull(educat.last_worked,'1/1/1900') AND isnull(educat.Web_Updated,'1/1/1900') >= isnull(educat.last_updated,'1/1/1900') THEN educat.Web_Updated 
END)  >= @from_date AND
(CASE  
	WHEN isnull(educat.last_updated,'1/1/1900') >= isnull(educat.last_worked,'1/1/1900') AND isnull(educat.last_updated,'1/1/1900') >= isnull(educat.Web_Updated,'1/1/1900') THEN educat.last_updated  
	WHEN isnull(educat.last_worked,'1/1/1900') >= isnull(educat.last_updated,'1/1/1900') AND isnull(educat.last_worked,'1/1/1900') >= isnull(educat.Web_Updated,'1/1/1900') THEN educat.last_worked 
	WHEN isnull(educat.Web_Updated,'1/1/1900') >= isnull(educat.last_worked,'1/1/1900') AND isnull(educat.Web_Updated,'1/1/1900') >= isnull(educat.last_updated,'1/1/1900') THEN educat.Web_Updated 
END) < @to_date AND CLNO = @CLNO AND apstatus in ('W','F')
	AND  (CASE  
	WHEN isnull(educat.last_updated,'1/1/1900') >= isnull(educat.last_worked,'1/1/1900') AND isnull(educat.last_updated,'1/1/1900') >= isnull(educat.Web_Updated,'1/1/1900') THEN dbo.elapsedbusinessdays_2( educat.CreatedDate,educat.last_updated)  
	WHEN isnull(educat.last_worked,'1/1/1900') >= isnull(educat.last_updated,'1/1/1900') AND isnull(educat.last_worked,'1/1/1900') >= isnull(educat.Web_Updated,'1/1/1900') THEN dbo.elapsedbusinessdays_2( educat.CreatedDate,educat.last_worked) 
	WHEN isnull(educat.Web_Updated,'1/1/1900') >= isnull(educat.last_worked,'1/1/1900') AND isnull(educat.Web_Updated,'1/1/1900') >= isnull(educat.last_updated,'1/1/1900') THEN dbo.elapsedbusinessdays_2( educat.CreatedDate,educat.Web_Updated)
end) = 2 
--group by clno
	)  /
  (select count(educatid) from educat with (NOLOCK) JOIN appl with (NOLOCK) on appl.apno = educat.apno 
   where 
(CASE  
	WHEN isnull(educat.last_updated,'1/1/1900') >= isnull(educat.last_worked,'1/1/1900') AND isnull(educat.last_updated,'1/1/1900') >= isnull(educat.Web_Updated,'1/1/1900') THEN educat.last_updated  
	WHEN isnull(educat.last_worked,'1/1/1900') >= isnull(educat.last_updated,'1/1/1900') AND isnull(educat.last_worked,'1/1/1900') >= isnull(educat.Web_Updated,'1/1/1900') THEN educat.last_worked 
	WHEN isnull(educat.Web_Updated,'1/1/1900') >= isnull(educat.last_worked,'1/1/1900') AND isnull(educat.Web_Updated,'1/1/1900') >= isnull(educat.last_updated,'1/1/1900') THEN educat.Web_Updated 
END)  >= @from_date AND 
(CASE  
	WHEN isnull(educat.last_updated,'1/1/1900') >= isnull(educat.last_worked,'1/1/1900') AND isnull(educat.last_updated,'1/1/1900') >= isnull(educat.Web_Updated,'1/1/1900') THEN educat.last_updated  
	WHEN isnull(educat.last_worked,'1/1/1900') >= isnull(educat.last_updated,'1/1/1900') AND isnull(educat.last_worked,'1/1/1900') >= isnull(educat.Web_Updated,'1/1/1900') THEN educat.last_worked 
	WHEN isnull(educat.Web_Updated,'1/1/1900') >= isnull(educat.last_worked,'1/1/1900') AND isnull(educat.Web_Updated,'1/1/1900') >= isnull(educat.last_updated,'1/1/1900') THEN educat.Web_Updated 
END)  < @to_date AND CLNO = @CLNO AND apstatus in ('W','F')
  )AS NUMERIC( 5, 2 ) ) AS 'Percentage', 

CAST( 100. * (SELECT count(*) FROM educat with (NOLOCK)
	JOIN appl with (NOLOCK) on appl.apno = educat.apno
	WHERE 
(CASE  
	WHEN isnull(educat.last_updated,'1/1/1900') >= isnull(educat.last_worked,'1/1/1900') AND isnull(educat.last_updated,'1/1/1900') >= isnull(educat.Web_Updated,'1/1/1900') THEN educat.last_updated  
	WHEN isnull(educat.last_worked,'1/1/1900') >= isnull(educat.last_updated,'1/1/1900') AND isnull(educat.last_worked,'1/1/1900') >= isnull(educat.Web_Updated,'1/1/1900') THEN educat.last_worked 
	WHEN isnull(educat.Web_Updated,'1/1/1900') >= isnull(educat.last_worked,'1/1/1900') AND isnull(educat.Web_Updated,'1/1/1900') >= isnull(educat.last_updated,'1/1/1900') THEN educat.Web_Updated 
END)  >= @from_date AND 
(CASE  
	WHEN isnull(educat.last_updated,'1/1/1900') >= isnull(educat.last_worked,'1/1/1900') AND isnull(educat.last_updated,'1/1/1900') >= isnull(educat.Web_Updated,'1/1/1900') THEN educat.last_updated  
	WHEN isnull(educat.last_worked,'1/1/1900') >= isnull(educat.last_updated,'1/1/1900') AND isnull(educat.last_worked,'1/1/1900') >= isnull(educat.Web_Updated,'1/1/1900') THEN educat.last_worked 
	WHEN isnull(educat.Web_Updated,'1/1/1900') >= isnull(educat.last_worked,'1/1/1900') AND isnull(educat.Web_Updated,'1/1/1900') >= isnull(educat.last_updated,'1/1/1900') THEN educat.Web_Updated 
END)  < @to_date AND CLNO = @CLNO AND apstatus in ('W','F')
	AND  (CASE  
	WHEN isnull(educat.last_updated,'1/1/1900') >= isnull(educat.last_worked,'1/1/1900') AND isnull(educat.last_updated,'1/1/1900') >= isnull(educat.Web_Updated,'1/1/1900') THEN dbo.elapsedbusinessdays_2( educat.CreatedDate,educat.last_updated)  
	WHEN isnull(educat.last_worked,'1/1/1900') >= isnull(educat.last_updated,'1/1/1900') AND isnull(educat.last_worked,'1/1/1900') >= isnull(educat.Web_Updated,'1/1/1900') THEN dbo.elapsedbusinessdays_2( educat.CreatedDate,educat.last_worked) 
	WHEN isnull(educat.Web_Updated,'1/1/1900') >= isnull(educat.last_worked,'1/1/1900') AND isnull(educat.Web_Updated,'1/1/1900') >= isnull(educat.last_updated,'1/1/1900') THEN dbo.elapsedbusinessdays_2( educat.CreatedDate,educat.Web_Updated)
	END) <= 2
-- group by clno
	) / 
  (select count(educatid) from educat with (NOLOCK) JOIN appl with (NOLOCK) on appl.apno = educat.apno 
   where 
(CASE  
	WHEN isnull(educat.last_updated,'1/1/1900') >= isnull(educat.last_worked,'1/1/1900') AND isnull(educat.last_updated,'1/1/1900') >= isnull(educat.Web_Updated,'1/1/1900') THEN educat.last_updated  
	WHEN isnull(educat.last_worked,'1/1/1900') >= isnull(educat.last_updated,'1/1/1900') AND isnull(educat.last_worked,'1/1/1900') >= isnull(educat.Web_Updated,'1/1/1900') THEN educat.last_worked 
	WHEN isnull(educat.Web_Updated,'1/1/1900') >= isnull(educat.last_worked,'1/1/1900') AND isnull(educat.Web_Updated,'1/1/1900') >= isnull(educat.last_updated,'1/1/1900') THEN educat.Web_Updated 
END)  >= @from_date AND 
(CASE  
	WHEN isnull(educat.last_updated,'1/1/1900') >= isnull(educat.last_worked,'1/1/1900') AND isnull(educat.last_updated,'1/1/1900') >= isnull(educat.Web_Updated,'1/1/1900') THEN educat.last_updated  
	WHEN isnull(educat.last_worked,'1/1/1900') >= isnull(educat.last_updated,'1/1/1900') AND isnull(educat.last_worked,'1/1/1900') >= isnull(educat.Web_Updated,'1/1/1900') THEN educat.last_worked 
	WHEN isnull(educat.Web_Updated,'1/1/1900') >= isnull(educat.last_worked,'1/1/1900') AND isnull(educat.Web_Updated,'1/1/1900') >= isnull(educat.last_updated,'1/1/1900') THEN educat.Web_Updated 
END)  < @to_date AND CLNO = @CLNO AND apstatus in ('W','F')
  )AS NUMERIC( 5, 2 ) ) as 'Cumulative %'
FROM educat with (NOLOCK) JOIN appl with (NOLOCK) on appl.apno = educat.apno
WHERE  
(CASE  
	WHEN isnull(educat.last_updated,'1/1/1900') >= isnull(educat.last_worked,'1/1/1900') AND isnull(educat.last_updated,'1/1/1900') >= isnull(educat.Web_Updated,'1/1/1900') THEN educat.last_updated  
	WHEN isnull(educat.last_worked,'1/1/1900') >= isnull(educat.last_updated,'1/1/1900') AND isnull(educat.last_worked,'1/1/1900') >= isnull(educat.Web_Updated,'1/1/1900') THEN educat.last_worked 
	WHEN isnull(educat.Web_Updated,'1/1/1900') >= isnull(educat.last_worked,'1/1/1900') AND isnull(educat.Web_Updated,'1/1/1900') >= isnull(educat.last_updated,'1/1/1900') THEN educat.Web_Updated 
END)  >= @from_date AND 
(CASE  
	WHEN isnull(educat.last_updated,'1/1/1900') >= isnull(educat.last_worked,'1/1/1900') AND isnull(educat.last_updated,'1/1/1900') >= isnull(educat.Web_Updated,'1/1/1900') THEN educat.last_updated  
	WHEN isnull(educat.last_worked,'1/1/1900') >= isnull(educat.last_updated,'1/1/1900') AND isnull(educat.last_worked,'1/1/1900') >= isnull(educat.Web_Updated,'1/1/1900') THEN educat.last_worked 
	WHEN isnull(educat.Web_Updated,'1/1/1900') >= isnull(educat.last_worked,'1/1/1900') AND isnull(educat.Web_Updated,'1/1/1900') >= isnull(educat.last_updated,'1/1/1900') THEN educat.Web_Updated 
END) < @to_date AND  CLNO = @CLNO AND apstatus in ('W','F') 
--group by clno 

UNION
SELECT '1 day' AS 'Turnaround Time',( SELECT count(*) FROM educat with (NOLOCK)
JOIN appl with (NOLOCK) on appl.apno = educat.apno
WHERE
(CASE  
	WHEN isnull(educat.last_updated,'1/1/1900') >= isnull(educat.last_worked,'1/1/1900') AND isnull(educat.last_updated,'1/1/1900') >= isnull(educat.Web_Updated,'1/1/1900') THEN educat.last_updated   
	WHEN isnull(educat.last_worked,'1/1/1900') >= isnull(educat.last_updated,'1/1/1900') AND isnull(educat.last_worked,'1/1/1900') >= isnull(educat.Web_Updated,'1/1/1900') THEN educat.last_worked  
	WHEN isnull(educat.Web_Updated,'1/1/1900') >= isnull(educat.last_worked,'1/1/1900') AND isnull(educat.Web_Updated,'1/1/1900') >= isnull(educat.last_updated,'1/1/1900') THEN educat.Web_Updated  
END) >= @from_date
AND
(CASE  
	WHEN isnull(educat.last_updated,'1/1/1900') >= isnull(educat.last_worked,'1/1/1900') AND isnull(educat.last_updated,'1/1/1900') >= isnull(educat.Web_Updated,'1/1/1900') THEN educat.last_updated  
	WHEN isnull(educat.last_worked,'1/1/1900') >= isnull(educat.last_updated,'1/1/1900') AND isnull(educat.last_worked,'1/1/1900') >= isnull(educat.Web_Updated,'1/1/1900') THEN educat.last_worked 
	WHEN isnull(educat.Web_Updated,'1/1/1900') >= isnull(educat.last_worked,'1/1/1900') AND isnull(educat.Web_Updated,'1/1/1900') >= isnull(educat.last_updated,'1/1/1900') THEN educat.Web_Updated 
END)  < @to_date
AND CLNO = @CLNO
AND apstatus in ('W','F')
AND (CASE  
	WHEN isnull(educat.last_updated,'1/1/1900') >= isnull(educat.last_worked,'1/1/1900') AND isnull(educat.last_updated,'1/1/1900') >= isnull(educat.Web_Updated,'1/1/1900') THEN dbo.elapsedbusinessdays_2( educat.CreatedDate,educat.last_updated)  
	WHEN isnull(educat.last_worked,'1/1/1900') >= isnull(educat.last_updated,'1/1/1900') AND isnull(educat.last_worked,'1/1/1900') >= isnull(educat.Web_Updated,'1/1/1900') THEN dbo.elapsedbusinessdays_2( educat.CreatedDate,educat.last_worked) 
	WHEN isnull(educat.Web_Updated,'1/1/1900') >= isnull(educat.last_worked,'1/1/1900') AND isnull(educat.Web_Updated,'1/1/1900') >= isnull(educat.last_updated,'1/1/1900') THEN dbo.elapsedbusinessdays_2( educat.CreatedDate,educat.Web_Updated)
END) = 1
--group by clno
) as 'Count'
, CAST( 100. * (SELECT count(*) FROM educat with (NOLOCK)
	JOIN appl with (NOLOCK) on appl.apno = educat.apno
	WHERE 
(CASE  
	WHEN isnull(educat.last_updated,'1/1/1900') >= isnull(educat.last_worked,'1/1/1900') AND isnull(educat.last_updated,'1/1/1900') >= isnull(educat.Web_Updated,'1/1/1900') THEN educat.last_updated  
	WHEN isnull(educat.last_worked,'1/1/1900') >= isnull(educat.last_updated,'1/1/1900') AND isnull(educat.last_worked,'1/1/1900') >= isnull(educat.Web_Updated,'1/1/1900') THEN educat.last_worked 
	WHEN isnull(educat.Web_Updated,'1/1/1900') >= isnull(educat.last_worked,'1/1/1900') AND isnull(educat.Web_Updated,'1/1/1900') >= isnull(educat.last_updated,'1/1/1900') THEN educat.Web_Updated 
END)  >= @from_date AND
(CASE  
	WHEN isnull(educat.last_updated,'1/1/1900') >= isnull(educat.last_worked,'1/1/1900') AND isnull(educat.last_updated,'1/1/1900') >= isnull(educat.Web_Updated,'1/1/1900') THEN educat.last_updated  
	WHEN isnull(educat.last_worked,'1/1/1900') >= isnull(educat.last_updated,'1/1/1900') AND isnull(educat.last_worked,'1/1/1900') >= isnull(educat.Web_Updated,'1/1/1900') THEN educat.last_worked 
	WHEN isnull(educat.Web_Updated,'1/1/1900') >= isnull(educat.last_worked,'1/1/1900') AND isnull(educat.Web_Updated,'1/1/1900') >= isnull(educat.last_updated,'1/1/1900') THEN educat.Web_Updated 
END) < @to_date AND CLNO = @CLNO AND apstatus in ('W','F')
	AND  (CASE  
	WHEN isnull(educat.last_updated,'1/1/1900') >= isnull(educat.last_worked,'1/1/1900') AND isnull(educat.last_updated,'1/1/1900') >= isnull(educat.Web_Updated,'1/1/1900') THEN dbo.elapsedbusinessdays_2( educat.CreatedDate,educat.last_updated)  
	WHEN isnull(educat.last_worked,'1/1/1900') >= isnull(educat.last_updated,'1/1/1900') AND isnull(educat.last_worked,'1/1/1900') >= isnull(educat.Web_Updated,'1/1/1900') THEN dbo.elapsedbusinessdays_2( educat.CreatedDate,educat.last_worked) 
	WHEN isnull(educat.Web_Updated,'1/1/1900') >= isnull(educat.last_worked,'1/1/1900') AND isnull(educat.Web_Updated,'1/1/1900') >= isnull(educat.last_updated,'1/1/1900') THEN dbo.elapsedbusinessdays_2( educat.CreatedDate,educat.Web_Updated)
end) = 1
-- group by clno 
	)  /
  (select count(educatid) from educat with (NOLOCK) JOIN appl with (NOLOCK) on appl.apno = educat.apno 
   where 
(CASE  
	WHEN isnull(educat.last_updated,'1/1/1900') >= isnull(educat.last_worked,'1/1/1900') AND isnull(educat.last_updated,'1/1/1900') >= isnull(educat.Web_Updated,'1/1/1900') THEN educat.last_updated  
	WHEN isnull(educat.last_worked,'1/1/1900') >= isnull(educat.last_updated,'1/1/1900') AND isnull(educat.last_worked,'1/1/1900') >= isnull(educat.Web_Updated,'1/1/1900') THEN educat.last_worked 
	WHEN isnull(educat.Web_Updated,'1/1/1900') >= isnull(educat.last_worked,'1/1/1900') AND isnull(educat.Web_Updated,'1/1/1900') >= isnull(educat.last_updated,'1/1/1900') THEN educat.Web_Updated 
END)  >= @from_date AND 
(CASE  
	WHEN isnull(educat.last_updated,'1/1/1900') >= isnull(educat.last_worked,'1/1/1900') AND isnull(educat.last_updated,'1/1/1900') >= isnull(educat.Web_Updated,'1/1/1900') THEN educat.last_updated  
	WHEN isnull(educat.last_worked,'1/1/1900') >= isnull(educat.last_updated,'1/1/1900') AND isnull(educat.last_worked,'1/1/1900') >= isnull(educat.Web_Updated,'1/1/1900') THEN educat.last_worked 
	WHEN isnull(educat.Web_Updated,'1/1/1900') >= isnull(educat.last_worked,'1/1/1900') AND isnull(educat.Web_Updated,'1/1/1900') >= isnull(educat.last_updated,'1/1/1900') THEN educat.Web_Updated 
END)  < @to_date AND CLNO = @CLNO AND apstatus in ('W','F')
  )AS NUMERIC( 5, 2 ) ) AS 'Percentage',

CAST( 100. * (SELECT count(*) FROM educat with (NOLOCK)
	JOIN appl with (NOLOCK) on appl.apno = educat.apno
	WHERE 
(CASE  
	WHEN isnull(educat.last_updated,'1/1/1900') >= isnull(educat.last_worked,'1/1/1900') AND isnull(educat.last_updated,'1/1/1900') >= isnull(educat.Web_Updated,'1/1/1900') THEN educat.last_updated  
	WHEN isnull(educat.last_worked,'1/1/1900') >= isnull(educat.last_updated,'1/1/1900') AND isnull(educat.last_worked,'1/1/1900') >= isnull(educat.Web_Updated,'1/1/1900') THEN educat.last_worked 
	WHEN isnull(educat.Web_Updated,'1/1/1900') >= isnull(educat.last_worked,'1/1/1900') AND isnull(educat.Web_Updated,'1/1/1900') >= isnull(educat.last_updated,'1/1/1900') THEN educat.Web_Updated 
END)  >= @from_date AND 
(CASE  
	WHEN isnull(educat.last_updated,'1/1/1900') >= isnull(educat.last_worked,'1/1/1900') AND isnull(educat.last_updated,'1/1/1900') >= isnull(educat.Web_Updated,'1/1/1900') THEN educat.last_updated  
	WHEN isnull(educat.last_worked,'1/1/1900') >= isnull(educat.last_updated,'1/1/1900') AND isnull(educat.last_worked,'1/1/1900') >= isnull(educat.Web_Updated,'1/1/1900') THEN educat.last_worked 
	WHEN isnull(educat.Web_Updated,'1/1/1900') >= isnull(educat.last_worked,'1/1/1900') AND isnull(educat.Web_Updated,'1/1/1900') >= isnull(educat.last_updated,'1/1/1900') THEN educat.Web_Updated 
END)  < @to_date AND CLNO = @CLNO AND apstatus in ('W','F')
	AND  (CASE  
	WHEN isnull(educat.last_updated,'1/1/1900') >= isnull(educat.last_worked,'1/1/1900') AND isnull(educat.last_updated,'1/1/1900') >= isnull(educat.Web_Updated,'1/1/1900') THEN dbo.elapsedbusinessdays_2( educat.CreatedDate,educat.last_updated)  
	WHEN isnull(educat.last_worked,'1/1/1900') >= isnull(educat.last_updated,'1/1/1900') AND isnull(educat.last_worked,'1/1/1900') >= isnull(educat.Web_Updated,'1/1/1900') THEN dbo.elapsedbusinessdays_2( educat.CreatedDate,educat.last_worked) 
	WHEN isnull(educat.Web_Updated,'1/1/1900') >= isnull(educat.last_worked,'1/1/1900') AND isnull(educat.Web_Updated,'1/1/1900') >= isnull(educat.last_updated,'1/1/1900') THEN dbo.elapsedbusinessdays_2( educat.CreatedDate,educat.Web_Updated)
	END) <= 1 
--group by clno
	) / 
  (select count(educatid) from educat with (NOLOCK) JOIN appl with (NOLOCK) on appl.apno = educat.apno 
   where 
(CASE  
	WHEN isnull(educat.last_updated,'1/1/1900') >= isnull(educat.last_worked,'1/1/1900') AND isnull(educat.last_updated,'1/1/1900') >= isnull(educat.Web_Updated,'1/1/1900') THEN educat.last_updated  
	WHEN isnull(educat.last_worked,'1/1/1900') >= isnull(educat.last_updated,'1/1/1900') AND isnull(educat.last_worked,'1/1/1900') >= isnull(educat.Web_Updated,'1/1/1900') THEN educat.last_worked 
	WHEN isnull(educat.Web_Updated,'1/1/1900') >= isnull(educat.last_worked,'1/1/1900') AND isnull(educat.Web_Updated,'1/1/1900') >= isnull(educat.last_updated,'1/1/1900') THEN educat.Web_Updated 
END)  >= @from_date AND 
(CASE  
	WHEN isnull(educat.last_updated,'1/1/1900') >= isnull(educat.last_worked,'1/1/1900') AND isnull(educat.last_updated,'1/1/1900') >= isnull(educat.Web_Updated,'1/1/1900') THEN educat.last_updated  
	WHEN isnull(educat.last_worked,'1/1/1900') >= isnull(educat.last_updated,'1/1/1900') AND isnull(educat.last_worked,'1/1/1900') >= isnull(educat.Web_Updated,'1/1/1900') THEN educat.last_worked 
	WHEN isnull(educat.Web_Updated,'1/1/1900') >= isnull(educat.last_worked,'1/1/1900') AND isnull(educat.Web_Updated,'1/1/1900') >= isnull(educat.last_updated,'1/1/1900') THEN educat.Web_Updated 
END)  < @to_date AND CLNO = @CLNO AND apstatus in ('W','F')
  )AS NUMERIC( 5, 2 ) ) as 'Cumulative %'
FROM educat with (NOLOCK) JOIN appl with (NOLOCK) on appl.apno = educat.apno
WHERE  
(CASE  
	WHEN isnull(educat.last_updated,'1/1/1900') >= isnull(educat.last_worked,'1/1/1900') AND isnull(educat.last_updated,'1/1/1900') >= isnull(educat.Web_Updated,'1/1/1900') THEN educat.last_updated  
	WHEN isnull(educat.last_worked,'1/1/1900') >= isnull(educat.last_updated,'1/1/1900') AND isnull(educat.last_worked,'1/1/1900') >= isnull(educat.Web_Updated,'1/1/1900') THEN educat.last_worked 
	WHEN isnull(educat.Web_Updated,'1/1/1900') >= isnull(educat.last_worked,'1/1/1900') AND isnull(educat.Web_Updated,'1/1/1900') >= isnull(educat.last_updated,'1/1/1900') THEN educat.Web_Updated 
END)  >= @from_date AND 
(CASE  
	WHEN isnull(educat.last_updated,'1/1/1900') >= isnull(educat.last_worked,'1/1/1900') AND isnull(educat.last_updated,'1/1/1900') >= isnull(educat.Web_Updated,'1/1/1900') THEN educat.last_updated  
	WHEN isnull(educat.last_worked,'1/1/1900') >= isnull(educat.last_updated,'1/1/1900') AND isnull(educat.last_worked,'1/1/1900') >= isnull(educat.Web_Updated,'1/1/1900') THEN educat.last_worked 
	WHEN isnull(educat.Web_Updated,'1/1/1900') >= isnull(educat.last_worked,'1/1/1900') AND isnull(educat.Web_Updated,'1/1/1900') >= isnull(educat.last_updated,'1/1/1900') THEN educat.Web_Updated 
END) < @to_date AND  CLNO = @CLNO AND apstatus in ('W','F') 
--group by clno 

UNION

SELECT '3 days' AS 'Turnaround Time',( SELECT count(*) FROM educat with (NOLOCK)
JOIN appl with (NOLOCK) on appl.apno = educat.apno
WHERE
(CASE  
	WHEN isnull(educat.last_updated,'1/1/1900') >= isnull(educat.last_worked,'1/1/1900') AND isnull(educat.last_updated,'1/1/1900') >= isnull(educat.Web_Updated,'1/1/1900') THEN educat.last_updated   
	WHEN isnull(educat.last_worked,'1/1/1900') >= isnull(educat.last_updated,'1/1/1900') AND isnull(educat.last_worked,'1/1/1900') >= isnull(educat.Web_Updated,'1/1/1900') THEN educat.last_worked  
	WHEN isnull(educat.Web_Updated,'1/1/1900') >= isnull(educat.last_worked,'1/1/1900') AND isnull(educat.Web_Updated,'1/1/1900') >= isnull(educat.last_updated,'1/1/1900') THEN educat.Web_Updated  
END) >= @from_date
AND
(CASE  
	WHEN isnull(educat.last_updated,'1/1/1900') >= isnull(educat.last_worked,'1/1/1900') AND isnull(educat.last_updated,'1/1/1900') >= isnull(educat.Web_Updated,'1/1/1900') THEN educat.last_updated  
	WHEN isnull(educat.last_worked,'1/1/1900') >= isnull(educat.last_updated,'1/1/1900') AND isnull(educat.last_worked,'1/1/1900') >= isnull(educat.Web_Updated,'1/1/1900') THEN educat.last_worked 
	WHEN isnull(educat.Web_Updated,'1/1/1900') >= isnull(educat.last_worked,'1/1/1900') AND isnull(educat.Web_Updated,'1/1/1900') >= isnull(educat.last_updated,'1/1/1900') THEN educat.Web_Updated 
END)  < @to_date
AND CLNO = @CLNO AND apstatus in ('W','F')
AND apstatus in ('W','F')
AND (CASE  
	WHEN isnull(educat.last_updated,'1/1/1900') >= isnull(educat.last_worked,'1/1/1900') AND isnull(educat.last_updated,'1/1/1900') >= isnull(educat.Web_Updated,'1/1/1900') THEN dbo.elapsedbusinessdays_2( educat.CreatedDate,educat.last_updated)  
	WHEN isnull(educat.last_worked,'1/1/1900') >= isnull(educat.last_updated,'1/1/1900') AND isnull(educat.last_worked,'1/1/1900') >= isnull(educat.Web_Updated,'1/1/1900') THEN dbo.elapsedbusinessdays_2( educat.CreatedDate,educat.last_worked) 
	WHEN isnull(educat.Web_Updated,'1/1/1900') >= isnull(educat.last_worked,'1/1/1900') AND isnull(educat.Web_Updated,'1/1/1900') >= isnull(educat.last_updated,'1/1/1900') THEN dbo.elapsedbusinessdays_2( educat.CreatedDate,educat.Web_Updated)
END) = 3
--group by clno
) as 'Count'
, CAST( 100. * (SELECT count(*) FROM educat with (NOLOCK)
	JOIN appl with (NOLOCK) on appl.apno = educat.apno
	WHERE 
(CASE  
	WHEN isnull(educat.last_updated,'1/1/1900') >= isnull(educat.last_worked,'1/1/1900') AND isnull(educat.last_updated,'1/1/1900') >= isnull(educat.Web_Updated,'1/1/1900') THEN educat.last_updated  
	WHEN isnull(educat.last_worked,'1/1/1900') >= isnull(educat.last_updated,'1/1/1900') AND isnull(educat.last_worked,'1/1/1900') >= isnull(educat.Web_Updated,'1/1/1900') THEN educat.last_worked 
	WHEN isnull(educat.Web_Updated,'1/1/1900') >= isnull(educat.last_worked,'1/1/1900') AND isnull(educat.Web_Updated,'1/1/1900') >= isnull(educat.last_updated,'1/1/1900') THEN educat.Web_Updated 
END)  >= @from_date AND
(CASE  
	WHEN isnull(educat.last_updated,'1/1/1900') >= isnull(educat.last_worked,'1/1/1900') AND isnull(educat.last_updated,'1/1/1900') >= isnull(educat.Web_Updated,'1/1/1900') THEN educat.last_updated  
	WHEN isnull(educat.last_worked,'1/1/1900') >= isnull(educat.last_updated,'1/1/1900') AND isnull(educat.last_worked,'1/1/1900') >= isnull(educat.Web_Updated,'1/1/1900') THEN educat.last_worked 
	WHEN isnull(educat.Web_Updated,'1/1/1900') >= isnull(educat.last_worked,'1/1/1900') AND isnull(educat.Web_Updated,'1/1/1900') >= isnull(educat.last_updated,'1/1/1900') THEN educat.Web_Updated 
END) < @to_date AND CLNO = @CLNO AND apstatus in ('W','F')
	AND  (CASE  
	WHEN isnull(educat.last_updated,'1/1/1900') >= isnull(educat.last_worked,'1/1/1900') AND isnull(educat.last_updated,'1/1/1900') >= isnull(educat.Web_Updated,'1/1/1900') THEN dbo.elapsedbusinessdays_2( educat.CreatedDate,educat.last_updated)  
	WHEN isnull(educat.last_worked,'1/1/1900') >= isnull(educat.last_updated,'1/1/1900') AND isnull(educat.last_worked,'1/1/1900') >= isnull(educat.Web_Updated,'1/1/1900') THEN dbo.elapsedbusinessdays_2( educat.CreatedDate,educat.last_worked) 
	WHEN isnull(educat.Web_Updated,'1/1/1900') >= isnull(educat.last_worked,'1/1/1900') AND isnull(educat.Web_Updated,'1/1/1900') >= isnull(educat.last_updated,'1/1/1900') THEN dbo.elapsedbusinessdays_2( educat.CreatedDate,educat.Web_Updated)
end) = 3 
--group by clno
	)  /
  (select count(educatid) from educat with (NOLOCK) JOIN appl with (NOLOCK) on appl.apno = educat.apno 
   where 
(CASE  
	WHEN isnull(educat.last_updated,'1/1/1900') >= isnull(educat.last_worked,'1/1/1900') AND isnull(educat.last_updated,'1/1/1900') >= isnull(educat.Web_Updated,'1/1/1900') THEN educat.last_updated  
	WHEN isnull(educat.last_worked,'1/1/1900') >= isnull(educat.last_updated,'1/1/1900') AND isnull(educat.last_worked,'1/1/1900') >= isnull(educat.Web_Updated,'1/1/1900') THEN educat.last_worked 
	WHEN isnull(educat.Web_Updated,'1/1/1900') >= isnull(educat.last_worked,'1/1/1900') AND isnull(educat.Web_Updated,'1/1/1900') >= isnull(educat.last_updated,'1/1/1900') THEN educat.Web_Updated 
END)  >= @from_date AND 
(CASE  
	WHEN isnull(educat.last_updated,'1/1/1900') >= isnull(educat.last_worked,'1/1/1900') AND isnull(educat.last_updated,'1/1/1900') >= isnull(educat.Web_Updated,'1/1/1900') THEN educat.last_updated  
	WHEN isnull(educat.last_worked,'1/1/1900') >= isnull(educat.last_updated,'1/1/1900') AND isnull(educat.last_worked,'1/1/1900') >= isnull(educat.Web_Updated,'1/1/1900') THEN educat.last_worked 
	WHEN isnull(educat.Web_Updated,'1/1/1900') >= isnull(educat.last_worked,'1/1/1900') AND isnull(educat.Web_Updated,'1/1/1900') >= isnull(educat.last_updated,'1/1/1900') THEN educat.Web_Updated 
END)  < @to_date AND CLNO = @CLNO AND apstatus in ('W','F')
  )AS NUMERIC( 5, 2 ) ) AS 'Percentage', 

CAST( 100. * (SELECT count(*) FROM educat with (NOLOCK)
	JOIN appl with (NOLOCK) on appl.apno = educat.apno
	WHERE 
(CASE  
	WHEN isnull(educat.last_updated,'1/1/1900') >= isnull(educat.last_worked,'1/1/1900') AND isnull(educat.last_updated,'1/1/1900') >= isnull(educat.Web_Updated,'1/1/1900') THEN educat.last_updated  
	WHEN isnull(educat.last_worked,'1/1/1900') >= isnull(educat.last_updated,'1/1/1900') AND isnull(educat.last_worked,'1/1/1900') >= isnull(educat.Web_Updated,'1/1/1900') THEN educat.last_worked 
	WHEN isnull(educat.Web_Updated,'1/1/1900') >= isnull(educat.last_worked,'1/1/1900') AND isnull(educat.Web_Updated,'1/1/1900') >= isnull(educat.last_updated,'1/1/1900') THEN educat.Web_Updated 
END)  >= @from_date AND 
(CASE  
	WHEN isnull(educat.last_updated,'1/1/1900') >= isnull(educat.last_worked,'1/1/1900') AND isnull(educat.last_updated,'1/1/1900') >= isnull(educat.Web_Updated,'1/1/1900') THEN educat.last_updated  
	WHEN isnull(educat.last_worked,'1/1/1900') >= isnull(educat.last_updated,'1/1/1900') AND isnull(educat.last_worked,'1/1/1900') >= isnull(educat.Web_Updated,'1/1/1900') THEN educat.last_worked 
	WHEN isnull(educat.Web_Updated,'1/1/1900') >= isnull(educat.last_worked,'1/1/1900') AND isnull(educat.Web_Updated,'1/1/1900') >= isnull(educat.last_updated,'1/1/1900') THEN educat.Web_Updated 
END)  < @to_date AND CLNO = @CLNO AND apstatus in ('W','F')
	AND  (CASE  
	WHEN isnull(educat.last_updated,'1/1/1900') >= isnull(educat.last_worked,'1/1/1900') AND isnull(educat.last_updated,'1/1/1900') >= isnull(educat.Web_Updated,'1/1/1900') THEN dbo.elapsedbusinessdays_2( educat.CreatedDate,educat.last_updated)  
	WHEN isnull(educat.last_worked,'1/1/1900') >= isnull(educat.last_updated,'1/1/1900') AND isnull(educat.last_worked,'1/1/1900') >= isnull(educat.Web_Updated,'1/1/1900') THEN dbo.elapsedbusinessdays_2( educat.CreatedDate,educat.last_worked) 
	WHEN isnull(educat.Web_Updated,'1/1/1900') >= isnull(educat.last_worked,'1/1/1900') AND isnull(educat.Web_Updated,'1/1/1900') >= isnull(educat.last_updated,'1/1/1900') THEN dbo.elapsedbusinessdays_2( educat.CreatedDate,educat.Web_Updated)
	END) <=3
--group by clno
	) / 
  (select count(educatid) from educat with (NOLOCK) JOIN appl with (NOLOCK) on appl.apno = educat.apno 
   where 
(CASE  
	WHEN isnull(educat.last_updated,'1/1/1900') >= isnull(educat.last_worked,'1/1/1900') AND isnull(educat.last_updated,'1/1/1900') >= isnull(educat.Web_Updated,'1/1/1900') THEN educat.last_updated  
	WHEN isnull(educat.last_worked,'1/1/1900') >= isnull(educat.last_updated,'1/1/1900') AND isnull(educat.last_worked,'1/1/1900') >= isnull(educat.Web_Updated,'1/1/1900') THEN educat.last_worked 
	WHEN isnull(educat.Web_Updated,'1/1/1900') >= isnull(educat.last_worked,'1/1/1900') AND isnull(educat.Web_Updated,'1/1/1900') >= isnull(educat.last_updated,'1/1/1900') THEN educat.Web_Updated 
END)  >= @from_date AND 
(CASE  
	WHEN isnull(educat.last_updated,'1/1/1900') >= isnull(educat.last_worked,'1/1/1900') AND isnull(educat.last_updated,'1/1/1900') >= isnull(educat.Web_Updated,'1/1/1900') THEN educat.last_updated  
	WHEN isnull(educat.last_worked,'1/1/1900') >= isnull(educat.last_updated,'1/1/1900') AND isnull(educat.last_worked,'1/1/1900') >= isnull(educat.Web_Updated,'1/1/1900') THEN educat.last_worked 
	WHEN isnull(educat.Web_Updated,'1/1/1900') >= isnull(educat.last_worked,'1/1/1900') AND isnull(educat.Web_Updated,'1/1/1900') >= isnull(educat.last_updated,'1/1/1900') THEN educat.Web_Updated 
END)  < @to_date AND CLNO = @CLNO AND apstatus in ('W','F')
  )AS NUMERIC( 5, 2 ) ) as 'Cumulative %'
FROM educat with (NOLOCK) JOIN appl with (NOLOCK) on appl.apno = educat.apno
WHERE  
(CASE  
	WHEN isnull(educat.last_updated,'1/1/1900') >= isnull(educat.last_worked,'1/1/1900') AND isnull(educat.last_updated,'1/1/1900') >= isnull(educat.Web_Updated,'1/1/1900') THEN educat.last_updated  
	WHEN isnull(educat.last_worked,'1/1/1900') >= isnull(educat.last_updated,'1/1/1900') AND isnull(educat.last_worked,'1/1/1900') >= isnull(educat.Web_Updated,'1/1/1900') THEN educat.last_worked 
	WHEN isnull(educat.Web_Updated,'1/1/1900') >= isnull(educat.last_worked,'1/1/1900') AND isnull(educat.Web_Updated,'1/1/1900') >= isnull(educat.last_updated,'1/1/1900') THEN educat.Web_Updated 
END)  >= @from_date AND 
(CASE  
	WHEN isnull(educat.last_updated,'1/1/1900') >= isnull(educat.last_worked,'1/1/1900') AND isnull(educat.last_updated,'1/1/1900') >= isnull(educat.Web_Updated,'1/1/1900') THEN educat.last_updated  
	WHEN isnull(educat.last_worked,'1/1/1900') >= isnull(educat.last_updated,'1/1/1900') AND isnull(educat.last_worked,'1/1/1900') >= isnull(educat.Web_Updated,'1/1/1900') THEN educat.last_worked 
	WHEN isnull(educat.Web_Updated,'1/1/1900') >= isnull(educat.last_worked,'1/1/1900') AND isnull(educat.Web_Updated,'1/1/1900') >= isnull(educat.last_updated,'1/1/1900') THEN educat.Web_Updated 
END) < @to_date AND  CLNO = @CLNO AND apstatus in ('W','F') 
--group by clno 


UNION

SELECT '4 days' AS 'Turnaround Time',( SELECT count(*) FROM educat with (NOLOCK)
JOIN appl with (NOLOCK) on appl.apno = educat.apno
WHERE
(CASE  
	WHEN isnull(educat.last_updated,'1/1/1900') >= isnull(educat.last_worked,'1/1/1900') AND isnull(educat.last_updated,'1/1/1900') >= isnull(educat.Web_Updated,'1/1/1900') THEN educat.last_updated   
	WHEN isnull(educat.last_worked,'1/1/1900') >= isnull(educat.last_updated,'1/1/1900') AND isnull(educat.last_worked,'1/1/1900') >= isnull(educat.Web_Updated,'1/1/1900') THEN educat.last_worked  
	WHEN isnull(educat.Web_Updated,'1/1/1900') >= isnull(educat.last_worked,'1/1/1900') AND isnull(educat.Web_Updated,'1/1/1900') >= isnull(educat.last_updated,'1/1/1900') THEN educat.Web_Updated  
END) >= @from_date
AND
(CASE  
	WHEN isnull(educat.last_updated,'1/1/1900') >= isnull(educat.last_worked,'1/1/1900') AND isnull(educat.last_updated,'1/1/1900') >= isnull(educat.Web_Updated,'1/1/1900') THEN educat.last_updated  
	WHEN isnull(educat.last_worked,'1/1/1900') >= isnull(educat.last_updated,'1/1/1900') AND isnull(educat.last_worked,'1/1/1900') >= isnull(educat.Web_Updated,'1/1/1900') THEN educat.last_worked 
	WHEN isnull(educat.Web_Updated,'1/1/1900') >= isnull(educat.last_worked,'1/1/1900') AND isnull(educat.Web_Updated,'1/1/1900') >= isnull(educat.last_updated,'1/1/1900') THEN educat.Web_Updated 
END)  < @to_date
AND CLNO = @CLNO AND apstatus in ('W','F')
AND (CASE  
	WHEN isnull(educat.last_updated,'1/1/1900') >= isnull(educat.last_worked,'1/1/1900') AND isnull(educat.last_updated,'1/1/1900') >= isnull(educat.Web_Updated,'1/1/1900') THEN dbo.elapsedbusinessdays_2( educat.CreatedDate,educat.last_updated)  
	WHEN isnull(educat.last_worked,'1/1/1900') >= isnull(educat.last_updated,'1/1/1900') AND isnull(educat.last_worked,'1/1/1900') >= isnull(educat.Web_Updated,'1/1/1900') THEN dbo.elapsedbusinessdays_2( educat.CreatedDate,educat.last_worked) 
	WHEN isnull(educat.Web_Updated,'1/1/1900') >= isnull(educat.last_worked,'1/1/1900') AND isnull(educat.Web_Updated,'1/1/1900') >= isnull(educat.last_updated,'1/1/1900') THEN dbo.elapsedbusinessdays_2( educat.CreatedDate,educat.Web_Updated)
END) = 4
--group by clno
) as 'Count'
, CAST( 100. * (SELECT count(*) FROM educat with (NOLOCK)
	JOIN appl with (NOLOCK) on appl.apno = educat.apno
	WHERE 
(CASE  
	WHEN isnull(educat.last_updated,'1/1/1900') >= isnull(educat.last_worked,'1/1/1900') AND isnull(educat.last_updated,'1/1/1900') >= isnull(educat.Web_Updated,'1/1/1900') THEN educat.last_updated  
	WHEN isnull(educat.last_worked,'1/1/1900') >= isnull(educat.last_updated,'1/1/1900') AND isnull(educat.last_worked,'1/1/1900') >= isnull(educat.Web_Updated,'1/1/1900') THEN educat.last_worked 
	WHEN isnull(educat.Web_Updated,'1/1/1900') >= isnull(educat.last_worked,'1/1/1900') AND isnull(educat.Web_Updated,'1/1/1900') >= isnull(educat.last_updated,'1/1/1900') THEN educat.Web_Updated 
END)  >= @from_date AND
(CASE  
	WHEN isnull(educat.last_updated,'1/1/1900') >= isnull(educat.last_worked,'1/1/1900') AND isnull(educat.last_updated,'1/1/1900') >= isnull(educat.Web_Updated,'1/1/1900') THEN educat.last_updated  
	WHEN isnull(educat.last_worked,'1/1/1900') >= isnull(educat.last_updated,'1/1/1900') AND isnull(educat.last_worked,'1/1/1900') >= isnull(educat.Web_Updated,'1/1/1900') THEN educat.last_worked 
	WHEN isnull(educat.Web_Updated,'1/1/1900') >= isnull(educat.last_worked,'1/1/1900') AND isnull(educat.Web_Updated,'1/1/1900') >= isnull(educat.last_updated,'1/1/1900') THEN educat.Web_Updated 
END) < @to_date AND CLNO = @CLNO AND apstatus in ('W','F')
	AND  (CASE  
	WHEN isnull(educat.last_updated,'1/1/1900') >= isnull(educat.last_worked,'1/1/1900') AND isnull(educat.last_updated,'1/1/1900') >= isnull(educat.Web_Updated,'1/1/1900') THEN dbo.elapsedbusinessdays_2( educat.CreatedDate,educat.last_updated)  
	WHEN isnull(educat.last_worked,'1/1/1900') >= isnull(educat.last_updated,'1/1/1900') AND isnull(educat.last_worked,'1/1/1900') >= isnull(educat.Web_Updated,'1/1/1900') THEN dbo.elapsedbusinessdays_2( educat.CreatedDate,educat.last_worked) 
	WHEN isnull(educat.Web_Updated,'1/1/1900') >= isnull(educat.last_worked,'1/1/1900') AND isnull(educat.Web_Updated,'1/1/1900') >= isnull(educat.last_updated,'1/1/1900') THEN dbo.elapsedbusinessdays_2( educat.CreatedDate,educat.Web_Updated)
end) = 4 
--group by clno
	)  /
  (select count(educatid) from educat with (NOLOCK) JOIN appl with (NOLOCK) on appl.apno = educat.apno 
   where 
(CASE  
	WHEN isnull(educat.last_updated,'1/1/1900') >= isnull(educat.last_worked,'1/1/1900') AND isnull(educat.last_updated,'1/1/1900') >= isnull(educat.Web_Updated,'1/1/1900') THEN educat.last_updated  
	WHEN isnull(educat.last_worked,'1/1/1900') >= isnull(educat.last_updated,'1/1/1900') AND isnull(educat.last_worked,'1/1/1900') >= isnull(educat.Web_Updated,'1/1/1900') THEN educat.last_worked 
	WHEN isnull(educat.Web_Updated,'1/1/1900') >= isnull(educat.last_worked,'1/1/1900') AND isnull(educat.Web_Updated,'1/1/1900') >= isnull(educat.last_updated,'1/1/1900') THEN educat.Web_Updated 
END)  >= @from_date AND 
(CASE  
	WHEN isnull(educat.last_updated,'1/1/1900') >= isnull(educat.last_worked,'1/1/1900') AND isnull(educat.last_updated,'1/1/1900') >= isnull(educat.Web_Updated,'1/1/1900') THEN educat.last_updated  
	WHEN isnull(educat.last_worked,'1/1/1900') >= isnull(educat.last_updated,'1/1/1900') AND isnull(educat.last_worked,'1/1/1900') >= isnull(educat.Web_Updated,'1/1/1900') THEN educat.last_worked 
	WHEN isnull(educat.Web_Updated,'1/1/1900') >= isnull(educat.last_worked,'1/1/1900') AND isnull(educat.Web_Updated,'1/1/1900') >= isnull(educat.last_updated,'1/1/1900') THEN educat.Web_Updated 
END)  < @to_date AND CLNO = @CLNO AND apstatus in ('W','F')
  )AS NUMERIC( 5, 2 ) ) AS 'Percentage',

CAST( 100. * (SELECT count(*) FROM educat with (NOLOCK)
	JOIN appl with (NOLOCK) on appl.apno = educat.apno
	WHERE 
(CASE  
	WHEN isnull(educat.last_updated,'1/1/1900') >= isnull(educat.last_worked,'1/1/1900') AND isnull(educat.last_updated,'1/1/1900') >= isnull(educat.Web_Updated,'1/1/1900') THEN educat.last_updated  
	WHEN isnull(educat.last_worked,'1/1/1900') >= isnull(educat.last_updated,'1/1/1900') AND isnull(educat.last_worked,'1/1/1900') >= isnull(educat.Web_Updated,'1/1/1900') THEN educat.last_worked 
	WHEN isnull(educat.Web_Updated,'1/1/1900') >= isnull(educat.last_worked,'1/1/1900') AND isnull(educat.Web_Updated,'1/1/1900') >= isnull(educat.last_updated,'1/1/1900') THEN educat.Web_Updated 
END)  >= @from_date AND 
(CASE  
	WHEN isnull(educat.last_updated,'1/1/1900') >= isnull(educat.last_worked,'1/1/1900') AND isnull(educat.last_updated,'1/1/1900') >= isnull(educat.Web_Updated,'1/1/1900') THEN educat.last_updated  
	WHEN isnull(educat.last_worked,'1/1/1900') >= isnull(educat.last_updated,'1/1/1900') AND isnull(educat.last_worked,'1/1/1900') >= isnull(educat.Web_Updated,'1/1/1900') THEN educat.last_worked 
	WHEN isnull(educat.Web_Updated,'1/1/1900') >= isnull(educat.last_worked,'1/1/1900') AND isnull(educat.Web_Updated,'1/1/1900') >= isnull(educat.last_updated,'1/1/1900') THEN educat.Web_Updated 
END)  < @to_date AND CLNO = @CLNO AND apstatus in ('W','F')
	AND  (CASE  
	WHEN isnull(educat.last_updated,'1/1/1900') >= isnull(educat.last_worked,'1/1/1900') AND isnull(educat.last_updated,'1/1/1900') >= isnull(educat.Web_Updated,'1/1/1900') THEN dbo.elapsedbusinessdays_2( educat.CreatedDate,educat.last_updated)  
	WHEN isnull(educat.last_worked,'1/1/1900') >= isnull(educat.last_updated,'1/1/1900') AND isnull(educat.last_worked,'1/1/1900') >= isnull(educat.Web_Updated,'1/1/1900') THEN dbo.elapsedbusinessdays_2( educat.CreatedDate,educat.last_worked) 
	WHEN isnull(educat.Web_Updated,'1/1/1900') >= isnull(educat.last_worked,'1/1/1900') AND isnull(educat.Web_Updated,'1/1/1900') >= isnull(educat.last_updated,'1/1/1900') THEN dbo.elapsedbusinessdays_2( educat.CreatedDate,educat.Web_Updated)
	END) <= 4
-- group by clno
	) / 
  (select count(educatid) from educat with (NOLOCK) JOIN appl with (NOLOCK) on appl.apno = educat.apno 
   where 
(CASE  
	WHEN isnull(educat.last_updated,'1/1/1900') >= isnull(educat.last_worked,'1/1/1900') AND isnull(educat.last_updated,'1/1/1900') >= isnull(educat.Web_Updated,'1/1/1900') THEN educat.last_updated  
	WHEN isnull(educat.last_worked,'1/1/1900') >= isnull(educat.last_updated,'1/1/1900') AND isnull(educat.last_worked,'1/1/1900') >= isnull(educat.Web_Updated,'1/1/1900') THEN educat.last_worked 
	WHEN isnull(educat.Web_Updated,'1/1/1900') >= isnull(educat.last_worked,'1/1/1900') AND isnull(educat.Web_Updated,'1/1/1900') >= isnull(educat.last_updated,'1/1/1900') THEN educat.Web_Updated 
END)  >= @from_date AND 
(CASE  
	WHEN isnull(educat.last_updated,'1/1/1900') >= isnull(educat.last_worked,'1/1/1900') AND isnull(educat.last_updated,'1/1/1900') >= isnull(educat.Web_Updated,'1/1/1900') THEN educat.last_updated  
	WHEN isnull(educat.last_worked,'1/1/1900') >= isnull(educat.last_updated,'1/1/1900') AND isnull(educat.last_worked,'1/1/1900') >= isnull(educat.Web_Updated,'1/1/1900') THEN educat.last_worked 
	WHEN isnull(educat.Web_Updated,'1/1/1900') >= isnull(educat.last_worked,'1/1/1900') AND isnull(educat.Web_Updated,'1/1/1900') >= isnull(educat.last_updated,'1/1/1900') THEN educat.Web_Updated 
END)  < @to_date AND CLNO = @CLNO AND apstatus in ('W','F')
  )AS NUMERIC( 5, 2 ) ) as 'Cumulative %'
FROM educat with (NOLOCK) JOIN appl with (NOLOCK) on appl.apno = educat.apno
WHERE  
(CASE  
	WHEN isnull(educat.last_updated,'1/1/1900') >= isnull(educat.last_worked,'1/1/1900') AND isnull(educat.last_updated,'1/1/1900') >= isnull(educat.Web_Updated,'1/1/1900') THEN educat.last_updated  
	WHEN isnull(educat.last_worked,'1/1/1900') >= isnull(educat.last_updated,'1/1/1900') AND isnull(educat.last_worked,'1/1/1900') >= isnull(educat.Web_Updated,'1/1/1900') THEN educat.last_worked 
	WHEN isnull(educat.Web_Updated,'1/1/1900') >= isnull(educat.last_worked,'1/1/1900') AND isnull(educat.Web_Updated,'1/1/1900') >= isnull(educat.last_updated,'1/1/1900') THEN educat.Web_Updated 
END)  >= @from_date AND 
(CASE  
	WHEN isnull(educat.last_updated,'1/1/1900') >= isnull(educat.last_worked,'1/1/1900') AND isnull(educat.last_updated,'1/1/1900') >= isnull(educat.Web_Updated,'1/1/1900') THEN educat.last_updated  
	WHEN isnull(educat.last_worked,'1/1/1900') >= isnull(educat.last_updated,'1/1/1900') AND isnull(educat.last_worked,'1/1/1900') >= isnull(educat.Web_Updated,'1/1/1900') THEN educat.last_worked 
	WHEN isnull(educat.Web_Updated,'1/1/1900') >= isnull(educat.last_worked,'1/1/1900') AND isnull(educat.Web_Updated,'1/1/1900') >= isnull(educat.last_updated,'1/1/1900') THEN educat.Web_Updated 
END) < @to_date AND  CLNO = @CLNO AND apstatus in ('W','F') 
--group by clno 

UNION

SELECT '5 days' AS 'Turnaround Time',( SELECT count(*) FROM educat with (NOLOCK)
JOIN appl with (NOLOCK) on appl.apno = educat.apno
WHERE
(CASE  
	WHEN isnull(educat.last_updated,'1/1/1900') >= isnull(educat.last_worked,'1/1/1900') AND isnull(educat.last_updated,'1/1/1900') >= isnull(educat.Web_Updated,'1/1/1900') THEN educat.last_updated   
	WHEN isnull(educat.last_worked,'1/1/1900') >= isnull(educat.last_updated,'1/1/1900') AND isnull(educat.last_worked,'1/1/1900') >= isnull(educat.Web_Updated,'1/1/1900') THEN educat.last_worked  
	WHEN isnull(educat.Web_Updated,'1/1/1900') >= isnull(educat.last_worked,'1/1/1900') AND isnull(educat.Web_Updated,'1/1/1900') >= isnull(educat.last_updated,'1/1/1900') THEN educat.Web_Updated  
END) >= @from_date
AND
(CASE  
	WHEN isnull(educat.last_updated,'1/1/1900') >= isnull(educat.last_worked,'1/1/1900') AND isnull(educat.last_updated,'1/1/1900') >= isnull(educat.Web_Updated,'1/1/1900') THEN educat.last_updated  
	WHEN isnull(educat.last_worked,'1/1/1900') >= isnull(educat.last_updated,'1/1/1900') AND isnull(educat.last_worked,'1/1/1900') >= isnull(educat.Web_Updated,'1/1/1900') THEN educat.last_worked 
	WHEN isnull(educat.Web_Updated,'1/1/1900') >= isnull(educat.last_worked,'1/1/1900') AND isnull(educat.Web_Updated,'1/1/1900') >= isnull(educat.last_updated,'1/1/1900') THEN educat.Web_Updated 
END)  < @to_date
AND CLNO = @CLNO AND apstatus in ('W','F')
AND (CASE  
	WHEN isnull(educat.last_updated,'1/1/1900') >= isnull(educat.last_worked,'1/1/1900') AND isnull(educat.last_updated,'1/1/1900') >= isnull(educat.Web_Updated,'1/1/1900') THEN dbo.elapsedbusinessdays_2( educat.CreatedDate,educat.last_updated)  
	WHEN isnull(educat.last_worked,'1/1/1900') >= isnull(educat.last_updated,'1/1/1900') AND isnull(educat.last_worked,'1/1/1900') >= isnull(educat.Web_Updated,'1/1/1900') THEN dbo.elapsedbusinessdays_2( educat.CreatedDate,educat.last_worked) 
	WHEN isnull(educat.Web_Updated,'1/1/1900') >= isnull(educat.last_worked,'1/1/1900') AND isnull(educat.Web_Updated,'1/1/1900') >= isnull(educat.last_updated,'1/1/1900') THEN dbo.elapsedbusinessdays_2( educat.CreatedDate,educat.Web_Updated)
END) = 5
--group by clno
) as 'Count'
, CAST( 100. * (SELECT count(*) FROM educat with (NOLOCK)
	JOIN appl with (NOLOCK) on appl.apno = educat.apno
	WHERE 
(CASE  
	WHEN isnull(educat.last_updated,'1/1/1900') >= isnull(educat.last_worked,'1/1/1900') AND isnull(educat.last_updated,'1/1/1900') >= isnull(educat.Web_Updated,'1/1/1900') THEN educat.last_updated  
	WHEN isnull(educat.last_worked,'1/1/1900') >= isnull(educat.last_updated,'1/1/1900') AND isnull(educat.last_worked,'1/1/1900') >= isnull(educat.Web_Updated,'1/1/1900') THEN educat.last_worked 
	WHEN isnull(educat.Web_Updated,'1/1/1900') >= isnull(educat.last_worked,'1/1/1900') AND isnull(educat.Web_Updated,'1/1/1900') >= isnull(educat.last_updated,'1/1/1900') THEN educat.Web_Updated 
END)  >= @from_date AND
(CASE  
	WHEN isnull(educat.last_updated,'1/1/1900') >= isnull(educat.last_worked,'1/1/1900') AND isnull(educat.last_updated,'1/1/1900') >= isnull(educat.Web_Updated,'1/1/1900') THEN educat.last_updated  
	WHEN isnull(educat.last_worked,'1/1/1900') >= isnull(educat.last_updated,'1/1/1900') AND isnull(educat.last_worked,'1/1/1900') >= isnull(educat.Web_Updated,'1/1/1900') THEN educat.last_worked 
	WHEN isnull(educat.Web_Updated,'1/1/1900') >= isnull(educat.last_worked,'1/1/1900') AND isnull(educat.Web_Updated,'1/1/1900') >= isnull(educat.last_updated,'1/1/1900') THEN educat.Web_Updated 
END) < @to_date AND CLNO = @CLNO AND apstatus in ('W','F')
	AND  (CASE  
	WHEN isnull(educat.last_updated,'1/1/1900') >= isnull(educat.last_worked,'1/1/1900') AND isnull(educat.last_updated,'1/1/1900') >= isnull(educat.Web_Updated,'1/1/1900') THEN dbo.elapsedbusinessdays_2( educat.CreatedDate,educat.last_updated)  
	WHEN isnull(educat.last_worked,'1/1/1900') >= isnull(educat.last_updated,'1/1/1900') AND isnull(educat.last_worked,'1/1/1900') >= isnull(educat.Web_Updated,'1/1/1900') THEN dbo.elapsedbusinessdays_2( educat.CreatedDate,educat.last_worked) 
	WHEN isnull(educat.Web_Updated,'1/1/1900') >= isnull(educat.last_worked,'1/1/1900') AND isnull(educat.Web_Updated,'1/1/1900') >= isnull(educat.last_updated,'1/1/1900') THEN dbo.elapsedbusinessdays_2( educat.CreatedDate,educat.Web_Updated)
end) = 5 
--group by clno
	)  /
  (select count(educatid) from educat with (NOLOCK) JOIN appl with (NOLOCK) on appl.apno = educat.apno 
   where 
(CASE  
	WHEN isnull(educat.last_updated,'1/1/1900') >= isnull(educat.last_worked,'1/1/1900') AND isnull(educat.last_updated,'1/1/1900') >= isnull(educat.Web_Updated,'1/1/1900') THEN educat.last_updated  
	WHEN isnull(educat.last_worked,'1/1/1900') >= isnull(educat.last_updated,'1/1/1900') AND isnull(educat.last_worked,'1/1/1900') >= isnull(educat.Web_Updated,'1/1/1900') THEN educat.last_worked 
	WHEN isnull(educat.Web_Updated,'1/1/1900') >= isnull(educat.last_worked,'1/1/1900') AND isnull(educat.Web_Updated,'1/1/1900') >= isnull(educat.last_updated,'1/1/1900') THEN educat.Web_Updated 
END)  >= @from_date AND 
(CASE  
	WHEN isnull(educat.last_updated,'1/1/1900') >= isnull(educat.last_worked,'1/1/1900') AND isnull(educat.last_updated,'1/1/1900') >= isnull(educat.Web_Updated,'1/1/1900') THEN educat.last_updated  
	WHEN isnull(educat.last_worked,'1/1/1900') >= isnull(educat.last_updated,'1/1/1900') AND isnull(educat.last_worked,'1/1/1900') >= isnull(educat.Web_Updated,'1/1/1900') THEN educat.last_worked 
	WHEN isnull(educat.Web_Updated,'1/1/1900') >= isnull(educat.last_worked,'1/1/1900') AND isnull(educat.Web_Updated,'1/1/1900') >= isnull(educat.last_updated,'1/1/1900') THEN educat.Web_Updated 
END)  < @to_date AND CLNO = @CLNO AND apstatus in ('W','F')
  )AS NUMERIC( 5, 2 ) ) AS 'Percentage',

CAST( 100. * (SELECT count(*) FROM educat with (NOLOCK)
	JOIN appl with (NOLOCK) on appl.apno = educat.apno
	WHERE 
(CASE  
	WHEN isnull(educat.last_updated,'1/1/1900') >= isnull(educat.last_worked,'1/1/1900') AND isnull(educat.last_updated,'1/1/1900') >= isnull(educat.Web_Updated,'1/1/1900') THEN educat.last_updated  
	WHEN isnull(educat.last_worked,'1/1/1900') >= isnull(educat.last_updated,'1/1/1900') AND isnull(educat.last_worked,'1/1/1900') >= isnull(educat.Web_Updated,'1/1/1900') THEN educat.last_worked 
	WHEN isnull(educat.Web_Updated,'1/1/1900') >= isnull(educat.last_worked,'1/1/1900') AND isnull(educat.Web_Updated,'1/1/1900') >= isnull(educat.last_updated,'1/1/1900') THEN educat.Web_Updated 
END)  >= @from_date AND 
(CASE  
	WHEN isnull(educat.last_updated,'1/1/1900') >= isnull(educat.last_worked,'1/1/1900') AND isnull(educat.last_updated,'1/1/1900') >= isnull(educat.Web_Updated,'1/1/1900') THEN educat.last_updated  
	WHEN isnull(educat.last_worked,'1/1/1900') >= isnull(educat.last_updated,'1/1/1900') AND isnull(educat.last_worked,'1/1/1900') >= isnull(educat.Web_Updated,'1/1/1900') THEN educat.last_worked 
	WHEN isnull(educat.Web_Updated,'1/1/1900') >= isnull(educat.last_worked,'1/1/1900') AND isnull(educat.Web_Updated,'1/1/1900') >= isnull(educat.last_updated,'1/1/1900') THEN educat.Web_Updated 
END)  < @to_date AND CLNO = @CLNO AND apstatus in ('W','F')
	AND  (CASE  
	WHEN isnull(educat.last_updated,'1/1/1900') >= isnull(educat.last_worked,'1/1/1900') AND isnull(educat.last_updated,'1/1/1900') >= isnull(educat.Web_Updated,'1/1/1900') THEN dbo.elapsedbusinessdays_2( educat.CreatedDate,educat.last_updated)  
	WHEN isnull(educat.last_worked,'1/1/1900') >= isnull(educat.last_updated,'1/1/1900') AND isnull(educat.last_worked,'1/1/1900') >= isnull(educat.Web_Updated,'1/1/1900') THEN dbo.elapsedbusinessdays_2( educat.CreatedDate,educat.last_worked) 
	WHEN isnull(educat.Web_Updated,'1/1/1900') >= isnull(educat.last_worked,'1/1/1900') AND isnull(educat.Web_Updated,'1/1/1900') >= isnull(educat.last_updated,'1/1/1900') THEN dbo.elapsedbusinessdays_2( educat.CreatedDate,educat.Web_Updated)
	END) <= 5
-- group by clno
	) / 
  (select count(educatid) from educat with (NOLOCK) JOIN appl with (NOLOCK) on appl.apno = educat.apno 
   where 
(CASE  
	WHEN isnull(educat.last_updated,'1/1/1900') >= isnull(educat.last_worked,'1/1/1900') AND isnull(educat.last_updated,'1/1/1900') >= isnull(educat.Web_Updated,'1/1/1900') THEN educat.last_updated  
	WHEN isnull(educat.last_worked,'1/1/1900') >= isnull(educat.last_updated,'1/1/1900') AND isnull(educat.last_worked,'1/1/1900') >= isnull(educat.Web_Updated,'1/1/1900') THEN educat.last_worked 
	WHEN isnull(educat.Web_Updated,'1/1/1900') >= isnull(educat.last_worked,'1/1/1900') AND isnull(educat.Web_Updated,'1/1/1900') >= isnull(educat.last_updated,'1/1/1900') THEN educat.Web_Updated 
END)  >= @from_date AND 
(CASE  
	WHEN isnull(educat.last_updated,'1/1/1900') >= isnull(educat.last_worked,'1/1/1900') AND isnull(educat.last_updated,'1/1/1900') >= isnull(educat.Web_Updated,'1/1/1900') THEN educat.last_updated  
	WHEN isnull(educat.last_worked,'1/1/1900') >= isnull(educat.last_updated,'1/1/1900') AND isnull(educat.last_worked,'1/1/1900') >= isnull(educat.Web_Updated,'1/1/1900') THEN educat.last_worked 
	WHEN isnull(educat.Web_Updated,'1/1/1900') >= isnull(educat.last_worked,'1/1/1900') AND isnull(educat.Web_Updated,'1/1/1900') >= isnull(educat.last_updated,'1/1/1900') THEN educat.Web_Updated 
END)  < @to_date AND CLNO = @CLNO AND apstatus in ('W','F')
  )AS NUMERIC( 5, 2 ) ) as 'Cumulative %'
FROM educat with (NOLOCK) JOIN appl with (NOLOCK) on appl.apno = educat.apno
WHERE  
(CASE  
	WHEN isnull(educat.last_updated,'1/1/1900') >= isnull(educat.last_worked,'1/1/1900') AND isnull(educat.last_updated,'1/1/1900') >= isnull(educat.Web_Updated,'1/1/1900') THEN educat.last_updated  
	WHEN isnull(educat.last_worked,'1/1/1900') >= isnull(educat.last_updated,'1/1/1900') AND isnull(educat.last_worked,'1/1/1900') >= isnull(educat.Web_Updated,'1/1/1900') THEN educat.last_worked 
	WHEN isnull(educat.Web_Updated,'1/1/1900') >= isnull(educat.last_worked,'1/1/1900') AND isnull(educat.Web_Updated,'1/1/1900') >= isnull(educat.last_updated,'1/1/1900') THEN educat.Web_Updated 
END)  >= @from_date AND 
(CASE  
	WHEN isnull(educat.last_updated,'1/1/1900') >= isnull(educat.last_worked,'1/1/1900') AND isnull(educat.last_updated,'1/1/1900') >= isnull(educat.Web_Updated,'1/1/1900') THEN educat.last_updated  
	WHEN isnull(educat.last_worked,'1/1/1900') >= isnull(educat.last_updated,'1/1/1900') AND isnull(educat.last_worked,'1/1/1900') >= isnull(educat.Web_Updated,'1/1/1900') THEN educat.last_worked 
	WHEN isnull(educat.Web_Updated,'1/1/1900') >= isnull(educat.last_worked,'1/1/1900') AND isnull(educat.Web_Updated,'1/1/1900') >= isnull(educat.last_updated,'1/1/1900') THEN educat.Web_Updated 
END) < @to_date AND  CLNO = @CLNO AND apstatus in ('W','F') 
--group by clno 

UNION


SELECT '6+ days' AS 'Turnaround Time',( SELECT count(*) FROM educat with (NOLOCK)
JOIN appl with (NOLOCK) on appl.apno = educat.apno
WHERE
(CASE  
	WHEN isnull(educat.last_updated,'1/1/1900') >= isnull(educat.last_worked,'1/1/1900') AND isnull(educat.last_updated,'1/1/1900') >= isnull(educat.Web_Updated,'1/1/1900') THEN educat.last_updated   
	WHEN isnull(educat.last_worked,'1/1/1900') >= isnull(educat.last_updated,'1/1/1900') AND isnull(educat.last_worked,'1/1/1900') >= isnull(educat.Web_Updated,'1/1/1900') THEN educat.last_worked  
	WHEN isnull(educat.Web_Updated,'1/1/1900') >= isnull(educat.last_worked,'1/1/1900') AND isnull(educat.Web_Updated,'1/1/1900') >= isnull(educat.last_updated,'1/1/1900') THEN educat.Web_Updated  
END) >= @from_date
AND
(CASE  
	WHEN isnull(educat.last_updated,'1/1/1900') >= isnull(educat.last_worked,'1/1/1900') AND isnull(educat.last_updated,'1/1/1900') >= isnull(educat.Web_Updated,'1/1/1900') THEN educat.last_updated  
	WHEN isnull(educat.last_worked,'1/1/1900') >= isnull(educat.last_updated,'1/1/1900') AND isnull(educat.last_worked,'1/1/1900') >= isnull(educat.Web_Updated,'1/1/1900') THEN educat.last_worked 
	WHEN isnull(educat.Web_Updated,'1/1/1900') >= isnull(educat.last_worked,'1/1/1900') AND isnull(educat.Web_Updated,'1/1/1900') >= isnull(educat.last_updated,'1/1/1900') THEN educat.Web_Updated 
END)  < @to_date
AND CLNO = @CLNO
AND apstatus in ('W','F')
AND (CASE  
	WHEN isnull(educat.last_updated,'1/1/1900') >= isnull(educat.last_worked,'1/1/1900') AND isnull(educat.last_updated,'1/1/1900') >= isnull(educat.Web_Updated,'1/1/1900') THEN dbo.elapsedbusinessdays_2( educat.CreatedDate,educat.last_updated)  
	WHEN isnull(educat.last_worked,'1/1/1900') >= isnull(educat.last_updated,'1/1/1900') AND isnull(educat.last_worked,'1/1/1900') >= isnull(educat.Web_Updated,'1/1/1900') THEN dbo.elapsedbusinessdays_2( educat.CreatedDate,educat.last_worked) 
	WHEN isnull(educat.Web_Updated,'1/1/1900') >= isnull(educat.last_worked,'1/1/1900') AND isnull(educat.Web_Updated,'1/1/1900') >= isnull(educat.last_updated,'1/1/1900') THEN dbo.elapsedbusinessdays_2( educat.CreatedDate,educat.Web_Updated)
END) >=6
--group by clno
) as 'Count'
, CAST( 100. * (SELECT count(*) FROM educat with (NOLOCK)
	JOIN appl with (NOLOCK) on appl.apno = educat.apno
	WHERE 
(CASE  
	WHEN isnull(educat.last_updated,'1/1/1900') >= isnull(educat.last_worked,'1/1/1900') AND isnull(educat.last_updated,'1/1/1900') >= isnull(educat.Web_Updated,'1/1/1900') THEN educat.last_updated  
	WHEN isnull(educat.last_worked,'1/1/1900') >= isnull(educat.last_updated,'1/1/1900') AND isnull(educat.last_worked,'1/1/1900') >= isnull(educat.Web_Updated,'1/1/1900') THEN educat.last_worked 
	WHEN isnull(educat.Web_Updated,'1/1/1900') >= isnull(educat.last_worked,'1/1/1900') AND isnull(educat.Web_Updated,'1/1/1900') >= isnull(educat.last_updated,'1/1/1900') THEN educat.Web_Updated 
END)  >= @from_date AND
(CASE  
	WHEN isnull(educat.last_updated,'1/1/1900') >= isnull(educat.last_worked,'1/1/1900') AND isnull(educat.last_updated,'1/1/1900') >= isnull(educat.Web_Updated,'1/1/1900') THEN educat.last_updated  
	WHEN isnull(educat.last_worked,'1/1/1900') >= isnull(educat.last_updated,'1/1/1900') AND isnull(educat.last_worked,'1/1/1900') >= isnull(educat.Web_Updated,'1/1/1900') THEN educat.last_worked 
	WHEN isnull(educat.Web_Updated,'1/1/1900') >= isnull(educat.last_worked,'1/1/1900') AND isnull(educat.Web_Updated,'1/1/1900') >= isnull(educat.last_updated,'1/1/1900') THEN educat.Web_Updated 
END) < @to_date AND CLNO = @CLNO AND apstatus in ('W','F')
	AND  (CASE  
	WHEN isnull(educat.last_updated,'1/1/1900') >= isnull(educat.last_worked,'1/1/1900') AND isnull(educat.last_updated,'1/1/1900') >= isnull(educat.Web_Updated,'1/1/1900') THEN dbo.elapsedbusinessdays_2( educat.CreatedDate,educat.last_updated)  
	WHEN isnull(educat.last_worked,'1/1/1900') >= isnull(educat.last_updated,'1/1/1900') AND isnull(educat.last_worked,'1/1/1900') >= isnull(educat.Web_Updated,'1/1/1900') THEN dbo.elapsedbusinessdays_2( educat.CreatedDate,educat.last_worked) 
	WHEN isnull(educat.Web_Updated,'1/1/1900') >= isnull(educat.last_worked,'1/1/1900') AND isnull(educat.Web_Updated,'1/1/1900') >= isnull(educat.last_updated,'1/1/1900') THEN dbo.elapsedbusinessdays_2( educat.CreatedDate,educat.Web_Updated)
end) >=6 
--group by clno
	)  /
  (select count(educatid) from educat with (NOLOCK) JOIN appl with (NOLOCK) on appl.apno = educat.apno 
   where 
(CASE  
	WHEN isnull(educat.last_updated,'1/1/1900') >= isnull(educat.last_worked,'1/1/1900') AND isnull(educat.last_updated,'1/1/1900') >= isnull(educat.Web_Updated,'1/1/1900') THEN educat.last_updated  
	WHEN isnull(educat.last_worked,'1/1/1900') >= isnull(educat.last_updated,'1/1/1900') AND isnull(educat.last_worked,'1/1/1900') >= isnull(educat.Web_Updated,'1/1/1900') THEN educat.last_worked 
	WHEN isnull(educat.Web_Updated,'1/1/1900') >= isnull(educat.last_worked,'1/1/1900') AND isnull(educat.Web_Updated,'1/1/1900') >= isnull(educat.last_updated,'1/1/1900') THEN educat.Web_Updated 
END)  >= @from_date AND 
(CASE  
	WHEN isnull(educat.last_updated,'1/1/1900') >= isnull(educat.last_worked,'1/1/1900') AND isnull(educat.last_updated,'1/1/1900') >= isnull(educat.Web_Updated,'1/1/1900') THEN educat.last_updated  
	WHEN isnull(educat.last_worked,'1/1/1900') >= isnull(educat.last_updated,'1/1/1900') AND isnull(educat.last_worked,'1/1/1900') >= isnull(educat.Web_Updated,'1/1/1900') THEN educat.last_worked 
	WHEN isnull(educat.Web_Updated,'1/1/1900') >= isnull(educat.last_worked,'1/1/1900') AND isnull(educat.Web_Updated,'1/1/1900') >= isnull(educat.last_updated,'1/1/1900') THEN educat.Web_Updated 
END)  < @to_date AND CLNO = @CLNO AND apstatus in ('W','F')
  )AS NUMERIC( 5, 2 ) ) AS 'Percentage',

CAST( 100. * (SELECT count(*) FROM educat with (NOLOCK)
	JOIN appl with (NOLOCK) on appl.apno = educat.apno
	WHERE 
(CASE  
	WHEN isnull(educat.last_updated,'1/1/1900') >= isnull(educat.last_worked,'1/1/1900') AND isnull(educat.last_updated,'1/1/1900') >= isnull(educat.Web_Updated,'1/1/1900') THEN educat.last_updated  
	WHEN isnull(educat.last_worked,'1/1/1900') >= isnull(educat.last_updated,'1/1/1900') AND isnull(educat.last_worked,'1/1/1900') >= isnull(educat.Web_Updated,'1/1/1900') THEN educat.last_worked 
	WHEN isnull(educat.Web_Updated,'1/1/1900') >= isnull(educat.last_worked,'1/1/1900') AND isnull(educat.Web_Updated,'1/1/1900') >= isnull(educat.last_updated,'1/1/1900') THEN educat.Web_Updated 
END)  >= @from_date AND 
(CASE  
	WHEN isnull(educat.last_updated,'1/1/1900') >= isnull(educat.last_worked,'1/1/1900') AND isnull(educat.last_updated,'1/1/1900') >= isnull(educat.Web_Updated,'1/1/1900') THEN educat.last_updated  
	WHEN isnull(educat.last_worked,'1/1/1900') >= isnull(educat.last_updated,'1/1/1900') AND isnull(educat.last_worked,'1/1/1900') >= isnull(educat.Web_Updated,'1/1/1900') THEN educat.last_worked 
	WHEN isnull(educat.Web_Updated,'1/1/1900') >= isnull(educat.last_worked,'1/1/1900') AND isnull(educat.Web_Updated,'1/1/1900') >= isnull(educat.last_updated,'1/1/1900') THEN educat.Web_Updated 
END)  < @to_date AND CLNO = @CLNO AND apstatus in ('W','F')
	AND  (CASE  
	WHEN isnull(educat.last_updated,'1/1/1900') >= isnull(educat.last_worked,'1/1/1900') AND isnull(educat.last_updated,'1/1/1900') >= isnull(educat.Web_Updated,'1/1/1900') THEN dbo.elapsedbusinessdays_2( educat.CreatedDate,educat.last_updated)  
	WHEN isnull(educat.last_worked,'1/1/1900') >= isnull(educat.last_updated,'1/1/1900') AND isnull(educat.last_worked,'1/1/1900') >= isnull(educat.Web_Updated,'1/1/1900') THEN dbo.elapsedbusinessdays_2( educat.CreatedDate,educat.last_worked) 
	WHEN isnull(educat.Web_Updated,'1/1/1900') >= isnull(educat.last_worked,'1/1/1900') AND isnull(educat.Web_Updated,'1/1/1900') >= isnull(educat.last_updated,'1/1/1900') THEN dbo.elapsedbusinessdays_2( educat.CreatedDate,educat.Web_Updated)
	END) >=0 
--group by clno
	) / 
  (select count(educatid) from educat with (NOLOCK) JOIN appl with (NOLOCK) on appl.apno = educat.apno 
   where 
(CASE  
	WHEN isnull(educat.last_updated,'1/1/1900') >= isnull(educat.last_worked,'1/1/1900') AND isnull(educat.last_updated,'1/1/1900') >= isnull(educat.Web_Updated,'1/1/1900') THEN educat.last_updated  
	WHEN isnull(educat.last_worked,'1/1/1900') >= isnull(educat.last_updated,'1/1/1900') AND isnull(educat.last_worked,'1/1/1900') >= isnull(educat.Web_Updated,'1/1/1900') THEN educat.last_worked 
	WHEN isnull(educat.Web_Updated,'1/1/1900') >= isnull(educat.last_worked,'1/1/1900') AND isnull(educat.Web_Updated,'1/1/1900') >= isnull(educat.last_updated,'1/1/1900') THEN educat.Web_Updated 
END)  >= @from_date AND 
(CASE  
	WHEN isnull(educat.last_updated,'1/1/1900') >= isnull(educat.last_worked,'1/1/1900') AND isnull(educat.last_updated,'1/1/1900') >= isnull(educat.Web_Updated,'1/1/1900') THEN educat.last_updated  
	WHEN isnull(educat.last_worked,'1/1/1900') >= isnull(educat.last_updated,'1/1/1900') AND isnull(educat.last_worked,'1/1/1900') >= isnull(educat.Web_Updated,'1/1/1900') THEN educat.last_worked 
	WHEN isnull(educat.Web_Updated,'1/1/1900') >= isnull(educat.last_worked,'1/1/1900') AND isnull(educat.Web_Updated,'1/1/1900') >= isnull(educat.last_updated,'1/1/1900') THEN educat.Web_Updated 
END)  < @to_date AND CLNO = @CLNO AND apstatus in ('W','F')
  )AS NUMERIC( 5, 2 ) ) as 'Cumulative %'
FROM educat with (NOLOCK) JOIN appl with (NOLOCK) on appl.apno = educat.apno
WHERE  
(CASE  
	WHEN isnull(educat.last_updated,'1/1/1900') >= isnull(educat.last_worked,'1/1/1900') AND isnull(educat.last_updated,'1/1/1900') >= isnull(educat.Web_Updated,'1/1/1900') THEN educat.last_updated  
	WHEN isnull(educat.last_worked,'1/1/1900') >= isnull(educat.last_updated,'1/1/1900') AND isnull(educat.last_worked,'1/1/1900') >= isnull(educat.Web_Updated,'1/1/1900') THEN educat.last_worked 
	WHEN isnull(educat.Web_Updated,'1/1/1900') >= isnull(educat.last_worked,'1/1/1900') AND isnull(educat.Web_Updated,'1/1/1900') >= isnull(educat.last_updated,'1/1/1900') THEN educat.Web_Updated 
END)  >= @from_date AND 
(CASE  
	WHEN isnull(educat.last_updated,'1/1/1900') >= isnull(educat.last_worked,'1/1/1900') AND isnull(educat.last_updated,'1/1/1900') >= isnull(educat.Web_Updated,'1/1/1900') THEN educat.last_updated  
	WHEN isnull(educat.last_worked,'1/1/1900') >= isnull(educat.last_updated,'1/1/1900') AND isnull(educat.last_worked,'1/1/1900') >= isnull(educat.Web_Updated,'1/1/1900') THEN educat.last_worked 
	WHEN isnull(educat.Web_Updated,'1/1/1900') >= isnull(educat.last_worked,'1/1/1900') AND isnull(educat.Web_Updated,'1/1/1900') >= isnull(educat.last_updated,'1/1/1900') THEN educat.Web_Updated 
END) < @to_date AND  CLNO = @CLNO AND apstatus in ('W','F') 
--group by clno 

UNION

SELECT 'Total',
(select COUNT( educatid ) from educat with (NOLOCK) JOIN appl with (NOLOCK) on educat.apno = appl.apno
where 
(CASE  
	WHEN isnull(educat.last_updated,'1/1/1900') >= isnull(educat.last_worked,'1/1/1900') AND isnull(educat.last_updated,'1/1/1900') >= isnull(educat.Web_Updated,'1/1/1900') THEN educat.last_updated  
	WHEN isnull(educat.last_worked,'1/1/1900') >= isnull(educat.last_updated,'1/1/1900') AND isnull(educat.last_worked,'1/1/1900') >= isnull(educat.Web_Updated,'1/1/1900') THEN educat.last_worked 
	WHEN isnull(educat.Web_Updated,'1/1/1900') >= isnull(educat.last_worked,'1/1/1900') AND isnull(educat.Web_Updated,'1/1/1900') >= isnull(educat.last_updated,'1/1/1900') THEN educat.Web_Updated 
END) >= @from_date AND 
(CASE  
	WHEN isnull(educat.last_updated,'1/1/1900') >= isnull(educat.last_worked,'1/1/1900') AND isnull(educat.last_updated,'1/1/1900') >= isnull(educat.Web_Updated,'1/1/1900') THEN educat.last_updated  
	WHEN isnull(educat.last_worked,'1/1/1900') >= isnull(educat.last_updated,'1/1/1900') AND isnull(educat.last_worked,'1/1/1900') >= isnull(educat.Web_Updated,'1/1/1900') THEN educat.last_worked 
	WHEN isnull(educat.Web_Updated,'1/1/1900') >= isnull(educat.last_worked,'1/1/1900') AND isnull(educat.Web_Updated,'1/1/1900') >= isnull(educat.last_updated,'1/1/1900') THEN educat.Web_Updated 
END)  < @to_date AND CLNO = @CLNO  AND apstatus in ('W','F') 
--group by CLNO
), 100, 100
FROM educat with (NOLOCK) JOIN appl with (NOLOCK) on appl.apno = educat.apno
WHERE  
(CASE  
	WHEN isnull(educat.last_updated,'1/1/1900') >= isnull(educat.last_worked,'1/1/1900') AND isnull(educat.last_updated,'1/1/1900') >= isnull(educat.Web_Updated,'1/1/1900') THEN educat.last_updated  
	WHEN isnull(educat.last_worked,'1/1/1900') >= isnull(educat.last_updated,'1/1/1900') AND isnull(educat.last_worked,'1/1/1900') >= isnull(educat.Web_Updated,'1/1/1900') THEN educat.last_worked 
	WHEN isnull(educat.Web_Updated,'1/1/1900') >= isnull(educat.last_worked,'1/1/1900') AND isnull(educat.Web_Updated,'1/1/1900') >= isnull(educat.last_updated,'1/1/1900') THEN educat.Web_Updated 
END) >= @from_date AND 
(CASE  
	WHEN isnull(educat.last_updated,'1/1/1900') >= isnull(educat.last_worked,'1/1/1900') AND isnull(educat.last_updated,'1/1/1900') >= isnull(educat.Web_Updated,'1/1/1900') THEN educat.last_updated  
	WHEN isnull(educat.last_worked,'1/1/1900') >= isnull(educat.last_updated,'1/1/1900') AND isnull(educat.last_worked,'1/1/1900') >= isnull(educat.Web_Updated,'1/1/1900') THEN educat.last_worked 
	WHEN isnull(educat.Web_Updated,'1/1/1900') >= isnull(educat.last_worked,'1/1/1900') AND isnull(educat.Web_Updated,'1/1/1900') >= isnull(educat.last_updated,'1/1/1900') THEN educat.Web_Updated 
END)< @to_date AND  CLNO = @CLNO AND apstatus in ('W','F') 
--group by clno
END --end of educat section


if ( @section = 'Criminal')
BEGIN
 
SELECT '0 Day' AS 'Turnaround Time',( SELECT count(*) FROM Crim with (NOLOCK)
JOIN appl with (NOLOCK) on appl.apno = Crim.apno
WHERE Crim.last_updated >= @from_date AND Crim.last_updated < @to_date AND CLNO = @CLNO AND apstatus in ('W','F')
AND  dbo.elapsedbusinessdays_2( Crim.Crimenteredtime, Crim.last_updated ) = 0
--group by clno
) as 'Count',
CAST( 100. * (SELECT count(*) FROM Crim with (NOLOCK)
	JOIN appl with (NOLOCK) on appl.apno = Crim.apno
	WHERE Crim.Last_updated >= @from_date AND Crim.Last_updated < @to_date AND CLNO = @CLNO AND apstatus in ('W','F')
	AND  dbo.elapsedbusinessdays_2( Crim.Crimenteredtime, Crim.Last_updated ) = 0 
--group by clno
	)  /
  (select count(CrimID) from Crim with (NOLOCK) JOIN appl with (NOLOCK) on appl.apno = Crim.apno 
   where Crim.Last_updated >= @from_date AND Crim.Last_updated < @to_date AND CLNO = @CLNO AND apstatus in ('W','F')
  )AS NUMERIC( 5, 2 ) ) AS 'Percentage',
CAST( 100. * (SELECT count(*) FROM Crim with (NOLOCK)
	JOIN appl with (NOLOCK) on appl.apno = Crim.apno
	WHERE Crim.Last_updated >= @from_date AND Crim.Last_updated < @to_date AND CLNO = @CLNO AND apstatus in ('W','F')
	AND  dbo.elapsedbusinessdays_2( Crim.Crimenteredtime, Crim.Last_updated  ) = 0 
--group by clno
	) / 
  (select count(CrimId) from Crim with (NOLOCK) JOIN appl with (NOLOCK) on appl.apno = Crim.apno 
   where  Crim.Last_updated >= @from_date AND  Crim.Last_updated < @to_date AND CLNO = @CLNO AND apstatus in ('W','F')
  )AS NUMERIC( 5, 2 ) ) as 'Cumulative %'

FROM Crim with (NOLOCK) JOIN appl with (NOLOCK) on appl.apno = Crim.apno
WHERE   Crim.Last_updated>= @from_date AND  Crim.Last_updated < @to_date AND  CLNO = @CLNO AND apstatus in ('W','F') 

--group by clno

UNION

SELECT '1 Day' AS 'Turnaround Time',( SELECT count(*) FROM Crim with (NOLOCK)
JOIN appl with (NOLOCK) on appl.apno = Crim.apno
WHERE Crim.last_updated >= @from_date AND Crim.last_updated < @to_date AND CLNO = @CLNO AND apstatus in ('W','F')
AND  dbo.elapsedbusinessdays_2( Crim.Crimenteredtime, Crim.last_updated ) = 1
--group by clno
) as 'Count',
CAST( 100. * (SELECT count(*) FROM Crim with (NOLOCK)
	JOIN appl with (NOLOCK) on appl.apno = Crim.apno
	WHERE Crim.Last_updated >= @from_date AND Crim.Last_updated < @to_date AND CLNO = @CLNO AND apstatus in ('W','F')
	AND  dbo.elapsedbusinessdays_2( Crim.Crimenteredtime, Crim.Last_updated ) = 1
-- group by clno
	)  /
  (select count(CrimID) from Crim with (NOLOCK) JOIN appl with (NOLOCK) on appl.apno = Crim.apno 
   where Crim.Last_updated >= @from_date AND Crim.Last_updated < @to_date AND CLNO = @CLNO AND apstatus in ('W','F')
  )AS NUMERIC( 5, 2 ) ) AS 'Percentage',
CAST( 100. * (SELECT count(*) FROM Crim with (NOLOCK)
	JOIN appl with (NOLOCK) on appl.apno = Crim.apno
	WHERE Crim.Last_updated >= @from_date AND Crim.Last_updated < @to_date AND CLNO = @CLNO AND apstatus in ('W','F')
	AND  dbo.elapsedbusinessdays_2( Crim.Crimenteredtime, Crim.Last_updated  ) <= 1 
--group by clno
	) / 
  (select count(CrimId) from Crim with (NOLOCK) JOIN appl with (NOLOCK) on appl.apno = Crim.apno 
   where  Crim.Last_updated >= @from_date AND  Crim.Last_updated < @to_date AND CLNO = @CLNO AND apstatus in ('W','F')
  )AS NUMERIC( 5, 2 ) ) as 'Cumulative %'

FROM Crim with (NOLOCK) JOIN appl with (NOLOCK) on appl.apno = Crim.apno
WHERE   Crim.Last_updated>= @from_date AND  Crim.Last_updated < @to_date AND  CLNO = @CLNO AND apstatus in ('W','F') 
--group by clno

UNION

SELECT '2 Days' AS 'Turnaround Time',( SELECT count(*) FROM Crim with (NOLOCK)
JOIN appl with (NOLOCK) on appl.apno = Crim.apno
WHERE Crim.last_updated >= @from_date AND Crim.last_updated < @to_date AND CLNO = @CLNO AND apstatus in ('W','F')
AND  dbo.elapsedbusinessdays_2( Crim.Crimenteredtime, Crim.last_updated ) = 2
--group by clno
) as 'Count',
CAST( 100. * (SELECT count(*) FROM Crim with (NOLOCK)
	JOIN appl with (NOLOCK) on appl.apno = Crim.apno
	WHERE Crim.Last_updated >= @from_date AND Crim.Last_updated < @to_date AND CLNO = @CLNO AND apstatus in ('W','F')
	AND  dbo.elapsedbusinessdays_2( Crim.Crimenteredtime, Crim.Last_updated ) = 2 
--group by clno
	)  /
  (select count(CrimID) from Crim with (NOLOCK) JOIN appl with (NOLOCK) on appl.apno = Crim.apno 
   where Crim.Last_updated >= @from_date AND Crim.Last_updated < @to_date AND CLNO = @CLNO AND apstatus in ('W','F')
  )AS NUMERIC( 5, 2 ) ) AS 'Percentage',
CAST( 100. * (SELECT count(*) FROM Crim with (NOLOCK)
	JOIN appl with (NOLOCK) on appl.apno = Crim.apno
	WHERE Crim.Last_updated >= @from_date AND Crim.Last_updated < @to_date AND CLNO = @CLNO AND apstatus in ('W','F')
	AND  dbo.elapsedbusinessdays_2( Crim.Crimenteredtime, Crim.Last_updated  ) <= 2 
--group by clno
	) / 
  (select count(CrimId) from Crim with (NOLOCK) JOIN appl with (NOLOCK) on appl.apno = Crim.apno 
   where  Crim.Last_updated >= @from_date AND  Crim.Last_updated < @to_date AND CLNO = @CLNO AND apstatus in ('W','F')
  )AS NUMERIC( 5, 2 ) ) as 'Cumulative %'

FROM Crim with (NOLOCK) JOIN appl with (NOLOCK) on appl.apno = Crim.apno
WHERE   Crim.Last_updated>= @from_date AND  Crim.Last_updated < @to_date AND  CLNO = @CLNO AND apstatus in ('W','F') 
--group by clno

UNION

SELECT '3 Days' AS 'Turnaround Time',( SELECT count(*) FROM Crim with (NOLOCK)
JOIN appl with (NOLOCK) on appl.apno = Crim.apno
WHERE Crim.last_updated >= @from_date AND Crim.last_updated < @to_date AND CLNO = @CLNO AND apstatus in ('W','F')
AND  dbo.elapsedbusinessdays_2( Crim.Crimenteredtime, Crim.last_updated ) = 3
--group by clno
) as 'Count',
CAST( 100. * (SELECT count(*) FROM Crim with (NOLOCK)
	JOIN appl with (NOLOCK) on appl.apno = Crim.apno
	WHERE Crim.Last_updated >= @from_date AND Crim.Last_updated < @to_date AND CLNO = @CLNO AND apstatus in ('W','F')
	AND  dbo.elapsedbusinessdays_2( Crim.Crimenteredtime, Crim.Last_updated ) = 3
-- group by clno
	)  /
  (select count(CrimID) from Crim with (NOLOCK) JOIN appl with (NOLOCK) on appl.apno = Crim.apno 
   where Crim.Last_updated >= @from_date AND Crim.Last_updated < @to_date AND CLNO = @CLNO AND apstatus in ('W','F')
  )AS NUMERIC( 5, 2 ) ) AS 'Percentage',
CAST( 100. * (SELECT count(*) FROM Crim with (NOLOCK)
	JOIN appl with (NOLOCK) on appl.apno = Crim.apno
	WHERE Crim.Last_updated >= @from_date AND Crim.Last_updated < @to_date AND CLNO = @CLNO AND apstatus in ('W','F')
	AND  dbo.elapsedbusinessdays_2( Crim.Crimenteredtime, Crim.Last_updated  ) <= 3 
--group by clno
	) / 
  (select count(CrimId) from Crim with (NOLOCK) JOIN appl with (NOLOCK) on appl.apno = Crim.apno 
   where  Crim.Last_updated >= @from_date AND  Crim.Last_updated < @to_date AND CLNO = @CLNO AND apstatus in ('W','F')
  )AS NUMERIC( 5, 2 ) ) as 'Cumulative %'

FROM Crim with (NOLOCK) JOIN appl with (NOLOCK) on appl.apno = Crim.apno
WHERE   Crim.Last_updated>= @from_date AND  Crim.Last_updated < @to_date AND  CLNO = @CLNO AND apstatus in ('W','F') 
--group by clno


UNION

SELECT '4 Days' AS 'Turnaround Time',( SELECT count(*) FROM Crim with (NOLOCK)
JOIN appl with (NOLOCK) on appl.apno = Crim.apno
WHERE Crim.last_updated >= @from_date AND Crim.last_updated < @to_date AND CLNO = @CLNO AND apstatus in ('W','F')
AND  dbo.elapsedbusinessdays_2( Crim.Crimenteredtime, Crim.last_updated ) = 4
--group by clno
) as 'Count',
CAST( 100. * (SELECT count(*) FROM Crim with (NOLOCK)
	JOIN appl with (NOLOCK) on appl.apno = Crim.apno
	WHERE Crim.Last_updated >= @from_date AND Crim.Last_updated < @to_date AND CLNO = @CLNO AND apstatus in ('W','F')
	AND  dbo.elapsedbusinessdays_2( Crim.Crimenteredtime, Crim.Last_updated ) = 4
-- group by clno
	)  /
  (select count(CrimID) from Crim with (NOLOCK) JOIN appl with (NOLOCK) on appl.apno = Crim.apno 
   where Crim.Last_updated >= @from_date AND Crim.Last_updated < @to_date AND CLNO = @CLNO AND apstatus in ('W','F')
  )AS NUMERIC( 5, 2 ) ) AS 'Percentage',
CAST( 100. * (SELECT count(*) FROM Crim with (NOLOCK)
	JOIN appl with (NOLOCK) on appl.apno = Crim.apno
	WHERE Crim.Last_updated >= @from_date AND Crim.Last_updated < @to_date AND CLNO = @CLNO AND apstatus in ('W','F')
	AND  dbo.elapsedbusinessdays_2( Crim.Crimenteredtime, Crim.Last_updated  ) <= 4 
--group by clno
	) / 
  (select count(CrimId) from Crim with (NOLOCK) JOIN appl with (NOLOCK) on appl.apno = Crim.apno 
   where  Crim.Last_updated >= @from_date AND  Crim.Last_updated < @to_date AND CLNO = @CLNO AND apstatus in ('W','F')
  )AS NUMERIC( 5, 2 ) ) as 'Cumulative %'

FROM Crim with (NOLOCK) JOIN appl with (NOLOCK) on appl.apno = Crim.apno
WHERE   Crim.Last_updated>= @from_date AND  Crim.Last_updated < @to_date AND  CLNO = @CLNO AND apstatus in ('W','F') 
--group by clno

UNION

SELECT '5 Days' AS 'Turnaround Time',( SELECT count(*) FROM Crim with (NOLOCK)
JOIN appl with (NOLOCK) on appl.apno = Crim.apno
WHERE Crim.last_updated >= @from_date AND Crim.last_updated < @to_date AND CLNO = @CLNO AND apstatus in ('W','F')
AND  dbo.elapsedbusinessdays_2( Crim.Crimenteredtime, Crim.last_updated ) = 5
--group by clno
) as 'Count',
CAST( 100. * (SELECT count(*) FROM Crim with (NOLOCK)
	JOIN appl with (NOLOCK) on appl.apno = Crim.apno
	WHERE Crim.Last_updated >= @from_date AND Crim.Last_updated < @to_date AND CLNO = @CLNO AND apstatus in ('W','F')
	AND  dbo.elapsedbusinessdays_2( Crim.Crimenteredtime, Crim.Last_updated ) = 5
-- group by clno
	)  /
  (select count(CrimID) from Crim with (NOLOCK) JOIN appl with (NOLOCK) on appl.apno = Crim.apno 
   where Crim.Last_updated >= @from_date AND Crim.Last_updated < @to_date AND CLNO = @CLNO AND apstatus in ('W','F')
  )AS NUMERIC( 5, 2 ) ) AS 'Percentage',
CAST( 100. * (SELECT count(*) FROM Crim with (NOLOCK)
	JOIN appl with (NOLOCK) on appl.apno = Crim.apno
	WHERE Crim.Last_updated >= @from_date AND Crim.Last_updated < @to_date AND CLNO = @CLNO AND apstatus in ('W','F')
	AND  dbo.elapsedbusinessdays_2( Crim.Crimenteredtime, Crim.Last_updated  ) <= 5 
--group by clno
	) / 
  (select count(CrimId) from Crim with (NOLOCK) JOIN appl with (NOLOCK) on appl.apno = Crim.apno 
   where  Crim.Last_updated >= @from_date AND  Crim.Last_updated < @to_date AND CLNO = @CLNO AND apstatus in ('W','F')
  )AS NUMERIC( 5, 2 ) ) as 'Cumulative %'

FROM Crim with (NOLOCK) JOIN appl with (NOLOCK) on appl.apno = Crim.apno
WHERE   Crim.Last_updated>= @from_date AND  Crim.Last_updated < @to_date AND  CLNO = @CLNO AND apstatus in ('W','F') 
--group by clno

UNION

SELECT '6+ Day' AS 'Turnaround Time',( SELECT count(*) FROM Crim with (NOLOCK)
JOIN appl with (NOLOCK) on appl.apno = Crim.apno
WHERE Crim.Last_updated >= @from_date AND Crim.Last_updated < @to_date AND CLNO = @CLNO AND apstatus in ('W','F')
AND  dbo.elapsedbusinessdays_2( Crim.Crimenteredtime, Crim.Last_updated ) >= 6
--group by clno
) as 'Count',

CAST( 100. * (SELECT count(*) FROM Crim with (NOLOCK)
	JOIN appl with (NOLOCK) on appl.apno = crim.apno
	WHERE Crim.Last_updated >= @from_date AND Crim.Last_updated < @to_date AND CLNO = @CLNO AND apstatus in ('W','F')
	AND  dbo.elapsedbusinessdays_2( Crim.Crimenteredtime, Crim.Last_updated ) >= 6
-- group by clno
	)  /
  (select count(crimid) from crim with (NOLOCK) JOIN appl with (NOLOCK) on appl.apno = crim.apno 
   where Crim.Last_updated >= @from_date AND Crim.Last_updated < @to_date AND CLNO = @CLNO AND apstatus in ('W','F')
  )AS NUMERIC( 5, 2 ) ) AS 'Percentage',

CAST( 100. * (SELECT count(*) FROM crim with (NOLOCK)
	JOIN appl with (NOLOCK) on appl.apno = crim.apno
	WHERE Crim.Last_updated >= @from_date AND Crim.Last_updated < @to_date AND CLNO = @CLNO AND apstatus in ('W','F')
	AND  dbo.elapsedbusinessdays_2( Crim.Crimenteredtime, Crim.Last_updated   )  >=0
-- group by clno
	) / 
  (select count(crimid) from crim with (NOLOCK) JOIN appl with (NOLOCK) on appl.apno =crim.apno 
   where Crim.Last_updated >= @from_date AND Crim.Last_updated < @to_date AND CLNO = @CLNO AND apstatus in ('W','F')
  )AS NUMERIC( 5, 2 ) ) as 'Cumulative %'

FROM crim with (NOLOCK) JOIN appl with (NOLOCK) on appl.apno = crim.apno
WHERE  Crim.Last_updated >= @from_date AND Crim.Last_updated < @to_date AND  CLNO = @CLNO AND apstatus in ('W','F') 
--group by clno

UNION

SELECT 'Total',
(select COUNT( crimid ) from crim with (NOLOCK) join appl with (NOLOCK) on crim.apno = appl.apno
where Crim.Last_updated  >= @from_date and Crim.Last_updated  < @to_date and CLNO = @CLNO  AND apstatus in ('W','F')
--group by CLNO
), 100, 100
FROM Crim with (NOLOCK) JOIN appl with (NOLOCK) on appl.apno = Crim.apno
WHERE  Crim.Last_updated >= @from_date AND Crim.Last_updated < @to_date AND  CLNO = @CLNO AND apstatus in ('W','F') 
--group by clno

END -- end of criminal section



if ( @section = 'Licenses')
BEGIN
 
SELECT '0 Day' AS 'Turnaround Time',( SELECT count(*) FROM profLic with (NOLOCK)
JOIN appl with (NOLOCK) on appl.apno = profLic.apno
WHERE ProfLic.Last_updated >= @from_date AND ProfLic.Last_updated < @to_date AND CLNO = @CLNO AND apstatus in ('W','F')
AND  dbo.elapsedbusinessdays_2( ProfLic.createdDate, ProfLic.Last_updated ) = 0
--group by clno
) as 'Count',
CAST( 100. * (SELECT count(*) FROM ProfLic with (NOLOCK)
	JOIN appl with (NOLOCK) on appl.apno = Proflic.apno
	WHERE ProfLic.Last_updated >= @from_date AND ProfLic.Last_updated < @to_date AND CLNO = @CLNO AND apstatus in ('W','F')
	AND  dbo.elapsedbusinessdays_2( ProfLic.createdDate, ProfLic.Last_updated ) = 0-- group by clno
	)  /
  (select count(ProfLicID) from Proflic with (NOLOCK) JOIN appl with (NOLOCK) on appl.apno = Proflic.apno 
   where ProfLic.Last_updated >= @from_date AND ProfLic.Last_updated < @to_date AND CLNO = @CLNO AND apstatus in ('W','F')
  )AS NUMERIC( 5, 2 ) ) AS 'Percentage',
CAST( 100. * (SELECT count(*) FROM Proflic with (NOLOCK)
	JOIN appl with (NOLOCK) on appl.apno = proflic.apno
	WHERE ProfLic.Last_updated >= @from_date AND ProfLic.Last_updated < @to_date AND CLNO = @CLNO AND apstatus in ('W','F')
	AND  dbo.elapsedbusinessdays_2(ProfLic.createdDate, ProfLic.Last_updated  ) = 0-- group by clno
	) / 
  (select count(ProfLicID) from proflic with (NOLOCK) JOIN appl with (NOLOCK) on appl.apno = ProfLic.apno 
   where  ProfLic.Last_updated >= @from_date AND  ProfLic.Last_updated< @to_date AND CLNO = @CLNO AND apstatus in ('W','F')
  )AS NUMERIC( 5, 2 ) ) as 'Cumulative %'

FROM ProfLic with (NOLOCK) JOIN appl with (NOLOCK) on appl.apno = ProfLic.apno
WHERE   ProfLic.Last_updated>= @from_date AND  ProfLic.Last_updated < @to_date AND  CLNO = @CLNO AND apstatus in ('W','F') 

--group by clno

UNION

SELECT '1 Day' AS 'Turnaround Time',( SELECT count(*) FROM profLic with (NOLOCK)
JOIN appl with (NOLOCK) on appl.apno = profLic.apno
WHERE ProfLic.Last_updated >= @from_date AND ProfLic.Last_updated < @to_date AND CLNO = @CLNO AND apstatus in ('W','F')
AND  dbo.elapsedbusinessdays_2( ProfLic.createdDate, ProfLic.Last_updated ) = 1
--group by clno
) as 'Count',
CAST( 100. * (SELECT count(*) FROM ProfLic with (NOLOCK)
	JOIN appl with (NOLOCK) on appl.apno = Proflic.apno
	WHERE ProfLic.Last_updated >= @from_date AND ProfLic.Last_updated < @to_date AND CLNO = @CLNO AND apstatus in ('W','F')
	AND  dbo.elapsedbusinessdays_2( ProfLic.createdDate, ProfLic.Last_updated ) = 1-- group by clno
	)  /
  (select count(ProfLicID) from Proflic with (NOLOCK) JOIN appl with (NOLOCK) on appl.apno = Proflic.apno 
   where ProfLic.Last_updated >= @from_date AND ProfLic.Last_updated < @to_date AND CLNO = @CLNO AND apstatus in ('W','F')
  )AS NUMERIC( 5, 2 ) ) AS 'Percentage',
CAST( 100. * (SELECT count(*) FROM Proflic with (NOLOCK)
	JOIN appl with (NOLOCK) on appl.apno = proflic.apno
	WHERE ProfLic.Last_updated >= @from_date AND ProfLic.Last_updated < @to_date AND CLNO = @CLNO AND apstatus in ('W','F')
	AND  dbo.elapsedbusinessdays_2(ProfLic.createdDate, ProfLic.Last_updated  ) <= 1 --group by clno
	) / 
  (select count(ProfLicID) from proflic with (NOLOCK) JOIN appl with (NOLOCK) on appl.apno = ProfLic.apno 
   where  ProfLic.Last_updated >= @from_date AND  ProfLic.Last_updated< @to_date AND CLNO = @CLNO AND apstatus in ('W','F')
  )AS NUMERIC( 5, 2 ) ) as 'Cumulative %'

FROM ProfLic with (NOLOCK) JOIN appl with (NOLOCK) on appl.apno = ProfLic.apno
WHERE   ProfLic.Last_updated>= @from_date AND  ProfLic.Last_updated < @to_date AND  CLNO = @CLNO AND apstatus in ('W','F') 
--group by clno


UNION

SELECT '2 Days' AS 'Turnaround Time',( SELECT count(*) FROM profLic with (NOLOCK)
JOIN appl with (NOLOCK) on appl.apno = profLic.apno
WHERE ProfLic.Last_updated >= @from_date AND ProfLic.Last_updated < @to_date AND CLNO = @CLNO AND apstatus in ('W','F')
AND  dbo.elapsedbusinessdays_2( ProfLic.createdDate, ProfLic.Last_updated ) = 2
--group by clno
) as 'Count',
CAST( 100. * (SELECT count(*) FROM ProfLic with (NOLOCK)
	JOIN appl with (NOLOCK) on appl.apno = Proflic.apno
	WHERE ProfLic.Last_updated >= @from_date AND ProfLic.Last_updated < @to_date AND CLNO = @CLNO AND apstatus in ('W','F')
	AND  dbo.elapsedbusinessdays_2( ProfLic.createdDate, ProfLic.Last_updated ) = 2 --group by clno
	)  /
  (select count(ProfLicID) from Proflic with (NOLOCK) JOIN appl with (NOLOCK) on appl.apno = Proflic.apno 
   where ProfLic.Last_updated >= @from_date AND ProfLic.Last_updated < @to_date AND CLNO = @CLNO AND apstatus in ('W','F')
  )AS NUMERIC( 5, 2 ) ) AS 'Percentage',
CAST( 100. * (SELECT count(*) FROM Proflic with (NOLOCK)
	JOIN appl with (NOLOCK) on appl.apno = proflic.apno
	WHERE ProfLic.Last_updated >= @from_date AND ProfLic.Last_updated < @to_date AND CLNO = @CLNO AND apstatus in ('W','F')
	AND  dbo.elapsedbusinessdays_2(ProfLic.createdDate, ProfLic.Last_updated  ) <= 2 --group by clno
	) / 
  (select count(ProfLicID) from proflic with (NOLOCK) JOIN appl with (NOLOCK) on appl.apno = ProfLic.apno 
   where  ProfLic.Last_updated >= @from_date AND  ProfLic.Last_updated< @to_date AND CLNO = @CLNO AND apstatus in ('W','F')
  )AS NUMERIC( 5, 2 ) ) as 'Cumulative %'

FROM ProfLic with (NOLOCK) JOIN appl with (NOLOCK) on appl.apno = ProfLic.apno
WHERE   ProfLic.Last_updated>= @from_date AND  ProfLic.Last_updated < @to_date AND  CLNO = @CLNO AND apstatus in ('W','F') 
--group by clno

UNION

SELECT '3 Days' AS 'Turnaround Time',( SELECT count(*) FROM profLic with (NOLOCK)
JOIN appl with (NOLOCK) on appl.apno = profLic.apno
WHERE ProfLic.Last_updated >= @from_date AND ProfLic.Last_updated < @to_date AND CLNO = @CLNO AND apstatus in ('W','F')
AND  dbo.elapsedbusinessdays_2( ProfLic.createdDate, ProfLic.Last_updated ) = 3
--group by clno
) as 'Count',
CAST( 100. * (SELECT count(*) FROM ProfLic with (NOLOCK)
	JOIN appl with (NOLOCK) on appl.apno = Proflic.apno
	WHERE ProfLic.Last_updated >= @from_date AND ProfLic.Last_updated < @to_date AND CLNO = @CLNO AND apstatus in ('W','F')
	AND  dbo.elapsedbusinessdays_2( ProfLic.createdDate, ProfLic.Last_updated ) = 3 
--group by clno
	)  /
  (select count(ProfLicID) from Proflic with (NOLOCK) JOIN appl with (NOLOCK) on appl.apno = Proflic.apno 
   where ProfLic.Last_updated >= @from_date AND ProfLic.Last_updated < @to_date AND CLNO = @CLNO AND apstatus in ('W','F')
  )AS NUMERIC( 5, 2 ) ) AS 'Percentage',
CAST( 100. * (SELECT count(*) FROM Proflic with (NOLOCK)
	JOIN appl with (NOLOCK) on appl.apno = proflic.apno
	WHERE ProfLic.Last_updated >= @from_date AND ProfLic.Last_updated < @to_date AND CLNO = @CLNO AND apstatus in ('W','F')
	AND  dbo.elapsedbusinessdays_2(ProfLic.createdDate, ProfLic.Last_updated  ) <= 3 --group by clno
	) / 
  (select count(ProfLicID) from proflic with (NOLOCK) JOIN appl with (NOLOCK) on appl.apno = ProfLic.apno 
   where  ProfLic.Last_updated >= @from_date AND  ProfLic.Last_updated< @to_date AND CLNO = @CLNO AND apstatus in ('W','F')
  )AS NUMERIC( 5, 2 ) ) as 'Cumulative %'

FROM ProfLic with (NOLOCK) JOIN appl with (NOLOCK) on appl.apno = ProfLic.apno
WHERE   ProfLic.Last_updated>= @from_date AND  ProfLic.Last_updated < @to_date AND  CLNO = @CLNO AND apstatus in ('W','F') 
--group by clno



UNION

SELECT '4 Days' AS 'Turnaround Time',( SELECT count(*) FROM profLic with (NOLOCK)
JOIN appl with (NOLOCK) on appl.apno = profLic.apno
WHERE ProfLic.Last_updated >= @from_date AND ProfLic.Last_updated < @to_date AND CLNO = @CLNO AND apstatus in ('W','F')
AND  dbo.elapsedbusinessdays_2( ProfLic.createdDate, ProfLic.Last_updated ) = 4
--group by clno
) as 'Count',
CAST( 100. * (SELECT count(*) FROM ProfLic with (NOLOCK)
	JOIN appl on appl.apno = Proflic.apno
	WHERE ProfLic.Last_updated >= @from_date AND ProfLic.Last_updated < @to_date AND CLNO = @CLNO AND apstatus in ('W','F')
	AND  dbo.elapsedbusinessdays_2( ProfLic.createdDate, ProfLic.Last_updated ) = 4 
--group by clno
	)  /
  (select count(ProfLicID) from Proflic with (NOLOCK) JOIN appl with (NOLOCK) on appl.apno = Proflic.apno 
   where ProfLic.Last_updated >= @from_date AND ProfLic.Last_updated < @to_date AND CLNO = @CLNO AND apstatus in ('W','F')
  )AS NUMERIC( 5, 2 ) ) AS 'Percentage',
CAST( 100. * (SELECT count(*) FROM Proflic with (NOLOCK)
	JOIN appl with (NOLOCK) on appl.apno = proflic.apno
	WHERE ProfLic.Last_updated >= @from_date AND ProfLic.Last_updated < @to_date AND CLNO = @CLNO AND apstatus in ('W','F')
	AND  dbo.elapsedbusinessdays_2(ProfLic.createdDate, ProfLic.Last_updated  ) <= 4 --group by clno
	) / 
  (select count(ProfLicID) from proflic with (NOLOCK) JOIN appl with (NOLOCK) on appl.apno = ProfLic.apno 
   where  ProfLic.Last_updated >= @from_date AND  ProfLic.Last_updated< @to_date AND CLNO = @CLNO AND apstatus in ('W','F')
  )AS NUMERIC( 5, 2 ) ) as 'Cumulative %'

FROM ProfLic with (NOLOCK) JOIN appl with (NOLOCK) on appl.apno = ProfLic.apno
WHERE   ProfLic.Last_updated>= @from_date AND  ProfLic.Last_updated < @to_date AND  CLNO = @CLNO AND apstatus in ('W','F') 
--group by clno

UNION

SELECT '5 Days' AS 'Turnaround Time',( SELECT count(*) FROM profLic with (NOLOCK)
JOIN appl with (NOLOCK) on appl.apno = profLic.apno
WHERE ProfLic.Last_updated >= @from_date AND ProfLic.Last_updated < @to_date AND CLNO = @CLNO AND apstatus in ('W','F')
AND  dbo.elapsedbusinessdays_2( ProfLic.createdDate, ProfLic.Last_updated ) = 5
--group by clno
) as 'Count',
CAST( 100. * (SELECT count(*) FROM ProfLic with (NOLOCK)
	JOIN appl on appl.apno = Proflic.apno
	WHERE ProfLic.Last_updated >= @from_date AND ProfLic.Last_updated < @to_date AND CLNO = @CLNO AND apstatus in ('W','F')
	AND  dbo.elapsedbusinessdays_2( ProfLic.createdDate, ProfLic.Last_updated ) = 5 
--group by clno
	)  /
  (select count(ProfLicID) from Proflic with (NOLOCK) JOIN appl with (NOLOCK) on appl.apno = Proflic.apno 
   where ProfLic.Last_updated >= @from_date AND ProfLic.Last_updated < @to_date AND CLNO = @CLNO AND apstatus in ('W','F')
  )AS NUMERIC( 5, 2 ) ) AS 'Percentage',
CAST( 100. * (SELECT count(*) FROM Proflic with (NOLOCK)
	JOIN appl with (NOLOCK) on appl.apno = proflic.apno
	WHERE ProfLic.Last_updated >= @from_date AND ProfLic.Last_updated < @to_date AND CLNO = @CLNO AND apstatus in ('W','F')
	AND  dbo.elapsedbusinessdays_2(ProfLic.createdDate, ProfLic.Last_updated  ) <= 5 --group by clno
	) / 
  (select count(ProfLicID) from proflic with (NOLOCK) JOIN appl with (NOLOCK) on appl.apno = ProfLic.apno 
   where  ProfLic.Last_updated >= @from_date AND  ProfLic.Last_updated< @to_date AND CLNO = @CLNO AND apstatus in ('W','F')
  )AS NUMERIC( 5, 2 ) ) as 'Cumulative %'

FROM ProfLic with (NOLOCK) JOIN appl with (NOLOCK) on appl.apno = ProfLic.apno
WHERE   ProfLic.Last_updated>= @from_date AND  ProfLic.Last_updated < @to_date AND  CLNO = @CLNO AND apstatus in ('W','F') 
--group by clno

UNION

SELECT '6 Days+' AS 'Turnaround Time',( SELECT count(*) FROM profLic with (NOLOCK)
JOIN appl with (NOLOCK) on appl.apno = profLic.apno
WHERE ProfLic.Last_updated >= @from_date AND ProfLic.Last_updated < @to_date AND CLNO = @CLNO AND apstatus in ('W','F')
AND  dbo.elapsedbusinessdays_2( ProfLic.createdDate, ProfLic.Last_updated ) >=6
--group by clno
) as 'Count',
CAST( 100. * (SELECT count(*) FROM ProfLic with (NOLOCK)
	JOIN appl with (NOLOCK) on appl.apno = Proflic.apno
	WHERE ProfLic.Last_updated >= @from_date AND ProfLic.Last_updated < @to_date AND CLNO = @CLNO AND apstatus in ('W','F')
	AND  dbo.elapsedbusinessdays_2( ProfLic.createdDate, ProfLic.Last_updated ) >=6
-- group by clno
	)  /
  (select count(ProfLicID) from Proflic with (NOLOCK) JOIN appl with (NOLOCK) on appl.apno = Proflic.apno 
   where ProfLic.Last_updated >= @from_date AND ProfLic.Last_updated < @to_date AND CLNO = @CLNO AND apstatus in ('W','F')
  )AS NUMERIC( 5, 2 ) ) AS 'Percentage',
CAST( 100. * (SELECT count(*) FROM Proflic with (NOLOCK)
	JOIN appl with (NOLOCK) on appl.apno = proflic.apno
	WHERE ProfLic.Last_updated >= @from_date AND ProfLic.Last_updated < @to_date AND CLNO = @CLNO AND apstatus in ('W','F')
	AND  dbo.elapsedbusinessdays_2(ProfLic.createdDate, ProfLic.Last_updated  ) >=0 --group by clno
	) / 
  (select count(ProfLicID) from proflic with (NOLOCK) JOIN appl with (NOLOCK) on appl.apno = ProfLic.apno 
   where  ProfLic.Last_updated >= @from_date AND  ProfLic.Last_updated< @to_date AND CLNO = @CLNO AND apstatus in ('W','F')
  )AS NUMERIC( 5, 2 ) ) as 'Cumulative %'

FROM ProfLic with (NOLOCK) JOIN appl with (NOLOCK) on appl.apno = ProfLic.apno
WHERE   ProfLic.Last_updated>= @from_date AND  ProfLic.Last_updated < @to_date AND  CLNO = @CLNO AND apstatus in ('W','F') 
--group by clno

UNION

SELECT 'Total',
(select COUNT( ProfLicID ) from ProfLic with (NOLOCK) join appl with (NOLOCK) on ProfLic.apno = appl.apno
where ProfLic.Last_updated  >= @from_date and profLic.Last_updated  < @to_date and CLNO = @CLNO  AND apstatus in ('W','F')
--group by CLNO
), 100, 100
FROM ProfLic with (NOLOCK) JOIN appl with (NOLOCK) on appl.apno = ProfLic.apno
WHERE  ProfLic.Last_updated >= @from_date AND profLic.Last_updated < @to_date AND  CLNO = @CLNO AND apstatus in ('W','F') 
--group by clno

END -- end of License section

--//from here veena 07/07/2008
IF @section = 'PersonalReference'
BEGIN
SELECT '0 days' AS 'Turnaround Time',( SELECT count(*) FROM PersRef with (NOLOCK)
JOIN appl with (NOLOCK)  on appl.apno = persRef.apno
WHERE
(CASE  
	WHEN isnull(PersRef.last_updated,'1/1/1900') >= isnull(PersRef.last_worked,'1/1/1900') AND isnull(PersRef.last_updated,'1/1/1900') >= isnull(PersRef.Web_Updated,'1/1/1900') THEN PersRef.last_updated   
	WHEN isnull(PersRef.last_worked,'1/1/1900') >= isnull(PersRef.last_updated,'1/1/1900') AND isnull(PersRef.last_worked,'1/1/1900') >= isnull(PersRef.Web_Updated,'1/1/1900') THEN PersRef.last_worked  
	WHEN isnull(PersRef.Web_Updated,'1/1/1900') >= isnull(PersRef.last_worked,'1/1/1900') AND isnull(PersRef.Web_Updated,'1/1/1900') >= isnull(PersRef.last_updated,'1/1/1900') THEN PersRef.Web_Updated  
END) >= @from_date
AND
(CASE  
	WHEN isnull(PersRef.last_updated,'1/1/1900') >= isnull(PersRef.last_worked,'1/1/1900') AND isnull(PersRef.last_updated,'1/1/1900') >= isnull(PersRef.Web_Updated,'1/1/1900') THEN PersRef.last_updated  
	WHEN isnull(PersRef.last_worked,'1/1/1900') >= isnull(PersRef.last_updated,'1/1/1900') AND isnull(PersRef.last_worked,'1/1/1900') >= isnull(PersRef.Web_Updated,'1/1/1900') THEN PersRef.last_worked 
	WHEN isnull(PersRef.Web_Updated,'1/1/1900') >= isnull(PersRef.last_worked,'1/1/1900') AND isnull(PersRef.Web_Updated,'1/1/1900') >= isnull(PersRef.last_updated,'1/1/1900') THEN PersRef.Web_Updated 
END)  < @to_date
AND CLNO = @CLNO
AND apstatus in ('W','F')

AND (CASE  
	WHEN isnull(PersRef.last_updated,'1/1/1900') >= isnull(PersRef.last_worked,'1/1/1900') AND isnull(PersRef.last_updated,'1/1/1900') >= isnull(PersRef.Web_Updated,'1/1/1900') THEN dbo.elapsedbusinessdays_2( PersRef.CreatedDate,PersRef.last_updated)  
	WHEN isnull(PersRef.last_worked,'1/1/1900') >= isnull(PersRef.last_updated,'1/1/1900') AND isnull(PersRef.last_worked,'1/1/1900') >= isnull(PersRef.Web_Updated,'1/1/1900') THEN dbo.elapsedbusinessdays_2( PersRef.CreatedDate,PersRef.last_worked) 
	WHEN isnull(PersRef.Web_Updated,'1/1/1900') >= isnull(PersRef.last_worked,'1/1/1900') AND isnull(PersRef.Web_Updated,'1/1/1900') >= isnull(PersRef.last_updated,'1/1/1900') THEN dbo.elapsedbusinessdays_2( PersRef.CreatedDate,PersRef.Web_Updated)
END) = 0
--group by clno
) as 'Count'
, CAST( 100. * (SELECT count(*) FROM persRef with (NOLOCK)
	JOIN appl with (NOLOCK) on appl.apno = PersRef.apno
	WHERE 
(CASE  
	WHEN isnull(PersRef.last_updated,'1/1/1900') >= isnull(PersRef.last_worked,'1/1/1900') AND isnull(PersRef.last_updated,'1/1/1900') >= isnull(PersRef.Web_Updated,'1/1/1900') THEN PersRef.last_updated  
	WHEN isnull(PersRef.last_worked,'1/1/1900') >= isnull(PersRef.last_updated,'1/1/1900') AND isnull(PersRef.last_worked,'1/1/1900') >= isnull(PersRef.Web_Updated,'1/1/1900') THEN PersRef.last_worked 
	WHEN isnull(PersRef.Web_Updated,'1/1/1900') >= isnull(PersRef.last_worked,'1/1/1900') AND isnull(PersRef.Web_Updated,'1/1/1900') >= isnull(PersRef.last_updated,'1/1/1900') THEN PersRef.Web_Updated 
END)  >= @from_date AND
(CASE  
	WHEN isnull(PersRef.last_updated,'1/1/1900') >= isnull(PersRef.last_worked,'1/1/1900') AND isnull(PersRef.last_updated,'1/1/1900') >= isnull(PersRef.Web_Updated,'1/1/1900') THEN PersRef.last_updated  
	WHEN isnull(PersRef.last_worked,'1/1/1900') >= isnull(PersRef.last_updated,'1/1/1900') AND isnull(PersRef.last_worked,'1/1/1900') >= isnull(PersRef.Web_Updated,'1/1/1900') THEN PersRef.last_worked 
	WHEN isnull(PersRef.Web_Updated,'1/1/1900') >= isnull(PersRef.last_worked,'1/1/1900') AND isnull(PersRef.Web_Updated,'1/1/1900') >= isnull(PersRef.last_updated,'1/1/1900') THEN PersRef.Web_Updated 
END) < @to_date AND CLNO = @CLNO AND apstatus in ('W','F')
	AND  (CASE  
	WHEN isnull(PersRef.last_updated,'1/1/1900') >= isnull(PersRef.last_worked,'1/1/1900') AND isnull(PersRef.last_updated,'1/1/1900') >= isnull(PersRef.Web_Updated,'1/1/1900') THEN dbo.elapsedbusinessdays_2( PersRef.CreatedDate,PersRef.last_updated)  
	WHEN isnull(PersRef.last_worked,'1/1/1900') >= isnull(PersRef.last_updated,'1/1/1900') AND isnull(PersRef.last_worked,'1/1/1900') >= isnull(PersRef.Web_Updated,'1/1/1900') THEN dbo.elapsedbusinessdays_2( PersRef.CreatedDate,PersRef.last_worked) 
	WHEN isnull(PersRef.Web_Updated,'1/1/1900') >= isnull(PersRef.last_worked,'1/1/1900') AND isnull(PersRef.Web_Updated,'1/1/1900') >= isnull(PersRef.last_updated,'1/1/1900') THEN dbo.elapsedbusinessdays_2( PersRef.CreatedDate,PersRef.Web_Updated)
end) = 0 
--group by clno
	)  /

  (select count(PersRefid) from PersRef with (NOLOCK) JOIN appl with (NOLOCK) on appl.apno = PersRef.apno 
   where 
(CASE  
	WHEN isnull(PersRef.last_updated,'1/1/1900') >= isnull(PersRef.last_worked,'1/1/1900') AND isnull(PersRef.last_updated,'1/1/1900') >= isnull(PersRef.Web_Updated,'1/1/1900') THEN PersRef.last_updated  
	WHEN isnull(PersRef.last_worked,'1/1/1900') >= isnull(PersRef.last_updated,'1/1/1900') AND isnull(PersRef.last_worked,'1/1/1900') >= isnull(PersRef.Web_Updated,'1/1/1900') THEN PersRef.last_worked 
	WHEN isnull(PersRef.Web_Updated,'1/1/1900') >= isnull(PersRef.last_worked,'1/1/1900') AND isnull(PersRef.Web_Updated,'1/1/1900') >= isnull(PersRef.last_updated,'1/1/1900') THEN PersRef.Web_Updated 
END)  >= @from_date AND 
(CASE  
	WHEN isnull(PersRef.last_updated,'1/1/1900') >= isnull(PersRef.last_worked,'1/1/1900') AND isnull(PersRef.last_updated,'1/1/1900') >= isnull(PersRef.Web_Updated,'1/1/1900') THEN PersRef.last_updated  
	WHEN isnull(PersRef.last_worked,'1/1/1900') >= isnull(PersRef.last_updated,'1/1/1900') AND isnull(PersRef.last_worked,'1/1/1900') >= isnull(PersRef.Web_Updated,'1/1/1900') THEN PersRef.last_worked 
	WHEN isnull(PersRef.Web_Updated,'1/1/1900') >= isnull(PersRef.last_worked,'1/1/1900') AND isnull(PersRef.Web_Updated,'1/1/1900') >= isnull(PersRef.last_updated,'1/1/1900') THEN PersRef.Web_Updated 
END)  < @to_date AND CLNO = @CLNO AND apstatus in ('W','F')
  )AS NUMERIC( 7, 2 ) ) AS 'Percentage',

CAST( 100. * (SELECT count(*) FROM PersRef with (NOLOCK)
	JOIN appl with (NOLOCK) on appl.apno = PersRef.apno
	WHERE 
(CASE  
	WHEN isnull(PersRef.last_updated,'1/1/1900') >= isnull(PersRef.last_worked,'1/1/1900') AND isnull(PersRef.last_updated,'1/1/1900') >= isnull(PersRef.Web_Updated,'1/1/1900') THEN PersRef.last_updated  
	WHEN isnull(PersRef.last_worked,'1/1/1900') >= isnull(PersRef.last_updated,'1/1/1900') AND isnull(PersRef.last_worked,'1/1/1900') >= isnull(PersRef.Web_Updated,'1/1/1900') THEN PersRef.last_worked 
	WHEN isnull(PersRef.Web_Updated,'1/1/1900') >= isnull(PersRef.last_worked,'1/1/1900') AND isnull(PersRef.Web_Updated,'1/1/1900') >= isnull(PersRef.last_updated,'1/1/1900') THEN PersRef.Web_Updated 
END)  >= @from_date AND 
(CASE  
	WHEN isnull(PersRef.last_updated,'1/1/1900') >= isnull(PersRef.last_worked,'1/1/1900') AND isnull(PersRef.last_updated,'1/1/1900') >= isnull(PersRef.Web_Updated,'1/1/1900') THEN PersRef.last_updated  
	WHEN isnull(PersRef.last_worked,'1/1/1900') >= isnull(PersRef.last_updated,'1/1/1900') AND isnull(PersRef.last_worked,'1/1/1900') >= isnull(PersRef.Web_Updated,'1/1/1900') THEN PersRef.last_worked 
	WHEN isnull(PersRef.Web_Updated,'1/1/1900') >= isnull(PersRef.last_worked,'1/1/1900') AND isnull(PersRef.Web_Updated,'1/1/1900') >= isnull(PersRef.last_updated,'1/1/1900') THEN PersRef.Web_Updated 
END)  < @to_date AND CLNO = @CLNO AND apstatus in ('W','F')
	AND  (CASE  
	WHEN isnull(PersRef.last_updated,'1/1/1900') >= isnull(PersRef.last_worked,'1/1/1900') AND isnull(PersRef.last_updated,'1/1/1900') >= isnull(PersRef.Web_Updated,'1/1/1900') THEN dbo.elapsedbusinessdays_2( PersRef.CreatedDate,PersRef.last_updated)  
	WHEN isnull(PersRef.last_worked,'1/1/1900') >= isnull(PersRef.last_updated,'1/1/1900') AND isnull(PersRef.last_worked,'1/1/1900') >= isnull(PersRef.Web_Updated,'1/1/1900') THEN dbo.elapsedbusinessdays_2( PersRef.CreatedDate,PersRef.last_worked) 
	WHEN isnull(PersRef.Web_Updated,'1/1/1900') >= isnull(PersRef.last_worked,'1/1/1900') AND isnull(PersRef.Web_Updated,'1/1/1900') >= isnull(PersRef.last_updated,'1/1/1900') THEN dbo.elapsedbusinessdays_2( PersRef.CreatedDate,PersRef.Web_Updated)
	END) = 0
-- group by clno
	) / 
  (select count(PersRefid) from PersRef with (NOLOCK) JOIN appl with (NOLOCK) on appl.apno = PersRef.apno 
   where 
(CASE  
	WHEN isnull(PersRef.last_updated,'1/1/1900') >= isnull(PersRef.last_worked,'1/1/1900') AND isnull(PersRef.last_updated,'1/1/1900') >= isnull(PersRef.Web_Updated,'1/1/1900') THEN PersRef.last_updated  
	WHEN isnull(PersRef.last_worked,'1/1/1900') >= isnull(PersRef.last_updated,'1/1/1900') AND isnull(PersRef.last_worked,'1/1/1900') >= isnull(PersRef.Web_Updated,'1/1/1900') THEN PersRef.last_worked 
	WHEN isnull(PersRef.Web_Updated,'1/1/1900') >= isnull(PersRef.last_worked,'1/1/1900') AND isnull(PersRef.Web_Updated,'1/1/1900') >= isnull(PersRef.last_updated,'1/1/1900') THEN PersRef.Web_Updated 
END)  >= @from_date AND 
(CASE  
	WHEN isnull(PersRef.last_updated,'1/1/1900') >= isnull(PersRef.last_worked,'1/1/1900') AND isnull(PersRef.last_updated,'1/1/1900') >= isnull(PersRef.Web_Updated,'1/1/1900') THEN PersRef.last_updated  
	WHEN isnull(PersRef.last_worked,'1/1/1900') >= isnull(PersRef.last_updated,'1/1/1900') AND isnull(PersRef.last_worked,'1/1/1900') >= isnull(PersRef.Web_Updated,'1/1/1900') THEN PersRef.last_worked 
	WHEN isnull(PersRef.Web_Updated,'1/1/1900') >= isnull(PersRef.last_worked,'1/1/1900') AND isnull(PersRef.Web_Updated,'1/1/1900') >= isnull(PersRef.last_updated,'1/1/1900') THEN PersRef.Web_Updated 
END)  < @to_date AND CLNO = @CLNO AND apstatus in ('W','F')
  )AS NUMERIC( 7, 2 ) ) as 'Cumulative %'
FROM PersRef with (NOLOCK) JOIN appl with (NOLOCK) on appl.apno = PersRef.apno
WHERE  
(CASE  
	WHEN isnull(PersRef.last_updated,'1/1/1900') >= isnull(PersRef.last_worked,'1/1/1900') AND isnull(PersRef.last_updated,'1/1/1900') >= isnull(PersRef.Web_Updated,'1/1/1900') THEN PersRef.last_updated  
	WHEN isnull(PersRef.last_worked,'1/1/1900') >= isnull(PersRef.last_updated,'1/1/1900') AND isnull(PersRef.last_worked,'1/1/1900') >= isnull(PersRef.Web_Updated,'1/1/1900') THEN PersRef.last_worked 
	WHEN isnull(PersRef.Web_Updated,'1/1/1900') >= isnull(PersRef.last_worked,'1/1/1900') AND isnull(PersRef.Web_Updated,'1/1/1900') >= isnull(PersRef.last_updated,'1/1/1900') THEN PersRef.Web_Updated 
END)  >= @from_date AND 
(CASE  
	WHEN isnull(PersRef.last_updated,'1/1/1900') >= isnull(PersRef.last_worked,'1/1/1900') AND isnull(PersRef.last_updated,'1/1/1900') >= isnull(PersRef.Web_Updated,'1/1/1900') THEN PersRef.last_updated  
	WHEN isnull(PersRef.last_worked,'1/1/1900') >= isnull(PersRef.last_updated,'1/1/1900') AND isnull(PersRef.last_worked,'1/1/1900') >= isnull(PersRef.Web_Updated,'1/1/1900') THEN PersRef.last_worked 
	WHEN isnull(PersRef.Web_Updated,'1/1/1900') >= isnull(PersRef.last_worked,'1/1/1900') AND isnull(PersRef.Web_Updated,'1/1/1900') >= isnull(PersRef.last_updated,'1/1/1900') THEN PersRef.Web_Updated 
END) < @to_date AND  CLNO = @CLNO AND apstatus in ('W','F') 
--group by clno 

UNION

SELECT '1 day' AS 'Turnaround Time',( SELECT count(*) FROM PersRef with (NOLOCK)
JOIN appl with (NOLOCK) on appl.apno = PersRef.apno
WHERE
(CASE  
	WHEN isnull(PersRef.last_updated,'1/1/1900') >= isnull(PersRef.last_worked,'1/1/1900') AND isnull(PersRef.last_updated,'1/1/1900') >= isnull(PersRef.Web_Updated,'1/1/1900') THEN PersRef.last_updated   
	WHEN isnull(PersRef.last_worked,'1/1/1900') >= isnull(PersRef.last_updated,'1/1/1900') AND isnull(PersRef.last_worked,'1/1/1900') >= isnull(PersRef.Web_Updated,'1/1/1900') THEN PersRef.last_worked  
	WHEN isnull(PersRef.Web_Updated,'1/1/1900') >= isnull(PersRef.last_worked,'1/1/1900') AND isnull(PersRef.Web_Updated,'1/1/1900') >= isnull(PersRef.last_updated,'1/1/1900') THEN PersRef.Web_Updated  
END) >= @from_date
AND
(CASE  
	WHEN isnull(PersRef.last_updated,'1/1/1900') >= isnull(PersRef.last_worked,'1/1/1900') AND isnull(PersRef.last_updated,'1/1/1900') >= isnull(PersRef.Web_Updated,'1/1/1900') THEN PersRef.last_updated  
	WHEN isnull(PersRef.last_worked,'1/1/1900') >= isnull(PersRef.last_updated,'1/1/1900') AND isnull(PersRef.last_worked,'1/1/1900') >= isnull(PersRef.Web_Updated,'1/1/1900') THEN PersRef.last_worked 
	WHEN isnull(PersRef.Web_Updated,'1/1/1900') >= isnull(PersRef.last_worked,'1/1/1900') AND isnull(PersRef.Web_Updated,'1/1/1900') >= isnull(PersRef.last_updated,'1/1/1900') THEN PersRef.Web_Updated 
END)  < @to_date
AND CLNO = @CLNO
AND apstatus in ('W','F')
AND (CASE  
	WHEN isnull(PersRef.last_updated,'1/1/1900') >= isnull(PersRef.last_worked,'1/1/1900') AND isnull(PersRef.last_updated,'1/1/1900') >= isnull(PersRef.Web_Updated,'1/1/1900') THEN dbo.elapsedbusinessdays_2( PersRef.CreatedDate,PersRef.last_updated)  
	WHEN isnull(PersRef.last_worked,'1/1/1900') >= isnull(PersRef.last_updated,'1/1/1900') AND isnull(PersRef.last_worked,'1/1/1900') >= isnull(PersRef.Web_Updated,'1/1/1900') THEN dbo.elapsedbusinessdays_2( PersRef.CreatedDate,PersRef.last_worked) 
	WHEN isnull(PersRef.Web_Updated,'1/1/1900') >= isnull(PersRef.last_worked,'1/1/1900') AND isnull(PersRef.Web_Updated,'1/1/1900') >= isnull(PersRef.last_updated,'1/1/1900') THEN dbo.elapsedbusinessdays_2( PersRef.CreatedDate,PersRef.Web_Updated)
END) = 1
--group by clno
) as 'Count'
, CAST( 100. * (SELECT count(*) FROM PersRef with (NOLOCK)
	JOIN appl with (NOLOCK) on appl.apno = PersRef.apno
	WHERE 
(CASE  
	WHEN isnull(PersRef.last_updated,'1/1/1900') >= isnull(PersRef.last_worked,'1/1/1900') AND isnull(PersRef.last_updated,'1/1/1900') >= isnull(PersRef.Web_Updated,'1/1/1900') THEN PersRef.last_updated  
	WHEN isnull(PersRef.last_worked,'1/1/1900') >= isnull(PersRef.last_updated,'1/1/1900') AND isnull(PersRef.last_worked,'1/1/1900') >= isnull(PersRef.Web_Updated,'1/1/1900') THEN PersRef.last_worked 
	WHEN isnull(PersRef.Web_Updated,'1/1/1900') >= isnull(PersRef.last_worked,'1/1/1900') AND isnull(PersRef.Web_Updated,'1/1/1900') >= isnull(PersRef.last_updated,'1/1/1900') THEN PersRef.Web_Updated 
END)  >= @from_date AND
(CASE  
	WHEN isnull(PersRef.last_updated,'1/1/1900') >= isnull(PersRef.last_worked,'1/1/1900') AND isnull(PersRef.last_updated,'1/1/1900') >= isnull(PersRef.Web_Updated,'1/1/1900') THEN PersRef.last_updated  
	WHEN isnull(PersRef.last_worked,'1/1/1900') >= isnull(PersRef.last_updated,'1/1/1900') AND isnull(PersRef.last_worked,'1/1/1900') >= isnull(PersRef.Web_Updated,'1/1/1900') THEN PersRef.last_worked 
	WHEN isnull(PersRef.Web_Updated,'1/1/1900') >= isnull(PersRef.last_worked,'1/1/1900') AND isnull(PersRef.Web_Updated,'1/1/1900') >= isnull(PersRef.last_updated,'1/1/1900') THEN PersRef.Web_Updated 
END) < @to_date AND CLNO = @CLNO AND apstatus in ('W','F')
	AND  (CASE  
	WHEN isnull(PersRef.last_updated,'1/1/1900') >= isnull(PersRef.last_worked,'1/1/1900') AND isnull(PersRef.last_updated,'1/1/1900') >= isnull(PersRef.Web_Updated,'1/1/1900') THEN dbo.elapsedbusinessdays_2( PersRef.CreatedDate,PersRef.last_updated)  
	WHEN isnull(PersRef.last_worked,'1/1/1900') >= isnull(PersRef.last_updated,'1/1/1900') AND isnull(PersRef.last_worked,'1/1/1900') >= isnull(PersRef.Web_Updated,'1/1/1900') THEN dbo.elapsedbusinessdays_2( PersRef.CreatedDate,PersRef.last_worked) 
	WHEN isnull(PersRef.Web_Updated,'1/1/1900') >= isnull(PersRef.last_worked,'1/1/1900') AND isnull(PersRef.Web_Updated,'1/1/1900') >= isnull(PersRef.last_updated,'1/1/1900') THEN dbo.elapsedbusinessdays_2( PersRef.CreatedDate,PersRef.Web_Updated)
end) = 1
--group by clno 
	)  /
  (select count(PersRefid) from PersRef with (NOLOCK) JOIN appl with (NOLOCK) on appl.apno = PersRef.apno 
   where 
(CASE  
	WHEN isnull(PersRef.last_updated,'1/1/1900') >= isnull(PersRef.last_worked,'1/1/1900') AND isnull(PersRef.last_updated,'1/1/1900') >= isnull(PersRef.Web_Updated,'1/1/1900') THEN PersRef.last_updated  
	WHEN isnull(PersRef.last_worked,'1/1/1900') >= isnull(PersRef.last_updated,'1/1/1900') AND isnull(PersRef.last_worked,'1/1/1900') >= isnull(PersRef.Web_Updated,'1/1/1900') THEN PersRef.last_worked 
	WHEN isnull(PersRef.Web_Updated,'1/1/1900') >= isnull(PersRef.last_worked,'1/1/1900') AND isnull(PersRef.Web_Updated,'1/1/1900') >= isnull(PersRef.last_updated,'1/1/1900') THEN PersRef.Web_Updated 
END)  >= @from_date AND 
(CASE  
	WHEN isnull(PersRef.last_updated,'1/1/1900') >= isnull(PersRef.last_worked,'1/1/1900') AND isnull(PersRef.last_updated,'1/1/1900') >= isnull(PersRef.Web_Updated,'1/1/1900') THEN PersRef.last_updated  
	WHEN isnull(PersRef.last_worked,'1/1/1900') >= isnull(PersRef.last_updated,'1/1/1900') AND isnull(PersRef.last_worked,'1/1/1900') >= isnull(PersRef.Web_Updated,'1/1/1900') THEN PersRef.last_worked 
	WHEN isnull(PersRef.Web_Updated,'1/1/1900') >= isnull(PersRef.last_worked,'1/1/1900') AND isnull(PersRef.Web_Updated,'1/1/1900') >= isnull(PersRef.last_updated,'1/1/1900') THEN PersRef.Web_Updated 
END)  < @to_date AND CLNO = @CLNO AND apstatus in ('W','F')
  )AS NUMERIC( 7, 2 ) ) AS 'Percentage',

CAST( 100. * (SELECT count(*) FROM PersRef with (NOLOCK)
	JOIN appl with (NOLOCK) on appl.apno = PersRef.apno
	WHERE 
(CASE  
	WHEN isnull(PersRef.last_updated,'1/1/1900') >= isnull(PersRef.last_worked,'1/1/1900') AND isnull(PersRef.last_updated,'1/1/1900') >= isnull(PersRef.Web_Updated,'1/1/1900') THEN PersRef.last_updated  
	WHEN isnull(PersRef.last_worked,'1/1/1900') >= isnull(PersRef.last_updated,'1/1/1900') AND isnull(PersRef.last_worked,'1/1/1900') >= isnull(PersRef.Web_Updated,'1/1/1900') THEN PersRef.last_worked 
	WHEN isnull(PersRef.Web_Updated,'1/1/1900') >= isnull(PersRef.last_worked,'1/1/1900') AND isnull(PersRef.Web_Updated,'1/1/1900') >= isnull(PersRef.last_updated,'1/1/1900') THEN PersRef.Web_Updated 
END)  >= @from_date AND 
(CASE  
	WHEN isnull(PersRef.last_updated,'1/1/1900') >= isnull(PersRef.last_worked,'1/1/1900') AND isnull(PersRef.last_updated,'1/1/1900') >= isnull(PersRef.Web_Updated,'1/1/1900') THEN PersRef.last_updated  
	WHEN isnull(PersRef.last_worked,'1/1/1900') >= isnull(PersRef.last_updated,'1/1/1900') AND isnull(PersRef.last_worked,'1/1/1900') >= isnull(PersRef.Web_Updated,'1/1/1900') THEN PersRef.last_worked 
	WHEN isnull(PersRef.Web_Updated,'1/1/1900') >= isnull(PersRef.last_worked,'1/1/1900') AND isnull(PersRef.Web_Updated,'1/1/1900') >= isnull(PersRef.last_updated,'1/1/1900') THEN PersRef.Web_Updated 
END)  < @to_date AND CLNO = @CLNO AND apstatus in ('W','F')
	AND  (CASE  
	WHEN isnull(PersRef.last_updated,'1/1/1900') >= isnull(PersRef.last_worked,'1/1/1900') AND isnull(PersRef.last_updated,'1/1/1900') >= isnull(PersRef.Web_Updated,'1/1/1900') THEN dbo.elapsedbusinessdays_2( PersRef.CreatedDate,PersRef.last_updated)  
	WHEN isnull(PersRef.last_worked,'1/1/1900') >= isnull(PersRef.last_updated,'1/1/1900') AND isnull(PersRef.last_worked,'1/1/1900') >= isnull(PersRef.Web_Updated,'1/1/1900') THEN dbo.elapsedbusinessdays_2( PersRef.CreatedDate,PersRef.last_worked) 
	WHEN isnull(PersRef.Web_Updated,'1/1/1900') >= isnull(PersRef.last_worked,'1/1/1900') AND isnull(PersRef.Web_Updated,'1/1/1900') >= isnull(PersRef.last_updated,'1/1/1900') THEN dbo.elapsedbusinessdays_2( PersRef.CreatedDate,PersRef.Web_Updated)
	END) <= 1
-- group by clno
	) / 
  (select count(PersRefid) from PersRef with (NOLOCK) JOIN appl with (NOLOCK) on appl.apno = PersRef.apno 
   where 
(CASE  
	WHEN isnull(PersRef.last_updated,'1/1/1900') >= isnull(PersRef.last_worked,'1/1/1900') AND isnull(PersRef.last_updated,'1/1/1900') >= isnull(PersRef.Web_Updated,'1/1/1900') THEN PersRef.last_updated  
	WHEN isnull(PersRef.last_worked,'1/1/1900') >= isnull(PersRef.last_updated,'1/1/1900') AND isnull(PersRef.last_worked,'1/1/1900') >= isnull(PersRef.Web_Updated,'1/1/1900') THEN PersRef.last_worked 
	WHEN isnull(PersRef.Web_Updated,'1/1/1900') >= isnull(PersRef.last_worked,'1/1/1900') AND isnull(PersRef.Web_Updated,'1/1/1900') >= isnull(PersRef.last_updated,'1/1/1900') THEN PersRef.Web_Updated 
END)  >= @from_date AND 
(CASE  
	WHEN isnull(PersRef.last_updated,'1/1/1900') >= isnull(PersRef.last_worked,'1/1/1900') AND isnull(PersRef.last_updated,'1/1/1900') >= isnull(PersRef.Web_Updated,'1/1/1900') THEN PersRef.last_updated  
	WHEN isnull(PersRef.last_worked,'1/1/1900') >= isnull(PersRef.last_updated,'1/1/1900') AND isnull(PersRef.last_worked,'1/1/1900') >= isnull(PersRef.Web_Updated,'1/1/1900') THEN PersRef.last_worked 
	WHEN isnull(PersRef.Web_Updated,'1/1/1900') >= isnull(PersRef.last_worked,'1/1/1900') AND isnull(PersRef.Web_Updated,'1/1/1900') >= isnull(PersRef.last_updated,'1/1/1900') THEN PersRef.Web_Updated 
END)  < @to_date AND CLNO = @CLNO AND apstatus in ('W','F')
  )AS NUMERIC( 7, 2 ) ) as 'Cumulative %'
FROM PersRef with (NOLOCK) JOIN appl with (NOLOCK) on appl.apno = PersRef.apno
WHERE  
(CASE  
	WHEN isnull(PersRef.last_updated,'1/1/1900') >= isnull(PersRef.last_worked,'1/1/1900') AND isnull(PersRef.last_updated,'1/1/1900') >= isnull(PersRef.Web_Updated,'1/1/1900') THEN PersRef.last_updated  
	WHEN isnull(PersRef.last_worked,'1/1/1900') >= isnull(PersRef.last_updated,'1/1/1900') AND isnull(PersRef.last_worked,'1/1/1900') >= isnull(PersRef.Web_Updated,'1/1/1900') THEN PersRef.last_worked 
	WHEN isnull(PersRef.Web_Updated,'1/1/1900') >= isnull(PersRef.last_worked,'1/1/1900') AND isnull(PersRef.Web_Updated,'1/1/1900') >= isnull(PersRef.last_updated,'1/1/1900') THEN PersRef.Web_Updated 
END)  >= @from_date AND 
(CASE  
	WHEN isnull(PersRef.last_updated,'1/1/1900') >= isnull(PersRef.last_worked,'1/1/1900') AND isnull(PersRef.last_updated,'1/1/1900') >= isnull(PersRef.Web_Updated,'1/1/1900') THEN PersRef.last_updated  
	WHEN isnull(PersRef.last_worked,'1/1/1900') >= isnull(PersRef.last_updated,'1/1/1900') AND isnull(PersRef.last_worked,'1/1/1900') >= isnull(PersRef.Web_Updated,'1/1/1900') THEN PersRef.last_worked 
	WHEN isnull(PersRef.Web_Updated,'1/1/1900') >= isnull(PersRef.last_worked,'1/1/1900') AND isnull(PersRef.Web_Updated,'1/1/1900') >= isnull(PersRef.last_updated,'1/1/1900') THEN PersRef.Web_Updated 
END) < @to_date AND  CLNO = @CLNO AND apstatus in ('W','F') 
--group by clno 

UNION

SELECT '2 days' AS 'Turnaround Time',( SELECT count(*) FROM PersRef with (NOLOCK)
JOIN appl with (NOLOCK) on appl.apno = PersRef.apno
WHERE
(CASE  
	WHEN isnull(PersRef.last_updated,'1/1/1900') >= isnull(PersRef.last_worked,'1/1/1900') AND isnull(PersRef.last_updated,'1/1/1900') >= isnull(PersRef.Web_Updated,'1/1/1900') THEN PersRef.last_updated   
	WHEN isnull(PersRef.last_worked,'1/1/1900') >= isnull(PersRef.last_updated,'1/1/1900') AND isnull(PersRef.last_worked,'1/1/1900') >= isnull(PersRef.Web_Updated,'1/1/1900') THEN PersRef.last_worked  
	WHEN isnull(PersRef.Web_Updated,'1/1/1900') >= isnull(PersRef.last_worked,'1/1/1900') AND isnull(PersRef.Web_Updated,'1/1/1900') >= isnull(PersRef.last_updated,'1/1/1900') THEN PersRef.Web_Updated  
END) >= @from_date
AND
(CASE  
	WHEN isnull(PersRef.last_updated,'1/1/1900') >= isnull(PersRef.last_worked,'1/1/1900') AND isnull(PersRef.last_updated,'1/1/1900') >= isnull(PersRef.Web_Updated,'1/1/1900') THEN PersRef.last_updated  
	WHEN isnull(PersRef.last_worked,'1/1/1900') >= isnull(PersRef.last_updated,'1/1/1900') AND isnull(PersRef.last_worked,'1/1/1900') >= isnull(PersRef.Web_Updated,'1/1/1900') THEN PersRef.last_worked 
	WHEN isnull(PersRef.Web_Updated,'1/1/1900') >= isnull(PersRef.last_worked,'1/1/1900') AND isnull(PersRef.Web_Updated,'1/1/1900') >= isnull(PersRef.last_updated,'1/1/1900') THEN PersRef.Web_Updated 
END)  < @to_date
AND CLNO = @CLNO AND apstatus in ('W','F')
AND apstatus in ('W','F')
AND (CASE  
	WHEN isnull(PersRef.last_updated,'1/1/1900') >= isnull(PersRef.last_worked,'1/1/1900') AND isnull(PersRef.last_updated,'1/1/1900') >= isnull(PersRef.Web_Updated,'1/1/1900') THEN dbo.elapsedbusinessdays_2( PersRef.CreatedDate,PersRef.last_updated)  
	WHEN isnull(PersRef.last_worked,'1/1/1900') >= isnull(PersRef.last_updated,'1/1/1900') AND isnull(PersRef.last_worked,'1/1/1900') >= isnull(PersRef.Web_Updated,'1/1/1900') THEN dbo.elapsedbusinessdays_2( PersRef.CreatedDate,PersRef.last_worked) 
	WHEN isnull(PersRef.Web_Updated,'1/1/1900') >= isnull(PersRef.last_worked,'1/1/1900') AND isnull(PersRef.Web_Updated,'1/1/1900') >= isnull(PersRef.last_updated,'1/1/1900') THEN dbo.elapsedbusinessdays_2( PersRef.CreatedDate,PersRef.Web_Updated)
END) = 2
--group by clno
) as 'Count'
, CAST( 100. * (SELECT count(*) FROM PersRef with (NOLOCK)
	JOIN appl with (NOLOCK) on appl.apno = PersRef.apno
	WHERE 
(CASE  
	WHEN isnull(PersRef.last_updated,'1/1/1900') >= isnull(PersRef.last_worked,'1/1/1900') AND isnull(PersRef.last_updated,'1/1/1900') >= isnull(PersRef.Web_Updated,'1/1/1900') THEN PersRef.last_updated  
	WHEN isnull(PersRef.last_worked,'1/1/1900') >= isnull(PersRef.last_updated,'1/1/1900') AND isnull(PersRef.last_worked,'1/1/1900') >= isnull(PersRef.Web_Updated,'1/1/1900') THEN PersRef.last_worked 
	WHEN isnull(PersRef.Web_Updated,'1/1/1900') >= isnull(PersRef.last_worked,'1/1/1900') AND isnull(PersRef.Web_Updated,'1/1/1900') >= isnull(PersRef.last_updated,'1/1/1900') THEN PersRef.Web_Updated 
END)  >= @from_date AND
(CASE  
	WHEN isnull(PersRef.last_updated,'1/1/1900') >= isnull(PersRef.last_worked,'1/1/1900') AND isnull(PersRef.last_updated,'1/1/1900') >= isnull(PersRef.Web_Updated,'1/1/1900') THEN PersRef.last_updated  
	WHEN isnull(PersRef.last_worked,'1/1/1900') >= isnull(PersRef.last_updated,'1/1/1900') AND isnull(PersRef.last_worked,'1/1/1900') >= isnull(PersRef.Web_Updated,'1/1/1900') THEN PersRef.last_worked 
	WHEN isnull(PersRef.Web_Updated,'1/1/1900') >= isnull(PersRef.last_worked,'1/1/1900') AND isnull(PersRef.Web_Updated,'1/1/1900') >= isnull(PersRef.last_updated,'1/1/1900') THEN PersRef.Web_Updated 
END) < @to_date AND CLNO = @CLNO AND apstatus in ('W','F')
	AND  (CASE  
	WHEN isnull(PersRef.last_updated,'1/1/1900') >= isnull(PersRef.last_worked,'1/1/1900') AND isnull(PersRef.last_updated,'1/1/1900') >= isnull(PersRef.Web_Updated,'1/1/1900') THEN dbo.elapsedbusinessdays_2( PersRef.CreatedDate,PersRef.last_updated)  
	WHEN isnull(PersRef.last_worked,'1/1/1900') >= isnull(PersRef.last_updated,'1/1/1900') AND isnull(PersRef.last_worked,'1/1/1900') >= isnull(PersRef.Web_Updated,'1/1/1900') THEN dbo.elapsedbusinessdays_2( PersRef.CreatedDate,PersRef.last_worked) 
	WHEN isnull(PersRef.Web_Updated,'1/1/1900') >= isnull(PersRef.last_worked,'1/1/1900') AND isnull(PersRef.Web_Updated,'1/1/1900') >= isnull(PersRef.last_updated,'1/1/1900') THEN dbo.elapsedbusinessdays_2( PersRef.CreatedDate,PersRef.Web_Updated)
end) = 2 
--group by clno
	)  /
  (select count(PersRefid) from PersRef with (NOLOCK) JOIN appl with (NOLOCK) on appl.apno = PersRef.apno 
   where 
(CASE  
	WHEN isnull(PersRef.last_updated,'1/1/1900') >= isnull(PersRef.last_worked,'1/1/1900') AND isnull(PersRef.last_updated,'1/1/1900') >= isnull(PersRef.Web_Updated,'1/1/1900') THEN PersRef.last_updated  
	WHEN isnull(PersRef.last_worked,'1/1/1900') >= isnull(PersRef.last_updated,'1/1/1900') AND isnull(PersRef.last_worked,'1/1/1900') >= isnull(PersRef.Web_Updated,'1/1/1900') THEN PersRef.last_worked 
	WHEN isnull(PersRef.Web_Updated,'1/1/1900') >= isnull(PersRef.last_worked,'1/1/1900') AND isnull(PersRef.Web_Updated,'1/1/1900') >= isnull(PersRef.last_updated,'1/1/1900') THEN PersRef.Web_Updated 
END)  >= @from_date AND 
(CASE  
	WHEN isnull(PersRef.last_updated,'1/1/1900') >= isnull(PersRef.last_worked,'1/1/1900') AND isnull(PersRef.last_updated,'1/1/1900') >= isnull(PersRef.Web_Updated,'1/1/1900') THEN PersRef.last_updated  
	WHEN isnull(PersRef.last_worked,'1/1/1900') >= isnull(PersRef.last_updated,'1/1/1900') AND isnull(PersRef.last_worked,'1/1/1900') >= isnull(PersRef.Web_Updated,'1/1/1900') THEN PersRef.last_worked 
	WHEN isnull(PersRef.Web_Updated,'1/1/1900') >= isnull(PersRef.last_worked,'1/1/1900') AND isnull(PersRef.Web_Updated,'1/1/1900') >= isnull(PersRef.last_updated,'1/1/1900') THEN PersRef.Web_Updated 
END)  < @to_date AND CLNO = @CLNO AND apstatus in ('W','F')
  )AS NUMERIC( 7, 2 ) ) AS 'Percentage', 

CAST( 100. * (SELECT count(*) FROM PersRef with (NOLOCK)
	JOIN appl with (NOLOCK) on appl.apno = PersRef.apno
	WHERE 
(CASE  
	WHEN isnull(PersRef.last_updated,'1/1/1900') >= isnull(PersRef.last_worked,'1/1/1900') AND isnull(PersRef.last_updated,'1/1/1900') >= isnull(PersRef.Web_Updated,'1/1/1900') THEN PersRef.last_updated  
	WHEN isnull(PersRef.last_worked,'1/1/1900') >= isnull(PersRef.last_updated,'1/1/1900') AND isnull(PersRef.last_worked,'1/1/1900') >= isnull(PersRef.Web_Updated,'1/1/1900') THEN PersRef.last_worked 
	WHEN isnull(PersRef.Web_Updated,'1/1/1900') >= isnull(PersRef.last_worked,'1/1/1900') AND isnull(PersRef.Web_Updated,'1/1/1900') >= isnull(PersRef.last_updated,'1/1/1900') THEN PersRef.Web_Updated 
END)  >= @from_date AND 
(CASE  
	WHEN isnull(PersRef.last_updated,'1/1/1900') >= isnull(PersRef.last_worked,'1/1/1900') AND isnull(PersRef.last_updated,'1/1/1900') >= isnull(PersRef.Web_Updated,'1/1/1900') THEN PersRef.last_updated  
	WHEN isnull(PersRef.last_worked,'1/1/1900') >= isnull(PersRef.last_updated,'1/1/1900') AND isnull(PersRef.last_worked,'1/1/1900') >= isnull(PersRef.Web_Updated,'1/1/1900') THEN PersRef.last_worked 
	WHEN isnull(PersRef.Web_Updated,'1/1/1900') >= isnull(PersRef.last_worked,'1/1/1900') AND isnull(PersRef.Web_Updated,'1/1/1900') >= isnull(PersRef.last_updated,'1/1/1900') THEN PersRef.Web_Updated 
END)  < @to_date AND CLNO = @CLNO AND apstatus in ('W','F')
	AND  (CASE  
	WHEN isnull(PersRef.last_updated,'1/1/1900') >= isnull(PersRef.last_worked,'1/1/1900') AND isnull(PersRef.last_updated,'1/1/1900') >= isnull(PersRef.Web_Updated,'1/1/1900') THEN dbo.elapsedbusinessdays_2( PersRef.CreatedDate,PersRef.last_updated)  
	WHEN isnull(PersRef.last_worked,'1/1/1900') >= isnull(PersRef.last_updated,'1/1/1900') AND isnull(PersRef.last_worked,'1/1/1900') >= isnull(PersRef.Web_Updated,'1/1/1900') THEN dbo.elapsedbusinessdays_2( PersRef.CreatedDate,PersRef.last_worked) 
	WHEN isnull(PersRef.Web_Updated,'1/1/1900') >= isnull(PersRef.last_worked,'1/1/1900') AND isnull(PersRef.Web_Updated,'1/1/1900') >= isnull(PersRef.last_updated,'1/1/1900') THEN dbo.elapsedbusinessdays_2( PersRef.CreatedDate,PersRef.Web_Updated)
	END) <= 2
-- group by clno
	) / 
  (select count(PersRefid) from PersRef with (NOLOCK) JOIN appl with (NOLOCK) on appl.apno = PersRef.apno 
   where 
(CASE  
	WHEN isnull(PersRef.last_updated,'1/1/1900') >= isnull(PersRef.last_worked,'1/1/1900') AND isnull(PersRef.last_updated,'1/1/1900') >= isnull(PersRef.Web_Updated,'1/1/1900') THEN PersRef.last_updated  
	WHEN isnull(PersRef.last_worked,'1/1/1900') >= isnull(PersRef.last_updated,'1/1/1900') AND isnull(PersRef.last_worked,'1/1/1900') >= isnull(PersRef.Web_Updated,'1/1/1900') THEN PersRef.last_worked 
	WHEN isnull(PersRef.Web_Updated,'1/1/1900') >= isnull(PersRef.last_worked,'1/1/1900') AND isnull(PersRef.Web_Updated,'1/1/1900') >= isnull(PersRef.last_updated,'1/1/1900') THEN PersRef.Web_Updated 
END)  >= @from_date AND 
(CASE  
	WHEN isnull(PersRef.last_updated,'1/1/1900') >= isnull(PersRef.last_worked,'1/1/1900') AND isnull(PersRef.last_updated,'1/1/1900') >= isnull(PersRef.Web_Updated,'1/1/1900') THEN PersRef.last_updated  
	WHEN isnull(PersRef.last_worked,'1/1/1900') >= isnull(PersRef.last_updated,'1/1/1900') AND isnull(PersRef.last_worked,'1/1/1900') >= isnull(PersRef.Web_Updated,'1/1/1900') THEN PersRef.last_worked 
	WHEN isnull(PersRef.Web_Updated,'1/1/1900') >= isnull(PersRef.last_worked,'1/1/1900') AND isnull(PersRef.Web_Updated,'1/1/1900') >= isnull(PersRef.last_updated,'1/1/1900') THEN PersRef.Web_Updated 
END)  < @to_date AND CLNO = @CLNO AND apstatus in ('W','F')
  )AS NUMERIC( 7, 2 ) ) as 'Cumulative %'
FROM PersRef with (NOLOCK) JOIN appl with (NOLOCK) on appl.apno = PersRef.apno
WHERE  
(CASE  
	WHEN isnull(PersRef.last_updated,'1/1/1900') >= isnull(PersRef.last_worked,'1/1/1900') AND isnull(PersRef.last_updated,'1/1/1900') >= isnull(PersRef.Web_Updated,'1/1/1900') THEN PersRef.last_updated  
	WHEN isnull(PersRef.last_worked,'1/1/1900') >= isnull(PersRef.last_updated,'1/1/1900') AND isnull(PersRef.last_worked,'1/1/1900') >= isnull(PersRef.Web_Updated,'1/1/1900') THEN PersRef.last_worked 
	WHEN isnull(PersRef.Web_Updated,'1/1/1900') >= isnull(PersRef.last_worked,'1/1/1900') AND isnull(PersRef.Web_Updated,'1/1/1900') >= isnull(PersRef.last_updated,'1/1/1900') THEN PersRef.Web_Updated 
END)  >= @from_date AND 
(CASE  
	WHEN isnull(PersRef.last_updated,'1/1/1900') >= isnull(PersRef.last_worked,'1/1/1900') AND isnull(PersRef.last_updated,'1/1/1900') >= isnull(PersRef.Web_Updated,'1/1/1900') THEN PersRef.last_updated  
	WHEN isnull(PersRef.last_worked,'1/1/1900') >= isnull(PersRef.last_updated,'1/1/1900') AND isnull(PersRef.last_worked,'1/1/1900') >= isnull(PersRef.Web_Updated,'1/1/1900') THEN PersRef.last_worked 
	WHEN isnull(PersRef.Web_Updated,'1/1/1900') >= isnull(PersRef.last_worked,'1/1/1900') AND isnull(PersRef.Web_Updated,'1/1/1900') >= isnull(PersRef.last_updated,'1/1/1900') THEN PersRef.Web_Updated 
END) < @to_date AND  CLNO = @CLNO AND apstatus in ('W','F') 
--group by clno 

UNION


SELECT '3 days' AS 'Turnaround Time',( SELECT count(*) FROM PersRef with (NOLOCK)
JOIN appl with (NOLOCK) on appl.apno = PersRef.apno
WHERE
(CASE  
	WHEN isnull(PersRef.last_updated,'1/1/1900') >= isnull(PersRef.last_worked,'1/1/1900') AND isnull(PersRef.last_updated,'1/1/1900') >= isnull(PersRef.Web_Updated,'1/1/1900') THEN PersRef.last_updated   
	WHEN isnull(PersRef.last_worked,'1/1/1900') >= isnull(PersRef.last_updated,'1/1/1900') AND isnull(PersRef.last_worked,'1/1/1900') >= isnull(PersRef.Web_Updated,'1/1/1900') THEN PersRef.last_worked  
	WHEN isnull(PersRef.Web_Updated,'1/1/1900') >= isnull(PersRef.last_worked,'1/1/1900') AND isnull(PersRef.Web_Updated,'1/1/1900') >= isnull(PersRef.last_updated,'1/1/1900') THEN PersRef.Web_Updated  
END) >= @from_date
AND
(CASE  
	WHEN isnull(PersRef.last_updated,'1/1/1900') >= isnull(PersRef.last_worked,'1/1/1900') AND isnull(PersRef.last_updated,'1/1/1900') >= isnull(PersRef.Web_Updated,'1/1/1900') THEN PersRef.last_updated  
	WHEN isnull(PersRef.last_worked,'1/1/1900') >= isnull(PersRef.last_updated,'1/1/1900') AND isnull(PersRef.last_worked,'1/1/1900') >= isnull(PersRef.Web_Updated,'1/1/1900') THEN PersRef.last_worked 
	WHEN isnull(PersRef.Web_Updated,'1/1/1900') >= isnull(PersRef.last_worked,'1/1/1900') AND isnull(PersRef.Web_Updated,'1/1/1900') >= isnull(PersRef.last_updated,'1/1/1900') THEN PersRef.Web_Updated 
END)  < @to_date
AND CLNO = @CLNO AND apstatus in ('W','F')
AND apstatus in ('W','F')
AND (CASE  
	WHEN isnull(PersRef.last_updated,'1/1/1900') >= isnull(PersRef.last_worked,'1/1/1900') AND isnull(PersRef.last_updated,'1/1/1900') >= isnull(PersRef.Web_Updated,'1/1/1900') THEN dbo.elapsedbusinessdays_2( PersRef.CreatedDate,PersRef.last_updated)  
	WHEN isnull(PersRef.last_worked,'1/1/1900') >= isnull(PersRef.last_updated,'1/1/1900') AND isnull(PersRef.last_worked,'1/1/1900') >= isnull(PersRef.Web_Updated,'1/1/1900') THEN dbo.elapsedbusinessdays_2( PersRef.CreatedDate,PersRef.last_worked) 
	WHEN isnull(PersRef.Web_Updated,'1/1/1900') >= isnull(PersRef.last_worked,'1/1/1900') AND isnull(PersRef.Web_Updated,'1/1/1900') >= isnull(PersRef.last_updated,'1/1/1900') THEN dbo.elapsedbusinessdays_2( PersRef.CreatedDate,PersRef.Web_Updated)
END) = 3
--group by clno
) as 'Count'
, CAST( 100. * (SELECT count(*) FROM PersRef with (NOLOCK)
	JOIN appl with (NOLOCK) on appl.apno = PersRef.apno
	WHERE 
(CASE  
	WHEN isnull(PersRef.last_updated,'1/1/1900') >= isnull(PersRef.last_worked,'1/1/1900') AND isnull(PersRef.last_updated,'1/1/1900') >= isnull(PersRef.Web_Updated,'1/1/1900') THEN PersRef.last_updated  
	WHEN isnull(PersRef.last_worked,'1/1/1900') >= isnull(PersRef.last_updated,'1/1/1900') AND isnull(PersRef.last_worked,'1/1/1900') >= isnull(PersRef.Web_Updated,'1/1/1900') THEN PersRef.last_worked 
	WHEN isnull(PersRef.Web_Updated,'1/1/1900') >= isnull(PersRef.last_worked,'1/1/1900') AND isnull(PersRef.Web_Updated,'1/1/1900') >= isnull(PersRef.last_updated,'1/1/1900') THEN PersRef.Web_Updated 
END)  >= @from_date AND
(CASE  
	WHEN isnull(PersRef.last_updated,'1/1/1900') >= isnull(PersRef.last_worked,'1/1/1900') AND isnull(PersRef.last_updated,'1/1/1900') >= isnull(PersRef.Web_Updated,'1/1/1900') THEN PersRef.last_updated  
	WHEN isnull(PersRef.last_worked,'1/1/1900') >= isnull(PersRef.last_updated,'1/1/1900') AND isnull(PersRef.last_worked,'1/1/1900') >= isnull(PersRef.Web_Updated,'1/1/1900') THEN PersRef.last_worked 
	WHEN isnull(PersRef.Web_Updated,'1/1/1900') >= isnull(PersRef.last_worked,'1/1/1900') AND isnull(PersRef.Web_Updated,'1/1/1900') >= isnull(PersRef.last_updated,'1/1/1900') THEN PersRef.Web_Updated 
END) < @to_date AND CLNO = @CLNO AND apstatus in ('W','F')
	AND  (CASE  
	WHEN isnull(PersRef.last_updated,'1/1/1900') >= isnull(PersRef.last_worked,'1/1/1900') AND isnull(PersRef.last_updated,'1/1/1900') >= isnull(PersRef.Web_Updated,'1/1/1900') THEN dbo.elapsedbusinessdays_2( PersRef.CreatedDate,PersRef.last_updated)  
	WHEN isnull(PersRef.last_worked,'1/1/1900') >= isnull(PersRef.last_updated,'1/1/1900') AND isnull(PersRef.last_worked,'1/1/1900') >= isnull(PersRef.Web_Updated,'1/1/1900') THEN dbo.elapsedbusinessdays_2( PersRef.CreatedDate,PersRef.last_worked) 
	WHEN isnull(PersRef.Web_Updated,'1/1/1900') >= isnull(PersRef.last_worked,'1/1/1900') AND isnull(PersRef.Web_Updated,'1/1/1900') >= isnull(PersRef.last_updated,'1/1/1900') THEN dbo.elapsedbusinessdays_2( PersRef.CreatedDate,PersRef.Web_Updated)
end) = 3 
--group by clno
	)  /
  (select count(PersRefid) from PersRef with (NOLOCK) JOIN appl with (NOLOCK) on appl.apno = PersRef.apno 
   where 
(CASE  
	WHEN isnull(PersRef.last_updated,'1/1/1900') >= isnull(PersRef.last_worked,'1/1/1900') AND isnull(PersRef.last_updated,'1/1/1900') >= isnull(PersRef.Web_Updated,'1/1/1900') THEN PersRef.last_updated  
	WHEN isnull(PersRef.last_worked,'1/1/1900') >= isnull(PersRef.last_updated,'1/1/1900') AND isnull(PersRef.last_worked,'1/1/1900') >= isnull(PersRef.Web_Updated,'1/1/1900') THEN PersRef.last_worked 
	WHEN isnull(PersRef.Web_Updated,'1/1/1900') >= isnull(PersRef.last_worked,'1/1/1900') AND isnull(PersRef.Web_Updated,'1/1/1900') >= isnull(PersRef.last_updated,'1/1/1900') THEN PersRef.Web_Updated 
END)  >= @from_date AND 
(CASE  
	WHEN isnull(PersRef.last_updated,'1/1/1900') >= isnull(PersRef.last_worked,'1/1/1900') AND isnull(PersRef.last_updated,'1/1/1900') >= isnull(PersRef.Web_Updated,'1/1/1900') THEN PersRef.last_updated  
	WHEN isnull(PersRef.last_worked,'1/1/1900') >= isnull(PersRef.last_updated,'1/1/1900') AND isnull(PersRef.last_worked,'1/1/1900') >= isnull(PersRef.Web_Updated,'1/1/1900') THEN PersRef.last_worked 
	WHEN isnull(PersRef.Web_Updated,'1/1/1900') >= isnull(PersRef.last_worked,'1/1/1900') AND isnull(PersRef.Web_Updated,'1/1/1900') >= isnull(PersRef.last_updated,'1/1/1900') THEN PersRef.Web_Updated 
END)  < @to_date AND CLNO = @CLNO AND apstatus in ('W','F')
  )AS NUMERIC( 7, 2 ) ) AS 'Percentage', 

CAST( 100. * (SELECT count(*) FROM PersRef with (NOLOCK)
	JOIN appl with (NOLOCK) on appl.apno = PersRef.apno
	WHERE 
(CASE  
	WHEN isnull(PersRef.last_updated,'1/1/1900') >= isnull(PersRef.last_worked,'1/1/1900') AND isnull(PersRef.last_updated,'1/1/1900') >= isnull(PersRef.Web_Updated,'1/1/1900') THEN PersRef.last_updated  
	WHEN isnull(PersRef.last_worked,'1/1/1900') >= isnull(PersRef.last_updated,'1/1/1900') AND isnull(PersRef.last_worked,'1/1/1900') >= isnull(PersRef.Web_Updated,'1/1/1900') THEN PersRef.last_worked 
	WHEN isnull(PersRef.Web_Updated,'1/1/1900') >= isnull(PersRef.last_worked,'1/1/1900') AND isnull(PersRef.Web_Updated,'1/1/1900') >= isnull(PersRef.last_updated,'1/1/1900') THEN PersRef.Web_Updated 
END)  >= @from_date AND 
(CASE  
	WHEN isnull(PersRef.last_updated,'1/1/1900') >= isnull(PersRef.last_worked,'1/1/1900') AND isnull(PersRef.last_updated,'1/1/1900') >= isnull(PersRef.Web_Updated,'1/1/1900') THEN PersRef.last_updated  
	WHEN isnull(PersRef.last_worked,'1/1/1900') >= isnull(PersRef.last_updated,'1/1/1900') AND isnull(PersRef.last_worked,'1/1/1900') >= isnull(PersRef.Web_Updated,'1/1/1900') THEN PersRef.last_worked 
	WHEN isnull(PersRef.Web_Updated,'1/1/1900') >= isnull(PersRef.last_worked,'1/1/1900') AND isnull(PersRef.Web_Updated,'1/1/1900') >= isnull(PersRef.last_updated,'1/1/1900') THEN PersRef.Web_Updated 
END)  < @to_date AND CLNO = @CLNO AND apstatus in ('W','F')
	AND  (CASE  
	WHEN isnull(PersRef.last_updated,'1/1/1900') >= isnull(PersRef.last_worked,'1/1/1900') AND isnull(PersRef.last_updated,'1/1/1900') >= isnull(PersRef.Web_Updated,'1/1/1900') THEN dbo.elapsedbusinessdays_2( PersRef.CreatedDate,PersRef.last_updated)  
	WHEN isnull(PersRef.last_worked,'1/1/1900') >= isnull(PersRef.last_updated,'1/1/1900') AND isnull(PersRef.last_worked,'1/1/1900') >= isnull(PersRef.Web_Updated,'1/1/1900') THEN dbo.elapsedbusinessdays_2( PersRef.CreatedDate,PersRef.last_worked) 
	WHEN isnull(PersRef.Web_Updated,'1/1/1900') >= isnull(PersRef.last_worked,'1/1/1900') AND isnull(PersRef.Web_Updated,'1/1/1900') >= isnull(PersRef.last_updated,'1/1/1900') THEN dbo.elapsedbusinessdays_2( PersRef.CreatedDate,PersRef.Web_Updated)
	END) <=3
--group by clno
	) / 
  (select count(PersRefid) from PersRef with (NOLOCK) JOIN appl with (NOLOCK) on appl.apno = PersRef.apno 
   where 
(CASE  
	WHEN isnull(PersRef.last_updated,'1/1/1900') >= isnull(PersRef.last_worked,'1/1/1900') AND isnull(PersRef.last_updated,'1/1/1900') >= isnull(PersRef.Web_Updated,'1/1/1900') THEN PersRef.last_updated  
	WHEN isnull(PersRef.last_worked,'1/1/1900') >= isnull(PersRef.last_updated,'1/1/1900') AND isnull(PersRef.last_worked,'1/1/1900') >= isnull(PersRef.Web_Updated,'1/1/1900') THEN PersRef.last_worked 
	WHEN isnull(PersRef.Web_Updated,'1/1/1900') >= isnull(PersRef.last_worked,'1/1/1900') AND isnull(PersRef.Web_Updated,'1/1/1900') >= isnull(PersRef.last_updated,'1/1/1900') THEN PersRef.Web_Updated 
END)  >= @from_date AND 
(CASE  
	WHEN isnull(PersRef.last_updated,'1/1/1900') >= isnull(PersRef.last_worked,'1/1/1900') AND isnull(PersRef.last_updated,'1/1/1900') >= isnull(PersRef.Web_Updated,'1/1/1900') THEN PersRef.last_updated  
	WHEN isnull(PersRef.last_worked,'1/1/1900') >= isnull(PersRef.last_updated,'1/1/1900') AND isnull(PersRef.last_worked,'1/1/1900') >= isnull(PersRef.Web_Updated,'1/1/1900') THEN PersRef.last_worked 
	WHEN isnull(PersRef.Web_Updated,'1/1/1900') >= isnull(PersRef.last_worked,'1/1/1900') AND isnull(PersRef.Web_Updated,'1/1/1900') >= isnull(PersRef.last_updated,'1/1/1900') THEN PersRef.Web_Updated 
END)  < @to_date AND CLNO = @CLNO AND apstatus in ('W','F')
  )AS NUMERIC( 7, 2 ) ) as 'Cumulative %'
FROM PersRef with (NOLOCK) JOIN appl with (NOLOCK) on appl.apno = PersRef.apno
WHERE  
(CASE  
	WHEN isnull(PersRef.last_updated,'1/1/1900') >= isnull(PersRef.last_worked,'1/1/1900') AND isnull(PersRef.last_updated,'1/1/1900') >= isnull(PersRef.Web_Updated,'1/1/1900') THEN PersRef.last_updated  
	WHEN isnull(PersRef.last_worked,'1/1/1900') >= isnull(PersRef.last_updated,'1/1/1900') AND isnull(PersRef.last_worked,'1/1/1900') >= isnull(PersRef.Web_Updated,'1/1/1900') THEN PersRef.last_worked 
	WHEN isnull(PersRef.Web_Updated,'1/1/1900') >= isnull(PersRef.last_worked,'1/1/1900') AND isnull(PersRef.Web_Updated,'1/1/1900') >= isnull(PersRef.last_updated,'1/1/1900') THEN PersRef.Web_Updated 
END)  >= @from_date AND 
(CASE  
	WHEN isnull(PersRef.last_updated,'1/1/1900') >= isnull(PersRef.last_worked,'1/1/1900') AND isnull(PersRef.last_updated,'1/1/1900') >= isnull(PersRef.Web_Updated,'1/1/1900') THEN PersRef.last_updated  
	WHEN isnull(PersRef.last_worked,'1/1/1900') >= isnull(PersRef.last_updated,'1/1/1900') AND isnull(PersRef.last_worked,'1/1/1900') >= isnull(PersRef.Web_Updated,'1/1/1900') THEN PersRef.last_worked 
	WHEN isnull(PersRef.Web_Updated,'1/1/1900') >= isnull(PersRef.last_worked,'1/1/1900') AND isnull(PersRef.Web_Updated,'1/1/1900') >= isnull(PersRef.last_updated,'1/1/1900') THEN PersRef.Web_Updated 
END) < @to_date AND  CLNO = @CLNO AND apstatus in ('W','F') 
--group by clno 


UNION

SELECT '4 days' AS 'Turnaround Time',( SELECT count(*) FROM PersRef with (NOLOCK)
JOIN appl with (NOLOCK) on appl.apno = PersRef.apno
WHERE
(CASE  
	WHEN isnull(PersRef.last_updated,'1/1/1900') >= isnull(PersRef.last_worked,'1/1/1900') AND isnull(PersRef.last_updated,'1/1/1900') >= isnull(PersRef.Web_Updated,'1/1/1900') THEN PersRef.last_updated   
	WHEN isnull(PersRef.last_worked,'1/1/1900') >= isnull(PersRef.last_updated,'1/1/1900') AND isnull(PersRef.last_worked,'1/1/1900') >= isnull(PersRef.Web_Updated,'1/1/1900') THEN PersRef.last_worked  
	WHEN isnull(PersRef.Web_Updated,'1/1/1900') >= isnull(PersRef.last_worked,'1/1/1900') AND isnull(PersRef.Web_Updated,'1/1/1900') >= isnull(PersRef.last_updated,'1/1/1900') THEN PersRef.Web_Updated  
END) >= @from_date
AND
(CASE  
	WHEN isnull(PersRef.last_updated,'1/1/1900') >= isnull(PersRef.last_worked,'1/1/1900') AND isnull(PersRef.last_updated,'1/1/1900') >= isnull(PersRef.Web_Updated,'1/1/1900') THEN PersRef.last_updated  
	WHEN isnull(PersRef.last_worked,'1/1/1900') >= isnull(PersRef.last_updated,'1/1/1900') AND isnull(PersRef.last_worked,'1/1/1900') >= isnull(PersRef.Web_Updated,'1/1/1900') THEN PersRef.last_worked 
	WHEN isnull(PersRef.Web_Updated,'1/1/1900') >= isnull(PersRef.last_worked,'1/1/1900') AND isnull(PersRef.Web_Updated,'1/1/1900') >= isnull(PersRef.last_updated,'1/1/1900') THEN PersRef.Web_Updated 
END)  < @to_date
AND CLNO = @CLNO AND apstatus in ('W','F')
AND (CASE  
	WHEN isnull(PersRef.last_updated,'1/1/1900') >= isnull(PersRef.last_worked,'1/1/1900') AND isnull(PersRef.last_updated,'1/1/1900') >= isnull(PersRef.Web_Updated,'1/1/1900') THEN dbo.elapsedbusinessdays_2( PersRef.CreatedDate,PersRef.last_updated)  
	WHEN isnull(PersRef.last_worked,'1/1/1900') >= isnull(PersRef.last_updated,'1/1/1900') AND isnull(PersRef.last_worked,'1/1/1900') >= isnull(PersRef.Web_Updated,'1/1/1900') THEN dbo.elapsedbusinessdays_2( PersRef.CreatedDate,PersRef.last_worked) 
	WHEN isnull(PersRef.Web_Updated,'1/1/1900') >= isnull(PersRef.last_worked,'1/1/1900') AND isnull(PersRef.Web_Updated,'1/1/1900') >= isnull(PersRef.last_updated,'1/1/1900') THEN dbo.elapsedbusinessdays_2( PersRef.CreatedDate,PersRef.Web_Updated)
END) = 4
--group by clno
) as 'Count'
, CAST( 100. * (SELECT count(*) FROM PersRef with (NOLOCK)
	JOIN appl with (NOLOCK) on appl.apno = PersRef.apno
	WHERE 
(CASE  
	WHEN isnull(PersRef.last_updated,'1/1/1900') >= isnull(PersRef.last_worked,'1/1/1900') AND isnull(PersRef.last_updated,'1/1/1900') >= isnull(PersRef.Web_Updated,'1/1/1900') THEN PersRef.last_updated  
	WHEN isnull(PersRef.last_worked,'1/1/1900') >= isnull(PersRef.last_updated,'1/1/1900') AND isnull(PersRef.last_worked,'1/1/1900') >= isnull(PersRef.Web_Updated,'1/1/1900') THEN PersRef.last_worked 
	WHEN isnull(PersRef.Web_Updated,'1/1/1900') >= isnull(PersRef.last_worked,'1/1/1900') AND isnull(PersRef.Web_Updated,'1/1/1900') >= isnull(PersRef.last_updated,'1/1/1900') THEN PersRef.Web_Updated 
END)  >= @from_date AND
(CASE  
	WHEN isnull(PersRef.last_updated,'1/1/1900') >= isnull(PersRef.last_worked,'1/1/1900') AND isnull(PersRef.last_updated,'1/1/1900') >= isnull(PersRef.Web_Updated,'1/1/1900') THEN PersRef.last_updated  
	WHEN isnull(PersRef.last_worked,'1/1/1900') >= isnull(PersRef.last_updated,'1/1/1900') AND isnull(PersRef.last_worked,'1/1/1900') >= isnull(PersRef.Web_Updated,'1/1/1900') THEN PersRef.last_worked 
	WHEN isnull(PersRef.Web_Updated,'1/1/1900') >= isnull(PersRef.last_worked,'1/1/1900') AND isnull(PersRef.Web_Updated,'1/1/1900') >= isnull(PersRef.last_updated,'1/1/1900') THEN PersRef.Web_Updated 
END) < @to_date AND CLNO = @CLNO AND apstatus in ('W','F')
	AND  (CASE  
	WHEN isnull(PersRef.last_updated,'1/1/1900') >= isnull(PersRef.last_worked,'1/1/1900') AND isnull(PersRef.last_updated,'1/1/1900') >= isnull(PersRef.Web_Updated,'1/1/1900') THEN dbo.elapsedbusinessdays_2( PersRef.CreatedDate,PersRef.last_updated)  
	WHEN isnull(PersRef.last_worked,'1/1/1900') >= isnull(PersRef.last_updated,'1/1/1900') AND isnull(PersRef.last_worked,'1/1/1900') >= isnull(PersRef.Web_Updated,'1/1/1900') THEN dbo.elapsedbusinessdays_2( PersRef.CreatedDate,PersRef.last_worked) 
	WHEN isnull(PersRef.Web_Updated,'1/1/1900') >= isnull(PersRef.last_worked,'1/1/1900') AND isnull(PersRef.Web_Updated,'1/1/1900') >= isnull(PersRef.last_updated,'1/1/1900') THEN dbo.elapsedbusinessdays_2( PersRef.CreatedDate,PersRef.Web_Updated)
end) = 4 
--group by clno
	)  /
  (select count(PersRefid) from PersRef with (NOLOCK) JOIN appl with (NOLOCK) on appl.apno = PersRef.apno 
   where 
(CASE  
	WHEN isnull(PersRef.last_updated,'1/1/1900') >= isnull(PersRef.last_worked,'1/1/1900') AND isnull(PersRef.last_updated,'1/1/1900') >= isnull(PersRef.Web_Updated,'1/1/1900') THEN PersRef.last_updated  
	WHEN isnull(PersRef.last_worked,'1/1/1900') >= isnull(PersRef.last_updated,'1/1/1900') AND isnull(PersRef.last_worked,'1/1/1900') >= isnull(PersRef.Web_Updated,'1/1/1900') THEN PersRef.last_worked 
	WHEN isnull(PersRef.Web_Updated,'1/1/1900') >= isnull(PersRef.last_worked,'1/1/1900') AND isnull(PersRef.Web_Updated,'1/1/1900') >= isnull(PersRef.last_updated,'1/1/1900') THEN PersRef.Web_Updated 
END)  >= @from_date AND 
(CASE  
	WHEN isnull(PersRef.last_updated,'1/1/1900') >= isnull(PersRef.last_worked,'1/1/1900') AND isnull(PersRef.last_updated,'1/1/1900') >= isnull(PersRef.Web_Updated,'1/1/1900') THEN PersRef.last_updated  
	WHEN isnull(PersRef.last_worked,'1/1/1900') >= isnull(PersRef.last_updated,'1/1/1900') AND isnull(PersRef.last_worked,'1/1/1900') >= isnull(PersRef.Web_Updated,'1/1/1900') THEN PersRef.last_worked 
	WHEN isnull(PersRef.Web_Updated,'1/1/1900') >= isnull(PersRef.last_worked,'1/1/1900') AND isnull(PersRef.Web_Updated,'1/1/1900') >= isnull(PersRef.last_updated,'1/1/1900') THEN PersRef.Web_Updated 
END)  < @to_date AND CLNO = @CLNO AND apstatus in ('W','F')
  )AS NUMERIC( 7, 2 ) ) AS 'Percentage',

CAST( 100. * (SELECT count(*) FROM PersRef with (NOLOCK)
	JOIN appl with (NOLOCK) on appl.apno = PersRef.apno
	WHERE 
(CASE  
	WHEN isnull(PersRef.last_updated,'1/1/1900') >= isnull(PersRef.last_worked,'1/1/1900') AND isnull(PersRef.last_updated,'1/1/1900') >= isnull(PersRef.Web_Updated,'1/1/1900') THEN PersRef.last_updated  
	WHEN isnull(PersRef.last_worked,'1/1/1900') >= isnull(PersRef.last_updated,'1/1/1900') AND isnull(PersRef.last_worked,'1/1/1900') >= isnull(PersRef.Web_Updated,'1/1/1900') THEN PersRef.last_worked 
	WHEN isnull(PersRef.Web_Updated,'1/1/1900') >= isnull(PersRef.last_worked,'1/1/1900') AND isnull(PersRef.Web_Updated,'1/1/1900') >= isnull(PersRef.last_updated,'1/1/1900') THEN PersRef.Web_Updated 
END)  >= @from_date AND 
(CASE  
	WHEN isnull(PersRef.last_updated,'1/1/1900') >= isnull(PersRef.last_worked,'1/1/1900') AND isnull(PersRef.last_updated,'1/1/1900') >= isnull(PersRef.Web_Updated,'1/1/1900') THEN PersRef.last_updated  
	WHEN isnull(PersRef.last_worked,'1/1/1900') >= isnull(PersRef.last_updated,'1/1/1900') AND isnull(PersRef.last_worked,'1/1/1900') >= isnull(PersRef.Web_Updated,'1/1/1900') THEN PersRef.last_worked 
	WHEN isnull(PersRef.Web_Updated,'1/1/1900') >= isnull(PersRef.last_worked,'1/1/1900') AND isnull(PersRef.Web_Updated,'1/1/1900') >= isnull(PersRef.last_updated,'1/1/1900') THEN PersRef.Web_Updated 
END)  < @to_date AND CLNO = @CLNO AND apstatus in ('W','F')
	AND  (CASE  
	WHEN isnull(PersRef.last_updated,'1/1/1900') >= isnull(PersRef.last_worked,'1/1/1900') AND isnull(PersRef.last_updated,'1/1/1900') >= isnull(PersRef.Web_Updated,'1/1/1900') THEN dbo.elapsedbusinessdays_2( PersRef.CreatedDate,PersRef.last_updated)  
	WHEN isnull(PersRef.last_worked,'1/1/1900') >= isnull(PersRef.last_updated,'1/1/1900') AND isnull(PersRef.last_worked,'1/1/1900') >= isnull(PersRef.Web_Updated,'1/1/1900') THEN dbo.elapsedbusinessdays_2( PersRef.CreatedDate,PersRef.last_worked) 
	WHEN isnull(PersRef.Web_Updated,'1/1/1900') >= isnull(PersRef.last_worked,'1/1/1900') AND isnull(PersRef.Web_Updated,'1/1/1900') >= isnull(PersRef.last_updated,'1/1/1900') THEN dbo.elapsedbusinessdays_2( PersRef.CreatedDate,PersRef.Web_Updated)
	END) <= 4
-- group by clno
	) / 
  (select count(PersRefid) from PersRef with (NOLOCK) JOIN appl with (NOLOCK) on appl.apno = PersRef.apno 
   where 
(CASE  
	WHEN isnull(PersRef.last_updated,'1/1/1900') >= isnull(PersRef.last_worked,'1/1/1900') AND isnull(PersRef.last_updated,'1/1/1900') >= isnull(PersRef.Web_Updated,'1/1/1900') THEN PersRef.last_updated  
	WHEN isnull(PersRef.last_worked,'1/1/1900') >= isnull(PersRef.last_updated,'1/1/1900') AND isnull(PersRef.last_worked,'1/1/1900') >= isnull(PersRef.Web_Updated,'1/1/1900') THEN PersRef.last_worked 
	WHEN isnull(PersRef.Web_Updated,'1/1/1900') >= isnull(PersRef.last_worked,'1/1/1900') AND isnull(PersRef.Web_Updated,'1/1/1900') >= isnull(PersRef.last_updated,'1/1/1900') THEN PersRef.Web_Updated 
END)  >= @from_date AND 
(CASE  
	WHEN isnull(PersRef.last_updated,'1/1/1900') >= isnull(PersRef.last_worked,'1/1/1900') AND isnull(PersRef.last_updated,'1/1/1900') >= isnull(PersRef.Web_Updated,'1/1/1900') THEN PersRef.last_updated  
	WHEN isnull(PersRef.last_worked,'1/1/1900') >= isnull(PersRef.last_updated,'1/1/1900') AND isnull(PersRef.last_worked,'1/1/1900') >= isnull(PersRef.Web_Updated,'1/1/1900') THEN PersRef.last_worked 
	WHEN isnull(PersRef.Web_Updated,'1/1/1900') >= isnull(PersRef.last_worked,'1/1/1900') AND isnull(PersRef.Web_Updated,'1/1/1900') >= isnull(PersRef.last_updated,'1/1/1900') THEN PersRef.Web_Updated 
END)  < @to_date AND CLNO = @CLNO AND apstatus in ('W','F')
  )AS NUMERIC( 7, 2 ) ) as 'Cumulative %'
FROM PersRef with (NOLOCK) JOIN appl with (NOLOCK) on appl.apno = PersRef.apno
WHERE  
(CASE  
	WHEN isnull(PersRef.last_updated,'1/1/1900') >= isnull(PersRef.last_worked,'1/1/1900') AND isnull(PersRef.last_updated,'1/1/1900') >= isnull(PersRef.Web_Updated,'1/1/1900') THEN PersRef.last_updated  
	WHEN isnull(PersRef.last_worked,'1/1/1900') >= isnull(PersRef.last_updated,'1/1/1900') AND isnull(PersRef.last_worked,'1/1/1900') >= isnull(PersRef.Web_Updated,'1/1/1900') THEN PersRef.last_worked 
	WHEN isnull(PersRef.Web_Updated,'1/1/1900') >= isnull(PersRef.last_worked,'1/1/1900') AND isnull(PersRef.Web_Updated,'1/1/1900') >= isnull(PersRef.last_updated,'1/1/1900') THEN PersRef.Web_Updated 
END)  >= @from_date AND 
(CASE  
	WHEN isnull(PersRef.last_updated,'1/1/1900') >= isnull(PersRef.last_worked,'1/1/1900') AND isnull(PersRef.last_updated,'1/1/1900') >= isnull(PersRef.Web_Updated,'1/1/1900') THEN PersRef.last_updated  
	WHEN isnull(PersRef.last_worked,'1/1/1900') >= isnull(PersRef.last_updated,'1/1/1900') AND isnull(PersRef.last_worked,'1/1/1900') >= isnull(PersRef.Web_Updated,'1/1/1900') THEN PersRef.last_worked 
	WHEN isnull(PersRef.Web_Updated,'1/1/1900') >= isnull(PersRef.last_worked,'1/1/1900') AND isnull(PersRef.Web_Updated,'1/1/1900') >= isnull(PersRef.last_updated,'1/1/1900') THEN PersRef.Web_Updated 
END) < @to_date AND  CLNO = @CLNO AND apstatus in ('W','F') 
--group by clno 

UNION

SELECT '5 days' AS 'Turnaround Time',( SELECT count(*) FROM PersRef with (NOLOCK)
JOIN appl with (NOLOCK) on appl.apno = PersRef.apno
WHERE
(CASE  
	WHEN isnull(PersRef.last_updated,'1/1/1900') >= isnull(PersRef.last_worked,'1/1/1900') AND isnull(PersRef.last_updated,'1/1/1900') >= isnull(PersRef.Web_Updated,'1/1/1900') THEN PersRef.last_updated   
	WHEN isnull(PersRef.last_worked,'1/1/1900') >= isnull(PersRef.last_updated,'1/1/1900') AND isnull(PersRef.last_worked,'1/1/1900') >= isnull(PersRef.Web_Updated,'1/1/1900') THEN PersRef.last_worked  
	WHEN isnull(PersRef.Web_Updated,'1/1/1900') >= isnull(PersRef.last_worked,'1/1/1900') AND isnull(PersRef.Web_Updated,'1/1/1900') >= isnull(PersRef.last_updated,'1/1/1900') THEN PersRef.Web_Updated  
END) >= @from_date
AND
(CASE  
	WHEN isnull(PersRef.last_updated,'1/1/1900') >= isnull(PersRef.last_worked,'1/1/1900') AND isnull(PersRef.last_updated,'1/1/1900') >= isnull(PersRef.Web_Updated,'1/1/1900') THEN PersRef.last_updated  
	WHEN isnull(PersRef.last_worked,'1/1/1900') >= isnull(PersRef.last_updated,'1/1/1900') AND isnull(PersRef.last_worked,'1/1/1900') >= isnull(PersRef.Web_Updated,'1/1/1900') THEN PersRef.last_worked 
	WHEN isnull(PersRef.Web_Updated,'1/1/1900') >= isnull(PersRef.last_worked,'1/1/1900') AND isnull(PersRef.Web_Updated,'1/1/1900') >= isnull(PersRef.last_updated,'1/1/1900') THEN PersRef.Web_Updated 
END)  < @to_date
AND CLNO = @CLNO AND apstatus in ('W','F')
AND (CASE  
	WHEN isnull(PersRef.last_updated,'1/1/1900') >= isnull(PersRef.last_worked,'1/1/1900') AND isnull(PersRef.last_updated,'1/1/1900') >= isnull(PersRef.Web_Updated,'1/1/1900') THEN dbo.elapsedbusinessdays_2( PersRef.CreatedDate,PersRef.last_updated)  
	WHEN isnull(PersRef.last_worked,'1/1/1900') >= isnull(PersRef.last_updated,'1/1/1900') AND isnull(PersRef.last_worked,'1/1/1900') >= isnull(PersRef.Web_Updated,'1/1/1900') THEN dbo.elapsedbusinessdays_2( PersRef.CreatedDate,PersRef.last_worked) 
	WHEN isnull(PersRef.Web_Updated,'1/1/1900') >= isnull(PersRef.last_worked,'1/1/1900') AND isnull(PersRef.Web_Updated,'1/1/1900') >= isnull(PersRef.last_updated,'1/1/1900') THEN dbo.elapsedbusinessdays_2( PersRef.CreatedDate,PersRef.Web_Updated)
END) = 5
--group by clno
) as 'Count'
, CAST( 100. * (SELECT count(*) FROM PersRef with (NOLOCK)
	JOIN appl with (NOLOCK) on appl.apno = PersRef.apno
	WHERE 
(CASE  
	WHEN isnull(PersRef.last_updated,'1/1/1900') >= isnull(PersRef.last_worked,'1/1/1900') AND isnull(PersRef.last_updated,'1/1/1900') >= isnull(PersRef.Web_Updated,'1/1/1900') THEN PersRef.last_updated  
	WHEN isnull(PersRef.last_worked,'1/1/1900') >= isnull(PersRef.last_updated,'1/1/1900') AND isnull(PersRef.last_worked,'1/1/1900') >= isnull(PersRef.Web_Updated,'1/1/1900') THEN PersRef.last_worked 
	WHEN isnull(PersRef.Web_Updated,'1/1/1900') >= isnull(PersRef.last_worked,'1/1/1900') AND isnull(PersRef.Web_Updated,'1/1/1900') >= isnull(PersRef.last_updated,'1/1/1900') THEN PersRef.Web_Updated 
END)  >= @from_date AND
(CASE  
	WHEN isnull(PersRef.last_updated,'1/1/1900') >= isnull(PersRef.last_worked,'1/1/1900') AND isnull(PersRef.last_updated,'1/1/1900') >= isnull(PersRef.Web_Updated,'1/1/1900') THEN PersRef.last_updated  
	WHEN isnull(PersRef.last_worked,'1/1/1900') >= isnull(PersRef.last_updated,'1/1/1900') AND isnull(PersRef.last_worked,'1/1/1900') >= isnull(PersRef.Web_Updated,'1/1/1900') THEN PersRef.last_worked 
	WHEN isnull(PersRef.Web_Updated,'1/1/1900') >= isnull(PersRef.last_worked,'1/1/1900') AND isnull(PersRef.Web_Updated,'1/1/1900') >= isnull(PersRef.last_updated,'1/1/1900') THEN PersRef.Web_Updated 
END) < @to_date AND CLNO = @CLNO AND apstatus in ('W','F')
	AND  (CASE  
	WHEN isnull(PersRef.last_updated,'1/1/1900') >= isnull(PersRef.last_worked,'1/1/1900') AND isnull(PersRef.last_updated,'1/1/1900') >= isnull(PersRef.Web_Updated,'1/1/1900') THEN dbo.elapsedbusinessdays_2( PersRef.CreatedDate,PersRef.last_updated)  
	WHEN isnull(PersRef.last_worked,'1/1/1900') >= isnull(PersRef.last_updated,'1/1/1900') AND isnull(PersRef.last_worked,'1/1/1900') >= isnull(PersRef.Web_Updated,'1/1/1900') THEN dbo.elapsedbusinessdays_2( PersRef.CreatedDate,PersRef.last_worked) 
	WHEN isnull(PersRef.Web_Updated,'1/1/1900') >= isnull(PersRef.last_worked,'1/1/1900') AND isnull(PersRef.Web_Updated,'1/1/1900') >= isnull(PersRef.last_updated,'1/1/1900') THEN dbo.elapsedbusinessdays_2( PersRef.CreatedDate,PersRef.Web_Updated)
end) = 5 
--group by clno
	)  /
  (select count(PersRefid) from PersRef with (NOLOCK) JOIN appl with (NOLOCK) on appl.apno = PersRef.apno 
   where 
(CASE  
	WHEN isnull(PersRef.last_updated,'1/1/1900') >= isnull(PersRef.last_worked,'1/1/1900') AND isnull(PersRef.last_updated,'1/1/1900') >= isnull(PersRef.Web_Updated,'1/1/1900') THEN PersRef.last_updated  
	WHEN isnull(PersRef.last_worked,'1/1/1900') >= isnull(PersRef.last_updated,'1/1/1900') AND isnull(PersRef.last_worked,'1/1/1900') >= isnull(PersRef.Web_Updated,'1/1/1900') THEN PersRef.last_worked 
	WHEN isnull(PersRef.Web_Updated,'1/1/1900') >= isnull(PersRef.last_worked,'1/1/1900') AND isnull(PersRef.Web_Updated,'1/1/1900') >= isnull(PersRef.last_updated,'1/1/1900') THEN PersRef.Web_Updated 
END)  >= @from_date AND 
(CASE  
	WHEN isnull(PersRef.last_updated,'1/1/1900') >= isnull(PersRef.last_worked,'1/1/1900') AND isnull(PersRef.last_updated,'1/1/1900') >= isnull(PersRef.Web_Updated,'1/1/1900') THEN PersRef.last_updated  
	WHEN isnull(PersRef.last_worked,'1/1/1900') >= isnull(PersRef.last_updated,'1/1/1900') AND isnull(PersRef.last_worked,'1/1/1900') >= isnull(PersRef.Web_Updated,'1/1/1900') THEN PersRef.last_worked 
	WHEN isnull(PersRef.Web_Updated,'1/1/1900') >= isnull(PersRef.last_worked,'1/1/1900') AND isnull(PersRef.Web_Updated,'1/1/1900') >= isnull(PersRef.last_updated,'1/1/1900') THEN PersRef.Web_Updated 
END)  < @to_date AND CLNO = @CLNO AND apstatus in ('W','F')
  )AS NUMERIC( 7, 2 ) ) AS 'Percentage',

CAST( 100. * (SELECT count(*) FROM PersRef with (NOLOCK)
	JOIN appl with (NOLOCK) on appl.apno = PersRef.apno
	WHERE 
(CASE  
	WHEN isnull(PersRef.last_updated,'1/1/1900') >= isnull(PersRef.last_worked,'1/1/1900') AND isnull(PersRef.last_updated,'1/1/1900') >= isnull(PersRef.Web_Updated,'1/1/1900') THEN PersRef.last_updated  
	WHEN isnull(PersRef.last_worked,'1/1/1900') >= isnull(PersRef.last_updated,'1/1/1900') AND isnull(PersRef.last_worked,'1/1/1900') >= isnull(PersRef.Web_Updated,'1/1/1900') THEN PersRef.last_worked 
	WHEN isnull(PersRef.Web_Updated,'1/1/1900') >= isnull(PersRef.last_worked,'1/1/1900') AND isnull(PersRef.Web_Updated,'1/1/1900') >= isnull(PersRef.last_updated,'1/1/1900') THEN PersRef.Web_Updated 
END)  >= @from_date AND 
(CASE  
	WHEN isnull(PersRef.last_updated,'1/1/1900') >= isnull(PersRef.last_worked,'1/1/1900') AND isnull(PersRef.last_updated,'1/1/1900') >= isnull(PersRef.Web_Updated,'1/1/1900') THEN PersRef.last_updated  
	WHEN isnull(PersRef.last_worked,'1/1/1900') >= isnull(PersRef.last_updated,'1/1/1900') AND isnull(PersRef.last_worked,'1/1/1900') >= isnull(PersRef.Web_Updated,'1/1/1900') THEN PersRef.last_worked 
	WHEN isnull(PersRef.Web_Updated,'1/1/1900') >= isnull(PersRef.last_worked,'1/1/1900') AND isnull(PersRef.Web_Updated,'1/1/1900') >= isnull(PersRef.last_updated,'1/1/1900') THEN PersRef.Web_Updated 
END)  < @to_date AND CLNO = @CLNO AND apstatus in ('W','F')
	AND  (CASE  
	WHEN isnull(PersRef.last_updated,'1/1/1900') >= isnull(PersRef.last_worked,'1/1/1900') AND isnull(PersRef.last_updated,'1/1/1900') >= isnull(PersRef.Web_Updated,'1/1/1900') THEN dbo.elapsedbusinessdays_2( PersRef.CreatedDate,PersRef.last_updated)  
	WHEN isnull(PersRef.last_worked,'1/1/1900') >= isnull(PersRef.last_updated,'1/1/1900') AND isnull(PersRef.last_worked,'1/1/1900') >= isnull(PersRef.Web_Updated,'1/1/1900') THEN dbo.elapsedbusinessdays_2( PersRef.CreatedDate,PersRef.last_worked) 
	WHEN isnull(PersRef.Web_Updated,'1/1/1900') >= isnull(PersRef.last_worked,'1/1/1900') AND isnull(PersRef.Web_Updated,'1/1/1900') >= isnull(PersRef.last_updated,'1/1/1900') THEN dbo.elapsedbusinessdays_2( PersRef.CreatedDate,PersRef.Web_Updated)
	END) <= 5
-- group by clno
	) / 
  (select count(PersRefid) from PersRef with (NOLOCK) JOIN appl with (NOLOCK) on appl.apno = PersRef.apno 
   where 
(CASE  
	WHEN isnull(PersRef.last_updated,'1/1/1900') >= isnull(PersRef.last_worked,'1/1/1900') AND isnull(PersRef.last_updated,'1/1/1900') >= isnull(PersRef.Web_Updated,'1/1/1900') THEN PersRef.last_updated  
	WHEN isnull(PersRef.last_worked,'1/1/1900') >= isnull(PersRef.last_updated,'1/1/1900') AND isnull(PersRef.last_worked,'1/1/1900') >= isnull(PersRef.Web_Updated,'1/1/1900') THEN PersRef.last_worked 
	WHEN isnull(PersRef.Web_Updated,'1/1/1900') >= isnull(PersRef.last_worked,'1/1/1900') AND isnull(PersRef.Web_Updated,'1/1/1900') >= isnull(PersRef.last_updated,'1/1/1900') THEN PersRef.Web_Updated 
END)  >= @from_date AND 
(CASE  
	WHEN isnull(PersRef.last_updated,'1/1/1900') >= isnull(PersRef.last_worked,'1/1/1900') AND isnull(PersRef.last_updated,'1/1/1900') >= isnull(PersRef.Web_Updated,'1/1/1900') THEN PersRef.last_updated  
	WHEN isnull(PersRef.last_worked,'1/1/1900') >= isnull(PersRef.last_updated,'1/1/1900') AND isnull(PersRef.last_worked,'1/1/1900') >= isnull(PersRef.Web_Updated,'1/1/1900') THEN PersRef.last_worked 
	WHEN isnull(PersRef.Web_Updated,'1/1/1900') >= isnull(PersRef.last_worked,'1/1/1900') AND isnull(PersRef.Web_Updated,'1/1/1900') >= isnull(PersRef.last_updated,'1/1/1900') THEN PersRef.Web_Updated 
END)  < @to_date AND CLNO = @CLNO AND apstatus in ('W','F')
  )AS NUMERIC( 7, 2 ) ) as 'Cumulative %'
FROM PersRef with (NOLOCK) JOIN appl with (NOLOCK) on appl.apno = PersRef.apno
WHERE  
(CASE  
	WHEN isnull(PersRef.last_updated,'1/1/1900') >= isnull(PersRef.last_worked,'1/1/1900') AND isnull(PersRef.last_updated,'1/1/1900') >= isnull(PersRef.Web_Updated,'1/1/1900') THEN PersRef.last_updated  
	WHEN isnull(PersRef.last_worked,'1/1/1900') >= isnull(PersRef.last_updated,'1/1/1900') AND isnull(PersRef.last_worked,'1/1/1900') >= isnull(PersRef.Web_Updated,'1/1/1900') THEN PersRef.last_worked 
	WHEN isnull(PersRef.Web_Updated,'1/1/1900') >= isnull(PersRef.last_worked,'1/1/1900') AND isnull(PersRef.Web_Updated,'1/1/1900') >= isnull(PersRef.last_updated,'1/1/1900') THEN PersRef.Web_Updated 
END)  >= @from_date AND 
(CASE  
	WHEN isnull(PersRef.last_updated,'1/1/1900') >= isnull(PersRef.last_worked,'1/1/1900') AND isnull(PersRef.last_updated,'1/1/1900') >= isnull(PersRef.Web_Updated,'1/1/1900') THEN PersRef.last_updated  
	WHEN isnull(PersRef.last_worked,'1/1/1900') >= isnull(PersRef.last_updated,'1/1/1900') AND isnull(PersRef.last_worked,'1/1/1900') >= isnull(PersRef.Web_Updated,'1/1/1900') THEN PersRef.last_worked 
	WHEN isnull(PersRef.Web_Updated,'1/1/1900') >= isnull(PersRef.last_worked,'1/1/1900') AND isnull(PersRef.Web_Updated,'1/1/1900') >= isnull(PersRef.last_updated,'1/1/1900') THEN PersRef.Web_Updated 
END) < @to_date AND  CLNO = @CLNO AND apstatus in ('W','F') 
--group by clno 

UNION

SELECT '6+ days' AS 'Turnaround Time',( SELECT count(*) FROM PersRef with (NOLOCK)
JOIN appl with (NOLOCK) on appl.apno = PersRef.apno
WHERE
(CASE  
	WHEN isnull(PersRef.last_updated,'1/1/1900') >= isnull(PersRef.last_worked,'1/1/1900') AND isnull(PersRef.last_updated,'1/1/1900') >= isnull(PersRef.Web_Updated,'1/1/1900') THEN PersRef.last_updated   
	WHEN isnull(PersRef.last_worked,'1/1/1900') >= isnull(PersRef.last_updated,'1/1/1900') AND isnull(PersRef.last_worked,'1/1/1900') >= isnull(PersRef.Web_Updated,'1/1/1900') THEN PersRef.last_worked  
	WHEN isnull(PersRef.Web_Updated,'1/1/1900') >= isnull(PersRef.last_worked,'1/1/1900') AND isnull(PersRef.Web_Updated,'1/1/1900') >= isnull(PersRef.last_updated,'1/1/1900') THEN PersRef.Web_Updated  
END) >= @from_date
AND
(CASE  
	WHEN isnull(PersRef.last_updated,'1/1/1900') >= isnull(PersRef.last_worked,'1/1/1900') AND isnull(PersRef.last_updated,'1/1/1900') >= isnull(PersRef.Web_Updated,'1/1/1900') THEN PersRef.last_updated  
	WHEN isnull(PersRef.last_worked,'1/1/1900') >= isnull(PersRef.last_updated,'1/1/1900') AND isnull(PersRef.last_worked,'1/1/1900') >= isnull(PersRef.Web_Updated,'1/1/1900') THEN PersRef.last_worked 
	WHEN isnull(PersRef.Web_Updated,'1/1/1900') >= isnull(PersRef.last_worked,'1/1/1900') AND isnull(PersRef.Web_Updated,'1/1/1900') >= isnull(PersRef.last_updated,'1/1/1900') THEN PersRef.Web_Updated 
END)  < @to_date
AND CLNO = @CLNO
AND apstatus in ('W','F')
AND (CASE  
	WHEN isnull(PersRef.last_updated,'1/1/1900') >= isnull(PersRef.last_worked,'1/1/1900') AND isnull(PersRef.last_updated,'1/1/1900') >= isnull(PersRef.Web_Updated,'1/1/1900') THEN dbo.elapsedbusinessdays_2( PersRef.CreatedDate,PersRef.last_updated)  
	WHEN isnull(PersRef.last_worked,'1/1/1900') >= isnull(PersRef.last_updated,'1/1/1900') AND isnull(PersRef.last_worked,'1/1/1900') >= isnull(PersRef.Web_Updated,'1/1/1900') THEN dbo.elapsedbusinessdays_2( PersRef.CreatedDate,PersRef.last_worked) 
	WHEN isnull(PersRef.Web_Updated,'1/1/1900') >= isnull(PersRef.last_worked,'1/1/1900') AND isnull(PersRef.Web_Updated,'1/1/1900') >= isnull(PersRef.last_updated,'1/1/1900') THEN dbo.elapsedbusinessdays_2( PersRef.CreatedDate,PersRef.Web_Updated)
END) >=6
--group by clno
) as 'Count'
, CAST( 100. * (SELECT count(*) FROM PersRef with (NOLOCK)
	JOIN appl with (NOLOCK) on appl.apno = PersRef.apno
	WHERE 
(CASE  
	WHEN isnull(PersRef.last_updated,'1/1/1900') >= isnull(PersRef.last_worked,'1/1/1900') AND isnull(PersRef.last_updated,'1/1/1900') >= isnull(PersRef.Web_Updated,'1/1/1900') THEN PersRef.last_updated  
	WHEN isnull(PersRef.last_worked,'1/1/1900') >= isnull(PersRef.last_updated,'1/1/1900') AND isnull(PersRef.last_worked,'1/1/1900') >= isnull(PersRef.Web_Updated,'1/1/1900') THEN PersRef.last_worked 
	WHEN isnull(PersRef.Web_Updated,'1/1/1900') >= isnull(PersRef.last_worked,'1/1/1900') AND isnull(PersRef.Web_Updated,'1/1/1900') >= isnull(PersRef.last_updated,'1/1/1900') THEN PersRef.Web_Updated 
END)  >= @from_date AND
(CASE  
	WHEN isnull(PersRef.last_updated,'1/1/1900') >= isnull(PersRef.last_worked,'1/1/1900') AND isnull(PersRef.last_updated,'1/1/1900') >= isnull(PersRef.Web_Updated,'1/1/1900') THEN PersRef.last_updated  
	WHEN isnull(PersRef.last_worked,'1/1/1900') >= isnull(PersRef.last_updated,'1/1/1900') AND isnull(PersRef.last_worked,'1/1/1900') >= isnull(PersRef.Web_Updated,'1/1/1900') THEN PersRef.last_worked 
	WHEN isnull(PersRef.Web_Updated,'1/1/1900') >= isnull(PersRef.last_worked,'1/1/1900') AND isnull(PersRef.Web_Updated,'1/1/1900') >= isnull(PersRef.last_updated,'1/1/1900') THEN PersRef.Web_Updated 
END) < @to_date AND CLNO = @CLNO AND apstatus in ('W','F')
	AND  (CASE  
	WHEN isnull(PersRef.last_updated,'1/1/1900') >= isnull(PersRef.last_worked,'1/1/1900') AND isnull(PersRef.last_updated,'1/1/1900') >= isnull(PersRef.Web_Updated,'1/1/1900') THEN dbo.elapsedbusinessdays_2( PersRef.CreatedDate,PersRef.last_updated)  
	WHEN isnull(PersRef.last_worked,'1/1/1900') >= isnull(PersRef.last_updated,'1/1/1900') AND isnull(PersRef.last_worked,'1/1/1900') >= isnull(PersRef.Web_Updated,'1/1/1900') THEN dbo.elapsedbusinessdays_2( PersRef.CreatedDate,PersRef.last_worked) 
	WHEN isnull(PersRef.Web_Updated,'1/1/1900') >= isnull(PersRef.last_worked,'1/1/1900') AND isnull(PersRef.Web_Updated,'1/1/1900') >= isnull(PersRef.last_updated,'1/1/1900') THEN dbo.elapsedbusinessdays_2( PersRef.CreatedDate,PersRef.Web_Updated)
end) >=6 
--group by clno
	)  /
  (select count(PersRefid) from PersRef with (NOLOCK) JOIN appl with (NOLOCK) on appl.apno = PersRef.apno 
   where 
(CASE  
	WHEN isnull(PersRef.last_updated,'1/1/1900') >= isnull(PersRef.last_worked,'1/1/1900') AND isnull(PersRef.last_updated,'1/1/1900') >= isnull(PersRef.Web_Updated,'1/1/1900') THEN PersRef.last_updated  
	WHEN isnull(PersRef.last_worked,'1/1/1900') >= isnull(PersRef.last_updated,'1/1/1900') AND isnull(PersRef.last_worked,'1/1/1900') >= isnull(PersRef.Web_Updated,'1/1/1900') THEN PersRef.last_worked 
	WHEN isnull(PersRef.Web_Updated,'1/1/1900') >= isnull(PersRef.last_worked,'1/1/1900') AND isnull(PersRef.Web_Updated,'1/1/1900') >= isnull(PersRef.last_updated,'1/1/1900') THEN PersRef.Web_Updated 
END)  >= @from_date AND 
(CASE  
	WHEN isnull(PersRef.last_updated,'1/1/1900') >= isnull(PersRef.last_worked,'1/1/1900') AND isnull(PersRef.last_updated,'1/1/1900') >= isnull(PersRef.Web_Updated,'1/1/1900') THEN PersRef.last_updated  
	WHEN isnull(PersRef.last_worked,'1/1/1900') >= isnull(PersRef.last_updated,'1/1/1900') AND isnull(PersRef.last_worked,'1/1/1900') >= isnull(PersRef.Web_Updated,'1/1/1900') THEN PersRef.last_worked 
	WHEN isnull(PersRef.Web_Updated,'1/1/1900') >= isnull(PersRef.last_worked,'1/1/1900') AND isnull(PersRef.Web_Updated,'1/1/1900') >= isnull(PersRef.last_updated,'1/1/1900') THEN PersRef.Web_Updated 
END)  < @to_date AND CLNO = @CLNO AND apstatus in ('W','F')
  )AS NUMERIC( 7, 2 ) ) AS 'Percentage',

CAST( 100. * (SELECT count(*) FROM PersRef with (NOLOCK)
	JOIN appl with (NOLOCK) on appl.apno = PersRef.apno
	WHERE 
(CASE  
	WHEN isnull(PersRef.last_updated,'1/1/1900') >= isnull(PersRef.last_worked,'1/1/1900') AND isnull(PersRef.last_updated,'1/1/1900') >= isnull(PersRef.Web_Updated,'1/1/1900') THEN PersRef.last_updated  
	WHEN isnull(PersRef.last_worked,'1/1/1900') >= isnull(PersRef.last_updated,'1/1/1900') AND isnull(PersRef.last_worked,'1/1/1900') >= isnull(PersRef.Web_Updated,'1/1/1900') THEN PersRef.last_worked 
	WHEN isnull(PersRef.Web_Updated,'1/1/1900') >= isnull(PersRef.last_worked,'1/1/1900') AND isnull(PersRef.Web_Updated,'1/1/1900') >= isnull(PersRef.last_updated,'1/1/1900') THEN PersRef.Web_Updated 
END)  >= @from_date AND 
(CASE  
	WHEN isnull(PersRef.last_updated,'1/1/1900') >= isnull(PersRef.last_worked,'1/1/1900') AND isnull(PersRef.last_updated,'1/1/1900') >= isnull(PersRef.Web_Updated,'1/1/1900') THEN PersRef.last_updated  
	WHEN isnull(PersRef.last_worked,'1/1/1900') >= isnull(PersRef.last_updated,'1/1/1900') AND isnull(PersRef.last_worked,'1/1/1900') >= isnull(PersRef.Web_Updated,'1/1/1900') THEN PersRef.last_worked 
	WHEN isnull(PersRef.Web_Updated,'1/1/1900') >= isnull(PersRef.last_worked,'1/1/1900') AND isnull(PersRef.Web_Updated,'1/1/1900') >= isnull(PersRef.last_updated,'1/1/1900') THEN PersRef.Web_Updated 
END)  < @to_date AND CLNO = @CLNO AND apstatus in ('W','F')
	AND  (CASE  
	WHEN isnull(PersRef.last_updated,'1/1/1900') >= isnull(PersRef.last_worked,'1/1/1900') AND isnull(PersRef.last_updated,'1/1/1900') >= isnull(PersRef.Web_Updated,'1/1/1900') THEN dbo.elapsedbusinessdays_2( PersRef.CreatedDate,PersRef.last_updated)  
	WHEN isnull(PersRef.last_worked,'1/1/1900') >= isnull(PersRef.last_updated,'1/1/1900') AND isnull(PersRef.last_worked,'1/1/1900') >= isnull(PersRef.Web_Updated,'1/1/1900') THEN dbo.elapsedbusinessdays_2( PersRef.CreatedDate,PersRef.last_worked) 
	WHEN isnull(PersRef.Web_Updated,'1/1/1900') >= isnull(PersRef.last_worked,'1/1/1900') AND isnull(PersRef.Web_Updated,'1/1/1900') >= isnull(PersRef.last_updated,'1/1/1900') THEN dbo.elapsedbusinessdays_2( PersRef.CreatedDate,PersRef.Web_Updated)
	END) >=0 
--group by clno
	) / 
  (select count(PersRefid) from PersRef with (NOLOCK) JOIN appl with (NOLOCK) on appl.apno = PersRef.apno 
   where 
(CASE  
	WHEN isnull(PersRef.last_updated,'1/1/1900') >= isnull(PersRef.last_worked,'1/1/1900') AND isnull(PersRef.last_updated,'1/1/1900') >= isnull(PersRef.Web_Updated,'1/1/1900') THEN PersRef.last_updated  
	WHEN isnull(PersRef.last_worked,'1/1/1900') >= isnull(PersRef.last_updated,'1/1/1900') AND isnull(PersRef.last_worked,'1/1/1900') >= isnull(PersRef.Web_Updated,'1/1/1900') THEN PersRef.last_worked 
	WHEN isnull(PersRef.Web_Updated,'1/1/1900') >= isnull(PersRef.last_worked,'1/1/1900') AND isnull(PersRef.Web_Updated,'1/1/1900') >= isnull(PersRef.last_updated,'1/1/1900') THEN PersRef.Web_Updated 
END)  >= @from_date AND 
(CASE  
	WHEN isnull(PersRef.last_updated,'1/1/1900') >= isnull(PersRef.last_worked,'1/1/1900') AND isnull(PersRef.last_updated,'1/1/1900') >= isnull(PersRef.Web_Updated,'1/1/1900') THEN PersRef.last_updated  
	WHEN isnull(PersRef.last_worked,'1/1/1900') >= isnull(PersRef.last_updated,'1/1/1900') AND isnull(PersRef.last_worked,'1/1/1900') >= isnull(PersRef.Web_Updated,'1/1/1900') THEN PersRef.last_worked 
	WHEN isnull(PersRef.Web_Updated,'1/1/1900') >= isnull(PersRef.last_worked,'1/1/1900') AND isnull(PersRef.Web_Updated,'1/1/1900') >= isnull(PersRef.last_updated,'1/1/1900') THEN PersRef.Web_Updated 
END)  < @to_date AND CLNO = @CLNO AND apstatus in ('W','F')
  )AS NUMERIC( 7, 2 ) ) as 'Cumulative %'
FROM PersRef with (NOLOCK) JOIN appl with (NOLOCK) on appl.apno = PersRef.apno
WHERE  
(CASE  
	WHEN isnull(PersRef.last_updated,'1/1/1900') >= isnull(PersRef.last_worked,'1/1/1900') AND isnull(PersRef.last_updated,'1/1/1900') >= isnull(PersRef.Web_Updated,'1/1/1900') THEN PersRef.last_updated  
	WHEN isnull(PersRef.last_worked,'1/1/1900') >= isnull(PersRef.last_updated,'1/1/1900') AND isnull(PersRef.last_worked,'1/1/1900') >= isnull(PersRef.Web_Updated,'1/1/1900') THEN PersRef.last_worked 
	WHEN isnull(PersRef.Web_Updated,'1/1/1900') >= isnull(PersRef.last_worked,'1/1/1900') AND isnull(PersRef.Web_Updated,'1/1/1900') >= isnull(PersRef.last_updated,'1/1/1900') THEN PersRef.Web_Updated 
END)  >= @from_date AND 
(CASE  
	WHEN isnull(PersRef.last_updated,'1/1/1900') >= isnull(PersRef.last_worked,'1/1/1900') AND isnull(PersRef.last_updated,'1/1/1900') >= isnull(PersRef.Web_Updated,'1/1/1900') THEN PersRef.last_updated  
	WHEN isnull(PersRef.last_worked,'1/1/1900') >= isnull(PersRef.last_updated,'1/1/1900') AND isnull(PersRef.last_worked,'1/1/1900') >= isnull(PersRef.Web_Updated,'1/1/1900') THEN PersRef.last_worked 
	WHEN isnull(PersRef.Web_Updated,'1/1/1900') >= isnull(PersRef.last_worked,'1/1/1900') AND isnull(PersRef.Web_Updated,'1/1/1900') >= isnull(PersRef.last_updated,'1/1/1900') THEN PersRef.Web_Updated 
END) < @to_date AND  CLNO = @CLNO AND apstatus in ('W','F') 
--group by clno 

UNION

SELECT 'Total',
(select COUNT( PersRefid ) from PersRef with (NOLOCK) JOIN appl with (NOLOCK) on PersRef.apno = appl.apno
where 
(CASE  
	WHEN isnull(PersRef.last_updated,'1/1/1900') >= isnull(PersRef.last_worked,'1/1/1900') AND isnull(PersRef.last_updated,'1/1/1900') >= isnull(PersRef.Web_Updated,'1/1/1900') THEN PersRef.last_updated  
	WHEN isnull(PersRef.last_worked,'1/1/1900') >= isnull(PersRef.last_updated,'1/1/1900') AND isnull(PersRef.last_worked,'1/1/1900') >= isnull(PersRef.Web_Updated,'1/1/1900') THEN PersRef.last_worked 
	WHEN isnull(PersRef.Web_Updated,'1/1/1900') >= isnull(PersRef.last_worked,'1/1/1900') AND isnull(PersRef.Web_Updated,'1/1/1900') >= isnull(PersRef.last_updated,'1/1/1900') THEN PersRef.Web_Updated 
END) >= @from_date AND 
(CASE  
	WHEN isnull(PersRef.last_updated,'1/1/1900') >= isnull(PersRef.last_worked,'1/1/1900') AND isnull(PersRef.last_updated,'1/1/1900') >= isnull(PersRef.Web_Updated,'1/1/1900') THEN PersRef.last_updated  
	WHEN isnull(PersRef.last_worked,'1/1/1900') >= isnull(PersRef.last_updated,'1/1/1900') AND isnull(PersRef.last_worked,'1/1/1900') >= isnull(PersRef.Web_Updated,'1/1/1900') THEN PersRef.last_worked 
	WHEN isnull(PersRef.Web_Updated,'1/1/1900') >= isnull(PersRef.last_worked,'1/1/1900') AND isnull(PersRef.Web_Updated,'1/1/1900') >= isnull(PersRef.last_updated,'1/1/1900') THEN PersRef.Web_Updated 
END)  < @to_date AND CLNO = @CLNO  AND apstatus in ('W','F') 
--group by CLNO
), 100, 100
FROM PersRef with (NOLOCK) JOIN appl with (NOLOCK) on appl.apno = PersRef.apno
WHERE  
(CASE  
	WHEN isnull(PersRef.last_updated,'1/1/1900') >= isnull(PersRef.last_worked,'1/1/1900') AND isnull(PersRef.last_updated,'1/1/1900') >= isnull(PersRef.Web_Updated,'1/1/1900') THEN PersRef.last_updated  
	WHEN isnull(PersRef.last_worked,'1/1/1900') >= isnull(PersRef.last_updated,'1/1/1900') AND isnull(PersRef.last_worked,'1/1/1900') >= isnull(PersRef.Web_Updated,'1/1/1900') THEN PersRef.last_worked 
	WHEN isnull(PersRef.Web_Updated,'1/1/1900') >= isnull(PersRef.last_worked,'1/1/1900') AND isnull(PersRef.Web_Updated,'1/1/1900') >= isnull(PersRef.last_updated,'1/1/1900') THEN PersRef.Web_Updated 
END) >= @from_date AND 
(CASE  
	WHEN isnull(PersRef.last_updated,'1/1/1900') >= isnull(PersRef.last_worked,'1/1/1900') AND isnull(PersRef.last_updated,'1/1/1900') >= isnull(PersRef.Web_Updated,'1/1/1900') THEN PersRef.last_updated  
	WHEN isnull(PersRef.last_worked,'1/1/1900') >= isnull(PersRef.last_updated,'1/1/1900') AND isnull(PersRef.last_worked,'1/1/1900') >= isnull(PersRef.Web_Updated,'1/1/1900') THEN PersRef.last_worked 
	WHEN isnull(PersRef.Web_Updated,'1/1/1900') >= isnull(PersRef.last_worked,'1/1/1900') AND isnull(PersRef.Web_Updated,'1/1/1900') >= isnull(PersRef.last_updated,'1/1/1900') THEN PersRef.Web_Updated 
END)< @to_date AND  CLNO = @CLNO AND apstatus in ('W','F') 
--group by clno
END --end of PersRef section
--till here veena 07/07/2008


SET TRANSACTION ISOLATION LEVEL READ COMMITTED













