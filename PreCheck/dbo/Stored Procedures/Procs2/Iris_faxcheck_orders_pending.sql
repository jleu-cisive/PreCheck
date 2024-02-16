-- Alter Procedure Iris_faxcheck_orders_pending




CREATE PROCEDURE [dbo].[Iris_faxcheck_orders_pending] AS

--
--SELECT   distinct dbo.Iris_Researchers.R_Name, dbo.Iris_Researchers.R_Firstname, dbo.Crim.b_rule, dbo.Iris_Researchers.R_Lastname,
----isnull(dbo.LookupTimeZoneByState (Iris_Researchers.R_City,Iris_Researchers.R_State_Province,getdate(),iris_researchers.cutoff),'N/A') as cutoff,
----isnull(datediff(mi,getdate(),dbo.LookupTimeZoneByState (Iris_Researchers.R_City,Iris_Researchers.R_State_Province,getdate(),iris_researchers.cutoff)),999999999) as mycutoff,
--                      ISNULL(dbo.Crim.readytosend, 0) AS readytosend, dbo.Iris_Researchers.R_id AS vendorid, dbo.Iris_Researchers.R_Delivery, dbo.Crim.CNTY_NO,
--                          (SELECT     MIN(z.crimenteredtime)
--                            FROM          Crim z
--                            WHERE      (z.cnty_no = crim.cnty_no) AND (z.Clear IS NULL or z.clear = 'R') AND (z.iris_rec = 'yes')) AS crim_time, dbo.Counties.A_County AS county, 
--                      dbo.Counties.State, dbo.Crim.IRIS_REC
--FROM         dbo.Crim WITH (NOLOCK) INNER JOIN
--                      dbo.Counties WITH (NOLOCK) ON dbo.Crim.CNTY_NO = dbo.Counties.CNTY_NO INNER JOIN
--                      dbo.Appl WITH (NOLOCK) ON dbo.Crim.APNO = dbo.Appl.APNO LEFT OUTER JOIN
--                      dbo.Iris_Researchers WITH (NOLOCK) ON dbo.Crim.vendorid = dbo.Iris_Researchers.R_id
--WHERE     (dbo.Iris_Researchers.R_Delivery = 'fax-copyofcheck') AND (dbo.Crim.Clear IS NULL or Crim.clear = 'R') AND (dbo.Crim.IRIS_REC = 'yes') 
--AND (dbo.Crim.batchnumber IS NULL)  AND   (DATEDIFF(mi, dbo.Crim.Crimenteredtime, GETDATE()) >= 1) 
--and (dbo.Appl.InUse IS NULL )
--


select 
A.R_Name,
A.R_Firstname,
A.b_rule,
A.R_Lastname,
case when sum(A.readytosend) < count(A.readytosend) then 0
else 1 end as readytosend,
A.vendorid,
A.R_Delivery,
A.CNTY_NO,
MIN(A.crim_time) AS crim_time,
A.county, 
A.State,
A.IRIS_REC
from 

(
SELECT   distinct dbo.Iris_Researchers.R_Name, 
         dbo.Iris_Researchers.R_Firstname, 
         dbo.Crim.b_rule, 
         dbo.Iris_Researchers.R_Lastname,
         Case When 
           ((case when dbo.Iris_Researcher_Charges.Researcher_Aliases_count = 'All' then 5
           else dbo.Iris_Researcher_Charges.Researcher_Aliases_count end) >=
           (case when len(isnull(alias1_Last, '') + isnull(alias1_Middle, '')  + isnull(alias1_First, ''))> 0 then 1
            else 0 end +
            case when len(isnull(alias2_Last, '') + isnull(alias2_Middle, '')  + isnull(alias2_First, ''))> 0 then 1
            else 0 end +
            case when len(isnull(alias3_Last, '') + isnull(alias3_Middle, '')  + isnull(alias3_First, ''))> 0 then 1
            else 0 end +
            case when len(isnull(alias4_Last, '') + isnull(alias4_Middle, '')  + isnull(alias4_First, ''))> 0 then 1
            else 0 end)) or dbo.Crim.readytosend = 1 then 1
          else 0 end AS readytosend, 
         dbo.Iris_Researchers.R_id AS vendorid, 
         dbo.Iris_Researchers.R_Delivery, 
         dbo.Crim.CNTY_NO,
         (SELECT MIN(z.crimenteredtime)
            FROM Crim z
           WHERE (z.cnty_no = crim.cnty_no) 
             AND (z.Clear IS NULL or z.clear = 'R') 
             AND (z.iris_rec = 'yes')) AS crim_time, 
         dbo.Counties.A_County AS county, 
         dbo.Counties.State, 
         dbo.Crim.IRIS_REC
  FROM   dbo.Crim WITH (NOLOCK) 
INNER JOIN  dbo.Counties WITH (NOLOCK) ON dbo.Crim.CNTY_NO = dbo.Counties.CNTY_NO 
INNER JOIN  dbo.Appl WITH (NOLOCK) ON dbo.Crim.APNO = dbo.Appl.APNO 
LEFT OUTER JOIN  dbo.Iris_Researchers WITH (NOLOCK) ON dbo.Crim.vendorid = dbo.Iris_Researchers.R_id
LEFT OUTER JOIN dbo.Iris_Researcher_Charges WITH (NOLOCK)ON dbo.Iris_Researchers.R_id = dbo.Iris_Researcher_Charges.Researcher_id
and dbo.Crim.CNTY_NO = dbo.Iris_Researcher_Charges.cnty_no
WHERE (dbo.Iris_Researchers.R_Delivery = 'fax-copyofcheck') 
  AND (dbo.Crim.Clear IS NULL or Crim.clear = 'R') 
  AND (dbo.Crim.IRIS_REC = 'yes') 
  AND (dbo.Crim.batchnumber IS NULL)  
  AND (DATEDIFF(mi, dbo.Crim.Crimenteredtime, GETDATE()) >= 1) 
  and (dbo.Appl.InUse IS NULL )
  and dbo.Appl.CLNO not in (3468) and (dbo.crim.IsHidden = 0 ) -- Added this by Santosh on 06/24/13 to exclude BAD APPS and unused searches
)A
group by
A.R_Name,
A.R_Firstname,
A.b_rule,
A.R_Lastname,
A.vendorid,
A.R_Delivery,
A.CNTY_NO,
A.county, 
A.State,
A.IRIS_REC
order by
case when sum(A.readytosend) < count(A.readytosend) then 0
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

select  c.crimid, 
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
WHERE    (ir.R_Delivery = 'fax-copyofcheck') 
  AND (c.Clear IS NULL or c.clear = 'R') 
  AND (c.IRIS_REC = 'yes') 
  AND (c.batchnumber IS NULL) 
  AND (DATEDIFF(mi, c.last_updated, GETDATE()) >= 1)  
  AND (a.InUse IS NULL ) 
  AND (c.readytosend=0)
  --AND (a.ApStatus = 'p' OR a.ApStatus = 'w')

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
