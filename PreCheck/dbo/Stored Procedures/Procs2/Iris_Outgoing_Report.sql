-- Alter Procedure Iris_Outgoing_Report

/*
Modifed By: Deepak Vodethela
Modified Date: 02/23/2017
Description: This SP is used in "resendorder.rpt". Modified to fit in the new requirement of Alias List Display on report using the new tables.
Execution:

Others - [dbo].[Iris_Outgoing_Report] 5617172
OMNI - [dbo].[Iris_Outgoing_Report] 5274220  
*/

CREATE PROCEDURE [dbo].[Iris_Outgoing_Report] @batchnumber int AS

-- Temp table to hold values that are sent out.
	CREATE TABLE #tmpCrimsSentToVendor([ApplAliasID] [int], [APNO] [int],[First] [varchar](50),[Middle] [varchar](50), [Last] [varchar](50), [IsMaiden] [bit], [Generation] [varchar](15), 
										[IsPublicRecordQualified] [bit],[IsPrimaryName] [bit],[ApplAlias_IsActive] [bit], [AddedBy] [varchar](25))

	DECLARE @CrimID int, @DeliveryMethod varchar(50)

	SELECT @CrimID = CrimID, @DeliveryMethod = deliverymethod FROM Crim(NOLOCK) WHERE batchnumber = @batchnumber      

	--SELECT @CrimID AS CrimID, @DeliveryMethod AS DeliveryMethod

	-- Insert into temp table
	INSERT INTO #tmpCrimsSentToVendor EXEC [dbo].[Crim_GetAliasesToSend] @CrimID 

	--SELECT * FROM #tmpCrimsSentToVendor
	
	SELECT APNO, ISNULL(Last,'') +' '+ ISNULL(First,'') +' '+ ISNULL(Middle,'') +' '+ ISNULL(Generation,'') AS QualifiedNames 
		INTO #tmpAliasesSentToVendor
	FROM #tmpCrimsSentToVendor
	WHERE IsPrimaryName = 0

	--SELECT * FROM #tmpAliasesSentToVendor

	SELECT  APNO,
			AliasesSentToVendor = STUFF((SELECT '/ ' + QualifiedNames
										FROM #tmpAliasesSentToVendor b 
										WHERE b.APNO = a.APNO 
										FOR XML PATH('')), 1, 2, '') 
		INTO #tmpSelectedAliases
	FROM #tmpAliasesSentToVendor A
	GROUP BY APNO
	ORDER BY APNO

	--SELECT * FROM #tmpSelectedAliases

	IF(@DeliveryMethod = 'WEB SERVICE') 
	BEGIN
		SELECT  A.[Last],A.[First],A.Middle,A.Alias,A.Alias2,A.Alias3,A.Alias4,A.SSN,A.DOB, 
				C.CRIM_SpecialInstr, A.Addr_Num + ' ' + A.Addr_Street AS address, A.City,A.State,A.Zip, 
				A.ApStatus, C.txtlast, C.txtalias, C.txtalias2, C.txtalias3, C.txtalias4,
				CAST('' AS VARCHAR(2000)) AS Expr1, 
				A.Alias1_Last,A.Alias1_First,A.Alias1_Middle,A.Alias1_Generation, 
				A.Alias2_Last,A.Alias2_First,A.Alias2_Middle,A.Alias2_Generation, 
				A.Alias3_Last,A.Alias3_First,A.Alias3_Middle,A.Alias3_Generation, 
				A.Alias4_Last,A.Alias4_First,A.Alias4_Middle,A.Alias4_Generation, 
				A.Alias2 AS Expr2, 
				A.Alias3 AS Expr3, 
				A.Alias4 AS Expr4, 
				IR.R_Name, IR.R_Email_Address, C.Ordered, IR.R_Zip, 
				IR.R_Phone, IR.R_Fax, IR.R_Firstname, IR.R_Lastname, 
				IR.R_Middlename, C.batchnumber, IR.R_VendorNotes, C.County AS Bis_Crim_County, 
				A.APNO, CN.A_County, CN.State AS crimstate,CN.country, C.CrimID
		FROM dbo.Appl AS A WITH (NOLOCK) 
		INNER JOIN dbo.Crim AS C WITH (NOLOCK) ON A.APNO = C.APNO 
		INNER JOIN dbo.Iris_Researchers AS IR WITH (NOLOCK) ON C.vendorid = IR.R_id 
		INNER JOIN dbo.TblCounties AS CN WITH (NOLOCK) ON C.CNTY_NO = CN.CNTY_NO 
		WHERE (C.batchnumber = @batchnumber)
		  AND (A.ApStatus = 'p' OR  A.ApStatus = 'w') 
		  AND (C.clear = 'O')
	END
	ELSE
	BEGIN
		SELECT 	A.Last, A.First, A.Middle,
				A.Alias, A.Alias2, A.Alias3, A.Alias4, A.SSN, A.DOB, 
				C.CRIM_SpecialInstr, A.Addr_Num + ' ' + A.Addr_Street AS address, A.City, A.State, A.Zip, 
				A.ApStatus, 
				C.txtlast, C.txtalias, C.txtalias2, C.txtalias3, C.txtalias4, 
				isnull(CAST(TA.AliasesSentToVendor AS VARCHAR(2000)),'') AS Expr1, 
				'' Alias1_Last, '' Alias1_First, '' Alias1_Middle, '' Alias1_Generation, 
				'' Alias2_Last, '' Alias2_First, '' Alias2_Middle, '' Alias2_Generation, 
				'' Alias3_Last, '' Alias3_First, '' Alias3_Middle, '' Alias3_Generation, 
				'' Alias4_Last, '' Alias4_First, '' Alias4_Middle, '' Alias4_Generation, 
				'' AS Expr2, 
				'' AS Expr3, 
				'' AS Expr4, 
				IR.R_Name, IR.R_Email_Address, C.Ordered, IR.R_Zip, 
				IR.R_Phone, IR.R_Fax, 
				IR.R_Firstname, IR.R_Lastname, IR.R_Middlename, 
				C.batchnumber, IR.R_VendorNotes, C.County AS Bis_Crim_County, 
				A.APNO, CN.A_County, CN.State AS crimstate,CN.country, C.CrimID
		FROM dbo.Appl AS A WITH (NOLOCK) 
		INNER JOIN dbo.Crim AS C WITH (NOLOCK) ON A.APNO = C.APNO 
		INNER JOIN dbo.Iris_Researchers AS IR WITH (NOLOCK) ON C.vendorid = IR.R_id 
		INNER JOIN dbo.TblCounties AS CN WITH (NOLOCK) ON C.CNTY_NO = CN.CNTY_NO 
		LEFT JOIN #tmpCrimsSentToVendor AS T ON A.APNO = T.APNO AND T.IsPrimaryName = 1
		LEFT JOIN #tmpSelectedAliases AS TA ON A.APNO = TA.APNO 
		WHERE (C.batchnumber = @batchnumber)
		  AND (A.ApStatus = 'p' OR  A.ApStatus = 'w') 
		  AND (C.clear = 'O')

	END

	DROP TABLE #tmpCrimsSentToVendor
	DROP TABLE #tmpAliasesSentToVendor
	DROP TABLE #tmpSelectedAliases

/*
SELECT  dbo.Appl.[Last], dbo.Appl.[First], dbo.Appl.Middle, dbo.Appl.Alias, dbo.Appl.Alias2, dbo.Appl.Alias3, dbo.Appl.Alias4, dbo.Appl.SSN, dbo.Appl.DOB, 
        dbo.Crim.CRIM_SpecialInstr, dbo.Appl.Addr_Num + ' ' + dbo.Appl.Addr_Street AS address, dbo.Appl.City, dbo.Appl.State, dbo.Appl.Zip, 
        dbo.Appl.ApStatus, dbo.Crim.txtlast, dbo.Crim.txtalias, dbo.Crim.txtalias2, dbo.Crim.txtalias3, dbo.Crim.txtalias4, dbo.Appl.Alias AS Expr1, 
        dbo.Appl.Alias1_Last, dbo.Appl.Alias1_First, dbo.Appl.Alias1_Middle, dbo.Appl.Alias1_Generation, dbo.Appl.Alias2_Last, dbo.Appl.Alias2_First, 
        dbo.Appl.Alias2_Middle, dbo.Appl.Alias2_Generation, dbo.Appl.Alias3_Last, dbo.Appl.Alias3_First, dbo.Appl.Alias3_Middle, dbo.Appl.Alias3_Generation, 
        dbo.Appl.Alias4_Last, dbo.Appl.Alias4_First, dbo.Appl.Alias4_Middle, dbo.Appl.Alias4_Generation, dbo.Appl.Alias2 AS Expr2, dbo.Appl.Alias3 AS Expr3, 
        dbo.Appl.Alias4 AS Expr4, dbo.Iris_Researchers.R_Name, dbo.Iris_Researchers.R_Email_Address, dbo.Crim.Ordered, dbo.Iris_Researchers.R_Zip, 
        dbo.Iris_Researchers.R_Phone, dbo.Iris_Researchers.R_Fax, dbo.Iris_Researchers.R_Firstname, dbo.Iris_Researchers.R_Lastname, 
        dbo.Iris_Researchers.R_Middlename, dbo.Crim.batchnumber, dbo.Iris_Researchers.R_VendorNotes, dbo.Crim.County AS Bis_Crim_County, 
        dbo.Appl.APNO, dbo.Counties.A_County, dbo.Counties.State AS crimstate,dbo.counties.country, dbo.Crim.CrimID
FROM  dbo.Appl WITH (NOLOCK) 
INNER JOIN dbo.Crim WITH (NOLOCK) ON dbo.Appl.APNO = dbo.Crim.APNO INNER JOIN
                      dbo.Iris_Researchers WITH (NOLOCK) ON dbo.Crim.vendorid = dbo.Iris_Researchers.R_id INNER JOIN
                      dbo.Counties WITH (NOLOCK) ON dbo.Crim.CNTY_NO = dbo.Counties.CNTY_NO 
WHERE     (dbo.Appl.ApStatus = 'p' OR  dbo.Appl.ApStatus = 'w') AND (dbo.Crim.batchnumber = @batchnumber)
and (crim.clear = 'O')
*/
