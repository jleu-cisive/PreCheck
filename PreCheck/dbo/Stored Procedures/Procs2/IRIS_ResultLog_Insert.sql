-- Alter Procedure IRIS_ResultLog_Insert




CREATE PROCEDURE [dbo].[IRIS_ResultLog_Insert]

(

	@CrimID int

	, @Investigator varchar(20)

	, @Clear varchar(1)

	, @CategoryID int = NULL

)

AS

SET NOCOUNT ON



DECLARE @APNO int

SET @Investigator = SUBSTRING(REPLACE(@Investigator, 'PRECHECK\', ''), 1, 8)



IF @CategoryID IS NULL

BEGIN

	DECLARE @CNTY_NO int, @OldClear varchar(1)



	SELECT @OldClear = Clear, @APNO = APNO FROM dbo.Crim WHERE CrimID = @CrimID

	IF @OldClear = 'V'	--status: VendorReviewed

		SELECT @CategoryID = ResultLogCategoryID FROM dbo.IRIS_ResultLogCategory WHERE ResultLogCategory = 'Website Vendors'

	ELSE

	BEGIN

		SET @CNTY_NO = NULL

		SELECT TOP 1 @CNTY_NO = C2.CNTY_NO

		FROM dbo.Crim C

			INNER JOIN dbo.TblCounties C2 ON C.CNTY_NO = C2.CNTY_NO

				AND C.CrimID = @CrimID

				AND C2.A_County LIKE '%SEX OFFENDER%'



		IF @CNTY_NO IS NULL

			SELECT @CategoryID = ResultLogCategoryID FROM dbo.IRIS_ResultLogCategory WHERE ResultLogCategory = 'Regular Vendors'

		ELSE

			SELECT @CategoryID = ResultLogCategoryID FROM dbo.IRIS_ResultLogCategory WHERE ResultLogCategory = 'Sex Offender'

	END

END



INSERT INTO dbo.IRIS_ResultLog (ResultLogCategoryID, CrimID, APNO, Investigator, LogDate, Clear)

VALUES (@CategoryID, @CrimID, @APNO, @Investigator, getdate(), @Clear)



SET NOCOUNT OFF
