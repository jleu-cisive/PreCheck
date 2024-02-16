-- Alter Procedure LoadParallelBillingDataForOrigCompDate

--	exec LoadParallelBillingDataForOrigCompDate 9

CREATE PROCEDURE [dbo].[LoadParallelBillingDataForOrigCompDate]
	@NumberOfDays INT
AS

--CLNO 3468 is used for bad APNOs should not go to the billing
-- 2135,3079 are used for testing
--SELECT APPS TO BE BILLED
SELECT APNO, CLNO, PackageID
INTO #SelectAPNOsForBIlling
FROM Appl (NOLOCK)
WHERE CLNO NOT IN (3468) AND OrigCompDate > DATEADD(dd, -@NumberOfDays, GETDATE()) --AND ApStatus='F' 
AND PackageID IS NOT NULL;

;WITH cte_GetPackagePrice AS --GET PACKAGE RATES FOR EACH APP
(
    SELECT a.*, coalesce(cp.Rate,pm.DefaultPrice) AS PackageRate 
    FROM #SelectAPNOsForBIlling AS a WITH(NOLOCK)
    LEFT JOIN (
		SELECT CLNO, 
			PackageID, 
			Max(Rate) as Rate
		FROM ClientPackages (NOLOCK)
		GROUP BY CLNO, PackageID
    ) AS cp ON cp.PackageID = a.PackageID AND cp.CLNO = a.CLNO
    LEFT JOIN PackageMain pm WITH(NOLOCK) ON pm.PackageID = a.PackageID
),
cte_ResolveDupicatePackageConfigs As -- RESOLVE DUPLICATED PACKAGE QUANTITIES CONFIGURATION
(
    SELECT PackageID, ServiceType, MAX(IncludedCount) AS IncludedCount FROM PackageService (NOLOCK) GROUP BY PackageID, ServiceType
),
cte_GetPackageConfig AS -- GET PACKAGE QUANTITIES FOR EACH TYPE OF COMPONENT
(
    SELECT a.*, 
		pEmpl.IncludedCount AS PackageEmploymentQuantity,
		pEduc.IncludedCount AS PackageEducationQuantity,
		pCrim.IncludedCount AS PackageCrimQuantity,
		pCred.IncludedCount AS PackageCreditQuantity,
		pDl.IncludedCount AS PackageDLQuantity,
		pProf.IncludedCount AS PackageProfLicQuantity,
		pPers.IncludedCount AS PackagePersRefQuantity,
		pSoc.IncludedCount  AS PackageSocQuantity
    FROM cte_GetPackagePrice a WITH (NOLOCK)
        LEFT JOIN cte_ResolveDupicatePackageConfigs AS pEmpl WITH (NOLOCK) ON pEmpl.PackageID = a.PackageID AND pEmpl.ServiceType = 4
        LEFT JOIN cte_ResolveDupicatePackageConfigs AS pEduc WITH (NOLOCK) ON pEduc.PackageID = a.PackageID AND pEduc.ServiceType = 5
        LEFT JOIN cte_ResolveDupicatePackageConfigs AS pCrim WITH (NOLOCK) ON pCrim.PackageID = a.PackageID AND pCrim.ServiceType = 0
        LEFT JOIN cte_ResolveDupicatePackageConfigs AS pCred WITH (NOLOCK) ON pCred.PackageID = a.PackageID AND pCred.ServiceType = 2
        LEFT JOIN cte_ResolveDupicatePackageConfigs AS pDl WITH (NOLOCK) ON pDl.PackageID = a.PackageID AND pDl.ServiceType = 3
        LEFT JOIN cte_ResolveDupicatePackageConfigs AS pProf WITH (NOLOCK) ON pProf.PackageID = a.PackageID AND pProf.ServiceType = 6
        LEFT JOIN cte_ResolveDupicatePackageConfigs AS pPers WITH (NOLOCK) ON pPers.PackageID = a.PackageID AND pPers.ServiceType = 7
        LEFT JOIN cte_ResolveDupicatePackageConfigs AS pSoc WITH  (NOLOCK) ON pSoc.PackageID  = a.PackageID AND pSoc.ServiceType = 8
),
cte_GetClientConfigurations AS -- GET CLIENT CONFIGURATIONS
(
    SELECT
        a.*,
        c.OneCountyPricing,
        c.OneCountyPrice,
        ISNULL(ccb.ComboEmplPersRefCount, 0) AS ComboEmplPersRefCount,
        case when c.ClientTypeID = 14 then cast(1 as bit) else ISNULL(ccb.ZeroAdditionalItems, 0) end as ZeroAdditionalItems,
        case when c.ClientTypeID = 14 then cast(1 as bit) else ccb.LockPackagePricing end as LockPackagePricing,
        CASE WHEN ISNULL(ccPassT.Value, 'FALSE') = 'TRUE' THEN 1 
        ELSE 0 
        END  AS RemovePassThruCharges
    FROM cte_GetPackageConfig as a
		left join (
			select a.APNO, COALESCE(ch.ParentCLNO, a.CLNO) as CLNO from cte_GetPackageConfig as a with (nolock)
			left join ClientHierarchyByService as ch with (nolock) on ch.CLNO = a.CLNO AND ch.refHierarchyServiceID = 3
			) as z on a.APNO = z.APNO
		left join ClientConfig_Billing as ccb with (nolock)on ccb.CLNO = z.CLNO
		LEFT JOIN ClientConfiguration (NOLOCK) ccPassT ON ccPassT.CLNO = a.CLNO AND ccPassT.ConfigurationKey='RemovePassThruCharges'
		inner join Client as c with(nolock) on c.CLNO = z.CLNO
),
cte_GetClientRates AS --GET SPECIAL RATES FOR THE CLIENT 
(
    SELECT 
        a.*, 
        crEmpl.Rate AS ClientEmploymentRate,
        crEdu.Rate AS ClientEducationRate,
        crProf.Rate AS ClientProfLicRate,
        crPers.Rate AS ClientPersRefRate,
        crdl.Rate AS ClientDlRate,
        crCred.Rate AS ClientCredRate,
        crSoc.Rate AS ClientSocRate
    FROM cte_GetClientConfigurations AS a
		LEFT JOIN ClientRates (NOLOCK) crEmpl on crEmpl.CLNO = a.CLNO AND crEmpl.RateType = 'EMPL' --Get Employment Rate
		LEFT JOIN ClientRates (NOLOCK) crEdu  ON  crEdu.CLNO = a.CLNO AND crEdu.RateType  = 'EDUC' --Get Education Rate
		LEFT JOIN ClientRates (NOLOCK) crProf ON crProf.CLNO = a.CLNO AND crProf.RateType = 'PROF' --Get Professional Licences Rate
		LEFT JOIN ClientRates (NOLOCK) crPers ON crPers.CLNO = a.CLNO AND crPers.RateType = 'PERS' --Get Personal References Rate
		LEFT JOIN ClientRates (NOLOCK) crDL   ON crDL.CLNO   = a.CLNO AND crDL.RateType   = 'DL'   --Get DLs Rate
		LEFT JOIN ClientRates (NOLOCK) crCred ON crCred.CLNO = a.CLNO AND crCred.RateType = 'CRED' --Get Credit Rate
		LEFT JOIN ClientRates (NOLOCK) crSoc ON crSoc.CLNO = a.CLNO AND crSoc.RateType = 'SOC' --Get Social Security Rate
),
cte_AllApps AS -- ALL APPS WITH CONFIGURATION 
(
    SELECT * FROM cte_GetClientRates WITH (NOLOCK)
)
SELECT * INTO #Apps FROM cte_AllApps  WITH (NOLOCK);

WITH cte_GetEmploymentRecords AS --GET ALL EMPLOYMENT RECORDS FOR THE SELECTED APPS
(
	SELECT a.*, 
		e.EmplID AS SubKey,
		CONVERT(NVARCHAR(2), NULL) AS SubKeyChar, 
		'EMPLOYMENT: ' + e.Employer AS FeeDesc, 
		COALESCE(a.ClientEmploymentRate, (SELECT DefaultRate FROM DefaultRates WHERE RateType = 'EMPL')) AS Price,  
		'EMPL' AS RecordType,
		ROW_NUMBER() OVER (PARTITION BY a.APNO ORDER BY e.EmplID) AS RowNumber
    FROM #Apps AS a WITH (NOLOCK)
		INNER JOIN Empl (NOLOCK) AS e ON e.Apno = a.APNO --Get Employment Records
    WHERE e.IsOnReport = 1 AND e.IsHidden = 0
),
cte_CalculateEmploymentRecordsPrice AS --DEFINE EMPLOYMENT RECORD PRICE BASED ON PACKAGE CONFIG
(
	SELECT *, IIF(RowNumber <= PackageEmploymentQuantity, 0, Price) AS FinalPrice FROM cte_GetEmploymentRecords WITH (NOLOCK)
)

SELECT * INTO #EmploymentRecords FROM cte_CalculateEmploymentRecordsPrice WITH (NOLOCK);

WITH cte_GetEducationRecords AS --GET EDUCATION COMPONENTS FOR THE SELECTED APPS
(
	SELECT a.*, 
		e.EducatID AS SubKey,
		CONVERT(NVARCHAR(2), NULL) AS SubKeyChar, 
		'EDUCATION: ' + e.School AS FeeDesc,
		coalesce(a.clientEducationRate, (Select DefaultRate From DefaultRates WHERE RateType = 'EDUC')) AS Price,  
		'EDUC' AS RecordType,
		ROW_NUMBER() OVER (PARTITION BY a.APNO ORDER BY e.EducatID) AS RowNumber
    FROM #Apps AS a WITH (NOLOCK)
		INNER JOIN Educat (NOLOCK) AS e ON e.APNO = a.APNO
    WHERE e.IsOnReport = 1 AND  e.IsHidden = 0
),
cte_CalculateEducationRecordsPrice AS -- DEFINE EDUCATION RECORD PRICE BASED ON PACKAGE CONFIGURATION
(
    SELECT *, IIF(RowNumber <= PackageEducationQuantity, 0, Price) AS FinalPrice FROM cte_GetEducationRecords WITH (NOLOCK)
)

SELECT * INTO #EducationRecords FROM cte_CalculateEducationRecordsPrice WITH (NOLOCK);

DECLARE @SexOffenderCounty INT = 2480;

WITH cte_GetCrimRecords AS --GET COUNTIES FOR THE SELECTED APPS
(
    SELECT DISTINCT 
        a.*,
        c.CNTY_NO 
    FROM #Apps AS a WITH (NOLOCK)
		INNER JOIN Crim AS c WITH (NOLOCK) ON c.APNO = a.APNO
    WHERE c.IsHidden = 0
),
cte_GetCrimRecordsRate As  --DEFINE COUNTY RATES BASED ON CLIENT CONFIG 
(
    SELECT 
        a.*,
        'Criminal Search: ' + ISNULL(c.A_County, '') + ', ' + ISNULL(c.State, '') + ', '+ ISNULL(c.Country, '') AS FeeDesc,
        IIF(a.CNTY_NO = @SexOffenderCounty, 0, IIF(cr.ExcludeFromRules = 1, cr.Rate, IIF(a.OneCountyPricing = 1, a.OneCountyPrice, COALESCE(cr.Rate, c.Crim_DefaultRate)))) AS Price,
        IIF(a.CNTY_NO = @SexOffenderCounty, 1, ISNULL(cr.ExcludeFromRules, 0)) AS ExcludeFromRules,
        'CRIM' AS RecordType
    FROM cte_GetCrimRecords AS a WITH (NOLOCK)
		INNER JOIN dbo.TblCounties AS c WITH (NOLOCK) ON c.CNTY_NO = a.CNTY_NO
		LEFT JOIN (select CLNO, CNTY_NO, MAX(CONVERT(INT, ExcludeFromRules)) ExcludeFromRules, MIN(Rate)Rate
					FROM ClientCrimRate WITH (NOLOCK) GROUP BY CLNO, CNTY_NO
		) AS cr ON cr.CLNO = a.CLNO AND cr.CNTY_NO = a.CNTY_NO
),
cte_CalculateExcludedCrimrecords AS 
(
	SELECT *, 0 AS RowNumber, 0.0 AS FinalPrice FROM cte_GetCrimRecordsRate WITH (NOLOCK) WHERE ExcludeFromRules = 1
),
cte_GetNotExcludedCrimRecords AS 
(
    SELECT *, ROW_NUMBER() OVER (PARTITION BY APNO ORDER BY Price) AS RowNumber FROM cte_GetCrimRecordsRate WITH (NOLOCK) WHERE ExcludeFromRules = 0
),
cte_CalculateNotExcludedCrimRecordsPrices AS
(
    SELECT *, IIF(RowNumber <= PackageCrimQuantity, 0, Price) AS FinalPrice FROM cte_GetNoTExcludedCrimRecords WITH (NOLOCK)
),
cte_CalculateCrimRecordsPrice AS
(
    SELECT a.*, z.CNTY_NO AS SubKey, CONVERT(NVARCHAR(2), NULL) AS SubKeyChar, z.FeeDesc, z.Price, z.RecordType, z.RowNumber, z.FinalPrice FROM #Apps AS a WITH (NOLOCK)
		INNER JOIN (
			SELECT * FROM cte_CalculateExcludedCrimrecords WITH (NOLOCK)
			UNION ALL
			SELECT * FROM cte_CalculateNotExcludedCrimRecordsPrices WITH (NOLOCK)
		) AS z on z.APNO = a.APNO
)

SELECT * INTO #CrimRecords FROM cte_CalculateCrimRecordsPrice WITH (NOLOCK);

WITH cte_GetProfLicRecords AS
(
    SELECT a.*,
        ProfLicID AS SubKey,
		CONVERT(NVARCHAR(2), NULL) AS SubKeyChar,
        'License: ' + p.Lic_Type AS FeeDesc,
        coalesce(a.ClientProfLicRate, (SELECT DefaultRate From DefaultRates WHERE RateType = 'PROF')) Price, 
        'PROF' AS RecordType,
        ROW_NUMBER() OVER (PARTITION BY a.APNO ORDER BY p.ProfLicID) AS RowNumber 
    FROM #Apps AS a WITH (NOLOCK)
		INNER JOIN ProfLic (NOLOCK) AS p ON p.Apno = a.APNO
    WHERE p.IsOnReport = 1 AND p.IsHidden = 0
),
cte_CalculateProfLicRecordsPrice AS
(
	SELECT *, IIF(RowNumber <= PackageProfLicQuantity, 0, Price) As FinalPrice FROM cte_GetProfLicRecords WITH (NOLOCK)
)

SELECT * INTO #ProfLicRecords FROM cte_CalculateProfLicRecordsPrice WITH (NOLOCK);

WITH cte_GetPersRefRecords AS
(
    SELECT a.*,
        p.PersRefID AS SubKey,
		CONVERT(NVARCHAR(2), NULL) AS SubKeyChar,
        'Personal Reference: ' + p.Name AS FeeDesc,
        coalesce(a.ClientPersRefRate, (SELECT DefaultRate From DefaultRates WHERE RateType = 'PERS')) Price,
        'PERS' AS RecordType,
        ROW_NUMBER() OVER (PARTITION BY a.APNO ORDER BY p.PersRefID) AS RowNUmber
    FROM #Apps AS a WITH (NOLOCK)
		INNER JOIN PersRef (NOLOCK) AS p ON p.APNO = a.APNO
    WHERE p.IsOnReport = 1 AND p.IsHidden = 0
),
cte_CalculatePersRefRecordsPrice AS
(
    SELECT *, IIF(RowNUmber <= PackagePersRefQuantity, 0, Price) AS FinalPrice FROM cte_GetPersRefRecords WITH (NOLOCK)
)

SELECT * INTO #PersRefRecords FROM cte_CalculatePersRefRecordsPrice WITH (NOLOCK);

WITH cte_GetDLRecords AS
(
    SELECT a.*,
        d.APNO AS SubKey,
		CONVERT(NVARCHAR(2), NULL) AS SubKeyChar,
        'MVR Report' AS FeeDesc,
        coalesce(a.ClientDlRate, (SELECT DefaultRate From DefaultRates WHERE RateType = 'DL')) Price,
        'DL' AS RecordType,
        ROW_NUMBER() OVER (PARTITION BY a.APNO ORDER BY d.APNO) AS RowNUmber
    FROM #Apps AS a WITH (NOLOCK)
		INNER JOIN DL (NOLOCK) AS d ON d.APNO = a.APNO
    WHERE d.IsHidden = 0
),
cte_CalculateDlRecordsPrice AS
(
    SELECT *, IIF(RowNUmber <= PackageDLQuantity, 0, Price) AS FinalPrice FROM cte_GetDLRecords WITH (NOLOCK)
)

SELECT * INTO #DLRecords FROM cte_CalculateDlRecordsPrice WITH (NOLOCK);

WITH cte_GetCredRecords AS
(              
    SELECT a.*,
        c.APNO AS SubKey,
		CONVERT(NVARCHAR(2), c.RepType) AS SubKeyChar,
        IIF(c.RepType = 'C' ,'Credit Report','Social Security Search') AS FeeDesc,
        IIF(c.RepType = 'C', coalesce(a.ClientCredRate, (SELECT DefaultRate From DefaultRates WHERE RateType = 'CRED')),
                                                                                        coalesce(a.ClientSocRate,(SELECT DefaultRate From DefaultRates WHERE RateType = 'SOC'))) AS Price,
        IIF(c.RepType = 'C', a.PackageCreditQuantity, a.PackageSocQuantity) AS Quantity,
        'CRED' AS RecordType,
        ROW_NUMBER() OVER (PARTITION BY a.APNO ORDER BY c.APNO) AS RowNUmber
    FROM #Apps AS a WITH (NOLOCK)
		INNER JOIN Credit (NOLOCK) c ON c.APNO = a.APNO
    WHERE c.IsHidden = 0
),
cte_CalculateCredRecordsPrice AS
(
	SELECT *, IIF(RowNUmber <= Quantity, 0, Price) AS FinalPrice FROM cte_GetCredRecords WITH (NOLOCK)
)

SELECT * INTO #CredRecords FROM cte_CalculateCredRecordsPrice WITH (NOLOCK);

ALTER TABLE #CredRecords DROP COLUMN Quantity;

WITH cte_AllStandardComponents AS
(
    SELECT * FROM #EmploymentRecords WITH (NOLOCK)
    UNION ALL
    SELECT * FROM #EducationRecords WITH (NOLOCK)
    UNION ALL
    SELECT * FROM #CrimRecords WITH (NOLOCK)
    UNION ALL
    SELECT * FROM #ProfLicRecords WITH (NOLOCK)
    UNION ALL
    SELECT * FROM #PersRefRecords WITH (NOLOCK)
    UNION ALL
    SELECT * FROM #DLRecords WITH (NOLOCK)
    UNION ALL
    SELECT * FROM #CredRecords WITH (NOLOCK)
)

SELECT * INTO #AllComponents FROM cte_AllStandardComponents WITH (NOLOCK);

	DECLARE @CountiesList varchar(1000);
	DECLARE @SpecialCounties TABLE(County INT NOT NULL);
	SELECT @CountiesList = Value FROM ClientConfiguration WHERE ConfigurationKey = 'CountiesExcludedFromAliasCourtFees'

	--SPECIAL CLIENTS WITH SPECIAL RULES FOR ALIAS BILLING (6,7,19,3860)
	INSERT INTO @SpecialCounties(County) 
	SELECT CAST(value AS INT) FROM dbo.fn_Split(@CountiesList, ',');


	With cte_Q1 AS
	(
		SELECT a.APNO, a.CLNO, aas.SectionKeyID, COUNT(aas.SectionKeyID) AS NumOfNames 
		FROM #Apps AS a WITH (NOLOCK)
		INNER JOIN ApplAlias (NOLOCK) aa ON aa.APNO = a.APNO
		INNER JOIN ApplAlias_Sections (NOLOCK) aas ON aas.ApplAliasID = aa.ApplAliasID
		WHERE aa.IsPublicRecordQualified = 1
			AND aa.IsActive = 1
			AND aas.ApplSectionID = 5
			AND aas.IsActive = 1
		GROUP BY a.APNO, a.CLNO, aas.SectionKeyID
	),
	cte_Q2 (APNO, CLNO, CNTY_NO, NumOfNames, VendorID, SearchesReturnedByVendor) AS
	(
		SELECT q.APNO, q.CLNO, c.CNTY_NO, q.NumOfNames, c.vendorid, COUNT(c.CrimID) AS SearchesReturnedByVendor
		FROM cte_Q1 AS q WITH (NOLOCK)
		INNER JOIN Crim (NOLOCK) c ON c.CrimID = q.SectionKeyID
		WHERE c.IsHidden = 0
		GROUP BY q.APNO, q.CLNO, c.CNTY_NO, q.NumOfNames, c.vendorid
	),
	cte_Q3 AS
	(
		SELECT
			q.APNO,
			q.CLNO,
			q.CNTY_NO,
			MIN(c.A_County) + ', ' + MIN(c.State) + ' Court Access Fee' as FeeDesc,
			CASE WHEN q.VendorID = 5905088 THEN 1 ELSE q.NumOfNames END AS NumOfNames,
			c.PassThroughCharge,
			ISNULL(Max(CASE WHEN q.VendorID = 5905088 THEN 1 ELSE q.NumOfNames END ), 1) *  MIN(c.PassThroughCharge) as Amount,
			MIN(q.SearchesReturnedByVendor) AS SearchesReturnedByVendor,
			'Reportable Alias' AS AliasType
		FROM cte_Q2 AS q 
			INNER JOIN Counties (NOLOCK) AS c ON q.CNTY_NO = c.CNTY_NO 
		WHERE c.CNTY_NO NOT IN (SELECT County FROM @SpecialCounties)
			AND c.PassThroughCharge > 0
		GROUP BY q.APNO, q.CLNO, q.CNTY_NO, q.NumOfNames,c.PassThroughCharge, q.VendorID
	)

	SELECT * INTO #ReportableAliases FROM cte_Q3 WITH (NOLOCK); 

	WITH cte_P1 AS
	(
		SELECT a.APNO, a.CLNO, c.CNTY_NO, COUNT(aas.SectionKeyID) AS NumOfNames
		FROM #Apps AS a WITH (NOLOCK)
			INNER JOIN Crim (NOLOCK) AS c ON c.APNO = a.APNO
			INNER JOIN ApplAlias_Sections (NOLOCK) AS aas ON aas.SectionKeyID = c.CrimID
		WHERE
			aas.ApplSectionID = 5
			AND aas.IsActive = 1
			AND c.batchnumber IS NOT NULL
			AND c.status IS NOT NULL
			AND (c.Ordered IS NOT NULL OR C.IrisOrdered IS NOT NULL)
			AND c.IsHidden = 1
		GROUP BY a.APNO, a.CLNO,c.CNTY_NO, aas.SectionKeyID
	),
	cte_P2 AS
	(
		SELECT 
			p.APNO,p.CLNO, 
			p.CNTY_NO, 
			COUNT(c.CrimID) SearchesReturnedByVendor, 
			MIN(p.NumOfNames) AS NumOfNames, 
			c.vendorid AS VendorID
		FROM Crim (NOLOCK) AS c
		INNER JOIN cte_P1 AS p WITH (NOLOCK) ON p.APNO = c.APNO AND p.CNTY_NO = c.CNTY_NO
		WHERE c.Clear IN ('T', 'F')
		GROUP BY p.APNO, p.CLNO, p.CNTY_NO, c.vendorid
		HAVING COUNT(c.CrimID) > 1
	),
	cte_P3 AS
	(
		SELECT 
			p.APNO,
			p.CLNO,
			c.CNTY_NO,
			MIN (c.A_County) + ', ' + MIN (c.State) + ' Court Access Fee' AS FeeDesc,
			CASE WHEN p.VendorID = 5905088 THEN 1 ELSE p.NumOfNames END AS NumOfNames,
			c.PassThroughCharge, 
			ISNULL (MAX (CASE WHEN p.VendorID = 5905088 THEN 1 ELSE p.NumOfNames END), 1) * MIN (c.PassThroughCharge) Amount,
			MIN (p.SearchesReturnedByVendor) AS SearchesReturnedByVendor,
			'NonReportable Alias' AS AliasType
		FROM Counties (NOLOCK) AS c
			INNER JOIN cte_P2 AS p WITH (NOLOCK) ON p.CNTY_NO = c.CNTY_NO
		WHERE c.CNTY_NO NOT IN (SELECT County FROM @SpecialCounties)
			AND c.PassThroughCharge > 0
		GROUP BY p.APNO, p.CLNO, c.CNTY_NO, p.NumOfNames, c.PassThroughCharge, p.VendorID
	)

	SELECT * INTO #NonReportableAliases FROM cte_P3 WITH (NOLOCK);

	WITH cte_ChargesForAllDeliveryMethods AS
	(
		SELECT a.APNO,
			a.CLNO,
			c.CrimID, 
			c.CNTY_NO,
			cn.PassThroughCharge,
			cn.A_County + ', ' + cn.State + ' Court Access Fee' AS FeeDesc, 
			cn.PassThroughCharge AS Amount,
			c.deliverymethod as DeliveryMethod,
			c.vendorid,
			'Other Crim Records' AS AliasType
		FROM #Apps AS a WITH (NOLOCK)
		INNER JOIN Crim (NOLOCK) AS c ON a.APNO = c.APNO
		INNER JOIN Counties (NOLOCK) AS cn ON cn.CNTY_NO = c.CNTY_NO
		LEFT JOIN (
			SELECT APNO, CNTY_NO FROM #ReportableAliases WITH (NOLOCK)
			UNION ALL
			SELECT APNO, CNTY_NO FROM #NonReportableAliases WITH (NOLOCK)
		) AS z ON z.CNTY_NO = c.CNTY_NO AND z.APNO = a.APNO
		WHERE z.APNO IS NULL AND z.CNTY_NO IS NULL
		AND cn.PassThroughCharge > 0
		AND c.IsHidden = 0
		AND c.Clear IN ('T', 'F')
		AND (c.Ordered IS NOT NULL OR c.IrisOrdered IS NOT NULL)
	)

	SELECT * INTO #AliasesWithNoEntriesInApplAliasSections FROM cte_ChargesForAllDeliveryMethods WITH (NOLOCK); 
	
	WITH cte_W1 AS
	(
	SELECT * FROM #AliasesWithNoEntriesInApplAliasSections WITH (NOLOCK) WHERE DeliveryMethod = 'WEB SERVICE'
	),
	cte_W2 AS 
	(
		SELECT 
			a.APNO, A.CLNO, C.CNTY_NO, A.FeeDesc, a.PassThroughCharge, a.vendorid as VendorID,
			MAX(ISNULL(CONVERT(INT, c.txtalias), 0)) AS Alias1,
			MAX(ISNULL(CONVERT(INT, c.txtalias2), 0)) AS Alias2,
			MAX(ISNULL(CONVERT(INT, c.txtalias3), 0)) AS Alias3,
			MAX(ISNULL(CONVERT(INT, c.txtalias4), 0)) AS Alias4,
			MAX(ISNULL(CONVERT(INT, c.txtlast), 0)) AS Alias5
		FROM cte_W1 AS a WITH (NOLOCK)
			INNER JOIN Crim (NOLOCK) AS c ON c.APNO = a.APNO AND c.CrimID = a.CrimID
		GROUP BY a.APNO, a.CLNO, c.CNTY_NO, a.FeeDesc, a.PassThroughCharge, a.vendorid
	), 
	cte_W3 AS
	(
		SELECT *,
			Alias1 + Alias2 + Alias3 + Alias4 + Alias5 AS NUmOfnames
		FROM cte_W2 WITH (NOLOCK)
	),
	cte_W4 AS
	(
		SELECT 
			APNO,
			CLNO,
			CNTY_NO,
			FeeDesc,
			PassThroughCharge,
			NumOfNames,
			IIF(CNTY_NO IN (SELECT County FROM @SpecialCounties) OR VendorID = 5905088 ,1, NumOfNames) * PassThroughCharge AS Amount,
		'WEB SERVICE ALIAS' AS AliasType 
		FROM cte_W3 WITH (NOLOCK)
	)
	
	SELECT * INTO #AliasesFromWebServices FROM cte_W4 WITH (NOLOCK);

	WITH cte_CalculateAllAliasPrice AS
	(
		SELECT a.*,
			z.CNTY_NO AS SubKey,
			CONVERT(NVARCHAR(2), z.NumOfNames) AS SubKeyChar,
			z.FeeDesc,			
			z.Amount AS Price,
			'ALIAS' AS RecordType,
			ROW_NUMBER() OVER (PARTITION BY a.APNO ORDER BY z.Amount) AS RowNumber,
			IIF(a.RemovePassThruCharges = 1, 0, Amount) AS FinalPrice
		FROM #Apps AS a WITH (NOLOCK)
			INNER JOIN (
				SELECT DISTINCT APNO, CNTY_NO, FeeDesc, PassThroughCharge, NumOfNames, Amount, 'ReportableAndNonRepportableAliases' AliasType
				FROM (
					SELECT APNO, CNTY_NO, FeeDesc, PassThroughCharge, NumOfNames, Amount, AliasType FROM #ReportableAliases WITH (NOLOCK)
					UNION ALL
					SELECT APNO, CNTY_NO, FeeDesc, PassThroughCharge, NumOfNames, Amount, AliasType FROM #NonReportableAliases WITH (NOLOCK)
				) AS a
				UNION ALL
				SELECT DISTINCT APNO, CNTY_NO, FeeDesc, PassThroughCharge, 1 AS NumOfNames, Amount, AliasType FROM #AliasesWithNoEntriesInApplAliasSections WITH (NOLOCK)
				WHERE DeliveryMethod != 'WEB SERVICE'
				UNION ALL
				SELECT APNO, CNTY_NO, FeeDesc, PassThroughCharge, NumOfNames, Amount, AliasType FROM #AliasesFromWebServices WITH (NOLOCK)
			) AS z ON z.APNO = a.APNO
	) 

SELECT * INTO #AllALiases FROM cte_CalculateAllAliasPrice WITH (NOLOCK);

WITH cte_Result AS 
(
    SELECT * FROM #AllComponents WITH (NOLOCK)
    UNION ALL
    SELECT * FROM #AllALiases WITH (NOLOCK)
)

SELECT APNO, CLNO, PackageID, PackageRate, SubKey, SubKeyChar, FeeDesc, FinalPrice AS Price, RecordType, RowNumber 
INTO #Result
FROM cte_Result WITH (NOLOCK);

WITH cte_PackagesForInvDetail AS (
	SELECT a.APNO, a.CLNO, a.PackageID, P.PackageDesc, a.PackageRate FROM #Apps AS a WITH (NOLOCK)
	INNER JOIN PackageMain (NOLOCK) p ON p.PackageID = a.PackageID
)

SELECT APNO, CLNO, 0 AS ServiceType, convert(int, PackageID) AS SubKey, CONVERT(NVARCHAR, NULL) AS SubKeyChar, GETDATE() AS CreateDate, 'PACKAGE: ' + PackageDesc AS FeeDescription , PackageRate AS Amount 
INTO #InvDetails
FROM cte_PackagesForInvDetail WITH (NOLOCK);

WITH cte_ManualEntries AS
(
    SELECT a.APNO, a.CLNO,i.InvDetID AS SubKey, i.SubKeyChar,i.CreateDate,i.Description,i.Amount,i.Type FROM #SelectAPNOsForBIlling AS a
    INNER JOIN InvDetail (NOLOCK) AS i ON i.APNO = a.APNO AND i.Type = 1 
)

INSERT INTO #InvDetails (APNO,CLNO, ServiceType, SubKey, SubKeyChar, CreateDate,FeeDescription,Amount)
SELECT APNO, CLNO, Type, SubKey, SubKeyChar, CreateDate, Description, Amount FROM cte_ManualEntries WITH (NOLOCK);

INSERT INTO #InvDetails (APNO, CLNO, ServiceType, SubKey, SubKeyChar, CreateDate, FeeDescription, Amount)
SELECT 
    APNO,
    CLNO,
    CASE WHEN RecordType = 'EMPL' THEN 6
		WHEN RecordType = 'EDUC' THEN 7
		WHEN RecordType = 'CRIM' THEN 2
		WHEN RecordType = 'CRED' THEN 4
		WHEN RecordType = 'DL' THEN 5
		WHEN RecordType = 'PROF' THEN 8
		WHEN RecordType = 'PERS' THEN 9
		WHEN RecordType = 'ALIAS' THEN 2
		END ServiceType,
	SubKey,
	SubKeyChar,
    GETDATE(),
    FeeDesc,
    Price
FROM #Result WITH (NOLOCK);

DECLARE @SummaryOfChanges TABLE(Change VARCHAR(20)); 
;WITH cteTarget AS
(
    SELECT tpb.APNO, tpb.CLNO, tpb.ServiceType, tpb.SubKey, tpb.SubKeyChar, tpb.CreateDate, tpb.LastUpdateDate, tpb.FeeDescription, tpb.Amount, tpb.IsDeleted 
    FROM InvDetailsParallel_orgcompdate tpb 
    INNER JOIN #SelectAPNOsForBIlling app on app.APNO = tpb.APNO
)
MERGE cteTarget as target
USING(SELECT APNO, CLNO, ServiceType, SubKey, SubKeyChar, FeeDescription, Amount FROM #InvDetails) AS source (APNO, CLNO, ServiceType, SubKey, SubKeyChar, FeeDescription, Amount)
ON target.APNO = source.APNO and target.CLNO = source.CLNO and target.ServiceType = source.ServiceType and target.SubKey = source.SubKey AND ISNULL(target.SubKeyChar, CONVERT(nvarchar,-1)) = ISNULL(source.SubKeyChar, CONVERT(nvarchar,-1))
WHEN NOT MATCHED BY TARGET THEN
    INSERT (APNO, CLNO, ServiceType, SubKey, SubKeyChar, CreateDate, LastUpdateDate, FeeDescription, Amount)
    VALUES (source.APNO, source.CLNO, source.ServiceType, source.SubKey, source.SubKeyChar, GETDATE(),NULL, source.FeeDescription, source.Amount)
WHEN NOT MATCHED BY SOURCE THEN
    UPDATE SET target.IsDeleted = 1, target.LastUpdateDate = GETDATE()
WHEN MATCHED AND (source.FeeDescription <> target.FeeDescription OR source.Amount <> target.Amount) THEN
                UPDATE SET
                target.FeeDescription = source.FeeDescription,
                target.Amount = source.Amount,
                target.LastUpdateDate = GETDATE()
OUTPUT $action INTO @SummaryOfChanges;
SELECT Change, COUNT(*) AS CountPerChange  
FROM @SummaryOfChanges  
GROUP BY Change;

DROP TABLE #SelectAPNOsForBIlling
DROP TABLE #Apps
DROP TABLE #EmploymentRecords
DROP TABLE #EducationRecords
DROP TABLE #CrimRecords
DROP TABLE #ProfLicRecords
DROP TABLE #PersRefRecords
DROP TABLE #DLRecords
DROP TABLE #CredRecords
DROP TABLE #AllComponents
DROP TABLE #ReportableAliases
DROP TABLE #NonReportableAliases
DROP TABLE #AliasesFromWebServices
DROP TABLE #AliasesWithNoEntriesInApplAliasSections
DROP TABLE #AllALiases
DROP TABLE #Result
DROP TABLE #InvDetails
