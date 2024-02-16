CREATE PROCEDURE dbo.FormCrimOnlineInsertUpdateApplPDF
(@CrimApplPDFID int, @APNO int, @NameSearched varchar(150), @PDF image, @IsUpdate bit)
AS
SET NOCOUNT ON

IF @IsUpdate = 0	-- 0 : insert
  INSERT INTO dbo.CrimApplPDF (APNO, NameSearched, PDF) VALUES (@APNO, @NameSearched, @PDF)
ELSE			-- 1 : update
  UPDATE dbo.CrimApplPDF SET PDF = @PDF WHERE CrimApplPDFID = @CrimApplPDFID

SET NOCOUNT OFF
