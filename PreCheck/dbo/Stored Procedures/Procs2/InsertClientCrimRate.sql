-- Alter Procedure InsertClientCrimRate

-- =======================================
-- Date: September 30, 2001
-- Author: Pat Coffer
--
-- Inserts a client criminal rate.
-- =======================================
CREATE PROCEDURE dbo.InsertClientCrimRate
	@CLNO smallint,
	@CNTY_NO int,
	@Rate smallmoney
AS
SET NOCOUNT ON

DECLARE @county as Varchar(25)
DECLARE @state as Varchar(25)
DECLARE @country as Varchar(25)
SELECT @county=A_COUNTY,@state=STATE,@country=COUNTRY FROM dbo.TblCounties WHERE CNTY_NO=@CNTY_NO

INSERT INTO ClientCrimRate
	(CLNO, CNTY_NO, Rate,County)
VALUES
	(@CLNO, @CNTY_NO, @Rate,@county+','+@state+','+@country)
