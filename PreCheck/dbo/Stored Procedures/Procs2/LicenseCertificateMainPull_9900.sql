
-- ==================================================================================
-- Author:	Prasanna 
-- Create date: 04/09/2021
-- Description: Modified SP CredentCheckDocuments.[dbo].[LicenseCertificateMainPull]
-- EXEC [dbo].[LicenseCertificateMainPull_9900] 9900, '05/01/2022','5/18/2022'
-- Modified By: Prasanna on 4/9/2021 for HDT#84577 - license mapping for this account, has several client types mapped to a single LMP license type
-- Modified by Prasanna on 04/23/2021 for changing the start date after the catchup file - HDT#87583 9900 - Bulk Certificate Schedule
-- Modified by Amyliu on 05/19/2022 for 13606 merge to 9900 for HDT48222,HDT48224,HDT48225,HDT49610
-- exec [dbo].[LicenseCertificateMainPull_9900]	 9900, '01/20/2020', '05/19/2022'
-- modified by Amy on 06/06/2022 for HDT50747:  client license type on Credentialing Certificate and index file
-- ===============================================================================

CREATE PROCEDURE [dbo].[LicenseCertificateMainPull_9900]	
	@CLNO int, @StartDate datetime,@EndDate datetime

AS
BEGIN


    SET  @StartDate = '01/20/2021'

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
		and licenseid in (select Licenseid from HEVN.dbo.LicenseHistory AS L (NOLOCK) where VerifiedDate is not null and VerifiedBy2nd is not null 
		and VerifiedDate >= @StartDate 	  AND VerifiedDate < @EndDate 
		and employer_id = @CLNO)

	SELECT  DISTINCT  LicenseCertificateID as FolderID,ER.EmployerID as clno,LicenseCertificateID as ReportID, ER.employeeNumber, F.ClientFacilityGroup, ER.SSN ,-- T.ItemValue AS LicenseType
			coalesce(T1.LicenseType,l.Type, lt.ItemValue) AS LicenseType, CONVERT(VARCHAR, L.ExpiresDate, 101) AS ExpiresDate, L.Number, L.[Lifetime], 
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
				  and ( HrCompany is null or HrCompany ='CHI')
				  AND EmployerID = @CLNO) AS ER ON ISNULL(L.Employer_id,0) = ER.Employerid AND L.SSN = ER.SSN
	INNER JOIN (SELECT * FROM #tmpLicenseCertificates) AS LC ON L.Licenseid = LC.Licenseid
	INNER JOIN (SELECT facilityid,ClientFacilityGroup 
				FROM HEVN.dbo.Facility (NOLOCK)
				WHERE ParentEmployerID = @CLNO or EmployerID = @CLNO) AS F ON ER.facilityid = F.FacilityID
	INNER JOIN HEVN.[dbo].[LicenseType](NOLOCK) AS LT ON L.LicenseTypeID = LT.LicenseTypeID
	LEFT JOIN HEVN.[dbo].[ClientLicenseType] AS T1 ON L.LicenseTypeID = T1.lmsLicenseTypeID and L.Employer_ID = T1.EmployerID AND isnull(l.Type,'')= isnull(T1.LicenseType,'')
	and t1.EmployerID= @CLNO
	WHERE ((SELECT Count(*)
			FROM precheck.dbo.reportuploadlog AS r WITH (NOLOCK)
			WHERE r.ReportID = LC.LicenseCertificateID 
			  AND r.resend = 0
			  AND r.ReportType = 3) = 0	)

	ORDER BY F.ClientFacilityGroup,employeeNumber

	--SELECT * FROM #tmp


	SELECT top 5000  T.FolderID, T.clno, T.ReportID, T.EmployeeNumber, T.ClientFacilityGroup, T.LicenseType AS [License Type], T.ExpiresDate AS [Expiration Date]
	FROM #tmp AS T
	ORDER BY EmployeeNumber

	DROP TABLE #tmpLicenseCertificates
	DROP TABLE #tmp
	DROP TABLE #LicenseHistoryRecords
END
