-- =============================================
-- Author:		schapyala
-- Create date: 06/06/2012
-- Description:	Returns applicant's residential history based on APNO and/or SSN
-- =============================================
CREATE PROCEDURE [dbo].[GetApplAddressHistory] 
@APNO int, @SSN varchar(20)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED 
	
	IF(Select count(1) FROM dbo.ApplAddress WHERE  APNO = @APNO)>0
		SELECT Address,City, State, Zip, Country, DateStart, DateEnd
		FROM   dbo.ApplAddress
		WHERE  APNO = @APNO
	ELSE
		SELECT Distinct Address,City, State, Zip, Country, DateStart, DateEnd
		FROM   dbo.ApplAddress
		WHERE  SSN = @SSN		
	
	SET TRANSACTION ISOLATION LEVEL READ COMMITTED 


END
