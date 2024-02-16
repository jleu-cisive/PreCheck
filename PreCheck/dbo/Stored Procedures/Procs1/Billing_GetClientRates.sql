
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[Billing_GetClientRates]
	-- Add the parameters for the stored procedure here
	@CLNO int
AS
BEGIN
--check for shared pricing
IF(select count(*) from clienthierarchyByService where clno = @CLNO and refHierarchyServiceID = 3) > 0
BEGIN
SET @CLNO = (select ParentCLNO from clienthierarchyByService where clno = @CLNO and refHierarchyServiceID = 3);
END

	SELECT RateType, Rate FROM ClientRates WHERE CLNO = @CLNO
END

