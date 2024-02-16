-- Create Procedure AIMS_Populate_Get_Jobs


-- =============================================
-- Author:		Doug DeGenaro
-- Create date: 10/20/2022
-- Description:	This checks to see if the PID is verified by requestid
-- =============================================
--[dbo].[AIMS_Populate_Get_Jobs] 1
CREATE PROCEDURE [dbo].SP_GetIsVerifiedPIDByRequestId 
(@RequestId int)  
as  
BEGIN  
	declare @count int = 0  
	declare @apno int = 0  
	select @apno = apno from dbo.Integration_OrderMgmt_Request (nolock) where RequestId = @RequestId  
  
	select 
		@count = count(1) 
	from 
		Credit c  (nolock) 
	inner join 
		dbo.SectStat s (nolock) 
	on 
		c.SectStat = s.code 
	where 
		RepType = 'S'  
		and IsVerifyStatus = 1 
		and apno = @apno  
   if (@count = 0)  
	 select cast(0 as bit)  
	else  
	 select cast(1 as bit)  
END