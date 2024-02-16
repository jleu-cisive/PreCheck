
CREATE PROCEDURE [dbo].[FormNewApplicationCheckSSN]
(
	@clno int = null,
	@ssn varchar(11)
)
AS
DECLARE @ErrorCode int

begin transaction
SET @ErrorCode = @@Error
if(@clno is null OR @clno = 0)
begin
SELECT A.APNO, A.ApDate, A.Last, A.First, A.ApStatus, C.Name
FROM dbo.Appl A INNER JOIN dbo.Client C ON A.CLNO = C.CLNO
WHERE REPLACE(A.SSN,'-','') = REPLACE(@ssn, '-', '')
end
else
begin
SELECT A.APNO, A.ApDate, A.Last, A.First, A.ApStatus, C.Name
FROM dbo.Appl A INNER JOIN dbo.Client C ON A.CLNO = C.CLNO
WHERE REPLACE(A.SSN,'-','') = REPLACE(@ssn, '-', '') and C.CLNO = @clno
end

IF (@ErrorCode<>0)
BEGIN
	RollBack Transaction
	Return (-@ErrorCode)
END
ELSE
	Commit Transaction
