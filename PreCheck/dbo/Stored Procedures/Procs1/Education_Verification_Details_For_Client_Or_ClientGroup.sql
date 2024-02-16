/*---------------------------------------------------------------------------------
Procedure Name : [dbo].[Education_Verification_Details_For_Client_Or_ClientGroup]
Requested By: Dana Sangerhausen
Execution : EXEC [dbo].[Education_Verification_Details_For_Client_Or_ClientGroup] '0','09/01/2017','09/28/2017',0
Modified BY : Radhika Dereddy on 08/08/2017
Modified Description: Added Educate CreatedDate, LastUpdateDate, TAT, Investigator
Modified BY : Radhika Dereddy on 09/06/2017
Modified Description: Added  R.Affiliate, R.AffiliateID
Modified BY : Deepak Vodethela 
Modiofied On: 10/09/2017
Modified Description: Corrected the logic to get all the reports that are changed from “Needs Review” to “Pending”. This is when the reports are live. 
Modified BY : Prasanna on 12/07/2020 HDT#82017 Add Columns to QReport
Execution: EXEC [dbo].[Education_Verification_Details_For_Client_Or_ClientGroup] 2331,'12/01/2017','12/31/2017',0
EXEC [dbo].[Education_Verification_Details_For_Client_Or_ClientGroup] 15392,'11/01/2020','11/30/2020',230
EXEC [dbo].[Education_Verification_Details_For_Client_Or_ClientGroup] '7814:7838:7873:7885','06/01/2018','06/30/2018',4
/* Modified By: Vairavan A
-- Modified Date: 06/30/2022
-- Description: Main Ticketno-53763 
Modify existing q-reports that have affiliate ids in their search parameters
Details: 
Change search parameters for the Affiliate Id field
     * search by multiple affiliate ids (ex 4:297)
     * want to also be able to search all affiliates by putting zero - meaning 0 to search all affiliates
     * multiple affiliates to be separated by a colon  
Under Parameter Names - after Affiliate ID include this wording (separate by colon, default 0)

Subticket id -54476 Update AffiliateID Parameter 130-429
*/
---Testing
/*
EXEC Education_Verification_Details_For_Client_Or_ClientGroup 2331,'12/01/2017','12/31/2017','0'
EXEC Education_Verification_Details_For_Client_Or_ClientGroup 2331,'12/01/2017','12/31/2017','4'
EXEC Education_Verification_Details_For_Client_Or_ClientGroup 0,'12/01/2017','12/31/2017','4:30'
*/
*/---------------------------------------------------------------------------------

CREATE PROCEDURE [dbo].[Education_Verification_Details_For_Client_Or_ClientGroup]
@Clno VARCHAR(MAX) = NULL,
@StartDate DateTime,
@EndDate DateTime,
--@AffiliateID Bigint--code commented by vairavan for ticket id -54476
@AffiliateIDs varchar(MAX) = '0'--code added by vairavan for ticket id -54476
AS
BEGIN

	SET ANSI_WARNINGS OFF 
	SET NOCOUNT ON;
	SET TRANSACTION ISOLATION LEVEL  READ UNCOMMITTED

	IF(@Clno = '' OR LOWER(@Clno) = 'null' OR @Clno = '0'  ) 
	Begin  
		SET @Clno = NULL  
	END

	   --code added by vairavan for ticket id -54476 starts
	IF @AffiliateIDs = '0' 
	BEGIN  
		SET @AffiliateIDs = NULL  
	END
	--code added by vairavan for ticket id -54476 ends

	SELECT	A.APNO, A.ApDate, A.CLNO, C.[Name] AS ClientName, A.[First], A.[Last], E.School, E.From_A , E.To_A, E.Degree_V, ISNULL(E.Contact_Name,'') as [Contact Name], A.Investigator,  
			A.ApDate, CASE WHEN A.ReopenDate = '01/01/1900' THEN '' ELSE A.ReopenDate END as [Report Reopen Date],
			E.CreatedDate as [Education CreatedDate], 
			E.Last_Updated AS [Education LastUpdatedDate], 
			E.web_updated as [Education Received Date],
			dbo.elapsedbusinessdays_2(E.CreatedDate, E.Last_Updated) AS [Education TAT in Days], 
			[dbo].[ElapsedBusinessHours_2](E.CreatedDate, E.Last_Updated) AS [Education TAT in Hours],
			dbo.elapsedbusinessdays_2(A.Apdate, A.origCompDate) AS [Report TAT in Days],
			[dbo].[ElapsedBusinessHours_2](A.Apdate, A.origCompDate) AS [Report TAT in Hours],
			REPLACE(REPLACE(E.Pub_Notes, CHAR(10),';'),CHAR(13),';') AS Pub_Notes, 
			REPLACE(REPLACE(E.Priv_Notes, CHAR(10),';'),CHAR(13),';') AS Priv_Notes, 
			S.[Description] SectStat_Description, 
			REPLACE(REPLACE(R.Affiliate, CHAR(10),';'),CHAR(13),';') AS Affiliate, 
			R.AffiliateID
	FROM dbo.Educat AS E WITH(NOLOCK)
	INNER JOIN dbo.Appl AS A WITH(NOLOCK) ON E.APNO = A.APNO
	INNER JOIN dbo.Client AS C WITH(NOLOCK) ON C.CLNO = A.CLNO
	INNER JOIN dbo.SectStat AS S WITH(NOLOCK) ON S.Code = E.SectStat
	INNER JOIN refAffiliate AS R  WITH(NOLOCK) ON C.AffiliateID = R.AffiliateID
	WHERE E.IsHidden = 0
	  AND E.IsOnReport = 1
	  AND E.SectStat NOT IN ('0','9')
	 -- AND R.AffiliateID = IIF(@AffiliateID = 0, R.AffiliateID, @AffiliateID)--code commented by vairavan for ticket id -54476
	  and (@AffiliateIDs IS NULL OR c.AffiliateID IN (SELECT value FROM fn_Split(@AffiliateIDs,':')))--code added by vairavan for ticket id -54476
	  AND (@CLNO IS NULL OR C.CLNO IN (SELECT VALUE FROM fn_Split(@CLNO,':')))
	  AND apdate between @StartDate and DateAdd(d,1,@EndDate)
	ORDER BY E.CreatedDate




  END

