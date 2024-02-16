



-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[QReport_IrisNoAliasCountCounties]
	-- Add the parameters for the stored procedure here
	@StartDate datetime = null,
	@EndDate datetime = null
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	select rc.researcher_id as VendorID ,r.r_Name as VendorName, rc.researcher_county as CountyName, rc.researcher_state as CountyState, count(c.cnty_no) as SearchNumber 
from Iris_Researcher_Charges rc 
inner join  Iris_Researchers r on rc.researcher_id = r.r_id inner join Crim c on c.cnty_no = rc.cnty_no
 where rc.researcher_Aliases_count = '0' and c.vendorid=rc.researcher_id and c.irisordered between @StartDate and @EndDate 
group by c.cnty_no,rc.researcher_id,r.r_Name,rc.researcher_county,rc.researcher_state order by VendorID


END

