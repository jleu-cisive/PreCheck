/*
-- Modified By Radhika Dereddy on 09/15/2021 - cast @BatchPrintNumber to varchar(50) and not int
*/
CREATE PROCEDURE [dbo].[Crim_SetBatchStatus]
(@BatchPrintNumber int, @Clear varchar(1), @LockBy varchar(8), @Ordered varchar(20), @IrisOrdered datetime)
AS
SET NOCOUNT ON

UPDATE 	dbo.Crim 
SET 	[Clear] = @Clear
	, IrisFlag = 1
	, Ordered = @Ordered
	, IrisOrdered = @IrisOrdered
WHERE 	CrimID IN (SELECT C.CrimID FROM dbo.Crim C WITH (NOLOCK) INNER JOIN dbo.Appl A WITH (NOLOCK) ON C.APNO = A.APNO
		   WHERE A.InUse = @LockBy AND C.Status = CAST(@BatchPrintNumber as varchar(50)))

SET NOCOUNT OFF
