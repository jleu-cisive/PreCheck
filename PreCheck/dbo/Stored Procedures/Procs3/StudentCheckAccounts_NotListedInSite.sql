-- ========================================================================================
-- Author:		Prasanna
-- Create date: 02/03/2019
-- Description:	List of all StudentCheck accounts that are active, but do not appear in the drop down list of schools to choose from on the StudentCheck site
-- Requestor: Ryan Trevino
-- ========================================================================================
CREATE PROCEDURE [dbo].[StudentCheckAccounts_NotListedInSite] 

AS
BEGIN
	
	SELECT vc.ClientId AS CLNO, vc.ClientName AS[Client Name], cc.FirstName + ' '+ cc.LastName AS [Contact Name], cc.Email AS [Contact Email] FROM  Enterprise.[PreCheck].[vwClient] vc
    INNER JOIN dbo.ClientContacts cc ON vc.ClientId = cc.CLNO
    INNER JOIN dbo.refClientType rct ON rct.ClientTypeID = vc.clienttypeId
    WHERE rct.ClientTypeID NOT in(6,7,8,11,13) AND vc.IsActiveWebOrderClient=1 

END
