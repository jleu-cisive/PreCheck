-- Batch submitted through debugger: SQLQuery109.sql|7|0|C:\Users\DDEGEN~1\AppData\Local\Temp\~vsF7D6.sql


/*
update dbo.Appl set DL_Number='1234567',DL_State='TX' where apno = 2500506
exec dbo.PrecheckFramework_CreateOrders 'Order_Credit',3161067,'KMattson'
select * from dl where apno = 2500506
delete from dl where apno = 2500506 
*/
CREATE procedure [dbo].[PrecheckFramework_CreateOrders](@sectionList varchar(1000),@apno int,@userName varchar(20) = null)  
as  
declare @crimid int  
declare @currentDate datetime  
  
set @currentDate = CURRENT_TIMESTAMP  
if (charindex('Order_Credit',@sectionList) > 0)    
   BEGIN    
     IF (SELECT count(apno) FROM dbo.Credit WHERE apno = @apno and RepType='C') = 0    
		 BEGIN
			Declare @msg nvarchar(500), @Sub nvarchar(200),@EnteredBy varchar(20)

 			Select @EnteredBy = EnteredBy, @msg = 'This is to inform you that Client:  ' + cast(Name as nvarchar)+ '(' + cast(A.CLNO as nvarchar) + ') requires/requested Credit to be ordered for Report# ' + cast(@apno as varchar) + '; ' + char(9) + char(13)+ char(9) + char(13) +   'Applicant: ' + A.First + ' ' + A.Last  + char(9) + char(13)+ char(9) + char(13) +   'Thank you.'
			From DBO.APPL A inner join DBO.Client C on A.CLNO = C.CLNO
			Where APNO = @apno

			Set @Sub = 'Credit Requested For Report# ' + cast(@apno as varchar) + '; Requested By: ' + isnull(@userName,@EnteredBy)

			EXEC msdb.dbo.sp_send_dbmail    @from_address=N'CreditReports@PreCheck.com', @recipients=N'CreditReports@PreCheck.com', @subject= @Sub,   @body=@msg ; --,@copy_recipients = N'Santoshchapyala@precheck.com;JessicaViera@precheck.com;MistySmallwood@precheck.com'

			  Insert into     
			   dbo.Credit     
			  ([APNO],[SectStat],CreatedDate,Vendor,RepType)    
			  values     
			   (@apno,'0',@currentDate,'U','C')  
		 END	     
  
   END    

--schapyala modified the procedure on 02/04/14 -- not to set the added crims to 'R'. This should be done by the AI reviewing the PR page in AIMI       
 if (charindex('Order_USFederal',@sectionList) > 0)    
 BEGIN    
   declare @cno int    
   set @cno = 2738    
   IF (SELECT count(apno) FROM dbo.Crim WHERE apno = @apno and CNTY_NO = @cno) = 0     
   Begin    
    exec dbo.CreateCrim @apno,@cno,@crimid OUTPUT
    if (select count(1) from dbo.Crim where Crimid = @crimid) = 0
			set @crimid = (select top 1 crimid from dbo.crim where apno = @apno and cnty_no = @cno order by crimenteredtime desc)     
    --update dbo.Crim set Clear = 'R' where CrimId = @crimid       
   End    
    --Insert into dbo.Crim    
    -- ([APNO],CNTY_NO,CreatedDate)    
    --values     
    -- (@apno,@cno,CURRENT_TIMESTAMP)    
 END     
     
 if (charindex('Order_FedBankruptcy',@sectionList) > 0)    
 BEGIN    
   --declare @cno int    
   set @cno = 229    
   IF (SELECT count(apno) FROM dbo.Crim WHERE apno = @apno and CNTY_NO = @cno) = 0     
   Begin    
    exec dbo.CreateCrim @apno,@cno,@crimid OUTPUT
		if (select count(1) from dbo.Crim where Crimid = @crimid) = 0
			set @crimid = (select top 1 crimid from dbo.crim where apno = @apno and cnty_no = @cno order by crimenteredtime desc)     
    --update dbo.Crim set Clear = 'R' where CrimId = @crimid       
   End        
 END     
     
 if (charindex('Order_USCivil',@sectionList) > 0)    
 BEGIN       
   set @cno = 2737    
   IF (SELECT count(apno) FROM dbo.Crim WHERE apno = @apno and CNTY_NO = @cno) = 0    
   Begin    
    exec dbo.CreateCrim @apno,@cno,@crimid OUTPUT
    if (select count(1) from dbo.Crim where Crimid = @crimid) = 0
			set @crimid = (select top 1 crimid from dbo.crim where apno = @apno and cnty_no = @cno order by crimenteredtime desc)     
    --update dbo.Crim set Clear = 'R' where CrimId = @crimid       
   End     
    --Insert into dbo.Crim    
    -- ([APNO],CNTY_NO,CreatedDate)    
    --values     
    -- (@apno,@cno,CURRENT_TIMESTAMP)    
 END     
     
 if (charindex('Order_MVR',@sectionList) > 0)    
 BEGIN       
   IF (SELECT count(apno) FROM dbo.DL WHERE apno = @apno) = 0 
   BEGIN    

   declare @dlnum varchar(100);
   declare @dlstate varchar(3);

   select @dlnum=DL_Number,@dlstate=DL_State from dbo.Appl where apno = @apno
   if (IsNull(@dlnum,'') <> '' and IsNull(@dlstate,'') <> '')
    Insert into dbo.DL    
     ([APNO],[SectStat],CreatedDate)    
    values     
     (@apno,'9',@currentDate)    
	END
 END      
     
 if (charindex('Order_PositiveID',@sectionList) > 0)    
 BEGIN    
   IF (SELECT count(apno) FROM dbo.Credit WHERE apno = @apno and RepType = 'S' ) = 0     
    Insert into dbo.Credit    
     ([APNO],[SectStat],RepType,Vendor,CreatedDate)    
    values     
     (@apno,'0','S','U',@currentDate)    
 END     
     
 if (charindex('Order_SanctionCheck',@sectionList) > 0)    
 BEGIN    
   IF (SELECT count(apno) FROM dbo.MedInteg WHERE apno = @apno) = 0     
    Insert into dbo.MedInteg    
     ([APNO],[SectStat],CreatedDate)    
    values     
     (@apno,'0',@currentDate)    
 END 
