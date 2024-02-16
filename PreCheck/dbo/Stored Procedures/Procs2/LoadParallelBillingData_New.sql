
-- =============================================
-- Author:		Yves Fernandes
-- Create date: 03/01/2019
-- Description:	Used in Parallel PowerBi Dashboard
-- Modified by Andrew Seybolt to fix the allocation memory issue on 08/11/2021
-- EXEC LoadParallelBillingData @NumberOfDays = 1
-- =============================================

CREATE PROCEDURE [dbo].[LoadParallelBillingData_New]
	@NumberOfDays INT
AS

--Declare @NumberOfDays INT = 5
DECLARE @SexOffenderCounty INT = 2480;
DECLARE @CountiesList varchar(1000);

drop table if exists #SpecialCounties
Create TABLE #SpecialCounties (County INT NOT NULL);

--CLNO 3468 is used for bad APNOs should not go to the billing
--SELECT APPS TO BE BILLED

drop table if exists #SelectAPNOsForBIlling

SELECT APNO, CLNO, PackageID
INTO #SelectAPNOsForBIlling
FROM Appl (NOLOCK)
WHERE CLNO NOT IN (3468,2135,3079) AND OrigCompDate > DATEADD(dd, - @NumberOfDays, GETDATE()) 
--CompDate > DATEADD(dd, -@NumberOfDays, GETDATE()) --Radhika Dereddy commented on 02/20/2020
--AND ApStatus='F' 
AND PackageID IS NOT NULL;

--GET PACKAGE RATES FOR EACH APP

DROP TABLE IF EXISTS #GetPackagePrice

 SELECT a.*, coalesce(cp.Rate,pm.DefaultPrice) AS PackageRate 
	into #GetPackagePrice
    FROM #SelectAPNOsForBIlling AS a 
    LEFT JOIN (
		SELECT CLNO, 
			PackageID, 
			Max(Rate) as Rate
		FROM ClientPackages (NOLOCK)
		GROUP BY CLNO, PackageID
    ) AS cp ON cp.PackageID = a.PackageID AND cp.CLNO = a.CLNO
    LEFT JOIN PackageMain pm WITH(NOLOCK) ON pm.PackageID = a.PackageID

 -- RESOLVE DUPLICATED PACKAGE QUANTITIES CONFIGURATION

DROP TABLE IF EXISTS #ResolveDupicatePackageConfigs

SELECT PackageID, ServiceType, MAX(IncludedCount) AS IncludedCount 
into #ResolveDupicatePackageConfigs
FROM PackageService (NOLOCK) GROUP BY PackageID, ServiceType


-- GET PACKAGE QUANTITIES FOR EACH TYPE OF COMPONENT

DROP TABLE IF EXISTS #GetPackageConfig

SELECT a.*, 
		pEmpl.IncludedCount AS PackageEmploymentQuantity,
		pEduc.IncludedCount AS PackageEducationQuantity,
		pCrim.IncludedCount AS PackageCrimQuantity,
		pCred.IncludedCount AS PackageCreditQuantity,
		pDl.IncludedCount AS PackageDLQuantity,
		pProf.IncludedCount AS PackageProfLicQuantity,
		pPers.IncludedCount AS PackagePersRefQuantity,
		pSoc.IncludedCount  AS PackageSocQuantity
	INTO #GetPackageConfig
    FROM #GetPackagePrice a 
        LEFT JOIN #ResolveDupicatePackageConfigs AS pEmpl  ON pEmpl.PackageID = a.PackageID AND pEmpl.ServiceType = 4
        LEFT JOIN #ResolveDupicatePackageConfigs AS pEduc  ON pEduc.PackageID = a.PackageID AND pEduc.ServiceType = 5
        LEFT JOIN #ResolveDupicatePackageConfigs AS pCrim  ON pCrim.PackageID = a.PackageID AND pCrim.ServiceType = 0
        LEFT JOIN #ResolveDupicatePackageConfigs AS pCred  ON pCred.PackageID = a.PackageID AND pCred.ServiceType = 2
        LEFT JOIN #ResolveDupicatePackageConfigs AS pDl  ON pDl.PackageID = a.PackageID AND pDl.ServiceType = 3
        LEFT JOIN #ResolveDupicatePackageConfigs AS pProf  ON pProf.PackageID = a.PackageID AND pProf.ServiceType = 6
        LEFT JOIN #ResolveDupicatePackageConfigs AS pPers  ON pPers.PackageID = a.PackageID AND pPers.ServiceType = 7
        LEFT JOIN #ResolveDupicatePackageConfigs AS pSoc  ON pSoc.PackageID  = a.PackageID AND pSoc.ServiceType = 8

-- GET CLIENT CONFIGURATIONS

DROP TABLE IF EXISTS #GetClientConfigurations 

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
	into #GetClientConfigurations
    FROM #GetPackageConfig as a
		left join (
			select a.APNO, COALESCE(ch.ParentCLNO, a.CLNO) as CLNO from #GetPackageConfig as a 
			left join ClientHierarchyByService as ch with (nolock) on ch.CLNO = a.CLNO AND ch.refHierarchyServiceID = 3
			) as z on a.APNO = z.APNO
		left join ClientConfig_Billing as ccb with (nolock)on ccb.CLNO = z.CLNO
		LEFT JOIN ClientConfiguration (NOLOCK) ccPassT ON ccPassT.CLNO = a.CLNO AND ccPassT.ConfigurationKey='RemovePassThruCharges'
		inner join Client as c with(nolock) on c.CLNO = z.CLNO

 --GET SPECIAL RATES FOR THE CLIENT 

DROP TABLE IF EXISTS #GetClientRates

SELECT 
        a.*, 
        crEmpl.Rate AS ClientEmploymentRate,
        crEdu.Rate AS ClientEducationRate,
        crProf.Rate AS ClientProfLicRate,
        crPers.Rate AS ClientPersRefRate,
        crdl.Rate AS ClientDlRate,
        crCred.Rate AS ClientCredRate,
        crSoc.Rate AS ClientSocRate
	into #GetClientRates
    FROM #GetClientConfigurations AS a
		LEFT JOIN ClientRates (NOLOCK) crEmpl on crEmpl.CLNO = a.CLNO AND crEmpl.RateType = 'EMPL' --Get Employment Rate
		LEFT JOIN ClientRates (NOLOCK) crEdu  ON  crEdu.CLNO = a.CLNO AND crEdu.RateType  = 'EDUC' --Get Education Rate
		LEFT JOIN ClientRates (NOLOCK) crProf ON crProf.CLNO = a.CLNO AND crProf.RateType = 'PROF' --Get Professional Licences Rate
		LEFT JOIN ClientRates (NOLOCK) crPers ON crPers.CLNO = a.CLNO AND crPers.RateType = 'PERS' --Get Personal References Rate
		LEFT JOIN ClientRates (NOLOCK) crDL   ON crDL.CLNO   = a.CLNO AND crDL.RateType   = 'DL'   --Get DLs Rate
		LEFT JOIN ClientRates (NOLOCK) crCred ON crCred.CLNO = a.CLNO AND crCred.RateType = 'CRED' --Get Credit Rate
		LEFT JOIN ClientRates (NOLOCK) crSoc ON crSoc.CLNO = a.CLNO AND crSoc.RateType = 'SOC' --Get Social Security Rate 

--GET ALL EMPLOYMENT RECORDS FOR THE SELECTED APPS

drop table if exists #AllApps

select *
into #Allapps
from #GetClientRates

drop table if exists #Apps

SELECT * INTO #Apps FROM #AllApps

drop table if exists #GetEmploymentRecords

SELECT a.*, 
		e.EmplID AS SubKey,
		CONVERT(NVARCHAR(2), NULL) AS SubKeyChar, 
		'EMPLOYMENT: ' + e.Employer AS FeeDesc, 
		COALESCE(a.ClientEmploymentRate, (SELECT DefaultRate FROM DefaultRates WHERE RateType = 'EMPL')) AS Price,  
		'EMPL' AS RecordType,
		ROW_NUMBER() OVER (PARTITION BY a.APNO ORDER BY e.EmplID) AS RowNumber
	into #GetEmploymentRecords
    FROM #Apps AS a 
		INNER JOIN Empl (NOLOCK) AS e ON e.Apno = a.APNO --Get Employment Records
    WHERE e.IsOnReport = 1 AND e.IsHidden = 0

 --DEFINE EMPLOYMENT RECORD PRICE BASED ON PACKAGE CONFIG

 drop table if exists #CalculateEmploymentRecordsPrice

SELECT *, IIF(RowNumber <= PackageEmploymentQuantity, 0, Price) AS FinalPrice
into #CalculateEmploymentRecordsPrice
FROM #GetEmploymentRecords 

drop table if exists #EmploymentRecords

SELECT * INTO #EmploymentRecords FROM #CalculateEmploymentRecordsPrice 

--GET EDUCATION COMPONENTS FOR THE SELECTED APPS

drop table if exists #GetEducationRecords

SELECT a.*, 
		e.EducatID AS SubKey,
		CONVERT(NVARCHAR(2), NULL) AS SubKeyChar, 
		'EDUCATION: ' + e.School AS FeeDesc,
		coalesce(a.clientEducationRate, (Select DefaultRate From DefaultRates WHERE RateType = 'EDUC')) AS Price,  
		'EDUC' AS RecordType,
		ROW_NUMBER() OVER (PARTITION BY a.APNO ORDER BY e.EducatID) AS RowNumber
	into #GetEducationRecords
    FROM #Apps AS a 
		INNER JOIN Educat (NOLOCK) AS e ON e.APNO = a.APNO
    WHERE e.IsOnReport = 1 AND  e.IsHidden = 0

-- DEFINE EDUCATION RECORD PRICE BASED ON PACKAGE CONFIGURATION

drop table if exists #CalculateEducationRecordsPrice

SELECT *, IIF(RowNumber <= PackageEducationQuantity, 0, Price) AS FinalPrice 
into #CalculateEducationRecordsPrice
FROM #GetEducationRecords 

drop table if exists #EducationRecords

SELECT * INTO #EducationRecords FROM #CalculateEducationRecordsPrice 

--GET COUNTIES FOR THE SELECTED APPS

drop table if exists #GetCrimRecords

SELECT DISTINCT 
        a.*,
        c.CNTY_NO 
	into #GetCrimRecords
    FROM #Apps AS a 
		INNER JOIN Crim AS c WITH (NOLOCK) ON c.APNO = a.APNO
    WHERE c.IsHidden = 0

 --DEFINE COUNTY RATES BASED ON CLIENT CONFIG 

drop table if exists #GetCrimRecordsRate

SELECT  a.*,
        'Criminal Search: ' + ISNULL(c.A_County, '') + ', ' + ISNULL(c.State, '') + ', '+ ISNULL(c.Country, '') AS FeeDesc,
        IIF(a.CNTY_NO = @SexOffenderCounty, 0, IIF(cr.ExcludeFromRules = 1, cr.Rate, IIF(a.OneCountyPricing = 1, a.OneCountyPrice, COALESCE(cr.Rate, c.Crim_DefaultRate)))) AS Price,
        IIF(a.CNTY_NO = @SexOffenderCounty, 1, ISNULL(cr.ExcludeFromRules, 0)) AS ExcludeFromRules,
        'CRIM' AS RecordType
	into #GetCrimRecordsRate
    FROM #GetCrimRecords AS a 
		INNER JOIN dbo.TblCounties AS c WITH (NOLOCK) ON c.CNTY_NO = a.CNTY_NO
		LEFT JOIN (select CLNO, CNTY_NO, MAX(CONVERT(INT, ExcludeFromRules)) ExcludeFromRules, MIN(Rate)Rate
					FROM ClientCrimRate WITH (NOLOCK) GROUP BY CLNO, CNTY_NO
		) AS cr ON cr.CLNO = a.CLNO AND cr.CNTY_NO = a.CNTY_NO

drop table if exists #CalculateExcludedCrimrecords

SELECT *, 0 AS RowNumber, 0.0 AS FinalPrice 
into #CalculateExcludedCrimrecords
FROM #GetCrimRecordsRate 
WHERE ExcludeFromRules = 1


drop table if exists #GetNotExcludedCrimRecords

SELECT *, ROW_NUMBER() OVER (PARTITION BY APNO ORDER BY Price) AS RowNumber 
into #GetNotExcludedCrimRecords
FROM #GetCrimRecordsRate 
WHERE ExcludeFromRules = 0


drop table if exists #CalculateNotExcludedCrimRecordsPrices

SELECT *, IIF(RowNumber <= PackageCrimQuantity, 0, Price) AS FinalPrice 
into #CalculateNotExcludedCrimRecordsPrices
FROM #GetNoTExcludedCrimRecords 


drop table if exists #CalculateCrimRecordsPrice

SELECT a.*, z.CNTY_NO AS SubKey, CONVERT(NVARCHAR(2), NULL) AS SubKeyChar, z.FeeDesc, z.Price, z.RecordType, z.RowNumber, z.FinalPrice 
into #CalculateCrimRecordsPrice
FROM #Apps AS a 
		INNER JOIN (
			SELECT * FROM #CalculateExcludedCrimrecords 
			UNION ALL
			SELECT * FROM #CalculateNotExcludedCrimRecordsPrices 
		) AS z on z.APNO = a.APNO

drop table if exists #CrimRecords

SELECT * INTO #CrimRecords FROM #CalculateCrimRecordsPrice 

drop table if exists #GetProfLicRecords

SELECT a.*,
        ProfLicID AS SubKey,
		CONVERT(NVARCHAR(2), NULL) AS SubKeyChar,
        'License: ' + p.Lic_Type AS FeeDesc,
        coalesce(a.ClientProfLicRate, (SELECT DefaultRate From DefaultRates WHERE RateType = 'PROF')) Price, 
        'PROF' AS RecordType,
        ROW_NUMBER() OVER (PARTITION BY a.APNO ORDER BY p.ProfLicID) AS RowNumber 
	into #GetProfLicRecords
    FROM #Apps AS a 
		INNER JOIN ProfLic (NOLOCK) AS p ON p.Apno = a.APNO
    WHERE p.IsOnReport = 1 AND p.IsHidden = 0

drop table if exists #CalculateProfLicRecordsPrice

SELECT *, IIF(RowNumber <= PackageProfLicQuantity, 0, Price) As FinalPrice 
into #CalculateProfLicRecordsPrice
FROM #GetProfLicRecords 

drop table if exists #ProfLicRecords

SELECT * INTO #ProfLicRecords 
FROM #CalculateProfLicRecordsPrice 

drop table if exists #GetPersRefRecords

SELECT a.*,
        p.PersRefID AS SubKey,
		CONVERT(NVARCHAR(2), NULL) AS SubKeyChar,
        'Personal Reference: ' + p.Name AS FeeDesc,
        coalesce(a.ClientPersRefRate, (SELECT DefaultRate From DefaultRates WHERE RateType = 'PERS')) Price,
        'PERS' AS RecordType,
        ROW_NUMBER() OVER (PARTITION BY a.APNO ORDER BY p.PersRefID) AS RowNUmber
	into #GetPersRefRecords
    FROM #Apps AS a 
		INNER JOIN PersRef (NOLOCK) AS p ON p.APNO = a.APNO
    WHERE p.IsOnReport = 1 AND p.IsHidden = 0

drop table if exists #CalculatePersRefRecordsPrice

SELECT *, IIF(RowNUmber <= PackagePersRefQuantity, 0, Price) AS FinalPrice 
into #CalculatePersRefRecordsPrice
FROM #GetPersRefRecords 

drop table if exists #PersRefRecords

SELECT * INTO #PersRefRecords 
FROM #CalculatePersRefRecordsPrice 

drop table if exists #GetDLRecords

SELECT a.*,
        d.APNO AS SubKey,
		CONVERT(NVARCHAR(2), NULL) AS SubKeyChar,
        'MVR Report' AS FeeDesc,
        coalesce(a.ClientDlRate, (SELECT DefaultRate From DefaultRates WHERE RateType = 'DL')) Price,
        'DL' AS RecordType,
        ROW_NUMBER() OVER (PARTITION BY a.APNO ORDER BY d.APNO) AS RowNUmber
	into #GetDLRecords
    FROM #Apps AS a 
		INNER JOIN DL (NOLOCK) AS d ON d.APNO = a.APNO
    WHERE d.IsHidden = 0

drop table if exists #CalculateDlRecordsPrice

SELECT *, IIF(RowNUmber <= PackageDLQuantity, 0, Price) AS FinalPrice 
into #CalculateDlRecordsPrice
FROM #GetDLRecords

DROP TABLE IF EXISTS #DLRecords

SELECT * INTO #DLRecords FROM #CalculateDlRecordsPrice 

drop table if exists #GetCredRecords

    SELECT a.*,
        c.APNO AS SubKey,
		CONVERT(NVARCHAR(2), c.RepType) AS SubKeyChar,
        IIF(c.RepType = 'C' ,'Credit Report','Social Security Search') AS FeeDesc,
        IIF(c.RepType = 'C', coalesce(a.ClientCredRate, (SELECT DefaultRate From DefaultRates WHERE RateType = 'CRED')),
                                                                                        coalesce(a.ClientSocRate,(SELECT DefaultRate From DefaultRates WHERE RateType = 'SOC'))) AS Price,
        IIF(c.RepType = 'C', a.PackageCreditQuantity, a.PackageSocQuantity) AS Quantity,
        'CRED' AS RecordType,
        ROW_NUMBER() OVER (PARTITION BY a.APNO ORDER BY c.APNO) AS RowNUmber
	into #GetCredRecords
    FROM #Apps AS a 
		INNER JOIN Credit (NOLOCK) c ON c.APNO = a.APNO
    WHERE c.IsHidden = 0

drop table if exists #CalculateCredRecordsPrice

	SELECT *, IIF(RowNUmber <= Quantity, 0, Price) AS FinalPrice 
	into #CalculateCredRecordsPrice
	FROM #GetCredRecords

drop table if exists #CredRecords

SELECT * INTO #CredRecords FROM #CalculateCredRecordsPrice

ALTER TABLE #CredRecords DROP COLUMN Quantity;

drop table if exists #AllComponents

    SELECT * 
	into #AllComponents
	FROM #EmploymentRecords 
    UNION ALL
    SELECT * FROM #EducationRecords 
    UNION ALL
    SELECT * FROM #CrimRecords 
    UNION ALL
    SELECT * FROM #ProfLicRecords 
    UNION ALL
    SELECT * FROM #PersRefRecords
    UNION ALL
    SELECT * FROM #DLRecords 
    UNION ALL
    SELECT * FROM #CredRecords 

	SELECT @CountiesList = Value FROM ClientConfiguration WHERE ConfigurationKey = 'CountiesExcludedFromAliasCourtFees'

	--SPECIAL CLIENTS WITH SPECIAL RULES FOR ALIAS BILLING (6,7,19,3860)
	INSERT INTO #SpecialCounties(County) 
	SELECT CAST(value AS INT) FROM dbo.fn_Split(@CountiesList, ',');


drop table if exists #Q1

		SELECT a.APNO, a.CLNO, aas.SectionKeyID, COUNT(aas.SectionKeyID) AS NumOfNames 
		into #Q1
		FROM #Apps AS a 
		INNER JOIN ApplAlias (NOLOCK) aa ON aa.APNO = a.APNO
		INNER JOIN ApplAlias_Sections (NOLOCK) aas ON aas.ApplAliasID = aa.ApplAliasID
		WHERE aa.IsPublicRecordQualified = 1
			AND aa.IsActive = 1
			AND aas.ApplSectionID = 5
			AND aas.IsActive = 1
		GROUP BY a.APNO, a.CLNO, aas.SectionKeyID

drop table if exists #Q2

		SELECT q.APNO, q.CLNO, c.CNTY_NO, q.NumOfNames, c.vendorid, COUNT(c.CrimID) AS SearchesReturnedByVendor
		into #Q2
		FROM #Q1 AS q 
		INNER JOIN Crim (NOLOCK) c ON c.CrimID = q.SectionKeyID
		WHERE c.IsHidden = 0
		GROUP BY q.APNO, q.CLNO, c.CNTY_NO, q.NumOfNames, c.vendorid

CREATE NONCLUSTERED INDEX [index]
ON #Q2 ([CNTY_NO])
INCLUDE ([APNO],[CLNO],[NumOfNames],[vendorid],[SearchesReturnedByVendor])

drop table if exists #Q3

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
		into #Q3
		FROM #Q2 AS q 
			INNER JOIN Counties (NOLOCK) AS c ON q.CNTY_NO = c.CNTY_NO 
		WHERE c.CNTY_NO NOT IN (SELECT County FROM #SpecialCounties)
			AND c.PassThroughCharge > 0
		GROUP BY q.APNO, q.CLNO, q.CNTY_NO, q.NumOfNames,c.PassThroughCharge, q.VendorID

drop table if exists #ReportableAliases

	SELECT * INTO #ReportableAliases FROM #Q3  

drop table if exists #P1
		SELECT a.APNO, a.CLNO, c.CNTY_NO, COUNT(aas.SectionKeyID) AS NumOfNames
		into #P1
		FROM #Apps AS a  
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

drop table if exists #P2

		SELECT 
			p.APNO,p.CLNO, 
			p.CNTY_NO, 
			COUNT(c.CrimID) SearchesReturnedByVendor, 
			MIN(p.NumOfNames) AS NumOfNames, 
			c.vendorid AS VendorID
		into #P2
		FROM Crim (NOLOCK) AS c
		INNER JOIN #P1 AS p  ON p.APNO = c.APNO AND p.CNTY_NO = c.CNTY_NO
		WHERE c.Clear IN ('T', 'F')
		GROUP BY p.APNO, p.CLNO, p.CNTY_NO, c.vendorid
		HAVING COUNT(c.CrimID) > 1

drop table if exists #P3

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
		into #P3
		FROM Counties (NOLOCK) AS c
			INNER JOIN #P2 AS p ON p.CNTY_NO = c.CNTY_NO
		WHERE c.CNTY_NO NOT IN (SELECT County FROM #SpecialCounties)
			AND c.PassThroughCharge > 0
		GROUP BY p.APNO, p.CLNO, c.CNTY_NO, p.NumOfNames, c.PassThroughCharge, p.VendorID

drop table if exists #NonReportableAliases

	SELECT * INTO #NonReportableAliases FROM #P3  

drop table if exists #ChargesForAllDeliveryMethods

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
		into #ChargesForAllDeliveryMethods
		FROM #Apps AS a  
		INNER JOIN Crim (NOLOCK) AS c ON a.APNO = c.APNO
		INNER JOIN Counties (NOLOCK) AS cn ON cn.CNTY_NO = c.CNTY_NO
		LEFT JOIN (
			SELECT APNO, CNTY_NO FROM #ReportableAliases  
			UNION ALL
			SELECT APNO, CNTY_NO FROM #NonReportableAliases  
		) AS z ON z.CNTY_NO = c.CNTY_NO AND z.APNO = a.APNO
		WHERE z.APNO IS NULL AND z.CNTY_NO IS NULL
		AND cn.PassThroughCharge > 0
		AND c.IsHidden = 0
		AND c.Clear IN ('T', 'F')
		AND (c.Ordered IS NOT NULL OR c.IrisOrdered IS NOT NULL)

drop table if exists #AliasesWithNoEntriesInApplAliasSections

	SELECT * INTO #AliasesWithNoEntriesInApplAliasSections FROM #ChargesForAllDeliveryMethods  
	
drop table if exists #W1

	SELECT * 
	into #W1
	FROM #AliasesWithNoEntriesInApplAliasSections  WHERE DeliveryMethod = 'WEB SERVICE'

drop table if exists #W2

		SELECT 
			a.APNO, A.CLNO, C.CNTY_NO, A.FeeDesc, a.PassThroughCharge, a.vendorid as VendorID,
			MAX(ISNULL(CONVERT(INT, c.txtalias), 0)) AS Alias1,
			MAX(ISNULL(CONVERT(INT, c.txtalias2), 0)) AS Alias2,
			MAX(ISNULL(CONVERT(INT, c.txtalias3), 0)) AS Alias3,
			MAX(ISNULL(CONVERT(INT, c.txtalias4), 0)) AS Alias4,
			MAX(ISNULL(CONVERT(INT, c.txtlast), 0)) AS Alias5
		into #W2
		FROM #W1 AS a 
			INNER JOIN Crim (NOLOCK) AS c ON c.APNO = a.APNO AND c.CrimID = a.CrimID
		GROUP BY a.APNO, a.CLNO, c.CNTY_NO, a.FeeDesc, a.PassThroughCharge, a.vendorid

drop table if exists #W3

		SELECT *,
			Alias1 + Alias2 + Alias3 + Alias4 + Alias5 AS NUmOfnames
		into #W3
		FROM #W2  

drop table if exists #W4 

		SELECT 
			APNO,
			CLNO,
			CNTY_NO,
			FeeDesc,
			PassThroughCharge,
			NumOfNames,
			IIF(CNTY_NO IN (SELECT County FROM #SpecialCounties) OR VendorID = 5905088 ,1, NumOfNames) * PassThroughCharge AS Amount,
		'WEB SERVICE ALIAS' AS AliasType 
		into #W4
		FROM #W3  

drop table if exists #AliasesFromWebServices
	
	SELECT * INTO #AliasesFromWebServices 
	FROM #W4  

drop table if exists #CalculateAllAliasPrice

		SELECT a.*,
			z.CNTY_NO AS SubKey,
			CONVERT(NVARCHAR(2), z.NumOfNames) AS SubKeyChar,
			z.FeeDesc,			
			z.Amount AS Price,
			'ALIAS' AS RecordType,
			ROW_NUMBER() OVER (PARTITION BY a.APNO ORDER BY z.Amount) AS RowNumber,
			IIF(a.RemovePassThruCharges = 1, 0, Amount) AS FinalPrice
		into #CalculateAllAliasPrice
		FROM #Apps AS a 
			INNER JOIN (
				SELECT DISTINCT APNO, CNTY_NO, FeeDesc, PassThroughCharge, NumOfNames, Amount, 'ReportableAndNonRepportableAliases' AliasType
				FROM (
					SELECT APNO, CNTY_NO, FeeDesc, PassThroughCharge, NumOfNames, Amount, AliasType FROM #ReportableAliases 
					UNION ALL
					SELECT APNO, CNTY_NO, FeeDesc, PassThroughCharge, NumOfNames, Amount, AliasType FROM #NonReportableAliases 
				) AS a
				UNION ALL
				SELECT DISTINCT APNO, CNTY_NO, FeeDesc, PassThroughCharge, 1 AS NumOfNames, Amount, AliasType FROM #AliasesWithNoEntriesInApplAliasSections  
				WHERE DeliveryMethod != 'WEB SERVICE'
				UNION ALL
				SELECT APNO, CNTY_NO, FeeDesc, PassThroughCharge, NumOfNames, Amount, AliasType FROM #AliasesFromWebServices 
			) AS z ON z.APNO = a.APNO

Drop table if exists #AllALiases

SELECT * INTO #AllALiases FROM #CalculateAllAliasPrice 

drop table if exists #Result

    SELECT * 
	into #Result
	FROM #AllComponents  
    UNION ALL
    SELECT * FROM #AllALiases  

drop table if exists #FinalResult

SELECT APNO, CLNO, PackageID, PackageRate, SubKey, SubKeyChar, FeeDesc, FinalPrice AS Price, RecordType, RowNumber 
INTO #FinalResult
FROM #Result 

drop table if exists #PackagesForInvDetail

	SELECT a.APNO, a.CLNO, a.PackageID, P.PackageDesc, a.PackageRate 
	into #PackagesForInvDetail
	FROM #Apps AS a 
	INNER JOIN PackageMain (NOLOCK) p ON p.PackageID = a.PackageID

drop table if exists #InvDetails

SELECT APNO, CLNO, 0 AS ServiceType, convert(int, PackageID) AS SubKey, CONVERT(NVARCHAR, NULL) AS SubKeyChar, GETDATE() AS CreateDate, 'PACKAGE: ' + PackageDesc AS FeeDescription , PackageRate AS Amount 
INTO #InvDetails
FROM #PackagesForInvDetail  

drop table if exists #ManualEntries

    SELECT a.APNO, a.CLNO,i.InvDetID AS SubKey, i.SubKeyChar,i.CreateDate,i.Description,i.Amount,i.Type 
	into #ManualEntries
	FROM #SelectAPNOsForBIlling AS a
    INNER JOIN InvDetail (NOLOCK) AS i ON i.APNO = a.APNO AND i.Type = 1 


INSERT INTO #InvDetails (APNO,CLNO, ServiceType, SubKey, SubKeyChar, CreateDate,FeeDescription,Amount)
SELECT APNO, CLNO, Type, SubKey, SubKeyChar, CreateDate, Description, Amount FROM #ManualEntries  

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
FROM #Result  

drop table if exists #Target

    SELECT tpb.APNO, tpb.CLNO, tpb.ServiceType, tpb.SubKey, tpb.SubKeyChar, tpb.CreateDate, tpb.LastUpdateDate, tpb.FeeDescription, tpb.Amount, ISNULL(tpb.IsDeleted, 0) as IsDeleted
	into #Target
    FROM InvDetailsParallel tpb 
    INNER JOIN #SelectAPNOsForBIlling app on app.APNO = tpb.APNO

	--SELECT distinct Isdeleted from #Target


drop table if exists #SummaryOfChanges
create table #SummaryOfChanges (Change VARCHAR(20)); 

MERGE #Target as target
USING (SELECT APNO, CLNO, ServiceType, SubKey, SubKeyChar, FeeDescription, Amount 
	FROM #InvDetails) AS source (APNO, CLNO, ServiceType, SubKey, SubKeyChar, FeeDescription, Amount)
	ON target.APNO = source.APNO and target.CLNO = source.CLNO and target.ServiceType = source.ServiceType and target.SubKey = source.SubKey AND ISNULL(target.SubKeyChar, CONVERT(nvarchar,-1)) = ISNULL(source.SubKeyChar, CONVERT(nvarchar,-1))
WHEN NOT MATCHED BY TARGET THEN
    INSERT (APNO, CLNO, ServiceType, SubKey, SubKeyChar, CreateDate, LastUpdateDate, FeeDescription, Amount, IsDeleted)
    VALUES (source.APNO, source.CLNO, source.ServiceType, source.SubKey, source.SubKeyChar, GETDATE(),NULL, source.FeeDescription, source.Amount, 0)
WHEN NOT MATCHED BY SOURCE THEN
    UPDATE SET target.IsDeleted = 1, target.LastUpdateDate = GETDATE()
WHEN MATCHED AND (source.FeeDescription <> target.FeeDescription OR source.Amount <> target.Amount) THEN
                UPDATE SET
                target.FeeDescription = source.FeeDescription,
                target.Amount = source.Amount,
                target.LastUpdateDate = GETDATE()
OUTPUT $action INTO #SummaryOfChanges;

SELECT Change, COUNT(*) AS CountPerChange  
FROM #SummaryOfChanges  
GROUP BY Change;

