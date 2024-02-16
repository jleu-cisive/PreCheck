


-- =============================================
-- Author:		Kiran Miryala
-- Create date: 07-22-2008
-- Description:	 Pulls Prof License Details for the client in Check Reports
--Modified Date: 02/28/2014
--Modified By: schapyala;
--Modification: Added new fields to the output: NameOnLicense_V,Speciality_V,LifeTime_V,MultiState_V,BoardActions_V,ContactMethod_V,Organization,Contact_Name,Contact_Title,Contact_Date
-- =============================================
CREATE PROCEDURE [dbo].[ClientAccess_AppDetail_pullProfLic]
@profLicID int 
AS
SET NOCOUNT ON


SELECT Lic_type, lic_no,year,expire,state,status,pub_notes
,Lic_Type_V,Lic_No_V,State_V,Year_V,Expire_V,NameOnLicense_V,Speciality_V,LifeTime_V,MultiState_V,BoardActions_V,ContactMethod_V,Organization,Contact_Name,
Contact_Title,Contact_Date
FROM dbo.proflic (NoLock) where proflicid =  @profLicID

SET NOCOUNT OFF
SET ANSI_NULLS ON

