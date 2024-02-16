
-- EXEC [dbo].[HCA_LicenseCertificateMainPull] 7519,'3/01/2019', '3/10/2019'

CREATE PROCEDURE [dbo].[HCA_LicenseCertificateMainPull]
	
	@CLNO int, @StartDate datetime,@EndDate datetime

AS
BEGIN
SET NOCOUNT ON 

--set  @StartDate = '12/01/2018' 
--set @EndDate  = '12/15/2018'
insert into winservicelog (logdate,logmessage) values(getdate(),'MethodistParamsRelease: ' + cast(@CLNO as varchar(20)) + ' ' + convert(varchar,@StartDate,101) + ' ' + convert(varchar,@EndDate,101));


--Exec CredentCheckDocuments.dbo.[LicenseCertificateMainPull] @CLNO,@StartDate ,@EndDate
		
		SELECT LicenseCertificateID, LicenseID, CreatedDate 
		INTO #tmpLicenseCertificates
	FROM CredentCheckDocuments.dbo.LicenseCertificate (NOLOCK)
	WHERE LicenseCertificateid IN (SELECT MAX(Licensecertificateid) 
									FROM CredentCheckDocuments.dbo.LicenseCertificate (NOLOCK)
									GROUP BY Licenseid)
		and licenseid in 
		(select Licenseid from HEVN.dbo.LicenseHistory AS L (NOLOCK) 
		where VerifiedDate is not null and VerifiedBy2nd is not null and 
		  VerifiedDate >= @StartDate 	  AND VerifiedDate < @EndDate and employer_id = @CLNO)
	  --AND CreatedDate >= @StartDate 
	  --AND CreatedDate < @EndDate



	--SELECT * FROM #tmpLicenseCertificates --where licenseid in (10765124,10939763,10915250,10915268,10921623,10930992)
	--order by createddate desc
	SELECT DISTINCT LicenseCertificateID as FolderID,ER.EmployerID as clno,LicenseCertificateID as ReportID, ER.employeeNumber, F.ClientFacilityGroup, ER.SSN ,-- T.ItemValue AS LicenseType
	T1.LicenseType
	, CONVERT(VARCHAR, L.ExpiresDate, 101) AS ExpiresDate
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
	INNER JOIN HEVN.[dbo].[ClientLicenseType] AS T1 ON L.LicenseTypeID = T1.lmsLicenseTypeID and L.type = t1.licensetype and t1.EmployerID= @CLNO
	WHERE ((SELECT Count(*) 
			FROM precheck.dbo.reportuploadlog AS r WITH (NOLOCK) 
			WHERE r.ReportID = LC.LicenseCertificateID 
			  AND r.resend = 0 
			  AND r.ReportType = 3) = 0	)

	ORDER BY F.ClientFacilityGroup,employeeNumber

	--SELECT * FROM #tmp

	
		SELECT distinct T.FolderID, T.clno, T.ReportID, T.EmployeeNumber, T.ClientFacilityGroup, T.LicenseType AS [License Type], T.ExpiresDate AS [Expiration Date]
		FROM #tmp AS T
		ORDER BY EmployeeNumber
	

	DROP TABLE #tmpLicenseCertificates
	DROP TABLE #tmp

SET NOCOUNT OFF 
END


