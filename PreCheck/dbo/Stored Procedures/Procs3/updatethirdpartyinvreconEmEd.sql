--====================================================================================================================== 
--Author:        Lalit Kumar
--Create Date:   2-february-2023
--Description:   insert logging information in [InvDetail_Reconciliation] table per lead for employment and education  
--====================================================================================================================== 
 
CREATE procedure [dbo].[updatethirdpartyinvreconEmEd]  
( 
 @SectionKeyId int=0,
 @apno int=0,  
 @CompanyName varchar(100)=null,  
 @BillingAmount smallmoney = 0,
 @Surcharge smallmoney = 0,
 @InvDetId int=null,
 @Description Varchar(100)=null,
 @Category int=null
)  
AS  
BEGIN 
set NOCOUNT ON
if(@SectionKeyId is null)
begin
set @SectionKeyId=0
end
set @BillingAmount=ISNULL(@BillingAmount,0)
set @Surcharge=ISNULL(@Surcharge,0)

if(@Category=1)
Begin
    declare @sjvservicefee smallmoney=3.25
	declare @ReturnedDate datetime=getdate()
	DECLARE @invcreatedate datetime=getdate()--'2023-01-10 14:55:26.970'
BEGIN TRY
	-----------
	select @SectionKeyId=EmplID,@sjvservicefee=OrderCost,@ReturnedDate=ReturnedDate FROM
	(SELECT top 1 e.EmplID, Response.value('(//Results/Result/OrderCost)[1]', 'smallmoney') OrderCost, Response.value('(//Results/Result/VerifiedDate)[1]', 'datetime') ReturnedDate,ivd.CreatedDate
	FROM InvDetail id WITH(NOLOCK)
		 INNER JOIN Empl e WITH(NOLOCK) ON id.APNO=e.APNO AND e.APNO=@apno AND id.CreateDate BETWEEN DATEADD(SECOND,-5, @invcreatedate) AND DATEADD(SECOND, 1, @invcreatedate)
		 INNER JOIN Integration_VendorOrder ivd WITH(NOLOCK) ON ivd.Response.value('(//Results/Result/SubjectCtyID)[1]', 'int')=e.OrderId AND VendorName='sjv' AND ivd.CreatedDate BETWEEN
		 DATEADD(SECOND,-10, id.CreateDate) AND DATEADD(SECOND, 2, id.CreateDate) 
	ORDER BY ivd.CreatedDate)t
	SET @SectionKeyId=ISNULL(@SectionKeyId,0)
	SET @sjvservicefee=ISNULL(@sjvservicefee,0)
	------------
   if(@CompanyName='The Work Number')
   begin
    insert INTO InvDetail_Reconciliation(VendorId,APNO,SectionKeyId,SectionId,FeeTypeId,Amount,	Surcharge,	EnteredBy,	EnteredVia,	InvDetID,	Description,ReturnedDate)
   	select 5069,@apno,@SectionKeyId,1,1,@sjvservicefee,	0,	'invreconEmEd',	'Sjvintrunner',	NULL,	@Description,@ReturnedDate UNION all
    select 5079,@apno,@SectionKeyId,1,2,@Surcharge,	0,	'invreconEmEd',	'Sjvintrunner',	@InvDetId,	@Description ,@ReturnedDate
	if(@SectionKeyId>0)
	BEGIN
	exec dbo.updatethirdpartyvenodorEmEd @SectionKeyId,5069,1,'invreconEmEd','Sjvintrunner',0	
	--exec dbo.updatethirdpartyvenodorEmEd @SectionKeyId,5079,1,'invreconEmEd','Sjvintrunner',0
	END

   end
   ------------
   ELSE
   BEGIN
    insert INTO InvDetail_Reconciliation(VendorId,APNO,SectionKeyId,SectionId,FeeTypeId,Amount,	Surcharge,	EnteredBy,	EnteredVia,	InvDetID,	Description,ReturnedDate)
   	select 5069,@apno,@SectionKeyId,1,1,@sjvservicefee,	0,	'invreconEmEd',	'Sjvintrunner',	NULL,	@Description,@ReturnedDate UNION all
    select 5069,@apno,@SectionKeyId,1,2,@BillingAmount,	@Surcharge,	'invreconEmEd',	'Sjvintrunner',	@InvDetId,	@Description ,@ReturnedDate
	if(@SectionKeyId>0)
	BEGIN
	exec dbo.updatethirdpartyvenodorEmEd @SectionKeyId,5069,1,'invreconEmEd','Sjvintrunner',0
	END
   END
   ----------
END TRY  
--------
BEGIN CATCH  
    insert INTO InvDetail_Reconciliation(VendorId,APNO,SectionKeyId,SectionId,FeeTypeId,Amount,	Surcharge,	EnteredBy,	EnteredVia,	InvDetID,	Description,ReturnedDate)
   	select 5069,@apno,0,1,2,ISNULL(@BillingAmount,0),	ISNULL(@Surcharge,0),	'invreconEmEd',	'SjvError',	null,	@Description,GETDATE()
	if(ISNULL(@SectionKeyId,0)>0)
	BEGIN
	exec dbo.updatethirdpartyvenodorEmEd @SectionKeyId,5069,1,'invreconEmEd','Sjvintrunner',0
	END
END CATCH
---------
End

if(@Category=2)
Begin
BEGIN TRY
DECLARE @nchfee SMALLMONEY=0
DECLARE @nchSurcharge SMALLMONEY=0
DECLARE @nchpassthrough SMALLMONEY=0
SELECT @nchfee=ServiceFee,@nchSurcharge=SurCharge from ThirdPartyVendors WITH(NOLOCK) where ThirdPartyVendorId=6093
SET @nchpassthrough=@BillingAmount-@nchfee-@nchSurcharge

    insert INTO InvDetail_Reconciliation(VendorId,APNO,SectionKeyId,SectionId,FeeTypeId,Amount,	Surcharge,	EnteredBy,	EnteredVia,	InvDetID,	Description,ReturnedDate)
   	select 6093,@apno,@SectionKeyId,2,1,@nchfee,	@nchSurcharge,	'invreconEmEd',	'NchUtil',	@InvDetId,	@Description,GETDATE() UNION all
    select 6093,@apno,@SectionKeyId,2,2,@nchpassthrough,@Surcharge,	'invreconEmEd',	'NchUtil',	@InvDetId,	@Description ,GETDATE()

	--------------
	if(ISNULL(@SectionKeyId,0)>0)
	BEGIN
	exec dbo.updatethirdpartyvenodorEmEd @SectionKeyId,6093,2,'invreconEmEd','NchUtil',0
	END
	--------------

END TRY
BEGIN CATCH 
	  insert INTO InvDetail_Reconciliation(VendorId,APNO,SectionKeyId,SectionId,FeeTypeId,Amount,	Surcharge,	EnteredBy,	EnteredVia,	InvDetID,	Description,ReturnedDate)
      select 6093,@apno,0,2,2,ISNULL(@BillingAmount,0),	ISNULL(@Surcharge,0),	'invreconEmEd',	'NchError',	null,	@Description,GETDATE()
	  --------------
	  if(ISNULL(@SectionKeyId,0)>0)
	  BEGIN
	  exec dbo.updatethirdpartyvenodorEmEd @SectionKeyId,6093,2,'invreconEmEd','NchUtil',0
	  end
	  --------------
END CATCH
END
set NOCOUNT OFF
End


