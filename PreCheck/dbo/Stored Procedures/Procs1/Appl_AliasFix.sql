
--====================================================================================================================== 
--Author:        Lalit Kumar and Santosh Chapyala
--Create Date:   5-October-2023
--Description:   Alias updates in appl table where these are missing.
-- modified by lalit on 9 oct 2023 to only include active names and exclude names where it contains a number
--======================================================================================================================
CREATE PROCEDURE [dbo].[Appl_AliasFix]
AS
BEGIN
-------------------------------------------------------------- START ----------------------------------------------------
drop TABLE if EXISTS #tempapno
--------------------------------- create temp table
CREATE TABLE #tempapno(
	apno [int]  NOT NULL,
	First [varchar](50) NULL,
	Last [varchar](50) NULL,
	clno [smallint] NULL,
	CreatedDate [datetime] NULL,
	Pending [char] NULL,
	ReopenDate [datetime] NULL,
	OrigCompDate [datetime] NULL,
	Alias1_first [varchar](50) NULL,
	Alias1_Middle [varchar](50) NULL,
	Alias1_Last [varchar](50) NULL,
	Alias1_Generation [varchar](3) NULL,
	Alias2_First [varchar](50) NULL,
	Alias2_Middle [varchar](50) NULL,
	Alias2_Last [varchar](50) NULL,
	Alias2_Generation [varchar](3) NULL,
    Alias3_first [varchar](50) NULL,
	Alias3_Middle [varchar](50) NULL,
	Alias3_Last [varchar](50) NULL,
	Alias3_Generation [varchar](3) NULL, 
	Alias4_first [varchar](50) NULL,
	Alias4_Middle [varchar](50) NULL,
	Alias4_Last [varchar](50) NULL,
	Alias4_Generation [varchar](3) NULL,	
)
CREATE NONCLUSTERED INDEX [PK_apno] ON #tempapno ([apno])

------------------- 1 insert apno with missing alias into temp table
insert into #tempapno(apno,	First,	Last,	clno,	CreatedDate,	Pending,	ReopenDate	,OrigCompDate,	Alias1_first,	Alias1_Middle,	Alias1_Last,
	Alias1_Generation,	Alias2_First,	Alias2_Middle	,Alias2_Last,	Alias2_Generation,	Alias3_first,	Alias3_Middle	,Alias3_Last,
	Alias3_Generation,	Alias4_first	,Alias4_Middle,	Alias4_Last,	Alias4_Generation )
	select distinct a.apno ,a.First,a.Last,a.clno,a.CreatedDate,a.ApStatus as 'Pending',a.ReopenDate,a.OrigCompDate,
	 Alias1_first,a.Alias1_Middle,a.Alias1_Last,a.Alias1_Generation,a.Alias2_First,a.Alias2_Middle,a.Alias2_Last,a.Alias2_Generation,
	 Alias3_first,a.Alias3_Middle,a.Alias3_Last,a.Alias3_Generation,a.Alias4_First,a.Alias4_Middle,a.Alias4_Last,a.Alias4_Generation
	from appl  a with(nolock)
where  
(a.Alias1_first is  null  and a.Alias2_first is  null and a.Alias3_first is  null and a.Alias4_first is  null)
  and a.Alias1_last is  null  and a.Alias2_last is  null and a.Alias3_last is  null and a.Alias4_last is  null 
and a.ApStatus in ('P','M','A','W') 
and a.clno not in (2135,3468)
and a.OrigCompDate is null
and a.ApDate>=dateadd(month,-6,current_timestamp) -- reduce it to 1 week
------------------ drop unwanted records from temp table 2
delete tmp
--select distinct tmp.* 
from #tempapno tmp left join ApplAlias aa with(nolock) on  tmp.apno=aa.apno and aa.IsPrimaryName<>1 and IsActive=1
where aa.APNO is null
------------------ update temp table 3
update tmp
set 
tmp.Alias1_first=f1,
tmp.Alias1_Middle=m1,
tmp.Alias1_Last=l1,
tmp.Alias1_Generation=g1,
tmp.Alias2_first=f2,
tmp.Alias2_Middle=m2,
tmp.Alias2_Last=l2,
tmp.Alias2_Generation=g2,
tmp.Alias3_first=f3,
tmp.Alias3_Middle=m3,
tmp.Alias3_Last=l3,
tmp.Alias3_Generation=g3,
tmp.Alias4_first=f4,
tmp.Alias4_Middle=m4,
tmp.Alias4_Last=l4,
tmp.Alias4_Generation=g4
----select tmp.* 
from 
(SELECT
    APNO,
    MAX(CASE WHEN rn = 1 THEN First END) AS f1,
	MAX(CASE WHEN rn = 1 THEN middle END) AS m1,
    MAX(CASE WHEN rn = 1 THEN Last END) AS l1,
	MAX(CASE WHEN rn = 1 THEN t.Generation END) AS g1,

    MAX(CASE WHEN rn = 2 THEN First END) AS f2,
	MAX(CASE WHEN rn = 2 THEN middle END) AS m2,
    MAX(CASE WHEN rn = 2 THEN Last END) AS l2,
	MAX(CASE WHEN rn = 2 THEN t.Generation END) AS g2,

	MAX(CASE WHEN rn = 3 THEN First END) AS f3,
	MAX(CASE WHEN rn = 3 THEN middle END) AS m3,
    MAX(CASE WHEN rn = 3 THEN Last END) AS l3,
	MAX(CASE WHEN rn = 3 THEN t.Generation END) AS g3,

	MAX(CASE WHEN rn = 4 THEN First END) AS f4,
	MAX(CASE WHEN rn = 4 THEN middle END) AS m4,
    MAX(CASE WHEN rn = 4 THEN Last END) AS l4,
	MAX(CASE WHEN rn = 4 THEN t.Generation END) AS g4
FROM (
    SELECT top 100 percent
        aa.APNO,
        aa.First,
        aa.Last,
		aa.Middle,
		aa.Generation,
        ROW_NUMBER() OVER (PARTITION BY aa.APNO ORDER BY (SELECT NULL)) AS rn
    FROM applalias aa with(nolock) inner join #tempapno tmp on aa.APNO=tmp.apno and  aa.IsPrimaryName<>1 AND IsActive=1
	and (ISNULL(aa.first,'') NOT LIKE '%[0-9]%' AND ISNULL(aa.last,'') NOT LIKE '%[0-9]%' and ISNULL(aa.middle,'') NOT LIKE '%[0-9]%')
	order by aa.ApplAliasID
) AS t
GROUP BY APNO)t2 
inner join #tempapno tmp on t2.apno=tmp.apno
--SELECT * from  #tempapno
--SELECT * from dbo.ApplAlias where APNO=7669699
---------------------------- Update appl  4
update a
set
a.Alias1_first=tmp.Alias1_first,
a.Alias1_Middle=tmp.Alias1_Middle,
a.Alias1_Last=tmp.Alias1_Last,
a.Alias1_Generation=tmp.Alias1_Generation,

a.Alias2_first=tmp.Alias2_first,
a.Alias2_Middle=tmp.Alias2_Middle,
a.Alias2_Last=tmp.Alias2_Last,
a.Alias2_Generation=tmp.Alias2_Generation,

a.Alias3_first=tmp.Alias3_first,
a.Alias3_Middle=tmp.Alias3_Middle,
a.Alias3_Last=tmp.Alias3_Last,
a.Alias3_Generation=tmp.Alias3_Generation,

a.Alias4_first=tmp.Alias4_first,
a.Alias4_Middle=tmp.Alias4_Middle,
a.Alias4_Last=tmp.Alias4_Last,
a.Alias4_Generation=tmp.Alias4_Generation
----select * 
from Appl a inner join #tempapno tmp on a.apno=tmp.apno
where --tmp.Alias1_first is not null 
a.Alias1_first is  null and tmp.Alias1_first is not NULL
----------------------------------update medinteg 5 / not needed for SP
update mi
set mi.sectstat = 9, mi.report = null,mi.Last_Updated = current_timestamp
----select *
from 
precheck..medinteg mi inner join #tempapno tmp on mi.apno=tmp.apno
where tmp.Alias1_first is not null and mi.SectStat NOT in (9,0,7)
------------- create log
INSERT into ApplAliasUpdateLog(apno,	Alias1_first,	Alias1_Middle,	Alias1_Last,	Alias1_Generation,	Alias2_First,	Alias2_Middle,	Alias2_Last	,Alias2_Generation,	Alias3_first,	Alias3_Middle	,Alias3_Last,	Alias3_Generation,	Alias4_first,	Alias4_Middle,	Alias4_Last,	Alias4_Generation )
SELECT apno,	Alias1_first,	Alias1_Middle,	Alias1_Last,	Alias1_Generation,	Alias2_First,	Alias2_Middle,	Alias2_Last	,Alias2_Generation,	Alias3_first,	Alias3_Middle	,Alias3_Last,	Alias3_Generation,	Alias4_first,	Alias4_Middle,	Alias4_Last,	Alias4_Generation 
FROM #tempapno 
where Alias1_first is not null --and tmp.Alias1_first is not NULL

drop TABLE if EXISTS #tempapno
-------------------------------------------------------------- END -----------------------------------------------------

END
