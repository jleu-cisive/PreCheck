-- Alter Procedure Criminal_County_Maintenance
-- =============================================
-- Author:		Dongmei He
-- Create date: 07/17/2017
-- Description:	New Qreport for Criminal COunty Maintenance 
-- Modified By: Radhika Dereddy on 11/7/2018 to add a new column delivery method and VendorName
-- =============================================
CREATE PROCEDURE [dbo].[Criminal_County_Maintenance]
		
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT CC.County, CC.[State], CC.Crim_DefaultRate as [Default Rate], 
	isnull(CC.PassThroughCharge, 0.00) as [Pass Through Charge], r_delivery as [DeliveryMethod],
	r_name as [VendorName], ic.Researcher_Default as [Preferred Vendor]
	FROM dbo.TblCounties CC(nolock)
	INNER JOIN iris_researcher_charges ic(nolock) on CC.CNTY_NO = ic.CNTY_NO
	INNER JOIN iris_researchers r(nolock) on ic.researcher_id = r.r_id   
	WHERE ic.Researcher_county IS NOT NULL
	AND ic.Researcher_Default ='Yes'
	 
END
