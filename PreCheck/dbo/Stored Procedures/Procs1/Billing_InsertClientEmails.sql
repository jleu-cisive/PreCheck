-- =============================================
-- Author:		Radhika Dereddy
-- Create date: 11/04/2013
-- Description:	Gets the ClientName for a CLNO
-- =============================================
CREATE PROCEDURE [dbo].[Billing_InsertClientEmails] 
	-- Add the parameters for the stored procedure here
	@AccountNumbers varchar(1000),
	@ClientName varchar(3000),
	@Name varchar(1000),
	@Phone varchar(500),
	@Email1 varchar(1000),
	@Email2 varchar(1000)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED


Declare @CNo varchar(100)
Declare @pos int
Declare @acctNo varchar(1000)
SET @acctNo = @AccountNumbers


SET @pos = charindex(',', @AccountNumbers)

WHILE (@pos <> 0)
BEGIN
	SET @CNo = Substring(@AccountNumbers, 1, @pos-1)
	
	INSERT INTO dbo.ClientEmail 
	(AccountNumbers, CLNO, ClientName, Name, Phone, Email1, Email2, CreatedDate)
	VALUES
	(@acctNo, @CNo, @ClientName,@Name, @Phone,@Email1 ,@Email2, GetDate())

	SET @AccountNumbers = Substring(@AccountNumbers, @pos+1, LEN(@AccountNumbers))
	SET @pos = charindex(',', @AccountNumbers)
END
   
SET NOCOUNT OFF
SET TRANSACTION ISOLATION LEVEL READ COMMITTED

END

