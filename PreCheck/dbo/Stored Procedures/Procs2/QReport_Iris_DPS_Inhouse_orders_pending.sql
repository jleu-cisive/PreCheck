

-- Alter Procedure Iris_DPS_Inhouse_orders_pending



CREATE PROCEDURE [dbo].[QReport_Iris_DPS_Inhouse_orders_pending] AS


select 
		A.R_Name,
		A.R_Firstname,
		A.b_rule,
		A.R_Lastname,
		case when sum(A.readytosend) < count(A.readytosend) then 0 	else 1 end as readytosend,
		A.vendorid,
		A.R_Delivery,
		A.CNTY_NO,
		MIN(A.crim_time) AS crim_time,
		A.county, 
		A.State,
		A.IRIS_REC
from (
		SELECT   dbo.Iris_Researchers.R_Name,
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
				  else 0 end AS readytosend ,
				 dbo.Iris_Researchers.R_id AS vendorid,
				 dbo.Iris_Researchers.R_Delivery,
				 dbo.Crim.CNTY_NO,
				 crim.crimenteredtime  AS crim_time,
				 dbo.TblCounties.A_County AS county,
				 dbo.TblCounties.State,
				 dbo.Crim.IRIS_REC
				--, dbo.Appl.InUse
		FROM        dbo.Crim 
			INNER JOIN  dbo.TblCounties ON dbo.Crim.CNTY_NO = dbo.TblCounties.CNTY_NO 
			INNER JOIN  dbo.Appl ON dbo.Crim.APNO = dbo.Appl.APNO
			LEFT OUTER JOIN dbo.Iris_Researchers ON dbo.Crim.vendorid = dbo.Iris_Researchers.R_id
			LEFT OUTER JOIN dbo.Iris_Researcher_Charges WITH (NOLOCK)ON dbo.Iris_Researchers.R_id = dbo.Iris_Researcher_Charges.Researcher_id
			and dbo.Crim.CNTY_NO = dbo.Iris_Researcher_Charges.cnty_no
		WHERE    (dbo.Iris_Researchers.R_Delivery = 'InHouse') AND  (Crim.clear = 'o')  
				  AND (dbo.Crim.IRIS_REC = 'yes') AND (dbo.Crim.batchnumber IS NULL) 
				  --AND (DATEDIFF(mi, dbo.Crim.Crimenteredtime, GETDATE()) >= 20) 
				  AND (dbo.Appl.InUse IS NULL ) AND (Appl.ApStatus = 'p' OR Appl.ApStatus = 'w')
				  AND (dbo.Iris_Researchers.R_ID = 262)
				  and dbo.Appl.CLNO not in (3468) and (dbo.crim.IsHidden = 0 ) -- Added this by Santosh on 06/24/13 to exclude BAD APPS and unused searches
		) A
group by
		A.R_Name,
		A.R_Firstname,
		A.b_rule,
		A.R_Lastname,
		--A.readytosend,
		A.vendorid,
		A.R_Delivery,
		A.CNTY_NO,
		A.county, 
		A.State,
		A.IRIS_REC
		order by crim_time asc,
		case when sum(A.readytosend) < count(A.readytosend) then 0
		else 1 end

