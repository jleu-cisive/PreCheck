
--select * from [dbo].[GetCandidateOfferByRequestId](8540)
-- =============================================
-- Author:		ddegenaro
-- Create date: 11/01/2011
-- Description:	WS_GetStatus equivalent when there is no apno, created for HCA Offer initiative
-- =============================================
CREATE PROCEDURE [dbo].[GetOrderByRequestId]
(
	@requestid int
)
as 
BEGIN
SELECT 
	r.RequestId as Apno,
	[dbo].[GetIntegrationRequestNodeValue](@requestid,null,'Last') as LAST,
	[dbo].[GetIntegrationRequestNodeValue](@requestid,null,'First') as FIRST,
	[dbo].[GetIntegrationRequestNodeValue](@requestid,null,'Middle') as MIDDLE,
	null as COMPDATE,
	r.RequestDate as APDATE, 
	r.Partner_Reference as CLIENTAPNO,
	GetDate() as LAST_UPDATED,
	r.CLNO as FacilityCLNO,
	[dbo].[GetIntegrationRequestNodeValue](@requestid,null,'Comments') PreCheckComments,
	null as ApStatus,
	r.refUserActionId as RefUserActionid,
	'InProgress' as RefUserAction, -- We always want to set to InProgress even when there is no apno this is for HCA
	tf.ResponseDate as OfferResponseDate,
	tf.OfferTokenId as OfferTokenId,
	tf.EnableOrder as EnableOrder									
FROM 
	dbo.Integration_OrderMgmt_Request r 
INNER JOIN 
	dbo.Integration_OrderMgmt_RefUserAction rua 
ON
	r.refuserActionid = rua.refUserActionID
Inner join 
	[Enterprise].[dbo].[GetCandidateOfferByRequestId](@Requestid) tf 
ON
	r.RequestID = tf.IntegrationRequestId
WHERE 
	r.RequestID = @RequestId
END
