
-- =============================================
-- Author:		Radhika Dereddy
-- Create date: 10/31/2013
-- Description:	Update ServiceActive to True in WinServiceSchedule
-- Modified by Radhika Dereddy on 06/01/2019 to create the Zero Balance invoice for Advent Health.
-- =============================================
CREATE PROCEDURE [dbo].[Billing_UpdateWinServiceSchedule] 
	-- Add the parameters for the stored procedure here
	@ServiceName varchar(50),
	@ServiceNextRunTime dateTime
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @InvoiceDate Datetime2(3)

	SET @InvoiceDate = (SELECT Max(InvDate) FROM InvMaster)

	EXEC [dbo].[Billing_CreateZeroBalanceInvoices] @InvoiceDate

    -- Insert statements for procedure here
	UPDATE dbo.WinServiceSchedule SET ServiceActive = 'True', ServiceNextRunTime = @ServiceNextRunTime
	WHERE ServiceName = @ServiceName
END

