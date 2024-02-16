
CREATE FUNCTION [dbo].[GetDateTime](@dateString varchar(50))
RETURNS DateTime
AS
BEGIN

  DECLARE @dateReturn DateTime
  DECLARE @index1 int, @index2 int

  if @dateString = 'present'
	Begin
	 SET @dateReturn = Current_timestamp
	 Return @dateReturn
	end

  SET @dateString = REPLACE(@dateString, '.', '')
  SET @dateString = REPLACE(@dateString, '-', '/')
  SET @index1 = CHARINDEX('/', @dateString)
  IF @index1 = 0
    SET @dateReturn = NULL
  ELSE
  BEGIN
    SET @index2 = CHARINDEX('/', @dateString, @index1 + 1)

    DECLARE @month varchar(3), @day varchar(2), @year varchar(4)
    SET @month = SUBSTRING(@dateString, 1, @index1 - 1)

    IF @index2 = 0
    BEGIN
      SET @year = SUBSTRING(@dateString, @index1 + 1, LEN(@dateString) - @index1)
      SET @day = '01'
    END
    ELSE
    BEGIN
      SET @year = SUBSTRING(@dateString, @index2 + 1, LEN(@dateString) - @index2)
      SET @day = SUBSTRING(@dateString, @index1 + 1, @index2 - @index1 - 1)
    END

    IF ISNUMERIC(@month) = 1 AND ISNUMERIC(@day) = 1 AND ISNUMERIC(@year) = 1 
	 BEGIN  
		
	  IF CAST(@month as int) between 1 and 12 AND CAST(@day as int) between 1 and 31 AND CAST(@year as int) between 1900 and 2100
		BEGIN
      Set @month = CAST(CAST(@month  as int) as varchar)
      SET @dateReturn = CAST(@month  + '/' + @day + '/' + @year AS DateTime)
		END
		ELSE SET @dateReturn = NULL
      END 
    ELSE
      SET @dateReturn = NULL
  END

  RETURN @dateReturn

END



