-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[BISReportDBInsert_ConfigCheck]
	@APNO int
AS
BEGIN
	select c.configurationkey,c.value from appl a left join clientconfiguration c on a.clno = c.clno
 where a.apno = @APNO and c.configurationkey in( 'Redirect_Nevada','OASIS_InProgressStatus');

END
