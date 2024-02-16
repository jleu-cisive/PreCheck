-- =============================================
-- Author: Humera Ahmed
-- Create date: 03/16/2021
-- Description:A new Q-Report that will allow us to identify the immunization tracking order volume and the revenue generated.
-- EXEC [dbo].[ImmunizationTrackingOrderRevenue_Qreport] '03/15/2021','03/16/2021'
-- =============================================
CREATE PROCEDURE [dbo].[ImmunizationTrackingOrderRevenue_Qreport]
       -- Add the parameters for the stored procedure here
       @StartDate datetime,
       @EndDate datetime
AS
BEGIN
       -- SET NOCOUNT ON added to prevent extra result sets from
       -- interfering with SELECT statements.
       SET NOCOUNT ON;

    -- Insert statements for procedure here
       SELECT 
              count(id.InvDetID) [Total Number of StudentCheck Orders]
              , sum(id.Amount) [Total Revenue generated] 
       FROM dbo.InvDetail id (NOLOCK)
       WHERE 
              id.Description LIKE '%Service: Immunization%'
              AND cast(id.CreateDate AS date) BETWEEN @StartDate AND @EndDate
END
