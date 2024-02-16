-- Alter Procedure Billing_PassThroughChargesBatch
-- =============================================
-- Modified By: Radhika Dereddy
-- Modified Date: 04/06/2018
/* Reason: It has come to the attention of Eddie Kemp that the additional court fees are not being charged per name being researched for criminal searches. 
   Eddie estimates that monthly losses are approximately $50K per month. 
   Each Pass Through fee must be multiplied by the total number of names searched via the research method, researcher, etc. 
   Alias Name Logic must be used to determine the number of names being submitted via the research method.
   The total costs associated with the Pass Through Charge(s) must be added to the invoice per the client manager settings.*/

-- Modified by Radhika Dereddy on 05/08/2018 - add the group by clause for ApplAliasID for not charging for duplicate names
-- Modified by Radhika Dereddy on 10/17/2018 - to remove applAliasid and include sectionkeyid, since the Alias automation logic fixed the duplicate entries in the system.
-- Modified by Deepak & Radhika on 10/29/2018 - Reworked on the process for Alias Court Fee Charges
-- Modified by Radhika Dereddy on 11/27/2018 - To charge the 4 statewide counties (6,7,19,3860) for only the primary name and exclude all other aliases for an apno per client and charge all aliases for all other counties

-- EXEC [dbo].[Billing_PassThroughChargesBatch] '11/01/2018','11/30/2018'
-- =============================================
CREATE PROCEDURE [dbo].[Billing_PassThroughChargesBatch]
(
	@StartDate datetime,
	@EndDate datetime	
)
AS
SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

	DECLARE @VendorforInternaltionalSearches int = 5905088

	-- Below configuration key is to charge the 4 counties only for the Primary name and exclude the alias names
	DECLARE @CountiesList varchar(1000)

	SELECT @CountiesList = Value FROM ClientConfiguration WHERE ConfigurationKey = 'CountiesExcludedFromAliasCourtFees'
	SELECT Value INTO #tmpSpecialCounties FROM dbo.fn_Split(@CountiesList, ',')
	--Select * from #tmpSpecialCounties

	-- Reportable Crims
	SELECT DISTINCT Z.APNO, Z.CLNO, Z.CNTY_NO, MIN(C.A_County) + ', ' + MIN(C.State) + ' Court Access Fee' AS 'Description', 
					(CASE WHEN Z.vendorid = @VendorforInternaltionalSearches THEN 1
						  WHEN SplCNTY.value IS NOT NULL THEN 1  
						  ELSE Z.NoOfNames 
					 END) AS NoOfNames,
					C.PassThroughCharge,
					(ISNULL(MAX(CASE WHEN Z.vendorid = @VendorforInternaltionalSearches THEN 1 
								     WHEN SplCNTY.value IS NOT NULL THEN 1 
									 ElSE Z.NoOfNames
								END), 1) *  MIN(C.PassThroughCharge)) AS 'Amount', 
					'' AS SearchesReturnedByVendor
			INTO #tmpReportable
	FROM dbo.TblCounties AS C(NOLOCK)
	LEFT OUTER JOIN #tmpSpecialCounties AS SplCNTY(NOLOCK) ON C.CNTY_NO = SplCNTY.value
	INNER JOIN (
				SELECT DISTINCT C2.apno, A.CLNO, c2.CNTY_NO, X.NoOfNames, C2.vendorid
				FROM dbo.Crim AS C2(NOLOCK) 
				INNER JOIN dbo.Appl AS A(NOLOCK) ON C2.APNO = A.APNO and A.ApStatus = 'F'
				INNER JOIN  
				(
					SELECT AA.APNO, S.SectionKeyID, COUNT(S.SectionKeyID) as NoOfNames
					FROM ApplALias AA (nolock)
					INNER JOIN dbo.ApplAlias_Sections AS S(NOLOCK) ON AA.ApplAliasID = S.ApplAliasID AND S.IsActive = 1 AND S.ApplSectionID = 5 
					WHERE AA.IsPublicRecordQualified = 1 
					  AND AA.IsActive = 1 
					GROUP BY AA.APNO, S.SectionKeyID
				) 
				AS X ON C2.CrimID = X.SectionKeyID
			   WHERE C2.IsHidden = 0
				 AND A.Billed = 0
			  ) Z  on C.CNTY_NO = Z.CNTY_NO AND C.PassThroughCharge > 0 
	GROUP BY Z.APNO, Z.CLNO, Z.CNTY_NO, Z.NoOfNames ,C.PassThroughCharge,Z.vendorid, SplCNTY.value
	ORDER BY Z.apno,Z.CNTY_NO

	--SELECT * FROM #tmpReportable t WHERE T.APNO	= 4318601

	-- Not Reportable records
	/*When a vendor returns multiple entries for a single Criminal record, the PRI marks the original (sent criminal record) as not reportable 
	  and adds an new criminal record as reportable to send it to client. The aliases that are associated with the original criminal record were never accounted for 
	  because of not reportable flag. The logic below captures these records*/
	SELECT DISTINCT Z.APNO, Z.CLNO, Z.CNTY_NO, MIN(C.A_County) + ', ' + MIN(C.State) + ' Court Access Fee' as 'Description', 
					(CASE WHEN Z.vendorid = @VendorforInternaltionalSearches THEN 1
						 WHEN SplCNTY.value IS NOT NULL THEN 1  
						 ELSE Z.NoOfNames 
					END) AS NoOfNames,
					C.PassThroughCharge,
					(ISNULL(Max(CASE WHEN Z.vendorid = @VendorforInternaltionalSearches THEN 1 
									 WHEN SplCNTY.value IS NOT NULL THEN 1 
									 ELSE Z.NoOfNames 
							    END), 1) *  MIN(C.PassThroughCharge)) as 'Amount',
					MIN(SearchesReturnedByVendor) AS SearchesReturnedByVendor
			INTO #tmpNotReportableButHasAliases
	FROM dbo.TblCounties AS C(NOLOCK)
	LEFT OUTER JOIN #tmpSpecialCounties AS SplCNTY(NOLOCK) ON C.CNTY_NO = SplCNTY.value
	INNER JOIN (
				SELECT c.APNO, Q.CLNO, c.CNTY_NO, COUNT(c.CrimID) AS SearchesReturnedByVendor, MIN(Q.NoOfNames) AS NoOfNames, c.vendorid
				FROM dbo.Crim c(NOLOCK)
				INNER JOIN (SELECT c.APNO, A.CLNO, c.CNTY_NO, COUNT(S.SectionKeyID) AS NoOfNames
							FROM dbo.Crim c(NOLOCK)
							INNER JOIN dbo.Appl AS A(NOLOCK) ON C.APNO = A.APNO and A.ApStatus = 'F'
							INNER JOIN dbo.ApplAlias_Sections S(NOLOCK) ON C.CrimID = S.SectionKeyID AND S.ApplSectionID = 5 AND S.IsActive = 1
							WHERE C.batchnumber IS NOT NULL
							  AND C.status IS NOT NULL
							  AND (C.Ordered IS NOT NULL OR C.IrisOrdered IS NOT NULL)
							  AND C.IsHidden = 1
							  AND A.Billed = 0
							GROUP BY c.APNO, A.CLNO, C.CNTY_NO, S.SectionKeyID) AS Q ON c.CNTY_NO = q.CNTY_NO AND C.APNO = Q.APNO
				WHERE c.Clear IN ('T','F')
				GROUP BY c.APNO, Q.CLNO, c.CNTY_NO, c.vendorid
				HAVING COUNT(c.CrimID) > 1
			  ) Z  on C.CNTY_NO = Z.CNTY_NO AND C.PassThroughCharge > 0 
	GROUP BY Z.APNO, Z.CLNO, Z.CNTY_NO, Z.NoOfNames ,C.PassThroughCharge,Z.vendorid,SplCNTY.value
	ORDER BY Z.apno,Z.CNTY_NO

	--SELECT * FROM #tmpReportable AS P WHERE P.APNO = 4318601 ORDER BY P.APNO, P.CNTY_NO
	--SELECT * FROM #tmpNotReportableButHasAliases AS P WHERE P.APNO = 4318601 ORDER BY P.APNO, P.CNTY_NO
	
	SELECT APNO, CLNO, CNTY_NO, Description, NoOfNames,PassThroughCharge,Amount, SearchesReturnedByVendor
		INTO #tmpReportableAndNotReportableCrims
	FROM (
			SELECT * FROM #tmpReportable
			UNION ALL
			SELECT * FROM #tmpNotReportableButHasAliases 
		) AS D

	--SELECT * FROM #tmpReportable AS P WHERE P.APNO = 4128867
	--SELECT * FROM #tmpNotReportableButHasAliases AS P WHERE P.APNO = 4128867
	--SELECT * FROM #tmpReportableAndNotReportableCrims AS P WHERE P.APNO = 4128867

	-- Capture all Crim records which are in conclusive status but do not have entry in ApplAlias_Sections table
	SELECT C2.CrimID, C2.APNO, A.CLNO, C.CNTY_NO, (C.A_County) + ', ' + (C.State) + ' Court Access Fee' AS 'Description', (C.PassThroughCharge) AS [PassThroughCharge], (C.PassThroughCharge) AS [Amount],
			t.apno as Tapno,(C2.deliverymethod) AS deliverymethod
		INTO #tmpChargesForAllDeliveryMethods
	FROM dbo.TblCounties AS C(NOLOCK)
	INNER JOIN dbo.Crim AS C2(NOLOCK) ON C.CNTY_NO = C2.CNTY_NO AND C.PassThroughCharge > 0 AND C2.IsHidden = 0                    
	INNER JOIN dbo.Appl AS A(NOLOCK) ON C2.APNO = A.APNO AND A.ApStatus = 'F'
	INNER JOIN dbo.Client AS Cl(NOLOCK) ON Cl.CLNO = A.CLNO AND A.Billed = 0
	LEFT OUTER JOIN #tmpReportableAndNotReportableCrims AS t ON c2.apno = t.apno AND c2.CNTY_NO = t.CNTY_NO
	WHERE A.Billed = 0
	  AND C2.Clear IN ('T','F')
	  AND (c2.Ordered IS NOT NULL OR c2.IrisOrdered IS NOT NULL)
	ORDER BY c2.apno

	--SELECT * FROM #tmpChargesForAllDeliveryMethods t WHERE T.APNO = 4318601

	/* START - The below logic is to capture number of Aliases selected for WEB SERVICE Delivery method from Crim table.
		TO DO - Implement changes on IRIS to capture Aliases selected for WEB SERVICE Delivey method to insert into ApplAlias_Sections table.
				Once the above change is completed, remove this logic.
	*/
	-- Temp table to hold values that are sent out.
	CREATE TABLE #tmpCrimsSentToVendor(AliasesSelected varchar(100), NoOfAliasesSelected [int], CrimID [int], Apno [int])

	-- Temp table to hold CrimID's
	CREATE TABLE #tmpCrims(AliasesSelected varchar(100), NoOfAliasesSelected [int], CrimID [int], Apno [int])

	--SELECT * FROM #tmpInvDetail K ORDER BY K.APNO

	-- 05/04/2019 - Deepak - Added the below logic to charge once per Crim Record specifically for "WEB SERVICE" vendors
	;WITH cte_W1 AS
	(
		SELECT K.CrimID, K.APNO, K.CLNO, K.CNTY_NO, K.Description, K.PassThroughCharge, K.Tapno
		FROM #tmpChargesForAllDeliveryMethods K 
		WHERE K.Tapno IS NULL
		  AND K.deliverymethod = 'WEB SERVICE'
	),
	cte_W2 AS 
	(
		SELECT 
			a.APNO, A.CLNO, C.CNTY_NO, A.Description, a.PassThroughCharge, c.VendorID,
			MAX(ISNULL(CONVERT(INT, c.txtalias), 0)) AS Alias1,
			MAX(ISNULL(CONVERT(INT, c.txtalias2), 0)) AS Alias2,
			MAX(ISNULL(CONVERT(INT, c.txtalias3), 0)) AS Alias3,
			MAX(ISNULL(CONVERT(INT, c.txtalias4), 0)) AS Alias4,
			MAX(ISNULL(CONVERT(INT, c.txtlast), 0)) AS Alias5
		FROM cte_W1 AS a WITH (NOLOCK)
			INNER JOIN Crim (NOLOCK) AS c ON c.APNO = a.APNO AND c.CrimID = a.CrimID
		GROUP BY a.APNO, a.CLNO, c.CNTY_NO, a.Description, a.PassThroughCharge,c.VendorID
	), 
	cte_W3 AS
	(
		SELECT *,
			Alias1 + Alias2 + Alias3 + Alias4 + Alias5 AS NoOfNames
		FROM cte_W2 WITH (NOLOCK)
	),cte_W4 AS
	(
		SELECT 
			APNO,
			CLNO,
			CNTY_NO,
			Description,
			PassThroughCharge,
			NoOfNames,
			IIF(CNTY_NO IN (SELECT [value] FROM #tmpSpecialCounties) OR VendorID = @VendorforInternaltionalSearches ,1, NoOfNames) * PassThroughCharge AS Amount
		FROM cte_W3 WITH (NOLOCK)
	)
	
	SELECT * INTO #tmpWebServiceCharges FROM cte_W4 WITH (NOLOCK);

	--SELECT * FROM #tmpWebServiceCharges AS A WHERE A.Apno = 4128867 ORDER BY A.APNO

	/* END - The above logic is to capture number of Aliases selected for WEB SERVICE Delivery method from Crim table.*/

	SELECT DISTINCT Z.APNO, Z.CLNO, Z.CNTY_NO, Z.Description, Z.NoOfNames, Z.PassThroughCharge, Z.Amount
			INTO #tmpInvDetail
	FROM (
			SELECT DISTINCT x.APNO, x.CLNO, x.CNTY_NO, x.NoOfNames, x.PassThroughCharge, x.Amount, x.Description FROM #tmpReportableAndNotReportableCrims AS x
			UNION ALL
			SELECT G.APNO, G.CLNO, G.CNTY_NO, G.NoOfNames, G.PassThroughCharge, G.Amount, G.[Description]
			FROM #tmpWebServiceCharges AS G
			UNION ALL
			SELECT DISTINCT K.APNO, K.CLNO, K.CNTY_NO, '' AS NoOfNames, '' AS PassThroughCharge, K.Amount, K.Description 
			FROM #tmpChargesForAllDeliveryMethods AS K 
			WHERE K.Tapno IS NULL 
			  AND k.deliverymethod != 'WEB SERVICE' 
		 ) Z
	ORDER BY  Z.apno 

	-- Main Query go generate the billing.
	INSERT INTO dbo.InvDetail (APNO, [Type], Subkey, SubkeyChar, Billed, InvoiceNumber, CreateDate, Description, Amount)
	SELECT DISTINCT Q.APNO, 2 AS [Type], Q.CNTY_NO AS [SubKey], CASE WHEN Q.NoOfNames = 0 THEN 1 ELSE Q.NoOfNames END AS [SubKeyChar], 
					0 AS Billed, NULL AS [InvoiceNumber], CURRENT_TIMESTAMP AS [CreateDate], Q.[Description], Q.Amount			
	FROM #tmpInvDetail AS Q 
	ORDER BY Q.APNO, Q.CNTY_NO

	--SELECT * FROM #tmpInvDetail T ORDER BY T.APNO, T.CNTY_NO

	DROP TABLE #tmpReportable
	DROP TABLE #tmpNotReportableButHasAliases
	DROP TABLE #tmpReportableAndNotReportableCrims
	DROP TABLE #tmpChargesForAllDeliveryMethods
	DROP TABLE #tmpCrimsSentToVendor
	DROP TABLE #tmpCrims
	--DROP TABLE #tmpWebServiceCrims
	DROP TABLE #tmpWebServiceCharges
	DROP TABLE #tmpInvDetail
	DROP TABLE #tmpSpecialCounties

	-- Add package surcharges
	EXEC Billing_PackageSurcharge 1,null,NULL


SET NOCOUNT OFF
SET TRANSACTION ISOLATION LEVEL READ COMMITTED
