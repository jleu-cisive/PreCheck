-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE dbo.BISReportDBInsert_NevadaCheck
	@APNO int
AS
BEGIN
	select c.value from appl a left join clientconfiguration c on a.clno = c.clno
 where a.apno = @APNO and c.configurationkey = 'Redirect_Nevada';

END
