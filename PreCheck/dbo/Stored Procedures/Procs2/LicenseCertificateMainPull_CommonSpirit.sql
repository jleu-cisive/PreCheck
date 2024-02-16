
-- ==================================================================================
-- Author:	Prasanna 
-- Create date: 02/23/2022
-- Description: PSV License Certificate Request by EmployeeNumber provided in spreadsheet(HDT#24387)
-- EXEC [dbo].[LicenseCertificateMainPull_CommonSpirit] 9900
-- ===============================================================================

CREATE PROCEDURE [dbo].[LicenseCertificateMainPull_CommonSpirit]	
	@CLNO int = 0
AS
BEGIN

	CREATE TABLE #LicenseHistoryRecords (LicensehistoryID int , Licenseid int)

	INSERT INTO #LicenseHistoryRecords
	exec  HEVN.[dbo].[USP_GetDistinctLatestLicenseHistory] @CLNO

	SELECT  LicenseCertificateID, LicenseID, CreatedDate 
		INTO #tmpLicenseCertificates
	FROM CredentCheckDocuments.dbo.LicenseCertificate (NOLOCK)
	WHERE LicenseCertificateid IN (SELECT MAX(Licensecertificateid) 
									FROM CredentCheckDocuments.dbo.LicenseCertificate (NOLOCK)
									where Licenseid in (select Licensehistoryid from #LicenseHistoryRecords)
									GROUP BY Licenseid)
		and licenseid in (select Licenseid from HEVN.dbo.LicenseHistory AS L (NOLOCK) where VerifiedDate is not null and VerifiedBy2nd is not null and 
		employer_id = @CLNO and ParentLicenseID in (select licenseID from HEVN.dbo.[License] where EmployeeRecordID in(2849754,2849869,2850044,1360458,2850190,2850197,2850206,2850211,2689209,2850266,2850271,2850282,
		2850316,2850319,2850323,2610170,2850351,2850368,2893339,2850373,2850386,2850405,2993271,2850439,2850445,2850455,2850457,2850461,2850480,2694311,3127702,
		2850490,2456956,2456957,2850515,2850529,2850551,2850561,2574709,2656747,2307689,2850601,2325705,2462025,2850629,3154118,2453846,3077735,3103834,3009775,
		2406750,2559498,2642593,3186220,2435653,2650610,2628959,3178191,2458548,2482238,2850722,2850723,2441484,2628960,3193258,2850725,2456522,2456962,2531565,
		2456524,2456525,2456968,2456970,2456527,2456972,2456974,3186221,2482239,2456531,2456977,2456979,2456983,2456984,2558772,2456985,2456533,2456986,2456537,
		2456991,2477066,2850734,2465444,2465447,3160706,3011341,2699519,2465448,2850745,2535254,2483498,2995010,2483506,3128612,3128613,2562886,2850764,2950614,
		2850766,2850772,2562905,2850774,3121269,2850779,2850780,3119190,2625171,2850783,3184559,3105380,2567075,2850807,2993274,3194570,2850820,3046634,2850831,
		2656029,3117214,3046635,3046636,2850895,2850896,2850919,3189447,2850924,2850935,2850954,2850968,2850986,2850994,3194572,2851015,2851017,2851040,3186485,
		2851061,2851083,2881413,3194573,2851177,2851182,2922573,2851319,2851380,2851455,2704146,2851495,3152912,3104832,2851631)))

	SELECT  DISTINCT  LicenseCertificateID as FolderID,ER.EmployerID as clno,LicenseCertificateID as ReportID, ER.employeeNumber, F.ClientFacilityGroup, ER.SSN ,-- T.ItemValue AS LicenseType
			T1.LicenseType , CONVERT(VARCHAR, L.ExpiresDate, 101) AS ExpiresDate, L.Number, L.[Lifetime], 
			L.IssuingAuthority,l.issuingstate			
			,CONVERT(VARCHAR, L.ReviewDate, 101) as 'VerificationDate'
		INTO #tmp
	FROM HEVN.dbo.LicenseHistory AS L (NOLOCK)
	INNER JOIN (SELECT EmployerID,SSN,employeeNumber,Facilityid,departmentid 
				FROM HEVN.dbo.EmployeeRecord(NOLOCK)
				WHERE enddate IS NULL
				  AND Facilityid IS NOT NULL 
				  AND departmentid IS NOT NULL 
				  AND employeenumber IS NOT NULL 
				  AND EmployerID = @CLNO) AS ER ON ISNULL(L.Employer_id,0) = ER.Employerid AND L.SSN = ER.SSN
	INNER JOIN (SELECT * FROM #tmpLicenseCertificates) AS LC ON L.Licenseid = LC.Licenseid
	INNER JOIN (SELECT facilityid,ClientFacilityGroup 
				FROM HEVN.dbo.Facility (NOLOCK)
				WHERE ParentEmployerID = @CLNO or EmployerID = @CLNO) AS F ON ER.facilityid = F.FacilityID
	--INNER JOIN HEVN.[dbo].[LicenseType](NOLOCK) AS T ON L.LicenseTypeID = T.LicenseTypeID
	INNER JOIN HEVN.[dbo].[ClientLicenseType] AS T1 ON L.LicenseTypeID = T1.lmsLicenseTypeID and L.ClientLicenseTypeID = T1.ClientLicenseTypeID
	and t1.EmployerID= @CLNO
	--WHERE ((SELECT Count(*) 
	--		FROM precheck.dbo.reportuploadlog AS r WITH (NOLOCK) 
	--		WHERE r.ReportID = LC.LicenseCertificateID 
	--		  AND r.resend = 0 
	--		  AND r.ReportType = 3) = 0	)

	ORDER BY F.ClientFacilityGroup,employeeNumber

	--SELECT * FROM #tmp


	SELECT top 5000  T.FolderID, T.clno, T.ReportID, T.EmployeeNumber, T.ClientFacilityGroup, T.LicenseType AS [License Type], T.ExpiresDate AS [Expiration Date]
	FROM #tmp AS T
	ORDER BY EmployeeNumber

	DROP TABLE #tmpLicenseCertificates
	DROP TABLE #tmp
	DROP TABLE #LicenseHistoryRecords
END
