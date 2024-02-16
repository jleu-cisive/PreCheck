  
-- Modified by Arindam Mitra on 10/18/2022 to add AffiliateId for ticket #67224
-- Execution: EXEC dbo.EmployCheck_Active_Employees_by_Client NULL, '0:59' 

CREATE PROCEDURE [dbo].[EmployCheck_Active_Employees_by_Client] 
@ClientID INT,
@AffiliateId varchar(MAX) = '0'--code added by Arindam for ticket id -67224
AS  

--code added by Arindam for ticket id -67224 starts
	IF @AffiliateId = '0' 
	BEGIN  
		SET @AffiliateId = NULL  
	END
 --code added by Arindam for ticket id -67224 ends
  
SELECT A.* FROM [HEVN].[dbo].[employeerecord] A (NOLOCK)
INNER JOIN dbo.Client CL(NOLOCK) on CL.CLNO = A.employerid    --code added by Arindam for ticket id -67224 
 INNER JOIN refAffiliate RA(NOLOCK) on RA.AffiliateID = CL.AffiliateID		--code added by Arindam for ticket id -67224 
WHERE A.enddate is null and A.employerid = @ClientID  
AND (@AffiliateId IS NULL OR RA.AffiliateId IN (SELECT value FROM fn_Split(@AffiliateId,':')))--code added by Arindam for ticket id -67224
  