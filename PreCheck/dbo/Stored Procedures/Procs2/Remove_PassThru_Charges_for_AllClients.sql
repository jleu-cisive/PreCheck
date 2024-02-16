-- =============================================
-- Author:		Radhika Dereddy
-- Create date: 07/20/2017
-- Description: Remove_PassThru_Charges_for_AllClients
-- =============================================
CREATE PROCEDURE Remove_PassThru_Charges_for_AllClients
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	Select cc.CLNO, c.Name as ClientName, cc.Value as RemovePassThruCharge
	From ClientConfiguration cc
	inner join Client c on cc.CLNO = c.CLNO
	Where cc.ConfigurationKey ='RemovePassThruCharges' and Value = 'True'
END
