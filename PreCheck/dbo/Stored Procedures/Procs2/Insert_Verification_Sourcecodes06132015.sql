-- =============================================
-- Author:		Bernie Chan
-- Create date: 10/17/2014
-- Description:	Insert company code, empid & verification source into Integration_Verification_SourceCode table
-- Example: exec [dbo].[Insert_Verification_Sourcecodes] 3074371, 'WorkNumber', '11111', '22222', '33333', '44444'
--               SELECT * FROM [PreCheck].[dbo].[Integration_Verification_SourceCode]
-- =============================================
create PROCEDURE [dbo].[Insert_Verification_Sourcecodes06132015]

	@empId int,
	@verificationSource varchar(20),
	@verificationSourceCode1 varchar(20),
	@verificationSourceCode2 varchar(20),
	@verificationSourceCode3 varchar(20),
	@verificationSourceCode4 varchar(20)
AS

BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	SET NOCOUNT ON;

	-- Get something likes "Rolodex" OR "WorkNumber" from something like "Rolodex~2~5"
	SET @verificationSource = SUBSTRING(@verificationSource,1,CHARINDEX('~',@verificationSource)-1)

	UPDATE [PreCheck].[dbo].[Integration_Verification_SourceCode] SET VerificationSourceCode = '', refVerificationSource = '', IsChecked = '' WHERE SectionKeyID = @empId

	Declare @rowcount int;
	SET @rowcount = @@ROWCOUNT;

	IF @rowcount = 0
	BEGIN
		IF @verificationSourceCode1 <> ''
		BEGIN
			INSERT INTO [PreCheck].[dbo].[Integration_Verification_SourceCode] (VerificationSourceCode, SectionKeyID, refVerificationSource, IsChecked)
			VALUES (@verificationSourceCode1, @empId, @verificationSource, '0')
		END
		IF @verificationSourceCode2 <> ''
		BEGIN
			INSERT INTO [PreCheck].[dbo].[Integration_Verification_SourceCode] (VerificationSourceCode, SectionKeyID, refVerificationSource, IsChecked)
			VALUES (@verificationSourceCode2, @empId, @verificationSource, '0')
		END
		IF @verificationSourceCode3 <> ''
		BEGIN
			INSERT INTO [PreCheck].[dbo].[Integration_Verification_SourceCode] (VerificationSourceCode, SectionKeyID, refVerificationSource, IsChecked)
			VALUES (@verificationSourceCode3, @empId, @verificationSource, '0')
		END
		IF @verificationSourceCode4 <> ''
		BEGIN		
			INSERT INTO [PreCheck].[dbo].[Integration_Verification_SourceCode] (VerificationSourceCode, SectionKeyID, refVerificationSource, IsChecked)
			VALUES (@verificationSourceCode4, @empId, @verificationSource, '0')
		END
	END

	ELSE IF @rowcount = 1
	BEGIN
		IF @verificationSourceCode1 <> ''
		BEGIN
			UPDATE [PreCheck].[dbo].[Integration_Verification_SourceCode]
				SET VerificationSourceCode = @verificationSourceCode1, refVerificationSource = @verificationSource
			WHERE VerificationSourceCodeID in
			(
			SELECT TOP 1 VerificationSourceCodeID FROM
			[PreCheck].[dbo].[Integration_Verification_SourceCode]
			WHERE VerificationSourceCode = '' AND SectionKeyID = @empId
			)
		END
		IF @verificationSourceCode2 <> ''
		BEGIN
			INSERT INTO [PreCheck].[dbo].[Integration_Verification_SourceCode] (VerificationSourceCode, SectionKeyID, refVerificationSource, IsChecked)
			VALUES (@verificationSourceCode2, @empId, @verificationSource, '0')
		END
		IF @verificationSourceCode3 <> ''
		BEGIN
			INSERT INTO [PreCheck].[dbo].[Integration_Verification_SourceCode] (VerificationSourceCode, SectionKeyID, refVerificationSource, IsChecked)
			VALUES (@verificationSourceCode3, @empId, @verificationSource, '0')
		END
		IF @verificationSourceCode4 <> ''
		BEGIN		
			INSERT INTO [PreCheck].[dbo].[Integration_Verification_SourceCode] (VerificationSourceCode, SectionKeyID, refVerificationSource, IsChecked)
			VALUES (@verificationSourceCode4, @empId, @verificationSource, '0')
		END
	END
	
	ELSE IF @rowcount = 2
	BEGIN
		IF @verificationSourceCode1 <> ''
		BEGIN
			UPDATE [PreCheck].[dbo].[Integration_Verification_SourceCode]
				SET VerificationSourceCode = @verificationSourceCode1, refVerificationSource = @verificationSource
			WHERE VerificationSourceCodeID in
			(
			SELECT TOP 1 VerificationSourceCodeID FROM
			[PreCheck].[dbo].[Integration_Verification_SourceCode]
			WHERE VerificationSourceCode = '' AND SectionKeyID = @empId
			)
		END
		IF @verificationSourceCode2 <> ''
		BEGIN
			UPDATE [PreCheck].[dbo].[Integration_Verification_SourceCode]
				SET VerificationSourceCode = @verificationSourceCode2, refVerificationSource = @verificationSource
			WHERE VerificationSourceCodeID in
			(
			SELECT TOP 1 VerificationSourceCodeID FROM
			[PreCheck].[dbo].[Integration_Verification_SourceCode]
			WHERE VerificationSourceCode = '' AND SectionKeyID = @empId
			)
		END
		IF @verificationSourceCode3 <> ''
		BEGIN
			INSERT INTO [PreCheck].[dbo].[Integration_Verification_SourceCode] (VerificationSourceCode, SectionKeyID, refVerificationSource, IsChecked)
			VALUES (@verificationSourceCode3, @empId, @verificationSource, '0')
		END
		IF @verificationSourceCode4 <> ''
		BEGIN		
			INSERT INTO [PreCheck].[dbo].[Integration_Verification_SourceCode] (VerificationSourceCode, SectionKeyID, refVerificationSource, IsChecked)
			VALUES (@verificationSourceCode4, @empId, @verificationSource, '0')
		END	
	END

	ELSE IF @rowcount = 3
	BEGIN
		IF @verificationSourceCode1 <> ''
		BEGIN		
			UPDATE [PreCheck].[dbo].[Integration_Verification_SourceCode]
				SET VerificationSourceCode = @verificationSourceCode1, refVerificationSource = @verificationSource
			WHERE VerificationSourceCodeID in
			(
			SELECT TOP 1 VerificationSourceCodeID FROM
			[PreCheck].[dbo].[Integration_Verification_SourceCode]
			WHERE VerificationSourceCode = '' AND SectionKeyID = @empId
			)
		END
		IF @verificationSourceCode2 <> ''
		BEGIN
			UPDATE [PreCheck].[dbo].[Integration_Verification_SourceCode]
				SET VerificationSourceCode = @verificationSourceCode2, refVerificationSource = @verificationSource
			WHERE VerificationSourceCodeID in
			(
			SELECT TOP 1 VerificationSourceCodeID FROM
			[PreCheck].[dbo].[Integration_Verification_SourceCode]
			WHERE VerificationSourceCode = '' AND SectionKeyID = @empId
			)
		END
		IF @verificationSourceCode3 <> ''
		BEGIN		
			UPDATE [PreCheck].[dbo].[Integration_Verification_SourceCode]
				SET VerificationSourceCode = @verificationSourceCode3, refVerificationSource = @verificationSource
			WHERE VerificationSourceCodeID in
			(
			SELECT TOP 1 VerificationSourceCodeID FROM
			[PreCheck].[dbo].[Integration_Verification_SourceCode]
			WHERE VerificationSourceCode = '' AND SectionKeyID = @empId
			)
		END
		IF @verificationSourceCode4 <> ''
		BEGIN		
			INSERT INTO [PreCheck].[dbo].[Integration_Verification_SourceCode] (VerificationSourceCode, SectionKeyID, refVerificationSource, IsChecked)
			VALUES (@verificationSourceCode4, @empId, @verificationSource, '0')
		END	
	END

	ELSE IF @rowcount = 4
	BEGIN
	    IF @verificationSourceCode1 <> ''
		BEGIN	
			UPDATE [PreCheck].[dbo].[Integration_Verification_SourceCode]
				SET VerificationSourceCode = @verificationSourceCode1, refVerificationSource = @verificationSource
			WHERE VerificationSourceCodeID in
			(
			SELECT TOP 1 VerificationSourceCodeID FROM
			[PreCheck].[dbo].[Integration_Verification_SourceCode]
			WHERE VerificationSourceCode = '' AND SectionKeyID = @empId
			)

		END
		IF @verificationSourceCode2 <> ''
		BEGIN
			UPDATE [PreCheck].[dbo].[Integration_Verification_SourceCode]
				SET VerificationSourceCode = @verificationSourceCode2, refVerificationSource = @verificationSource
			WHERE VerificationSourceCodeID in
			(
			SELECT TOP 1 VerificationSourceCodeID FROM
			[PreCheck].[dbo].[Integration_Verification_SourceCode]
			WHERE VerificationSourceCode = '' AND SectionKeyID = @empId
			)
		END
		IF @verificationSourceCode3 <> ''
		BEGIN	
			UPDATE [PreCheck].[dbo].[Integration_Verification_SourceCode]
				SET VerificationSourceCode = @verificationSourceCode3, refVerificationSource = @verificationSource
			WHERE VerificationSourceCodeID in
			(
			SELECT TOP 1 VerificationSourceCodeID FROM
			[PreCheck].[dbo].[Integration_Verification_SourceCode]
			WHERE VerificationSourceCode = '' AND SectionKeyID = @empId
			)
		END
		IF @verificationSourceCode4 <> ''
		BEGIN	
			UPDATE [PreCheck].[dbo].[Integration_Verification_SourceCode]
				SET VerificationSourceCode = @verificationSourceCode4, refVerificationSource = @verificationSource
			WHERE VerificationSourceCodeID in
			(
			SELECT TOP 1 VerificationSourceCodeID FROM
			[PreCheck].[dbo].[Integration_Verification_SourceCode]
			WHERE VerificationSourceCode = '' AND SectionKeyID = @empId
			)
		END
	END
END

	--DECLARE @SourceCodeID1 varchar(10), --for storing the 1st Primary key if the employee exists
	--		@SourceCodeID2 varchar(10), --for storing the 2nd Primary key if the employee exists
	--		@SourceCodeID3 varchar(10), --for storing the 3rd Primary key if the employee exists
	--		@SourceCodeID4 varchar(10)  --for storing the 4th Primary key if the employee exists

	---- Get something likes "Rolodex" OR "WorkNumber" from something like "Rolodex~2~5"
	--SET @verificationSource = SUBSTRING(@verificationSource,1,CHARINDEX('~',@verificationSource)-1)

	--IF EXISTS (SELECT VerificationSourceCodeID FROM [PreCheck].[dbo].[Integration_Verification_SourceCode] WHERE [SectionKeyID] = @empId)
	--	BEGIN
	--		-- Get the consecutive set of 4 unique primary key @SourceCodeID 1, 2, 3 and 4 for later UPDATE use as the WHERE pararmeters
	--		DECLARE @i int = 0
	--		WHILE @i < 5 BEGIN
	--			SET @i = @i + 1
	--			SELECT TOP 1 @SourceCodeID1 = VerificationSourceCodeID FROM [PreCheck].[dbo].[Integration_Verification_SourceCode] WHERE [SectionKeyID] = @empId
	--			SET @SourceCodeID2 = @SourceCodeID1 + 1
	--			SET @SourceCodeID3 = @SourceCodeID2 + 1
	--			SET @SourceCodeID4 = @SourceCodeID3 + 1								
	--		END

	--		UPDATE [PreCheck].[dbo].[Integration_Verification_SourceCode]
	--		SET VerificationSourceCode = @verificationSourceCode1,
	--		SectionKeyID = @empId,
	--		refVerificationSource = @verificationSource,
	--		IsChecked = '0'
	--		WHERE VerificationSourceCodeID = @SourceCodeID1 AND SectionKeyID = @empId
			
	--		UPDATE [PreCheck].[dbo].[Integration_Verification_SourceCode] 
	--		SET VerificationSourceCode = @verificationSourceCode2,
	--		SectionKeyID = @empId,
	--		refVerificationSource = @verificationSource,
	--		IsChecked = '0'
	--		WHERE VerificationSourceCodeID = @SourceCodeID2 AND SectionKeyID = @empId
			
	--		UPDATE [PreCheck].[dbo].[Integration_Verification_SourceCode]
	--		SET VerificationSourceCode = @verificationSourceCode3,
	--		SectionKeyID = @empId,
	--		refVerificationSource = @verificationSource,
	--		IsChecked = '0'
	--		WHERE VerificationSourceCodeID = @SourceCodeID3 AND SectionKeyID = @empId
						
	--		UPDATE [PreCheck].[dbo].[Integration_Verification_SourceCode]
	--		SET VerificationSourceCode = @verificationSourceCode4,
	--		SectionKeyID = @empId,
	--		refVerificationSource = @verificationSource,
	--		IsChecked = '0'
	--		WHERE VerificationSourceCodeID = @SourceCodeID4 AND SectionKeyID = @empId
	--	END
	--ELSE
	--	BEGIN
	--		INSERT INTO [PreCheck].[dbo].[Integration_Verification_SourceCode] (VerificationSourceCode, SectionKeyID, refVerificationSource, IsChecked)
	--		VALUES (@verificationSourceCode1, @empId, @verificationSource, '0')

	--		INSERT INTO [PreCheck].[dbo].[Integration_Verification_SourceCode] (VerificationSourceCode, SectionKeyID, refVerificationSource, IsChecked)
	--		VALUES (@verificationSourceCode2, @empId, @verificationSource, '0')

	--		INSERT INTO [PreCheck].[dbo].[Integration_Verification_SourceCode] (VerificationSourceCode, SectionKeyID, refVerificationSource, IsChecked)
	--		VALUES (@verificationSourceCode3, @empId, @verificationSource, '0')

	--		INSERT INTO [PreCheck].[dbo].[Integration_Verification_SourceCode] (VerificationSourceCode, SectionKeyID, refVerificationSource, IsChecked)
	--		VALUES (@verificationSourceCode4, @empId, @verificationSource, '0')
	--	END
--END