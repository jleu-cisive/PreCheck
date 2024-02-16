
-- =============================================
-- Author:		Radhika Dereddy
-- Create date: 12/22/2017
-- Description:	Get PreCheck Challenge ID
-- =============================================
CREATE PROCEDURE [dbo].[Billing_GetPreCheckChallengeID]
	-- Add the parameters for the stored procedure here

AS
BEGIN

SELECT PackageID FROM PackageMain WHERE PackageDesc = 'PrecheckChallenge'

END

