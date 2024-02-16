-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE dbo.SelectAllApplicationSections
	-- Add the parameters for the stored procedure here
	@APNO int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT * from appl where apno = @APNO;
	SELECT * FROM empl where apno = @APNO;
	SELECT * FROM educat where apno = @APNO;
	SELECT * FROM DL where apno = @APNO;
	SELECT * FROM PROFLIC WHERE APNO = @APNO;
	SELECT * FROM PERSREF WHERE APNO = @APNO;
	
END
