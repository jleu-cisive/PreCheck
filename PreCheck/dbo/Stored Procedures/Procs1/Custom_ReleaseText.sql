-- ====================================================================================
-- Author:		Prasanna
-- Create date: 04/02/2019
-- Description:	pull disclosure and Authorization language for all custom Clients
-- =====================================================================================
CREATE PROCEDURE [dbo].[Custom_ReleaseText] 
AS
BEGIN
	
    --   SELECT TOP 1 rt.clno, rt.DisclosureText, rt.AuthorizationText, rt.LastModifiedDate, rt.ChangedBy FROM ReleaseText rt WHERE rt.ClientType='ONLINE RELEASE' --dbo.ReleaseText.clno = ISNULL(@CLNO,0)
	   --GROUP BY rt.clno, rt.DisclosureText, rt.AuthorizationText, rt.LastModifiedDate, rt.ChangedBy
	   --ORDER BY rt.LastModifiedDate desc


	   SELECT rt.clno, MAX(c.Name) AS [Client Name], MAX(ra.Affiliate) AS [Affiliate], MAX(rt.DisclosureText) AS [Disclosure Text], MAX(rt.AuthorizationText) AS [Authorization Text],MAX(rt.LastModifiedDate) AS [LastModifiedDate], MAX(rt.ChangedBy) AS [Changed by] FROM ReleaseText rt 
	   INNER JOIN client c ON c.CLNO = rt.clno
	   inner join refaffiliate ra on ra.affiliateID = c.affiliateID
	   WHERE rt.ClientType='ONLINE RELEASE' AND rt.clno <> 0
	   GROUP BY rt.clno

END
