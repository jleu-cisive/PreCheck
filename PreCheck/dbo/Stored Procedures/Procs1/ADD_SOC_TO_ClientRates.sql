
CREATE PROCEDURE dbo.ADD_SOC_TO_ClientRates AS

--find list of CLNO's that do not have a 'Soc' record
DECLARE @CLNO as int
DECLARE get_next_client_id CURSOR FAST_FORWARD
 FOR 
	SELECT DISTINCT CLNO
	FROM         ClientRates a
	WHERE     (NOT EXISTS
                          (SELECT     NULL
                            FROM          ClientRates c
                            WHERE      (c.RateType = 'SOC') AND (c.CLNO = a.CLNO)))


 OPEN get_next_client_id
 FETCH NEXT FROM get_next_client_id INTO @CLNO

WHILE @@FETCH_STATUS = 0
--DECLARE @i as int
--SET @i = 1
--WHILE @i <4
 BEGIN
  INSERT INTO ClientRates (CLNO, RateType, Rate) VALUES (@CLNO, 'SOC', 5.0)
  FETCH NEXT FROM get_next_client_id INTO @CLNO
 -- SELECT @i = @i + 1
 END

 CLOSE get_next_client_id
 DEALLOCATE get_next_client_id
