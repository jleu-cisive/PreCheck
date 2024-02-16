


CREATE PROCEDURE [dbo].[Billing_PullClientConfiguration]  
	-- Add the parameters for the stored procedure here
	@CLNO int
AS
BEGIN
	
	SET NOCOUNT ON;
Declare @OneCountyPricing as bit
Declare @OneCountyPrice as money
Declare @ClientType as Int
   
--check for shared pricing
IF(select count(*) from clienthierarchyByService where clno = @CLNO and refHierarchyServiceID = 3) > 0
BEGIN
SET @CLNO = (select ParentCLNO from clienthierarchyByService where clno = @CLNO and refHierarchyServiceID = 3);
END

SELECT @OneCountyPrice=OneCountyPrice,@OneCountyPricing = OneCountyPricing,@ClientType = isnull(clienttypeID,0) 
FROM Client Where CLNO=@CLNO


--zero additional items for vendorcheck clients   
SELECT ComboEmplPersRefCount,ISNULL(@OneCountyPrice,0) as OneCountyPrice,ISNULL(@OneCountyPricing,0) as OneCountyPricing,
case when @ClientType = 14 then cast(1 as bit)
ELSE zeroadditionalitems end as zeroadditionalitems,
case when @ClientType = 14 then cast(1 as bit)
ELSE LockPackagePricing end as LockPackagePricing,nopackagenobill
 FROM Client c left join clientconfig_billing cb on c.clno = cb.clno WHERE c.CLNO = @CLNO

END


