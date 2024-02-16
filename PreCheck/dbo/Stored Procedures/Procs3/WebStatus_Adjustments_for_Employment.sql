-- =============================================
-- Author:		DEEPAK VODETHELA
-- Requested By:Dana Sangerhausen
-- Create date: 08/21/2017
-- Description:	Measures number of web status changes to a verification (whether pending or closed) in the date parameters entered
-- Execution: EXEC WebStatus_Adjustments_for_Employment '08/21/2017', '08/21/2017'
-- =============================================
CREATE PROCEDURE WebStatus_Adjustments_for_Employment 
	-- Add the parameters for the stored procedure here
	@StartDate DateTime, 
	@EndDate DateTime
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	
	SELECT	E.Apno, E.Employer, E.Investigator, E.InvestigatorAssigned, 
			COUNT(*) OVER (PARTITION BY C.ID) AS [# of WebStatus Changes],  
			W.[description] AS [Current Status], 
			C.ChangeDate AS [Date of Web Status Change], 
			O.[description] AS [WebStatus Changed From], 
			N.[description] AS [WebStatus Changed To], 
			(CASE WHEN LEN(LTRIM(RTRIM(UserID))) <=8 THEN LTRIM(RTRIM(UserID)) ELSE  SUBSTRING(LTRIM(RTRIM(UserID)) ,1 , LEN(LTRIM(RTRIM(UserID))) -5) END) AS [User who made change],
			dbo.elapsedbusinessdays_2(e.InvestigatorAssigned, c.ChangeDate) [Aging of Verification],
			dbo.elapsedbusinessdays_2(e.CreatedDate, c.ChangeDate) [Aging of Report]
	FROM ChangeLog(NOLOCK) AS C
	INNER JOIN Empl AS E(NOLOCK) ON C.ID = E.EmplID
	INNER JOIN Websectstat AS W(NOLOCK) ON E.web_status = W.code
	INNER JOIN Websectstat AS O(NOLOCK) ON C.OldValue = O.code
	INNER JOIN Websectstat AS N(NOLOCK) ON C.NewValue = N.code
	WHERE TableName = 'Empl.web_status'
	  AND ID NOT LIKE '%-%'
	  AND E.IsOnReport = 1
	  AND E.IsHidden = 0
	  AND C.ChangeDate BETWEEN @StartDate AND DATEADD(S,-1,DATEADD(D,1,@EndDate))
	GROUP BY E.Apno, E.Employer, E.Investigator, E.InvestigatorAssigned, C.ID, W.[description], E.web_updated,O.[description],N.[description],C.ChangeDate,
			 (CASE WHEN LEN(LTRIM(RTRIM(UserID))) <=8 THEN LTRIM(RTRIM(UserID)) ELSE  SUBSTRING(LTRIM(RTRIM(UserID)) ,1 , LEN(LTRIM(RTRIM(UserID))) -5) END),
			 dbo.elapsedbusinessdays_2(e.InvestigatorAssigned, c.ChangeDate),
			 dbo.elapsedbusinessdays_2(e.CreatedDate, c.ChangeDate)
	ORDER BY ID ASC, ChangeDate ASC

END
