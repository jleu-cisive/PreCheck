
CREATE PROCEDURE [dbo].[ReportsBy_Attentionto]  
   @Attn nvarchar(50)
AS
BEGIN

	select apno as [Report Number], [First], [Last] , Attn, RIGHT(SSN, 4) as SSN,compdate from Appl 
	where [Attn] = SUBSTRING(@Attn, CHARINDEX(',', @Attn) + 2, LEN(@Attn) - CHARINDEX(',', @Attn) + 1)  
	+' ' + SUBSTRING(@Attn, 1, CHARINDEX(',', @Attn) - 1)  
	 and (apdate >='07/01/2014' and apdate <= getdate())

END