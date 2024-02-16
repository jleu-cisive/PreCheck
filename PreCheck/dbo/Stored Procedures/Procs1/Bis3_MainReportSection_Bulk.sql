




CREATE PROCEDURE [dbo].[Bis3_MainReportSection_Bulk] @APNOFrom int ,@APNOTo int AS

-- Detect if all sections need to be supressed

SELECT     A.*, C.Addr1, C.Addr2 , C.Addr3 , C.Name AS Client_Name,c.city + ', ' + c.state + ' ' + c.zip as client_citystate,c.phone as Cphone,c.fax as Cfax,
 (SELECT COUNT(1) FROM Crim WITH (NOLOCK) WHERE (Crim.Apno = A.APNO) and  (IsHidden = 0)) AS Crim_Count,
       (SELECT COUNT(1) FROM Civil WITH (NOLOCK) WHERE (Civil.Apno = A.APNO)) AS Civil_Count,
       (SELECT COUNT(1) FROM Credit  WITH (NOLOCK) WHERE (Credit.Apno = A.APNO) and reptype = 'C'  and  (IsHidden = 0)) AS Credit_Count,
       (SELECT COUNT(1) FROM Credit WITH (NOLOCK) WHERE (Credit.Apno = A.APNO) and reptype = 'S'  and  (IsHidden = 0)) AS Social_Count,
       (SELECT COUNT(1) FROM DL WITH (NOLOCK) WHERE (DL.Apno = A.APNO)  and  (IsHidden = 0)) AS DL_Count,
       (SELECT COUNT(1) FROM Empl WITH (NOLOCK) WHERE (Empl.Apno = A.APNO)  and  (IsHidden = 0) and (IsOnReport = 1)) AS Empl_Count,
       (SELECT COUNT(1) FROM Educat  WITH (NOLOCK) WHERE (Educat.Apno = A.APNO)  and  (IsHidden = 0)  and (IsOnReport = 1)) AS Educat_Count,
       (SELECT COUNT(1) FROM ProfLic WITH (NOLOCK) WHERE (ProfLic.Apno = A.APNO)  and  (IsHidden = 0) and (IsOnReport = 1)) AS ProfLic_Count,
       (SELECT COUNT(1) FROM PersRef WITH (NOLOCK)  WHERE (PersRef.Apno = A.APNO)  and  (IsHidden = 0)  and (IsOnReport = 1)) AS PersRef_Count,
       (SELECT COUNT(1) FROM medinteg WITH (NOLOCK) WHERE (medinteg.Apno = A.APNO)  and  (IsHidden = 0)) AS Medinteg_Count,
--Add California verbiage if client is  California based or if Applicant is CA based -- schapyala added 03/09/2011
	   (CASE WHEN C.State = 'CA' or C.BillingState = 'CA' or A.State = 'CA' then 1 else 0 end) bAddCaliforniaVerbiage 
FROM         dbo.Appl A WITH (NOLOCK) INNER JOIN
                      dbo.Client C WITH (NOLOCK) ON A.CLNO = C.CLNO
WHERE     (A.APNO >= @APNOFrom and A.APNO <= @APNOTo)


