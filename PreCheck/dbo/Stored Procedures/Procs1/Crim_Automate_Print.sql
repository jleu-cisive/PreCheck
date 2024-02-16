-- Alter Procedure Crim_Automate_Print

/*
Modifed By: Deepak Vodethela
Modified Date: 02/23/2017
Description: This SP is used in "report1.rpt". Modified to fit in the new requirement of Alias List Display on report using the new tables.
Execution: EXEC [dbo].[Crim_Automate_Print] 4808203, 'CrimOnDB','O'
*/
CREATE PROCEDURE [dbo].[Crim_Automate_Print] 
(@newprintnumber int, @LockBy varchar(8), @Clear varchar(1))
AS
SET NOCOUNT ON
-- This SP was created from dbo.Iris_Automate_Print
-- The differences are the number of parameters and some of criterias are different

	-- Temp table to hold values that are sent out.
	CREATE TABLE #tmpCrimsSentToVendor([ApplAliasID] [int], [APNO] [int],[First] [varchar](50),[Middle] [varchar](50), [Last] [varchar](50), [IsMaiden] [bit], [Generation] [varchar](15), 
										[IsPublicRecordQualified] [bit],[IsPrimaryName] [bit],[ApplAlias_IsActive] [bit], [AddedBy] [varchar](25), [CrimID][int] null)

	-- Temp table to hold CrimID's
	CREATE TABLE #tmpCrims([ApplAliasID] [int], [APNO] [int],[First] [varchar](50),[Middle] [varchar](50), [Last] [varchar](50), [IsMaiden] [bit], [Generation] [varchar](15), 
											[IsPublicRecordQualified] [bit],[IsPrimaryName] [bit],[ApplAlias_IsActive] [bit], [AddedBy] [varchar](25))

	
	-- Get all the Crims for the parameter [Status]
	SELECT ROW_NUMBER() OVER(ORDER BY CrimID DESC) AS CrimRowNumber, CrimID, APNO, deliverymethod AS DeliveryMethod
		INTO #tmpCrimsForStatus 
	FROM Crim(NOLOCK) WHERE [STATUS] = @newprintnumber

	--SELECT * FROM #tmpCrimsForStatus ORDER BY CrimRowNumber

	DECLARE @TotalNumberOfCrimRecords int = (SELECT MAX(CrimRowNumber)FROM #tmpCrimsForStatus);
	DECLARE @CrimRecordRow int;
	DECLARE @Apno int;
	DECLARE @CrimID int;
	DECLARE @DeliveryMethod varchar(50)

	-- Get the true names that were actually sent out to vendors
	WHILE (@TotalNumberOfCrimRecords != 0)
	BEGIN	
			SELECT @CrimRecordRow = CrimRowNumber, @Apno = Apno, @CrimID = CrimID, @DeliveryMethod = DeliveryMethod
			FROM #tmpCrimsForStatus
			WHERE CrimRowNumber = @TotalNumberOfCrimRecords
			ORDER BY CrimRowNumber DESC		

			-- Get True names by CrimID
			INSERT INTO #tmpCrims EXEC [dbo].[Crim_GetAliasesToSend] @CrimID
			-- SELECT * FROM #tmpCrims

			INSERT INTO #tmpCrimsSentToVendor ([ApplAliasID] , [APNO] ,[First] ,[Middle] , [Last], [IsMaiden], [Generation], [IsPublicRecordQualified],[IsPrimaryName],[ApplAlias_IsActive], [AddedBy], [CrimID])  
			SELECT *, @CrimID from #tmpCrims

			-- Delete after insert such that same records will not be added
			DELETE FROM #tmpCrims
			
			-- SET the counter to -1
			SET @TotalNumberOfCrimRecords = @CrimRecordRow - 1

	END

	--SELECT * FROM #tmpCrimsForStatus
	--SELECT DISTINCT * FROM #tmpCrimsSentToVendor

	SELECT DISTINCT T.*, ISNULL(AliasCount,0) AliasCount
		INTO #tmpAliasCount
	FROM #tmpCrimsSentToVendor AS T
	INNER JOIN (SELECT DISTINCT CrimID, APNO, COUNT(1) AS AliasCount FROM #tmpCrimsSentToVendor(NOLOCK) GROUP BY CrimID, APNO) AS Y ON T.APNO = Y.APNO AND T.CrimID = Y.CrimID

	--SELECT '#tmpAliasCount' TableName, * FROM #tmpAliasCount

	SELECT	CrimID, APNO, ISNULL([Last],'') AS [Last], ISNULL([First],'') AS [First], ISNULL(Middle,'') AS Middle, ISNULL(Generation,'') AS Generation , 
			ISNULL(Last,'') +' '+ ISNULL(First,'') +' '+ ISNULL(Middle,'') +' '+ ISNULL(Generation,'') AS QualifiedNames, ISNULL(AliasCount,0) AliasCount
		INTO #tmpAliasesSentToVendor
	FROM #tmpAliasCount
	WHERE IsPrimaryName = 0

	--SELECT '#tmpAliasesSentToVendor' TableName, * FROM #tmpAliasesSentToVendor

	SELECT  CrimID, APNO,
			ISNULL([Last],'') AS [Last], 
			ISNULL([First],'') AS [First], 
			ISNULL(Middle,'') AS Middle, 
			ISNULL(Generation,'') AS Generation ,
			ISNULL(AliasCount,0) AliasCount,
			AliasesSentToVendor = STUFF((SELECT '/ ' + QualifiedNames
										FROM #tmpAliasesSentToVendor b 
										WHERE b.CrimID = a.CrimID 
										FOR XML PATH('')), 1, 2, '') 
		INTO #tmpSelectedAliases
	FROM #tmpAliasesSentToVendor A
	GROUP BY CrimID,APNO, Last, First, Middle, Generation, AliasCount
	ORDER BY APNO

	--SELECT '#tmpSelectedAliases' TableName, * FROM #tmpSelectedAliases

	--SELECT COUNT(DISTINCT DeliveryMethod) FROM #tmpCrimsForStatus(NOLOCK) WHERE DeliveryMethod = 'E-Mail'
	--SELECT COUNT(DISTINCT DeliveryMethod) FROM #tmpCrimsForStatus(NOLOCK) WHERE DeliveryMethod = 'WEB SERVICE'

	IF ((SELECT COUNT(DISTINCT DeliveryMethod) FROM #tmpCrimsForStatus(NOLOCK) WHERE DeliveryMethod = 'WEB SERVICE') = 1)
	BEGIN
		SELECT	A.[Last] , A.[First] , A.Middle
				, A.Alias , A.Alias2 , A.Alias3	, A.Alias4
				, A.SSN	, A.DOB	, C.CRIM_SpecialInstr
				, A.Addr_Num + ' ' + A.Addr_Street AS [address]
				, A.City , A.State , A.Zip , A.ApStatus
				, C.txtlast	, C.txtalias , C.txtalias2	, C.txtalias3 , C.txtalias4
				, CAST('' AS VARCHAR(2000)) AS Expr1
				, A.Alias1_Last	, A.Alias1_First , A.Alias1_Middle , A.Alias1_Generation
				, A.Alias2_Last	, A.Alias2_First , A.Alias2_Middle , A.Alias2_Generation
				, A.Alias3_Last	, A.Alias3_First , A.Alias3_Middle , A.Alias3_Generation
				, A.Alias4_Last	, A.Alias4_First , A.Alias4_Middle , A.Alias4_Generation
				, A.Alias2 AS Expr2
				, A.Alias3 AS Expr3
				, C.[Clear] AS Expr4	--A.Alias4 AS Expr4
				, IR.R_Name	, IR.R_Email_Address , C.Ordered, IR.R_Zip	, IR.R_Phone
				, IR.R_Fax	, IR.R_Firstname , IR.R_Lastname , IR.R_Middlename, C.batchnumber
				, IR.R_VendorNotes , C.County AS Bis_Crim_County , A.APNO , C2.A_County
				, C2.State AS crimstate	, C.status , C.batchnumber , C2.country	, C.crimid
		FROM dbo.Appl A WITH (NOLOCK) 
		INNER JOIN dbo.Crim C WITH (NOLOCK) ON A.APNO = C.APNO 
		INNER JOIN dbo.Iris_Researchers IR WITH (NOLOCK) ON C.vendorid = IR.R_id 
		INNER JOIN dbo.TblCounties C2 WITH (NOLOCK) ON C.CNTY_NO = C2.CNTY_NO
		WHERE (A.ApStatus = 'P' OR A.ApStatus = 'W') 
		  AND ISNULL(A.InUse, '') LIKE '%' + @LockBy + '%'
		  AND C.status = @newprintnumber
		  AND C.[Clear] = @Clear
  END
  ELSE
  BEGIN
		SELECT  --A.Last, A.First, A.Middle,
				--A.APNO, C.CrimID, ISNULL(TA.AliasCount,0) AliasCount,
				CASE WHEN ISNULL(TA.AliasCount,0) > 1 THEN A.[Last] ELSE
					(CASE WHEN LEN(ISNULL(CAST(TA.AliasesSentToVendor AS VARCHAR(2000)),'')) = 0 THEN A.[Last] ELSE TA.[Last] END) 
				END AS [Last],
				CASE WHEN ISNULL(TA.AliasCount,0) > 1 THEN A.[First] ELSE
					(CASE WHEN LEN(ISNULL(CAST(TA.AliasesSentToVendor AS VARCHAR(2000)),'')) = 0 THEN A.[First] ELSE TA.[First] END) 
				END AS [First],
				CASE WHEN ISNULL(TA.AliasCount,0) > 1 THEN A.Middle ELSE
					(CASE WHEN LEN(ISNULL(CAST(TA.AliasesSentToVendor AS VARCHAR(2000)),'')) = 0 THEN A.Middle ELSE TA.Middle END)
				END AS [Middle],
					A.Alias, A.Alias2, A.Alias3, A.Alias4, A.SSN, A.DOB, 
					C.CRIM_SpecialInstr, A.Addr_Num + ' ' + A.Addr_Street AS address, A.City, A.State, A.Zip, 
					A.ApStatus, 
					C.txtlast, C.txtalias, C.txtalias2, C.txtalias3, C.txtalias4, 
				CASE WHEN ISNULL(TA.AliasCount,0) > 1 THEN ISNULL(CAST(TA.AliasesSentToVendor AS VARCHAR(2000)),'') ELSE '' END AS Expr1,
					--'' AS Expr1,
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
			A.APNO, CN.A_County, CN.State AS crimstate,C.status,C.batchnumber,CN.country, C.crimid
		FROM dbo.Appl AS A WITH (NOLOCK) 
		INNER JOIN dbo.Crim AS C WITH (NOLOCK) ON A.APNO = C.APNO 
		INNER JOIN dbo.Iris_Researchers AS IR WITH (NOLOCK) ON C.vendorid = IR.R_id 
		INNER JOIN dbo.TblCounties AS CN WITH (NOLOCK) ON C.CNTY_NO = CN.CNTY_NO 
		LEFT JOIN #tmpCrimsSentToVendor AS T ON C.CrimID = T.CrimID AND T.IsPrimaryName = 1
		LEFT JOIN #tmpSelectedAliases AS TA ON C.CrimID = TA.CrimID
		WHERE (A.ApStatus = 'P' OR A.ApStatus = 'W') 
		  AND ISNULL(A.InUse, '') LIKE '%' + @LockBy + '%'
		  AND C.status = @newprintnumber
		  AND C.[Clear] = @Clear
  END


	DROP TABLE #tmpAliasCount
	DROP TABLE #tmpCrimsSentToVendor
	DROP TABLE #tmpCrimsForStatus
	DROP TABLE #tmpAliasesSentToVendor
	DROP TABLE #tmpSelectedAliases
	DROP TABLE #tmpCrims

	SET NOCOUNT OFF
