-- =============================================
-- Author:		Bernie Chan
-- Create date: 10/23/2014
-- Description:	Change multiple row into one single row for Verification Source Code for a specific employee
-- [GetVerificationSourcesByEmpId_06132015] 5124139
-- =============================================
CREATE PROCEDURE [dbo].[GetVerificationSourcesByEmpId_06132015]
	@Empld int

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

SELECT sectionkeyid, refVerificationSource, verificationsourcecode = STUFF((SELECT ',' + verificationsourcecode
FROM Integration_Verification_SourceCode AS x2 WHERE sectionkeyid = @Empld
ORDER BY sectionkeyid
FOR XML PATH('')), 1, 1, '')
FROM Integration_Verification_SourceCode AS x where verificationsourcecode is not null and verificationsourcecode <> '' AND sectionkeyid = @Empld
GROUP BY sectionkeyid, refVerificationSource
END
