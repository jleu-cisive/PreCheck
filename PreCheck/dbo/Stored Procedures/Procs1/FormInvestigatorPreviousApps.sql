CREATE PROCEDURE [dbo].[FormInvestigatorPreviousApps]
(@APNO int)
AS
SET NOCOUNT ON

SELECT  A1.APNO
 , CONVERT(varchar, A1.ApDate, 101) AS ApDate
 , A1.CLNO
 , C.[Name]
FROM    dbo.Appl A1 WITH (NOLOCK)
INNER JOIN  dbo.Client C WITH (NOLOCK)
       ON A1.CLNO = C.CLNO
WHERE A1.SSN = (SELECT SSN FROM dbo.Appl 
   WHERE APNO = @Apno AND SSN != '' AND SSN IS NOT NULL) --Removed the ISnull to make sure the index on SSN is used by execution plan
  AND A1.ApNO != @Apno
ORDER BY A1.ApDate DESC

/*Commented below based on Ed @ cisive recommendation. Santosh made the above change after validaing on 08/21/2019*/
--SELECT 	A1.APNO
--	, CONVERT(varchar, A1.ApDate, 101) AS ApDate
--	, A1.CLNO
--	, C.[Name]
--FROM 	dbo.Appl A1 WITH (NOLOCK)
--	INNER JOIN dbo.Appl A2 WITH (NOLOCK)
--	ON A1.SSN = A2.SSN
--	INNER JOIN dbo.Client C WITH (NOLOCK)
--	ON A1.CLNO = C.CLNO
--WHERE	A2.APNO = @APNO
--	AND A1.APNO <> A2.APNO AND ISNULL(A1.SSN,'') <> ''
--ORDER BY A1.ApDate DESC

SET NOCOUNT OFF
