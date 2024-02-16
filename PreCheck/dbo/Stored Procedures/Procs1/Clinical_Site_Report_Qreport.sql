-- =============================================
-- Author:		Prasanna Kumari
-- Create date: 02/23/2021
-- Description:	Report to pull the data points for Medical-StudentCheck client types
-- EXEC [Clinical_Site_Report_Qreport]
-- =============================================
CREATE PROCEDURE [dbo].[Clinical_Site_Report_Qreport]

AS
BEGIN
	
	select c.CLNO, c.Name as [Client Name],c.City,c.State,cc.FirstName as [Contact FirstName],
	cc.LastName as [Contact LastName],cc.Phone as [Contact Phone],cc.Email as [Contact Email],
	cc.ContactType as [Contact Type],cc.Title [Contact Title] 
	from client c(nolock)
	inner join clientcontacts cc(nolock) on c.CLNO = cc.CLNO
	where ClientTypeID = 4

END
