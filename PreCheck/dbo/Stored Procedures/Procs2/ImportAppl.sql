CREATE PROCEDURE dbo.ImportAppl
(
	@CLNO int
)
AS
SET NOCOUNT ON

UPDATE dbo.Import SET Name = RTRIM(Name)
UPDATE dbo.Import SET Last = SUBSTRING(Name, 1, CHARINDEX(',', Name) - 1)
	, First = SUBSTRING(Name, CHARINDEX(',', Name) + 2, LEN(Name))
UPDATE dbo.Import SET Middle = CASE WHEN CHARINDEX(' ', First) <> 0 THEN SUBSTRING(First, CHARINDEX(' ', First) + 1, LEN(First)) ELSE NULL END
UPDATE dbo.Import SET First = CASE WHEN CHARINDEX(' ', First) <> 0 THEN SUBSTRING(First, 1, CHARINDEX(' ', First) - 1) ELSE First END

INSERT INTO dbo.Appl (ApStatus, Billed, EnteredBy, ApDate, CLNO, Last, First, Middle, SSN, DOB, InUse, CreatedDate)
SELECT 'P', 0, 'TNGUYEN', getdate(), @CLNO, Last, First, Middle, SSN, DOB, 'TRONG', getdate()
FROM dbo.Import

INSERT INTO dbo.Credit (APNO, Vendor, RepType, Qued, Pulled, SectStat, CreatedDate)
SELECT APNO, 'U', 'S', 0, 1, '0', getdate()
FROM dbo.Appl WHERE InUse = 'TRONG'

INSERT INTO dbo.MedInteg (APNO, SectStat, CreatedDate)
SELECT APNO, '0', getdate()
FROM dbo.Appl WHERE InUse = 'TRONG'

INSERT INTO dbo.Crim (APNO, County, Clear, CNTY_NO, IRIS_REC, CreatedDate)
SELECT APNO, 'Sex Offender, US', NULL, 2480, 'Yes', getdate()
FROM dbo.Appl WHERE InUse = 'TRONG'

UPDATE dbo.Appl SET InUse = NULL WHERE InUse = 'TRONG'

SET NOCOUNT OFF