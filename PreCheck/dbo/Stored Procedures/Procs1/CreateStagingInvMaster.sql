
-- =============================================
-- Date: 01/09/2014
-- Author: Radhika Dereddy
-- =============================================
CREATE PROCEDURE [dbo].[CreateStagingInvMaster]
	@Clno smallint,
	@InvDate datetime,
	@ID int OUTPUT ----Radhika dereddy on 10/5/2013
AS
SET NOCOUNT ON
INSERT INTO Staging_InvMaster
	(InvoiceNumber, CLNO, Printed, InvDate, Sale, Tax)
VALUES
	(Null, @Clno, 0, @InvDate, 0, 0)
SET @ID = @@IDENTITY --Radhika dereddy on 10/5/2013

