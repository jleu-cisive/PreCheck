-- =============================================
-- Author:		DEEPAK VODETHELA
-- Create date: 03/26/2018
-- Description:	Derive ETA [Estimated Time of Arrival] based on Actual TAT [Turnaround Time]
-- Execution: DeriveETAFromTAT
-- Modified By: Deepak Vodethela
-- Modified Date: 06/07/2019 for Req#53080. Add 1 business day for Employment TAT.
-- Modified By: Deepak Vodethela
-- Modified Date: 09/02/2020 - Added "EXEC DeriveETAForVendorReviewedLeads" 
-- Modified By: Jeff Simenc
-- Modified Date: 03/14/2022 - Moved the call to sp AutoExtendETAService to outside of the transaction to
--								stop long running blocking queries
-- =============================================
CREATE PROCEDURE [dbo].[DeriveETAFromTAT]
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	DECLARE @EmploymentTAT int, @EducationTAT int, @ProfessionalLicenseTAT int, @MvrTAT int

	SELECT @EmploymentTAT = TAT FROM ApplSectionsTAT WHERE ApplSectionID = 1
	SELECT @EducationTAT = TAT FROM ApplSectionsTAT WHERE ApplSectionID = 2
	SELECT @ProfessionalLicenseTAT = TAT FROM ApplSectionsTAT WHERE ApplSectionID = 4
	--SELECT @MvrTAT = TAT FROM ApplSectionsTAT WHERE ApplSectionID = 6
	--SELECT @EmploymentTAT AS EmploymentTAT, @EducationTAT AS EducationTAT, @ProfessionalLicenseTAT AS ProfessionalLicenseTAT--, @MvrTAT AS MvrTAT

	DECLARE @tmpETADate TABLE 
	(
		[ApplSectionID] INT,
		APNO INT,
		SectionKeyID INT,
		ETADate Datetime
	)

	-- Employment
	INSERT INTO @tmpETADate
	SELECT	1 AS [ApplSectionID], E.Apno, E.EmplID AS SectionKeyID, 
			CASE WHEN E.CreatedDate > A.ApDate 
				THEN [MainDB].[dbo].[fnGetEstimatedBusinessDate_2](([MainDB].[dbo].[fnGetEstimatedBusinessDate_2](ISNULL(E.CreatedDate,0),ISNULL(@EmploymentTAT,0))),1)
				ELSE ([MainDB].[dbo].[fnGetEstimatedBusinessDate_2](([MainDB].[dbo].[fnGetEstimatedBusinessDate_2](ISNULL(A.ApDate,0),ISNULL(@EmploymentTAT,0))),1))
			END AS ETADate
	FROM Empl AS E(NOLOCK) 
	INNER JOIN Appl AS A(NOLOCK) ON E.Apno = A.Apno
	WHERE E.IsOnReport = 1
	  AND E.SectStat NOT IN ('2','3','4','5') --IN ('0','9')
	  AND A.ApStatus = 'P'
	  AND E.IsHidden = 0
	  AND @EmploymentTAT > 0

	-- Education
	INSERT INTO @tmpETADate
	SELECT	2 AS [ApplSectionID], E.Apno, E.EducatID AS SectionKeyID, 
			CASE WHEN E.CreatedDate > A.ApDate THEN [MainDB].[dbo].[fnGetEstimatedBusinessDate_2](ISNULL(E.CreatedDate,0),ISNULL(@EducationTAT,0))
				ELSE [MainDB].[dbo].[fnGetEstimatedBusinessDate_2](ISNULL(A.ApDate,0),@EducationTAT)
			END AS ETADate
	FROM Educat AS E(NOLOCK) 
	INNER JOIN Appl AS A(NOLOCK) ON E.Apno = A.Apno
	WHERE E.IsOnReport = 1
	  AND E.SectStat NOT IN ('2','3','4','5') --IN ('0','9')
	  AND A.ApStatus = 'P'
	  AND E.IsHidden = 0
	  AND @EducationTAT > 0

	-- Professional License
	INSERT INTO @tmpETADate
	SELECT	4 AS [ApplSectionID], P.Apno, P.ProfLicID AS SectionKeyID, 
			CASE WHEN P.CreatedDate > A.ApDate THEN [MainDB].[dbo].[fnGetEstimatedBusinessDate_2](ISNULL(P.CreatedDate,0),ISNULL(@ProfessionalLicenseTAT,0))
				ELSE [MainDB].[dbo].[fnGetEstimatedBusinessDate_2](ISNULL(A.ApDate,0),@ProfessionalLicenseTAT)
			END AS ETADate
	FROM ProfLic AS P(NOLOCK) 
	INNER JOIN Appl AS A(NOLOCK) ON P.Apno = A.Apno
	WHERE P.IsOnReport = 1
	  AND P.SectStat NOT IN ('2','3','4','5') --IN ('0','9')
	  AND A.ApStatus = 'P'
	  AND P.IsHidden = 0
	  AND @ProfessionalLicenseTAT > 0

	-- MVR
	INSERT INTO @tmpETADate
	SELECT	6 AS [ApplSectionID], M.Apno, 0 AS SectionKeyID, --A.[DL_State] , T.[DLState] AS [DLState],M.CreatedDate , A.ApDate,T.TAT,
			CASE WHEN M.CreatedDate > A.ApDate THEN [MainDB].[dbo].[fnGetEstimatedBusinessDate_2](ISNULL(M.CreatedDate,0),ISNULL(T.TAT,0))
				ELSE [MainDB].[dbo].[fnGetEstimatedBusinessDate_2](ISNULL(A.ApDate,0),NULLIF(T.TAT,0))
			END AS ETADate
	FROM DL AS M(NOLOCK) 
	INNER JOIN Appl AS A(NOLOCK) ON M.Apno = A.Apno
	LEFT OUTER JOIN ApplSectionsTAT AS T(NOLOCK) ON A.[DL_State] = T.[DLState] AND T.ApplSectionID = 6
	WHERE M.SectStat NOT IN ('2','3','4','5') -- IN ('0','9')
	  AND A.ApStatus = 'P'
	  AND M.IsHidden = 0
	  AND T.TAT > 0

	/* VD: 06/05/2018 - Commented to Derive TAT values by State 
	INSERT INTO @tmpETADate
	SELECT	6 AS [ApplSectionID], M.Apno, 0 AS SectionKeyID, 
			CASE WHEN M.CreatedDate > A.ApDate THEN [MainDB].[dbo].[fnGetEstimatedBusinessDate_2](ISNULL(M.CreatedDate,0),ISNULL(@MvrTAT,0))
				ELSE [MainDB].[dbo].[fnGetEstimatedBusinessDate_2](ISNULL(A.ApDate,0),@MvrTAT)
			END AS ETADate
	FROM DL AS M(NOLOCK) 
	INNER JOIN Appl AS A(NOLOCK) ON M.Apno = A.Apno
	WHERE M.SectStat NOT IN ('2','3','4','5') --IN ('0','9')
	  AND A.ApStatus = 'P'
	  AND M.IsHidden = 0
	  AND @MvrTAT > 0
	  --AND A.CLNO IN (SELECT CLNO FROM dbo.ClientConfiguration(NOLOCK) WHERE ConfigurationKey = 'Report_&_Component_ETA_Display_In_Client_Access' AND [Value] = 'True')
	  --AND (E.CreatedDate > CAST(CURRENT_TIMESTAMP AS DATE) OR A.Apdate > CAST(CURRENT_TIMESTAMP AS DATE))
	  --AND CAST(E.APNO AS VARCHAR(20)) + '_' + CAST(E.EducatID AS VARCHAR(20)) NOT IN (SELECT CAST(APNO AS VARCHAR(20)) + '_' + CAST(SectionKeyID AS VARCHAR(20))
			--																		  FROM [dbo].[ApplSectionsETA] 
	*/

	-- Sanction Check (MedInteg)
	INSERT INTO @tmpETADate
	SELECT	7 AS [ApplSectionID], M.Apno, 0 AS SectionKeyID, 
			CASE WHEN M.CreatedDate > A.ApDate THEN [MainDB].[dbo].[fnGetEstimatedBusinessDate_2](ISNULL(M.CreatedDate,0),2)
				ELSE [MainDB].[dbo].[fnGetEstimatedBusinessDate_2](ISNULL(A.ApDate,0),2)
			END AS ETADate
	FROM MedInteg AS M(NOLOCK) 
	INNER JOIN Appl AS A(NOLOCK) ON M.Apno = A.Apno
	WHERE M.SectStat NOT IN ('2','3','4','5') --IN ('0','9')
	  AND A.ApStatus = 'P'
	  AND M.IsHidden = 0

	-- Public Records
	INSERT INTO @tmpETADate
	SELECT  5 AS [ApplSectionID], C.Apno, C.CrimID AS SectionKeyID,
			-- VD:09/11/2018 - The ETA should be calculated from the date the crim goes through order management in IRIS.
			--CASE WHEN C.CrimEnteredTime > A.ApDate THEN [MainDB].[dbo].[fnGetEstimatedBusinessDate_2](ISNULL(C.CrimEnteredTime,0),NULLIF(T.TAT,0))
			--	ELSE [MainDB].[dbo].[fnGetEstimatedBusinessDate_2](ISNULL(A.ApDate,0),NULLIF(T.TAT,0))
			--END AS ETADate
			[MainDB].[dbo].[fnGetEstimatedBusinessDate_2](ISNULL(CAST(C.Ordered AS DATETIME),C.Last_Updated),NULLIF(T.TAT,0)) AS ETADate
			--[MainDB].[dbo].[fnGetEstimatedBusinessDate_2](ISNULL(C.CrimEnteredTime,0) ,NULLIF(T.TAT,0)) AS ETADate
	FROM Crim AS C(NOLOCK)
	INNER JOIN Appl AS A(NOLOCK) ON C.APNO = A.APNO
	LEFT OUTER JOIN ApplSectionsTAT AS T(NOLOCK) ON C.CNTY_NO = T.KeyID AND T.ApplSectionID = 5
	WHERE C.IsHidden = 0
	  --AND C.[Clear] NOT IN ('T','F','P') -- = 'R' -- VD:09/11/2018 - The ETA should be calculated from the date the crim goes through order management in IRIS.
	  AND A.ApStatus = 'P'
	  AND C.[Clear] IN ('O','W')
	  AND T.TAT > 0


	--SELECT * FROM @tmpETADate

	BEGIN TRY
			-- Begin Transaction
			BEGIN TRAN
				/*
				INSERT INTO [dbo].[ApplSectionsETA] ([ApplSectionID], APNO, SectionKeyID, ETADate)
				SELECT  [ApplSectionID],
						APNO,
						SectionKeyID,
						--ETADate,
						--DATENAME(dw, ETADate) AS DayofTheWeek,
						CASE WHEN DATENAME(dw, ETADate) IN ('Saturday') OR ((SELECT [Date] FROM [MainDB].[dbo].[TBLPrecheckHolidays] WHERE [Date] = CAST(ETADate AS DATE)) IS NOT NULL)
								THEN ETADate + 2
							 WHEN DATENAME(dw, ETADate) IN ('Sunday') OR ((SELECT [Date] FROM [MainDB].[dbo].[TBLPrecheckHolidays] WHERE [Date] = CAST(ETADate AS DATE)) IS NOT NULL)
								THEN ETADate + 1
							 ELSE ETADate
						END [FinalETADate]
				FROM @tmpETADate
				*/

				MERGE [dbo].[ApplSectionsETA] AS Target
				USING @tmpETADate AS Source 
				   ON (Target.APNO = Source.APNO AND Target.SectionKeyID = Source.SectionKeyID)
				WHEN NOT MATCHED BY TARGET THEN
				INSERT ([ApplSectionID], APNO, SectionKeyID, ETADate)
				VALUES (Source.[ApplSectionID], Source.APNO, Source.SectionKeyID, Source.ETADate);

				

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

	-- Moved this SP call to the outside of the transaction
	-- Apply +2 days for all the Past and Todays Vendor Reviewed Criminal Records
	EXEC [dbo].[AutoExtendETAService]

	--SELECT * FROM [dbo].[ApplSectionsETA] ORDER BY CreatedDate DESC
END
