-- =============================================
-- Author:		Radhika Dereddy
-- Create date: 08/09/2017
-- Description:	Get the list of clients which has parent clno
-- =============================================
CREATE PROCEDURE [dbo].[List_of_Clients_with_ParentCLNO] 
	-- Add the parameters for the stored procedure here

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	select C.CLNO, C.Name as ClientName, ParentCLNO = CAST(c.WebOrderParentCLNO AS VARCHAR) + ' - ' + P.Name from Client C
	LEFT JOIN CLient AS P WITH(NOLOCK) on C.WebOrderParentCLNO = P.CLNO
	order by 1 ASC
END
