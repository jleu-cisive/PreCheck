-- =============================================    
-- Author:  <Amy Liu>    
-- Tune date: <08/16/2021>    
-- Description: fine tune the stored procedure: ApplToBeFinaled    
--
-- Change Date : 10/03/2022
-- Change Author : Jeff Simenc	
-- Change Desc : Changed the "ISNULL" statemnts in the where clause.
--
-- Change Date : 04/13/2023
-- Change Author : Jeff Simenc	
-- Change Desc : Added index hint to the MedInteg table query.  Query now runs in 2 sec comparted to 30 sec
-- =============================================    
CREATE PROCEDURE [dbo].[ApplToBeFinaled] 
AS   
BEGIN
    
	SET NOCOUNT ON    
    
	--The logic doesn't cover if the app has no section attached to it.    
	SELECT A.Apno, A.ApStatus, A.UserID, A.Investigator,    
		   A.ApDate, A.ReopenDate,  A.Last, A.First, A.Middle,     
		   C.Name AS Client_Name    
	 FROM dbo.Appl A WITH (NOLOCK)    
	INNER JOIN dbo.Client C WITH(NOLOCK) ON A.Clno = C.Clno    
	left join dbo.Crim  WITH (NOLOCK) on crim.apno= a.apno And Crim.IsHidden =0 and ( crim.clear is null or crim.clear in ('R','M','O','V','I','W','Z','D'))    
	left join dbo.Civil WITH (NOLOCK) on civil.apno = a.apno AND ((Civil.Clear IS NULL) OR (Civil.Clear = 'O'))    
	left join dbo.Credit WITH (NOLOCK) on (Credit.Apno = A.Apno) AND (Credit.SectStat = '0' OR Credit.SectStat = '9')    
	left join  dbo.DL WITH (NOLOCK)  on (DL.Apno = A.Apno) AND (DL.SectStat = '0' OR DL.SectStat = '9')    
	left join dbo.Empl WITH (NOLOCK) on  (Empl.Apno = A.Apno) AND Empl.IsOnReport = 1 AND (Empl.SectStat = '0' OR Empl.SectStat = '9')    
	left join dbo.Educat WITH (NOLOCK) on  (Educat.Apno = A.Apno) AND Educat.IsOnReport = 1 AND (Educat.SectStat = '0' OR Educat.SectStat = '9')    
	left join dbo.ProfLic WITH (NOLOCK) on (ProfLic.Apno = A.Apno) AND ProfLic.IsOnReport = 1 AND (ProfLic.SectStat ='0' OR ProfLic.SectStat = '9')    
	left join dbo.PersRef WITH (NOLOCK) on  (PersRef.Apno = A.Apno) AND PersRef.IsOnReport = 1 AND (PersRef.SectStat = '0' OR PersRef.SectStat = '9')    
	left join dbo.Medinteg WITH (NOLOCK,INDEX(IX_MedInteg_ApNo))  on  (Medinteg.Apno = A.Apno) AND (Medinteg.SectStat = '0' OR Medinteg.SectStat = '9')    
	WHERE (A.ApStatus IN ('P','W'))    
	    AND A.Investigator <> ''	--AND ISNULL(A.Investigator, '') <> ''    -- chagned on 10/3
		AND A.userid IS NOT NULL	   
		--AND ISNULL(A.CAM, '') = '' -- Humera Ahmed on 8/16/2019 for fixing HDT#56758    
		AND c.clienttypeid <> 15	--AND ISNULL(c.clienttypeid,-1) <> 15    -- changed on 10/3
		AND crim.CrimID is null    
		AND civil.CivilID is null    
		AND credit.apno is null    
		AND DL.APNO is null    
		AND empl.EmplID is null    
		AND Educat.EducatID is null    
		AND ProfLic.ProfLicID is null    
		AND PersRef.PersRefID is null    
		AND Medinteg.apno is null       
	ORDER BY A.ApDate    
    
END