CREATE Procedure [dbo].[CAM_AI_Workbin_With_No_Investigator] 
(
   @CAM varchar(8),
   @EnteredVia varchar(20) 
)
AS 
BEGIN
/* Request for New report HDT #50088
--ReportNumber
--Created Date
--Elapsed (days)
--Elapsed Hours
--Client Number
--Client Name
--Affiliate
--Clients CAM
--Entered via
--Package Description
*/
/*
-- =============================================
-- Author:		Yashan
-- Create date: 6/15/2022
-- Description:	CAMPendingDetails
-- Ref Proc   :  [dbo].[CAMPendingDetails]
-- Exec dbo.CAM_AI_Workbin_With_No_Investigator '',''
-----------------------------------------------------
-- Modified by:	Cameron DeCook
--Removing Enterprise.dbo.[Order] join as it is not needed
-- =============================================
*/
		SELECT 
				A.APNO as [Report Number]
				, A.ApDate as [Create Date]
				, A.ApStatus as [Status]
				, A.Investigator as [Investigator]
				,[dbo].[ElapsedBusinessDays_2](A.ApDate, GETDATE()) AS Elapsed
				,[dbo].[ElapsedBusinessHours_2](A.ApDate, GETDATE()) AS ElapsedHours
				, A.Last as [Last Name]
				, A.First as[First Name]
				, C.CLNO as [Client ID] 
				, C.Name AS Client
				, c.AffiliateID
				, rf.Affiliate
				, ISNULL(A.UserID, C.CAM) AS [Client's CAM] 
				, A.EnteredVia 
				, pm.PackageDesc
				
			FROM dbo.Appl A WITH (NOLOCK)  
				INNER JOIN dbo.Client C WITH (NOLOCK)  ON A.CLNO = C.CLNO
				INNER JOIN refAffiliate rf WITH(NOLOCK) On c.AffiliateID = rf.AffiliateID	
				LEFT JOIN dbo.PackageMain pm ON a.PackageID = pm.PackageID
				
			WHERE 
				A.ApStatus in ('P','W') 
				AND C.CAM = IIF(@CAM='',C.CAM,@CAM) 
				AND A.EnteredVia= IIF(@EnteredVia='',A.EnteredVia,@EnteredVia) 
				And A.Investigator Is Null
			ORDER BY a.APNO DESC

--DROP TABLE IF EXISTS #tmpAppl;

END