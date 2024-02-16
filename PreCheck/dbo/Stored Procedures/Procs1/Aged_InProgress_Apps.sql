
/*
Procedure Name : Aged_InProgress_Apps
Requested By: Valerie K. Salazar
Developer: Deepak Vodethela
Execution : EXEC [dbo].[Aged_InProgress_Apps]  '',10
-- Modified by Humera Ahmed on 5/15/2019 for HDT#52276
--Modified by Radhika Dereddy on 06/16/2020 - Added this because while exporting the columns to excel the length of Priv_notes field is 214766 for APNO =5179533) 
-- and many of more so adding the max length of the excel to accommodate the export.

- Modified by Doug DeGenaro on 10/13/2021 for HDT#22157 - Put two conditions in for where UserID is '0' or AffiliateID is '0'
---- Modified by Vidya Jha on 9/20/2022 for HDT#63920- added SanctionCheck to the Component Type column
*/
/* Modified By: Sunil Mandal A
-- Modified Date: 06/30/2022
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
Execution : EXEC [dbo].[Aged_InProgress_Apps]  '',4
Execution : EXEC [dbo].[Aged_InProgress_Apps]  '','4:147:48'

*/

CREATE PROCEDURE [dbo].[Aged_InProgress_Apps]
@UserID VARCHAR(MAX) = NULL,
-- @AffiliateID VARCHAR(MAX) = NULL --code commented by Sunil Mandal for ticket id -53763	
	@AffiliateIDs varchar(MAX) = '0'--code added by Sunil Mandal for ticket id -53763
AS

	IF(@UserID = '' OR LOWER(@UserID) = 'null' or @UserID='0') 
	Begin  
		SET @UserID = NULL  
	END
/*
	IF(@AffiliateID = '' or @AffiliateID = '0') 
	Begin  
		SET @AffiliateID = NULL  
	END
*/
	--code added by Sunil Mandal for ticket id -53763 starts
	IF @AffiliateIDs = '0' 
	BEGIN  
		SET @AffiliateIDs = NULL  
	END
     --code added by Sunil Mandal for ticket id -53763 Ends	

	SELECT A.Apno [Report Number], A.CLNO [Client ID], C.Name AS Client_Name, C.AffiliateID [AffiliateID], ra.Affiliate, A.Last AS LastName, A.First AS FirstName, format(A.Apdate, 'MM/dd/yyyy hh:mm tt') [Report Date], A.Reopendate AS ReOpenDate, A.ApStatus,
		   dbo.elapsedbusinessdays_2( A.ApDate,CURRENT_TIMESTAMP) AS Elapsed, A.UserID
		INTO #tmp
	FROM Appl AS A WITH (NOLOCK)
	INNER JOIN Client C  WITH (NOLOCK) ON A.Clno = C.Clno
	INNER JOIN dbo.refAffiliate ra ON c.AffiliateID = ra.AffiliateID
	WHERE (A.ApStatus IN ('P','W')) 
	  AND A.CLNO NOT IN (2135,3468)
	  AND dbo.elapsedbusinessdays_2(A.ApDate,CURRENT_TIMESTAMP) > 3
	  AND (@UserID IS NULL OR A.UserID IN (SELECT * from [dbo].[Split](':',@UserID)))
	 -- AND (@AffiliateID IS NULL OR c.AffiliateID IN (SELECT * from [dbo].[Split](':',@AffiliateID)))  --code commented by Sunil Mandal for ticket id -53763	  
	  AND (@AffiliateIDs IS NULL OR c.AffiliateID IN (SELECT value FROM fn_Split(@AffiliateIDs,':')))--code added by Sunil Mandal for ticket id -53763
	  ORDER BY A.ApDate DESC

	--SELECT * FROM #tmp
	
	SELECT 'Empl' AS ComponetType, A.*, S.[Description] AS [Component Status], E.Employer AS [Source],
	REPLACE(REPLACE(E.Priv_Notes, char(10),';'),char(13),';') AS [Private Notes]
	FROM #tmp AS A WITH (NOLOCK) 
	INNER JOIN Empl AS E WITH (NOLOCK) ON A.[Report Number] = E.Apno -- Modified by HAhmed on 5/15/2019 for HDT#52276
	INNER JOIN SectStat AS S(NOLOCK) ON E.SectStat = S.Code
	WHERE E.IsOnreport = 1  
	  AND E.Ishidden = 0 
	  AND A.ApStatus = 'P' 
	  AND E.SectStat IN ('0','9')
	  AND LEN(Replace(REPLACE(E.Priv_Notes , char(10),';'),char(13),';')) < 32767 --Added by Radhika dereddy on 06/11/2020 this because while exporting the columns to excel the length of Priv_notes field is 214766 for APNO =5179533) and many of more so adding the max length of the excel to accommodate the export.

	UNION ALL
	SELECT 'Educat' AS ComponetType, A.*, S.[Description] AS [Component Status], E.School AS [Source], 
	REPLACE(REPLACE(E.Priv_Notes, char(10),';'),char(13),';') AS [Private Notes]
	FROM #tmp AS A WITH (NOLOCK) 
	INNER JOIN Educat AS E WITH (NOLOCK) ON A.[Report Number] = E.Apno -- Modified by HAhmed on 5/15/2019 for HDT#52276
	INNER JOIN SectStat AS S(NOLOCK) ON E.SectStat = S.Code
	WHERE E.IsOnreport = 1  
	  AND E.Ishidden = 0 
	  AND A.ApStatus = 'P' 
	  AND E.SectStat IN ('0','9')
	  AND LEN(Replace(REPLACE(E.Priv_Notes , char(10),';'),char(13),';')) < 32767 --Added by Radhika dereddy on 06/1644/2020 this because while exporting the columns to excel the length of Priv_notes field is 214766 for APNO =5179533) and many of more so adding the max length of the excel to accommodate the export.

	UNION ALL
	SELECT 'PersRef' AS ComponetType, A.*, S.[Description] AS [Component Status], P.Name AS [Source], 
	REPLACE(REPLACE(P.Priv_Notes, char(10),';'),char(13),';') AS [Private Notes]
	FROM #tmp AS A WITH (NOLOCK) 
	INNER JOIN PersRef AS P WITH (NOLOCK) ON A.[Report Number] = P.Apno -- Modified by HAhmed on 5/15/2019 for HDT#52276
	INNER JOIN SectStat AS S(NOLOCK) ON P.SectStat = S.Code
	WHERE P.IsOnreport = 1  
	  AND P.Ishidden = 0 
	  AND A.ApStatus = 'P' 
	  AND P.SectStat IN ('0','9')
	  AND LEN(Replace(REPLACE(P.Priv_Notes , char(10),';'),char(13),';')) < 32767 --Added by Radhika dereddy on 06/16/2020 this because while exporting the columns to excel the length of Priv_notes field is 214766 for APNO =5179533) and many of more so adding the max length of the excel to accommodate the export.

	UNION ALL
	SELECT 'ProfLic' AS ComponetType, A.*, S.[Description] AS [Component Status], P.Lic_Type AS [Source],
	 REPLACE(REPLACE(P.Priv_Notes, char(10),';'),char(13),';') AS [Private Notes]
	FROM #tmp AS A WITH (NOLOCK) 
	INNER JOIN ProfLic AS P WITH (NOLOCK) ON A.[Report Number] = P.Apno -- Modified by HAhmed on 5/15/2019 for HDT#52276
	INNER JOIN SectStat AS S(NOLOCK) ON P.SectStat = S.Code
	WHERE P.IsOnreport = 1  
	  AND P.Ishidden = 0 
	  AND A.ApStatus = 'P' 
	  AND P.SectStat IN ('0','9')
	  AND LEN(Replace(REPLACE(P.Priv_Notes , char(10),';'),char(13),';')) < 32767 --Added by Radhika dereddy on 06/16/2020 this because while exporting the columns to excel the length of Priv_notes field is 214766 for APNO =5179533) and many of more so adding the max length of the excel to accommodate the export.

	UNION ALL
	SELECT 'Crim' AS ComponetType, A.*, S.[CrimDescription] AS [Component Status], C.County AS [Source], 
	REPLACE(REPLACE(C.Priv_Notes, char(10),';'),char(13),';') AS [Private Notes]
	FROM #tmp AS A WITH (NOLOCK) 
	INNER JOIN Crim AS C WITH (NOLOCK) ON A.[Report Number] = C.Apno -- Modified by HAhmed on 5/15/2019 for HDT#52276
	INNER JOIN CrimSectStat AS S(NOLOCK) ON C.[CLEAR] = S.CrimSect
	WHERE C.Ishidden = 0 
	  AND A.ApStatus = 'P' 
	  AND C.[CLEAR] IN (NULL,'Q','Z','O','M','R','G','I','V','W')
	  AND LEN(Replace(REPLACE(C.Priv_Notes , char(10),';'),char(13),';')) < 32767 --Added by Radhika dereddy on 06/16/2020 this because while exporting the columns to excel the length of Priv_notes field is 214766 for APNO =5179533) and many of more so adding the max length of the excel to accommodate the export.

    UNION ALL
	  SELECT 'SanctionCheck' AS ComponetType, A.*, S.[Description] AS [Component Status],'SanctionCheck' AS [Source], 
	'' AS [Private Notes]
	FROM #tmp AS A WITH (NOLOCK) 
	INNER JOIN MedInteg AS P WITH (NOLOCK) ON A.[Report Number] = P.Apno 
	INNER JOIN SectStat AS S(NOLOCK) ON P.SectStat = S.Code
	WHERE 
	   P.Ishidden = 0 
	  AND A.ApStatus = 'P' 
	  AND P.SectStat IN ('0','9')  


  
	DROP TABLE #tmp


/*
SELECT A.Apno, A.CLNO, C.Name AS Client_Name, A.Last AS LastName, A.First AS FirstName, A.Apdate, A.Reopendate AS ReOpenDate, A.ApStatus,
	   dbo.elapsedbusinessdays_2( A.ApDate,CURRENT_TIMESTAMP) AS Elapsed, A.UserID
FROM Appl A WITH (NOLOCK)
INNER JOIN Client C  WITH (NOLOCK) ON A.Clno = C.Clno
WHERE (A.ApStatus IN ('P','W')) 
  AND A.CLNO NOT IN (2135,3468)
  AND dbo.elapsedbusinessdays_2(A.ApDate,CURRENT_TIMESTAMP) > 5
  AND (@UserID IS NULL OR A.UserID IN (SELECT * from [dbo].[Split](':',@UserID)))
  ORDER BY A.ApDate DESC
*/
