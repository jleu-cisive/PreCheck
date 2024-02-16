 -- Modified by Vidya Jha on 07/20/2023: For HDT 99965 to include any crims that have a Record Found or Transferred Record status to the Crim table and to ignore crims in Unused. 
CREATE PROCEDURE [Alert].[AdmittedRecordNotificationForCAM]  
AS  
  
 DECLARE  @CrimSearchesNotCompleted  TABLE(APNO int NOT NULL)  
  
 INSERT INTO @CrimSearchesNotCompleted  
 SELECT DISTINCT A.APNO FROM Appl(nolock) A   
 INNER JOIN CRIM(nolock) C   
 ON A.APNO = C.APNO   and C.IsHidden=0  
 WHERE A.ApStatus in ('P', 'W') and C.Clear not in ('P', 'T','F','I')  
  
 SELECT DISTINCT   
  ApplicantId=a.APNO,  
     CandidateName = (A.First + ' ' + A.Last),  
     Email= isnull(U.EmailAddress, 'dongmeihe@precheck.com'),  
     FacilityName=(CONVERT(VARCHAR(10),C.CLNO) + '/' + C.Name),  
     OrderDate=GetDate(), --CM.Last_Updated,  
     CCEmail='QARushes@precheck.com',  
     HourSinceInitialNotification = 0,  
     MaxDate=CONVERT(VARCHAR(12),CONVERT(DATE,DATEADD(DAY,10,CURRENT_TIMESTAMP)),101),  
     HasBackground=0,  
     HasDrugTest=0,  
     HasImmunization=0  
 FROM Appl(nolock) A   
 INNER JOIN Client(nolock) C   
  ON A.CLNO = C.CLNO  
 INNER JOIN Crim(nolock) CM  
  ON A.APNO = CM.APNO  And CM.IsHidden=0
 INNER JOIN ApplAdditionalData AD  
  ON A.APNO = AD.APNO  
 LEFT OUTER JOIN Users U  
  ON LOWER(RTRIM(LTRIM(C.CAM))) = LOWER(RTRIM(LTRIM(U.UserID)))  
 WHERE A.ApStatus in ('P', 'W')   
  AND AD.Crim_SelfDisclosed = 1  
  AND CM.Clear in ('P', 'T','F','I')  
  AND CM.APNO NOT IN (SELECT APNO FROM @CrimSearchesNotCompleted)  
  AND DATEDIFF(MINUTE, CM.Last_Updated, GETDATE()) BETWEEN 0 AND 60