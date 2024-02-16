-- =============================================
-- Author:		DEEPAK VODETHELA
-- Create date: 09/09/2020
-- Description:	Professional License
-- Execution : EXEC [ManualProfRef_Sync]
-- =============================================
CREATE PROCEDURE [ManualProfRef_Sync] 
	-- Add the parameters for the stored procedure here
	@Apno int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT	CT.*
			,A.ApplicantNumber 
		INTO #Ref_CT
	FROM ENTERPRISE.[dbo].ApplicantReference CT 
	INNER JOIN ENTERPRISE.dbo.Applicant A ON CT.ApplicantId = A.ApplicantId
	WHERE ApplicantNumber = @Apno

	SELECT 
		c.ApplicantNumber AS APNO,
		c.ApplicantId AS ApplicantId
		,ReferenceName
		,C.Phone AS	Phone
		,NULL AS [CompanyName]
		,NULL AS JobTitle
		,C.Email AS	Email
		,NULL AS [ReferenceRelation]
		,NULL AS [YearsKnown]
		,C.CreateDate AS CreatedDate
		,0 AS [CreateBy]
		,C.ModifyDate
		,0 AS [ModifyBy]
	INTO #Ref
	 FROM #Ref_CT C

	BEGIN TRAN

		INSERT INTO Precheck.[dbo].[PersRef] 
			( [APNO]
			,SectStat
			,Worksheet
			,[Name]
			,[Phone]
			,[Last_Updated]
			,[CreatedDate]
			,[Email]
			,[JobTitle])
		SELECT 
			S.[APNO]
			,'0'
			,0
			,CONVERT(VARCHAR(25),S.[ReferenceName])
			,CONVERT(VARCHAR(20),S.[Phone])
			,S.ModifyDate
			,S.[CreatedDate]
			,CONVERT(VARCHAR(50),S.[Email])
			,CONVERT(VARCHAR(100),S.[JobTitle])
		FROM Precheck.[dbo].[PersRef] A 
		RIGHT OUTER JOIN #Ref S  ON A.[APNO] = S.[APNO] 
		WHERE A.[APNO] IS NULL

	COMMIT TRAN


	DROP  TABLE #Ref_CT
	DROP TABLE #Ref

END
