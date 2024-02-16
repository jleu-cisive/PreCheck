

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
create PROCEDURE [dbo].[OASIS_PullClientConfigurations01232017] 
@CLNO int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
DECLARE @PRICINGCLNO int;

SET @PRICINGCLNO = (select top 1 parentclno from clienthierarchybyservice where clno = @clno
and refhierarchyserviceid = 3);
IF(@PRICINGCLNO is null)
SET @PRICINGCLNO = @CLNO;

SELECT clno,configurationkey,value,applytoeveryone FROM clientconfiguration with (nolock) where clno = @CLNO
UNION
SELECT @CLNO,'ClientAdjudicationEmail',
ISNULL((select email from precheck_staging..notificationconfig  with (nolock) where clno = @CLNO and refnotificationtypeid = 4),'') as value,
0 as applytoeveryone
UNION
SELECT @PRICINGCLNO,'NoPackageNoBill',
ISNULL((select case when nopackagenobill = 1 then 'True' when nopackagenobill is null then 'False' else 'False' END from clientconfig_billing  with (nolock) where clno = @PRICINGCLNO),'False') as value,
0 as applytoeveryone
;
END

