
/*********************************************************************************************** 
dbo.[Verification_UpdateEmployment] 
		@apno = 2188058,
		@CompanyName = 'Test',		
		@BillingAmount='2.50'
--- Modified By AmyLiu on 08/22/2022: HDT59105 SJV third party billing for July.
--- (changed CompanyName and Description to allow max input) 
-- updated by Lalit on 2 feb 2023 for vendorcost project
***********************************************************************************************/
CREATE procedure [dbo].[Verification_UpdateEmployment]
(	
	@apno int,
	@CompanyName varchar(100),
	@BillingAmount smallmoney = null	
)
AS
BEGIN 
	DECLARE @InvDetID INT=NULL;

	IF(@apno>0 and  @CompanyName is not null)
		BEGIN
			DECLARE @SurCharge smallmoney=NULL;-- chnaged the datatype from int to smallmoney 
			DECLARE @Description NVARCHAR(500)=N'Employment:'+@CompanyName;
			DECLARE @Type INT=1;
			DECLARE @Billed bit=0;
			DECLARE @SubKey int=null;
			DECLARE @SubKeyChar varchar(50)=null;
			DECLARE @InvoiceNumber int=null;
			Declare @OrgBillingAmount smallmoney=@BillingAmount;  ---- added by Lalit		
		
			IF(@BillingAmount IS NULL)
			BEGIN
				SELECT @BillingAmount=[fee] FROM [dbo].[ThirdPartyVendorFees] WHERE [companyName]=@CompanyName;
			END			

			SELECT @SurCharge=[surCharge] FROM [dbo].[ThirdPartyVendorFees] WHERE [companyName]=@CompanyName and [fee]=@BillingAmount;

			SET @SurCharge=ISNULL(@SurCharge,1);

			SET @BillingAmount=ISNULL(@BillingAmount,0);
			--IF(@BillingAmount>0) BEGIN
			IF(@SurCharge IS NOT NULL)
			BEGIN
			    SET @OrgBillingAmount=@BillingAmount   ----- added by Lalit
				SET @BillingAmount=@BillingAmount+@SurCharge;
			END

			INSERT INTO [dbo].[InvDetail]([APNO],[Type],[Subkey],[SubKeyChar],[Billed],[InvoiceNumber],[CreateDate],[Description],[Amount])
			VALUES(@apno, @Type,@SubKey,@SubKeyChar,@Billed,@InvoiceNumber,GETDATE(),left(@Description,100) ,@BillingAmount);

		 SET @InvDetID = @@Identity  
		 exec [dbo].[updatethirdpartyinvreconEmEd] null,@apno,@CompanyName,@OrgBillingAmount,@Surcharge,@InvDetID,@Description,1 ----- added by Lalit
		 SELECT @InvDetID AS InvDetID
			
		END

		
END
