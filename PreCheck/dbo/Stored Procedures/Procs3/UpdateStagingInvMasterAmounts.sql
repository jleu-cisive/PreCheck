
-- =============================================
-- Date: 01/09/2014
-- Author: Radhika Dereddy
-- =============================================
CREATE PROCEDURE [dbo].[UpdateStagingInvMasterAmounts]
	@ID int,
	@Sale smallmoney,
	@Tax smallmoney
AS
SET NOCOUNT ON
UPDATE Staging_InvMaster
SET Sale = @Sale,
    Tax = @Tax
WHERE ID = @ID

