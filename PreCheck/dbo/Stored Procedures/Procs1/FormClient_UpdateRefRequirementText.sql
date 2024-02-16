

-- ================================================
-- Date: 09/09/2014
-- Author: Prasanna
--
-- FormClient in OASIS to update refRequirementText based on the dropdownlist selection
-- ================================================ 
CREATE PROCEDURE [dbo].[FormClient_UpdateRefRequirementText]
	@CLNO int

AS
SET NOCOUNT ON

UPDATE dbo.refRequirementText
	SET SpecialReg = S.[Description], 
		Civil = CV.[Description], 
		Federal = F.[Description], 
		Statewide = SW.[Description] 
FROM dbo.refRequirementText AS RT WITH(NOLOCK)
INNER JOIN dbo.refStatewide AS SW WITH(NOLOCK) ON SW.StateWideID = RT.StateWideID 
INNER JOIN dbo.refStatewide AS F WITH(NOLOCK) ON F.StateWideID = RT.FederalID
INNER JOIN dbo.refStatewide AS CV WITH(NOLOCK) ON CV.StateWideID = RT.CivilID 
INNER JOIN dbo.refStatewide AS S WITH(NOLOCK) ON S.StateWideID = RT.SpecialRegID
WHERE RT.CLNO = @clno
