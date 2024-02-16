-- =============================================
-- Author:		Radhika Dereddy
-- Create date: 02/19/2019
-- Description:	StudetnCheck Immunization Order tracking
-- EXEC [ImmunizationOrders] '01/01/2019','02/01/2019'
-- =============================================
CREATE PROCEDURE [dbo].[ImmunizationOrders]
	-- Add the parameters for the stored procedure here
	@StartDate datetime,
	@EndDate datetime
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

   SELECT v.FirstName, v.LastName, v.MiddleName, v.DateOfBirth, v.Email,v.OrderNumber as [APNO], v.ClientID, C.Name, v.FacilityID, 
   Case when v.HasImmunization = 0 then 'No' else 'Yes' end as Immunization,
   v.CreateDate, v.OrderCreateDate
   FROM [Enterprise].dbo.[vwApplicantOrder] v
   inner join Client C (nolock) on v.CLientId = c.CLNO
   WHERE v.OrderCreateDate between @StartDate and DATEADD(day, 1, @EndDate)
   AND v.HasImmunization = 1
	
END
