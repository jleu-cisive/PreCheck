-- Alter Procedure IRIS_Vendor_List_with_Pricing
-- =============================================
-- Author:		Radhika Dereddy
-- Create date: 03/21/2019
-- Description:	Changing the Qreport inline query to a stored procedure.
-- Modified by Larry Ouch to add CountyID
-- Modified by Radhika - Add the CountyName in the Qreport
-- =============================================
CREATE PROCEDURE dbo.IRIS_Vendor_List_with_Pricing
	-- Add the parameters for the stored procedure here
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

   
SELECT DISTINCT r_id as vendorid,r_name as vendorname,r_delivery, 
ic.Researcher_county, cc.A_County as 'CountyName',ic.Researcher_state R_State_Province , ic.Researcher_combo, 
ic.Researcher_other, ic.Researcher_CourtFees, ic.Researcher_aliases_count, 
ic.Researcher_Default AS 'Preferred Vendor', ic.cnty_no AS 'County ID' 
FROM iris_researcher_charges ic WITH (NOLOCK) 
INNER JOIN  iris_researchers r  WITH (NOLOCK) ON ic.researcher_id = r.r_id   
INNER JOIN  dbo.TblCounties cc WITH(NOLOCK) ON ic.CNTY_NO = cc.CNTY_NO
WHERE ic.Researcher_county is not null 




/* Inline query as below 
select distinct r_id as vendorid,r_name as vendorname,r_delivery, ic.Researcher_county,ic.Researcher_state R_State_Province ,
 ic.Researcher_combo, ic.Researcher_other, ic.Researcher_CourtFees, ic.Researcher_aliases_count, 
 ic.Researcher_Default AS 'Preferred Vendor', ic.cnty_no   AS 'County ID'
from iris_researcher_charges ic with (nolock) inner join   iris_researchers r  with (nolock) on ic.researcher_id = r.r_id   
where ic.Researcher_county is not null
*/
END
