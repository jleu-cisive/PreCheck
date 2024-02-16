-- =============================================
-- Author:		Deepak Vodethela
-- Requested by: Milton Robins
-- Description: Qreport that will show the total number of employment records that were passed through The Work Number Automation along with the details
-- Create date: 06/30/2017
-- Execution: EXEC [WorkNumber_To_Automation] '01/26/2023', '02/01/2023'
-- =============================================
-- =============================================
-- Author:		Larry Ouch
-- Requested by: Brian Silver
-- Description: Updated logic to align with the new TALX waterfall process
-- Modify date: 02/01/2023
-- =============================================
CREATE PROCEDURE [dbo].[WorkNumber_To_Automation]
	-- Add the parameters for the stored procedure here
	@StartDate DateTime, 
	@EndDate DateTime
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here

	SELECT	E.Apno, E.Employer AS [Employer Name], S.[Description] AS [Status],W.[description] AS [Web Status], 			
			A.CreatedDate AS [Date],
			IVT.ErrorDetails AS [ITError]
	FROM GetNextAudit AS A (NOLOCK) 
	INNER JOIN Empl AS E(NOLOCK) ON A.EmplID = E.EmplID
	INNER JOIN SectStat AS S(NOLOCK) ON E.SectStat = S.Code
	INNER JOIN Websectstat AS W(NOLOCK) ON E.web_status = W.code
	LEFT JOIN [Integration_Verification_Transaction] IVT (NOLOCK) ON IVT.VerificationDbId = E.EmplID
	WHERE
	  A.CreatedDate BETWEEN @StartDate AND DATEADD(S,-1,DATEADD(D,1,@EndDate))
	  AND A.NewValue = 'TALX'
	  AND A.Description = 'GetNextService'
	ORDER BY A.CreatedDate DESC


END
