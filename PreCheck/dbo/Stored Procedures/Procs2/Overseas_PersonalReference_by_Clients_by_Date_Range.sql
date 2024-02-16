
-- =============================================
-- Author: Radhika Dereddy
-- Requester: Pam Esquero
-- Create date: 04/02/2020
-- Description:	To find out the overseas personal reference by date range
-- 
/* Modified By: Vairavan A
-- Modified Date: 07/06/2022
-- Description: Ticketno-53763 
Modify existing q-reports that have affiliate ids in their search parameters
Details: 
Change search parameters for the Affiliate Id field
     * search by multiple affiliate ids (ex 4:297)
     * want to also be able to search all affiliates by putting zero - meaning 0 to search all affiliates
     * multiple affiliates to be separated by a colon  
Under Parameter Names - after Affiliate ID include this wording (separate by colon, default 0)

Child ticket id -54481 Update AffiliateID Parameters 971-1053
*/
---Testing
/*
EXEC [dbo].[Overseas_PersonalReference_by_Clients_by_Date_Range] '6/11/2019','6/11/2022' ,'0','0'
EXEC [dbo].[Overseas_PersonalReference_by_Clients_by_Date_Range] '6/11/2019','6/11/2022' ,'0','4'
EXEC [dbo].[Overseas_PersonalReference_by_Clients_by_Date_Range] '6/11/2019','6/11/2022' ,'0','4:8'
*/
-- =============================================
CREATE PROCEDURE [dbo].[Overseas_PersonalReference_by_Clients_by_Date_Range]
	-- Add the parameters for the stored procedure here
	@StartDate DateTime,
	@EndDate DateTime,
	@CLNO VARCHAR(500) = NULL,
	--@AffiliateID int,--code commented by vairavan for ticket id -53763(54481)
    @AffiliateIDs varchar(MAX) = '0'--code added by vairavan for ticket id -53763(54481)
AS
SET NOCOUNT ON


	--code added by vairavan for ticket id -53763 starts
	IF @AffiliateIDs = '0' 
	BEGIN  
		SET @AffiliateIDs = NULL  
	END
	--code added by vairavan for ticket id -53763 ends

	IF(@CLNO = '0' OR @CLNO IS NULL OR @CLNO = 'null')
	BEGIN
		SET @CLNO = ''
	END

	SELECT  A.CLNO AS [Client ID], 
			C.Name AS [Client Name],
			RA.Affiliate,
			CASE WHEN F.IsOneHR = 1 THEN 'True' WHEN F.IsOneHR = 0 THEN 'False' WHEN F.IsOneHR IS Null THEN 'N/A' END AS [IsOneHR], 
			A.Investigator, 
			A.APNO AS [Report Number],
			A.SSN,
			E.Name, 
			A.First AS [First Name], 
			A.Last AS [Last Name], 
			dbo.elapsedbusinessdays_2(A.CreatedDate, A.CompDate) AS Turnaround,  
			dbo.elapsedbusinessdays_2(A.ReopenDate, A.CompDate) AS [ReOpen Turnaround], 
			dbo.elapsedbusinessdays_2(E.CreatedDate, E.Last_Updated) AS [Component TAT], 
			S.[Description] AS [Status], 
			format(A.ApDate,'MM/dd/yyyy hh:mm tt') AS [Received Date], 
			format(A.OrigCompDate,'MM/dd/yyyy hh:mm tt') AS[OriginalClose],
			format(A.CompDate,'MM/dd/yyyy hh:mm tt') AS [Close Date], 
			A.UserID AS CAM,
			e.Investigator AS [Investigator1], 
			CASE WHEN E.IsHidden = 0 THEN 'False' ELSE 'True' END AS [Is Hidden Report],
			CASE WHEN e.IsOnReport = 0 THEN 'False' ELSE 'True' END AS [Is On Report],
			E.Pub_Notes [Public Notes],
			E.PRIV_NOTES AS [Private Notes]
		INTO #tmpOverseas
	FROM dbo.Appl AS A(NOLOCK)
	INNER JOIN dbo.PersRef AS E(NOLOCK) ON A.APNO = E.APNO
	INNER JOIN dbo.SectStat AS S(NOLOCK) ON E.SectStat = S.CODE
	INNER JOIN dbo.Client AS C(NOLOCK) ON A.CLNO = C.CLNO
	INNER JOIN refAffiliate AS RA(NOLOCK) ON C.AffiliateID = RA.AffiliateID
	LEFT JOIN HEVN.dbo.Facility F (NOLOCK) ON isnull(A.DeptCode,0) = F.FacilityNum
	WHERE 
	A.OrigCompDate >= @StartDate  
	  AND A.OrigCompDate < DATEADD(DAY, 1, @EndDate)
	  AND (ISNULL(@CLNO,'') = '' OR A.CLNO IN (SELECT splitdata FROM dbo.fnSplitString(@CLNO,':')))
	 -- AND RA.AffiliateID = IIF(@AffiliateID =0, RA.AffiliateID, @AffiliateID)--code Commented by vairavan for ticket id -53763(54481)
	  and (@AffiliateIDs IS NULL OR RA.AffiliateID IN (SELECT value FROM fn_Split(@AffiliateIDs,':')))--code added by vairavan for ticket id -53763(54481)
	ORDER BY A.CLNO, A.APNO


	SELECT  A.SSN, COUNT(*) NoOfReports 
		into #tmpSSN
	FROM dbo.Appl AS A WITH(NOLOCK) 
	INNER JOIN #tmpOverseas AS O ON A.SSN = O.SSN
	GROUP BY A.SSN
	HAVING COUNT(*) > 1

	SELECT  [Client ID], [Client Name], Affiliate, O.IsOneHR, Investigator, [Report Number],
			 Name, [First Name], [Last Name], 
			 Turnaround,[ReOpen Turnaround],[Component TAT],[Status], [Received Date],
			 [OriginalClose],[Close Date],
			 CAM,[Investigator1],[Is Hidden Report],[Is On Report],
			 [Public Notes],[Private Notes]
	FROM #tmpOverseas AS O
	LEFT OUTER JOIN #tmpSSN AS S ON O.SSN = S.SSN

	

SET NOCOUNT OFF


