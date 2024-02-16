
-- =============================================
-- Author:		Doug DeGenaro
-- Create date: 
-- Description:	
-- =============================================
-- =============================================
-- Updated:		Doug DeGenaro
-- Create date: 09/27/2022
-- Description:	Added integration request clno
-- =============================================
CREATE FUNCTION [dbo].[GetIntegrationPartnerRequest] 
(	
	-- Add the parameters for the function here
	@requestId int
)
RETURNS TABLE 
AS
RETURN 
(
	-- Add the SELECT statement with parameter references here
	select 
	r.clno as ParentClno,
	r.RequestId,
	r.UserName,
	r.Partner_Reference,
	r.Partner_Tracking_number,
	r.refuseractionid,
	rfu.UserAction,
	r.RequestDate,
	pc.PartnerCallbackId 
from 
	dbo.Integration_ordermgmt_Request r (nolock) inner join dbo.PartnerCallback pc (nolock) 
	on r.RequestID = IsNull(pc.OrderNumber,0) or isnull(r.Apno,0) = pc.OrderNumber inner join
	dbo.Integration_ordermgmt_refUserAction rfu (nolock) on r.refuseractionid = rfu.refuseractionid
	where pc.PartnerCallbackId = @requestid
)

