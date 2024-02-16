-- =============================================
-- Author:		Radhika Dereddy
-- Create date: 07/20/2017
-- Description:	Client Note Cleanup
/* Modified By: Vairavan A
-- Modified Date: 10/28/2022
-- Description: Main Ticketno-67221 - Update Affiliate ID Parameter Parent HDT#56320
--exec client_note_cleanup 0,'0'
--exec client_note_cleanup 17784,'4:30'
*/ 
-- =============================================
CREATE PROCEDURE [PRECHECK\VAzagappan].[Client_Note_Cleanup]
	-- add the parameters for the stored procedure here
	  @clno int,
	  @affiliateids varchar(max) = '0'--code added by vairavan for ticket id -67221
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	--code added by vairavan for ticket id -67221 starts
IF @AffiliateIDs = '0' 
BEGIN  
	SET @AffiliateIDs = NULL  
END

--code added by vairavan for ticket id -67221 ends
    -- Insert statements for procedure here		
		
		 SELECT N.CLNO,C.Name,N.NoteText AS ClientNotes, n.NoteBy AS CAM, N.NoteDate
		 FROM ClientNotes AS N(NOLOCK)
		 INNER JOIN dbo.Client AS C(NOLOCK) ON C.CLNO = N.CLNO
		 WHERE N.CLNO =IIF(@CLNO = 0, N.CLNO, @CLNO) 
		 and (@AffiliateIDs IS NULL OR C.AffiliateID IN (SELECT value FROM fn_Split(@AffiliateIDs,':')))--code added by vairavan for ticket id -67221
		 ORDER BY N.NoteDate DESC
END
