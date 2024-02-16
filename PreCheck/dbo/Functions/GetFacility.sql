


-- =============================================
-- Author:		Humera Ahmed
-- Create date: 04/11/2022
-- Description:	Function to get all the facilities from HEVN database 
-- =============================================
CREATE FUNCTION [dbo].[GetFacility] 
(	
	-- Add the parameters for the function here
	@ParentEmployerID int,
	@EmployerID int
)
RETURNS TABLE 
AS
RETURN 
(
	-- Add the SELECT statement with parameter references here
	SELECT FacilityID, ParentEmployerID, EmployerID, FacilityNum, FacilityName, DisplayName, Abbreviation, OldName, ClientFacilityGroup, FacilityState, FacilityCLNO, IsActive, FacilityZip, Division, IsOneHR, FacilityRegion,FacilityCollaborator
	FROM  HEVN.dbo.Facility AS f WITH (NOLOCK)
	WHERE 
		f.ParentEmployerID = @ParentEmployerID
		AND f.EmployerID = @EmployerID
)
