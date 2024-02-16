
/*
EXEC [IRIS_PendINgOrders] 759

EXEC [IRIS_PendINgOrders_INcludINg_Overflow_With_No_MiddleName] 759

EXEC [IRIS_PendINgOrders] null,1

EXEC [IRIS_PendINgOrders_INcludINg_Overflow_With_No_MiddleName] null,1


*/


CREATE procedure [dbo].[IRIS_PendingOrders_Including_Overflow_With_No_MiddleName] (@County INt = null,@CountyList BIT = 0)   
AS  
SET NOCOUNT ON
IF @CountyList = 1 -- Return a distINct list of counties
	BEGIN
		DECLARE @time time(3) = Current_TimeStamp;

		SELECT  DISTINCT 'Crim' SectiON,Cnty_No,ISNULL(VendorMappINg.VendorId,5) AS VendorId		
		FROM  
		(  
		SELECT Cnty_No  
		FROM Crim C WITH (NOLOCK) INNER JOIN Appl A WITH (NOLOCK) ON A.APNO = C.APNO   
		WHERE  C.txtlASt = 1 
		--AND   (C.Cnty_no = @County) 
		AND (C.Clear IN( 'O','W')) 
		AND (A.INUse is null) 
		AND c.ishidden = 0   
		AND A.CLNO NOT IN (3468,2135) -- Added this by Santosh ON 06/24/13 to exclude BAD APPS 
		UNION ALL  
		SELECT Cnty_No  
		FROM Crim C WITH (NOLOCK) 
		INNER JOIN Appl A WITH (NOLOCK) ON A.APNO = C.APNO   
		WHERE  C.txtaliAS = 1  AND (LTRIM(RTRIM((ISNULL(A.AliAS1_LASt,'') + ', ' + ISNULL(A.AliAS1_First, '') )))) <> ',' 
		--WHERE  C.txtaliAS = 1  AND (LTRIM(RTRIM((ISNULL(A.AliAS1_LASt,'') + ', ' + ISNULL(A.AliAS1_First, '') + ' ' + ISNULL(A.AliAS1_Middle, ''))))) <> ','  
		--AND   (C.Cnty_no = @County) 
		AND (C.Clear IN( 'O','W')) 
		AND (A.INUse is null) 
		AND c.ishidden = 0 
		AND A.CLNO NOT IN (3468,2135) -- Added this by Santosh ON 06/24/13 to exclude BAD APPS   
		UNION ALL  
		SELECT Cnty_No 
		FROM Crim C WITH (NOLOCK) INNER JOIN Appl A WITH (NOLOCK) ON A.APNO = C.APNO   
		WHERE  C.txtaliAS2 = 1  AND (LTRIM(RTRIM((ISNULL(A.AliAS2_LASt,'') + ', ' + ISNULL(A.AliAS2_First, '') )))) <> ','  
		--WHERE  C.txtaliAS2 = 1  AND (LTRIM(RTRIM((ISNULL(A.AliAS2_LASt,'') + ', ' + ISNULL(A.AliAS2_First, '') + ' ' + ISNULL(A.AliAS2_Middle, ''))))) <> ','  
		--AND   (C.Cnty_no = @County) 
		AND (C.Clear IN( 'O','W')) 
		AND (A.INUse is null) 
		AND c.ishidden = 0   
		AND A.CLNO NOT IN (3468,2135) -- Added this by Santosh ON 06/24/13 to exclude BAD APPS 
		UNION ALL  
		SELECT Cnty_No 
		FROM Crim C WITH (NOLOCK) INNER JOIN Appl A WITH (NOLOCK) ON A.APNO = C.APNO  
		WHERE  C.txtaliAS3 = 1  AND (LTRIM(RTRIM((ISNULL(A.AliAS3_LASt,'') + ', ' + ISNULL(A.AliAS3_First, '') )))) <> ','   
		--WHERE  C.txtaliAS3 = 1  AND (LTRIM(RTRIM((ISNULL(A.AliAS3_LASt,'') + ', ' + ISNULL(A.AliAS3_First, '') + ' ' + ISNULL(A.AliAS3_Middle, ''))))) <> ','  
		--AND   (C.Cnty_no = @County) 
		AND (C.Clear IN( 'O','W')) 
		AND (A.INUse is null) 
		AND c.ishidden = 0  
		AND A.CLNO NOT IN (3468,2135) -- Added this by Santosh ON 06/24/13 to exclude BAD APPS  
		UNION ALL  
		SELECT Cnty_No
		FROM Crim C WITH (NOLOCK) INNER JOIN Appl A WITH (NOLOCK) ON A.APNO = C.APNO 
		WHERE  C.txtaliAS4 = 1 AND (LTRIM(RTRIM((ISNULL(A.AliAS4_LASt,'') + ', ' + ISNULL(A.AliAS4_First, '') )))) <> ','    
		--WHERE  C.txtaliAS4 = 1 AND (LTRIM(RTRIM((ISNULL(A.AliAS4_LASt,'') + ', ' + ISNULL(A.AliAS4_First, '') + ' ' + ISNULL(A.AliAS4_Middle, ''))))) <> ','  
		--AND   (C.Cnty_no = @County) 
		AND (C.Clear IN( 'O','W')) 
		AND (A.INUse is null) 
		AND c.ishidden = 0 
		AND A.CLNO NOT IN (3468,2135) -- Added this by Santosh ON 06/24/13 to exclude BAD APPS 
		UNION ALL 
		SELECT DISTINCT Cnty_No
		FROM Crim C WITH (NOLOCK) 
		INNER JOIN Appl A WITH (NOLOCK) ON A.APNO = C.APNO 
		INNER JOIN ApplAliAS AS AA(NOLOCK) ON A.APNO = AA.APNO
		WHERE (LTRIM(RTRIM((ISNULL(AA.LASt,'') + ', ' + ISNULL(AA.First, '') )))) <> ','    
		--AND   (C.Cnty_no = @County) 
		AND (C.Clear IN( 'O','W')) 
		AND (A.INUse is null) 
		AND c.ishidden = 0 
		AND A.CLNO NOT IN (3468,2135)
		) Qry INner joIN DataXtract_RequestMappINg M ON cASt(Qry.Cnty_No AS varchar)= SectiONKeyID
		left joIN dbo.Dataxtract_VendorRequestMappINg VendorMappINg ON M.DataXtract_RequestMappINgXMLID = VendorMappINg.DataXtract_RequestMappINgId
		WHERE M.SectiON = 'Crim' AND IsAutomatiONEnabled = 1
		AND (CASe when (OffPeakHoursONly =1 AND  @time > '4 AM' AND @time <'6 PM') then 0 else 1 end) = 1 -- ONly schedule these between 7 PM AND 5 AM CST
	END
ELSE -- Return the pendINg list per county
	BEGIN
		SELECT DistINct 'Crim' Section,SectionID,Apno,County,Cnty_No,CAST(ISNULL(Ordered,'1/1/1900') AS DateTime) Ordered,
				Last,
				First,
				Middle,		
				DOB,
				right('00' + CONVERT(varchar(2),MONTH(DOB)),2)  DOB_MM,  right('00' + CONVERT(varchar(2),Day(DOB)),2) DOB_DD,Year(DOB) DOB_YYYY,SSN,left(SSN,3) SSN1, CASe When charINdex('-',SSN)>0 then substrINg(SSN,5,2) else substrINg(SSN,4,2) end SSN2,right(SSN,4) SSN3,cASt(KnownHits AS varchar(max)) KnownHits --,'Doug' TestField,null Testfield2  
		INTO #tmpPendingSearches
		FROM  
		(  
		SELECT C.CrimID SectiONID,C.APNO ,C.County,C.Cnty_no, C.Ordered,ISNULL(A.LASt,'') LASt, ISNULL(A.First, '') First,Null Middle, --ISNULL(A.Middle, '') middle,  
				A.DOB AS DOB,  
				cASe when c.Cnty_no = 3906 then  REPLACE(A.SSN,'-','') else A.SSN end AS SSN,  
				ISNULL(C.CRIM_SpecialINstr,'') AS KnownHits  
		FROM Crim C WITH (NOLOCK) 
		INNER JOIN Appl A WITH (NOLOCK) ON A.APNO = C.APNO   
		WHERE  --C.txtlASt = 1 
		  --AND 
		  (C.Cnty_no = @County OR @County IS NULL) 
		  AND (C.Clear IN( 'O','W')) 
		  AND (A.INUse is null) 
		  AND (ISNULL(c.INUse,0) = 0)
		  AND c.ishidden = 0   
		  AND A.CLNO NOT IN (3468,2135) -- Added this by Santosh ON 06/24/13 to exclude BAD APPS 
		UNION ALL  
		SELECT C.CrimID SectiONID,C.APNO ,C.County,C.Cnty_no, C.Ordered,ISNULL(A.AliAS1_LASt,'') LASt, ISNULL(A.AliAS1_First, '') First,Null Middle, --ISNULL(A.AliAS1_Middle, '') middle,  
				A.DOB AS DOB,  
				cASe when c.Cnty_no = 3906 then  REPLACE(A.SSN,'-','') else A.SSN end AS SSN,    
				ISNULL(C.CRIM_SpecialINstr,'') AS KnownHits  
		FROM Crim C WITH (NOLOCK) 
		INNER JOIN Appl A WITH (NOLOCK) ON A.APNO = C.APNO   
		WHERE  --C.txtaliAS = 1  AND 
				(LTRIM(RTRIM((ISNULL(A.AliAS1_LASt,'') + ', ' + ISNULL(A.AliAS1_First, '') )))) <> ',' 
		  AND (C.Cnty_no = @County OR @County IS NULL) 
		  AND (C.Clear IN( 'O','W')) 
		  AND (A.INUse is null) 
		  AND (ISNULL(c.INUse,0) = 0)
		  AND c.ishidden = 0   
		AND A.CLNO NOT IN (3468,2135) -- Added this by Santosh ON 06/24/13 to exclude BAD APPS 
		UNION ALL  
		SELECT C.CrimID SectiONID,C.APNO ,C.County,C.Cnty_no, C.Ordered,ISNULL(A.AliAS2_LASt,'') LASt, ISNULL(A.AliAS2_First, '') First,Null Middle, --ISNULL(A.AliAS2_Middle, '') middle,  
				A.DOB AS DOB,  
				cASe when c.Cnty_no = 3906 then  REPLACE(A.SSN,'-','') else A.SSN end AS SSN,  
				ISNULL(C.CRIM_SpecialINstr,'') AS KnownHits  
		FROM Crim C WITH (NOLOCK) 
		INNER JOIN Appl A WITH (NOLOCK) ON A.APNO = C.APNO   
		WHERE  --C.txtaliAS2 = 1  AND 
				(LTRIM(RTRIM((ISNULL(A.AliAS2_LASt,'') + ', ' + ISNULL(A.AliAS2_First, '') )))) <> ','  
		  AND (C.Cnty_no = @County OR @County IS NULL) 
		  AND (C.Clear IN( 'O','W')) 
		  AND (A.INUse is null) 
		  AND (ISNULL(c.INUse,0) = 0)
		  AND c.ishidden = 0  
		  AND A.CLNO NOT IN (3468,2135) -- Added this by Santosh ON 06/24/13 to exclude BAD APPS 		 
		UNION ALL  
		SELECT C.CrimID SectiONID,C.APNO ,C.County,C.Cnty_no, C.Ordered,ISNULL(A.AliAS3_LASt,'') LASt, ISNULL(A.AliAS3_First, '') First,Null Middle, --ISNULL(A.AliAS3_Middle, '') middle,  
				A.DOB AS DOB,  
				cASe when c.Cnty_no = 3906 then  REPLACE(A.SSN,'-','') else A.SSN end AS SSN,   
				ISNULL(C.CRIM_SpecialINstr,'') AS KnownHits  
		FROM Crim C WITH (NOLOCK) 
		INNER JOIN Appl A WITH (NOLOCK) ON A.APNO = C.APNO   
		WHERE  --C.txtaliAS3 = 1  AND 
				(LTRIM(RTRIM((ISNULL(A.AliAS3_LASt,'') + ', ' + ISNULL(A.AliAS3_First, '') )))) <> ','  
		  AND (C.Cnty_no = @County OR @County IS NULL) 
		  AND (C.Clear IN( 'O','W')) 
		  AND (A.INUse is null) 
		  AND (ISNULL(c.INUse,0) = 0)
		  AND c.ishidden = 0   
		  AND A.CLNO NOT IN (3468,2135) -- Added this by Santosh ON 06/24/13 to exclude BAD APPS 
		UNION ALL  
		SELECT C.CrimID SectiONID,C.APNO ,C.County,C.Cnty_no, C.Ordered,ISNULL(A.AliAS4_LASt,'') LASt, ISNULL(A.AliAS4_First, '') First,Null Middle, --ISNULL(A.AliAS4_Middle, '') middle,  
				A.DOB AS DOB,  
				cASe when c.Cnty_no = 3906 then  REPLACE(A.SSN,'-','') else A.SSN end AS SSN,  
				ISNULL(C.CRIM_SpecialINstr,'') AS KnownHits  
		FROM Crim C WITH (NOLOCK) 
		INNER JOIN Appl A WITH (NOLOCK) ON A.APNO = C.APNO   
		WHERE  --C.txtaliAS4 = 1 AND 
				(LTRIM(RTRIM((ISNULL(A.AliAS4_LASt,'') + ', ' + ISNULL(A.AliAS4_First, '') )))) <> ','  
		  AND (C.Cnty_no = @County OR @County IS NULL) 
		  AND (C.Clear IN( 'O','W')) 
		  AND (A.INUse is null) 
		  AND (ISNULL(c.INUse,0) = 0)
		  AND c.ishidden = 0 
		  AND A.CLNO NOT IN (3468,2135) -- Added this by Santosh ON 06/24/13 to exclude BAD APPS
		UNION ALL  
		SELECT C.CrimID SectiONID,C.APNO ,C.County,C.Cnty_no, C.Ordered,ISNULL(AA.LASt,'') LASt, ISNULL(AA.First, '') First,Null Middle, --ISNULL(A.AliAS4_Middle, '') middle,  
				A.DOB AS DOB,  
				cASe when c.Cnty_no = 3906 then  REPLACE(A.SSN,'-','') else A.SSN end AS SSN,  
				ISNULL(C.CRIM_SpecialINstr,'') AS KnownHits  
		FROM Crim C WITH (NOLOCK) 
		INNER JOIN Appl A WITH (NOLOCK) ON A.APNO = C.APNO  
		INNER JOIN ApplAliAS AS AA(NOLOCK) ON A.APNO = AA.APNO
		WHERE  C.txtaliAS4 = 1 AND (LTRIM(RTRIM((ISNULL(AA.LASt,'') + ', ' + ISNULL(AA.First, '') )))) <> ','    
		  AND (C.Cnty_no = @County OR @County IS NULL) 
  		  AND (C.Clear IN( 'O','W')) 
		  AND (A.INUse is null) 
		  AND (ISNULL(c.INUse,0) = 0)
		  AND c.ishidden = 0 
		  AND A.CLNO NOT IN (3468,2135) 
		) Qry 
		ORDER BY CAST(ISNULL(Ordered,'1/1/1900') AS DateTime)
		/*
			-- Add Row Number to the Pending Searches
			SELECT  Section,SectionID,Apno,County,Cnty_No,Ordered,Last,First,Middle,DOB, KnownHits, ROW_NUMBER() OVER (ORDER BY apno) AS RowNumber 
			FROM #tmpPendingSearches t
			ORDER BY t.APNO
			*/
			-- Add Row Number and Dump data into a new Temp table to Remove the matching transpose names
			SELECT  T.Section, T.SectionID, T.Apno, T.County, T.Cnty_No, T.Ordered, T.Last, T.First, T.Middle, T.DOB, T.KnownHits, ROW_NUMBER() OVER (ORDER BY apno) AS RowNumber 
					INTO #tmpSearches 
			FROM #tmpPendingSearches T
			ORDER BY t.APNO

			/*
			-- Get the Transpose list
			SELECT T1.Section, T1.SectionID, T1.Apno, T1.County, T1.Cnty_No, T1.Ordered, T1.Last, T1.First, T1.Middle, T1.DOB, T1.KnownHits
					--T1.*
			FROM #tmpSearches AS t1
			INNER JOIN #tmpSearches AS t2 ON t1.apno = t2.APNO AND t1.First = t2.LASt AND t1.LASt = t2.First
			*/

			-- Remove the matching transpose names from the main set
			SELECT *
					INTO #tmpTransposeSearch
			FROM #tmpSearches 
			WHERE RowNumber NOT IN (SELECT MAX(t1.RowNumber)
									FROM #tmpSearches AS t1
									INNER JOIN #tmpSearches AS t2 ON t1.apno = t2.APNO AND t1.First = t2.LASt AND t1.LASt = t2.First
									GROUP BY t1.APNO
								   )
			ORDER BY APNo

			-- Get the final list
			SELECT Section,SectionID,Apno,County,Cnty_No,Ordered,Last,First,Middle,DOB, KnownHits FROM #tmpTransposeSearch


		--ELSE
		--SELECT * FROM #tmpPendINgSearches 

		DROP TABLE #tmpPendingSearches
		DROP TABLE #tmpSearches
		DROP TABLE #tmpTransposeSearch


	END
SET NOCOUNT OFF	

