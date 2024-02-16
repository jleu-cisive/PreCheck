-- =============================================
-- Author:           Humera Ahmed
-- Create date: 02/02/2021
-- Description:      HDT #79782 - Can you please create a Q-Report that shows only FCRA submitted orders and the status of that order.
-- EXEC [dbo].[FCRASubmittedOrders] 0,'02/11/2021','02/16/2021'
-- =============================================
CREATE PROCEDURE [dbo].[FCRASubmittedOrders] 
       -- Add the parameters for the stored procedure here
@CLNO int,
@StartDate datetime,
@EndDate datetime
AS
BEGIN
       -- SET NOCOUNT ON added to prevent extra result sets from
       -- interfering with SELECT statements.
       SET NOCOUNT ON;

    -- Insert statements for procedure here
       SELECT 
              so.Clno [Client #]
              , c.Name [Client Name]
              , so.UserName
              , so.FileName 
              , format(so.CreatedDate,'MM/dd/yyyy HH:mm') [CreatedDate]
              , sp.Description
              , so.Status
              , format(so.LastUpdated,'MM/dd/yyyy') [Completed (Reports Returned) Date]
       FROM 
              Precheck_NHDB.dbo.SanctionOrders so WITH (NOLOCK)
              INNER JOIN PRECHECK.dbo.Client c WITH (NOLOCK) ON so.Clno = c.CLNO
              INNER JOIN Precheck_NHDB.dbo.SanctionPackage sp WITH (NOLOCK) ON so.PackageId = sp.SanctionPackageID
       WHERE
              so.Clno = IIF(@CLNO =0, so.Clno, @CLNO)
              AND so.CreatedDate between @StartDate and DateAdd(d,1, @EndDate)
       ORDER BY 
              so.OrderId DESC

END
