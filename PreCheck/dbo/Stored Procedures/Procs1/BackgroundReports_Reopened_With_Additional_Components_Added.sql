
-- =======================================================================================================
-- Author:		Suchitra Yellapantula
-- Create date: 08/15/2016
-- Description:	Stored procedure to generate Background Reports reopened with additional components added
-- Parameters:  @StartDate, @EndDate --'2001-01-01'--,--'2009-01-01'--
-- Modified by Humera Ahmed on 9/13/2019 for HDT #58266 - Add CLNO, AffiliateId parameters and Affiliate Name column
-- =======================================================================================================

/* Modified By: Sunil Mandal A
-- Modified Date: 06/29/2022
-- Description: Ticketno-53763 
Modify existing q-reports that have affiliate ids in their search parameters
Details: 
Change search parameters for the Affiliate Id field
     * search by multiple affiliate ids (ex 4:297)
     * want to also be able to search all affiliates by putting zero - meaning 0 to search all affiliates
     * multiple affiliates to be separated by a colon  
Under Parameter Names - after Affiliate ID include this wording (separate by colon, default 0)
*/
---Testing
/*

EXEC [dbo].[BackgroundReports_Reopened_With_Additional_Components_Added] '2009-01-01','2009-01-10','0',0;
EXEC [dbo].[BackgroundReports_Reopened_With_Additional_Components_Added] '2009-01-01','2009-01-10','0','4:30:177';

*/

CREATE PROCEDURE [dbo].[BackgroundReports_Reopened_With_Additional_Components_Added]
	-- Add the parameters for the stored procedure here
	@StartDate Date, 
	@EndDate Date,
	@Clno VARCHAR(MAX) = '', --Humera Ahmed on 9/13/2019 for HDT #58266 - Add CLNO, AffiliateId parameters and Affiliate Name column
	-- @AffiliateID int = 0 --code added by Sunil Mandal for ticket id -53763
	@AffiliateIDs varchar(MAX) = '0'--code added by Sunil Mandal for ticket id -53763
	
AS
BEGIN
--Test values: SET @StartDate = '2001-01-01'; SET @EndDate = '2009-01-01';

	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	IF OBJECT_ID('tempdb..#Temp_AppInfo') IS NOT NULL DROP Table #Temp_AppInfo;
IF OBJECT_ID('tempdb..#Temp_CountEmpl') IS NOT NULL DROP Table #Temp_CountEmpl;
IF OBJECT_ID('tempdb..#Temp_CountEducat') IS NOT NULL DROP Table #Temp_CountEducat;
IF OBJECT_ID('tempdb..#Temp_CountLicense') IS NOT NULL DROP Table #Temp_CountLicense;
IF OBJECT_ID('tempdb..#Temp_CountRef') IS NOT NULL DROP Table #Temp_CountRef;
IF OBJECT_ID('tempdb..#Temp_CountCrim') IS NOT NULL DROP Table #Temp_CountCrim;
IF OBJECT_ID('tempdb..#Temp_CountSC') IS NOT NULL DROP Table #Temp_CountSC;
IF OBJECT_ID('tempdb..#Temp_CountMVR') IS NOT NULL DROP Table #Temp_CountMVR;
IF OBJECT_ID('tempdb..#Temp_CountCredit') IS NOT NULL DROP Table #Temp_CountCredit;

IF(@Clno = '' OR LOWER(@Clno) = 'null' OR @Clno = '0'  ) --Humera Ahmed on 9/13/2019 for HDT #58266 - Add CLNO, AffiliateId parameters and Affiliate Name column
Begin  
	SET @Clno = NULL  
END

	--code added by Sunil Mandal for ticket id -53763 starts
	IF @AffiliateIDs = '0' 
	BEGIN  
		SET @AffiliateIDs = NULL  
	END
     --code added by Sunil Mandal for ticket id -53763 Ends	

--Get the list of Apps which have been Reopened between the data range input by the user
SELECT A.Apno as 'Report Number', Cl.CAM, A.CLNO as 'Client ID', R.Affiliate AS 'Affiliate Name', Cl.Name, A.OrigCompDate as 'Date Closed', A.ReopenDate as 'Date Reopened'
INTO #Temp_AppInfo
FROM Appl A 
INNER JOIN Client Cl ON A.CLNO = Cl.CLNO
INNER JOIN refAffiliate R ON R.AffiliateID = Cl.AffiliateID
WHERE A. ReopenDate is not null and A.ApStatus='F'
AND (@CLNO IS NULL  OR Cl.CLNO IN (SELECT VALUE FROM fn_Split(@CLNO,':'))) -- Humera Ahmed on 9/13/2019 for HDT #58266 - Add CLNO, AffiliateId parameters and Affiliate Name column
--AND R.AffiliateID = IIF(@AffiliateID = 0, R.AffiliateID, @AffiliateID) --code added by Sunil Mandal for ticket id -53763
AND (@AffiliateIDs IS NULL OR R.AffiliateID IN (SELECT value FROM fn_Split(@AffiliateIDs,':')))--code added by Sunil Mandal for ticket id -53763
AND A.ReopenDate between @StartDate and @EndDate;

--Calculate the number of Employment components added for each of the APNOs above
SELECT T.[Report Number], COUNT(E.EmplID) as 'Employment' 
INTO #Temp_CountEmpl
FROM #Temp_AppInfo T
LEFT JOIN Empl E on T.[Report Number] = E.Apno and E.CreatedDate>=T.[Date Reopened]
GROUP BY T.[Report Number];


--Calculate the number of Education Components added for each of the APNOs above
SELECT T.[Report Number], COUNT(Ed.EducatID) as 'Education'
INTO #Temp_CountEducat
FROM #Temp_AppInfo T
LEFT JOIN Educat Ed ON T.[Report Number]=Ed.APNO and Ed.CreatedDate>=T.[Date Reopened]
GROUP BY T.[Report Number];


--Calculate the number of License components added for each of the APNOs above
SELECT T.[Report Number], COUNT(P.ProfLicID) as 'License'
INTO #Temp_CountLicense
FROM #Temp_AppInfo T
LEFT JOIN ProfLic P ON T.[Report Number]=P.APNO and P.CreatedDate>=T.[Date Reopened]
GROUP BY T.[Report Number];

--Calculate the number of Reference components added for each of the APNOs above
SELECT T.[Report Number], COUNT(Pr.PersRefID) as 'Reference'
INTO #Temp_CountRef
FROM #Temp_AppInfo T
LEFT JOIN PersRef Pr ON T.[Report Number]=Pr.APNO and Pr.CreatedDate>=T.[Date Reopened]
GROUP BY T.[Report Number];

--Calculate the number of Criminal Components added for each of the APNOs above
SELECT T.[Report Number], COUNT(C.CrimID) as 'Criminal'
INTO #Temp_CountCrim
FROM #Temp_AppInfo T
LEFT JOIN Crim C ON T.[Report Number]=C.APNO and C.CreatedDate>=T.[Date Reopened]
GROUP BY T.[Report Number];

--Calculate the number of Sanction Check components for each of the APNOs above
SELECT T.[Report Number], COUNT(M.APNO) as 'SanctionCheck' --SUM(CASE WHEN M.APNO is null then 0 ELSE 1 END) as 'SanctionCheck'
INTO #Temp_CountSC
FROM #Temp_AppInfo T
LEFT JOIN MedInteg M ON T.[Report Number]=M.APNO and M.CreatedDate>=T.[Date Reopened]
GROUP BY T.[Report Number];

--Calculate the number of MVR components for each of the APNOs above
SELECT T.[Report Number], COUNT(D.APNO) as 'MVR'
INTO #Temp_CountMVR
FROM #Temp_AppInfo T
LEFT JOIN DL D ON T.[Report Number]=D.APNO and D.CreatedDate>=T.[Date Reopened]
GROUP BY T.[Report Number];

--Calculate the number of MVR components for each of the APNOs above
SELECT T.[Report Number], COUNT(Ct.APNO) as 'Credit'
INTO #Temp_CountCredit 
FROM #Temp_AppInfo T
LEFT JOIN Credit Ct ON T.[Report Number]=Ct.APNO and Ct.CreatedDate>=T.[Date Reopened]
GROUP BY T.[Report Number];


--Select all the APNOs and counts for those APNOs where at least one of the categories has components created after the Reopened date selected
SELECT T.*, E.Employment, Ed.Education, L.License, R.Reference, C.Criminal, M.SanctionCheck, D.MVR, Ct.Credit
FROM #Temp_AppInfo T
INNER JOIN #Temp_CountEmpl E ON T.[Report Number]=E.[Report Number]
INNER JOIN #Temp_CountEducat Ed ON T.[Report Number]=Ed.[Report Number]
INNER JOIN #Temp_CountLicense L on T.[Report Number]=L.[Report Number]
INNER JOIN #Temp_CountRef R on T.[Report Number]=R.[Report Number]
INNER JOIN #Temp_CountCrim C on T.[Report Number] = C.[Report Number]
INNER JOIN #Temp_CountSC M on T.[Report Number] = M.[Report Number]
INNER JOIN #Temp_CountMVR D on T.[Report Number] = D.[Report Number]
INNER JOIN #Temp_CountCredit Ct on T.[Report Number] = Ct.[Report Number]
WHERE (E.Employment>0 or Ed.[Education]>0 or L.License>0 or R.Reference>0 or C.Criminal>0 or M.SanctionCheck>0 or L.License>0 or Ct.Credit>0);


DROP TABLE #Temp_AppInfo;
DROP Table #Temp_CountEmpl;
DROP Table #Temp_CountEducat;
DROP Table #Temp_CountLicense;
DROP Table #Temp_CountCrim;
DROP Table #Temp_CountSC;
DROP Table #Temp_CountRef;
DROP Table #Temp_CountCredit;
DROP Table #Temp_CountMVR;


END
