-- Alter Procedure GetClientCrimRates

-- ================================================
-- Date: September 30, 2001
-- Author: Pat Coffer
--
-- Returns a recordset containing all of the 
-- county criminal rates for a client.
-- ================================================ 
CREATE PROCEDURE dbo.GetClientCrimRates
	@CLNO smallint
AS
SET NOCOUNT ON

--Country, State, A_County needed to get order correct
SELECT a.CNTY_NO, Rate, Country, State, A_County FROM ClientCrimRate a INNER JOIN dbo.TblCounties b ON a.CNTY_NO = b.CNTY_NO 
   WHERE CLNO = @CLNO
    ORDER BY Country, State,  A_County
