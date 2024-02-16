-- Alter Function GetPreCheckCountyFromFIPS

CREATE FUNCTION [dbo].[GetPreCheckCountyFromFIPS] 
	(@FIPS varchar(5), @reportType varchar(20) = NULL)
RETURNS int
WITH EXECUTE AS CALLER
AS
BEGIN
	DECLARE @County int, @CNTY_State varchar(100), @IsStateWide bit;
	
	IF (@reportType = 'ZIPCRIM')
	BEGIN
		SELECT @County =  c.CNTY_NO, @CNTY_State = c.[State], @IsStateWide = c.isStatewide
		FROM dbo.TblCounties c 
		WHERE c.FIPS = @FIPS 
		  AND C.IsActive = 1
		RETURN @County
	END

	SELECT @County =  c.CNTY_NO, @CNTY_State = c.[State], @IsStateWide = c.isStatewide
	FROM dbo.TblCounties c 
	WHERE c.FIPS = @FIPS
	  AND C.IsActive = 1

	IF(@IsStateWide = 1)
	BEGIN
		SELECT @County = c.CNTY_NO 
		FROM dbo.TblCounties c 
		WHERE c.[State] = @CNTY_State 
		  AND c.refCountyTypeID = 2 
		  AND C.IsActive = 1
	END 
	return @County
END
