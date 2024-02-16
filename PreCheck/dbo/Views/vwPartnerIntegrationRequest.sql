create view dbo.vwPartnerIntegrationRequest
as
select 
	r.RequestId,
	r.UserName,
	r.Partner_Reference,
	r.Partner_Tracking_number,
	r.refuseractionid,
	pc.PartnerCallbackId 
from 
	dbo.Integration_ordermgmt_Request r inner join dbo.PartnerCallback pc 
	on r.RequestID = pc.OrderNumber
