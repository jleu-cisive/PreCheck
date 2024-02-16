-- =============================================
-- Author:Abhijit Awari
-- Create date: 07/14/2022
-- Description:	For HDT#56168 - a new Qreport, using the logic similar to the Crim Pending Detail status/deliverymethod Qreport, 
-- but will need only the following columns/data built into the new report:
-- App Number,App Date,App Status,Last Name,First Name,Last Updated,User Name,User ID,App_in_use
-- EXEC Reports_Locked_by_User
-- =============================================
create PROCEDURE [dbo].[Reports_Locked_by_User]
as	
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	select a.apno as [App Number],
	a.apdate as [App Date],
	a.apstatus as [App Status],
	a.last as [Last Name],
	a.first as [First Name],
	c.Last_Updated as [Last Updated],
	u.Name as [User Name],
	u.UserID as [User ID],
	a.inuse as [App_in_use]

	from appl a with (nolock)
	inner join users u with (nolock) on a.UserID = u.UserID
	inner join crim c with (nolock) on a.apno = c.apno
	inner join Iris_Researchers ir with(nolock) on c.vendorid = ir.R_Id
	where isnull(a.apstatus,'P') in ('P','W')
	and isnull(c.clear,'') not in ('F','T','P') and c.Clear IS NOT NULL
	and c.ishidden = 0
	order by crimid asc


END
