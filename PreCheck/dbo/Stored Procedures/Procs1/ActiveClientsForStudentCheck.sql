-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE ActiveClientsForStudentCheck
	-- Add the parameters for the stored procedure here
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	select 'SchoolPay', CLNO, Name, SchoolWillPay, IsInactive  from Client where SchoolWillPay = 1 and IsInactive =0

	UNION ALL

	select 'StudentPay', CLNO, Name, SchoolWillPay, IsInactive  from Client where SchoolWillPay = 0 and IsInactive =0
END
