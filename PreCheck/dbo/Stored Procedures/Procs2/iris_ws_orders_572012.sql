-- Alter Procedure iris_ws_orders_572012





CREATE PROCEDURE [dbo].[iris_ws_orders_572012]
AS
BEGIN
    SET NOCOUNT ON;
--
--    SELECT
--        R.r_name,
--        R.r_firstname,
--        C.b_rule,
--        R.r_lastname, 
--        ISNULL(C.readytosend, 0) AS readytosend,
--        R.R_id AS vendorid,
--        R.r_delivery,
--        C.cnty_no,
--        MIN(crimenteredtime) AS crim_time,
--        CO.a_county AS county, 
--        CO.state,
--        C.iris_rec,
--        C.clear 
--    FROM
--        dbo.crim C WITH (NOLOCK)
--        INNER JOIN dbo.counties CO WITH (NOLOCK) ON C.cnty_no = CO.cnty_no
--        INNER JOIN dbo.appl A WITH (NOLOCK) ON C.apno = A.apno
--        LEFT OUTER JOIN dbo.iris_researchers R WITH (NOLOCK) ON C.vendorid = R.r_id
--    WHERE
--        (UPPER(R.r_delivery) LIKE 'WEB%SERVICE')
--        AND (UPPER(C.clear) IN ('R','E'))
--        AND (UPPER(C.iris_rec) = 'YES')
--        AND (C.batchnumber IS NULL) 
--        AND (A.inuse IS NULL )
--        AND (UPPER(A.apstatus) IN ('P','W'))
--        GROUP BY
--          R.r_name,
--          R.r_firstname,
--          C.b_rule,
--          R.r_lastname,
--          ISNULL(C.readytosend, 0),
--          R.r_id,
--          R.r_delivery,
--          C.cnty_no,
--          CO.a_county,
--          CO.state,
--          C.iris_rec,
--          C.clear;
          
select 
B.R_Name,
B.R_Firstname,
B.b_rule,
B.R_Lastname,
case when sum(B.readytosend) < count(B.readytosend) then 0
else 1 end as readytosend,
B.vendorid,
B.R_Delivery,
B.CNTY_NO,
MIN(B.crim_time) AS crim_time,
B.county, 
B.State,
B.IRIS_REC,
B.Clear
from 

(
    SELECT
        R.r_name,
        R.r_firstname,
        C.b_rule,
        R.r_lastname, 
        Case When 
           ((case when dbo.Iris_Researcher_Charges.Researcher_Aliases_count = 'All' then 5
           else dbo.Iris_Researcher_Charges.Researcher_Aliases_count end) >=
           (case when len(isnull(A.alias1_Last, '') + isnull(A.alias1_Middle, '')  + isnull(A.alias1_First, ''))> 0 then 1
            else 0 end +
            case when len(isnull(A.alias2_Last, '') + isnull(A.alias2_Middle, '')  + isnull(A.alias2_First, ''))> 0 then 1
            else 0 end +
            case when len(isnull(A.alias3_Last, '') + isnull(A.alias3_Middle, '')  + isnull(A.alias3_First, ''))> 0 then 1
            else 0 end +
            case when len(isnull(A.alias4_Last, '') + isnull(A.alias4_Middle, '')  + isnull(A.alias4_First, ''))> 0 then 1
            else 0 end)) or C.readytosend = 1 then 1
          else 0 end AS readytosend,  
        R.R_id AS vendorid,
        R.r_delivery,
        C.cnty_no,
        MIN(crimenteredtime) AS crim_time,
        CO.a_county AS county, 
        CO.state,
        C.iris_rec,
        C.clear 
    FROM
        dbo.crim C WITH (NOLOCK)
        INNER JOIN dbo.TblCounties CO WITH (NOLOCK) ON C.cnty_no = CO.cnty_no
        INNER JOIN dbo.appl A WITH (NOLOCK) ON C.apno = A.apno
        LEFT OUTER JOIN dbo.iris_researchers R WITH (NOLOCK) ON C.vendorid = R.r_id
LEFT OUTER JOIN dbo.Iris_Researcher_Charges WITH (NOLOCK)ON R.R_id = dbo.Iris_Researcher_Charges.Researcher_id
and C.CNTY_NO = dbo.Iris_Researcher_Charges.cnty_no
    WHERE
        (UPPER(R.r_delivery) LIKE 'WEB%SERVICE')
        AND (UPPER(C.clear) IN ('R','E'))
        AND (UPPER(C.iris_rec) = 'YES')
        AND (C.batchnumber IS NULL) 
        AND (A.inuse IS NULL )
        AND (UPPER(A.apstatus) IN ('P','W'))
        GROUP BY
          R.r_name,
          R.r_firstname,
          C.b_rule,
          R.r_lastname,
          C.readytosend,
          R.r_id,
          R.r_delivery,
          C.cnty_no,
          CO.a_county,
          CO.state,
          C.iris_rec,
          C.clear,
dbo.Iris_Researcher_Charges.Researcher_Aliases_count,A.Alias1_Last,
A.Alias1_Middle, A.Alias1_First
,A.Alias2_Last,
A.Alias2_Middle, A.Alias2_First
,A.Alias3_Last,
A.Alias3_Middle, A.Alias3_First
,A.Alias4_Last,
A.Alias4_Middle, A.Alias4_First
)B
group by
B.R_Name,
B.R_Firstname,
B.b_rule,
B.R_Lastname,
B.vendorid,
B.R_Delivery,
B.CNTY_NO,
B.county, 
B.State,
B.IRIS_REC,
B.Clear
order by
case when sum(B.readytosend) < count(B.readytosend) then 0
else 1 end

CREATE TABLE #IrisAliasUpdate (
crimid int PRIMARY KEY CLUSTERED,
readytosend bit,
readytosend_old bit,
txtlast bit,
txtlast_old bit,
txtalias bit,
txtalias_old bit,
txtalias2 bit,
txtalias2_old bit,
txtalias3 bit,
txtalias3_old bit,
txtalias4 bit,
txtalias4_old bit,
apstatus char(1), 
iris_rec varchar(3), 
clear varchar(1), 
clear_old varchar(1),
batchnumber float, 
batchnumber_old float,
deliverymethod varchar(50), 
crimenteredtime datetime
)

INSERT INTO #IrisAliasUpdate (crimid,
                              readytosend,
                              readytosend_old,
                              txtlast,
                              txtlast_old,
                              txtalias,
                              txtalias_old,
                              txtalias2,
                              txtalias2_old,
                              txtalias3,
                              txtalias3_old,
                              txtalias4,
                              txtalias4_old, 
                              apstatus, 
                              iris_rec, 
                              clear, 
                              clear_old,
                              batchnumber, 
                              batchnumber_old, 
                              deliverymethod, 
                              crimenteredtime)

select   c.crimid, 
Case When 
           ((case when irc.Researcher_Aliases_count = 'All' then 5
           else irc.Researcher_Aliases_count end) >=
           (case when len(isnull(a.alias1_Last, '') + isnull(a.alias1_Middle, '')  + isnull(a.alias1_First, ''))> 0 then 1
            else 0 end +
            case when len(isnull(a.alias2_Last, '') + isnull(a.alias2_Middle, '')  + isnull(a.alias2_First, ''))> 0 then 1
            else 0 end +
            case when len(isnull(a.alias3_Last, '') + isnull(a.alias3_Middle, '')  + isnull(a.alias3_First, ''))> 0 then 1
            else 0 end +
            case when len(isnull(a.alias4_Last, '') + isnull(a.alias4_Middle, '')  + isnull(a.alias4_First, ''))> 0 then 1
            else 0 end)) then 1
          else 0 end as readytosend,
c.readytosend as readytosend_old,
          1 as txtlast,
          c.txtlast as txtlast_old,
 case when 
           (case when irc.Researcher_Aliases_count = 'All' then 5
           else irc.Researcher_Aliases_count end) >= 1 then
            case when len(isnull(a.alias1_Last, '') + isnull(a.alias1_Middle, '')  + isnull(a.alias1_First, ''))> 0 then 1
            else 0 end
            end as txtalias,
            txtalias as txtalias_old, 
 case when 
            (case when irc.Researcher_Aliases_count = 'All' then 5
            else irc.Researcher_Aliases_count end) >= 2 then
             case when len(isnull(a.alias2_Last, '') + isnull(a.alias2_Middle, '')  + isnull(a.alias2_First, ''))> 0 then 1
            else 0 end
            end as txtalias2,
txtalias2 as txtalias2_old,
case when 
           (case when irc.Researcher_Aliases_count = 'All' then 5
            else irc.Researcher_Aliases_count end) >= 3 then
            case when len(isnull(a.alias3_Last, '') + isnull(a.alias3_Middle, '')  + isnull(a.alias3_First, ''))> 0 then 1
            else 0 end
            end as txtalias3,
txtalias3 as txtalias3_old,
 case when 
           (case when irc.Researcher_Aliases_count = 'All' then 5
           else irc.Researcher_Aliases_count end) >= 4 then
            case when len(isnull(a.alias4_Last, '') + isnull(a.alias4_Middle, '')  + isnull(a.alias4_First, ''))> 0 then 1
            else 0 end
           end as txtalias4,
txtalias4 as txtalias4_old,
a.apstatus as apstatus, 
c.iris_rec as iris_rec, 
'' as clear, 
c.clear as clear_old,
0 as batchnumber, 
c.batchnumber as batchnumber_old, 
c.deliverymethod as deliverymethod, 
c.crimenteredtime as crimenteredtime
FROM        dbo.Crim c WITH (NOLOCK) INNER JOIN
                  dbo.TblCounties ct WITH (NOLOCK) ON c.CNTY_NO = ct.CNTY_NO INNER JOIN
                  dbo.Appl a WITH (NOLOCK) ON c.APNO = a.APNO LEFT OUTER JOIN
                  dbo.Iris_Researchers ir WITH (NOLOCK) ON c.vendorid = ir.R_id
LEFT OUTER JOIN dbo.Iris_Researcher_Charges irc WITH (NOLOCK)ON ir.R_id = irc.Researcher_id
and c.CNTY_NO = irc.cnty_no
WHERE    (UPPER(ir.R_Delivery) LIKE 'WEB%SERVICE') 
  AND (UPPER(C.clear) IN ('R','E'))
  AND (c.IRIS_REC = 'yes') 
  AND (c.batchnumber IS NULL) 
  AND (a.InUse IS NULL ) 
  AND (c.readytosend=0)
  AND (a.ApStatus = 'p' OR a.ApStatus = 'w')

update

#IrisAliasUpdate 

set txtalias = isnull(txtalias,0)

, txtalias2 = isnull(txtalias2,0)

,txtalias3 = isnull(txtalias3,0)

,txtalias4 = isnull(txtalias4,0)


INSERT INTO IrisAliasUpdate_Autocheck_log(crimid,readytosend,
                                     readytosend_old,
                                     txtlast,
                                     txtlast_old,
                                     txtalias,
                                     txtalias_old,
                                     txtalias2,
                                     txtalias2_old,
                                     txtalias3,
                                     txtalias3_old,
                                     txtalias4,
                                     txtalias4_old, 
                                     apstatus, 
                                     iris_rec, 
                                     clear, 
                                     clear_old,
                                     batchnumber, 
                                     batchnumber_old, 
                                     deliverymethod, 
                                     crimenteredtime,
                                     inserttimestamp)
                              select crimid,readytosend,
                                     readytosend_old,
                                     txtlast,
                                     txtlast_old,
                                     txtalias,
                                     txtalias_old,
                                     txtalias2,
                                     txtalias2_old,
                                     txtalias3,
                                     txtalias3_old,
                                     txtalias4,
                                     txtalias4_old, 
                                     apstatus, 
                                     iris_rec, 
                                     clear, 
                                     clear_old,
                                     batchnumber, 
                                     batchnumber_old, 
                                     deliverymethod, 
                                     crimenteredtime,
                                     getdate()
                         from #IrisAliasUpdate where readytosend = 1

update crim set 
readytosend = a.readytosend,
txtlast = a.txtlast,
txtalias = a.txtalias,
txtalias2 = a.txtalias2,
txtalias3 = a.txtalias3,
txtalias4 = a.txtalias4
from crim c join #IrisAliasUpdate a on a.crimid = c.crimid 
where a.readytosend =1
DROP TABLE #IrisAliasUpdate


    SET NOCOUNT OFF;
END
