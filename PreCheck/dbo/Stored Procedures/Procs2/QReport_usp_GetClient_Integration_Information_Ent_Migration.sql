
/************************************************************************************************************

*************************************************************************************************************
Author: Arindam Mitra
Date: 10/25/2023
Purpose: This report shows data for client migrations from Healthcare to Enterprise for ATS adapter. HDT# 110744

***************************************************************************************************************/

/*	
EXEC [dbo].[QReport_usp_GetClient_Integration_Information_Ent_Migration] '09/01/2021', '10/05/2023'
*/

CREATE PROCEDURE [dbo].[QReport_usp_GetClient_Integration_Information_Ent_Migration]
@StartDate date,  
@EndDate date  


AS

BEGIN

	SET NOCOUNT ON       --stop the server from returning a message to the client, reduce network traffic

	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

	

 SELECT cl.Name, cl.CLNO, cl.State, ra.Affiliate,  rc.ClientType, cl.ParentCLNO, cl.WebOrderParentCLNO,  
 COALESCE(cl.password,COALESCE((select password from dbo.client c1 where clno = cl.weborderparentclno),(select password from dbo.client c1 where clno = cl.ParentCLNO)),'Not Set') as [Web Service Password],  
 (select Top 1 EnteredVia from Appl a1 with (nolock) where a1.CLno = cl.CLNO and a1.Apdate IS NOT NULL and cl.IsInactive = 0 and cl.nonclient = 0 ) SubmittedVia, 
 ats.Deliverymethod AS ATS_IntegrationType, ats.ats_name AS ATSName,
 (select Max(a2.Apdate) from Appl a2 with (nolock) where a2.clno = cl.clno and a2.Apdate IS NOT NULL) as [LastDateOfActivity], cl.CAM,   
 (select max(a3.apdate) from Appl a3 with (nolock) where a3.clno = cl.clno and a3.UserID = cl.CAM and a3.Apdate IS NOT NULL) as [CAMAssigned],   
 (select Top 1 Userid from Appl a4 with (nolock) where a4.CLno = cl.CLNO and a4.UserID <> cl.CAM and a4.Apdate IS NOT NULL) as [PriorCAM],   
 (select count(*) from Appl a5 with (nolock) where a5.CLNO = cl.CLNO and cl.IsInactive = 0 and cl.nonclient = 0 and convert(date, a5.ApDate) between convert(date,@StartDate) AND convert(date,@EndDate)) as Volume  
 
 from Client cl
 inner join refaffiliate ra on cl.AffiliateID = ra.AffiliateID  
 left join ats ats on cl.clno = ats.clno  
 left join refclienttype rc with (nolock) on cl.clienttypeid = rc.clienttypeid  
 WHERE cl.IsInactive = 0  and cl.nonclient = 0
 ORDER BY cl.CLNO  
	

	SET NOCOUNT OFF

	SET TRANSACTION ISOLATION LEVEL READ COMMITTED

END


