





CREATE PROCEDURE [dbo].[Win_ServiceInUse] AS
-- WindowsService ApplPreProcess..

SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED  


 	Update dbo.Appl
	Set SSN = substring(SSN,1,3) + '-' + substring(SSN,4,2) +'-' + substring(SSN,6,4)
	where len(ltrim(rtrim(SSN))) = 9 and charindex('-',SSN) = 0
	and ((NeedsReview Like '%6') or (NeedsReview Like '%7' or NeedsReview Like '%1')) 

	Update dbo.Appl
	SET NeedsReview=substring(NeedsReview,1,1) + '1'
	--Select * from appl
	WHERE(InUse IS NULL) AND ( (NeedsReview Like '%6' ) OR ( NeedsReview Like '%7'  and (SSN is not null   and len(ltrim(Rtrim(SSN)))= 11 )))
	and ApStatus = 'P' 

	Update dbo.Appl
	SET inUse='Service' 
	--select * from Appl
	WHERE (InUse IS NULL) AND (NeedsReview Like '%1')
	and ApStatus = 'P' 
	 -- added by santosh to prevent CIC/Stuweb apps to be picked up prematurely before the Sync process ran - 08/28/2019
	AND APNO not in (Select APNO 
					 From dbo.Appl (nolock) 
					 Where city IS NULL 
					   AND [state] IS NULL 
					   AND EnteredVia IN ('CIC','Stuweb') 
					   AND ApStatus = 'P' 
					   AND InUse IS NULL 
					   AND (NeedsReview Like '%1'))

	Update dbo.Appl
	SET inUse= 'CNTY_S' 
	--SELECT InUse, EnteredVia, NeedsReview, ApStatus, ApDate, Apno, SSN FROM APPL(NOLOCK)
	 WHERE INUSE = 'CNTY_W' 


SET TRANSACTION ISOLATION LEVEL READ COMMITTED    
SET NOCOUNT OFF
