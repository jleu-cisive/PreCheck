
-- =============================================
-- Author:		DEEPAK VODETHELA	
-- Create date: 09/02/2020
-- Description:	Apply +2 days for all the Past and Todays Vendor Reviewed Reports
-- Execution : EXEC AutoExtendETAService
-- AmyLiu on 06/24/2022 Optimizing the stored procedure: HDT53025
-- =============================================
CREATE PROCEDURE [dbo].[AutoExtendETAService]
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
		Drop table if exists #GetRelatedJuridictions 
		Drop table if exists #tmpVendorReviwedLeads
		Drop table if exists #tmpAutoExtendETA

	CREATE TABLE #tmpVendorReviwedLeads
	(
		APNO INT,
		SectionKeyID INT,
		ApplSectionID INT,
		[ETADate-ASIS] Datetime,
		[ETADate-TOBE] Datetime,
		County Varchar(100)
	)

		--Index on temp tables
	CREATE CLUSTERED INDEX IX_tmpVendorReviwedLeads_01 ON #tmpVendorReviwedLeads(APNO,SectionKeyID)

	-- Add number of Days
	DECLARE @AddDays int = 2

		SELECT DISTINCT	C.Apno, c.CrimID AS SectionKeyID, -- ase.ETADate,c.CNTY_NO, c.[Clear], c.IsHidden,
		ase.ETADate as [ETADate-ASIS],
		CASE WHEN (CAST(ase.ETADate AS DATE) > (CAST(CURRENT_TIMESTAMP AS DATE))) THEN ase.ETADate
			ELSE [MainDB].[dbo].[fnGetEstimatedBusinessDate_2](CAST(CURRENT_TIMESTAMP AS DATE),@AddDays) 
		END AS [ETADate-TOBE],
		c.County into #GetRelatedJuridictions
		FROM dbo.Crim AS C (NOLOCK) 
		INNER JOIN Appl AS A(NOLOCK) ON C.APNO = A.APNO
		LEFT OUTER JOIN dbo.ApplSectionsETA ase(NOLOCK) ON c.CrimID = ase.SectionKeyID
		WHERE 
		 c.Ordered IS NOT NULL
		  AND a.ApStatus = 'P'
		  AND ISNULL(C.IsHidden,0) = 0
		  AND ISNULL(C.[Clear],'') = 'V'

			INSERT INTO #tmpVendorReviwedLeads
				(APNO, SectionKeyID, ApplSectionID, [ETADate-ASIS], [ETADate-TOBE], County)
			SELECT DISTINCT r.Apno, r.SectionKeyID, 5 as ApplSectionID, r.[ETADate-ASIS], r.[ETADate-TOBE], r.County
			FROM #GetRelatedJuridictions AS r
			WHERE ISNULL(r.[ETADate-ASIS],'01/01/1900') <> r.[ETADate-TOBE]

				-- Table to eliminate duplciates
			CREATE TABLE #tmpAutoExtendETA
			(
				APNO INT,
				SectionKeyID INT,
				ApplSectionID INT,
				[ETADate-TOBE] Datetime
			)
			INSERT INTO #tmpAutoExtendETA
			SELECT DISTINCT r.Apno, r.SectionKeyID, 5 as ApplSectionID, r.[ETADate-TOBE]
			FROM #tmpVendorReviwedLeads AS R

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
						USING #tmpAutoExtendETA AS Source 
						   ON (Target.APNO = Source.APNO AND Target.SectionKeyID = Source.SectionKeyID)
						WHEN MATCHED THEN
							UPDATE SET Target.ETADate = Source.[ETADate-TOBE], Target.UpdateDate = CURRENT_TIMESTAMP, Target.UpdatedBy = 'AutoExtendETAService'
							--WHERE Target.ETADate != Source.[ETADate-TOBE]
						WHEN NOT MATCHED BY TARGET THEN
							INSERT ([ApplSectionID], APNO, SectionKeyID, ETADate, CreatedBy, UpdatedBy)
							VALUES (Source.[ApplSectionID], Source.APNO, Source.SectionKeyID, Source.[ETADate-TOBE], 'AutoExtendETAService', 'AutoExtendETAService');

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

		Drop table if exists #GetRelatedJuridictions 
		Drop table if exists #tmpVendorReviwedLeads
		Drop table if exists #tmpAutoExtendETA



End