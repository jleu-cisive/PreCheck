

-- Alter Procedure Iris_Orders_By_DeliveryMethod

/*
Edited By	:	Deepak Vodethela	
Edited date	:	02/09/2017
Description	:	As part of Alias Logic Re-Write project all the Aliases will be from dbo.ApplAlias (Overflow table). Modified the conditions at Aliases section.
Execution : 
	EXEC [dbo].[Iris_Orders_By_DeliveryMethod] 'fax-copyofcheck'
	EXEC [dbo].[Iris_Orders_By_DeliveryMethod] 'Mail-copyofcheck'
	EXEC [dbo].[Iris_Orders_By_DeliveryMethod] 'mail'
*/

CREATE PROCEDURE [dbo].[QReport_Iris_Orders_By_DeliveryMethod]
@DeliveryMethod NVARCHAR(100) NULL
AS
	-- This script is to return the devivery method records
	SELECT	A.R_Name,
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
	FROM 
	(
	SELECT   DISTINCT IR.R_Name, 
			 IR.R_Firstname, 
			 C.b_rule, 
			 IR.R_Lastname,
			 CASE WHEN ((CASE WHEN irc.Researcher_Aliases_count = 'All' THEN 5 ELSE irc.Researcher_Aliases_count END) >= Y.AliasCount
					   ) THEN 1 ELSE 0 END AS ReadyToSend,
			 IR.R_id AS vendorid, 
			 IR.R_Delivery, 
			 C.CNTY_NO,
			 (SELECT MIN(z.crimenteredtime)
				FROM Crim z
			   WHERE (z.cnty_no = C.cnty_no) 
				 AND (z.Clear IS NULL or z.clear = 'R') 
				 AND (z.iris_rec = 'yes')) AS crim_time, 
			 X.A_County AS county, 
			 X.State, 
			 C.IRIS_REC
	FROM dbo.Crim AS C WITH (NOLOCK) 
		INNER JOIN dbo.TblCounties AS X WITH (NOLOCK) ON C.CNTY_NO = X.CNTY_NO 
		INNER JOIN dbo.Appl AS A WITH (NOLOCK) ON C.APNO = A.APNO
		INNER JOIN (SELECT APNO, COUNT(1) AS AliasCount FROM dbo.ApplAlias(NOLOCK) WHERE IsPublicRecordQualified = 1 GROUP BY APNO) AS Y ON A.APNO = Y.APNO
		INNER JOIN dbo.ApplAlias AS AA(NOLOCK) ON A.APNO = AA.APNO AND AA.IsPublicRecordQualified = 1 --AND AA.IsPrimaryName = 0
		LEFT OUTER JOIN dbo.Iris_Researchers AS IR WITH (NOLOCK) ON C.vendorid = IR.R_id
		LEFT OUTER JOIN dbo.Iris_Researcher_Charges AS IRC WITH (NOLOCK)ON IR.R_id = IRC.Researcher_id AND C.CNTY_NO = IRC.cnty_no
	WHERE (IR.R_Delivery = @DeliveryMethod) 
	  AND (C.Clear IS NULL or C.clear = 'R') 
	  AND (C.IRIS_REC = 'yes') 
	  AND (C.batchnumber IS NULL)  
	  AND (DATEDIFF(mi, C.Crimenteredtime, GETDATE()) >= 1) 
	  AND (A.InUse IS NULL )
	  AND A.CLNO not in (3468) 
	  AND (C.IsHidden = 0 ) -- Added this by Santosh on 06/24/13 to exclude BAD APPS and unused searches
	) A
	GROUP BY A.R_Name,
			 A.R_Firstname,
			 A.b_rule,
			 A.R_Lastname,
			 A.vendorid,
			 A.R_Delivery,
			 A.CNTY_NO,
			 A.county, 
			 A.State,
			 A.IRIS_REC
	ORDER BY crim_time asc, CASE WHEN SUM(A.readytosend) < COUNT(A.readytosend) THEN 0 ELSE 1 END

	

