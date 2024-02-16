
/*
Created By: Deepak Vodethela
Purpose: To get the 'Timezone' based on the Zip, City & State
Execution: SELECT dbo.fnGetTimeZone ('07001',NULL,NULL) AS [TimeZone]
*/

CREATE Function [dbo].[fnGetTimeZone](@Zip varchar(9)=null, @City varchar(50) = null, @state Char(2)=null)
	Returns varchar(20)
As
Begin
Declare @TimeZone varchar(20)

	--Pull TimeZone by Zip if available
	IF ISNULL(@Zip,'') <> ''
		SELECT @TimeZone = [TimeZone]
		FROM [MainDB].[dbo].[ZipCode] WITH(NOLOCK)
		WHERE Zip = @Zip 

	--If ZIP was not provided or Timezone not returned, search by City and State if provided
	IF ISNULL(@City,'') <> ''   and Isnull(@State,'') <> ''  AND @TimeZone IS NULL
		SELECT @TimeZone = [TimeZone]
		FROM [MainDB].[dbo].[ZipCode] WITH(NOLOCK)
		WHERE City = @City AND [State] = @state 

	--If City was not provided or Timezone not returned by City & State search, search by State if provided
	IF ISNULL(@State,'') <> '' AND @TimeZone IS NULL
		SELECT  Top 1 @TimeZone = [TimeZone]
		FROM [MainDB].[dbo].[ZipCode] WITH(NOLOCK)
		WHERE [State] = @State
		GROUP BY [TimeZone]
		ORDER BY COUNT(1) DESC

	--Return TimeZone
	RETURN isnull(@TimeZone,'Central')

End