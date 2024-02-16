-- =============================================
-- Author:		Radhika Dereddy
-- Create date: 07/18/2017
-- Description:	Clients with Credit Report
-- Modified : removed inline query from qreport table and created a stored proc
-- =============================================
CREATE PROCEDURE Clients_with_Credit_Report
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	Select c.CLNO, C.Name, w.creditreport from WeborderPrefs w
	inner join Client c on w.CLNo = c.Clno
	 where CreditReport = 1

END
