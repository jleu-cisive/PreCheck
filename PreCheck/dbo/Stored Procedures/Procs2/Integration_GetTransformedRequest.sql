CREATE procedure [dbo].[Integration_GetTransformedRequest]
(@clientRefNum varchar(50)= null,@clno int = null,@apno int = null)
as 

if (@apno is not null)
	select top 1 TransformedRequest from dbo.Integration_OrderMgmt_Request where apno=@apno order by RequestDate desc--and clno = @clno 
if (@clientRefNum is not null)
	select top 1 TransformedRequest from dbo.Integration_OrderMgmt_Request where partner_reference=@clientRefNum and clno = @clno order by RequestDate desc