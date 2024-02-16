CREATE procedure [dbo].[zzz_Integration_GetTransformedRequest]
(@clientRefNum varchar(50)= null,@clno int,@apno int = null)
as 
if (@apno is not null)
	select top 1 TransformedRequest from dbo.Integration_OrderMgmt_Request where apno=@apno and clno = @clno order by RequestDate desc
if (@clientRefNum is not null)
	select top 1 TransformedRequest from dbo.Integration_OrderMgmt_Request where partner_reference=@clientRefNum and clno = @clno order by RequestDate desc