-- Alter Procedure Counties_by_DeliveryMethod_With_Volume
-- =============================================
-- Author:		Deepak Vodethela	
-- Create date: 09/27/2018
-- Description:	Counties by DeliveryMethod with volume
-- Execution: EXEC [dbo].[Counties_by_DeliveryMethod_With_Volume] '09/01/2018','09/30/2018','Call_In'
-- =============================================
CREATE PROCEDURE [dbo].[Counties_by_DeliveryMethod_With_Volume]
	-- Add the parameters for the stored procedure here
	--DECLARE
	@StartDate Date,
	@EndDate Date,
	@DeliveryMethod Varchar(100)

	--set @StartDate = '11/01/2020'
	--set @EndDate = '11/10/2020'
	--set @DeliveryMethod = 'Integration'
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

   SELECT DISTINCT cnty.A_County AS County, cnty.[State], r.R_Delivery AS DeliveryMethod,R_Name as VendorName, COUNT(c.CrimID) AS Volume
   from Crim c(nolock) 
   inner join dbo.TblCounties cnty(NOLOCK) on c.CNTY_NO = cnty.CNTY_NO
   INNER JOIN dbo.Iris_Researchers AS r(NOLOCK) ON C.vendorid = R.R_id
   WHERE c.IsHidden = 0
     AND CAST(c.Crimenteredtime as Date) BETWEEN @StartDate AND DATEADD(d,1,@EndDate)
	 AND r.R_Delivery LIKE '%' + @DeliveryMethod + '%'
   GROUP BY cnty.A_County, cnty.[State],r.R_Delivery,R_Name
   ORDER BY cnty.A_County
END
