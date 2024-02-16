
CREATE PROCEDURE [dbo].[Verification_UpdateEducationInvoice]

(	
	@apno int,
	@CompanyName varchar(100),
	@BillingAmount smallmoney = null	
)
AS
BEGIN 
	DECLARE @InvDetID INT=NULL;
        --set @BillingAmount = @BillingAmount + 1.00
	IF(@apno>0 and  @CompanyName is not null and @BillingAmount > 0.00)
		BEGIN
			DECLARE @SurCharge smallmoney=NULL;-- chnaged the datatype from int to smallmoney 
			DECLARE @Description NVARCHAR(500)=N'Education: '+@CompanyName;
			DECLARE @Type INT=1;
			DECLARE @Billed bit=0;
			DECLARE @SubKey int=null;
			DECLARE @SubKeyChar varchar(50)=null;
			DECLARE @InvoiceNumber int=null;
			

			INSERT INTO [dbo].[InvDetail]([APNO],[Type],[Subkey],[SubKeyChar],[Billed],[InvoiceNumber],[CreateDate],[Description],[Amount])
									   VALUES(@apno, @Type,@SubKey,@SubKeyChar,@Billed,@InvoiceNumber,GETDATE(),left(@Description,100) ,@BillingAmount);

		 SET @InvDetID = @@Identity  
		 SELECT @InvDetID AS InvDetID
			
		END

		
END

