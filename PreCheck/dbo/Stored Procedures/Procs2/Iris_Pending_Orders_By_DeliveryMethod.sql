
/*
Procedure Name : [dbo].[Iris_Pending_Orders_By_DeliveryMethod]
Requested By: Alias Logic ReWrite
Developer: Deepak Vodethela
Execution : 
	EXEC [dbo].[Iris_Pending_Orders_By_DeliveryMethod] 'onlinedb'
	EXEC [dbo].[Iris_Pending_Orders_By_DeliveryMethod] 'Call_in'
	EXEC [dbo].[Iris_Pending_Orders_By_DeliveryMethod] 'fax'
	EXEC [dbo].[Iris_Pending_Orders_By_DeliveryMethod] 'fax-copyofcheck'
	EXEC [dbo].[Iris_Pending_Orders_By_DeliveryMethod] 'Mail-copyofcheck'
	EXEC [dbo].[Iris_Pending_Orders_By_DeliveryMethod] 'mail'
	EXEC [dbo].[Iris_Pending_Orders_By_DeliveryMethod] 'e-mail'
	EXEC [dbo].[Iris_Pending_Orders_By_DeliveryMethod] 'InHouse'
	EXEC [dbo].[Iris_Pending_Orders_By_DeliveryMethod] 'integration'
	EXEC [dbo].[Iris_Pending_Orders_By_DeliveryMethod] NULL
*/

CREATE PROCEDURE [dbo].[Iris_Pending_Orders_By_DeliveryMethod]
	@DeliveryMethod NVARCHAR(100) NULL
AS

	IF(@DeliveryMethod IN ('onlinedb','Call_in','fax','fax-copyofcheck','Mail-copyofcheck','mail','e-mail','integration'))
	BEGIN
		SELECT  dbo.Crim.status, dbo.Crim.Ordered, dbo.Iris_Researchers.R_Name AS vendor, dbo.Iris_Researchers.R_Delivery,-- appl.first,appl.last,
				dbo.Crim.CNTY_NO, dbo.Iris_Researchers.R_id AS vendorid, dbo.Iris_Researchers.R_Firstname, dbo.Iris_Researchers.R_Lastname, 
				dbo.Crim.batchnumber, dbo.Crim.IRIS_REC, CONVERT(numeric(7, 2), dbo.ElapsedBusinessDays(dbo.Crim.Ordered, GETDATE())) 
				AS Elapsed, dbo.Counties.A_County, dbo.Counties.State, dbo.Counties.A_County + ' , ' + dbo.Counties.State AS county
		FROM  dbo.Appl WITH (NOLOCK) 
		INNER JOIN dbo.Crim WITH (NOLOCK) ON dbo.Appl.APNO = dbo.Crim.APNO 
		INNER JOIN dbo.Counties WITH (NOLOCK) ON dbo.Crim.CNTY_NO = dbo.Counties.CNTY_NO 
		LEFT OUTER JOIN dbo.Iris_Researchers WITH (NOLOCK) ON dbo.Crim.vendorid = dbo.Iris_Researchers.R_id
		WHERE (dbo.Crim.IRIS_REC = 'yes') 
		  AND (dbo.Crim.Clear = 'O') 
		  AND dbo.Appl.CLNO not in (3468) 
		  AND (dbo.crim.IsHidden = 0 ) -- Added this by Santosh on 06/24/13 to exclude BAD APPS and unused searches
		GROUP BY dbo.Crim.status, dbo.Crim.Ordered, dbo.Iris_Researchers.R_Name, dbo.Iris_Researchers.R_Firstname, dbo.Iris_Researchers.R_Lastname, 
				 dbo.Crim.batchnumber,  dbo.Appl.ApStatus, dbo.Iris_Researchers.R_id, dbo.Iris_Researchers.R_Delivery, dbo.Crim.County, dbo.Crim.IRIS_REC, 
				 dbo.Crim.CNTY_NO, dbo.Counties.A_County, dbo.Counties.State--,appl.first,appl.last
		HAVING (dbo.Appl.ApStatus IN ('p','w')) 
		   AND (NOT (dbo.Crim.batchnumber IS NULL)) 
		   AND (dbo.Iris_Researchers.R_Delivery = @DeliveryMethod)
		ORDER BY CONVERT(numeric(7, 2), dbo.ElapsedBusinessDays(dbo.Crim.Ordered, GETDATE())) DESC
	END
	ELSE IF @DeliveryMethod IN ('InHouse')
	BEGIN
		SELECT  dbo.Crim.status, dbo.Crim.Ordered, dbo.Iris_Researchers.R_Name AS vendor, dbo.Iris_Researchers.R_Delivery, appl.first,appl.last,
				appl.dob, appl.apno, crim.crimid, dbo.Crim.CNTY_NO, dbo.Iris_Researchers.R_id AS vendorid	, dbo.Iris_Researchers.R_Firstname, dbo.Iris_Researchers.R_Lastname,
				dbo.Crim.batchnumber, dbo.Crim.IRIS_REC, CONVERT(numeric(7, 2), dbo.ElapsedBusinessDays(dbo.Crim.Ordered, GETDATE())) AS Elapsed, 
				dbo.Counties.A_County, dbo.Counties.State, dbo.Counties.A_County + ' , ' + dbo.Counties.State AS county
		FROM  dbo.Appl WITH (NOLOCK) 
		INNER JOIN dbo.Crim WITH (NOLOCK) ON dbo.Appl.APNO = dbo.Crim.APNO 
		INNER JOIN dbo.Counties WITH (NOLOCK) ON dbo.Crim.CNTY_NO = dbo.Counties.CNTY_NO 
		LEFT OUTER JOIN dbo.Iris_Researchers WITH (NOLOCK) ON dbo.Crim.vendorid = dbo.Iris_Researchers.R_id
		WHERE (dbo.Crim.IRIS_REC = 'yes') 
		  AND (dbo.Crim.Clear = 'O') 
		  AND (dbo.Iris_Researchers.R_ID <> 262)
		  AND dbo.Appl.CLNO not in (3468) 
		  AND (dbo.crim.IsHidden = 0 ) -- Added this by Santosh on 06/24/13 to exclude BAD APPS and unused searches
		GROUP BY dbo.Crim.status, dbo.Crim.Ordered, dbo.Iris_Researchers.R_Name, dbo.Iris_Researchers.R_Firstname, dbo.Iris_Researchers.R_Lastname, 
				 dbo.Crim.batchnumber, dbo.Appl.ApStatus, dbo.Iris_Researchers.R_id, dbo.Iris_Researchers.R_Delivery, dbo.Crim.County, dbo.Crim.IRIS_REC, 
				 dbo.Crim.CNTY_NO, dbo.Counties.A_County, dbo.Counties.State,appl.first,appl.last,appl.dob,appl.apno,crim.crimid
		HAVING (dbo.Appl.ApStatus IN ('p','w')) 
		   AND (dbo.Iris_Researchers.R_Delivery = @DeliveryMethod)
		ORDER BY CONVERT(numeric(7, 2), dbo.ElapsedBusinessDays(dbo.Crim.Ordered, GETDATE())) desc,dbo.Crim.batchnumber
	END
	ELSE
	BEGIN
		-- for DPS_InHouse Orders
		SELECT  dbo.Crim.status, dbo.Crim.Ordered, dbo.Iris_Researchers.R_Name AS vendor, dbo.Iris_Researchers.R_Delivery, appl.first,appl.last,appl.dob,appl.apno,crim.crimid,
				dbo.Crim.CNTY_NO, dbo.Iris_Researchers.R_id AS vendorid, dbo.Iris_Researchers.R_Firstname, dbo.Iris_Researchers.R_Lastname, 
				dbo.Crim.batchnumber, dbo.Crim.IRIS_REC, CONVERT(numeric(7, 2), dbo.ElapsedBusinessDays(dbo.Crim.Ordered, GETDATE())) 
				AS Elapsed, dbo.Counties.A_County, dbo.Counties.State, dbo.Counties.A_County + ' , ' + dbo.Counties.State AS county
		FROM  dbo.Appl WITH (NOLOCK) 
		INNER JOIN dbo.Crim WITH (NOLOCK) ON dbo.Appl.APNO = dbo.Crim.APNO 
		INNER JOIN dbo.Counties WITH (NOLOCK) ON dbo.Crim.CNTY_NO = dbo.Counties.CNTY_NO 
		LEFT OUTER JOIN dbo.Iris_Researchers WITH (NOLOCK) ON dbo.Crim.vendorid = dbo.Iris_Researchers.R_id
		WHERE (dbo.Crim.IRIS_REC = 'yes') 
		  AND (dbo.Crim.Clear = 'O') 
		  AND (dbo.Iris_Researchers.R_id = 262)
		  AND dbo.Appl.CLNO not in (3468) 
		  AND (dbo.crim.IsHidden = 0 ) -- Added this by Santosh on 06/24/13 to exclude BAD APPS and unused searches
		GROUP BY dbo.Crim.status, dbo.Crim.Ordered, dbo.Iris_Researchers.R_Name, dbo.Iris_Researchers.R_Firstname, dbo.Iris_Researchers.R_Lastname, 
				 dbo.Crim.batchnumber,  dbo.Appl.ApStatus, dbo.Iris_Researchers.R_id, dbo.Iris_Researchers.R_Delivery, dbo.Crim.County, dbo.Crim.IRIS_REC, 
				 dbo.Crim.CNTY_NO, dbo.Counties.A_County, dbo.Counties.State,appl.first,appl.last,appl.dob,appl.apno,crim.crimid
		HAVING (dbo.Appl.ApStatus IN ('p','w')) 
		   AND (NOT (dbo.Crim.batchnumber IS NULL)) 
		   AND (dbo.Iris_Researchers.R_Delivery = 'InHouse')
		ORDER BY CONVERT(numeric(7, 2), dbo.ElapsedBusinessDays(dbo.Crim.Ordered, GETDATE())) desc,dbo.Crim.batchnumber
	END