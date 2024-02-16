
create proc [dbo].[Integration_GetRefUserActionByRequestId](@requestId int)
as
select UserAction from dbo.Integration_OrderMgmt_refUserAction ra inner join dbo.Integration_OrderMgmt_Request r on ra.refUserActionID = r.refUserActionID
where r.RequestID = @requestId 
