  
/***********************************************************************************  
Created By : Doug DeGenaro  
Created On : 08/17/2012  
Name : dbo.WS_CreateSectionsByOrderList  
Parameters: a semicolor seperated order list, and an apno  
Description : creates a record for each section that matches from the orderlist  
**********************************************************************************/  
  
CREATE procedure [dbo].[WS_CreateSectionsByOrderList_08122013](@orderList varchar(max),@apno int)  
as  
  
declare @timestamp datetime  
set @timestamp = CURRENT_TIMESTAMP  
  
  
declare @flag int  
declare @count int  
declare @orderType varchar(50)  
  
set @count = (select count(*) from fn_Split(@orderList,';'));  
set @flag = 0  
while (@flag < @count)  
begin  
 set @orderType = (select value from fn_Split(@orderList,';') where idx = @flag);  
 if @orderType = 'Order_Credit'  
 Begin  
  INSERT Into Credit (APNO,Reptype,Vendor,CreatedDate) VALUES (@apno,'C','U',@timestamp)  
 End  
   
 if @orderType = 'Order_MVR'  
 Begin  
  INSERT Into DL (APNO,CreatedDate) VALUES (@apno,@timestamp)  
 End   
   
 if @orderType = 'Order_MedInteg'  
 Begin  
  INSERT Into MEDINTEG (APNO,CreatedDate) VALUES (@apno,@timestamp)  
 End  
 set @flag = @flag + 1  
end  
  