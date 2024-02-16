
-- =============================================
-- Author:		DEEPAK VODETHELA
-- Create date: 04/18/2018
-- Description:	AI Production Details
-- executionL: EXEC AI_Production_Detail 'jcarpent','04/17/2018'
--			   EXEC AI_Production_Detail NULL,'04/17/2018'
-- Modified By - Radhika Dereddy on 02/04/2019 to add affiliate column
-- Moidfied by - James Norton on 08/13/2021 - split querries to improve performance.
-- =============================================
CREATE PROCEDURE [dbo].[AI_Production_Detail]
	-- Add the parameters for the stored procedure here
	@UserID varchar(10),
	@CreatedDate datetime  
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

drop table IF exists #AI_1
drop table IF exists #AI_2

    -- Insert statements for procedure here
  
	Select a.apno,  aGetNextLog.CreatedDate, O.AIMICreatedDate AS [ReviewedDate], aGetNextLog.username--, ra.Affiliate		
	into #AI_1		
	from Appl a with(nolock)      
	inner join ApplGetNextLog aGetNextLog with(nolock) on a.APNO = aGetNextLog.APNO     
	INNER JOIN Metastorm9_2.dbo.Oasis AS O ON aGetNextLog.APNO = O.apno
	--inner join Client c with(nolock) on a.clno = c.clno 
	--inner join refAffiliate ra with(nolock) on c.AffiliateID =ra.AffiliateID     
	where (convert(date,aGetNextLog.CreatedDate) = @CreatedDate) 
	and ((@UserID is null)
		or (aGetNextLog.username IS NULL OR aGetNextLog.username = @UserID))   
	
	 
	
	Select a.apno, c.Name,   ra.Affiliate--,   O.AIMICreatedDate AS [ReviewedDate] 
	into #AI_2
	from Appl a with(nolock)      
	inner join ApplGetNextLog aGetNextLog with(nolock) on a.APNO = aGetNextLog.APNO     
	--INNER JOIN Metastorm9_2.dbo.Oasis AS O ON aGetNextLog.APNO = O.apno
	inner join Client c with(nolock) on a.clno = c.clno 
	inner join refAffiliate ra with(nolock) on c.AffiliateID =ra.AffiliateID     
	where (convert(date,aGetNextLog.CreatedDate) = @CreatedDate)
	and ((@UserID is null) or (aGetNextLog.username IS NULL OR aGetNextLog.username = @UserID))   
	

Select distinct a.apno, b.Name, a.CreatedDate, a.[ReviewedDate],  a.username, b.Affiliate

from #AI_1 a join #AI_2 b on a.apno = b.apno
order by apno
	
	 
END

