-- Alter Procedure ADD_IRIS_TO_COUNTIES

CREATE PROCEDURE dbo.ADD_IRIS_TO_COUNTIES AS

--find list of COUNTY/STATE that exist in IRIS, but not COUNTIES
DECLARE @state as VARCHAR (25)
DECLARE @county as VARCHAR (25)
DECLARE get_next_county CURSOR FAST_FORWARD
 FOR 
	SELECT     STATE, COUNTY
	FROM         Iris_County i
	WHERE     (NOT EXISTS
                          (SELECT     NULL
                            FROM          dbo.TblCounties c
                            WHERE      i.COUNTY = c.a_county))

 OPEN get_next_county
 FETCH NEXT FROM get_next_county INTO @state, @county

WHILE @@FETCH_STATUS = 0
--DECLARE @i as int
--SET @i = 1
--WHILE @i <3
 BEGIN
  INSERT INTO dbo.TblCounties (A_County, State,County,CRIM_DefaultRate) VALUES (@county,@state,'IRIS',16.50)
 FETCH NEXT FROM get_next_county INTO @state, @county
-- SELECT @i = @i + 1
 END

 CLOSE get_next_county
 DEALLOCATE get_next_county
