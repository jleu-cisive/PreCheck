
-- =============================================
-- Author:		Najma Begum
--Note: Can Optimize
-- =============================================
CREATE PROCEDURE [dbo].[QReport_GetEZVerifyRepeatUsers]
	-- Add the parameters for the stored procedure here
	@FromDate DateTime,
	@ToDate DateTime
AS	
BEGIN

SELECT l.EZVUserID,(dbo.EZVerifyUser.FirstName + ',' + dbo.EZVerifyUser.LastName) as UserName, dbo.EZVerifyUser.Company, (SELECT Count(EZVerifyLog.VerificationID)
FROM         dbo.EZVerifyLog            
                       where dbo.EZVerifyLog.VerificationID not like 'S%' and dbo.EZVerifyLog.lastupdated between @FromDate and DateAdd(d,1,@ToDate)

and dbo.EZVerifyLog.EZVUserID =l.EZVUserID) as Employment, (SELECT Count(EZVerifyLog.VerificationID)
FROM         dbo.EZVerifyLog            
                       where dbo.EZVerifyLog.VerificationID like 'S%' and dbo.EZVerifyLog.lastupdated between @FromDate and DateAdd(d,1,@ToDate)

and dbo.EZVerifyLog.EZVUserID =l.EZVUserID) as Education

FROM         dbo.EZVerifyLog l INNER JOIN
                      dbo.EZVerifyUser ON l.EZVUserID = dbo.EZVerifyUser.UID
                      
                      
                      where l.lastupdated between @FromDate and DateAdd(d,1,@ToDate)

group by l.ezvuserid, dbo.EZVerifyUser.FirstName,dbo.EZVerifyUser.LastName,dbo.EZVerifyUser.Company

having count(l.ezvuserid) > 1 

END

