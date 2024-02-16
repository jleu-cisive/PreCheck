-- Alter Procedure County_By_DeliveryMethod
-- =============================================
-- Author:		Prasanna	
-- Create date: 01/04/2018
-- Description:	Counties by Delivery Method
-- =============================================
CREATE PROCEDURE [dbo].[County_By_DeliveryMethod]
	-- Add the parameters for the stored procedure here

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

   select distinct cnty.A_County as County,cnty.[State], r.R_Delivery AS  deliverymethod 
   from Crim c(nolock) 
   inner join dbo.TblCounties cnty on c.CNTY_NO = cnty.CNTY_NO
   INNER JOIN dbo.Iris_Researchers AS r(NOLOCK) ON C.vendorid = R.R_id
   WHERE c.IsHidden	 = 0
   ORDER BY cnty.A_County
END
