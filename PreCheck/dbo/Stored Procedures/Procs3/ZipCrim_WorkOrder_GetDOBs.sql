
CREATE PROCEDURE [dbo].[ZipCrim_WorkOrder_GetDOBs]
	@APNO int
AS
BEGIN
	SET NOCOUNT ON;
	SELECT year(a.DOB) AS Year, month(a.DOB) AS Month, day(a.DOB) AS Day, cast(0 as bit) AS IsDeleted FROM dbo.Appl a WHERE a.APNO = @APNO
END
