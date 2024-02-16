
-- =============================================
-- Author:		Gaurav
-- Create date: 11/5/2019
-- Description:	Returns count on background completion
-- select [Report].[GetBackgroundCompletion]('2019-2-25','2019-2-26 00:34',7519,11045,'XML')
-- =============================================

CREATE  function [REPORT].[GetBackgroundCompletion](@StartTime SMALLDATETIME,@EndTime SMALLDATETIME, @ClientId INT, @ExcludeFacilityId INT null, @ExcludeSource VARCHAR(10) null)
RETURNS int
AS	
BEGIN
	
	DECLARE @count INT 
	SELECT @count=COUNT(*) FROM dbo.Appl a WITH (NOLOCK)
	INNER JOIN Enterprise.PreCheck.vwClient c WITH (NOLOCK) ON a.CLNO=c.ClientId
	LEFT OUTER JOIN Enterprise.PreCheck.vwApplicantReport AR ON a.APNO=ar.APNO
	WHERE (c.ClientId=ISNULL(@ClientId,c.ClientId) OR c.ParentId=ISNULL(@ClientId,c.ParentId))
	 AND a.EnteredVia <> ISNULL(@ExcludeSource,'')
	AND a.ApStatus='F'
 	AND a.CLNO<> ISNULL(@ExcludeFacilityId,0)
	AND a.OrigCompDate BETWEEN @StartTime AND @EndTime
	AND ar.IntegrationRequestId IS NULL
	RETURN ISNULL(@count,0)
END
