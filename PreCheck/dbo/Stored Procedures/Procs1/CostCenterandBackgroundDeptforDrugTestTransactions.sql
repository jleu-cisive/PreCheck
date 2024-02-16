-- =============================================  
-- Author:  Prasanna Kumari  
-- Create date: 06/30/2020  
-- Description:      QReport that lists the CostCenter and associated background Department numbers for OCHS Transaction IDs  
-- EXEC CostCenterandBackgroundDeptforDrugTestTransactions '01/01/2020','06/01/2020',15382,0  
-- =============================================  
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
											EXEC CostCenterandBackgroundDeptforDrugTestTransactions '01/01/2020','06/01/2020',15382,0
Shashank Bhoi	11/18/2022		67226		CTE added for performance improvement
*/
CREATE PROCEDURE [dbo].[CostCenterandBackgroundDeptforDrugTestTransactions] 
 -- Add the parameters for the stored procedure here  
       @startdate datetime = NULL,  
       @enddate datetime = NULL,  
       @parentCLNO int = 0,  
       @CLNO int= 0,
	   @AffiliateIDs varchar(MAX) = '0'	--Code added by Shashank for ticket id -67226
AS  
BEGIN  
 -- SET NOCOUNT ON added to prevent extra result sets from  
 -- interfering with SELECT statements.  
	SET NOCOUNT ON; 

	--Code added by Shashank for ticket id -67226 starts
	 IF(@AffiliateIDs = '' OR LOWER(@AffiliateIDs) = 'null' OR @AffiliateIDs = '0')   
		SET @AffiliateIDs = NULL;  
	--Code added by Shashank for ticket id -67226 ends 
  
  --Code commented for performance improvement against ticket id -67226 starts
 --   -- Insert statements for procedure here  
 --   select distinct ord.TID as [OCHS Transaction ID], ord.CLNO, c.WebOrderParentCLNO [Parent CLNO], c.[Name] as [Client Name],  
 --   ord.LastName as [Last], ord.FirstName as [First], ord.DateReceived, OCI.CostCenter, a.DeptCode [BG Department #]
	--FROM OCHS_ResultDetails			AS ord (nolock)  
 --   INNER JOIN client				AS c (nolock) on ord.clno = c.CLNO  
 --   INNER JOIN Appl					AS a (nolock) on a.CLNO = c.CLNO  
 --   INNER JOIN OCHS_CandidateInfo	AS OCI (nolock) on ord.CLNO = OCI.CLNO   
 --   WHERE (convert( date, ord.DateReceived) >= @startdate and convert( date, ord.DateReceived) <= @enddate) and  
 --   c.WebOrderParentCLNO = IIF(@ParentCLNO=0,C.weborderparentCLNO,@ParentCLNO) and ord.CLNO= IIF(@CLNO=0,C.CLNO,@CLNO)  
	--AND (@AffiliateIDs IS NULL OR c.AffiliateID IN (SELECT value FROM fn_Split(@AffiliateIDs,':'))); --Code added by Shashank for ticket id -67226 
--Code commented for performance improvement ticket id -67226 ends

  --Code added for performance improvement against ticket id -67226 starts
	;With cteA AS (
		SELECT	DeptCode,CLNO 
		FROM	dbo.Appl AS A with (nolock)
		WHERE	A.CLNO= IIF(@CLNO=0,A.CLNO,@CLNO) 
		GROUP BY DeptCode,CLNO
		)
		,cteOCI AS (
			SELECT CostCenter,CLNO 
			FROM  dbo.OCHS_CandidateInfo  AS CI with (nolock)
			WHERE CI.CLNO= IIF(@CLNO=0,CI.CLNO,@CLNO) 
			GROUP BY CostCenter,CLNO
		)
		,cteORD AS (
			-- Insert statements for procedure here  
			SELECT ord.TID as [OCHS Transaction ID], ord.CLNO, c.WebOrderParentCLNO [Parent CLNO], c.[Name] as [Client Name],  
			ord.LastName as [Last], ord.FirstName as [First], ord.DateReceived
			FROM dbo.OCHS_ResultDetails			AS ord (nolock)  
				 JOIN dbo.client				AS c (nolock) on ord.clno = c.CLNO  
			WHERE (convert( date, ord.DateReceived) >= @startdate and convert( date, ord.DateReceived) <= @enddate) 
			AND  c.WebOrderParentCLNO = IIF(@ParentCLNO=0,C.weborderparentCLNO,@ParentCLNO) 
			AND ord.CLNO= IIF(@CLNO=0,C.CLNO,@CLNO)  
			AND (@AffiliateIDs IS NULL OR c.AffiliateID IN (SELECT value FROM fn_Split(@AffiliateIDs,':'))) --Code added by Shashank for ticket id -67226 
		)
		SELECT ORD.*
		, NULL AS CostCenter, a.DeptCode [BG Department #]
		FROM cteORD						AS ORD
			 JOIN cteA					AS a (nolock) on a.CLNO = ORD.CLNO  
		UNION 
		SELECT ORD.*
		, OCI.CostCenter, NULL AS [BG Department #]
		FROM cteORD						AS ORD
			 JOIN cteOCI				AS OCI (nolock) on ord.CLNO = OCI.CLNO 
 --Code added for performance improvement against ticket id -67226 ends 
END  
