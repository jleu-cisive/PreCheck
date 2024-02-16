CREATE PROCEDURE [dbo].[Iris_VendorsAliasNameCountAndSearchVolume] --'11/01/2018','11/04/2018'
	-- Add the parameters for the stored procedure here
	@StartDate Date,
	@EndDate Date
	
AS
SET NOCOUNT ON
BEGIN

Select Distinct APNO, CNTY_NO, vendorid
into #temp_crim_search
from Crim AS C(nolock)
where vendorid is not null
AND    ((Convert(date, C.Crimenteredtime)>= CONVERT(date, @StartDate)) 
AND (Convert(date, C.Crimenteredtime) <= CONVERT(date, @EndDate)))
order by vendorid asc

--select * from #temp_crim_search

--select count(apno) from #temp_crim_search

SELECT IR.R_id AS VendorID, IRC.cnty_no, IR.R_Name AS Vendor, IRC.Researcher_County AS County, IRC.Researcher_State AS State,IRC.Researcher_Aliases_Count AS AliasCount,
IRC.Researcher_Default as preferred,IRC.Researcher_combo as combo , IRC.Researcher_other as other , IRC.Researcher_CourtFees as courtfees, IR.R_Delivery,
(select count(T.APNO) from #temp_crim_search as T where T.vendorid = IR.R_id and T.CNTY_NO = IRC.cnty_no) as 'Total Number of Searches Ordered'
FROM dbo.IRIS_Researchers IR (nolock) INNER JOIN dbo.IRIS_Researcher_Charges IRC ON IR.R_id = IRC.Researcher_ID 
ORDER BY IR.R_Name, IRC.Researcher_County, IRC.Researcher_State, IRC.Researcher_Aliases_Count

drop table #temp_crim_search

END