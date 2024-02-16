-- =============================================
-- Author:		DEEPAK VODETHELA	
-- Create date: 09/02/2020
-- Description:	Apply +2 days for all the Past and Todays Vendor Reviewed Reports
-- Execution : EXEC DeriveETAForVendorReviewedLeads
-- =============================================
CREATE PROCEDURE DeriveETAForVendorReviewedLeads
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	-- Variable to add Number of Days to ETADates for all the Pending and Todays Vendor Reviewed Criminal Records
	DECLARE @AddDays int = 2

	CREATE TABLE #tmpVendorReviwedLeads
	(
		APNO INT,
		SectionKeyID INT,
		ApplSectionID INT,
		[ETADate-ASIS] Datetime,
		[ETADate-TOBE] Datetime,
		CNTY_NO INT,
		County Varchar(100),
		CLNO INT,
		ApDate Datetime
	)

	--Index on temp tables
	CREATE CLUSTERED INDEX IX_tmpVendorReviwedLeads_01 ON #tmpVendorReviwedLeads(APNO,SectionKeyID)

	-- Get "Vendor Reviewed", "Ordered" has value and "Not Unused" Criminal Records for "Pending" Reports
	;WITH GetLatestETAPerCounty AS
	(
	SELECT DISTINCT ase.Apno, ase.SectionKeyID, ase.ETADate,c.County, c.CNTY_NO,c.[Clear],A.CLNO, A.ApStatus, A.ApDate
	FROM dbo.ApplSectionsETA ase
	INNER JOIN dbo.Crim c ON ase.SectionKeyID = C.CrimID 
	INNER JOIN Appl AS A(NOLOCK) ON C.APNO = A.APNO
	WHERE ase.ApplSectionID = 5 
	  AND c.IsHidden = 0
	  AND c.Ordered IS NOT NULL
	  AND c.[Clear] = 'V'
	  AND a.ApStatus = 'P'
	  ), --SELECT * FROM GetLatestETAPerCounty
		 -- Get Criminal Records which have "Past" and "Today's" ETADate
	  GetPastAndTodayCriminalRecords AS 
	  (
		SELECT g.Apno, g.SectionKeyID, g.ETADate, g.County, g.CNTY_NO, g.[Clear], g.CLNO, g.ApStatus, g.ApDate
		FROM GetLatestETAPerCounty AS g
		WHERE (CAST(g.ETADate AS DATE) <= CAST(CURRENT_TIMESTAMP AS DATE))
	  ),-- SELECT * FROM GetPastAndTodayCriminalRecords,
	  -- Get Related Juridictions and apply +2 days from Today
	  GetRelatedJuridictions AS 
	  (
		SELECT	C.Apno, c.CrimID AS SectionKeyID, 
				CASE WHEN c.CrimID NOT IN (p.SectionKeyID) THEN NULL ELSE p.ETADate END AS [ETADate-ASIS],
				[MainDB].[dbo].[fnGetEstimatedBusinessDate_2](CAST(CURRENT_TIMESTAMP AS DATE),@AddDays) AS [ETADate-TOBE],
				c.CNTY_NO,c.County,p.CLNO, p.ApDate
		FROM GetPastAndTodayCriminalRecords AS p
		LEFT OUTER JOIN dbo.Crim c ON p.Apno = c.APNO AND p.CNTY_NO = c.CNTY_NO
		WHERE C.IsHidden = 0
		  AND C.[Clear] = 'V'
	  )
	 INSERT INTO #tmpVendorReviwedLeads
	 SELECT DISTINCT r.Apno, r.SectionKeyID, 5 as ApplSectionID, r.[ETADate-ASIS], r.[ETADate-TOBE], r.CNTY_NO, r.County, r.CLNO, r.ApDate
	 FROM GetRelatedJuridictions AS r

	--SELECT * FROM #tmpVendorReviwedLeads

	BEGIN TRY
			-- Begin Transaction
			BEGIN TRAN

				--UPDATE PRIVATE NOTES in Crim Table
				--SELECT c.Priv_Notes
					UPDATE C SET C.Priv_Notes = CAST(CURRENT_TIMESTAMP AS VARCHAR) 
												+ ' : ETAService has updated the ETADate from : ' + ISNULL(CAST(t.[ETADate-ASIS] AS VARCHAR),'')
												+ ' to ETADate Updated: ' + ISNULL(CAST(t. [ETADate-TOBE] AS VARCHAR),'')
												+ ' for the County: ' + ISNULL(t.County,'')
												+ ' , '
												+ ISNULL(C.Priv_Notes,'')
				FROM dbo.Crim AS c
				INNER JOIN #tmpVendorReviwedLeads AS t ON c.CrimID = t.SectionKeyID

				-- Update Or Insert ApplSectionsETA table
				MERGE [dbo].[ApplSectionsETA] AS Target
				USING #tmpVendorReviwedLeads AS Source 
				   ON (Target.APNO = Source.APNO AND Target.SectionKeyID = Source.SectionKeyID)
				WHEN MATCHED THEN
					UPDATE SET Target.ETADate = Source.[ETADate-TOBE]
				WHEN NOT MATCHED BY TARGET THEN
					INSERT ([ApplSectionID], APNO, SectionKeyID, ETADate)
					VALUES (Source.[ApplSectionID], Source.APNO, Source.SectionKeyID, Source.[ETADate-TOBE]);

		-- Save Transaction
		COMMIT TRAN

		END TRY 
	BEGIN CATCH  
		SELECT  
			ERROR_NUMBER() AS ErrorNumber  
			,ERROR_SEVERITY() AS ErrorSeverity  
			,ERROR_STATE() AS ErrorState  
			,ERROR_PROCEDURE() AS ErrorProcedure  
			,ERROR_LINE() AS ErrorLine  
			,ERROR_MESSAGE() AS ErrorMessage;  

		-- Rollback Transaction
		ROLLBACK TRAN;
	END CATCH

	DROP TABLE #tmpVendorReviwedLeads
END
