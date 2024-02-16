
CREATE procedure [dbo].[Integration_OrderMgmt_GetAppNoFromPartnerRef]  
(@clno int,  
@clapno varchar(50)= null)  
AS  
if (@clapno is not null)
	Select top 1 apno from Appl where clno=@clno and clientapno=@clapno order by ApDate DESC  

