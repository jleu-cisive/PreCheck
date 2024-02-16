
--Query will use clno and get facility code
-- input parameters will be clno,facility code
-- returns OnHold/null and facility code

CREATE procedure [dbo].[WS_GetClnoByFacility]
@facility varchar(20),
@clno int
as
SET NOCOUNT ON
declare @FacilityCLNO int
--[WS_GetClnoByFacility] '01323',7519
--[WS_GetClnoByFacility] '26774',7519
--set @facility = '00460'
--set @clno = 7519

set @FacilityCLNO = (select distinct FacilityCLNO from HEVN.dbo.Facility WITH (nolock) 
where FacilityNum = @facility and ParentEmployerID = @clno and isactive=1)

if (@FacilityCLNO is  null)
	select @clno as clno
else
	select @FacilityCLNO as clno

SET NOCOUNT OFF
--WS_GetClnoByFacility '00460',7519