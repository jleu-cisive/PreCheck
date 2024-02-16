-- =============================================  
-- Author:  Sahithi  
-- Create date:04/09/2020  
-- Description:  hdt :70947, Scheduled a Client hits report   
-- exec [ClientHitsSummary_PreviousWeek] 16193 

/*
ModifiedBy		ModifiedDate	TicketNo	Description
Shashank Bhoi	10/13/2022		67226		#67226 Update Affiliate ID Parameter Parent HDT#56320
											Modify existing q-reports that have affiliate ids in their search parameters  
											Details:   
											Change search parameters for the Affiliate Id field  
											     * search by multiple affiliate ids (ex 4:297)  
											     * want to also be able to search all affiliates by putting zero - meaning 0 to search all affiliates  
											     * multiple affiliates to be separated by a colon    
											Under Parameter Names - after Affiliate ID include this wording (separate by colon, default 0) 
											EXEC [ClientHitsSummary_PreviousWeek] @CLNO=12444,  @AffiliateIDs=0

*/
-- =============================================  
CREATE PROCEDURE [dbo].[ClientHitsSummary_PreviousWeek]  
@CLNO int,   
@AffiliateIDs varchar(MAX) = '0'--Code added by vairavan for ticket id -67226 
AS  
BEGIN  
  SET NOCOUNT ON; 

  --Code added by Shashank for ticket id -67226 starts
  IF(@AffiliateIDs = '' OR LOWER(@AffiliateIDs) = 'null' OR @AffiliateIDs = '0')
	SET @AffiliateIDs = NULL;  
  --Code added by Shashank for ticket id -67226 ends  
  
  SELECT C.APNO as ReportNumber, a.first,a.last,c.Disposition ,c.Clear as 'Status',  
  c.County, c.Name,c.CaseNo,c.Ordered as OrderedDate,c.Offense,c.Sentence,c.Fine,  
  c.Pub_Notes 
  FROM CRIM			AS c   
  INNER JOIN Appl	AS a ON c.APNO = a.APNO  
  INNER JOIN Client AS cc ON a.CLNO = cc.CLNO  
  WHERE  c.Clear ='F' AND IsHidden = 0  
  AND cc.WebOrderParentCLNO = @CLNO   
  AND CAST(c.Ordered AS Date) BETWEEN CAST(DateAdd(DD,-7,GETDATE()) as DATE) AND CAST(GETDATE() as DATE)  
  AND (@AffiliateIDs IS NULL OR cc.AffiliateID IN (SELECT value FROM fn_Split(@AffiliateIDs,':'))); --Code added by Shashank for ticket id -67226 
     
END  
