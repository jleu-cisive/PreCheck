-- =============================================
-- Author:		DEEPAK VODETHELA
-- Create date: 04/18/2018
-- Description:	AI Production Details
-- executionL: EXEC AI_Production_Detail 'jcarpent','04/17/2018'
--			   EXEC AI_Production_Detail NULL,'04/17/2018'
-- Modified By - Radhika Dereddy on 02/04/2019 to add affiliate column
-- =============================================
CREATE PROCEDURE [dbo].[AI_Production_Detail_08182021]
	-- Add the parameters for the stored procedure here
	@UserID varchar(10),
	@CreatedDate datetime  
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	IF(@userID is null or @userID = '')   
	BEGIN     
		Select a.apno, c.Name, aGetNextLog.CreatedDate, O.AIMICreatedDate AS [ReviewedDate], aGetNextLog.username, ra.Affiliate
		from Appl a with(nolock)      
		inner join ApplGetNextLog aGetNextLog with(nolock) on a.APNO = aGetNextLog.APNO     
		INNER JOIN Metastorm9_2.dbo.Oasis AS O ON aGetNextLog.APNO = O.apno
		inner join Client c with(nolock) on a.clno = c.clno 
		inner join refAffiliate ra with(nolock) on c.AffiliateID =ra.AffiliateID     
		where (convert(date,aGetNextLog.CreatedDate) = @CreatedDate)   
	END  
	else   
	BEGIN     
		Select a.apno, c.Name, aGetNextLog.CreatedDate, O.AIMICreatedDate AS [ReviewedDate], aGetNextLog.username, ra.Affiliate 
		from Appl a with(nolock)      
		inner join ApplGetNextLog aGetNextLog with(nolock) on a.APNO = aGetNextLog.APNO     
		INNER JOIN Metastorm9_2.dbo.Oasis AS O ON aGetNextLog.APNO = O.apno
		inner join Client c with(nolock) on a.clno = c.clno   
		inner join refAffiliate ra with(nolock) on c.AffiliateID =ra.AffiliateID   
		where (aGetNextLog.username IS NULL OR aGetNextLog.username = @UserID) 
		and (convert(date,aGetNextLog.CreatedDate) = @CreatedDate)   
	END  
END
