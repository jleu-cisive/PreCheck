  
/***********************************************************************************  
Created By : Doug DeGenaro  
Created On : 08/17/2012  
Name : dbo.WS_CreateSectionsByOrderList  
Parameters: a semicolor seperated order list, and an apno  
Description : creates a record for each section that matches from the orderlist  
**********************************************************************************/  
  
CREATE procedure [dbo].[WS_CreateSectionsByOrderList](@orderList varchar(max),@apno int,@userName varchar(20) = null)  
as  
declare @crimid int  
declare @currentDate datetime  
  
set @currentDate = CURRENT_TIMESTAMP  
if (charindex('Order_Credit',@orderList) > 0)    
   BEGIN    
     IF (SELECT count(apno) FROM dbo.Credit WHERE apno = @apno and RepType='C') = 0    
		 BEGIN
			Declare @msg nvarchar(500), @Sub nvarchar(200),@EnteredBy varchar(20)

 			Select @EnteredBy = EnteredBy, @msg = 'This is to inform you that Client:  ' + cast(Name as nvarchar)+ '(' + cast(A.CLNO as nvarchar) + ') requires/requested Credit to be ordered for Report# ' + cast(@apno as varchar) + '; ' + char(9) + char(13)+ char(9) + char(13) +   'Applicant: ' + A.First + ' ' + A.Last  + char(9) + char(13)+ char(9) + char(13) +   'Thank you.'
			From DBO.APPL A inner join DBO.Client C on A.CLNO = C.CLNO
			Where APNO = @apno

			Set @Sub = 'Credit Requested For Report# ' + cast(@apno as varchar) + '; Requested By: ' + isnull(@userName,@EnteredBy)

			EXEC msdb.dbo.sp_send_dbmail    @from_address=N'CreditReports@PreCheck.com', @recipients=N'CreditReports@PreCheck.com', @subject= @Sub,   @body=@msg ;

			  Insert into     
			   dbo.Credit     
			  ([APNO],[SectStat],CreatedDate,Vendor,RepType)    
			  values     
			   (@apno,'0',@currentDate,'U','C')  
		 END	     
  
   END    
       
 if (charindex('Order_USFederal',@orderList) > 0)    
 BEGIN    
   declare @cno int    
   set @cno = 2738    
   IF (SELECT count(apno) FROM dbo.Crim WHERE apno = @apno and CNTY_NO = @cno) = 0     
   Begin    
    exec dbo.CreateCrim @apno,@cno,@crimid OUTPUT
    if (select count(1) from dbo.Crim where Crimid = @crimid) = 0
			set @crimid = (select top 1 crimid from dbo.crim where apno = @apno and cnty_no = @cno order by crimenteredtime desc)     
    update dbo.Crim set Clear = 'R' where CrimId = @crimid       
   End    
    --Insert into dbo.Crim    
    -- ([APNO],CNTY_NO,CreatedDate)    
    --values     
    -- (@apno,@cno,CURRENT_TIMESTAMP)    
 END     
     
 if (charindex('Order_FedBankruptcy',@orderList) > 0)    
 BEGIN    
   --declare @cno int    
   set @cno = 229    
   IF (SELECT count(apno) FROM dbo.Crim WHERE apno = @apno and CNTY_NO = @cno) = 0     
   Begin    
    exec dbo.CreateCrim @apno,@cno,@crimid OUTPUT
		if (select count(1) from dbo.Crim where Crimid = @crimid) = 0
			set @crimid = (select top 1 crimid from dbo.crim where apno = @apno and cnty_no = @cno order by crimenteredtime desc)     
    update dbo.Crim set Clear = 'R' where CrimId = @crimid       
   End        
 END     
     
 if (charindex('Order_USCivil',@orderList) > 0)    
 BEGIN       
   set @cno = 2737    
   IF (SELECT count(apno) FROM dbo.Crim WHERE apno = @apno and CNTY_NO = @cno) = 0    
   Begin    
    exec dbo.CreateCrim @apno,@cno,@crimid OUTPUT
    if (select count(1) from dbo.Crim where Crimid = @crimid) = 0
			set @crimid = (select top 1 crimid from dbo.crim where apno = @apno and cnty_no = @cno order by crimenteredtime desc)     
    update dbo.Crim set Clear = 'R' where CrimId = @crimid       
   End     
    --Insert into dbo.Crim    
    -- ([APNO],CNTY_NO,CreatedDate)    
    --values     
    -- (@apno,@cno,CURRENT_TIMESTAMP)    
 END     
     
 if (charindex('Order_MVR',@orderList) > 0)    
 BEGIN    
   IF (SELECT count(apno) FROM dbo.DL WHERE apno = @apno) = 0     
    Insert into dbo.DL    
     ([APNO],[SectStat],CreatedDate)    
    values     
     (@apno,'9',@currentDate)    
 END      
     
 if (charindex('Order_PositiveID',@orderList) > 0)    
 BEGIN    
   IF (SELECT count(apno) FROM dbo.Credit WHERE apno = @apno and RepType = 'S' ) = 0     
    Insert into dbo.Credit    
     ([APNO],[SectStat],RepType,Vendor,CreatedDate)    
    values     
     (@apno,'0','S','U',@currentDate)    
 END     
     
 if (charindex('Order_SanctionCheck',@orderList) > 0)    
 BEGIN    
   IF (SELECT count(apno) FROM dbo.MedInteg WHERE apno = @apno) = 0     
    Insert into dbo.MedInteg    
     ([APNO],[SectStat],CreatedDate)    
    values     
     (@apno,'0',@currentDate)    
 END 

  
--declare @timestamp datetime  
--set @timestamp = CURRENT_TIMESTAMP  
  
  
--declare @flag int  
--declare @count int  
--declare @orderType varchar(50)  
  
--set @count = (select count(*) from fn_Split(@orderList,';'));  
--set @flag = 0  
--while (@flag < @count)  
--begin  
-- set @orderType = (select value from fn_Split(@orderList,';') where idx = @flag);  
-- if @orderType = 'Order_Credit'  
-- Begin  
--  INSERT Into Credit (APNO,Reptype,Vendor,CreatedDate) VALUES (@apno,'C','U',@timestamp)  
-- End  
   
-- if @orderType = 'Order_MVR'  
-- Begin  
--  INSERT Into DL (APNO,CreatedDate) VALUES (@apno,@timestamp)  
-- End   
   
-- if @orderType = 'Order_MedInteg'  
-- Begin  
--  INSERT Into MEDINTEG (APNO,CreatedDate) VALUES (@apno,@timestamp)  
-- End  
-- set @flag = @flag + 1  
--end  
  