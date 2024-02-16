

/*
Procedure Name : [dbo].[License_Certificates_Created_For_Client_BackGround_Checks]
Requested By: Dana Sangerhausen
Developer: Deepak Vodethela
Execution : EXEC [dbo].[License_Certificates_Created_For_Client_BackGround_Checks] 3115 , '11/01/2015', '12/03/2015'
*/

CREATE PROCEDURE [dbo].[License_Certificates_Created_For_Client_BackGround_Checks]
@CLNO int = NULL,
@StartDate varchar(10), 
@EndDate varchar(10)
AS

SELECT A.ApDate AS ReportCreatedDate, A.APNO AS ReportNumber,P.Lic_Type AS LicenseType, S.Description AS SectionStatus,
              C.Name AS ClientName, A.Last AS ApplicantLastName, A.First AS ApplicantFirstName,  L.CreatedDate AS CertificateCreatedDate, A.CompDate CompletionDate,
              P.Investigator AS ProfLicInvestigator, Last_Worked AS LicenseLastWorked, 
              CASE WHEN GenerateCertificate = 0 and CertificateAvailabilityStatus = 1 THEN 'True'
                   WHEN GenerateCertificate = 1 THEN  'True' 
                   ELSE 'False'
              END AS CertificateGeneratedByInvestigator, 
              CASE CertificateAvailabilityStatus 
                     WHEN 0 THEN 'False'
                     WHEN 2 THEN 'False'
                     ELSE 'True' 
              END AS CertificateMadeAvailableForBGbySystem 
FROM [PreCheck].dbo.Appl AS A (NOLOCK) 
INNER JOIN [PreCheck].dbo.ProfLic AS P (NOLOCK) ON A.APNO = P.APNO
INNER JOIN [PreCheck].dbo.Client AS C (NOLOCK) ON C.CLNO = A.CLNO
INNER JOIN [PreCheck].dbo.SectStat AS S (NOLOCK) ON S.Code = P.SectStat
LEFT JOIN [CredentCheckDocuments].dbo.LicenseCertificate_BGCheck AS L (NOLOCK)ON A.APNO = L.APNO
WHERE @StartDate IS NULL OR A.ApDate >= @StartDate
  AND A.ApDate < DATEADD(DAY, 1, @EndDate)
  AND (@Clno IS NULL OR C.CLNO = @Clno)
  AND C.CLNO NOT IN (3468, 2135)
ORDER BY C.Name, A.ApDate DESC

