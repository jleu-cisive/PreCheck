-- =============================================
-- Author:		DEEPAK VODETHELA
-- Requested By:Dana Sangerhausen
-- Create date: 08/22/2017
-- Description:	How many background checks we have thus far where the primary applicant name field for Last Name has: 
--				Two distinct last names separated by a space
--				Two distinct names separated by a hyphen (with and without spaces on either side of hyphen)
-- Execution: EXEC Background_Check_LastNames_With_More_Than_One_Word '01/01/2017','12/31/2017'
-- =============================================
CREATE PROCEDURE Background_Check_LastNames_With_More_Than_One_Word
	-- Add the parameters for the stored procedure here
	@StartDate DateTime,
	@EndDate DateTime
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT Apno AS [Report Number], ApDate AS [Report Date], A.CLNO AS [Client Number], C.NAME AS [Client Name], A.Last AS [Last Name]
	FROM Appl AS A(NOLOCK)
	INNER JOIN CLIENT AS C(NOLOCK) ON A.CLNO = C.CLNO
	WHERE (LEN(Last) - LEN(REPLACE(Last , ' ', '')) + 1) > 1 
	  AND (Apdate BETWEEN @StartDate AND DATEADD(d,1,@EndDate))
	  AND ApStatus = 'F'
	ORDER BY ApDate DESC
END
