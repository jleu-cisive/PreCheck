
-- ==================================================================================
-- Author:	Vidya Jha 
-- Create date: 06/22/2023
-- ===============================================================================

CREATE PROCEDURE [dbo].[LicenseCertificateMainPull_17484]	
	@CLNO int, @StartDate datetime,@EndDate datetime

AS
BEGIN


    SET  @StartDate = '01/20/2022'
--declare @CLNO int=17484, @StartDate datetime='01/20/2022',@EndDate datetime='05/31/2023'

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

	SELECT  DISTINCT  LicenseCertificateID as FolderID,ER.EmployerID as clno,LicenseCertificateID as ReportID, ER.employeeNumber,F.ClientFacilityGroup,F.FacilityName, ER.SSN ,-- T.ItemValue AS LicenseType
			coalesce(T1.LicenseType,l.Type, lt.ItemValue) AS LicenseType, CONVERT(VARCHAR, L.ExpiresDate, 101) AS ExpiresDate, L.Number, L.[Lifetime], 
			L.IssuingAuthority,l.issuingstate,L.LicenseID			
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
	INNER JOIN (SELECT facilityid,ClientFacilityGroup,FacilityName 
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

	ORDER BY F.FacilityName,employeeNumber

	--SELECT * FROM #tmp
	SELECT  T.FolderID, T.clno, T.ReportID, T.EmployeeNumber, T.FacilityName, T.LicenseType AS [License Type], T.ExpiresDate AS [Expiration Date],Lh.ClientLicIdentifier as SkillReferenceId,'' as ClientFacilityGroup,'' as ExpDate into #Temp2 FROM #tmp T
	left join hevn..License lh on lh.LicenseHistoryID=T.LicenseID

	select top 5000  * from #Temp2 ORDER BY EmployeeNumber

	--SELECT top 5000  T.FolderID, T.clno, T.ReportID, T.EmployeeNumber, T.ClientFacilityGroup, T.LicenseType AS [License Type], T.ExpiresDate AS [Expiration Date]
	--FROM #tmp AS T
	--ORDER BY EmployeeNumber

	DROP TABLE #tmpLicenseCertificates
	DROP TABLE #tmp
	DROP TABLE #LicenseHistoryRecords
	Drop Table #Temp2
END
