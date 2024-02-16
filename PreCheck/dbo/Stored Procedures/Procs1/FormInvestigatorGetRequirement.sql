CREATE PROCEDURE [dbo].[FormInvestigatorGetRequirement]
(@CLNO int)
AS
SET NOCOUNT ON

SELECT 	TOP 1
	ISNULL(R1.NumOfRecord, 0) AS EmplNumOfRecord
	, ISNULL(R1.TimeSpan, 0) AS EmplTimeSpan
	, ISNULL(R1.IsSeeNotes, 0) AS EmplSeeNotes
	, ISNULL(R1.IsMostRecent, 0) AS EmplMostRecent
	, ISNULL(R1.IsOrdered, 0) AS EmplIsOrdered
	, ISNULL(R2.NumOfRecord, 0) AS CrimNumOfRecord
	, ISNULL(R2.TimeSpan, 0) AS CrimTimeSpan
	, ISNULL(R2.IsCalled, 0) AS CrimCalled
	, ISNULL(R2.IsOrdered, 0) AS CrimIsOrdered
	, ISNULL(R2.IsSeeNotes, 0) AS CrimSeeNotes
	, ISNULL(R3.LevelNum, 0) AS EducatLevel
	, ISNULL(R3.IsSeeNotes, 0) AS EducatSeeNotes
	, ISNULL(R3.IsHighestCompleted, 0) AS EducatHighestCompleted
	, ISNULL(R3.IsHighSchool, 0) AS EducatHighSchool
	, ISNULL(R3.IsCollege, 0) AS EducatCollege
	, ISNULL(R3.IsOrdered, 0) AS EducatIsOrdered
	, ISNULL(R3.IsHCA, 0) AS EducatHCA
	, R4.SpecialNote AS LicenseSpecialNote
	, ISNULL(R4.LevelNum, 0) AS LicenseLevel
	, ISNULL(R4.IsHCA, 0) AS LicenseHCA
	, ISNULL(R4.IsSeeNotes, 0) AS LicenseSeeNotes
	, ISNULL(R4.IsOrdered, 0) AS LicenseIsOrdered
	, C.PersonalRefNotes
	, RT.ProfRef
	, RT.DOT
	--, RT.SpecialReg
	--, RT.Civil
	--, RT.Federal
	--, RT.Statewide
	, S.[Description] SpecialReg
	, CV.[Description] Civil
	, F.[Description] Federal
	, SW.[Description] Statewide
	, CN.CreditNotes
	, C.MVR
FROM dbo.Client C WITH (NOLOCK)
	LEFT JOIN dbo.refRequirement R1 WITH (NOLOCK)
	ON C.CLNO = R1.CLNO AND R1.RecordType = 'empl'
	LEFT JOIN dbo.refRequirement R2 WITH (NOLOCK)
	ON C.CLNO = R2.CLNO AND R2.RecordType = 'crim'
	LEFT JOIN dbo.refRequirement R3 WITH (NOLOCK)
	ON C.CLNO = R3.CLNO AND R3.RecordType = 'educat'
	LEFT JOIN dbo.refRequirement R4 WITH (NOLOCK)
	ON C.CLNO = R4.CLNO AND R4.RecordType = 'proflic'
	LEFT JOIN dbo.refRequirementText RT WITH (NOLOCK)
	ON C.CLNO = RT.CLNO
	-- Start - Deepak and Prasanna 09/10/2014 -> Added to get the right referenced values based on ID
	LEFT JOIN dbo.refStatewide SW WITH(NOLOCK) ON SW.StateWideID = RT.StateWideID
	LEFT JOIN dbo.refStatewide F WITH(NOLOCK) ON F.StateWideID = RT.FederalID
	LEFT JOIN dbo.refStatewide CV WITH(NOLOCK) ON CV.StateWideID = RT.CivilID 
	LEFT JOIN dbo.refStatewide S WITH(NOLOCK) ON S.StateWideID = RT.SpecialRegID
	-- End -
	LEFT JOIN dbo.refCreditNotes CN WITH (NOLOCK)
	ON C.CreditNotesID = CN.CreditNotesID
WHERE C.CLNO = @CLNO

SET NOCOUNT OFF
