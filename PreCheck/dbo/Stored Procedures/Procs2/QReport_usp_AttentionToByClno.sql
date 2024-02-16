
/************************************************************************************************************

*************************************************************************************************************
Author: Arindam Mitra
Date: 10/31/2023
Purpose: This report shows client attn detail by CLNO. Converted the existing sql query to stored procedure and added columns like Attn To Email, Create Date, 
Original Close Date, Reopen Date and Complete Date. Also multiple value provision provided for CLNO and AffiliateId parameters. HDT# 115028

***************************************************************************************************************/

/*	
EXEC [dbo].[QReport_usp_AttentionToByClno] '0', '10/01/2023', '10/25/2023', '4:8'
*/

CREATE PROCEDURE [dbo].[QReport_usp_AttentionToByClno]
@CLNO varchar(MAX),
@StartDate Datetime,
@EndDate DateTime, 
@AffiliateId varchar(MAX) = '0' 


AS

BEGIN

	SET NOCOUNT ON       --stop the server from returning a message to the client, reduce network traffic

	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

/* Code added starts against HDT# 115028 */
	IF (@CLNO = '0' OR @CLNO = '' OR LOWER(@CLNO) = 'null')
	BEGIN  
		SET @CLNO = NULL  
	END

	IF (@AffiliateId = '0' OR @AffiliateId = '' OR LOWER(@AffiliateId) = 'null')
	BEGIN  
		SET @AffiliateId = NULL  
	END
/* Code added ends against HDT# 115028 */

	

 Select a.CLNO, c.Name as ClientName, a.APNO, a.ApStatus, a.Attn,
 o.Attention AS 'Attn To Email',
 a.CreatedDate AS 'Create Date', a.OrigCompDate AS 'Original Close Date', a.ReopenDate  AS 'Reopen Date', a.CompDate 'Complete Date' --Code added against HDT# 115028 
From Appl a  WITH(NOLOCK)
inner join Client c WITH(NOLOCK) on A.CLNO = C.CLNO  
LEFT JOIN refAffiliate RA WITH(NOLOCK) on RA.AffiliateID = c.AffiliateID	--Code added against HDT# 115028 
LEFT JOIN ENTERPRISE.dbo.Applicant AC with(nolock) ON A.APNO=AC.ApplicantNumber
LEFT JOIN ENTERPRISE.dbo.[Order] O with(nolock) ON o.OrderId=AC.OrderId  

WHERE (a.Apdate BETWEEN @StartDate AND @EndDate) 
--AND c.CLNO = IIF(@CLNO=0,C.CLNO,@CLNO) --Code commented against HDT# 115028 
AND (@CLNO IS NULL OR C.CLNO  IN (SELECT value FROM fn_Split(@CLNO,':'))) --Code added against HDT# 115028
AND (@AffiliateId IS NULL OR RA.AffiliateId IN (SELECT value FROM fn_Split(@AffiliateId,':')))  --Code added against HDT# 115028 
AND a.ApStatus in ('P', 'F') 
ORDER BY a.CLNO

	

	SET NOCOUNT OFF

	SET TRANSACTION ISOLATION LEVEL READ COMMITTED

END


