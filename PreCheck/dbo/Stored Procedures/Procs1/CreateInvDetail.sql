
CREATE PROCEDURE [dbo].[CreateInvDetail]  
  @Apno int,    
  @Type smallint,  
  @Subkey int,  
  @SubkeyChar varchar(2),  
  @Description varchar(50),  
  @Amount smallmoney,  
  @InvDetID int OUTPUT,  
  @ItemId int = null,  
  @BillingSectionType varchar(30) = null,  
  @BillingSubject varchar(30) = null,  
  @VendorId int = null,  
  @CreatedBy varchar(50) = null  
AS  
  set nocount on  
      
    
  if @ItemId is not null  
  Begin  
 if (select count(*) from dbo.VendorBilling where ItemId = @ItemId) = 0  
  Begin  
   Insert into dbo.VendorBilling(ItemId,APNO,BillingType,VendorId,BillingSubject,BillingAmount,CreatedBy,CreatedDate)  
   values (@ItemId,@Apno,@BillingSectionType,@VendorId,@BillingSubject,@Amount,@CreatedBy,GETDATE());       
   
   select @InvDetID = @@Identity 
  End  
 Else  
  Update dbo.VendorBilling set Apno = @Apno,BillingType=@BillingSectionType,BillingSubject = @BillingSubject,BillingAmount = @Amount,CreatedBy = @CreatedBy,CreatedDate = GETDATE()
  where ItemId = @ItemId 
  
  select @InvDetID = @ItemId
  End   
   
Else    
 Begin   
    
  insert into InvDetail  
    (Apno, Type, Subkey, SubkeyChar, CreateDate,   
      Description, Amount)  
  values  
    (@Apno, @Type, @Subkey, @SubkeyChar, GETDATE(),   
      @Description, @Amount)  
        
      select @InvDetID = @@Identity  
 End  
  
  
