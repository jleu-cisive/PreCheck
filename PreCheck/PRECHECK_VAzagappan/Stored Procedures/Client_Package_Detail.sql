-- =============================================
-- Author:		Radhika Dereddy
-- Create date: 07/20/2017
-- Description:	Client Package Detail
/* Modified By: Vairavan A
-- Modified Date: 10/28/2022
-- Description: Main Ticketno-67221 - Update Affiliate ID Parameter Parent HDT#56320
*/
-- =============================================
CREATE PROCEDURE [PRECHECK\VAzagappan].Client_Package_Detail
	-- Add the parameters for the stored procedure here
	 @Clno int = NULL,
	 @AffiliateIDs varchar(MAX) = '0'--code added by vairavan for ticket id -67221
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here	
	
		--code added by vairavan for ticket id -67221 starts
	IF @AffiliateIDs = '0' 
	BEGIN  
		SET @AffiliateIDs = NULL  
	END
	--code added by vairavan for ticket id -67221 ends
		
		SELECT CP.CLNO AS Clno,C.Name AS ClientName,PM.PackageDesc AS Package, CP.Rate
		FROM [dbo].[ClientPackages] AS CP(NOLOCK)
		INNER JOIN [dbo].[PackageMain] AS PM(NOLOCK) ON PM.PackageID = CP.PackageID
		INNER JOIN [dbo].[Client] AS C(NOLOCK) ON C.Clno = CP.Clno
		WHERE (@Clno IS NULL OR @Clno = '' OR CP.clno = @Clno)
		 AND PM.PackageID IN (681,682,735)	
		 and (@AffiliateIDs IS NULL OR C.AffiliateID IN (SELECT value FROM fn_Split(@AffiliateIDs,':')))--code added by vairavan for ticket id -67221
		ORDER BY CP.PackageID
END
