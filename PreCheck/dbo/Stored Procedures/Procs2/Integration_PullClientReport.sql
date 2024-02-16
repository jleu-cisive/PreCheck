-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[Integration_PullClientReport]
	-- Add the parameters for the stored procedure here
	@CLIENTAPNO int, @CLNO int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    SELECT TOP 1 backgroundreport from backgroundreports..backgroundreport b inner join appl a on b.apno = a.apno
where a.clientapno = @CLIENTAPNO and a.clno = @CLNO
--and (select count(*) from reportuploadlog (NOLOCK) where reportid = b.backgroundreportid and clno = @CLNO and reporttype = 3) = 0

order by b.createdate desc;


END
