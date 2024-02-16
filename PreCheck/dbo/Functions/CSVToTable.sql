
-- =============================================
-- Date: 01/09/2014
-- Author: Radhika Dereddy
-- Description:
-- =============================================

CREATE FUNCTION [dbo].[CSVToTable] (@Apno varchar(max))
Returns @TempID Table
(ID int not Null)

AS
BEGIN

SET @Apno = REPLACE(@Apno + ',', ',,',',')
DECLARE @ap int
DECLARE @value varchar(1000)


WHILE PATINDEX('%,%', @Apno) <>0
BEGIN
	SELECT @ap = PATINDEX('%,%', @Apno)
	SELECT @value= LEFT(@Apno, @ap -1)
	SELECT @Apno = STUFF(@Apno, 1, @ap, '')
	INSERt INTO @TempID(ID) Values(@value)
	
END 
  RETURN
END

