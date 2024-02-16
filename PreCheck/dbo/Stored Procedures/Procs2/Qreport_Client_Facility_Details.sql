-- =============================================
-- Author:		Sahithi
-- Create date: 06/01/2021
-- Description:	Client-Facility-Detail
-- exec [dbo].[Qreport_Client_Facility_Details] 7519
-- =============================================
CREATE PROCEDURE [dbo].[Qreport_Client_Facility_Details]
	-- Add the parameters for the stored procedure here
	 @CLNO int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	if @CLNO<>0
	Begin
SELECT  distinct F.FacilityID,F.FacilityNum,F.ParentEmployerID,F.EmployerID, F.FacilityName,  ClientFacilityGroup,FacilityState, FacilityCLNO, IsActive, Division, IsOneHR ,
case when er.FacilityID is null then 'False'
else 'True' end as [HasEmployeeRecordConstraint]
FROM HEVN.dbo.Facility F (Nolock)  join
  HEVN.dbo.EmployeeRecord er (Nolock) on F.FacilityID=er.FacilityID WHERE (ParentEmployerID = @CLNO) order by FacilityCLNO

 ---- select top 1 * from  HEVN.dbo.EmployeeRecord er

   End
   else if @CLNO=0
   begin
   SELECT distinct F. Facilityid,F.FacilityNum,ParentEmployerID,F.EmployerID, F.FacilityName,  ClientFacilityGroup, FacilityState, FacilityCLNO, IsActive, Division, IsOneHR ,
case when er.FacilityID is null then 'False'
else 'True' end as [HasEmployeeRecordConstraint]
FROM HEVN.dbo.Facility F (Nolock)  join
  HEVN.dbo.EmployeeRecord er (Nolock) on F.FacilityID=er.FacilityID  order by FacilityCLNO
   end
END
