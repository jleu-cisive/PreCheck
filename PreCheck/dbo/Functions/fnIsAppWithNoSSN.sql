-- =============================================
-- Author:		Larry Ouch
-- Create date: 3/06/2023
-- Description:	Function BIT value if APP Contains SSN
-- SELECT * FROM [dbo].[fnIsAppWithNoSSN] (6800981)
-- =============================================
CREATE FUNCTION [dbo].[fnIsAppWithNoSSN]
(
	-- Add the parameters for the function here
	@APNO int
)
RETURNS 
@Applicant TABLE 
(
	HasNoSSN	BIT
)
AS
BEGIN
	INSERT INTO @Applicant
	        (HasNoSSN)
	SELECT HasNoSSN = iif(ISNULL(A.SSN, '') = '', 1, 0) 
	FROM dbo.APPL A
	WHERE A.APNO = @APNO
	RETURN 
END
