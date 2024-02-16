/*
	EXEC [dbo].[GetCrimRecordsByCrimId] 46328429 --34530780
	07/15/2020: 1.) Relaxed the completed status check in the initial query i.e. #tmpCrimResults
	            2.) Added IsHidden = 0 in first conditional check to only qualify active/reportable records
	11/10/2020 : Excluded Clear = 'A' (Cancelled/Internal Error/Incomplete Results) 
    VD:12/21/2020 - TP#92767 - PreCheck: Lead sent to ZipCrim before Review Reportability Service Update. Introduced RefCrimStageID = 4 (Review Reportability Service Completed
	LO:02/15/2023 - Added logic for affiliate 310 - Bon Secours ZC
*/
CREATE PROCEDURE [dbo].[GetCrimRecordsByCrimId]
@crimid int  
as   
	DECLARE @APNO INT
	DECLARE @CNTY_NO INT
	DECLARE @SELECT BIT = 0
	DECLARE @Status varchar(1)

	SELECT @APNO = APNO, @CNTY_NO = CNTY_NO FROM CRIM WHERE CRIMID = @CRIMID

	SELECT APNO, CNTY_NO, [Clear], IsHidden, RefCrimStageID, COUNT(*) AS NumOfRecords
		INTO #tmpCrimResults
	FROM CRIM AS C(NOLOCK)
	WHERE APNO = @APNO 
	  AND CNTY_NO = @CNTY_NO 
	GROUP BY APNO, CNTY_NO, [Clear], IsHidden, RefCrimStageID

	-- SELECT * FROM #tmpCrimResults

	IF ((SELECT COUNT([Clear]) 
		 FROM #tmpCrimResults t 
		 INNER JOIN dbo.Crimsectstat AS s ON t.[Clear] = s.crimsect AND s.ReportedStatus_Integration = 'Completed'
		 INNER JOIN dbo.Appl AS a(NOLOCK) ON t.APNO = a.APNO -- added 2/15/2023
		 INNER JOIN dbo.Client as cl(NOLOCK) on cl.CLNO = a.CLNO -- added 2/15/2023
		 LEFT JOIN dbo.refAffiliate r(NOLOCK) ON r.AffiliateId  = cl.affiliateid -- added 2/15/2023
		 WHERE IsHidden = 0
		   AND t.[Clear] NOT IN ('A')
		   AND (T.RefCrimStageID = 4 OR (T.RefCrimStageID = 2 AND cl.AffiliateId = 310))) --Affiliate: 310 (Bon Secours ZC) 2/15/2023
		   =  (SELECT COUNT([Clear]) FROM #tmpCrimResults WHERE IsHidden = 0))
	BEGIN
		SELECT CRIMID, APNO, COUNTY, [CLEAR], CNTY_NO, [NAME], DOB, SSN, CaseNO, Date_Filed, Degree, Offense, ISNULL(rd.Disposition,C.Disposition) AS Disposition, Sentence, Fine, Disp_Date, Pub_Notes 
		FROM CRIM AS C(NOLOCK)
		INNER JOIN dbo.Crimsectstat AS s ON C.[Clear] = s.crimsect AND s.ReportedStatus_Integration = 'Completed'
		LEFT OUTER JOIN dbo.RefDisposition rd ON  c.RefDispositionID = rd.RefDispositionID AND rd.IsActive = 1
		WHERE APNO = @APNO 
		  AND CNTY_NO = @CNTY_NO 
		  AND ISHIDDEN = 0 
		  AND C.[Clear] NOT IN ('A')
	END
	ELSE
	BEGIN
		SELECT CRIMID, APNO, COUNTY, [CLEAR], CNTY_NO, [NAME], DOB, SSN, CaseNO, Date_Filed, Degree, Offense, Disposition, Sentence, Fine, Disp_Date, Pub_Notes 
		FROM CRIM 
		WHERE 1 = 2
	END

	DROP TABLE #tmpCrimResults

