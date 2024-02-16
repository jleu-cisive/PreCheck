-- Alter Procedure Billing_GetClientCrimRates


-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[Billing_GetClientCrimRates]
	@CLNO int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
Declare @OneCountyPricing as bit
Declare @OneCountyPrice as money
   
--check for shared pricing
IF(select count(*) from clienthierarchyByService where clno = @CLNO and refHierarchyServiceID = 3) > 0
BEGIN
SET @CLNO = (select ParentCLNO from clienthierarchyByService where clno = @CLNO and refHierarchyServiceID = 3);
END

SELECT @OneCountyPrice=OneCountyPrice,@OneCountyPricing = OneCountyPricing 
FROM Client Where CLNO=@CLNO

 SELECT ccr.cnty_no,case when (ExcludeFromRules = 0 AND @OneCountyPricing = 1) THEN @OneCountyPrice
 else ccr.Rate
 end as Rate,
 ExcludeFromRules
  FROM ClientCrimRate ccr

inner join dbo.TblCounties c on ccr.cnty_no = c.cnty_no
	WHERE  (ccr.CLNO = @CLNO) and c.county not like '%sex offender%'
UNION
SELECT c.cnty_no,
0.00 as Rate,'1' as ExcludeFromRules
FROM dbo.TblCounties c (nolock) where c.county like '%sex offender%'

END
