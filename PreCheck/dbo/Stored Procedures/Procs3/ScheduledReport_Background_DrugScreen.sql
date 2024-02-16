-- =============================================
-- Author:		Humera Ahmed
-- Create date: 01/28/2022
-- Description:	HDT#32517 - SFTP for UHS - Background and Drug Screen information.
-- Modified by Humera Ahmed on 2/28/2022 for HDT #36168 Update look back range to 180 days
-- Exec PreCheck.[dbo].[ScheduledReport_Background_DrugScreen] 13126
-- =============================================
CREATE PROCEDURE [dbo].[ScheduledReport_Background_DrugScreen]
	-- Add the parameters for the stored procedure here
	@CLNO int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	DROP TABLE IF EXISTS #TempBackground
	DROP TABLE IF EXISTS #TempSSN



	--Background data--
	SELECT 
		'Background' [Type of Verification]
		--, a.First+' '+a.Last [Name]
		,REPLACE(a.First, ',', ' ')+' '+REPLACE(a.Last, ',', ' ') [Name]
		, a.SSN
		, a.ApDate [Create Date]
		, a.CompDate [Complete Date]
	INTO #TempBackground
	FROM Appl a(nolock) 
		INNER JOIN dbo.Client c(nolock) ON a.CLNO = c.CLNO
	WHERE 
		(c.CLNO = @CLNO OR c.WebOrderParentCLNO = @CLNO)
		AND a.ApStatus = 'F' 
		AND a.ApDate >=DATEADD(m, -6, GETDATE())
	ORDER BY a.ApDate ASC

	--Drug Screen data--
	SELECT 
		'Drug Screen' [Type of Verification]
		--, oci.FirstName+' '+oci.LastName [Name]
		,REPLACE(oci.FirstName, ',', ' ')+' '+REPLACE(oci.LastName, ',', ' ') [Name]
		, oci.SSN
		, oci.CreatedDate [Create Date]
		, ord.LastUpdate [Complete Date] 
	INTO #TempSSN
	FROM dbo.OCHS_CandidateInfo oci 
		INNER JOIN dbo.Client c ON oci.CLNO = c.CLNO
		Right JOIN dbo.OCHS_ResultDetails ord ON cast (oci.OCHS_CandidateInfoID AS varchar(20)) = ord.OrderIDOrApno
	WHERE 
	(c.CLNO = @CLNO OR c.WebOrderParentCLNO = @CLNO )
	AND oci.CreatedDate >=DATEADD(m, -6, GETDATE())
	AND ord.OrderStatus = 'Completed'
	AND ord.OrderStatus NOT IN ('x:CancelledRequest')
	ORDER BY oci.CreatedDate

	--Total Data--
	SELECT [Type of Verification]
			, [Name]
			, [SSN]
			, [Create Date]
			, [Complete Date]
	FROM
	(
		SELECT 
			[Type of Verification]
			, [Name]
			, [SSN]
			, [Create Date]
			, [Complete Date]
		 FROM #TempBackground tb 
		UNION all
		SELECT
			[Type of Verification]
			, [Name]
			, [SSN]
			, [Create Date]
			, [Complete Date]
		FROM #TempSSN ts
	) verifications
	ORDER BY [Type of Verification], [Create Date]
END
