
/*
Unit Name: sp_Generate_TempPassword
Author Name:Santosh
Date of Creation: 07/17/2014
Brief Description:This Procedure generates a  NEW Temporary Password based of a random number and inserts into the Verifier Table.
OUTPUT values : returns the NEW Temporary Password generated
Date Modified:
Details of Modification:
*/

CREATE PROCEDURE [dbo].[sp_Generate_TempPassword] 
(@VerID varchar(20),
@Email varchar(100),
@CLNO int = null,
@Temp varchar(10) OUTPUT)
AS

BEGIN

	-- Create the variables for the random number generation
	DECLARE @Random int;
	DECLARE @Upper int;
	DECLARE @Lower int
	
	 
	
	-- This will create a random number between 1 and 999
	SET @Lower = 1 -- The lowest random number
	SET @Upper = 999999 -- The highest random number
	SELECT @Random = Round(((@Upper - @Lower -1) * Rand() + @Lower), 0)
	
	SET NOCOUNT ON
	
	--The random number generated concatenated with the letters 'tmp' is the new temporary password....the suffix 'tmp' will prompt the user to change the temporary password...
	--If the suffix is changed, then update the Verifier.asp page BODY tag with the new suffix
	SET @Temp = ltrim(rtrim(@Random)) + 'tmp'
	
	/*UPDATE VERIFIER 
	SET Password = @Temp
	WHERE VERIFIERID = @VerID*/

	--IF @CLNO IS NULL
	--	UPDATE dbo.clientcontacts 
	--	SET UserPassword = @Temp
	--	WHERE Username = @VerID	
	--	AND CLNO = @CLNO
	             
	--ELSE
		UPDATE dbo.clientcontacts 
		SET UserPassword = @Temp
		WHERE (Username = @VerID 	 
		OR   Email = @Email)
		AND CLNO = @CLNO
	             
	
	
	SET NOCOUNT OFF
	
	Return

END
