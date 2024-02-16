-- =============================================
-- Date: July 3, 2001
-- Author: Pat Coffer 
-- added @@identity on 10/5/2013 Radhika Dereddy
-- =============================================
CREATE PROCEDURE [dbo].[CreateInvMaster]
	@Clno smallint,
	@InvDate datetime,
	@InvoiceNumber int OUTPUT ----Radhika dereddy on 10/5/2013
AS
SET NOCOUNT ON
INSERT INTO InvMaster
	(CLNO, InvDate, Sale, Tax)
VALUES
	(@Clno, @InvDate, 0, 0)
SET @InvoiceNumber = @@IDENTITY --Radhika dereddy on 10/5/2013
