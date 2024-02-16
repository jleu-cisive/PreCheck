-- =============================================
-- Author:		Bernie Chan
-- Create date: 10/17/2014
-- Description:	Insert company code, empid & verification source into Integration_Verification_SourceCode table
-- Example: exec [dbo].[Insert_Verification_Sourcecodes] 3074371, 'WorkNumber', '11111', '22222', '33333', '44444'
--               SELECT * FROM [PreCheck].[dbo].[Integration_Verification_SourceCode]
-- Modified By: Deepak Vodethela
-- Modified Date: 10/14/2016
-- Description: Added If conditions for @verificationSource, @SourceVerifyType
-- =============================================
CREATE PROCEDURE [dbo].[Insert_Verification_Sourcecodes]

	@empId int,
	@verificationSource varchar(20),
	@verificationSourceCode1 varchar(20),
	@verificationSourceCode2 varchar(20),
	@verificationSourceCode3 varchar(20),
	@verificationSourceCode4 varchar(20),
	@SourceVerifyType varchar(20) = null,
	@SourceVerifyName varchar(100) = null
AS

BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	SET NOCOUNT ON;

	-- Get something likes "Rolodex" OR "WorkNumber" from something like "Rolodex~2~5"
	If (CHARINDEX('~',@verificationSource)> 0)
		SET @verificationSource = SUBSTRING(@verificationSource,1,CHARINDEX('~',@verificationSource)-1)
	
	If (CHARINDEX('~',@SourceVerifyType)> 0)
		SET @SourceVerifyType = SUBSTRING(@SourceVerifyType,1,CHARINDEX('~',@SourceVerifyType)-1)

	if  @SourceVerifyType = '0' SET @SourceVerifyType =  ''

	if  Len(@SourceVerifyName) > 100 SET @SourceVerifyName =  substring(@SourceVerifyName, 0, 99)

	UPDATE [PreCheck].[dbo].[Integration_Verification_SourceCode] SET VerificationSourceCode = '', refVerificationSource = '', IsChecked = 0, SourceVerifyType = '', SourceVerifyName = ''  WHERE SectionKeyID = @empId
	--UPDATE [PreCheck].[dbo].[Integration_Verification_SourceCode] SET VerificationSourceCode = NULL, refVerificationSource = NULL, IsChecked = 0, SourceVerifyType = NULL, SourceVerifyName = NULL  WHERE SectionKeyID = @empId
	--UPDATE [PreCheck].[dbo].[Integration_Verification_SourceCode] SET IsChecked = 0  WHERE SectionKeyID = @empId

	Declare @rowcount int;
	SET @rowcount = @@ROWCOUNT;
	
	IF @rowcount = 0
	BEGIN
		IF @verificationSourceCode1 <> ''
		BEGIN
			INSERT INTO [PreCheck].[dbo].[Integration_Verification_SourceCode] (VerificationSourceCode, SectionKeyID, refVerificationSource, IsChecked, SourceVerifyType, SourceVerifyName)
			VALUES (@verificationSourceCode1, @empId, @verificationSource, 0, @SourceVerifyType, @SourceVerifyName)
		END
		IF @verificationSourceCode2 <> ''
		BEGIN
			INSERT INTO [PreCheck].[dbo].[Integration_Verification_SourceCode] (VerificationSourceCode, SectionKeyID, refVerificationSource, IsChecked, SourceVerifyType, SourceVerifyName)
			VALUES (@verificationSourceCode2, @empId, @verificationSource, 0, @SourceVerifyType, @SourceVerifyName)
		END
		IF @verificationSourceCode3 <> ''
		BEGIN
			INSERT INTO [PreCheck].[dbo].[Integration_Verification_SourceCode] (VerificationSourceCode, SectionKeyID, refVerificationSource, IsChecked, SourceVerifyType, SourceVerifyName)
			VALUES (@verificationSourceCode3, @empId, @verificationSource, 0, @SourceVerifyType, @SourceVerifyName)
		END
		IF @verificationSourceCode4 <> ''
		BEGIN		
			INSERT INTO [PreCheck].[dbo].[Integration_Verification_SourceCode] (VerificationSourceCode, SectionKeyID, refVerificationSource, IsChecked, SourceVerifyType, SourceVerifyName)
			VALUES (@verificationSourceCode4, @empId, @verificationSource, 0, @SourceVerifyType, @SourceVerifyName)
		END
	END

	ELSE IF @rowcount = 1
	BEGIN
		IF @verificationSourceCode1 <> ''
		BEGIN
			UPDATE [PreCheck].[dbo].[Integration_Verification_SourceCode]
				SET VerificationSourceCode = @verificationSourceCode1, refVerificationSource = @verificationSource, SourceVerifyType = @SourceVerifyType, SourceVerifyName = @SourceVerifyName
			WHERE VerificationSourceCodeID in
			(
			SELECT TOP 1 VerificationSourceCodeID FROM
			[PreCheck].[dbo].[Integration_Verification_SourceCode]
			WHERE VerificationSourceCode = '' AND SectionKeyID = @empId
			)
		END
		IF @verificationSourceCode2 <> ''
		BEGIN
			INSERT INTO [PreCheck].[dbo].[Integration_Verification_SourceCode] (VerificationSourceCode, SectionKeyID, refVerificationSource, IsChecked, SourceVerifyType,SourceVerifyName)
			VALUES (@verificationSourceCode2, @empId, @verificationSource, 0, @SourceVerifyType, @SourceVerifyName)
		END
		IF @verificationSourceCode3 <> ''
		BEGIN
			INSERT INTO [PreCheck].[dbo].[Integration_Verification_SourceCode] (VerificationSourceCode, SectionKeyID, refVerificationSource, IsChecked, SourceVerifyType, SourceVerifyName)
			VALUES (@verificationSourceCode3, @empId, @verificationSource, 0, @SourceVerifyType, @SourceVerifyName)
		END
		IF @verificationSourceCode4 <> ''
		BEGIN		
			INSERT INTO [PreCheck].[dbo].[Integration_Verification_SourceCode] (VerificationSourceCode, SectionKeyID, refVerificationSource, IsChecked, SourceVerifyType, SourceVerifyName)
			VALUES (@verificationSourceCode4, @empId, @verificationSource, 0, @SourceVerifyType, @SourceVerifyName)
		END
	END
	
	ELSE IF @rowcount = 2
	BEGIN
		IF @verificationSourceCode1 <> ''
		BEGIN
			UPDATE [PreCheck].[dbo].[Integration_Verification_SourceCode]
				SET VerificationSourceCode = @verificationSourceCode1, refVerificationSource = @verificationSource, SourceVerifyType = @SourceVerifyType, SourceVerifyName = @SourceVerifyName
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
				SET VerificationSourceCode = @verificationSourceCode2, refVerificationSource = @verificationSource, SourceVerifyType = @SourceVerifyType, SourceVerifyName = @SourceVerifyName
			WHERE VerificationSourceCodeID in
			(
			SELECT TOP 1 VerificationSourceCodeID FROM
			[PreCheck].[dbo].[Integration_Verification_SourceCode]
			WHERE VerificationSourceCode = '' AND SectionKeyID = @empId
			)
		END
		IF @verificationSourceCode3 <> ''
		BEGIN
			INSERT INTO [PreCheck].[dbo].[Integration_Verification_SourceCode] (VerificationSourceCode, SectionKeyID, refVerificationSource, IsChecked, SourceVerifyType, SourceVerifyName)
			VALUES (@verificationSourceCode3, @empId, @verificationSource, 0, @SourceVerifyType, @SourceVerifyName)
		END
		IF @verificationSourceCode4 <> ''
		BEGIN		
			INSERT INTO [PreCheck].[dbo].[Integration_Verification_SourceCode] (VerificationSourceCode, SectionKeyID, refVerificationSource, IsChecked, SourceVerifyType, SourceVerifyName)
			VALUES (@verificationSourceCode4, @empId, @verificationSource, 0, @SourceVerifyType, @SourceVerifyName)
		END	
	END

	ELSE IF @rowcount = 3
	BEGIN
		IF @verificationSourceCode1 <> ''
		BEGIN		
			UPDATE [PreCheck].[dbo].[Integration_Verification_SourceCode]
				SET VerificationSourceCode = @verificationSourceCode1, refVerificationSource = @verificationSource, SourceVerifyType = @SourceVerifyType, SourceVerifyName = @SourceVerifyName
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
				SET VerificationSourceCode = @verificationSourceCode2, refVerificationSource = @verificationSource, SourceVerifyType = @SourceVerifyType, SourceVerifyName = @SourceVerifyName
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
				SET VerificationSourceCode = @verificationSourceCode3, refVerificationSource = @verificationSource, SourceVerifyType = @SourceVerifyType, SourceVerifyName = @SourceVerifyName
			WHERE VerificationSourceCodeID in
			(
			SELECT TOP 1 VerificationSourceCodeID FROM
			[PreCheck].[dbo].[Integration_Verification_SourceCode]
			WHERE VerificationSourceCode = '' AND SectionKeyID = @empId
			)
		END
		IF @verificationSourceCode4 <> ''
		BEGIN		
			INSERT INTO [PreCheck].[dbo].[Integration_Verification_SourceCode] (VerificationSourceCode, SectionKeyID, refVerificationSource, IsChecked, SourceVerifyType, SourceVerifyName)
			VALUES (@verificationSourceCode4, @empId, @verificationSource, 0, @SourceVerifyType, @SourceVerifyName)
		END	
	END

	ELSE IF @rowcount = 4
	BEGIN
	    IF @verificationSourceCode1 <> ''
		BEGIN	
			UPDATE [PreCheck].[dbo].[Integration_Verification_SourceCode]
				SET VerificationSourceCode = @verificationSourceCode1, refVerificationSource = @verificationSource, SourceVerifyType = @SourceVerifyType, SourceVerifyName = @SourceVerifyName
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
				SET VerificationSourceCode = @verificationSourceCode2, refVerificationSource = @verificationSource, SourceVerifyType = @SourceVerifyType, SourceVerifyName = @SourceVerifyName
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
				SET VerificationSourceCode = @verificationSourceCode3, refVerificationSource = @verificationSource, SourceVerifyType = @SourceVerifyType, SourceVerifyName = @SourceVerifyName
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
				SET VerificationSourceCode = @verificationSourceCode4, refVerificationSource = @verificationSource, SourceVerifyType = @SourceVerifyType, SourceVerifyName = @SourceVerifyName
			WHERE VerificationSourceCodeID in
			(
			SELECT TOP 1 VerificationSourceCodeID FROM
			[PreCheck].[dbo].[Integration_Verification_SourceCode]
			WHERE VerificationSourceCode = '' AND SectionKeyID = @empId
			)
		END
	END

		DELETE Integration_Verification_SourceCode WHERE VerificationSourceCode = '' AND refVerificationSource = '' AND IsChecked = 0 AND SourceVerifyType = '' AND SourceVerifyName = '' AND SectionKeyID = @empId
END
