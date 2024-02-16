
/*---------------------------------------------------------------------------------   
This is old single line Query prepared by unknown developer.
Converted into stored procedure on 03/16/2023 by Shashank Bhoi for #84621 change
  
ModifiedBy		ModifiedDate	TicketNo	Description  
Shashank Bhoi	03/16/2023		84621		#84621  include both affiliate 4 (HCA) & 294 (HCA Velocity).   
											EXEC dbo.HCA_CLNO_Process_Level_Mapping 

ModifiedBy - Arindam Mitra
Date - 8/08/2023
HDT# - 104847 Added condition for WebOrderParentCLNO column from client table 

*/---------------------------------------------------------------------------------   
CREATE PROCEDURE [dbo].[HCA_CLNO_Process_Level_Mapping] 
AS 
--Code commenetd by Shashank for ticket id -#84621
--SELECT FacilityNum, FacilityName,  ClientFacilityGroup, FacilityState, FacilityCLNO, IsActive,  Division, IsOneHR 
--FROM HEVN.dbo.Facility (Nolock) WHERE (ParentEmployerID = 7519) order by FacilityCLNO

--Code Added by Shashank for ticket id -#84621
SELECT FacilityNum, FacilityName,  ClientFacilityGroup, FacilityState, FacilityCLNO, IsActive,  Division, IsOneHR 
FROM	HEVN.dbo.Facility				AS F WITH(NOLOCK)
		LEFT JOIN Precheck.dbo.Client	AS C WITH(NOLOCK) ON F.FacilityCLNO = C.CLNO
WHERE	
--(ParentEmployerID = 7519) --Code commented against ticket #104847 

(F.ParentEmployerID = 7519 OR C.WebOrderParentCLNO = 7519) --Code added against ticket #104847
		AND C.AffiliateID IN (4, 294)
ORDER BY FacilityCLNO
