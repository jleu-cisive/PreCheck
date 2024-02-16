
CREATE PROCEDURE [dbo].[ApplStudentActionFiles] 
(
	@CLNO int
	, @File image
	, @IsAddRecord bit
)
AS
SET NOCOUNT ON

DECLARE @CLNO_School int

--SELECT @CLNO_School = CLNO_School FROM dbo.ClientSchoolHospital WHERE CLNO_Hospital = @CLNO

--IF ISNULL(@CLNO, 0) <> 0
--BEGIN
	INSERT dbo.ApplStudentActionUploadedFiles (CLNO, [DateLoaded], [File], IsAddRecord)
	VALUES (@CLNO, getdate(), @File, @IsAddRecord)
--END

SET NOCOUNT OFF 

set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
