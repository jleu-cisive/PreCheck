





CREATE PROCEDURE [dbo].[ReportApplFinalUnfinished] 
@StartDate datetime, 
@EndDate datetime 

AS

SELECT 
  Apno,Convert(varchar(20),ApDate,101)ApDate,UserID,
 IsNull((SELECT count(*) FROM Civil (NOLOCK) WHERE Civil.apno=a.apno and Clear not in ('T','P','F') Group BY APNO), 0) CivilCount, --AS CrimCount,
 IsNull((SELECT count(*) FROM Credit (NOLOCK) WHERE Credit.apno=a.apno and RepType='C' and SectStat in ('0','9') Group BY APNO), 0) AS CreditCount,
 IsNull((SELECT count(*) FROM Crim (NOLOCK) WHERE Crim.apno=a.apno and Clear not in ('T','P','F') Group BY APNO), 0) AS CrimCount,
 IsNull((SELECT count(*) FROM DL (NOLOCK) WHERE DL.apno=a.apno and SectStat in ('0','9') Group BY APNO), 0) AS DLCount,
 IsNull( (SELECT count(*) FROM Empl (NOLOCK) WHERE empl.apno=a.apno and SectStat in ('0','9') and Empl.IsOnReport = 1 Group BY APNO), 0) AS EmplCount,
 IsNull( (SELECT count(*) FROM MedInteg (NOLOCK) WHERE MedInteg.apno=a.apno and SectStat in ('0','9') Group BY APNO), 0) AS MedIntegCount,
 IsNull( (SELECT count(*) FROM PersRef (NOLOCK) WHERE PersRef.apno=a.apno and SectStat in ('0','9') and PersRef.IsOnReport = 1 Group BY APNO), 0) AS PersRefCount,
 IsNull( (SELECT count(*) FROM ProfLic (NOLOCK) WHERE ProfLic.apno=a.apno and SectStat in ('0','9') and ProfLic.IsOnReport = 1 Group BY APNO), 0) AS ProfLicCount,
 IsNull( (SELECT count(*) FROM Credit (NOLOCK) WHERE Credit.apno=a.apno and RepType='S' and SectStat in ('0','9') Group BY APNO), 0) AS SocialCount
FROM Appl a (NOLOCK) 
WHERE ApDate >= @StartDate and ApDate < @EndDate and ApStatus = 'F'
and (
     (SELECT count(*) FROM Civil (NOLOCK) WHERE Civil.apno=a.apno and Clear not in ('T','P','F') Group BY APNO) > 0
  or (SELECT count(*) FROM Credit (NOLOCK) WHERE Credit.apno=a.apno and RepType='C' and SectStat in ('0','9') Group BY APNO) > 0
  or (SELECT count(*) FROM Crim (NOLOCK) WHERE Crim.apno=a.apno and Clear not in ('T','P','F') Group BY APNO) > 0
  or (SELECT count(*) FROM DL (NOLOCK) WHERE DL.apno=a.apno and SectStat in ('0','9') Group BY APNO) > 0
  or (SELECT count(*) FROM Educat (NOLOCK) WHERE educat.apno=a.apno and SectStat in ('0','9') and Educat.IsOnReport = 1 Group BY APNO) > 0
  or (SELECT count(*) FROM Empl (NOLOCK) WHERE empl.apno=a.apno and SectStat in ('0','9') and Empl.IsOnReport = 1 Group BY APNO) > 0
  or (SELECT count(*) FROM MedInteg (NOLOCK) WHERE MedInteg.apno=a.apno and SectStat in ('0','9') Group BY APNO) > 0
  or (SELECT count(*) FROM PersRef (NOLOCK) WHERE PersRef.apno=a.apno and SectStat in ('0','9') and PersRef.IsOnReport = 1 Group BY APNO) > 0
  or (SELECT count(*) FROM ProfLic (NOLOCK) WHERE ProfLic.apno=a.apno and SectStat in ('0','9') and ProfLic.IsOnReport = 1 Group BY APNO) > 0
  or (SELECT count(*) FROM Credit (NOLOCK) WHERE Credit.apno=a.apno and RepType='S' and SectStat in ('0','9') Group BY APNO) > 0
     )
ORDER BY APNO
