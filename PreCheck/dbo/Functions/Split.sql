
CREATE FUNCTION [dbo].[Split](@Delimiter CHAR(1), @StringToBeSplit VARCHAR(MAX))
RETURNS @Results TABLE(Item varchar(8000))
AS
BEGIN
	DECLARE @DelimiterIndex INT
	DECLARE @ItemSplit VARCHAR(100)

	SET @DelimiterIndex=1
	IF @StringToBeSplit IS NULL SET @StringToBeSplit=''
	WHILE @DelimiterIndex!=0
		BEGIN
			IF LEN(@StringToBeSplit)=0 BREAK

			SET @DelimiterIndex=CharIndex(@Delimiter, @StringToBeSplit)
			IF @DelimiterIndex!=0 --FOUND
				BEGIN
					SET @ItemSplit=LEFT(@StringToBeSplit, @DelimiterIndex-1)
					SET @StringToBeSplit=RIGHT(@StringToBeSplit, LEN(@StringToBeSplit)-@DelimiterIndex)
				END
			ELSE 
				SET @ItemSplit=@StringToBeSplit --RECORD LAST ITEM
			INSERT INTO @Results(Item) VALUES(@ItemSplit)
		END
	DELETE FROM @Results WHERE Item IS NULL
	RETURN
END

