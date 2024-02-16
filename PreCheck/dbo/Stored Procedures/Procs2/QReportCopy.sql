-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[QReportCopy]
	-- Add the parameters for the stored procedure here
	(@userold varchar(8),@usernew varchar(8))
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

DECLARE @QueryDesc varchar(300),@Query varchar(1500),@Datatype varchar(300),@ModCount int
DECLARE My_Cursor CURSOR FOR
SELECT QueryDesc,Query,Datatype,ModCount
FROM QReport WHERE UserID = @userold AND QueryDesc = 'View Query Requests'
OPEN My_Cursor;
FETCH NEXT FROM My_Cursor INTO @QueryDesc,@Query,@Datatype,@ModCount;
WHILE @@FETCH_STATUS = 0
   BEGIN
	INSERT INTO QReport(UserID,QueryDesc,Query,Datatype,ModCount) VALUES
(@usernew,@QueryDesc,@Query,@Datatype,@ModCount)
      FETCH NEXT FROM My_Cursor INTO @QueryDesc,@Query,@Datatype,@ModCount;
   END;
CLOSE My_Cursor;
DEALLOCATE My_Cursor;

END

