
CREATE PROCEDURE [dbo].[GetSpecialInstructionsList] (@CLNO int, @Apno int =0 ,@Delimiter varchar(5) = '<BR>')
AS
	
DECLARE @Notes VARCHAR(Max) 
SELECT @Notes = COALESCE(@Notes + @Delimiter, '') + cast(notetext AS varchar(max))
FROM dbo.clientnotes 
WHERE notetype='SI' AND clno =@CLNO

IF isnull(@Apno,0) > 0
	SELECT @Notes = CASE WHEN isnull(Special_instructions,'')='' THEN @Notes ELSE 'Additional Instructions: ' + Special_instructions + @Delimiter + isnull(@Notes,'') end
	FROM dbo.appl 
	WHERE APNO = @Apno

SELECT SI = @Notes


