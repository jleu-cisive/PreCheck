-- =============================================
-- Author:		Radhika Dereddy
-- Create date: 07/20/2017
-- Description:	DE Production Details
-- Modified By - Radhika Dereddy on 02/04/2019 to add affiliate column
-- =============================================
CREATE PROCEDURE [dbo].[DE_Production_Details]
	-- Add the parameters for the stored procedure here
	 @UserID VARCHAR(8),
     @Date DATETIME
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
		SELECT A.APNO, C.Name,A.CreatedDate, A.EnteredBy AS Username, Ra.Affiliate
		FROM dbo.Appl(nolock) AS A
		INNER JOIN dbo.Client AS C ON C.CLNO = A.CLNO
		inner join refAffiliate ra with(nolock) on c.AffiliateID =ra.AffiliateID  
		WHERE A.EnteredVia = 'DEMI'
		  AND (@userID IS NULL OR @userID = '' OR A.EnteredBy = @UserID)
		  AND CONVERT(DATE,A.CreatedDate) = @Date
		ORDER BY A.CreatedDate DESC
END
